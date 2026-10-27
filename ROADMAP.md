# Roadmap

A checked task has implementation or documentation and available evidence. Manual
acceptance stays unchecked until actually performed. GAME_DESIGN.md is the approved
full-game direction; BUILD_PLAN.md gives the gated order. No gameplay was added by
the current design-document task. Preserve the existing generic prototype.

## D0 — Approved design baseline

- [x] Archive the exact supplied design prompt and continuing development workflow.
- [x] Create all 15 requested root design documents with provisional/TBD labels.
- [x] Record all 14 families, 28 branches, and 70 long-term forms in JSON.
- [x] Record and validate provisional economy examples, resource concurrency, and purchase gates.
- [x] Add design validation to the existing automated runner and update tracking.
- [ ] Review and merge the separate design pull request; resolve open questions before their systems ship.

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
- [x] Merge the generic combat implementation into main through pull request #2.

Start with the first manual check in [docs/combat-prototype.md](docs/combat-prototype.md).
Do not describe the milestone as playtested or accepted before those results exist.

## M2 — Two contrasting prototype fighters (designed; not implemented)

- [ ] Complete M1 manual acceptance and fix confirmed issues.
- [ ] Specify unassigned kit roles and test rules for Thundermaw and Worldforge.
- [ ] Implement their provisional kits only in a separately requested coding task.
- [ ] Normalize initial prototype power and test their contrasting styles.

Then follow BUILD_PLAN.md: Ember Rift → one full acquisition/evolution journey →
optional duo → PvP, and later one carefully developed family at a time. The full
70-form roster and turn-based 3v3 are long-term work. Purchases require separate
activation approval. This roadmap does not authorize implementation in a docs task.

## Session handoff

Read AGENTS.md and PROJECT_STATUS.md first. Continue the next incomplete task in
scope, document blockers, and keep passed/failed/unrun results distinct. If Studio
is unavailable, complete useful independent work without pretending manual checks ran.
