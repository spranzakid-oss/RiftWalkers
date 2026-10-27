# Evolution

**Status:** Approved design direction; evolution gameplay is planned, not
implemented. All costs, rates, and time targets are **Provisional**. See
[GAME_DESIGN.md](GAME_DESIGN.md) and the examples in
[config/design/economy.json](config/design/economy.json).

## What evolution requires

Evolution combines **elemental Sigils**, **creature mastery XP**, **Guardian
Fragments/Cores**, and a **short themed Trial**. This ties collection progress to
playing and learning a creature rather than buying its final form.

Earlier forms remain selectable. The roster's two branches per family are a
long-term content plan, not a requirement to build every branch at launch.
Branch selection, the ownership model for alternate branches, and any switching
costs are TBD; the final rules must preserve gameplay access to every evolution.

Creature rarities, final stat growth, animation sets, artwork, and most evolution
recipes have not been supplied. Do not infer them from names or copy one example
recipe onto the entire roster as if it were approved balance.

## Example: Voltclaw to Thundermaw

| Requirement | Starting amount / condition | Status |
| --- | --- | --- |
| Lightning Sigils | 480 | Provisional |
| Guardian Cores | 12 | Provisional |
| Creature mastery XP | 6,000 | Provisional |
| Themed challenge | Storm Trial completed | Approved example direction; Trial rules TBD |

The example does not specify Thundermaw's rarity. Prototype test access to
Thundermaw is distinct from a shipped acquisition/evolution journey. Normalize
the two contrasting fighters' power for those initial combat tests; do not turn
that prototype rule into an undocumented release-wide progression formula.

## Simultaneous-resource calculation

Use the **Provisional** Tier II Hunt example: 8 Sigils, 100 mastery XP, and
1 Guardian Fragment per successful Hunt, with **5 Fragments per Core**.

| Requirement | Derived successful Hunts from zero resources |
| --- | --- |
| 480 Lightning Sigils | `ceil(480 / 8) = 60` |
| 12 Cores, requiring 60 Fragments | `ceil((12 × 5) / 1) = 60` |
| 6,000 mastery XP | `ceil(6000 / 100) = 60` |

If the same eligible Hunt grants all three resources together, the material
bottleneck is `max(60, 60, 60) = 60` successful Hunts, **not 180**. This assumes
the awarded Sigils and XP count toward the selected recipe and mastery target.
Those attribution rules still need a final specification.

If that Tier II Hunt also takes the separate six-minute Hunt example's duration,
60 clears would equal **6 active hours, derived from Provisional assumptions**.
At the standard expedition target of 6–8 minutes, the same count would be
6–8 active hours if that target applied. Neither calculation includes discovery,
earlier forms, failures, travel, existing resources, or the Storm Trial. The
actual Tier II duration and full journey have not been finalized.

## Long-term Apex pacing

| Rarity | Active-time target to an Apex form | Status |
| --- | --- | --- |
| Common | 7–12 hours | Provisional |
| Uncommon / Rare / Epic / Legendary | Not specified | TBD; do not interpolate as approved balance |
| Mythic | 35–50 hours | Provisional |

These full-journey targets differ from a single material step and the Echo-only
acquisition times. Define where the clock starts, which activities count, and
which prerequisites are included before claiming the examples meet the targets.
Higher-tier Rifts can improve rates; exact improvements remain unfinalized.

## Proposed safe evolution flow

Show the chosen creature, branch, requirements, owned resources, missing items,
and Trial status. Let the player confirm the intended result. The server then
validates ownership, prerequisites, Trial completion, and costs, and performs one
recoverable transaction. A repeated confirmation must not spend twice or grant
duplicate ownership. The client cannot report its own XP or successful Trial.

Whether XP is consumed or only checked as a threshold, whether Trials can be
completed before gathering materials, and how interrupted transactions recover
are TBD. Resolve these questions before coding resource deductions.

Acceptance requires completing one whole solo acquisition/evolution journey,
selecting an earlier form afterward, and testing both valid and rejected requests,
reconnects, duplicate confirmations, and partial failures. See
[CREATURES.md](CREATURES.md), [ECONOMY.md](ECONOMY.md), and [BUILD_PLAN.md](BUILD_PLAN.md).
