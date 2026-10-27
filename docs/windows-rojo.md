# First Rojo connection on Windows

This guide checks local file synchronization with two print messages. Use
`sync.project.json` for this first check. It includes shared modules and the two
startup scripts, while preserving the existing combat code in the repository.
`default.project.json` is the separate full-project mapping, including that code.
**Studio verification is pending until you perform the steps below.**

## 1. Get the files onto your Windows computer

Studio and the Rojo command-line server must run on the **same computer**. The
cloud workspace is not a folder on your PC, and `localhost` means your own PC.

Use your local RiftWalkers checkout and select branch
`development/rojo-studio-sync` until these changes are merged into `main`.
In GitHub Desktop, click **Fetch origin**, then **Current branch**, and select
that branch. Preserve any existing changes rather than discarding them.
If you do not have a checkout, use GitHub's branch dropdown to select this branch,
then **Code → Download ZIP**. Extract the ZIP into a new folder; do not overwrite
your existing work. Once merged, an up-to-date `main` also contains these files.

Open the extracted or checked-out folder in **File Explorer**. The correct folder
contains `sync.project.json`, `default.project.json`, `rokit.toml`, and `src`.
Click File Explorer's address bar, type `powershell`, and press **Enter**.
This opens a command window in that folder. Run each command below by typing or
pasting it, then pressing **Enter**:

```powershell
Get-Location
Test-Path .\sync.project.json
```

`Get-Location` shows the current folder. `Test-Path` checks that the sync project
file exists there; it must print `True`. If it prints `False`, return to File
Explorer and open PowerShell in the folder containing that file.

## 2. Check Rojo and install its Studio plugin

```powershell
rojo --version
```

This checks the Rojo program on **your Windows PC**. Expect `Rojo 7.6.1`, the
version pinned by this project. The cloud machine's installation does not prove
Rojo is installed on Windows.

If Windows says the command is not recognized, install
[Rokit using its official Windows instructions](https://github.com/rojo-rbx/rokit#installation).
Rokit installs the tool versions listed in `rokit.toml`. Reopen PowerShell in
the project folder after installing it, then run:

```powershell
rokit install
rojo --version
```

`rokit install` reads this project's tool list and installs Rojo 7.6.1. Accept
Rokit's trust prompt for the official `rojo-rbx/rojo` tool if one appears. The
second command confirms the result. If another Rojo version remains selected,
`Get-Command rojo` shows which executable Windows found; resolve that tool/path
selection before continuing. Python and a VS Code extension are not needed to sync.

Close Roblox Studio, then run:

```powershell
rojo plugin install
```

This copies the matching Rojo plugin into Studio's local plugins folder. Open
Studio again afterward so it loads the plugin. See the
[official Rojo installation guide](https://rojo.space/docs/v7/getting-started/installation/)
if it does not appear. Keep one matching Rojo plugin active; avoid running an
old separately installed copy alongside it.

## 3. Start the local synchronization server

In the same PowerShell window and project folder, run:

```powershell
rojo serve sync.project.json --address 127.0.0.1 --port 34872
```

`serve` watches your files and makes changes available to Studio. The project
filename selects the startup-only profile. `127.0.0.1` restricts the connection
to this PC; `34872` is the port, or numbered connection point. Keep this window
open while working. Rojo should show that it is serving the project without errors.
To stop it later, click the PowerShell window and press **Ctrl+C**.

## 4. Connect Studio

1. In Studio's start screen, choose **New → Baseplate**. Use a fresh local test
   place so the first synchronization does not affect an existing experience.
2. Open **Explorer** and **Output** from the **View** tab/menu. Some Studio
   versions put these panels under **Window** instead; select the panels by name.
3. Open the **Plugins** tab, then click the **Rojo** button to open its panel.
4. In the Rojo panel, use host `localhost` (or `127.0.0.1`) and port `34872`,
   then click **Connect**. These are usually the defaults. Approve the plugin's
   local connection permission if Studio asks. You do not need a Roblox API key.
5. Review the initial synchronization changes and accept **Sync/Accept** if the
   plugin presents that confirmation. Exact button wording varies by version.
6. In Explorer, expand the arrows next to these services and folders:

| Explorer location | Expected object |
| --- | --- |
| `ReplicatedStorage → Shared` | Shared ModuleScripts, including `Config` and `CombatRules` |
| `ServerScriptService → Server → Startup` | A server `Script` |
| `StarterPlayer → StarterPlayerScripts → Client → Startup` | A client `LocalScript` |

Shared ModuleScripts do not execute by themselves. The startup-only profile
does not include the combat `Main` or `Controller` entrypoints. Review the sync
preview carefully if you previously connected this place to the full profile.

## 5. Verify both scripts and a saved local edit

1. Click **Play** in Studio, or press **F5**. Use Play rather than **Run/F8**:
   Play creates a player, which is needed for a client LocalScript.
2. In **Output**, clear any search text and enable both **Server** and **Client**
   messages, or select **All**, depending on your Studio version. Expect:

   ```text
   [Rift Walkers][SERVER] Rojo sync OK
   [Rift Walkers][CLIENT] Rojo sync OK
   ```

   The server line proves the server script ran; the client line proves the
   player's LocalScript ran. Expect each once when its script starts, not every frame.
3. Click **Stop**, or press **Shift+F5**, to return to edit mode.
4. Open local file `src/server/Startup.server.luau` in a text editor. Change its
   message to end in `Rojo sync OK v2` and **save** the file. Keep Rojo connected.
5. Open `ServerScriptService → Server → Startup` in Studio. Its source should
   update to your saved text. Click Play again and confirm the server prints the
   `v2` message. A source change does not necessarily rerun a running script;
   stopping and playing again makes this check clear.

Rojo sends local files **into** Studio. Edits made only inside Studio do not
automatically write back to your local files. Make source edits in your editor.

## If something does not work

- **Connection refused:** keep the Rojo PowerShell process running on this PC;
  match host/port and check for red terminal errors. Allow its local connection
  if your security software asks. Do not expose the server to the Internet.
- **Port already in use:** stop the Rojo process you previously started with
  Ctrl+C, then retry. If using a different port, change it in both places.
- **Missing client line:** use Play, check Output's client filter, and verify the
  LocalScript is under StarterPlayerScripts, not ServerScriptService.
- **Combat starts:** stop Play and check that the server command names
  `sync.project.json`. Reconnect using a fresh Baseplate and review the preview.
- **Saved edit does not appear:** check the folder, selected profile, plugin
  connection, and that your editor saved the file. Check Output for actual errors.

## Manual results — leave unchecked until verified

- [ ] Windows reports Rojo 7.6.1 and its server stays running.
- [ ] Studio connects and the three mapped locations appear in Explorer.
- [ ] Play prints both recognizable lines without project errors.
- [ ] A saved local edit appears in Studio and prints after Stop/Play.

Record your actual Studio version and results in [TEST_LOG.md](../TEST_LOG.md).
If a step fails, keep its error text and reproduction steps for [BUGS.md](../BUGS.md).
