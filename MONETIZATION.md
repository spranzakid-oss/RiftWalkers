# Monetization

**Status:** Approved boundaries; purchases and boost systems are planned, not
implemented. No product is enabled by this document. All prices, product IDs,
boost amounts, and durations remain **TBD / Provisional**. See
[GAME_DESIGN.md](GAME_DESIGN.md) and
[config/design/economy.json](config/design/economy.json).

## Approved model

Optional paid boosts may accelerate guaranteed **Character Echoes, elemental
Sigils, creature mastery, and Guardian resources**. Cosmetics and noncombat
conveniences are permitted. Every fighter and evolution remains permanently
obtainable through gameplay, including solo play.

The approved constraints are:

- No paid-only fighters or moves.
- No paid PvP combat advantages or direct purchases of stronger combat statistics.
- No paid random-chance boosts in the initial release.
- Boost timers count only eligible **active Rift play**.
- Product IDs and prices remain placeholders.
- Do not create or enable live purchases without explicit approval.

A guaranteed reward boost accelerates a stated earned resource; it must not
quietly become a paid roll for a creature. Specific cosmetics, convenience
products, limits, and prices have not been selected.

## Competitive fairness is a release gate

Paid progression speed can grant earlier access to a powerful creature or a wider
counter-pick collection. This is a possible indirect competitive advantage even
when purchases do not change an individual move's damage.

The approved “no paid PvP combat advantages” rule therefore requires an explicit
PvP fairness policy before purchases launch. Character power normalization,
collection restrictions, matchmaking, or other approaches may be evaluated, but
none is selected as the release solution here. Normalized Thundermaw/Worldforge
power is approved for initial prototype tests only. Do not claim that prototype
normalization has solved ranked fairness.

Validate the unboosted solo journey, competitive access, and player understanding
before finalizing products. A purchaser and a non-purchaser must not receive
different move rules, server authority, or exclusive competitive abilities.

## Eligible active-play timers

The approved timer rule excludes lobby, queue, loading, offline, and disconnected
time from eligible active Rift play. The exact handling of menus, inactivity,
revives, cutscenes, checkpoint pauses, and reconnect recovery remains TBD.

**Proposed architecture:** the server tracks boost ownership and eligible elapsed
time for a verified mission participant. The client displays remaining time but
cannot extend it, mark itself active, or choose a multiplier. Record state so a
reconnect neither consumes excluded time nor restores already spent eligible time.
No timer or inactivity detector is implemented by this documentation task.

Boost stacking, maximum duration, expiry during a run, partial rewards, and
application to converted Guardian Cores remain unfinalized. Decide where each
boost applies once so boosting Fragments and then converting them does not
accidentally apply the same reward boost again.

## Product data and purchase safety

Keep IDs and prices unset (`null` in machine-readable planning data), not fake
Roblox IDs or live catalog entries. Do not insert a real product, create a live
purchase prompt, or enable sales without approval. A design review is not purchase
activation approval.

**Proposed implementation requirement:** a server-validated receipt is processed
idempotently. That means retrying the same receipt can recover an interrupted
purchase without granting the product twice. Persist the grant and receipt state
before acknowledging fulfillment. The client never supplies proof of payment.
The final receipt/storage implementation and Roblox product choices remain TBD.

## Player-facing presentation

Before a purchase, clearly explain what changes, the guaranteed reward affected,
how eligible active time works, and the eventual price/duration. Show current
ownership and remaining eligible time. Keep gameplay acquisition routes visible
beside optional acceleration; do not disguise a payment as a required evolution
step. Exact screens and copy are unfinalized; see [UI_UX.md](UI_UX.md).

## Acceptance before launch

- Test the complete unboosted solo journey and the approved PvP fairness policy.
- Test timer exclusions, reconnects, inactivity decisions, expiry, and stacking rules.
- Retry receipt delivery, interrupt saving, and confirm one recoverable grant.
- Verify no paid-only content, paid combat-stat path, or paid random-chance boost.
- Obtain explicit approval for real products, prices, and activation before enabling sales.

See [ECONOMY.md](ECONOMY.md), [PVP.md](PVP.md), and [TESTING.md](TESTING.md).
