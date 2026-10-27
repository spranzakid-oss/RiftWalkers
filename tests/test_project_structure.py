"""Validate the Rojo configuration and the Roblox place it actually builds."""

from pathlib import Path
import json
import shutil
import subprocess
import tempfile
import tomllib
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]


def children(item):
    """Index direct Roblox children by their Explorer names."""
    return {
        child.findtext("./Properties/string[@name='Name']"): child
        for child in item.findall("Item")
    }


class ProjectStructureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        rojo = shutil.which("rojo")
        if rojo is None:
            raise RuntimeError("Rojo is missing. Follow README.md, then run rokit install.")
        tools = tomllib.loads((ROOT / "rokit.toml").read_text())["tools"]
        expected_version = tools["rojo"].rsplit("@", 1)[1]
        version = subprocess.run(
            [rojo, "--version"], capture_output=True, text=True, check=True, timeout=10
        ).stdout.strip()
        if version != f"Rojo {expected_version}":
            raise RuntimeError(f"Expected Rojo {expected_version} from rokit.toml; got {version}.")
        cls.project = json.loads((ROOT / "default.project.json").read_text())
        with tempfile.TemporaryDirectory(prefix="riftwalkers-test-") as directory:
            place = Path(directory) / "RiftWalkers.rbxlx"
            result = subprocess.run(
                [rojo, "build", "default.project.json", "--output", str(place)],
                cwd=ROOT,
                capture_output=True,
                text=True,
                timeout=60,
                check=False,
            )
            if result.returncode != 0:
                raise RuntimeError(f"Rojo build failed:\n{result.stdout}\n{result.stderr}")
            cls.place = ET.parse(place).getroot()
            sync_place = Path(directory) / "RiftWalkersSync.rbxlx"
            subprocess.run(
                [rojo, "build", "sync.project.json", "--output", str(sync_place)],
                cwd=ROOT,
                check=True,
                capture_output=True,
                text=True,
                timeout=60,
            )
            cls.sync_place = ET.parse(sync_place).getroot()

    def test_source_paths_are_present_and_confined_to_repository(self):
        paths = []

        def visit(node):
            if not isinstance(node, dict):
                return
            if "$path" in node:
                path = (ROOT / node["$path"]).resolve()
                self.assertTrue(path.is_relative_to(ROOT), f"Path escapes repository: {path}")
                self.assertTrue(path.is_dir(), f"Missing source directory: {path}")
                paths.append(path.relative_to(ROOT).as_posix())
            for value in node.values():
                visit(value)

        visit(self.project["tree"])
        self.assertCountEqual(paths, ["src/client", "src/server", "src/shared"])

    def test_built_place_separates_server_and_client(self):
        services = children(self.place)
        server_service = services["ServerScriptService"]
        self.assertEqual(server_service.attrib["class"], "ServerScriptService")
        self.assertEqual(children(server_service)["Server"].attrib["class"], "Folder")
        starter_player = services["StarterPlayer"]
        self.assertEqual(starter_player.attrib["class"], "StarterPlayer")
        player_scripts = children(starter_player)["StarterPlayerScripts"]
        self.assertEqual(player_scripts.attrib["class"], "StarterPlayerScripts")
        self.assertEqual(children(player_scripts)["Client"].attrib["class"], "Folder")
        self.assertNotIn("Server", children(services["ReplicatedStorage"]))

    def test_built_place_exposes_shared_folder(self):
        storage = children(self.place)["ReplicatedStorage"]
        self.assertEqual(storage.attrib["class"], "ReplicatedStorage")
        self.assertEqual(children(storage)["Shared"].attrib["class"], "Folder")

    def test_playable_entrypoints_and_modules_are_packaged(self):
        services = children(self.place)
        server = children(services["ServerScriptService"])["Server"]
        self.assertEqual(children(server)["Main"].attrib["class"], "Script")
        for module in ("World", "CombatService"):
            self.assertEqual(children(server)[module].attrib["class"], "ModuleScript")
        player_scripts = children(services["StarterPlayer"])["StarterPlayerScripts"]
        client = children(player_scripts)["Client"]
        self.assertEqual(children(client)["Controller"].attrib["class"], "LocalScript")
        self.assertEqual(children(client)["CombatCamera"].attrib["class"], "ModuleScript")
        shared = children(services["ReplicatedStorage"])["Shared"]
        for module in ("Config", "CombatRules"):
            self.assertEqual(children(shared)[module].attrib["class"], "ModuleScript")

    def test_development_files_are_not_shipped(self):
        names = {
            item.findtext("./Properties/string[@name='Name']")
            for item in self.place.iter("Item")
        }
        for name in (".gitkeep", "docs", "config", "tests", "AGENTS", "README"):
            self.assertNotIn(name, names)

    def test_sync_profile_packages_only_startup_scripts_and_shared_modules(self):
        services = children(self.sync_place)
        server = children(services["ServerScriptService"])["Server"]
        player_scripts = children(services["StarterPlayer"])["StarterPlayerScripts"]
        client = children(player_scripts)["Client"]
        for container, expected_class, marker in (
            (server, "Script", "[Rift Walkers][SERVER] Rojo sync OK"),
            (client, "LocalScript", "[Rift Walkers][CLIENT] Rojo sync OK"),
        ):
            self.assertEqual(set(children(container)), {"Startup"})
            startup = children(container)["Startup"]
            self.assertEqual(startup.attrib["class"], expected_class)
            self.assertIn(marker, startup.findtext("./Properties/*[@name='Source']", ""))
        shared = children(services["ReplicatedStorage"])["Shared"]
        self.assertEqual(shared.attrib["class"], "Folder")
        self.assertTrue(children(shared))
        for module in children(shared).values():
            self.assertEqual(module.attrib["class"], "ModuleScript")
        scripts = [item for item in self.sync_place.iter("Item") if item.attrib["class"] in {"Script", "LocalScript"}]
        self.assertEqual(len(scripts), 2, "First-sync place must not execute combat bootstraps")


if __name__ == "__main__":
    unittest.main(verbosity=2)
