# Player interface and experience

Status: **approved_direction** for the journeys and input priorities below.
Interface details marked Proposed or TBD are not finalized artwork or layouts.
Systems are **planned** unless explicitly **implemented_unverified**. All future
numeric balance displays must identify **provisional** values during testing.
See [GAME_DESIGN.md](GAME_DESIGN.md) for design authority and scope.

## Principles and current state

Explain the player's next action, why an action is unavailable, what progress was
earned, and what is guaranteed. Controller and keyboard/mouse come first. Combat
must remain readable while both fighters move on the ground and in the air.

The current M1 HUD shows generic fighter/target health, a basic move/input label,
controls, and damage feedback. It is implemented_unverified. Collection, evolution,
party, PvP, store, and full training interfaces are not implemented. No finalized
artwork, icons, animation, sound, or screen compositions are supplied by this task.

## Core player journeys

| Journey | Approved information or action to support |
| --- | --- |
| Tutorial and starter choice | Explain combat/exploration and let the player choose Embercub, Zephy, or Pebblit |
| Creature collection | Show discovered creatures, permanent acquisition progress, selectable earlier forms, and the gameplay path to each unlock |
| Targeted Hunt | Explain the selected creature, guaranteed Character Echo progress, mission, and difficulty |
| Rift preparation | Choose solo or optional duo, show mission/difficulty, then ready before entry |
| Rift and extraction | Present the current objective, encounter/event/guardian progress, extraction, and checkpoint reward outcome |
| Evolution | Show required Sigils, mastery, Guardian materials, themed Trial, and progress toward each requirement |
| Training | Provide a dummy plus damage and input displays that help players discover strings |
| PvP | Explain mode, best-of format, queue/invite state, confirmed score/result, and ranked access progress |
| Optional purchases | Explain the item, price when approved, effect, duration conditions, and free gameplay alternatives |

These journeys describe required capabilities, not a mandate to build every
screen in the first playable slice. Follow [BUILD_PLAN.md](BUILD_PLAN.md).

## Combat and training readability

Keep fighter and target health distinct and make a confirmed hit distinguishable
from an attack input. Clearly present guard, stun, cooldowns, resources, and
ultimate readiness when those mechanics exist. Exact resource meters and special
bindings remain TBD; do not imply they are implemented through a decorative HUD.

**Proposed training presentation:** input history, damage per exchange, reset
controls, and readable attack-state explanations. The approved requirement is a
dummy with damage/input displays; extra training features require scope review.
The current input label is not a full historical input display.

Teach a small starting route before exposing deeper strings. Define unfamiliar
terms in context: a launcher sends an opponent upward; hitstun briefly prevents
normal action after a hit. Avoid treating a long combo list as the tutorial.

## Progress, co-op, and economy clarity

Show acquisition and evolution requirements separately. Guaranteed targeted
Echoes should display progress as a known path, not a chance-based reward.
Rift failure must explain reasonable partial checkpoint rewards without implying
a full completion reward. Resource quantities and time estimates are provisional
until their corresponding economy values have been tested.

Duo invitations need accept/decline, availability feedback, ready checks, and
disconnect/rejoin information. Show individual loot and revive state. Explain
that all creatures and evolutions remain obtainable solo; never label an unlock
as requiring a co-op-exclusive reward. Exact party screens and timers are TBD.

For paid boosts, explain which guaranteed resources accelerate and that timers
count only eligible active Rift play. Product IDs and prices remain placeholders.
Do not show mock prices as approved products or enable live purchases from this
document. See [MONETIZATION.md](MONETIZATION.md).

## Input, accessibility, and failure states

**Proposed UX acceptance requirements:** consistent controller focus, visible
focused controls, equivalent action access on both supported input methods,
readable text, and labels/icons in addition to element colors. Test aspect ratios
and camera comfort; exact customization settings and accessibility options are
TBD, not promised implemented features.

Prevent combat actions while typing or navigating a menu. A disconnect, expired
invite, unavailable match, failed save, or rejected action needs a plain-language
explanation and a safe next action. Do not claim progress or purchases succeeded
until the server confirms them. Retry behavior must not duplicate rewards.

## Manual review for a beginner

Start with the existing M1 place and follow
[docs/combat-prototype.md](docs/combat-prototype.md). Check the controls on both
input methods, confirm the health labels match, and inspect Studio's Output for
errors. Record the Studio version, steps, and actual result in TEST_LOG.md.
Future interface flows should receive equally concrete acceptance steps when
implemented. No Studio or controller playtest is claimed by these design documents.
