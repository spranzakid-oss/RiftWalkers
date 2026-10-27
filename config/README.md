# Project configuration

This folder is reserved for development configuration and future configuration
documentation. It is **not** copied into Roblox by Rojo.

The active project configuration lives in the repository root:

- `default.project.json` maps source folders into Roblox's Explorer hierarchy.
- `rokit.toml` pins the command-line Rojo version, so developers use the same tool.
- `.github/workflows/validate.yml` runs the project checks on GitHub.

Future settings that the game must read belong in a reviewed Luau module under
`src/shared` (visible to players) or `src/server` (server-only). Never put passwords,
API keys, or other secrets in source control or in shared/client code. This setup
does not require any secrets or external game services.
