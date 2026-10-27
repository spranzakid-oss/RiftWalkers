# Roadmap

A checked task has implementation and available evidence. Manual acceptance
stays unchecked until actually performed. The user's combat request replaces the
original placeholder M1–M3 plan with the concrete milestone below.

## M0 — Project foundation (complete)

- [x] Create the Rojo source, documentation, configuration, and test layout.
- [x] Add contributor instructions and progress/decision/bug/test records.
- [x] Pin Rojo and run packaging tests and an actual place build.
- [x] Commit, push, and merge the foundation through pull request #1.

The original empty-project Studio check was not run in the cloud; it is included
in M1's stronger playable acceptance checklist below.

## M1 — Playable combat prototype (implemented; manual acceptance pending)

- [x] Document the authorized prototype, controls, architecture, and acceptance checks.
- [x] Create one reusable temporary fighter, arena, stationary dummy, and respawns.
- [x] Implement ground movement, sprint, jump, dash, and limited aerial movement.
- [x] Implement two-fighter camera framing and target selection.
- [x] Implement server-validated light/heavy attacks and configurable combo strings.
- [x] Implement health, damage, stun, knockback, and readable placeholder feedback.
- [x] Bind keyboard/mouse and controller actions.
- [x] Run packaging checks, Luau compilation, pure rule tests, and a Rojo place build.
- [ ] Run solo Studio acceptance, including Output and camera checks.
- [ ] Run two-player local-server acceptance and compare damage on both clients.
- [ ] Run controller hardware checks and record actual results.
- [ ] Measure responsiveness and ground/air balance; tune and fix confirmed issues.
- [ ] Create/review the combat pull request and merge when accepted.

Start with the first manual check in [docs/combat-prototype.md](docs/combat-prototype.md).
Do not describe the milestone as playtested or accepted before those results exist.

## M2 — Plan the next slice (not started)

- [ ] Use M1 test results and the user's direction to choose the next small slice.
- [ ] Write its limits and acceptance checks before implementation.
- [ ] Decide whether a character-specific moveset or another system is appropriate.

Rift Walking, evolution, monetization, additional fighters, and broader PvP
systems remain future work. This roadmap alone does not authorize them.

## Session handoff

Read AGENTS.md and PROJECT_STATUS.md first. Continue the next incomplete task in
scope, document blockers, and keep passed/failed/unrun results distinct. If Studio
is unavailable, complete useful independent work without pretending manual checks ran.
