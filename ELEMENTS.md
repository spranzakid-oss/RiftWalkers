# Elements

**Status:** Approved design direction; elemental gameplay is planned, not implemented.
The balance multipliers below are **Provisional**. See [GAME_DESIGN.md](GAME_DESIGN.md)
for scope and document status definitions.

## Approved vocabulary

The seven base elements are:

| Base elements |
| --- |
| Fire |
| Water |
| Air |
| Earth |
| Light |
| Shadow |
| Spirit |

The 21 approved hybrid names are:

| Hybrid names |
| --- |
| Steam |
| Lightning |
| Magma |
| Solar |
| Ash |
| Soulfire |
| Frost |
| Bloom |
| Purity |
| Abyss |
| Renewal |
| Sand |
| Aurora |
| Veil |
| Echo |
| Crystal |
| Blight |
| Golem |
| Eclipse |
| Celestial |
| Phantom |

A hybrid is an approved elemental identity. The name alone does not establish
which two base elements combine to make it, whether more than two are involved,
or whether players craft it. Hybrid recipes and acquisition rules remain **TBD**.
Some approved hybrids do not yet appear in a roster branch; do not invent extra
creatures just to assign every hybrid a family.

## Initial damage tuning

| Relationship | Initial multiplier | Status |
| --- | --- | --- |
| Effective | 1.15× | **Provisional; requires balance testing** |
| Resisted | 0.9× | **Provisional; requires balance testing** |

For illustration only, if a move's base damage is 100, applying only the supplied
effective multiplier gives 115 and applying only the resisted multiplier gives
90. The base value 100 is an arithmetic example, not an approved move value.
Actual damage ordering, rounding, interaction with combo scaling and guard,
stacking, caps, and how neutral interactions behave remain **TBD**.

No complete effectiveness/resistance chart was supplied. Do not infer a chart
from another game, elemental names, or familiar real-world relationships. The
first implementation needs an explicitly reviewed matchup table and tests that
cover every approved interaction. Server combat must own the final calculation.

## Creature typing and progression

[CREATURES.md](CREATURES.md) preserves the hybrid direction attached to each
approved evolution branch. That direction is not an invented per-stage typing
assignment. The roster data leaves exact per-form base elements unassigned
until those mappings are approved. A branch's label can inform its themed Trial,
but Trial details and hybrid conversion rules are still unfinalized.

Rift regions include Ember, Tidal, Gale, Terra, Light, Shadow, and Spirit, with
hybrid regions later; see [RIFTS.md](RIFTS.md). Region names do not by themselves
supply a complete enemy typing or reward table.

Use distinct names in data and UI for the **Echo element** and **Character Echoes**,
the acquisition resource. One is a type; the other is progress toward earning a
specific creature. They must not share an ambiguous identifier or inventory label.

## PvE synergy and competitive fairness

Elemental PvE synergy is part of the optional duo design; the actual effects and
magnitudes require tests and are **TBD**. Solo access to every creature and
evolution must remain intact. See [COOP.md](COOP.md).

Do not assume the prototype's equal-power Thundermaw/Worldforge test defines
ranked elemental balance. PvP power rules, matchup fairness, and progression
normalization need explicit decisions in [PVP.md](PVP.md) and
[MATCHMAKING.md](MATCHMAKING.md). Paid progression must not create a PvP combat
advantage; no paid elemental effectiveness bonuses are approved.

## Data and validation

[config/design/roster.json](config/design/roster.json) is the machine-readable
source for the approved element and hybrid name lists. It does not implement
elemental calculations in the runtime. Validate unique vocabulary, valid branch
hybrid references, and the complete roster before merging changes. Matchup and
recipe validation must be added when those definitions are actually approved.
