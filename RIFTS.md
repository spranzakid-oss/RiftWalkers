# Rift Walking

**Status:** Approved design direction; Rift gameplay is planned, not implemented.
All starting durations and reward amounts are **Provisional**. See
[GAME_DESIGN.md](GAME_DESIGN.md) for scope and terminology, and
[config/design/economy.json](config/design/economy.json) for economy examples.

## Purpose and solo access

Rift Walking is the main way to acquire and evolve fighters. Combat is the
game's primary attraction; Rifts give players a reason to explore and develop
their collection. Rifts support solo play and optional two-player co-op. Every
creature, evolution, and progression requirement must remain obtainable solo.

A standard expedition targets **6–8 minutes of active play, Provisional**.
This is a pacing goal, not a proven completion time or a limit on every mission.
Hunts, Trials, higher difficulties, retries, and travel may take different times;
their individual targets remain unfinalized.

## Mission types

| Mission | Approved purpose | Details still needed |
| --- | --- | --- |
| Expedition | Explore a Rift and complete its encounters, event, guardian, and extraction. | Room counts, event selection, and reward amounts. |
| Hunt | Pursue a revealed creature and earn guaranteed targeted Character Echoes. | Exact targets, encounter layouts, and difficulty-specific rewards. |
| Trial | Complete a short themed challenge, including an evolution requirement. | Rules, failure/retry behavior, and duration for each Trial. |

Discovery quests reveal creatures and open their Hunts. They should explain the
next objective clearly rather than leave a beginner searching for a hidden
random drop. Specific quest scripts and unlock conditions are not finalized.

## Expedition flow

The intended sequence is exploration, combat, a Rift event, a guardian encounter,
and extraction. Build rooms from modular, handcrafted layouts, with randomized
encounter choices. This combines deliberate room design with varied runs; it
does not require a fully procedural terrain generator.

**Proposed planning approach:** author room entrances, exits, combat areas, and
valid encounter locations as reusable room data. The server chooses only valid
connections and encounter options. Exact generation rules, room budgets, and
asset specifications remain TBD; no final rooms or artwork are supplied here.

## Regions and difficulty

Approved initial region directions are **Ember, Tidal, Gale, Terra, Light,
Shadow, and Spirit**, followed later by hybrid regions. This is a long-term set,
not a requirement to ship every region in the first slice. The build order starts
with Ember Rift after the contrasting-fighter combat prototype.

Approved difficulty names are **Fractured, Stable, Unstable, Ruptured, and
Primordial**. Enemy power, entry requirements, rewards, and matchmaking rules for
each tier remain unfinalized. The economy's example “Tier II Hunt” is not yet
assigned to one of these names; do not silently equate Tier II with Stable.

## Encounters and shared combat

Approved enemy archetypes are **Striker, Bruiser, Skirmisher, Artillery,
Guardian, and Support**, plus elite enemies and multi-phase bosses. Their exact
attacks, composition budgets, and statistics remain unfinalized. A multi-phase
boss changes its encounter behavior over the fight; no phase counts are locked.

Rift enemies and players use the same underlying combat engine as PvP: consistent
attack states, hit validation, damage rules, and reactions. Enemy decision-making
and mission logic can differ without creating a second, incompatible combat
system. Elemental co-op synergy applies to PvE; it must not silently redefine PvP.

## Rewards, failure, and extraction

Failures grant reasonable partial checkpoint rewards. The exact checkpoint
schedule, eligible rewards, and partial amounts are TBD. An incomplete run is not
automatically equivalent to a full clear, and a reconnect must not duplicate loot.

**Proposed implementation boundary:** the server records reached checkpoints,
mission completion, extraction, and granted rewards. A client displays these
results but cannot claim a guardian kill or supply its own payout. Record the
grant once using a unique mission/reward identifier; replaying the same request
must not award it again. This is architecture guidance, not implemented code.

## Acceptance before this system is called playable

- Complete the same acquisition/evolution journey solo and with optional co-op.
- Check valid rooms, reachable exits, enemy behavior, guardian phases, and extraction.
- Test failure after a checkpoint, reconnect, repeated extraction requests, and
  server interruption without duplicate or missing confirmed rewards.
- Measure run duration and reward rates; revise Provisional values with evidence.

See [COOP.md](COOP.md), [ECONOMY.md](ECONOMY.md), and [BUILD_PLAN.md](BUILD_PLAN.md).
