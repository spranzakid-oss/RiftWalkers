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

    def test_development_files_are_not_shipped(self):
        names = {
            item.findtext("./Properties/string[@name='Name']")
            for item in self.place.iter("Item")
        }
        for name in (".gitkeep", "docs", "config", "tests", "AGENTS", "README"):
            self.assertNotIn(name, names)


if __name__ == "__main__":
    unittest.main(verbosity=2)
