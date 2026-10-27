# Rift Walkers

Rift Walkers is an original Roblox creature-fighting and exploration game.

The game will feature fast-paced 3D arena combat, collectible and evolving creatures, elemental Rift expeditions, optional two-player cooperative exploration, and competitive PvP.

**Current stage:** project foundation only. These features are plans; no gameplay
or game assets have been implemented. See [PROJECT_STATUS.md](PROJECT_STATUS.md)
for progress and the next task.

Development uses OpenAI Codex, GitHub, Roblox Studio, and **Rojo**. Rojo turns
files in this repository into Roblox objects and can keep them in sync with
Studio. **Luau** is Roblox's scripting language; its source files will live in
`src` when implementation starts.

## Where files belong

```text
src/
  client/                 Code that runs on each player's device (empty)
  server/                 Code that runs on the Roblox server (empty)
  shared/                 Modules the client and server can both use (empty)
docs/                     Design notes and future specifications
config/                   Development configuration notes
tests/                    Automated project checks
AGENTS.md                 Instructions for future Codex sessions
PROJECT_STATUS.md         Current progress, blockers, and the next task
ROADMAP.md                Milestone checklist
DECISIONS.md              Important choices and their reasons
BUGS.md                   Known problems and reproduction steps
TEST_LOG.md               Checks that actually ran and their results
default.project.json      Maps source folders into Roblox
rokit.toml                Pins the Rojo tool version
.github/workflows/        Automatic checks on GitHub
```

The source folders contain only `.gitkeep` files, which let Git store otherwise
empty folders. Rojo ignores those files. There are no placeholder game scripts.

| Source folder | Location in Studio's Explorer | Purpose |
| --- | --- | --- |
| `src/client` | `StarterPlayer → StarterPlayerScripts → Client` | Player-side code, such as input and UI |
| `src/server` | `ServerScriptService → Server` | Server-only logic |
| `src/shared` | `ReplicatedStorage → Shared` | Modules visible to both sides |

Files ending in `.client.luau` become LocalScripts; `.server.luau` files become
server Scripts; other `.luau` files become ModuleScripts. Keep private data and
trusted game decisions on the server. Players can access client and shared code.

## Install the development tools

For the full editing workflow, use a Windows or macOS computer with
[Roblox Studio](https://create.roblox.com/). The Linux cloud environment can edit,
check, and build this project, but cannot run Studio.

1. Clone this repository, or use the existing checkout in Codex. Open a terminal
   in the repository's top-level folder, where `default.project.json` lives.
2. Install [Rokit](https://github.com/rojo-rbx/rokit#installation), a Roblox tool
   installer. Follow its instructions for your operating system, then run:

   ```sh
   rokit install
   rojo --version
   ```

   Accept Rokit's trust prompt for the official `rojo-rbx/rojo` tool if shown.
   This project pins Rojo **7.6.1** in `rokit.toml`.
3. On your Studio computer, install the matching plugin:

   ```sh
   rojo plugin install
   ```

   Restart Studio if it was already open. See the
   [official Rojo installation guide](https://rojo.space/docs/v7/getting-started/installation/)
   if the plugin does not appear.
4. Install [Python 3.11 or newer](https://www.python.org/downloads/) for the
   automated project checks. It does not become part of the Roblox game, and no
   third-party Python packages are needed. On Windows, `py -3` can replace
   `python3` in the commands below.

## Check and build the empty project

Run these commands from the repository root:

```sh
python3 tests/test_project_structure.py
mkdir -p build
rojo build default.project.json --output build/RiftWalkers.rbxlx
```

On Windows, create `build` with File Explorer or `New-Item -ItemType Directory
-Force build` in PowerShell instead of `mkdir -p build`.

The first command checks the source paths and the folder layout in a real Rojo
build. The last command produces a Roblox place file, which you can open in
Studio. `build` is ignored by Git because it can be recreated from source.
These checks do not test gameplay. GitHub Actions also runs them after pushes
and on pull requests; see the repository's **Actions** tab for its results.

## Connect to Studio for editing

On the **same Windows/macOS computer** running Studio:

1. Build and open `build/RiftWalkers.rbxlx` in Studio, or create a new blank place.
2. Run `rojo serve default.project.json` in the repository terminal. Keep it open.
3. Open the Rojo plugin in Studio and connect to `localhost` on port `34872`.
   Review the proposed sync changes before accepting them.
4. In Explorer, confirm the three source folders appear in the locations listed
   above. Click **Play**, then inspect **Output** for project errors. An empty
   world is expected: this repository has no gameplay or map yet.
5. Record the Studio version and result in [TEST_LOG.md](TEST_LOG.md). Stop the
   server with Ctrl+C when finished.

Do not point a personal Studio installation at the cloud machine's `localhost`;
that address always means the computer on which it is used. Use a local checkout
for live sync. Rojo sync is primarily from files **into** Studio; changes made
only in Studio are not automatically saved back into Git. Plan how to preserve
Studio-created assets before adding them. Do not experiment in an existing
published place during this initial check.

## Continue development

Read [AGENTS.md](AGENTS.md), then [PROJECT_STATUS.md](PROJECT_STATUS.md) and
[ROADMAP.md](ROADMAP.md). Future sessions should continue the next incomplete
task, run the available checks, and update the records. The next milestone after
foundation setup is the manual Studio connection check. Designing the first
playable slice comes later; this setup does not authorize implementing it.

## Put this setup onto main

The setup branch is `development/project-setup`. A **branch** holds proposed
changes without changing `main`. A **pull request** lets you review and merge
those changes on GitHub.

If the branch is only committed locally, push it from the checkout containing
the commit:

```sh
git push -u origin development/project-setup
```

On GitHub, choose **Compare & pull request**, set the base to `main` and the
compare branch to `development/project-setup`, and review the files. Wait for
the project checks to pass, then select **Merge pull request** (or **Squash and
merge**) and confirm. This makes the setup part of `main`. Do not force-push or
replace `main`. The session's final report will say whether the branch was
pushed and whether a pull request was actually created.
