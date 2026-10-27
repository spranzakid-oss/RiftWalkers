# Project status

Last updated: 2026-10-27

## Current task: authoritative design baseline (documentation only)

The supplied full-game design prompt is now preserved in
[docs/approved-design-prompt.md](docs/approved-design-prompt.md). Start at
[GAME_DESIGN.md](GAME_DESIGN.md) for all 15 requested design documents and
[BUILD_PLAN.md](BUILD_PLAN.md) for the development order. Machine-readable data
in `config/design` represents all 14 families, 28 branches, and 70 long-term
forms, plus provisional economy examples. Unspecified assignments stay null/TBD.
No new gameplay, assets, purchases, or runtime balance changes were made.

Before edits, native fetch and remote reference checks verified main at
`a27d8f1ffdb8721a528f0b258ef76da6a77a1762`. The working tree was clean, and
`development/authoritative-design` was created from that exact main. The completed
foundation and generic combat implementation are preserved. Continuing latest-main,
tracking, and new-PR requirements are recorded in AGENTS.md and
[docs/development-workflow.md](docs/development-workflow.md).

Design validation: 13 tests pass, including exact roster/kit transcription,
branch references, provisional economy arithmetic, links, and invalid-data cases.
The full existing check suite is recorded in TEST_LOG.md. All future balance
values and kits remain provisional; the 70-form list is not a launch requirement.

Delivery: design commit `b37a3d7` was pushed to `development/authoritative-design`.
The new `gh pr create` attempt returned `Post https://api.github.com/graphql:
Forbidden`; **no design PR was opened by this session**. The reviewable branch
and [prepared description](docs/design-pull-request.md) are available. Open a
new GitHub pull request from this branch into main; check actual hosted CI before
merging. Local checks passed; hosted CI has not been observed here.

## Preserved milestone: M1 — Generic playable combat prototype

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

Implementation commit: `be0f2ba`. The combat branch was subsequently merged
through pull request #2, verified in the latest main commit above. The previous
CLI creation attempt was blocked; that historical failure does not mean the
later web-created PR is still missing. The old prepared description remains in
[docs/combat-pull-request.md](docs/combat-pull-request.md) as historical context.

Five Python packaging tests and 28 Luau policy tests pass; all eight source/test
Luau files compile, and pure module analysis passes. See [TEST_LOG.md](TEST_LOG.md).
These results do not validate Roblox physics, input hardware, or camera feel.

## Next incomplete task

Review the new design documents and open questions. For the next gameplay task,
on Windows or macOS follow [docs/combat-prototype.md](docs/combat-prototype.md)
to build/open the place and run the **solo Studio acceptance checklist**, then
the local-server **two-player** and controller checks. Record the Studio version,
results, and any Output errors. Add reproducible failures to BUGS.md and fix them
before expanding the prototype. Then scope the normalized Thundermaw/Worldforge
comparison in BUILD_PLAN.md; these named fighters are designed, not implemented.

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

M0 foundation setup was merged into `main` through pull request #1 and the generic
M1 implementation through #2. The previous
empty-project Studio check is carried forward into the stronger M1 acceptance
check rather than marked as performed. M1 is not fully accepted until those
manual results are recorded. No Rift Walking, evolution, monetization,
persistence, extra fighters, or additional game modes were implemented.
