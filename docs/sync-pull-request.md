# Add startup-only Rojo synchronization check and Windows walkthrough

The full project already maps client/server/shared code correctly but starts the
earlier combat prototype. The user needs a tiny first Studio synchronization
check without additional combat work.

- Preserve `default.project.json` and existing combat source.
- Add `sync.project.json` with Shared modules and exactly one server Script and
  one client LocalScript, each printing a recognizable startup message.
- Document Windows file retrieval, tool/plugin installation, exact serve command,
  Studio connection/Output clicks, and a saved-local-edit verification.
- Validate both builds, script classes/placement, startup source, and the live
  CLI server response; update progress and leave manual checks pending.

Validation: 6 packaging tests and 28 unchanged combat-policy tests pass; all
10 Luau source/test files compile; pure analysis and both Rojo builds pass.
The local CLI API returned HTTP 200 for RiftWalkersSync. No Studio tests were run
or claimed. Windows installation, plugin connection, print execution, and a saved
edit appearing in Studio require the user's actual verification.
