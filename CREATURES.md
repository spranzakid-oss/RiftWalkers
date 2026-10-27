# Creatures

**Status:** Approved design direction; roster content is planned, not implemented.
All move kits and unspecified balance are **Provisional**. See [GAME_DESIGN.md](GAME_DESIGN.md) for the document hierarchy and scope.

## Long-term roster

A **family** starts with one base creature and has two evolution paths. Each path
adds a middle and an Apex form. The base is shared by both paths:
**14 base forms + 28 middle forms + 28 Apex forms = 70 unique forms**.
These 14 families and 28 branches are a long-term roadmap, not a launch roster
requirement. Release one carefully developed family at a time after the initial
playable slice proves the combat and progression loop.

| Base family | First branch | Hybrid direction | Second branch | Hybrid direction |
| --- | --- | --- | --- | --- |
| Embercub | Embercub → Lavapaw → Caldera Rex | Magma | Embercub → Voltclaw → Thundermaw | Lightning |
| Kilnox | Kilnox → Sunforge → Helioforge | Solar | Kilnox → Pyresoul → Phoenixen | Soulfire |
| Dripple | Dripple → Frostfin → Glaciadon | Frost | Dripple → Mossgill → Tidebloom | Bloom |
| Tidalyn | Tidalyn → Abyssail → Leviadusk | Abyss | Tidalyn → Vaporin → Tempestume | Steam |
| Zephy | Zephy → Stormlet → Thunderwing | Lightning | Zephy → Dunerun → Sandstrider | Sand |
| Veystrix | Veystrix → Nightgale → Veilreaper | Veil | Veystrix → Resonair → Sonifury | Echo |
| Pebblit | Pebblit → Crysthorn → Gemgolem | Crystal | Pebblit → Rotroot → Blightback | Blight |
| Terragon | Terragon → Magmarok → Worldforge | Magma | Terragon → Groveguard → Worldroot | Bloom |
| Glimlet | Glimlet → Lustrill → Pearltide | Purity | Glimlet → Dayflare → Sunlumen | Solar |
| Solari | Solari → Prismane → Crownprism | Crystal | Solari → Sunseraph → Dawnarch | Solar |
| Duskit | Duskit → Undertide → Abyssfang | Abyss | Duskit → Shademist → Nightslip | Veil |
| Nocthorn | Nocthorn → Phantomire → Dreadwraith | Phantom | Nocthorn → Gravemoss → Ruinshade | Blight |
| Wispin | Wispin → Etherling → Ghostlight | Phantom | Wispin → Echowisp → Reverbloom | Echo |
| Eidolon | Eidolon → Soulbrand → Astrablaze | Soulfire | Eidolon → Whisperwind → Choirgeist | Echo |

The parenthesized hybrid names supplied by the design brief identify a branch’s
direction. They do not specify exact typing for every stage or a crafting recipe.
Per-form base elements and rarity assignments remain **TBD**; names and list
ordering are not enough to invent those assignments.

## Collection and access

- Every creature and every evolution remains obtainable through gameplay.
- The tutorial offers a choice of **Embercub, Zephy, or Pebblit**.
- Discovery quests reveal creatures and open targeted Hunts that guarantee Character Echoes.
- Earlier forms remain selectable after evolution; evolution must not remove that choice.
- No creature or evolution requires co-op or a paid purchase.
- Requirements, resource examples, and provisional time targets are described in
  [ECONOMY.md](ECONOMY.md) and [EVOLUTION.md](EVOLUTION.md).

The approved rarity labels are Common, Uncommon, Rare, Epic, Legendary, and
Mythic. Which creature has which rarity, and how rarity affects acquisition or
power beyond the supplied examples, remain unfinalized. Do not assign rarities
to fill an empty field or treat rarity as an approved PvP advantage.

## First contrasting prototype fighters

The next character-specific combat slice should test Thundermaw and Worldforge.
Their power is to be normalized for the initial prototype comparison, so the
test isolates mobility, timing, and role instead of progression strength.
Normalization values and the exact implementation are **Provisional / TBD**.
Neither fighter’s named kit is implemented by this documentation task. The
existing Milestone 1 code still uses its generic temporary test fighter.

### Thundermaw — fast Lightning rushdown

**Provisional kit; requires playtesting.** Rushdown means a fighter that prefers
to close distance and maintain pressure. Supplied kit names:

- Momentum Charge
- Spark Claw
- Volt Breaker
- Rising Fang
- Arc Dash
- Static Burst
- Thunder Dive
- Flash Step
- **Stormbreaker — ultimate**

### Worldforge — slow armored Magma bruiser

**Provisional kit; requires playtesting.** A bruiser trades some mobility for
close-range presence. Armor behavior, limits, and counterplay are not finalized.
Supplied kit names:

- Stoneguard
- Stonebreaker
- Titan Slam
- Crag Uppercut
- Molten Charge
- Eruption Field
- Meteor Drop
- Bedrock Counter
- **Worldbreaker — ultimate**

Only the ultimate roles are explicitly assigned in the brief. Other names are
not yet assigned to passives, light/heavy moves, the two special slots, cancels,
or defensive actions. Their damage, timing, reach, cooldowns, animations, visual
effects, and move interactions remain **TBD**, not missing finalized assets.

## Machine-readable roster and change rules

[config/design/roster.json](config/design/roster.json) stores the same 14 families,
28 branches, and 70 unique forms. It is design data outside the Rojo runtime tree;
it does not unlock or spawn creatures in the existing prototype.

- IDs are stable lowercase names, with spaces changed to underscores; for example,
  `Caldera Rex` uses `caldera_rex`. Display names preserve the approved spelling.
- Each branch references a base, middle, and Apex form belonging to its own family.
- `rarity: null` and `base_element: null` mean **unfinalized**, not a default rarity or element.
- `kit_names` preserves the supplied names without inventing roles; `ultimate`
  records the one explicit slot assignment.
- New entries require source-supported names, valid references, and roster validation.

Before implementing a family, approve a small character specification with its
movement profile, complete move roles, visuals needed, progression requirements,
and acceptance tests. Preserve the long-term roster while keeping each release
small enough to finish and test.
