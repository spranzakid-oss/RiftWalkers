# Acquisition and economy

**Status:** Approved design direction; acquisition and economy systems are
planned, not implemented. Every numeric cost, payout, and pacing example here is
**Provisional**, including values repeated in
[config/design/economy.json](config/design/economy.json). See [GAME_DESIGN.md](GAME_DESIGN.md).

## Permanent gameplay access

Every fighter and evolution must be permanently earnable through gameplay,
without a paywall. Discovery quests reveal creatures and open targeted Hunts.
Hunts grant guaranteed Character Echoes toward acquisition, so players can work
toward a known target rather than depend solely on luck.

The tutorial offers **Embercub, Zephy, or Pebblit** as the starting choice.
Earlier forms remain selectable after evolution. Exact tutorial rewards and
unlock timings remain TBD; choosing a starter must not permanently block other
gameplay-earnable fighters.

Whether Echo ownership is tracked per family or per individual form is not yet
specified. Do not implement an Echo purchase that bypasses an evolution Trial
without an explicit design decision. Creature-specific rarity assignments are
also unfinalized; the rarity table is not an assignment to the named roster.

## Targeted Character Echoes

The following costs and the example Hunt payout are **Provisional**. The
derived run/time columns assume exactly two targeted Echoes from every six-minute
Hunt, no existing Echoes, no boosts, and no additional time between runs.

| Rarity | Echo requirement | Derived Hunts | Derived active time |
| --- | --- | --- | --- |
| Common | 4 | 2 | 12 minutes |
| Uncommon | 10 | 5 | 30 minutes |
| Rare | 24 | 12 | 72 minutes |
| Epic | 60 | 30 | 180 minutes |
| Legendary | 120 | 60 | 360 minutes |
| Mythic | 240 | 120 | 720 minutes |

These calculations concern the example acquisition step, not the full journey to
an Apex form. Mission availability, discovery quests, actual Hunt durations,
evolution prerequisites, and Trial time are not included.

## Resource roles and example Hunt

| Resource | Approved role / unresolved detail |
| --- | --- |
| Character Echoes | Guaranteed targeted acquisition progress; ownership granularity TBD. |
| Elemental Sigils | Evolution material associated with an element. |
| Creature mastery XP | Progress toward mastery requirements; award attribution TBD. |
| Guardian Fragments / Cores | Evolution materials; conversion process still needs UI/transaction rules. |
| Rift Marks | Listed expedition reward; spending uses and sinks remain TBD. |

Example **Tier II Hunt rewards, all Provisional**: 20 Rift Marks, 8 Sigils,
2 targeted Echoes, 100 mastery XP, and 1 Guardian Fragment. The example conversion
is **5 Fragments = 1 Core, Provisional**. “Tier II” has not been mapped to the
named difficulty tiers. Element choice, mastery recipient, and target eligibility
must be explicit in the eventual mission definition.

Resources accumulate simultaneously. Do not add their farming hours as though
the player must run a separate mission for each resource. [EVOLUTION.md](EVOLUTION.md)
shows the bottleneck calculation for the Thundermaw example.

## Pacing, fairness, and measurement

Higher-tier Rifts can improve resource rates. Exact increases, entry conditions,
loss/partial-reward policies, and sinks are not finalized. Balance the unboosted
solo route first. Record actual active time, failures, discovery time, and material
bottlenecks; do not treat the starting spreadsheet as playtest evidence.

Paid progression boosts are allowed only within [MONETIZATION.md](MONETIZATION.md).
They must not change move power or give paid-only access. Faster access can still
affect competitive choice; the PvP fairness policy is unresolved and must be
settled before purchases launch. Ranked power normalization is not approved here.

## Planned transaction safety

**Proposed architecture:** the server validates mission completion and resource
costs, then records a unique grant or transaction ID. Retrying that operation is
idempotent: it has the same result without granting or spending twice. Save
receipts before acknowledging completion, and recover interrupted operations.
No such service or persistent inventory is implemented in this task.

Before implementation, define inventory ownership, conversion rules, capacity,
refund/recovery behavior, versioned balance changes, and the reward ledger.
Validate acquisition, evolution, reconnects, duplicate requests, and boosted
versus unboosted routes. See [ARCHITECTURE.md](ARCHITECTURE.md) and [TESTING.md](TESTING.md).
