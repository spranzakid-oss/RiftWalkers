"""Validate design-only data against the archived brief, without running Roblox."""

from collections import Counter
from copy import deepcopy
import json
import math
from pathlib import Path
import re
import unittest
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
BRIEF = ROOT / "docs/approved-design-prompt.md"
DOCUMENTS = (
    "GAME_DESIGN.md", "COMBAT.md", "CREATURES.md", "ELEMENTS.md", "RIFTS.md",
    "COOP.md", "ECONOMY.md", "EVOLUTION.md", "PVP.md", "MATCHMAKING.md",
    "MONETIZATION.md", "UI_UX.md", "ARCHITECTURE.md", "TESTING.md", "BUILD_PLAN.md",
)


def form_id(name):
    return name.lower().replace(" ", "_")


def source_branches(brief):
    section = brief.split("ROSTER:", 1)[1].split("FIRST PROTOTYPE FIGHTERS:", 1)[0]
    return re.findall(
        r"([A-Za-z][A-Za-z ]*?) > ([A-Za-z][A-Za-z ]*?) > "
        r"([A-Za-z][A-Za-z ]*?) \(([A-Za-z]+)\)", section
    )


def source_elements(brief):
    line = re.search(r"^ELEMENTS: (.+)$", brief, re.MULTILINE).group(1)
    base, rest = line.split(". Hybrids: ", 1)
    hybrids, rest = rest.split(". Rarities: ", 1)
    rarities = rest.split(". Initial ", 1)[0]
    return tuple(part.split(", ") for part in (base, hybrids, rarities))


