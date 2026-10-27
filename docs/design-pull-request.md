# Add the approved Rift Walkers design baseline and validated planning data

The approved full-game brief was not represented in the generic combat prototype's
documentation. This change records it without changing runtime gameplay.

- Preserve the exact user prompt and continuing latest-main/new-PR workflow.
- Add the 15 requested design documents, with approved/planned/provisional/TBD
  distinctions, open questions, and a gated beginner-friendly build plan.
- Add machine-readable roster and economy data: 14 families, 28 branches, and
  70 unique forms, named provisional kits, guaranteed progression examples,
  concurrency arithmetic, and disabled/unset purchase planning fields.
- Add 13 standard-library validation cases to the full existing check runner;
  preserve all existing combat files and manual acceptance status.
- Update status, roadmap, decisions, bugs, and test evidence. Base is verified
  latest main `a27d8f1`, which already includes the completed combat PR #2.

Validation: design-data checks, existing packaging tests, Luau compilation/analysis,
combat policy tests, and Rojo build run through `python3 tests/run_checks.py`.
Actual counts/results are in TEST_LOG.md. No Studio playtest or hosted CI success
is claimed. No new fighter, Rift, economy service, asset, or purchase is implemented.

Review open design questions before implementing their systems. The existing
generic combat prototype still needs manual Studio acceptance. This file is the
prepared PR description, not evidence that a GitHub PR has been opened.
