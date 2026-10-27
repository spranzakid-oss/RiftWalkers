# Instructions for Codex and contributors

## Project and current scope

Rift Walkers is a Roblox creature-fighting and exploration game written in Luau.
The current milestone is the first playable arena combat prototype. The user
authorized one test fighter, movement, camera, basic combat, and a training dummy
after the foundation task. Do not treat planned features as implemented or
manual Studio checks as completed. Rift Walking, evolution, monetization, and
additional fighters remain outside this milestone. Follow the current user's
request when deciding what work is authorized.

## Start every session

1. Read `README.md`, `PROJECT_STATUS.md`, `ROADMAP.md`, `DECISIONS.md`, `BUGS.md`,
   and the latest entries in `TEST_LOG.md` before changing files.
2. Inspect `git status --short --branch` and recent commits. Preserve existing user
   changes. Use the existing checkout; cloud tasks are already isolated, so do not
   create a worktree unless the user asks for one.
3. Find the earliest incomplete milestone in `ROADMAP.md`, then its next unchecked
   task. Use `PROJECT_STATUS.md` for the latest handoff and blockers. Continue that
   task within the user's authorized scope instead of restarting finished work.
4. Briefly explain the intended change and checks in beginner-friendly language.
   If a task is blocked, record the exact blocker and continue useful independent
   work in scope. Ask only when a missing decision or permission prevents progress.
   Never invent a Studio test result or silently skip a blocked milestone.

## Folder ownership and Rojo conventions

- `src/client` maps to `StarterPlayer.StarterPlayerScripts.Client`: device-side
  code such as input or UI. Files named `*.client.luau` become LocalScripts.
- `src/server` maps to `ServerScriptService.Server`: trusted server code.
  Files named `*.server.luau` become Scripts.
- `src/shared` maps to `ReplicatedStorage.Shared`: reusable modules visible to
  both sides. Ordinary `*.luau` files become ModuleScripts.
- `docs`, `config`, and `tests` are development files and are not synced to Roblox.
- `.gitkeep` preserves an empty folder in Git; it is not game code. Remove one
  when a real tracked file replaces it in that folder.

Use `--!strict` in new Luau files unless there is a documented reason not to.
Keep modules small and purposeful. Do not add dummy gameplay, empty frameworks,
package managers, or speculative services to make the project appear complete.
For future gameplay, keep authority on the server and validate client requests.
Never put secrets in Git, client code, or shared modules.

## Validate each meaningful change

From the repository root, ensure the Rojo version matches `rokit.toml`. Install
with `rokit install` if needed. Python 3.11+ and the pinned Luau CLI are used only
for development checks; follow `tests/README.md` for installation.

```sh
python3 tests/run_checks.py
```

On Windows, `py -3` can replace `python3`. The runner checks the built structure,
compiles all Luau, analyzes pure modules, runs combat policy tests, and builds
the place in `build`. In this cloud checkout, verified binaries are retained in
`/workspace/.tools/rojo/7.6.1` and `/workspace/.tools/luau/0.744`; add these to
the command's PATH if they are not already available.
Missing tools or a failed build are failures to investigate, not successful or
skipped tests. GitHub Actions runs the same project checks.

When behavior is added, run all relevant existing behavior tests as well. Add
meaningful tests for changed behavior and document any new runner in
`tests/README.md`; the current Python checks do not execute Luau or Roblox.
Use Studio on Windows/macOS for sync checks and playtests. If Studio is unavailable
in the cloud, record that check as **not run**, give the manual steps, and complete
the checks that are available. Never call a cloud build a Studio playtest.

## Keep the handoff accurate

- Update `PROJECT_STATUS.md` with what changed, the current milestone, blockers,
  and one concrete next task. Keep it consistent with `ROADMAP.md`.
- Check roadmap tasks only after their acceptance checks pass. Continue to the
  next incomplete task while it remains in scope; do not expand beyond the
  authorized prototype or silently skip manual acceptance checks.
- Append actual commands, tool versions, dates, counts, and outcomes to
  `TEST_LOG.md`. Distinguish passed, failed, blocked, not run, and not applicable.
- Record reproducible problems in `BUGS.md` with a stable ID, reproduction steps,
  expected/actual behavior, impact, and eventual fix verification. Do not hide or
  delete unresolved bugs. Keep environmental limitations in the status/test log.
- Record consequential architecture or tooling choices in `DECISIONS.md` with
  their reasons. Put feature specifications in `docs` before a large change.
- Update `README.md` and `tests/README.md` when setup or commands change.

## Git and completion

Work on a descriptive development branch. Do not push to `main`, force-push,
discard user changes, or commit generated places, credentials, and local caches.
Run checks before committing; keep commits focused. When asked to commit or
prepare a pull request, do so using available access and report whether the
branch was committed locally, pushed, or has an actual pull request.

Finish with what changed, what checks ran, what remains untested, the branch or
pull request when relevant, and the next incomplete task. Explain technical terms
the first time they matter; the project owner is learning the workflow.
