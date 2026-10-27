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

## 2026-10-27 — Milestone 1 combat prototype

Environment: Linux x86_64, Python 3.12.14, Rojo 7.6.1, official Luau CLI 0.744.
Luau was installed outside the checkout from the official `luau-lang/luau`
release after SHA-256 verification:
`6506f0852c623aaffcb28494aac16c26dc04a269ea0e16cc0aafc8c8ac79f3ec`.

Command executed from the repository root:

```sh
PATH=/workspace/.tools/luau/0.744:/workspace/.tools/rojo/7.6.1:$PATH python3 tests/run_checks.py
```

| Check | Actual result |
| --- | --- |
| Python project/build suite | Passed: 5 tests, 0 failures, 0 skipped. Real temporary place inspected for executable entrypoints, module classes, correct service placement, and excluded development files. |
| Luau compilation | Passed: all 8 source/test files compiled with `luau-compile --null`. |
| Standalone type analysis | Passed: Config, CombatRules, and the Luau spec analyzed with no findings. Engine-dependent scripts were not typechecked against Roblox APIs. |
| Pure combat rules | Passed: 28 cases, 0 failures, 0 skipped. Covers strings, reset/buffer-related recovery gates, finishers, airborne rules, rejection states, dash limits, geometry, active-window crossing, config integrity, and token bucket behavior. The actual network queue is not simulated. |
| Final Rojo build | Passed: produced `build/RiftWalkers.rbxlx`; generated file is ignored by Git. |
| Whitespace | Passed: `git diff --check`. |
| Independent code review | Completed: server lifecycle/network checks and client input/camera paths reviewed. Corrected window-crossing and camera collision issues; see BUG-001/002. This is not engine execution. |
| GitHub-hosted workflow | Not observed here. The workflow now runs the full runner and uploads the place after a successful run. |
| Studio solo Play and engine API checks | Not run: Studio unavailable on Linux. |
| Two-player local server, network latency, controller hardware | Not run: requires Studio and input hardware. |
| 70/30 ground/air ratio and combat/camera feel | Not measured: starting values need playtests. |
| Development branch delivery | Passed: implementation commit `be0f2ba` pushed to `development/combat-prototype`. |
| Pull-request creation | Blocked: `gh pr create` returned `Post https://api.github.com/graphql: Forbidden`. No PR opened; description prepared in `docs/combat-pull-request.md`. |

Next: run the full manual acceptance matrix in `docs/combat-prototype.md`, then
log actual Studio version/results and any reproducible bugs. Do not treat cloud
policy tests or a built place as proof of Roblox gameplay behavior.

## 2026-10-27 — Authoritative design baseline

Scope: documentation, design-only JSON, semantic validation, and handoff updates.
No gameplay code or runtime values changed. Before edits and again before delivery,
fetch plus `git ls-remote origin refs/heads/main` confirmed
`a27d8f1ffdb8721a528f0b258ef76da6a77a1762`. The new branch is
`development/authoritative-design`, created from that exact main with a clean tree.
Main now includes the prior combat implementation through pull request #2.

Executed in the repository root with Python 3.12.14, Rojo 7.6.1, Luau CLI 0.744:

```sh
PATH=/workspace/.tools/rojo/7.6.1:/workspace/.tools/luau/0.744:$PATH python3 tests/run_checks.py
```

| Check | Actual result |
| --- | --- |
| Design validation | Passed: 13 cases, 0 failed/skipped. Exact 14 families/28 branches/70 forms and named kits match the archived brief. JSON references, provisional values, economic arithmetic, local links, and invalid-data cases checked. |
| Existing packaging suite | Passed: 5 tests, 0 failed/skipped. |
| Existing combat policies | Passed: 28 cases, 0 failed/skipped. |
| Luau compilation / pure module analysis | Passed: all 8 source/test files compile; pure modules/spec analyze cleanly. |
| Rojo build | Passed: generated the existing prototype place in ignored build/. |
| Source preservation | Passed: `git diff --exit-code origin/main -- src default.project.json rokit.toml` reports no differences. |
| Latest-main recheck | Passed: remote main and task merge base agree on the full SHA above; no newer main to integrate. |
| Whitespace | Passed: `git diff --check`. |
| Independent design review | Completed: checked brief coverage, provisional/TBD boundaries, resource concurrency, ranked fairness, and first-journey gaps. No concrete contradictions found. |
| Hosted GitHub CI | Not observed here; the existing workflow runs the updated full runner. |
| Studio/manual behavior | Not run. This task adds no gameplay; previous M1 manual acceptance remains pending. |

Total executed tests: **46 passed**, 0 failed, 0 skipped; compiler/analysis/build
checks are additional operations, not extra test cases. Economic arithmetic is
example consistency, not a measurement of live pacing or proof of full-game balance.
Open design questions are in GAME_DESIGN.md. The exact source prompt is archived;
no missing rarity, asset, recipe, price, or live product was invented.

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
