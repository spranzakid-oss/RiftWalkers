"""Run the same portable checks locally and in CI. Missing tools fail the run."""

from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def run(*command):
    print("+ " + " ".join(str(arg) for arg in command), flush=True)
    subprocess.run(command, cwd=ROOT, check=True)


def main():
    for tool in ("rojo", "luau", "luau-compile", "luau-analyze"):
        if shutil.which(tool) is None:
            raise SystemExit(f"Missing {tool}. Follow tests/README.md to install the pinned tools.")
    run(sys.executable, "tests/test_project_structure.py")
    sources = sorted(ROOT.glob("src/**/*.luau")) + sorted(ROOT.glob("tests/*.luau"))
    run("luau-compile", "--null", *(path.relative_to(ROOT) for path in sources))
    print(f"Compiled {len(sources)} Luau source/test files.", flush=True)
    # The standalone analyzer has no Roblox engine types; analyze only pure modules.
    run("luau-analyze", "src/shared/Config.luau", "src/shared/CombatRules.luau", "tests/combat_rules.spec.luau")
    run("luau", "tests/combat_rules.spec.luau")
    (ROOT / "build").mkdir(exist_ok=True)
    run("rojo", "build", "default.project.json", "--output", "build/RiftWalkers.rbxlx")
    run("git", "diff", "--check")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        raise SystemExit(error.returncode) from error
