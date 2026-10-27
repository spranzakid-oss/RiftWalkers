# PvP design

Status: **approved_direction**; match systems below are **planned**. Existing
generic fighter damage is **implemented_unverified**, not a finished PvP mode.
Numerical balance values remain **provisional**. Authority and terminology are
defined in [GAME_DESIGN.md](GAME_DESIGN.md).

## Formats

PvP means player versus player. Real-time arena combat is the main competitive
format. A separate turn-based 3v3 mode belongs to the later roadmap; it must not
replace the initial real-time combat engine or expand the first release by default.

| Mode | Approved format | Purpose |
| --- | --- | --- |
| Casual 1v1 | Best of three | Approachable play without ranked stakes |
| Invited friend duel | Best of three | Deliberate matches with a chosen friend |
| Ranked 1v1 | Best of five | Competitive progression after an accessible unlock |
| Turn-based 3v3 | Later; detailed rules TBD | Separate future mode |

A best-of-three set ends when someone wins two bouts; best-of-five ends at three
bout wins. “Bout” here means one scored unit in the set. Exact round structure,
timers, draws, overtime, health reset rules, and mode names are TBD; the formats
above do not silently finalize those details.

## Ranked access and fairness

Ranked unlocks through modest early-game milestones **without mandatory wins**.
The actual milestone list and thresholds are TBD. Show progress and requirements
before a player commits time; losing must not make the unlock impossible.

Matchmaking considers skill, creature power, and connection quality; see
[MATCHMAKING.md](MATCHMAKING.md). Do not infer that ranked uses normalized power:
normalization is approved for initial Thundermaw/Worldforge prototype tests only.
Release power normalization, elemental applicability, and progression effects
must be resolved before competitive implementation.

Every creature and evolution is obtainable through gameplay. Paid-only fighters,
moves, or PvP combat advantages are prohibited. Boost design must be checked
against that promise before it can affect a competitive mode; see
[MONETIZATION.md](MONETIZATION.md).

## Friend duel lifecycle

The approved flow includes invitation, accept/decline, expiry, privacy,
disconnect handling, and rematches. **Proposed state model:** invite pending →
accepted → loading → active set → results → optional rematch. Declined, expired,
cancelled, or disconnected paths must lead to a clear terminal state.

The server validates sender, recipient, current availability, accepted invitation,
and whether a pending request is still valid. Duplicate accept messages must not
start duplicate matches. A rematch needs consent from both players and a fresh
server decision; it is not implied by leaving the results screen open.

Exact invite timeout, privacy defaults, blocks/social integration, rejoin window,
and rematch resource policies are TBD. Do not invent a numeric timeout merely to
make this design appear finalized.

## Results and interruption rules

Match scores, winners, rewards, and ranked changes are server-controlled. A client
cannot award itself a win or submit final health as proof. Tie resolution,
disconnect forfeits, abandoned games, server failure, and protected early exits
need explicit mode rules before release.

**Proposed reliability requirement:** make finalization idempotent, meaning the
same result cannot be applied twice when messages or persistence attempts repeat.
Keep the reason for an interrupted set separate from an ordinary combat loss.
Any recovery or refund policy remains TBD; do not promise one without support.

## Player-facing feedback and tests

Show mode, set score, opponent, invitation status, connection/loading state, and
the reason a match ends. Explain ranked unlocks in plain language. Never display
a client-predicted result as final before the server confirms it.

Acceptance must cover both modes' set lengths, ranked access without wins,
accept/decline/expiry, simultaneous invites, privacy restrictions, duplicated
requests, disconnects during every phase, server shutdown, and rematch consent.
Use actual local-server and platform tests as each feature exists. The current
M1 has no queue, invitation, ranked unlock, set scoring, or match-result service.
See [TESTING.md](TESTING.md) and [BUILD_PLAN.md](BUILD_PLAN.md) for implementation gates.
