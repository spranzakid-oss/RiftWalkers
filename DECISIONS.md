# Decisions

Record choices that future contributors need to understand. Explain why a choice was made, what it affects, and when it should be revisited. Do not put passwords, access tokens, or private account details here.

## D001 — Keep source files in Git and connect them to Studio with Rojo

- Date: 2026-10-27
- Status: Accepted for project setup.
- Choice: Use `default.project.json` to map `src/client`, `src/server`, and `src/shared` into the Roblox data model.
- Reason: Text-based Luau files are easier to review and track in Git. Rojo copies them into the right places in Studio.
- Consequence: Change the mapping deliberately when the folder structure changes. Keep generated place files out of Git. Studio-only changes need an explicit plan for saving them back into the project.

## D002 — Separate client, server, and shared code

- Date: 2026-10-27
- Status: Accepted for project setup.
- Choice: Reserve client code for a player's device, server code for the game server, and shared code for modules both sides may use.
- Reason: This makes code ownership easier to understand before gameplay grows.
- Consequence: Anything in the shared or client folders can reach players. Never put secrets or trusted server-only logic there. Future gameplay must validate important player requests on the server.

## D003 — Build only the project foundation in this task

- Date: 2026-10-27
- Status: Historical setup scope; superseded for gameplay by the user's M1 request.
- Choice: Create the project layout, configuration, documentation, and validation without game mechanics.
- Reason: A clear starting point should exist before designing or implementing the first playable slice.
- Consequence: Empty source folders are intentional. A successful setup or build must not be described as a working game. Gameplay needs a separate scoped task.

## D004 — Keep tool versions and validation reproducible

- Date: 2026-10-27
- Status: Accepted for project setup.
- Choice: Pin the Rojo CLI version in `rokit.toml`. Use a Python 3 standard-library structure check and a real Rojo build for foundation validation.
- Reason: A version pin helps contributors use the same tool. The structure check needs no Python packages; the build checks that Rojo can consume the project.
- Consequence: These checks do not run Roblox gameplay. Use Roblox Studio on Windows or macOS for the manual M1 smoke test, and log it separately. Add a Luau test runner when there is meaningful Luau behavior to test.

## D005 — Keep progress and evidence in the repository

- Date: 2026-10-27
- Status: Accepted for project setup.
- Choice: Use AGENTS.md for session instructions and the status, roadmap, decisions, bugs, and test log for handoffs.
- Reason: Future sessions can continue from recorded work without relying on chat history.
- Consequence: Update the relevant records with each task. Keep actual test results separate from plans and do not mark blocked or unrun checks as passed.

## D006 — Implement the user-authorized combat slice as Milestone 1

- Date: 2026-10-27
- Status: Accepted for implementation; Studio acceptance pending.
- Choice: Replace the placeholder roadmap with one asset-free R6 fighter reused
  for players and a stationary training dummy, in a generated open-top arena.
- Reason: The user's new request defines a concrete playable combat prototype.
  Generated parts and procedural feedback avoid dependencies on uploaded assets.
- Consequence: No extra fighters or broader game systems. The old empty-project
  Studio check remains unrun and is carried into the stronger M1 acceptance test.

## D007 — Responsive client presentation with server-owned combat

- Date: 2026-10-27
- Status: Implemented, engine behavior awaiting manual tests.
- Choice: Client predicts movement/poses and sends only action intent. The server
  selects moves, validates timing/state/geometry/occlusion, deduplicates targets,
  and owns damage, stun, and hit knockback. Requests use a token bucket.
- Reason: Input should feel immediate without letting a client choose a victim,
  report a successful hit, or choose damage. Basic movement auditing catches
  obvious displacement; it is not a full competitive anti-cheat or lag compensation.
- Consequence: Use two-client and latency tests before claiming multiplayer feel
  or production security. Stationary dummy knockback is intentionally suppressed.

## D008 — Data-driven strings and fighter movement profiles

- Date: 2026-10-27
- Status: Implemented for the single test fighter.
- Choice: Config.Fighters registers Combat and Movement tables; pure CombatRules
  selects light strings/heavy finishers and handles cooldown and aerial limits.
- Reason: A future fighter can use bespoke values, strings, and movement without
  copying input/combat infrastructure. No additional fighter is implemented now.
- Consequence: Keep configuration valid and test new move references. The 70/30
  ground/air target requires playtest measurements rather than forced airtime quotas.

## D009 — Test pure policies in the official Luau CLI

- Date: 2026-10-27
- Status: Implemented.
- Choice: Pin Luau CLI 0.744 in CI with verified release checksum, run actual
  shared policies, compile all Luau, analyze pure modules, and retain Rojo tests.
- Reason: These are useful checks in Linux without pretending to run Roblox.
- Consequence: Engine-dependent code still needs Studio API analysis, physics,
  controller, camera, and local-server playtests. CI uploads a generated place
  for reviewers when the workflow passes; generated files are not committed.

## D010 — Preserve the approved full-game design without implementing it

- Date: 2026-10-27
- Status: Documentation baseline accepted from the user's supplied prompt.
- Choice: Preserve the exact prompt, create the 15 named design documents, and
  transcribe roster/economy data outside the Rojo runtime tree. All unfinalized
  balance values and prototype kits stay provisional; missing values remain null/TBD.
- Reason: The user requested authoritative documents before additional gameplay.
- Consequence: All 14 families/28 branches/70 forms are long-term direction, not
  a launch scope or implemented roster. Keep the existing generic M1 source intact.
  Next character-specific work plans normalized Thundermaw/Worldforge, then the
  gated sequence in BUILD_PLAN.md. Manual Studio acceptance remains unperformed.

## D011 — Start new tasks from verified latest main and deliver separate PRs

- Date: 2026-10-27
- Status: Continuing user workflow requirement.
- Choice: Fetch and compare remote main before edits; create a new task branch
  from the verified baseline without discarding existing work. Update tracking,
  test, commit/push, and prepare a new pull request. Recheck main before delivery.
- Evidence: This task starts at `a27d8f1ffdb8721a528f0b258ef76da6a77a1762`, which
  merges combat PR #2 and contains the preserved implementation.
- Consequence: A pushed branch or prepared description is not an opened PR.
  Report real access blockers and actual review/merge readiness separately.

## D012 — Preserve unresolved economy and competitive rules explicitly

- Date: 2026-10-27
- Status: Open design gates recorded, not resolved by invented specifications.
- Choice: Calculate concurrent evolution materials using the maximum run count,
  distinguish a single upgrade example from whole-journey Apex targets, and leave
  creature rarities, recipes, Tier II duration/type, and most costs unassigned.
- Reason: The supplied example is 60 eligible Hunts for each of three resources,
  hence 60 simultaneous runs, not 180. A six-hour scenario assumes six-minute
  runs; this does not finalize that tier or the full economy.
- Consequence: Paid acceleration's indirect competitive advantage still needs
  a fairness policy before purchases. Prototype-only normalization does not imply
  release-wide ranked normalization. Prices, IDs, and live purchases stay unset.
