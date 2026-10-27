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
- Status: Accepted; requested by the user.
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
