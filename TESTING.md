# Testing and acceptance

**Status:** approved test goals; future-system tests are planned. No Roblox
Studio playtesting was performed for this design-document task. A test plan is
not a passing test result. Record actual evidence in [TEST_LOG.md](TEST_LOG.md).
See [GAME_DESIGN.md](GAME_DESIGN.md) for design status and
[BUILD_PLAN.md](BUILD_PLAN.md) for the order in which features become testable.

## Run available automated checks

From a terminal in the repository folder, follow [tests/README.md](tests/README.md)
to install the tools, then run:

```sh
python3 tests/run_checks.py
```

On Windows, use `py -3` if `python3` is not the installed command. A terminal is
the application where these commands are typed. The root folder is the one that
contains `default.project.json`. Missing tools and failed checks are failures to
investigate, not permission to report the suite passed.

| Existing check | What it can establish |
| --- | --- |
| Five Python packaging tests | Actual Rojo output contains the expected source modules and executable script classes in the right services |
| Luau compilation of source/test files | Source parses and compiles; this does not validate Roblox API use |
| Standalone analysis of pure modules/spec | Type/lint checks for code without Roblox engine dependencies |
| Twenty-eight Luau combat-rule cases | Combo/timing/dash/geometry/rate-limit policies behave under controlled inputs |
| Rojo place build | A generated place can be packaged for manual Studio testing |

The existing baseline's outcomes are recorded in TEST_LOG.md; rerun after relevant
changes. Neither these tests nor a zero-error build prove movement, camera,
network physics, controller hardware, or Roblox engine integration works.

## Validate this design task

The design-data validator is `python3 tests/test_design_data.py`. It should fail
on inconsistent roster links, duplicate forms, wrong family/branch totals, or
invalid economy references. This is design validation, not gameplay execution.

Review all 14 families, 28 branches, and 70 unique forms against the preserved
approved brief. Count each base once; a shared base appearing in both paths is
not a second form. Validate starters, prototype references, and exact names.
Unknown rarities, recipes, artwork, animation, and final balance must remain
explicitly unknown instead of being filled with invented approved values.

Check provisional economy arithmetic separately from target claims. Resources
earned together accumulate in parallel: use the slowest required resource's
run count, not the sum of every resource's run count. An example resource subtotal
is not evidence that a whole-family Apex journey meets its active-hour target.
Match documents and machine-readable records; neither is automatically runtime
authority. Confirm this task does not modify the completed gameplay source.

## Manual testing: the existing prototype

On Windows or macOS, build/open `build/RiftWalkers.rbxlx` in Roblox Studio and
follow [docs/combat-prototype.md](docs/combat-prototype.md). Open **Output** to
see errors. Use **Play** for solo checks, then Studio's local-server test tools
with separate player clients for multiplayer checks. Record the Studio version,
input device, steps, expected/actual result, and useful error messages.

The generic fighter currently supports only a subset of the full combat design.
Do not claim Thundermaw, Worldforge, a Rift, progression, or purchases were tested
by attacking the existing stationary dummy.

## Planned slice acceptance

| Slice | Minimum evidence before accepting it |
| --- | --- |
| Contrasting fighters | Thundermaw and Worldforge at normalized initial prototype power; distinct movement and provisional kits; keyboard/mouse and controller; clear attack/guard/stun states; no unbounded combo route |
| Combat and camera | Both fighters readable while close/far, crossing, airborne, near walls, and on narrow viewports; no sudden flips; measure responsiveness and the provisional ground/air emphasis during actual sessions |
| Ember Rift | Same combat rules as PvP; mission choices, event, guardian, extraction, and failure checkpoint rewards; reproducible rewards from the server |
| Acquisition journey | Discovery opens a targeted Hunt; guaranteed Echoes grant permanent ownership; solo players can earn every included form without paying |
| Evolution journey | Validate every material/mastery/Trial requirement, concurrent material accumulation, repeat requests, and earlier-form selection after evolution |
| Optional duo | Individual loot, ready checks, revives, assists, PvE synergy, scaling, and solo-equivalent availability; no co-op-exclusive progression |
| PvP | Casual/friend best-of-three and ranked best-of-five results owned by server; modest ranked unlock without mandatory wins; legal loadouts and correct rematch consent |
| Matchmaking | Skill, creature power, and connection inputs evaluated without exposing private internals; cancel/timeout/disconnect cases; no fabricated precision about ratings |

Every new feature needs meaningful automated behavior tests where practical,
plus manual engine tests where required. Replace “looks fine” with reproducible
steps and observations. Balance values and pass thresholds not finalized by the
brief remain **Provisional/TBD**, including matchmaker tolerances and airtime metrics.

## Recovery, security, and monetization tests

For implemented future services, test invalid, repeated, stale, and unauthorized
requests; dead/disconnected actors; and two clients attempting conflicting actions.
Verify clients cannot invent hits, results, inventory, or resource balances.
Do not call the prototype's lenient movement audit a complete anti-cheat.

Invite tests cover accept, decline, timeout, privacy restrictions, cancellation,
disconnect, and rejoin. Recovery must not duplicate rewards or transfer a private
session to an unrelated player. Test persistence retries and migration failures
with test accounts before making durable grants available to players.

Purchases remain disabled without approval. Before any approved release, use an
isolated test plan for verified receipts, duplicate/retried receipt processing,
accurate grants, and boost timers counting only eligible active Rift play. Lobby,
idle, disconnected, and ineligible time must not drain a boost. Exact eligibility
and stacking rules are unresolved; test their approved definitions when decided.
Do not conduct real-money purchase tests or create live product IDs in this task.

## Record results honestly

Separate **passed**, **failed**, **blocked**, **not run**, and **not applicable**.
A future feature has no passing result until implemented and exercised. Keep
confirmed defects in BUGS.md with reproduction steps, and leave manual milestone
boxes unchecked until evidence exists. Hosted CI success must be observed, not
inferred from local success. Review the pull request and its actual checks before
merging; documentation review does not accept unrun gameplay milestones.
