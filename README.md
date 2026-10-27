# Rift Walkers

Rift Walkers is an original Roblox creature-fighting and exploration game.

The game will feature fast-paced 3D arena combat, collectible and evolving creatures, elemental Rift expeditions, optional two-player cooperative exploration, and competitive PvP.

**Current stage:** Milestone 1 combat prototype implemented for manual Studio
testing. It includes a temporary block fighter, movement, a two-fighter camera,
light/heavy strings, health, damage, hit reactions, an arena, and a training dummy.
The broader game features above remain plans. **Roblox Studio playtesting has
not been performed here.** See [PROJECT_STATUS.md](PROJECT_STATUS.md) for progress.

The approved full-game design now lives in [GAME_DESIGN.md](GAME_DESIGN.md), which
links all 15 topic documents and the machine-readable roster/economy. The original
prompt is [archived here](docs/approved-design-prompt.md). These are plans, not a
claim that the full roster or progression already exists. Balance figures remain
provisional. Read [BUILD_PLAN.md](BUILD_PLAN.md) for the gated development order.

Development uses OpenAI Codex, GitHub, Roblox Studio, and **Rojo**. Rojo turns
files in this repository into Roblox objects and can keep them in sync with
Studio. **Luau** is Roblox's scripting language; its source files live in `src`.

## Where files belong

```text
src/
  client/                 Controller, camera, input, and presentation
  server/                 Arena, fighter lifecycle, authoritative combat
  shared/                 Configurable fighter values and pure combat rules
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

The server creates the temporary arena and fighters when you press **Play**.
They are built from simple Roblox parts, so no uploaded art or animation assets
are needed. Source files remain the source of truth; generated places stay out
of Git.

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

## Check and build the prototype

Run these commands from the repository root:

```sh
python3 tests/run_checks.py
```

Install the Luau CLI as explained in [tests/README.md](tests/README.md) first.
The runner validates design data, checks packaging, compiles Luau, tests pure combat rules, and produces
`build/RiftWalkers.rbxlx`, which you can open in Studio. `build` is ignored by Git
because it can be recreated. These checks do not run Roblox engine gameplay.
GitHub Actions runs the same checks and, on success, saves the place as the
`RiftWalkers-prototype` artifact in the workflow run's **Artifacts** section.

## Connect to Studio for editing

On the **same Windows/macOS computer** running Studio:

1. Build and open `build/RiftWalkers.rbxlx` in Studio, or create a new blank place.
2. Run `rojo serve default.project.json` in the repository terminal. Keep it open.
3. Open the Rojo plugin in Studio and connect to `localhost` on port `34872`.
   Review the proposed sync changes before accepting them.
4. In Explorer, confirm the three source folders appear in the locations listed
   above. Click **Play**, then inspect **Output** for project errors. The arena,
   controllable test fighter, training dummy, and controls HUD should appear.
5. Record the Studio version and result in [TEST_LOG.md](TEST_LOG.md). Stop the
   server with Ctrl+C when finished.

Do not point a personal Studio installation at the cloud machine's `localhost`;
that address always means the computer on which it is used. Use a local checkout
for live sync. Rojo sync is primarily from files **into** Studio; changes made
only in Studio are not automatically saved back into Git. Plan how to preserve
Studio-created assets before adding them. Do not experiment in an existing
published place during this initial check.

## Play and test Milestone 1

| Action | Keyboard / mouse | Controller (Xbox names) |
| --- | --- | --- |
| Move / jump | WASD / Space | Left stick / A |
| Sprint | Hold Left Shift | Hold L3 |
| Dash | Q | B |
| Light / heavy attack | Left / right mouse button | X / Y |
| Cycle target, then unlock | Tab | R3 |

Start with Light → Light → Light, or try two lights followed by Heavy. Move into
reach: pressing attack does not guarantee a hit. There is one air dash per jump
and no flight mode. Edit `src/shared/Config.luau` to tune values. The 70% ground /
30% air balance is a design target to measure in playtests, not a proven result.

Follow [docs/combat-prototype.md](docs/combat-prototype.md) for exact strings,
configuration, architecture, and the solo/controller/two-player Studio checklist.

## Continue development

Read [AGENTS.md](AGENTS.md), then [PROJECT_STATUS.md](PROJECT_STATUS.md) and
[ROADMAP.md](ROADMAP.md). Future sessions should continue the next incomplete
task, run the available checks, and update the records. Review the design baseline,
then run the manual Milestone 1 Studio acceptance checklist. Tune or fix confirmed
problems before extending it into the two contrasting prototype fighters in the
build plan. This documentation change implements no new fighter or game system.

## Review and merge these design changes

The design branch is `development/authoritative-design`. A **branch** holds proposed
changes without changing `main`. A **pull request** lets you review and merge
those changes on GitHub.

If the branch is only committed locally, push it from the checkout containing
the commit:

```sh
git push -u origin development/authoritative-design
```

On GitHub, choose **Compare & pull request**, set the base to `main` and the
compare branch to `development/authoritative-design`, and review the files. Wait for
the project checks to pass, then select **Merge pull request** (or **Squash and
merge**) and confirm. This makes the design baseline part of `main`. Do not force-push or
replace `main`. The session's final report will say whether the branch was
pushed and whether a pull request was actually created.
