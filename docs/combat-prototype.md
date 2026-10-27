# Milestone 1: playable combat prototype

This milestone is a small arena for learning and testing the combat foundation.
It uses one temporary block-shaped R6 fighter, reused for every player, plus a
stationary training dummy. R6 means a simple Roblox character with six visible
body parts. The shapes and effects are temporary; no external animation or art
assets are required.

The user authorized this combat prototype after the initial project setup. Rift
Walking, creature evolution, monetization, persistence, and additional fighters
remain outside this milestone.

**Manual Roblox Studio playtesting has not been performed in this Linux cloud
environment.** The checklist below is the acceptance test to run on a supported
Windows or macOS computer. Automated results belong in [TEST_LOG.md](../TEST_LOG.md).

## Intended experience

Movement should feel quick: approach, strafe, sprint, dash, jump, and use limited
air control. Ground combat is the foundation; aerial movement adds short bursts
rather than permanent flight. Approximately 70% grounded and 30% aerial combat
is a tuning goal, not a measured result or a rule that forces players to land.

Light attacks follow a short, forgiving configured string. Heavy attacks offer a
slower, stronger option, including a configured finisher after light attacks.
The server selects the actual move from the player's current combo state. Future
fighters can have different move definitions and strings without changing the
input system. This prototype contains only the test fighter.

| Input sequence | Starting move sequence |
| --- | --- |
| Light, Light, Light | Jab → Cross → Kick |
| Heavy from neutral | Heavy |
| Light, Light, Heavy | Jab → Cross → RisingHeavy |
| Light, Light, Light, Heavy | Jab → Cross → Kick → Breaker |
| Light or Heavy while airborne | AirLight or AirHeavy; resets the grounded string |

Press the next button near the end of the current move. The server allows a
0.18-second input buffer before recovery ends, so a slightly early follow-up is
remembered. The grounded string resets when more than 0.95 seconds have passed
since the previous accepted move started (including its startup and recovery).
These are input strings: continuing the sequence does not guarantee every move
connects. Range, timing, walls, and the opponent's movement still matter.

The camera automatically frames the player and a nearby opponent in three
dimensions. Its pair framing takes inspiration from Tekken's readability; the
combat itself is a free-moving arena prototype, not a Tekken ruleset.

## Controls

| Action | Keyboard / mouse | Controller |
| --- | --- | --- |
| Move | W, A, S, D | Left stick |
| Jump | Space | A / bottom face button |
| Sprint | Hold Left Shift | Hold L3 / left-stick click |
| Dash | Q | B / right face button |
| Light attack | Left mouse button | X / left face button |
| Heavy attack | Right mouse button | Y / top face button |
| Cycle target / unlock | Tab | R3 / right-stick click |

Controller names use the Xbox layout. Test the equivalent physical buttons on
other controllers. Default Roblox movement and jump controls remain available.
Mobile controls are not part of this milestone.

The camera initially selects the nearest living opponent. Tab/R3 cycles through
nearby candidates, then unlocks after the last one. Press it again while unlocked
to select the nearest opponent.

Dash uses the current movement direction, or forward when standing still.
There is a cooldown between dashes and at most one dash before landing while
airborne. Jumping allows basic directional adjustment; there is no flight mode.
Attacks and hit reactions can temporarily restrict movement.

## Configuration and code ownership

The main values live in [src/shared/Config.luau](../src/shared/Config.luau).
Edit the values there, then stop and restart the Studio session to test them.
Shared configuration is visible to players and must never contain secrets.

`Config.Fighters` registers the single `TestFighter` definition. Its `Combat`
and `Movement` tables can be replaced for a future fighter; the input and combat
rules do not need a separate copy. The server selects the definition using the
fighter model's server-created `FighterId`, not an ID requested by the client.
The current world intentionally spawns only the test fighter.

| Area | Starting values / purpose |
| --- | --- |
| Fighter | 100 maximum health; one reusable test fighter |
| Movement | Walk speed 20, sprint speed 30, jump power 48 |
| Dash | Speed 72, duration 0.18 seconds, cooldown 0.9 seconds |
| Air movement | One air dash, 0.75 dash-speed multiplier, limited air steering |
| Moves and combos | Damage, startup, active hit time, recovery, reach, stun, knockback, and string choices |
| Camera | 65-degree field of view; targets within 90 studs; framing and smoothing values |
| Arena | Size, player respawn timing, and dummy reset timing |

Roblox uses **studs** as distance units. Higher movement numbers mean more studs
traveled each second. A move's **startup** is the delay before it can hit, its
**active time** is when its hitbox can deal damage, and its **recovery** is the
wait before the next action. A **hitbox** is an invisible region used to check
whether an attack reaches another fighter.

The client handles input, camera, display, immediate movement prediction, and a
non-authoritative predicted attack pose. Server feedback confirms or rejects it.
The server owns health, damage, move choice, combo state, cooldowns, hit timing,
stun, and knockback. It checks live characters, valid action types, rate limits,
grounded state, dash limits, hit range, and obstruction by walls. A target can be
hit only once by a particular swing. Basic travel auditing limits obvious
position manipulation; this is a prototype safeguard, not a claim of complete
anti-cheat protection.