def validate_roster(data, brief):
    """Return semantic errors; IDs, edges, stages, and supplied names must agree."""
    errors = []

    def require(condition, message):
        if not condition:
            errors.append(message)

    require(data.get("schema_version") == 1, "Unsupported roster schema version")
    require(data.get("status") == "approved_direction", "Roster direction status changed")
    require(data.get("content_status") == "planned_not_implemented", "Roster implies implemented content")
    require(data.get("long_term_not_launch") is True, "Roster must remain a long-term roadmap")
    base, hybrids, rarities = source_elements(brief)
    for field, expected in (("base_elements", base), ("hybrid_elements", hybrids), ("rarities", rarities)):
        require(data.get(field) == expected, f"{field} differs from the approved names/order")

    forms = data.get("forms", [])
    families = data.get("families", [])
    require(isinstance(forms, list), "forms must be a list")
    require(isinstance(families, list), "families must be a list")
    if not isinstance(forms, list) or not isinstance(families, list):
        return errors
    require(len(forms) == 70, "Expected 70 unique forms, not one copy per branch")
    require(len(families) == 14, "Expected 14 base families")
    ids = [entry.get("id") for entry in forms if isinstance(entry, dict)]
    require(len(ids) == len(forms) and len(set(ids)) == len(ids), "Duplicate or malformed form IDs")
    by_id = {entry["id"]: entry for entry in forms if isinstance(entry, dict) and "id" in entry}
    expected_branches = source_branches(brief)
    expected_names = {name for branch in expected_branches for name in branch[:3]}
    require({entry.get("name") for entry in forms if isinstance(entry, dict)} == expected_names,
            "Form names do not preserve the approved roster")
    stages = Counter(entry.get("stage") for entry in forms if isinstance(entry, dict))
    require(stages == {1: 14, 2: 28, 3: 28}, "Expected stage counts 14/28/28")
    for entry in forms:
        if not isinstance(entry, dict):
            require(False, "Malformed form record")
            continue
        require(isinstance(entry.get("name"), str) and entry.get("id") == form_id(entry.get("name", "")),
                f"Invalid form ID/name: {entry.get('id')}")
        require(entry.get("rarity") is None and "rarity" in entry,
                f"Unspecified rarity was invented: {entry.get('id')}")
        require(entry.get("base_element") is None and "base_element" in entry,
                f"Unspecified base element was invented: {entry.get('id')}")

    family_ids, branch_ids, found_edges, references = [], [], set(), Counter()
    for family in families:
        if not isinstance(family, dict):
            require(False, "Malformed family record")
            continue
        family_id = family.get("id")
        family_ids.append(family_id)
        require(family_id == family.get("base_form_id"), "Family/base IDs disagree")
        branches = family.get("branches", [])
        require(isinstance(branches, list) and len(branches) == 2, "Each family needs exactly two branches")
        if not isinstance(branches, list):
            continue
        owned = set()
        for branch in branches:
            if not isinstance(branch, dict):
                require(False, "Malformed branch record")
                continue
            branch_ids.append(branch.get("id"))
            direction = branch.get("hybrid_direction")
            require(direction in hybrids, "Unknown branch hybrid direction")
            require(branch.get("id") == f"{family_id}_{str(direction).lower()}", "Branch ID is unstable")
            chain = branch.get("form_ids", [])
            require(isinstance(chain, list) and len(chain) == 3 and len(set(chain)) == 3,
                    "Every branch must have three distinct forms")
            if not isinstance(chain, list) or len(chain) != 3:
                continue
            require(chain[0] == family.get("base_form_id"), "Branch does not start at its own base")
            names = []
            for stage, identifier in enumerate(chain, 1):
                references[identifier] += 1
                owned.add(identifier)
                entry = by_id.get(identifier)
                require(entry is not None, f"Broken branch reference: {identifier}")
                if entry:
                    names.append(entry.get("name"))
                    require(entry.get("family_id") == family_id, "Cross-family branch reference")
                    require(entry.get("stage") == stage, "Branch stage ordering is not 1/2/3")
            if len(names) == 3:
                found_edges.add(tuple(names) + (direction,))
        require(len(owned) == 5, "Each family needs one shared base and four distinct descendants")
    require(len(set(family_ids)) == 14, "Duplicate family IDs")
    require(len(branch_ids) == 28 and len(set(branch_ids)) == 28, "Expected 28 unique branches")
    require(found_edges == set(expected_branches), "Branch names/relationships differ from the approved brief")
    require(set(references) == set(by_id), "Orphan forms or unknown branch references")
    for identifier, entry in by_id.items():
        require(references[identifier] == (2 if entry.get("stage") == 1 else 1),
                f"Invalid shared-base/descendant use: {identifier}")
    require(data.get("starter_form_ids") == ["embercub", "zephy", "pebblit"], "Starter choices changed")

    prototypes = data.get("prototype_fighters", [])
    require({entry.get("form_id") for entry in prototypes} == {"thundermaw", "worldforge"}
            and len(prototypes) == 2, "Expected exactly the two planned prototype fighters")
    for entry in prototypes:
        identifier = entry.get("form_id")
        name = by_id.get(identifier, {}).get("name", "")
        line = re.search(rf"^{re.escape(name)}: (.+)\.$", brief, re.MULTILINE)
        require(line is not None, f"Prototype absent from brief: {identifier}")
        require(by_id.get(identifier, {}).get("stage") == 3, "Prototype must reference its actual terminal form")
        if line:
            archetype, *kit = line.group(1).split(", ")
            kit[-1] = kit[-1].removesuffix(" ultimate")
            require(entry.get("archetype") == archetype, "Prototype archetype changed")
            require(entry.get("kit_names") == kit and entry.get("ultimate") == kit[-1],
                    "Prototype kit names differ from the supplied provisional kit")
        require(entry.get("kit_status") == "provisional_requires_playtesting", "Kit presented as finalized")
        require(entry.get("normalization") == "equal_power_for_initial_prototype_tests", "Prototype power is not normalized")
    return errors


