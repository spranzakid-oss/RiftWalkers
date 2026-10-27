# Test log

Record what actually ran. A planned command is not a passing test. Separate passed, failed, skipped, blocked, and unrun checks. Include the date, command or manual steps, result, and a short explanation.

## 2026-10-27 — Initial project foundation

Environment: Linux x86_64, Python 3.12.14, Rojo 7.6.1. The official Rojo release
archive was downloaded over HTTPS and verified against GitHub's published
SHA-256: `a9542a713036897fdbd0173e7a105ea409658333133c949025fcb6f1a7ca909d`.
The binary is outside the checkout at `/workspace/.tools/rojo/7.6.1/rojo`.
Cloud commands used `PATH=/workspace/.tools/rojo/7.6.1:$PATH` so `rojo` resolves
to that verified version. This is a cloud-local path, not a requirement for
other computers; use Rokit as documented in the README.

| Check | Result | Evidence / next action |
| --- | --- | --- |
| `python3 tests/test_project_structure.py` | Passed | 4 tests executed, 0 failed, 0 skipped. Uses an actual temporary Rojo build to check the hierarchy, server/client separation, shared folder, source paths, and exclusion of development files. |
| `rojo build default.project.json --output build/RiftWalkers.rbxlx` | Passed | Produced the empty Roblox place in ignored `build/`. |
| `rojo serve default.project.json --address 127.0.0.1 --port 34872` | Passed | Local GET `/api/rojo` returned HTTP 200, project name `RiftWalkers`, server version `7.6.1`, and a root instance ID. Test process was stopped afterward. This tests the CLI server, not the Studio plugin. |
| `git diff --check` | Passed | No whitespace errors. |
| GitHub Actions | Not run here | Workflow added. Check its actual result on GitHub after pushing; local validation does not establish a hosted CI result. |
| Roblox Studio smoke test | Not run | Requires Studio on Windows or macOS. Follow M1 in ROADMAP.md. |
| Gameplay tests | Not applicable | Gameplay is intentionally unimplemented. |

The foundation checks validate folder mapping and packaging. They do not simulate a Roblox server or prove gameplay behavior.

## Future entry template

Copy this format when adding results:

```text
Date:
Change or milestone:
Environment and relevant tool versions:
Command or manual steps:
Result (passed / failed / skipped / blocked / not run):
Test count or observed behavior:
Related bug ID, if any:
Remaining checks:
```
