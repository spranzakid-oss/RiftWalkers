# Matchmaking design

Status: **approved_direction** for skill-, creature-power-, and connection-aware
matching. The queue and rating systems are **planned**, not implemented. Any
future tuning numbers are **provisional**. See [GAME_DESIGN.md](GAME_DESIGN.md)
for authority, scope, and status definitions.

## Goals

Help players find understandable, reasonably competitive 1v1 matches without
making poor connections or large power gaps invisible. Casual and ranked share
the combat engine but may need different queue policies. Friend duels use
explicit invitations rather than an ordinary public queue.

The owner approved three matching considerations:

| Consideration | Meaning | Unfinalized decision |
| --- | --- | --- |
| Skill | A player's demonstrated combat ability | Rating model, initial estimate, placements, uncertainty, and update formula |
| Creature power | The effective combat strength of the selected creature | Power formula, progression inputs, normalization, and acceptable gap |
| Connection | A connection suitable for responsive real-time combat | Supported regions, measurement, thresholds, and fallback policy |

No rating equation, numeric search band, queue timeout, or latency threshold has
been finalized. Do not turn the table into arbitrary production constants.

## Fairness decisions to resolve first

Initial Thundermaw/Worldforge tests normalize power so their contrasting styles
can be evaluated. That test setup does **not** decide whether released ranked
play normalizes creatures, uses earned progression, or combines the two.

Before implementation, define what affects effective power and how it interacts
with rarity, evolution, elements, mastery, and paid acceleration. Preserve the
promise of no paid PvP combat advantage. If a design would let a paid boost
change a ranked combat outcome through power, resolve that conflict before
enabling the mode; matchmaking alone is not proof of fairness.

The ranked unlock must use modest early milestones without a win requirement.
The server checks eligibility. Actual unlock steps are TBD and documented in
[PVP.md](PVP.md) when chosen.

## Proposed queue flow

The following is a proposed implementation sequence, not a finalized algorithm:

1. The client requests a mode and fighter; the server validates mode access,
   ownership, availability, and the server's current fighter definition.
2. Create one authoritative queue ticket per player and prevent duplicate entry.
3. Evaluate candidates using skill, effective power, and connection information.
   Broaden a search only within explicit, tested fairness limits.
4. Reserve a compatible pair atomically so one player cannot enter two matches.
5. Load both players, handle failure or cancellation, and begin only after the
   required server readiness checks succeed.
6. Let the authoritative match service finalize results. Remove expired or
   cancelled tickets and restore an understandable player state.

Atomic reservation means the system commits the pair as one operation. The
required platform services, ticket expiry, cross-server coordination, and retry
rules are TBD and must be designed before public deployment.

## Connection and population handling

Prefer compatible connections rather than silently stretching a latency limit
until any opponent can be found. **Proposed UX:** explain when a search is taking
longer and offer an explicit cancellation path. Do not promise a fixed wait time.
Connection measurement and privacy handling must use supported platform data;
never trust a client-supplied latency number as the sole authority.

Low population, region availability, repeated pairing, newly created accounts,
deliberate rating manipulation, and party/friend availability need evaluation.
Their mitigation rules are TBD rather than invented penalties or rank tiers.
Casual and ranked search relaxation policies must be reviewed independently.

## Validation and observability

Record enough non-secret operational evidence to understand queue wait,
connection quality, skill/power gaps, cancellation, reservation failures, and
match completion. Exact metrics, retention, and platform telemetry choices are
TBD; do not include personal credentials or unnecessary private data in logs.

Tests must cover duplicate queue requests, fighter changes after queue entry,
ineligible ranked players, concurrent reservations, cancellation races,
disconnects while queued/loading, stale tickets, and unavailable servers. Fairness
and latency require actual multiplayer measurements, not only simulated pairs.

The current repository has no public queue, ratings, region selection, or
matchmaking service. See [ARCHITECTURE.md](ARCHITECTURE.md),
[TESTING.md](TESTING.md), and [BUILD_PLAN.md](BUILD_PLAN.md) before implementation.
