# Optional two-player co-op

**Status:** Approved design direction; co-op Rift systems are planned, not
implemented. Numeric balance below is **Provisional**. See
[GAME_DESIGN.md](GAME_DESIGN.md) and
[config/design/economy.json](config/design/economy.json).

## Access and party size

Co-op supports **at most two players**, an approved scope limit. It is optional:
all content, creatures, and evolutions remain obtainable solo. Do not add a
co-op-only creature, evolution, material, or mandatory assist objective.

Approved features include party invitations, ready checks, individual loot,
revives, combo assists, elemental PvE synergy, and rejoin/disconnect recovery.
An assist allows partners to cooperate during combat; its exact timing, damage,
and interaction with anti-infinite protections are not finalized.

## Party flow

**Proposed flow:** choose a mission, invite a partner, receive an acceptance or
decline, review mission/difficulty, then have both players confirm readiness.
The server validates party membership, capacity, invitation eligibility, and
mission access before starting the shared run.

Invitation duration, friend/privacy rules for co-op, leader transfer, and behavior
when someone changes mission after readying are TBD. These require explicit
acceptance tests; no specific timeout has been approved. Invites must not start
an unwanted session or bypass another player's privacy choice.

## Initial duo scaling

| Property | Starting duo value | Status |
| --- | --- | --- |
| Enemy HP compared with solo | Approximately 170% | Provisional |
| Enemy count compared with solo | Approximately 135% | Provisional |

Do not assume these are tested difficulty equivalents. If both factors were
applied uniformly, the illustrative total enemy-health workload would be
`1.70 × 1.35 = 2.295` times solo, before encounter behavior and rounding.
That calculation is a derived warning for tuning, not an approved new multiplier.

Count rounding, encounter minimums, boss exceptions, enemy damage, and whether
scaling changes when a partner disconnects are TBD. Resolve those decisions
before implementation; repeated joining/leaving must not create easier loot loops.

## Loot, revives, and synergy

Individual loot means a partner cannot take another player's earned reward.
Eligibility, participation rules, checkpoint rewards, and failed-run payouts
still need specifications. No random-chance paid boost is introduced by co-op.

Revives support recovery during a run. Revive time, costs, limits, invulnerability,
and the all-players-down outcome remain unfinalized. Elemental synergy is a PvE
cooperation direction; its combinations and effects have not been approved.

**Proposed safeguard:** server-validate revive range and target state, assist
eligibility, and mission membership. Reuse the combat engine's state and combo
protections instead of letting two clients extend an infinite stun chain.

## Disconnect and rejoin recovery

The approved direction requires recovery, not an invented guaranteed rejoin
window. Rejoin time limits, reservation duration, leader handling, and fallback
after a failed recovery remain TBD.

**Proposed server ledger:** track mission identity, participants, reached
checkpoints, defeat/extraction state, and each participant's confirmed rewards.
On rejoin, restore only verified state that still belongs to the active mission.
Grant each eligible reward once. This is a plan; no persistence or party service
is implemented by the documentation task.

If recovery is unavailable, explain the outcome and apply the eventual documented
checkpoint policy. Never silently erase a confirmed grant or issue duplicate loot.
Boost timers follow eligible active Rift play; disconnect time is not active play.

## Acceptance checks

- Enter and finish the same progression content alone and as a pair.
- Accept, decline, cancel, and expire invites without stale party membership.
- Test ready-state changes, a full party, and restricted/private invitations.
- Test revives, assists, elemental synergy, and simultaneous defeat.
- Disconnect each partner before a checkpoint, after it, and during extraction.
- Rejoin repeatedly and retry grants; confirmed rewards must remain single grants.
- Measure difficulty and time before accepting the Provisional scaling values.

See [RIFTS.md](RIFTS.md), [ECONOMY.md](ECONOMY.md), and [TESTING.md](TESTING.md).
