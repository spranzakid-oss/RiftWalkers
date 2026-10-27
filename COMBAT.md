# Combat design

Status: **approved_direction** from the owner's design brief. Features are
**planned** unless listed as **implemented_unverified** below. Numerical balance
targets are **provisional**. Read [GAME_DESIGN.md](GAME_DESIGN.md) for authority,
scope, and status definitions; this document does not claim Studio playtesting.

## Combat identity

Rift Walkers uses accessible, fast-paced real-time 3D arena combat with original
characters and mechanics. Dragon Ball-style arena games inspire accessibility
and movement. Tekken inspires **two-fighter camera framing only**, not combat
rules, movement planes, or borrowed moves.

The global emphasis is approximately **70% grounded and 30% aerial combat
(provisional design target)**. This is a playtest goal across the game, not a
forced airtime quota. Individual fighters can specialize differently. Grounded
positioning should remain useful while brief launches, jumps, and air movement
create exciting exchanges.

## Core actions and decisions

| Approved action or system | Intended purpose | Status beyond current prototype |
| --- | --- | --- |
| Fast directional movement and forward/back/side dash | Approach, retreat, and change angles | Basic movement/dash implemented_unverified; character tuning planned |
| Dodge | Avoid an attack through a deliberate defensive choice | Planned; invulnerability, cost, and timing TBD |
| Guard | Defend without making dodge the only answer | Planned; guard coverage, resources, and break rules TBD |
| Jump and limited air dash | Short aerial routes without permanent flight | Basic versions implemented_unverified |
| Light and heavy attacks | Easy starting inputs with different commitments | Basic versions implemented_unverified |
| Two specials and an ultimate | Give each fighter a distinctive kit | Planned; bindings, resource rules, and exact slot mapping TBD |
| Counters and launchers | Reward reads and create routes | Basic lifting knockback exists; dedicated counter/launcher rules planned |
| Training dummy, damage and input displays | Make practice and discovery understandable | Dummy/damage feedback/basic input label exist; full input history planned |

A dash is not automatically a dodge: the current prototype grants no explicit
invulnerability. A named kit move does not automatically occupy a special slot.
Future kit assignments must fit the approved controls and be documented.

## States, timing, and combos

An attack has startup, active time, and recovery: the delay before a hit can
occur, the time it can connect, and the wait afterward. Attack states, cancel
windows, hitstun, blockstun, combo scaling, counters, launchers, and anti-infinite
protections are approved systems to develop. Their exact rules are TBD.

**Proposed implementation approach:** express allowed transitions in reusable
state rules, including moving, attacking, guarding, dodging, stunned, and defeated.
A cancel window is a deliberate exception that permits a new action before
normal recovery ends. Accept a cancel on the server only when the move's data
allows it. These state labels and implementation details are proposals, not new
finalized combat rules.

Simple inputs should reveal deeper character-specific strings through practice.
Combo scaling means later hits may contribute less damage; anti-infinite rules
must prevent a victim being trapped forever. Scaling curves, hit limits, launch
limits, escape rules, and counter rewards remain TBD and need playtests.

## Camera and input

The camera must frame both fighters, zoom as separation changes, track height,
and avoid sudden flips. Preserve readable space for positioning and attacks.
Keyboard/mouse and controller are the first supported input methods. Equivalent
combat actions must be available on both; new bindings remain TBD until tested.

The current camera uses target selection/cycling and side/overhead obstacle
fallbacks in an open-top test arena. This is implemented_unverified, not proof
that arbitrary future arenas or camera obstructions have been solved.

## Current repository versus the next fighter slice

The merged M1 code contains **one generic TestFighter**, not Thundermaw or
Worldforge. It has configurable light strings, heavy finishers, aerial attacks,
health, stun, knockback, movement, camera, and a dummy. Its current numeric values
are provisional prototype values, even where the code must use a concrete value.
See [docs/combat-prototype.md](docs/combat-prototype.md) for exact existing
controls and [src/shared/Config.luau](src/shared/Config.luau) for runtime values.

Thundermaw's fast Lightning rushdown and Worldforge's slow armored Magma bruiser
are the first contrasting fighter designs. Their named kits are provisional and
listed in [CREATURES.md](CREATURES.md). Normalize their power for initial tests
so mobility and commitment can be compared; this is not a finalized ranked rule.

## Authority and acceptance

The server decides move legality, hit timing, targets, damage, stun, and results.
Clients may predict presentation and movement without declaring successful hits.
The shared engine must eventually serve both PvP and Rift enemies; mode rules
must not bypass its validation. See [ARCHITECTURE.md](ARCHITECTURE.md).

Before accepting new combat: run automated rules tests, then solo, controller,
and two-player Studio checks. Test attacks through walls, range/height limits,
interruptions, simultaneous inputs, repeated requests, death, and reconnection.
Measure ground/air use and responsiveness rather than declaring the target met.
See [TESTING.md](TESTING.md). No new gameplay is implemented by this design task.
