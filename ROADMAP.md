# Roadmap

This is a development order, not a promise of release dates. A checked box means the work was completed and its checks were recorded. All gameplay below is unimplemented.

## M0 — Project foundation

- [x] Create the source, documentation, configuration, and test folders.
- [x] Add the Rojo project mapping and tool version pin.
- [x] Add instructions for contributors and future Codex sessions.
- [x] Add the status, decision, bug, and test records.
- [x] Run the available structure checks and build a Roblox place with Rojo.
- [x] Commit the setup on a development branch and document how to merge it.

Complete this milestone before continuing. The Studio check belongs to M1 and must not be reported as completed by a cloud build.

## M1 — Studio connection and an empty-project smoke test

- [ ] Install the pinned Rojo CLI and the Rojo Studio plugin on the developer's computer.
- [ ] Open the generated place or connect Studio to the local Rojo server.
- [ ] Confirm the client, server, and shared folders appear in the expected services.
- [ ] Use Studio's Play button and confirm that the empty project starts without project errors in Output.
- [ ] Record the Studio version, steps, result, and any errors in TEST_LOG.md and BUGS.md.

This milestone verifies the editing workflow. It does not require a game mechanic. If Studio is unavailable, record the blocker and continue only with independent work the user has authorized.

## M2 — Plan the first playable slice

- [ ] Agree on one small, testable experience with the user before implementing gameplay.
- [ ] Write a short specification in docs/ describing the intended player actions, success conditions, and limits.
- [ ] Decide which code belongs on the server, which belongs on the client, and what information may be shared.
- [ ] Break the approved slice into small implementation tasks and define how each will be tested.

No mechanic or architecture beyond the project foundation is approved by this roadmap alone.

## M3 — Build the approved playable slice

- [ ] Implement only the slice agreed in M2.
- [ ] Add meaningful automated checks where possible and Studio playtests where required.
- [ ] Document known bugs and what remains incomplete before expanding scope.

## Later milestones — Plan after the first slice

Possible future areas include creatures and evolution, elemental Rift expeditions, optional two-player exploration, and competitive PvP. Plan their requirements, security checks, persistence needs, and tests before implementation. Their order and scope remain undecided.

## How to continue

Start with the first unchecked task in the earliest unfinished milestone. Check PROJECT_STATUS.md for blockers and recent work. Ask for a decision only when a missing answer prevents useful progress; otherwise complete the authorized task and record what happened.