def validate_economy(data, roster):
    """Validate balance metadata, safety gates, units, references, and unknowns."""
    errors = []

    def require(condition, message):
        if not condition:
            errors.append(message)

    def check_numbers(value, path="economy"):
        if isinstance(value, dict):
            for key, child in value.items():
                check_numbers(child, f"{path}.{key}")
        elif isinstance(value, list):
            for index, child in enumerate(value):
                check_numbers(child, f"{path}[{index}]")
        elif isinstance(value, (int, float)) and not isinstance(value, bool):
            require(math.isfinite(value) and value >= 0, f"Invalid numeric balance: {path}")

    check_numbers(data)
    require(data.get("schema_version") == 1, "Unsupported economy schema version")
    require(data.get("status") == "provisional_balance", "Balance must be provisional")
    require(data.get("content_status") == "planned_not_implemented", "Economy implies implementation")
    acquisition = data.get("acquisition", {})
    echo = acquisition.get("echo_requirements", {})
    require(echo == {"Common": 4, "Uncommon": 10, "Rare": 24, "Epic": 60, "Legendary": 120, "Mythic": 240},
            "Echo requirements differ from the approved provisional example")
    require(set(echo) == set(roster.get("rarities", [])), "Echo rarities do not cover the roster")
    require(all(type(amount) is int and amount > 0 for amount in echo.values()), "Echo costs must be positive integers")
    require(acquisition.get("hunt_example") == {"duration_minutes": 6, "targeted_echoes": 2}, "Hunt example changed")
    for flag in ("permanent_unlocks", "discovery_required", "earlier_forms_selectable"):
        require(acquisition.get(flag) is True, f"Acquisition guarantee missing: {flag}")
    evolution = data.get("evolution", {})
    example = evolution.get("example", {})
    pair = [example.get("from_form_id"), example.get("to_form_id")]
    edges = [branch["form_ids"][1:] for family in roster.get("families", []) for branch in family.get("branches", [])]
    require(pair in edges and pair == ["voltclaw", "thundermaw"], "Evolution example references no approved branch")
    require(example.get("sigils") == {"element": "Lightning", "amount": 480}, "Sigil example changed")
    require(example.get("sigils", {}).get("element") in roster.get("hybrid_elements", []), "Unknown Sigil element")
    require(example.get("guardian_cores") == 12 and example.get("mastery_xp") == 6000
            and example.get("trial") == "Storm Trial", "Evolution requirements changed")
    require(evolution.get("fragments_per_core") == 5, "Fragment conversion changed")
    require(evolution.get("materials_accumulate_simultaneously") is True, "Parallel resources treated as sequential")
    rewards = data.get("hunt_rewards", {}).get("tier_ii_example", {})
    for key, amount in {"rift_marks": 20, "sigils": 8, "targeted_echoes": 2, "mastery_xp": 100, "guardian_fragments": 1}.items():
        require(type(rewards.get(key)) is int and rewards.get(key) == amount, f"Invalid Tier II reward: {key}")
    rifts = data.get("rifts", {})
    require(rifts.get("standard_expedition_target_minutes") == {"min": 6, "max": 8}, "Expedition target changed")
    scaling = rifts.get("duo_scaling", {})
    require(scaling.get("enemy_hp_multiplier") == 1.7 and scaling.get("enemy_count_multiplier") == 1.35,
            "Duo percentages were not converted to multipliers correctly")
    hours = data.get("apex_active_hours", {})
    require(set(hours) == set(echo), "Apex target rarities are incomplete")
    require(hours.get("Common") == {"min": 7, "max": 12}
            and hours.get("Mythic") == {"min": 35, "max": 50}, "Apex endpoints changed")
    for interval in hours.values():
        if interval is not None:
            require(interval.get("min", -1) <= interval.get("max", -1), "Invalid hour range")
    elements = data.get("elements", {})
    require(elements.get("effective_multiplier") == 1.15 and elements.get("resisted_multiplier") == 0.9,
            "Elemental multipliers changed")
    money = data.get("monetization", {})
    for flag in ("paid_only_fighters", "paid_only_moves", "pvp_combat_advantages", "initial_paid_random_chance_boosts", "live_purchases_enabled"):
        require(money.get(flag) is False, f"Monetization gate violated: {flag}")
    require(money.get("eligible_timer_basis") == "active_eligible_rift_play_only", "Boost timer may count ineligible time")
    unknowns = [
        evolution.get("trial_duration_minutes", "missing"), rewards.get("duration_minutes", "missing"),
        rewards.get("sigil_element", "missing"), scaling.get("rounding_rule", "missing"),
        *(hours.get(rarity, "missing") for rarity in ("Uncommon", "Rare", "Epic", "Legendary")),
        *(elements.get(key, "missing") for key in ("neutral_multiplier", "matchup_table", "hybrid_recipes")),
        *(money.get(key, "missing") for key in ("product_ids", "prices", "boost_multipliers", "competitive_access_fairness_rule")),
    ]
    require(all(value is None for value in unknowns), "An unspecified balance or live product value was invented")
    return errors


class DesignDataTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.brief = BRIEF.read_text()
        cls.roster = json.loads((ROOT / "config/design/roster.json").read_text())
        cls.economy = json.loads((ROOT / "config/design/economy.json").read_text())

    def test_all_roster_families_branches_forms_and_names_match_brief(self):
        self.assertEqual(len(source_branches(self.brief)), 28)
        self.assertEqual(validate_roster(self.roster, self.brief), [])

    def test_both_provisional_kits_preserve_supplied_moves(self):
        prototypes = self.roster["prototype_fighters"]
        self.assertEqual([entry["ultimate"] for entry in prototypes], ["Stormbreaker", "Worldbreaker"])
        self.assertTrue(all(len(entry["kit_names"]) == 9 for entry in prototypes))
        self.assertTrue(all(entry.get("other_kit_roles") == "unfinalized" for entry in prototypes))

    def test_economy_contract_and_unfinalized_fields(self):
        self.assertEqual(validate_economy(self.economy, self.roster), [])

    def test_echo_example_run_counts_and_minutes_are_not_apex_hours(self):
        acquisition = self.economy["acquisition"]
        example = acquisition["hunt_example"]
        runs = [math.ceil(amount / example["targeted_echoes"]) for amount in acquisition["echo_requirements"].values()]
        self.assertEqual(runs, [2, 5, 12, 30, 60, 120])
        self.assertEqual([run * example["duration_minutes"] for run in runs], [12, 30, 72, 180, 360, 720])
        self.assertNotEqual(720 / 60, self.economy["apex_active_hours"]["Mythic"]["min"])

    def test_simultaneous_material_example_uses_bottleneck_not_sum(self):
        evolution = self.economy["evolution"]
        requirement = evolution["example"]
        rewards = self.economy["hunt_rewards"]["tier_ii_example"]
        runs = [math.ceil(requirement["sigils"]["amount"] / rewards["sigils"]),
                math.ceil(requirement["guardian_cores"] * evolution["fragments_per_core"] / rewards["guardian_fragments"]),
                math.ceil(requirement["mastery_xp"] / rewards["mastery_xp"])]
        self.assertEqual(runs, [60, 60, 60])
        self.assertEqual(max(runs), 60)
        self.assertNotEqual(max(runs), sum(runs))
        self.assertIsNone(rewards["duration_minutes"])
        # Illustrative only: Tier II's duration and Sigil element are unspecified.
        self.assertEqual(max(runs) * self.economy["acquisition"]["hunt_example"]["duration_minutes"] / 60, 6)

    def test_all_requested_documents_and_archived_prompt_exist(self):
        self.assertEqual(len(DOCUMENTS), 15)
        for name in DOCUMENTS:
            self.assertTrue((ROOT / name).is_file(), f"Missing requested document: {name}")
            self.assertGreater(len((ROOT / name).read_text().strip()), 100, f"Empty document: {name}")
        self.assertTrue(BRIEF.is_file())

    def test_local_markdown_links_resolve_without_host_specific_paths(self):
        paths = list(ROOT.glob("*.md")) + list((ROOT / "docs").rglob("*.md"))
        paths += list((ROOT / "config").rglob("*.md")) + [ROOT / "tests/README.md"]
        for document in paths:
            for raw in re.findall(r"!?\[[^\]]*\]\((<[^>]+>|[^)\n]+)\)", document.read_text()):
                target = raw[1:-1] if raw.startswith("<") else raw.split()[0]
                url = urlsplit(target)
                if url.scheme or url.netloc or not url.path:
                    continue
                self.assertFalse(url.path.startswith("/"), f"Host-specific link in {document.name}: {target}")
                resolved = (document.parent / unquote(url.path)).resolve()
                self.assertTrue(resolved.is_relative_to(ROOT), f"Link escapes checkout: {target}")
                self.assertTrue(resolved.exists(), f"Broken link in {document.relative_to(ROOT)}: {target}")

    def test_duplicate_form_is_rejected(self):
        damaged = deepcopy(self.roster)
        damaged["forms"][1]["id"] = damaged["forms"][0]["id"]
        self.assertTrue(validate_roster(damaged, self.brief))

    def test_broken_branch_reference_is_rejected(self):
        damaged = deepcopy(self.roster)
        damaged["families"][0]["branches"][0]["form_ids"][1] = "missing_form"
        self.assertTrue(validate_roster(damaged, self.brief))

    def test_wrong_evolution_stage_is_rejected(self):
        damaged = deepcopy(self.roster)
        damaged["forms"][1]["stage"] = 3
        self.assertTrue(validate_roster(damaged, self.brief))

    def test_nonfinite_balance_is_rejected(self):
        damaged = deepcopy(self.economy)
        damaged["rifts"]["duo_scaling"]["enemy_hp_multiplier"] = math.nan
        self.assertTrue(validate_economy(damaged, self.roster))

    def test_negative_reward_is_rejected(self):
        damaged = deepcopy(self.economy)
        damaged["hunt_rewards"]["tier_ii_example"]["sigils"] = -8
        self.assertTrue(validate_economy(damaged, self.roster))

    def test_live_purchases_are_rejected(self):
        damaged = deepcopy(self.economy)
        damaged["monetization"]["live_purchases_enabled"] = True
        self.assertTrue(validate_economy(damaged, self.roster))


if __name__ == "__main__":
    unittest.main(verbosity=2)
