# RIFT WALKERS — Game design

Design baseline: 2026-10-27. **Approved direction; most systems are planned.**
The exact user brief is preserved in [approved-design-prompt.md](docs/approved-design-prompt.md).
This documentation task adds no gameplay and does not replace completed work.

## Identity and player promise

Rift Walkers is an original Roblox creature collection and evolution game. Its
two main pillars are fast, real-time 1v1 arena combat and elemental Rift Walking
exploration. Combat is the main attraction; Rift Walking is the main way to
acquire and evolve fighters. Every creature and evolution is earnable through
gameplay, without a paywall. Quality comes before roster size.

The intended loop is: discover a creature, unlock its targeted Hunt, earn it,
learn its combat style, gather evolution resources through Rifts, complete its
Trial, then explore or fight using the forms earned. Earlier forms stay selectable.
Starting players choose Embercub, Zephy, or Pebblit during the tutorial.

Combat uses accessible Dragon Ball-like 3D arena action with original creatures
and mechanics. Tekken inspires only the two-fighter camera, not the combat rules.
Keyboard/mouse and controller are the first supported input methods. Mobile is
not a promised part of the first slice.

## How to read these documents

| Label | Meaning |
| --- | --- |
| Approved direction | A requirement supplied by the user; preserve it unless the user changes it. |
| Provisional | An unfinalized balance number or kit that must be tested before being treated as final. |
| Planned | Describes desired behavior, not code that already exists. |
| Implemented, unverified in Studio | Exists in the current prototype, but has not passed manual Roblox acceptance here. |
| Proposed | A suggested technical solution or test policy, not an additional approved game rule. |
| TBD / null | Not specified yet. Null is not zero, free, disabled, or an inferred default. |

All unfinalized balance figures in these documents and design JSON are
**provisional**, including pacing, damage modifiers, resource amounts, grind
targets, and co-op scaling. Fixed structural directions, such as two-player
maximum co-op, named match formats, or the long-term family count, are distinct
from tuning values. No final art, animations, prices, product IDs, matchup chart,
or complete move specifications have been supplied.

If material disagrees, use the latest explicit user direction and record the
resolution in DECISIONS.md. This baseline expresses the archived brief. Record
later approved changes rather than silently editing history. Topic documents
explain the design; JSON is a checkable transcription of roster and provisional
economy values. Runtime `src/shared/Config.luau` remains the source for the
existing generic prototype; documentation does not automatically change it.

## Authoritative document map

| Document | Scope |
| --- | --- |
| [COMBAT.md](COMBAT.md) | Movement, camera, attack states, strings, defense, and training |
| [CREATURES.md](CREATURES.md) | All 14 families, 28 branches, 70 long-term forms, and prototype kits |
| [ELEMENTS.md](ELEMENTS.md) | Base/hybrid elements, rarity names, provisional modifiers, open matchup rules |
| [RIFTS.md](RIFTS.md) | Expedition loop, missions, regions, difficulties, enemies, and failure rewards |
| [COOP.md](COOP.md) | Optional duo play, invitations, revives, loot, and recovery |
| [ECONOMY.md](ECONOMY.md) | Guaranteed unlocks, resource sources, pacing, and example arithmetic |
| [EVOLUTION.md](EVOLUTION.md) | Mastery, Sigils, Guardian materials, Trials, and retained forms |
| [PVP.md](PVP.md) | Casual, invited duels, ranked, results, rematches, and future modes |
| [MATCHMAKING.md](MATCHMAKING.md) | Skill, creature power, connection, and ranked access |
| [MONETIZATION.md](MONETIZATION.md) | Optional acceleration/cosmetics, fairness constraints, and purchase gates |
| [UI_UX.md](UI_UX.md) | Beginner-facing screens, controls, clarity, and accessibility |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Existing code boundaries and proposed full-game services |
| [TESTING.md](TESTING.md) | Automated evidence and future manual acceptance criteria |
| [BUILD_PLAN.md](BUILD_PLAN.md) | Gated development order and the next incomplete task |

Machine-readable design: [roster.json](config/design/roster.json) and
[economy.json](config/design/economy.json). See their [field guide](config/design/README.md).
They are outside the Rojo tree and are not loaded by the game.

## Scope and present implementation

The merged M1 code contains one generic block fighter, a training dummy, an arena,
basic movement, pair camera, light/heavy strings, health, stun, and knockback.
Cloud checks pass in the recorded test log; Studio/controller/two-client
playtesting remains unrun. Thundermaw and Worldforge are approved **future**
contrasting prototypes, with provisional kits and normalized initial test power;
neither is implemented. The generic prototype is retained as the foundation.

The 14-family/70-form roster is a long-term roadmap, not launch scope. Progress
first through combat and two contrasting prototypes, then Ember Rift, one whole
acquisition/evolution journey, optional duo co-op, and PvP. Release later families
one carefully developed family at a time. The separate turn-based 3v3 mode is
later work, not part of the real-time 1v1 slice.

## Design questions to settle before their implementation

| ID | Still open | Implementation gate |
| --- | --- | --- |
| OPEN-01 | Per-form rarity/base-element assignments, hybrid recipes, and full matchup chart | Do not infer assignments from names or roster order. |
| OPEN-02 | Prototype kit roles beyond named ultimates, exact inputs, frame timings, cancels, damage, art, animations | Specify and test the two fighters before treating kits as final. |
| OPEN-03 | Ranked power handling and how accelerated progression avoids indirect paid competitive advantage | Define and verify fairness before enabling progression boosts in a PvP release. |
| OPEN-04 | Other rarity grind targets, full branch costs, region reward coverage, and first complete journey | Validate one end-to-end solo path; a single upgrade example is not a complete economy. |
| OPEN-05 | Exact partial rewards, rejoin windows, timeout durations, duo count rounding, and assist/synergy rules | Define abuse-resistant behavior with tests before those services ship. |
| OPEN-06 | Matchmaking weights, ranked milestone thresholds, disconnect outcomes, ratings, and neutral/stacking elemental rules | Specify them without inventing approved numbers. |
| OPEN-07 | Prices, IDs, boost multipliers, eligible-play criteria, timer handling, and receipt policies | Purchases remain unimplemented and disabled until explicit approval. |

These questions do not block writing this baseline. They do block presenting
unwritten rules or missing assets as finalized. Track subsequent decisions and
actual tests in DECISIONS.md and TEST_LOG.md.
