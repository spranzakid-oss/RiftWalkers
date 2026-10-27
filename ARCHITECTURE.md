# Architecture

**Status:** approved design direction; full-game systems below are planned unless
explicitly marked as existing. Technical service boundaries are **Proposed**,
not implemented infrastructure. Read [GAME_DESIGN.md](GAME_DESIGN.md) for the
design's authority and [BUILD_PLAN.md](BUILD_PLAN.md) for implementation order.

## What the repository already contains

The latest verified `main` baseline for this documentation task is `a27d8f1`,
which includes the combat prototype merged through pull request #2. Preserve it.

| Existing area | Responsibility | Current limitation |
| --- | --- | --- |
| `src/client/Controller.client.luau` | Input, movement/pose prediction, HUD, feedback | One generic test fighter; Studio acceptance pending |
| `src/client/CombatCamera.luau` | Pair framing, targeting, obstruction fallback | Enclosed maps and camera feel need manual testing |
| `src/server/CombatService.luau` | Validate action requests, choose moves, apply hits, damage, stun, knockback | Prototype travel audit, no historical position rewind |
| `src/server/World.luau` | Temporary arena, generic R6 rigs, stationary dummy, respawns | No Rift rooms, named creature assets, or persistent ownership |
| `src/shared/CombatRules.luau` | Testable combo, timing, dash, hitbox, rate-limit policies | No full guard, special, ultimate, or match system |
| `src/shared/Config.luau` | Runtime values and the single fighter registry entry | Starting prototype values, not approved final game balance |

The existing server owns combat decisions. That is a useful foundation, not a
claim of complete anti-exploit protection or production multiplayer readiness.
Thundermaw and Worldforge are design targets; neither is implemented yet.

## Source and design data have different jobs

Rojo maps `src/client`, `src/server`, and `src/shared` into Roblox. Client means
the player's device; server means the trusted game process shared by players.
Anything replicated to clients can be inspected and must not contain secrets.

The root design documents and `config/design/roster.json` and `economy.json` are
development records. They are outside the Rojo tree and are **not runtime game
data**. Editing a JSON requirement does not change live damage or grant items.
Future implementation must deliberately validate and convert the accepted subset
into runtime definitions. Do not automatically replace existing Config values
with the full roster or provisional economy figures.

## Shared combat engine

Approved direction: arena PvP and Rift PvE use the same combat engine. Common
attack states, hit rules, timing, movement limits, and feedback should not be
copied into separate systems that drift apart. Mode-specific policies can choose
opponents, rewards, scaling, and victory conditions around that engine.

The current fighter registry separates combat definitions from movement values.
Future fighters should reuse the input/request path while supplying bespoke
strings, specials, movement profiles, and carefully scoped behavior. A named move
is not an animation, frame specification, or implemented ability. Unique behavior
hooks and animation delivery remain **TBD** until the contrasting-fighter slice.

## Proposed future responsibilities

A service is a code area with one clear job; these names describe boundaries,
not modules to create during this documentation task.

| Planned responsibility | Server-owned facts | Client presentation |
| --- | --- | --- |
| Fighter inventory and progression | Earned forms, mastery, materials, evolution eligibility | Collection, goals, eligible choices |
| Rift sessions | Mission seed/choices, enemy state, checkpoints, extraction and reward claims | Map cues, objectives, reward previews |
| Parties and recovery | Membership, ready state, invite validity, rejoin permission | Invite/ready prompts and recovery messages |
| Match lifecycle | Participants, legal loadouts, round state, results, rematch consent | Queue, countdown, score, result screen |
| Matchmaking | Skill/power/connection inputs and authorized assignment | Queue status and cancel control |
| Entitlements and purchases | Verified receipts, granted resources, eligible boost time | Clearly labeled offers and remaining active time |

No client may submit an authoritative win, unlocked fighter, material balance,
completed Trial, purchase success, or elapsed paid-boost time. Validate both the
request's shape and whether the action is legal in the current server state.
Exact remote contracts, persistence APIs, storage keys, and hosting topology are
**Proposed/TBD**; select them during the relevant implementation slice.

## Persistence and recovery requirements

Planned durable records must distinguish an unlock from selecting a form: earlier
forms remain selectable after evolution. Keep economy changes auditable and
version data so later schema changes do not silently lose a player's progress.
Exact retention, migration, and storage designs remain **TBD**.

Use idempotent grants: processing the same reward or purchase twice must produce
the same final result as processing it once. **Proposed:** give each server result
or receipt a stable identifier and record its application before allowing retries
to grant again. Choose and test an atomic persistence strategy before release.
Do not claim Roblox storage is infallible or that this proposal is implemented.

Co-op and match reconnects must restore only an authorized player's session state.
Prevent duplicate loot, revives, match results, and boost usage after reconnects.
Invitation and recovery tokens should expire and be validated by the server;
timeout values and disconnect penalties are **TBD**, not invented here.

## Privacy, purchases, and release gates

Respect invitation/privacy settings; an invite is not consent to enter a match.
Send clients only information needed for their session or UI. Do not expose
private matchmaking inputs, persistence internals, or account credentials.

Paid progression acceleration must not become paid PvP combat advantage. The
competitive treatment of earned power is unresolved; do not assume ranked
normalization is already approved. See [MATCHMAKING.md](MATCHMAKING.md) and
[MONETIZATION.md](MONETIZATION.md). No live purchase activation is authorized.

Implement one testable slice at a time, retain the existing generic prototype,
and pass [TESTING.md](TESTING.md) before presenting a planned service as complete.
