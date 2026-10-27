# Running checks

From the repository root:

```sh
python3 tests/run_checks.py
```

On Windows, `py -3` can replace `python3`. Python 3.11+ is required, with no
third-party packages. The runner exits with failure if a tool is missing or a
check fails; it does not silently skip tests.

## Required tools

- **Rojo 7.6.1:** install Rokit and run `rokit install` as described in the README.
- **Luau CLI 0.744:** download the matching OS archive from the
  [official release](https://github.com/luau-lang/luau/releases/tag/0.744), verify
  its SHA-256 against the release's asset details, and extract it into a tools
  folder outside this repository. Add that folder to your PATH (the list of
  folders your terminal searches for commands). Keep `luau`, `luau-compile`, and
  `luau-analyze` together. On Windows these names end in `.exe`.

For this cloud instance the verified tools already exist. Use:

```sh
PATH=/workspace/.tools/rojo/7.6.1:/workspace/.tools/luau/0.744:$PATH python3 tests/run_checks.py
```

GitHub Actions installs these exact versions and verifies release checksums. The
Linux Luau archive's SHA-256 is
`6506f0852c623aaffcb28494aac16c26dc04a269ea0e16cc0aafc8c8ac79f3ec`.
Use the checksum for your own platform, not the Linux hash for a Windows archive.

## What runs

| Check | What it establishes |
| --- | --- |
| `python3 tests/test_project_structure.py` | 5 tests build a temporary place and inspect script classes, source paths, server/client separation, and excluded development files. |
| `luau-compile --null` over source and test files | All Luau parses and compiles, including engine-dependent code. This does not typecheck Roblox APIs. |
| `luau-analyze` on Config, CombatRules, and the spec | Pure modules/test code pass standalone type analysis. Engine scripts require Studio's Roblox types and are not covered by this check. |
| `luau tests/combat_rules.spec.luau` | 28 behavior cases cover strings, reset timing, finishers, customization, aerial moves, rejection states, dash allowance, geometry boundaries, active-window catch-up, config integrity, and request rate limiting. |
| `rojo build` | Writes `build/RiftWalkers.rbxlx` for manual Studio testing. |
| `git diff --check` | Checks whitespace in changes. |

The Luau tests execute the same pure rules the server calls; they do not duplicate
the rules in Python. Failed assertions fail the command. Build output is ignored
by Git and recreated each run.

## What remains manual

No command above starts a Roblox server, simulates network ownership, validates
engine APIs, exercises the camera, or tests a controller. Follow the concrete
solo and two-player checklist in [docs/combat-prototype.md](../docs/combat-prototype.md).
Record every actual test in TEST_LOG.md and any reproducible failure in BUGS.md.
