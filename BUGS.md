# Bugs

No unresolved application bugs have been confirmed by available automated checks
or review. The prototype has not been played in Roblox Studio, so this is not a
claim that gameplay or engine integration is bug-free. Record acceptance-test
failures here with reproduction steps; do not silently mark them passed.

## Open bugs

No confirmed uncorrected defects are recorded. BUG-002's code correction still
needs manual Studio verification; see its record below and the camera checklist.

The documentation/data task introduced no confirmed gameplay defect. Its design
open questions are recorded in GAME_DESIGN.md rather than misreported as runtime
bugs. Existing manual verification remains pending; source code was preserved.

## Resolved during M1 review

### BUG-001 — A frame hitch could skip an attack's entire active window

- Status: Resolved in the combat prototype branch (2026-10-27).
- Reproduction: Advance server sampling from before startup ends to after the
  active window, while still inside the move's recovery. The original sampler
  discarded the swing without ever checking for a target.
- Expected: A crossed active window receives a final validated sample, while
  entirely stale attacks cannot deal delayed damage.
- Fix: `CombatRules.activeSample` detects window crossings; `CombatService`
  performs the final sample with normal geometry/wall checks and hit deduplication.
- Verification: Three pure timing tests pass, including skipped windows and stale
  or invalid elapsed times. Live server hitch simulation in Studio remains unrun.

### BUG-002 — Camera smoothing could clip geometry and shorten framing

- Status: Corrected in code; manual verification pending (2026-10-27).
- Review reproduction: A blocked desired camera point was shortened after fitting
  the fighters; interpolation toward it could also cross a wall without a final check.
- Fix: Prefer full-distance side/opposite/overhead views, smooth around the focus,
  spherecast the resulting view, and compute FOV using the actual final distance.
- Verification: Luau compilation and code review passed. Run the wall/narrow-viewport
  acceptance check in Studio before treating this camera behavior as verified.

## How to record a bug

Give each bug a stable ID such as `BUG-001`. Include:

- A short title and status: open, in progress, blocked, or resolved.
- Where it happened, including relevant tool versions.
- The steps needed to reproduce it.
- What you expected and what actually happened.
- Any useful error text, with secrets and personal details removed.
- Its impact and any workaround.
- The fix, commit, and verification result when resolved.

Keep unresolved bugs visible. Record a setup limitation or missing manual check in PROJECT_STATUS.md and TEST_LOG.md; call it an application bug only when evidence supports that diagnosis.
