# Project status

Last updated: 2026-10-27

Rift Walkers is at the project setup stage. The planned game is a Roblox creature-fighting and exploration game. No gameplay has been implemented.

## Completed milestone: M0 — Project foundation

The folder layout, Rojo mapping, contributor instructions, tracking documents,
and GitHub Actions workflow are in place on `development/project-setup`. Four
automated checks and a real Rojo build passed. The local Rojo synchronization
server also responded successfully. See [TEST_LOG.md](TEST_LOG.md) for evidence
and [README.md](README.md#put-this-setup-onto-main) for merge instructions.

## Next incomplete task

Continue with **M1: Studio connection and an empty-project smoke test** in
[ROADMAP.md](ROADMAP.md). First install the pinned Rojo CLI and its Studio plugin
on a Windows or macOS computer, following the README.

M1 needs Roblox Studio on a supported Windows or macOS computer. Open the generated place or connect the Rojo plugin, confirm that the mapped folders appear, and run the empty place with no project errors. This cloud environment cannot perform that Studio check.

## What exists

- Separate places for client, server, and shared Luau source files.
- A Rojo project file that maps those folders into Roblox services.
- Setup guidance, project tracking, and checks for the initial structure.
- A pinned Rojo 7.6.1 tool definition and automated GitHub checks. GitHub-hosted
  checks must still run after the branch is pushed; only local checks ran here.

## What does not exist yet

Combat, creatures, expeditions, cooperation, PvP, persistence, maps, and user interfaces are future work. A successful build means the project can be packaged; it does not mean these game features exist or have been tested.

## Session handoff

Read [AGENTS.md](AGENTS.md), this file, and the roadmap before changing anything. Work on the first incomplete task within the user's request. Update the status, test log, decisions, and bug list when relevant. Do not begin gameplay implementation as part of this setup task.

The setup is prepared on a development branch; it must be merged before it is
part of `main`. Roblox Studio is unavailable in this Linux cloud environment,
and the GitHub API is unavailable here, so do not claim a Studio playtest or an
automatically opened pull request. Neither limitation prevents local edits,
builds, tests, or creating a Git commit.
