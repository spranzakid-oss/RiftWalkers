# Machine-readable design baseline

These JSON files record design information. They are **not loaded by Roblox**,
are outside the Rojo mapping, and do not change `src/shared/Config.luau`.
The source brief is [approved-design-prompt.md](../../docs/approved-design-prompt.md).
See [GAME_DESIGN.md](../../GAME_DESIGN.md) for interpretation and open questions.

| File | Meaning |
| --- | --- |
| `roster.json` | Approved long-term direction: 14 families, 28 branches, 70 unique forms; all planned, not a launch requirement. |
| `economy.json` | All numeric balance values are provisional, including economy, elemental multipliers, and duo pacing examples. |

`schema_version` is the data-format version. Stable lowercase IDs connect records
without depending on display names. `null` means unspecified; never read it as
zero or fill it with a guessed rarity, element, price, or unlock cost.

## Roster fields

- `families` name a base form and two branches. Each branch's `form_ids` lists
  base → middle → apex. The shared base counts once: 14 + 28 × 2 = 70 forms.
- `forms` stores each unique ID, display name, family, and stage. Rarity and
  base-element assignments are null because the brief did not assign them.
- `hybrid_direction` preserves the label attached to a branch in the brief. It
  does not invent a recipe or a finalized element for every intermediate form.
- `prototype_fighters` preserves the named provisional kits. `ultimate` is named
  by the user; other action/passive/special slots remain unassigned.
- Lists of base elements, hybrid elements, and rarities define the supplied
  vocabulary, not a completed effectiveness chart or rarity distribution.

## Economy fields

`acquisition` contains Echo examples, `evolution` the Thundermaw upgrade example
and fragment conversion, `hunt_rewards` a Tier II example, `rifts` provisional
duration/scaling, and `apex_active_hours` the only supplied full-journey targets.
`elements` intentionally leaves the neutral multiplier, recipes, and chart null.
`monetization` records constraints and keeps live purchases false with null IDs,
prices, and boost multipliers. It is documentation, not a purchase implementation.

Analysis must state assumptions: the Tier II Hunt has no finalized duration or
Sigil element. Applying its rates to Lightning materials at six minutes per run
is an illustrative scenario, not a guaranteed live reward route. Resources earned
together use the maximum required run count, not a sum of separate grinds.

## Validate an edit

```sh
python3 tests/test_design_data.py
```

Use Python 3.11+ (`py -3` on Windows if needed); no packages are required. The
checks verify counts, unique names/IDs, valid branch links and kit references,
provisional data constraints, economic arithmetic, and documentation links.
They are also included in `python3 tests/run_checks.py` and CI. They do not
prove that pacing is enjoyable or validate unimplemented systems in Studio.
