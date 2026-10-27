# Requested development workflow

The user supplied this instruction alongside the approved design prompt:

> Before making any new changes, verify that this task is using the latest main branch of my Rift Walkers GitHub repository. Read AGENTS.md, PROJECT_STATUS.md and the existing project files. Preserve all completed work. Implement the next requested development task, update the project tracking files, and prepare the changes in a new pull request. Tell me when the pull request is ready to review and merge.

For this task, native Git fetch and a read-only remote reference check agreed
on `a27d8f1ffdb8721a528f0b258ef76da6a77a1762` before edits. The working tree was
clean, completed combat work was already merged in pull request #2, and
`development/authoritative-design` was created directly from that `origin/main`.

AGENTS.md includes the ongoing rule. Never reset or discard local work to
satisfy a latest-main check. Preserve it first and integrate remote changes
deliberately. A clean new branch from current main is the normal starting point.
Recheck main before delivery and integrate any newer changes without losing work.

The next requested task here is the authoritative design documentation in
[the archived prompt](approved-design-prompt.md), **not gameplay implementation**.
Record actual PR creation separately from a push or a prepared description.
