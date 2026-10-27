# Build plan

Status: **approved development order; acceptance gates below are proposed checks**.
Read [GAME_DESIGN.md](GAME_DESIGN.md) for the baseline and open questions. This
task creates documentation/data only. It does not authorize implementing all
planned systems in one session.

## Preserve the existing foundation

Before this task, remote `main` was verified at
`a27d8f1ffdb8721a528f0b258ef76da6a77a1762`, the merge of combat pull request #2.
The new design branch starts there. M0 setup and M1 generic combat code are
preserved. The design expands the planned slice; it does not erase completed
implementation or turn unrun Studio tests into completed ones.

## Gated delivery order

| Step | Deliverable | Gate before moving on |
| --- | --- | --- |
| D0 — This task | Authoritative documents, archived prompt, complete long-term roster/economy data, validation | Review the documents and open questions; verify 14 families, 28 branches, and 70 forms. No new gameplay. |
| C0 — Existing generic prototype | Arena, reusable controller, camera, server-validated basic combat, dummy | Run the existing solo, two-player, controller, and camera Studio checklist; fix recorded failures. Implementation exists; manual acceptance is pending. |
| C1 — Contrasting combat prototypes | Thundermaw and Worldforge with equal normalized test power, provisional bespoke kits | First define which kit names fill which actions. Implement a small testable step per request. Verify ground/air balance, responsiveness, defense, hit rules, and anti-infinite protections. |
| R1 — Ember Rift | Small solo expedition using the same combat engine, modular rooms, encounters, event, guardian, extraction | Verify completion, failure/checkpoint rewards, predictable server-owned rewards, and provisional standard duration. No full roster. |
| J1 — One complete collection/evolution journey | Discovery → targeted Hunt → permanent unlock → materials/mastery → Trial → retained forms | Select the family/branch and verify all required resource sources are available solo. Balance concurrent resources as one journey. |
| C2 — Optional duo | Two-player invitations/ready check, personal loot, revives/assists, scaling, rejoin recovery | Verify no exclusive rewards, solo completion remains viable, and reconnects cannot duplicate rewards. |
| P1 — PvP | Invited/casual best-of-three, then ranked best-of-five with modest no-win-required unlock | Validate authoritative results, matchmaking, privacy, disconnect/rematch handling, and competitive fairness before release. |
| F1 — Careful expansion | One polished creature family at a time | Verify acquisition, both branches, original assets, combat readability, balance, and solo accessibility. |
| Later | Hybrid regions and separate turn-based 3v3 | Scope separately after the real-time foundation works. |

This is an order, not a dated release commitment. PvP combat can be tested in
local servers before the full progression/matchmaking release. Paid products
are a separate approval gate and are not enabled merely because progression exists.

## First complete journey needs a deliberate choice

The brief includes a Voltclaw → Thundermaw Lightning example and asks for Ember
Rift first. It does not finalize the first full family's costs or where each
Lightning resource comes from. Do not promise that Ember Rift alone supplies
that complete example. Choose a supported journey and its resource routes before
J1, or document an approved additional route. Keep earlier forms selectable and
avoid irreversible paid or branch-choice locks that were not approved.

## Immediate next task after design review

Run C0's manual acceptance in Roblox Studio on Windows or macOS using
[docs/combat-prototype.md](docs/combat-prototype.md). Record actual results before
claiming playability. If Studio is unavailable in the cloud, record the blocker
and continue only useful work the user has requested; do not skip to implementing
the whole roster. Then scope C1 from its open kit-role and balance questions.

## Beginner workflow for each development task

1. Read AGENTS.md and PROJECT_STATUS.md. Fetch and verify the latest `main` before
   starting a new task branch, preserving any existing work.
2. Pick one requested step with a clear result and test. Keep code changes on a
   new branch; a branch is a safe place to review changes before `main` gets them.
3. Run available checks, update roadmap/status/decisions/bugs/test log, and commit.
4. Push the branch and open a pull request with base `main`. Review the files and
   actual check results. Only merge after the relevant acceptance conditions pass.
5. If credentials or network policy block PR creation, report the exact blocker
   and provide a prepared description/link; do not claim a PR exists.
