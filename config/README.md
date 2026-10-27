# Project configuration

This folder is reserved for development configuration and future configuration
documentation. It is **not** copied into Roblox by Rojo.

The active project configuration lives in the repository root:

- `default.project.json` maps source folders into Roblox's Explorer hierarchy.
- `rokit.toml` pins the command-line Rojo version, so developers use the same tool.
- `.github/workflows/validate.yml` runs the project checks on GitHub.

The prototype's gameplay values live in `src/shared/Config.luau`: fighter health,
move strings, damage, timings, hitboxes, movement, camera, and arena dimensions.
`Config.Fighters` registers combat/movement profiles; only the test fighter ships.
Future private server settings belong under `src/server`. Never put passwords,
API keys, or other secrets in source control or shared/client code. This prototype
does not require any secrets or external game services.

`config/design/roster.json` and `config/design/economy.json` are machine-readable
planning data; see their [field guide](design/README.md). They are not synced to
Roblox and do not automatically change the existing prototype's configuration.
All balance numbers there remain provisional, with unspecified values left null.
