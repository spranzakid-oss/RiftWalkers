# Proposed pull request: Add Milestone 1 arena combat prototype

Base: `main` · Compare: `development/combat-prototype`

The foundation had no executable game. This change adds an asset-free arena
combat prototype with one reusable test fighter and a stationary training dummy,
ready for manual Roblox Studio testing.

- Add walking/sprinting/jumping, directional ground and limited air dashes,
  keyboard/mouse/controller bindings, target cycling, and two-fighter camera framing.
- Add configurable light strings, heavy finishers, aerial moves, health, stun,
  knockback, feedback/HUD, death/respawn, and dummy resets.
- Keep combat decisions on the server: validate request types, rate, state,
  timing, hit geometry, wall obstruction, and per-swing deduplication. Clients
  predict presentation/movement but never report damage or successful hits.
- Document controls, fighter profiles, known limitations, and a concrete solo,
  two-player, camera, and controller acceptance matrix. Update project handoff.

Validation: 5 Python packaging tests and 28 actual Luau policy tests pass; all
8 Luau source/test files compile; pure module analysis and Rojo build pass.
GitHub Actions runs these checks and uploads the generated place on success.

Roblox Studio playtesting, engine API analysis, local multiplayer simulation,
controller hardware, and the 70/30 combat-balance measurement have **not run**.
Manual acceptance is pending. No extra fighters, Rift Walking, evolution,
monetization, or persistence are included. Basic travel auditing is not a full
anti-cheat, and hit detection does not provide historical lag compensation.

Reviewers should follow [combat-prototype.md](combat-prototype.md) and record
results before accepting the milestone. This file is a prepared description;
it is not evidence that a GitHub pull request has been opened.