Hitboxes are sampled repeatedly during active time, with one final validated
sample if a short server hitch crosses that window. A swing that is already
past its full recovery is discarded. These checks use current geometry, not
historical position rewind; network-latency tuning remains a manual test.

The client requests an action; it does not choose how much damage to inflict or
tell the server that a target was hit. This separation matters when more than
one player is connected.

## Open the prototype in Studio

1. Follow the tool installation steps in [README.md](../README.md), using the
   combat branch until it has been merged. Install the matching Rojo plugin.
2. In the repository folder, create `build` and run
   `rojo build default.project.json --output build/RiftWalkers.rbxlx`.
3. Open that file in Studio. Alternatively, start with a blank local place and
   run `rojo serve default.project.json` on the same computer as Studio, then
   connect the plugin to `localhost`, port `34872`, and review the sync.
4. Open **Explorer** and **Output**. Press **Play**. The server creates the arena,
   temporary fighter, and training dummy during play; they are not static art
   stored in the place file. The dummy should be within easy walking distance.
5. Run the solo checklist, then stop play. For multiplayer, use Studio's **Test**
   tools to start a local server with **2 players**, and run the multiplayer rows.
   Studio's labels can vary by version; use separate test clients, not only a
   single Play session.
6. Record the Studio version, input device, steps, result, and any Output errors
   in `TEST_LOG.md`. Add a reproducible bug to `BUGS.md` if a check fails.

Use a local test place, not an existing published experience. A cloud build
cannot replace these engine and input checks.

## Manual acceptance checklist — not yet run

| Check | Steps and expected result |
| --- | --- |
| Spawn and arena | Start Play. One controllable fighter and a stationary dummy appear inside the arena. Floor and boundaries hold the player; Output has no project errors. |
| Ground movement | Walk in every direction, strafe around the dummy, then hold sprint. Turning and stopping respond promptly; sprint is visibly faster. Releasing sprint restores walking. |
| Jump and air control | Jump while still, moving, and sprinting. Adjust direction in the air. The player lands normally and cannot fly indefinitely. |
| Ground dash | Dash while moving in each direction and while standing still. Travel is short, cooldown prevents immediate repeated bursts, and walls prevent passing through boundaries. |
| Air dash | Jump and dash, then try to dash again before landing. Only the configured air dash is allowed. Landing restores the allowance. |
| Light string | Move into reach and press light at a steady pace. The HUD progresses Jab → Cross → Kick and confirmed hits reduce dummy health. Pause past the 0.95-second reset window; the next light is Jab again. |
| Heavy and finisher | Try Heavy from neutral, Light → Light → Heavy for RisingHeavy, and Light → Light → Light → Heavy for Breaker. Compare timing and damage with Config. A slower startup is visible; input does not bypass recovery. |
| Aerial attacks | Jump and press light or heavy. The HUD shows AirLight or AirHeavy. Land and attack again; the grounded string starts over rather than resuming its old position. |
| Range and walls | Attack from beyond reach, facing away, and with a solid wall between fighters. No damage should register. Move into unobstructed reach and repeat; damage should register. |
| One hit per swing | Watch the health change from one attack while overlapping the target. It matches that move's damage once, rather than multiplying each frame or for every body part. |
| Hit reaction | On a confirmed hit, check feedback, brief stun, and knockback on an unanchored player. The stationary dummy may react visually while remaining in place. |
| Death and reset | Reduce dummy health to zero and wait for its reset. In a 2-player test, defeat a player and wait for respawn. The new character can move, target, and attack; the defeated body cannot continue hitting. |
| Two-player damage | On a 2-player local server, attack the other player. Both clients show the same health changes and visible hit feedback. Each player can control only their own character. |
| Interrupted attacks | With 2 players, hit someone during startup and defeat someone during startup. Stunned or dead fighters must not deliver a delayed hit after their attack has been interrupted. |
| Repeated input | Hold or rapidly repeat attacks and dash requests. Rate limits, cooldowns, recovery, and air limits still apply; no duplicate damage or Output errors appear. |
| Controller | Repeat movement, jump, sprint, dash, both attacks, and target selection with a controller. Chat/text focus should not accidentally trigger attacks. |
| Camera framing | Circle the target, move close and far away, jump, and change targets. Both fighters remain readable without abrupt flips; with no live nearby target, the camera still follows the player. |
| Camera obstruction | Move near arena walls and test a narrow viewport and different screen sizes. Check for clipping, hidden fighters, or unstable zoom. If a wall blocks a clear view, record the exact position. |
| Respawn and cleanup | Respawn repeatedly, stop and restart Play, and reconnect clients. Controls, camera, and feedback should not duplicate or remain stuck. Check Output throughout. |

The prototype can be accepted only after these manual results are recorded.
Measure responsiveness and grounded/aerial balance during playtesting, then tune
the configuration instead of assuming the starting values are final.

## What automated checks can establish

The Python project checks and Rojo build validate packaging and where scripts
land in Roblox. Luau command-line tests exercise pure combat policies with
repeatable inputs; they do not start Roblox, simulate network ownership, or
verify engine physics, camera feel, character animation, or controller hardware.
Run the commands documented in [tests/README.md](../tests/README.md), then run
the Studio checklist above. Keep those kinds of evidence separate.
