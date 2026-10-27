# Project status

Last updated: 2026-10-27

## Current milestone: M1 — Playable combat prototype

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

Implementation commit: `be0f2ba`. The branch was pushed to GitHub. An actual
`gh pr create` attempt failed with `Forbidden` at `api.github.com/graphql`;
**no combat pull request was opened**. The prepared description is in
[docs/combat-pull-request.md](docs/combat-pull-request.md). Open a pull request
from this branch into `main` using GitHub's web interface when reviewing.

Five Python packaging tests and 28 Luau policy tests pass; all eight source/test
Luau files compile, and pure module analysis passes. See [TEST_LOG.md](TEST_LOG.md).
These results do not validate Roblox physics, input hardware, or camera feel.

## Next incomplete task

On Windows or macOS, follow [docs/combat-prototype.md](docs/combat-prototype.md)
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
