# Project status

Last updated: 2026-10-27

## Current task: first local Rojo / Studio synchronization

The user has installed Studio and is setting up Rojo on Windows. This task is
limited to synchronization and two startup messages; it adds no combat features.
Before changes, remote main was verified at
`a27d8f1ffdb8721a528f0b258ef76da6a77a1762`. The clean new task branch is
`development/rojo-studio-sync`, based on that exact main. The previous design
baseline remains preserved on `development/authoritative-design`; it was not
merged into main at this check and is not discarded by this separate task.

- Existing `default.project.json` maps shared/server/client folders correctly and
  is unchanged. It includes the prior combat prototype.
- New `sync.project.json` maps Shared modules plus only Server.Startup and
  Client.Startup, for the user's first connection check without running combat.
- Tiny server/client scripts print distinct `[Rift Walkers]` messages at startup.
- Rojo 7.6.1 is installed in the cloud at `/workspace/.tools/rojo/7.6.1/rojo`.
  Windows installation is unknown until the user runs `rojo --version` there.
- Full Windows commands, plugin clicks, Output checks, and saved-file sync proof
  are in [docs/windows-rojo.md](docs/windows-rojo.md).
- Six packaging tests, 28 existing rule tests, compilation, and builds pass.
  The startup-only CLI server responds correctly. Studio execution is **unverified**.

Next: the user follows the Windows guide, confirms both startup messages and a
saved local edit in Studio, and reports the actual Studio version/results. Do
not check off Studio synchronization or startup execution until that happens.

## Preserved milestone: M1 — Playable combat prototype

Implementation and cloud validation are complete; manual Roblox Studio acceptance
is **pending**. A build is ready for manual testing, not a verified playable release.
The user authorized this milestone after the foundation setup.

Implemented on `development/combat-prototype`:

- One reusable, asset-free R6 test fighter for players, plus a stationary dummy.
- Walking, sprinting, jumping, directional dash, one air dash, and air steering.
- Automatic target selection/cycling and a dynamic camera that frames a pair.
- Data-driven light strings, heavy finishers, and separate aerial moves.
- Server-owned hit timing, geometry, wall checks, damage, stun, and knockback.
- Health/target HUD, procedural attack/stagger poses, hit flashes, damage numbers.
- Arena generation, death/respawn, dummy reset, keyboard/mouse/controller bindings.
- Automated packaging, Luau compilation, and pure combat policy tests in CI.

Implementation commit: `be0f2ba`, subsequently merged into main through pull
request #2. The earlier CLI PR attempt was blocked, but that historical failure
does not undo the later verified merge. The old description remains in
[docs/combat-pull-request.md](docs/combat-pull-request.md).

Five Python packaging tests and 28 Luau policy tests pass; all eight source/test
Luau files compile, and pure module analysis passes. See [TEST_LOG.md](TEST_LOG.md).
These results do not validate Roblox physics, input hardware, or camera feel.

## Next incomplete task

First complete [the Windows startup-only sync check](docs/windows-rojo.md). Its
Studio result is pending user verification. For later combat acceptance on
Windows or macOS, follow [docs/combat-prototype.md](docs/combat-prototype.md)
to build/open the place and run the **solo Studio acceptance checklist**, then
the local-server **two-player** and controller checks. Record the Studio version,
results, and any Output errors. Add reproducible failures to BUGS.md and fix them
before expanding the prototype.

## Limitations and blockers

- Roblox Studio is unavailable in this Linux environment. No Studio Play, local
  multiplayer simulation, controller hardware check, or engine type analysis ran.
- The 70/30 ground/air mix and movement/combat/camera feel need measured playtests.
- Hit detection uses current server geometry; it has no client rewind or lag
  compensation. The basic travel audit is lenient, not a complete anti-cheat.
- The open-top arena supports camera side/overhead fallbacks. Arbitrary enclosed
  future maps may constrain framing and require additional camera work.
- The GitHub API endpoint is blocked in this environment. Git branch push works;
  actual pull-request creation remains separate from preparing/pushing the branch.

## Completed and deferred work

M0 foundation setup was merged into `main` through pull request #1. The previous
empty-project Studio check is carried forward into the stronger M1 acceptance
check rather than marked as performed. M1 is not fully accepted until those
manual results are recorded. No Rift Walking, evolution, monetization,
persistence, extra fighters, or additional game modes were implemented.
