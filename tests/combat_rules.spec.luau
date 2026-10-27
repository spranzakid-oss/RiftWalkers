--!strict
-- Run with the Luau CLI: luau tests/combat_rules.spec.luau
-- These tests execute the same pure rules used by the live server.
local Rules = require("../src/shared/CombatRules")
local Config = require("../src/shared/Config")

local total = 0
local failures: { string } = {}

local function test(name: string, body: () -> ())
	total += 1
	local success, message = pcall(body)
	if success then
		print("PASS " .. name)
	else
		table.insert(failures, name .. ": " .. tostring(message))
		print("FAIL " .. failures[#failures])
	end
end

local function equal(actual: any, expected: any)
	assert(actual == expected, "expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function unchanged(state: any, before: any)
	for key, value in before do
		equal(state[key], value)
	end
end

local function attack(state: Rules.State, input: string, now: number, grounded: boolean, expected: string)
	local move, reason = Rules.attack(Config.Fighter, state, input, now, grounded)
	equal(reason, nil)
	equal(move, expected)
end

test("light string advances and wraps", function()
	local state = Rules.newState()
	for _, name in { "Jab", "Cross", "Kick", "Jab" } do
		attack(state, "Light", state.NextAttackAt, true, name)
	end
	equal(state.ComboIndex, 1)
end)

test("idle time resets the light string", function()
	local state = Rules.newState()
	attack(state, "Light", 1, true, "Jab")
	attack(state, "Light", state.NextAttackAt, true, "Cross")
	attack(state, "Light", state.LastAttackAt + Config.Fighter.ComboReset + 0.01, true, "Jab")
end)

test("combo reset boundary remains chainable", function()
	local state = Rules.newState()
	attack(state, "Light", 1, true, "Jab")
	attack(state, "Light", state.LastAttackAt + Config.Fighter.ComboReset, true, "Cross")
end)

test("heavy alone uses the default move and clears the chain", function()
	local state = Rules.newState()
	attack(state, "Heavy", 1, true, "Heavy")
	equal(state.ComboIndex, 0)
	attack(state, "Light", state.NextAttackAt, true, "Jab")
end)

test("two lights then heavy select the rising finisher", function()
	local state = Rules.newState()
	attack(state, "Light", 1, true, "Jab")
	attack(state, "Light", state.NextAttackAt, true, "Cross")
	attack(state, "Heavy", state.NextAttackAt, true, "RisingHeavy")
	equal(state.ComboIndex, 0)
end)

test("three lights then heavy select the breaker finisher", function()
	local state = Rules.newState()
	for _, name in { "Jab", "Cross", "Kick" } do
		attack(state, "Light", state.NextAttackAt, true, name)
	end
	attack(state, "Heavy", state.NextAttackAt, true, "Breaker")
	equal(state.ComboIndex, 0)
end)

test("a fighter can replace its string without changing the rules", function()
	local fighter = table.clone(Config.Fighter)
	fighter.LightString = { "Kick", "Jab" }
	fighter.HeavyFinishers = { [1] = "Breaker" }
	local state = Rules.newState()
	equal(Rules.attack(fighter, state, "Light", 1, true), "Kick")
	equal(Rules.attack(fighter, state, "Heavy", state.NextAttackAt, true), "Breaker")
	equal(Config.Fighter.LightString[1], "Jab")
	equal(Config.Fighter.HeavyFinishers[2], "RisingHeavy")
end)

test("aerial moves clear the ground chain instead of extending it", function()
	local state = Rules.newState()
	attack(state, "Light", 1, true, "Jab")
	attack(state, "Light", state.NextAttackAt, true, "Cross")
	attack(state, "Light", state.NextAttackAt, false, "AirLight")
	equal(state.ComboIndex, 0)
	attack(state, "Heavy", state.NextAttackAt, false, "AirHeavy")
	equal(state.ComboIndex, 0)
	attack(state, "Light", state.NextAttackAt, true, "Jab")
end)

for _, case in {
	{ Name = "invalid input", Input = "Launch", Field = "NextAttackAt", Value = 0, Reason = "invalid-input" },
	{ Name = "stun", Input = "Light", Field = "StunnedUntil", Value = 2, Reason = "stunned" },
	{ Name = "dash", Input = "Light", Field = "DashingUntil", Value = 2, Reason = "dashing" },
	{ Name = "recovery", Input = "Light", Field = "NextAttackAt", Value = 2, Reason = "recovery" },
} do
	test("attack rejects " .. case.Name .. " without advancing state", function()
		local state: any = Rules.newState()
		state[case.Field] = case.Value
		state.ComboIndex = 2
		local before = table.clone(state)
		local move, reason = Rules.attack(Config.Fighter, state, case.Input, 1, true)
		equal(move, nil)
		equal(reason, case.Reason)
		unchanged(state, before)
	end)
end

test("unknown configured moves fail without advancing state", function()
	local fighter = table.clone(Config.Fighter)
	fighter.LightString = { "MissingMove" }
	local state = Rules.newState()
	local before = table.clone(state)
	local move, reason = Rules.attack(fighter, state, "Light", 1, true)
	equal(move, nil)
	equal(reason, "unknown-move")
	unchanged(state, before)
end)

test("dash allows one air dash and ground contact resets allowance", function()
	local state = Rules.newState()
	local accepted, reason = Rules.dash(Config.Movement, state, 1, false)
	equal(accepted, true)
	equal(reason, nil)
	equal(state.AirDashes, 1)
	local at = state.NextDashAt
	local before = table.clone(state)
	accepted, reason = Rules.dash(Config.Movement, state, at, false)
	equal(accepted, false)
	equal(reason, "air-limit")
	unchanged(state, before)
	equal(Rules.dash(Config.Movement, state, at, true), true)
	equal(state.AirDashes, 0)
	equal(Rules.dash(Config.Movement, state, state.NextDashAt, false), true)
	equal(state.AirDashes, 1)
end)

for _, case in {
	{ Name = "stun", Field = "StunnedUntil", Reason = "stunned" },
	{ Name = "attack", Field = "NextAttackAt", Reason = "attacking" },
	{ Name = "cooldown", Field = "NextDashAt", Reason = "cooldown" },
} do
	test("dash rejects " .. case.Name .. " without advancing state", function()
		local state: any = Rules.newState()
		state[case.Field] = 2
		local before = table.clone(state)
		local accepted, reason = Rules.dash(Config.Movement, state, 1, false)
		equal(accepted, false)
		equal(reason, case.Reason)
		unchanged(state, before)
	end)
end

test("dash cooldown expires at its exact boundary", function()
	local state = Rules.newState()
	equal(Rules.dash(Config.Movement, state, 1, true), true)
	local accepted, reason = Rules.dash(Config.Movement, state, state.NextDashAt - 0.001, true)
	equal(accepted, false)
	equal(reason, "cooldown")
	equal(Rules.dash(Config.Movement, state, state.NextDashAt, true), true)
end)

test("hitbox includes finite edges and rejects rear, range, width, and height misses", function()
	local move = Config.Fighter.Moves.Jab
	equal(Rules.insideHitbox(0, 0, 0, move), true)
	equal(Rules.insideHitbox(move.Reach + 1, move.Width / 2, move.Height / 2, move), true)
	equal(Rules.insideHitbox(move.Reach, -move.Width / 2, -move.Height / 2, move), true)
	equal(Rules.insideHitbox(-0.001, 0, 0, move), false)
	equal(Rules.insideHitbox(move.Reach + 1.001, 0, 0, move), false)
	equal(Rules.insideHitbox(1, move.Width / 2 + 0.001, 0, move), false)
	equal(Rules.insideHitbox(1, 0, move.Height / 2 + 0.001, move), false)
	equal(Rules.insideHitbox(1, 0, -move.Height / 2 - 0.001, move), false)
end)

test("hitbox never accepts non-finite scalar coordinates", function()
	local move = Config.Fighter.Moves.Jab
	for _, nonFinite in { math.huge, -math.huge, 0 / 0 } do
		equal(Rules.insideHitbox(nonFinite, 0, 0, move), false)
		equal(Rules.insideHitbox(1, nonFinite, 0, move), false)
		equal(Rules.insideHitbox(1, 0, nonFinite, move), false)
	end
end)

test("active sampling begins at windup and covers active frames", function()
	local move = Config.Fighter.Moves.Jab
	equal(Rules.activeSample(0, move.Windup - 0.001, move), false)
	equal(Rules.activeSample(0, move.Windup, move), true)
	equal(Rules.activeSample(move.Windup, move.Windup + move.Active, move), true)
end)

test("active sampling catches a crossed window but never a fully stale attack", function()
	local move = Config.Fighter.Moves.Jab
	local activeEnd = move.Windup + move.Active
	equal(Rules.activeSample(move.Windup - 0.01, activeEnd + 0.01, move), true)
	equal(Rules.activeSample(activeEnd + 0.01, activeEnd + 0.02, move), false)
	equal(Rules.activeSample(0, activeEnd + move.Recovery, move), true)
	equal(Rules.activeSample(0, activeEnd + move.Recovery + 0.001, move), false)
end)

test("active sampling rejects rollback, negative time, and non-finite elapsed time", function()
	local move = Config.Fighter.Moves.Jab
	equal(Rules.activeSample(move.Windup + 0.01, move.Windup, move), false)
	equal(Rules.activeSample(-0.01, move.Windup, move), false)
	for _, nonFinite in { math.huge, -math.huge, 0 / 0 } do
		equal(Rules.activeSample(nonFinite, move.Windup, move), false)
		equal(Rules.activeSample(0, nonFinite, move), false)
	end
end)

test("configured combat values are finite and valid for timing and hit geometry", function()
	local fighter: any = Config.Fighter
	for moveName, move in fighter.Moves do
		for _, key in { "Damage", "Windup", "Active", "Recovery", "Reach", "Width", "Height", "Stun", "Knockback", "Lift" } do
			local value = move[key]
			assert(type(value) == "number" and value == value and math.abs(value) < math.huge, moveName .. "." .. key .. " must be finite")
			-- Lift is signed: AirHeavy intentionally sends a target downward.
			if key ~= "Lift" then
				assert(value >= 0, moveName .. "." .. key .. " cannot be negative")
			end
		end
		for _, key in { "Windup", "Active", "Recovery", "Reach", "Width", "Height" } do
			assert(move[key] > 0, moveName .. "." .. key .. " must be positive")
		end
	end
end)

test("configured strings are nonempty and reference real moves", function()
	local fighter: any = Config.Fighter
	assert(#fighter.LightString > 0, "LightString cannot be empty")
	for _, moveName in fighter.LightString do
		assert(fighter.Moves[moveName], "LightString refers to missing move " .. tostring(moveName))
	end
	for _, moveName in fighter.HeavyFinishers do
		assert(fighter.Moves[moveName], "HeavyFinishers refers to missing move " .. tostring(moveName))
	end
	for _, moveName in { "Heavy", "AirLight", "AirHeavy" } do
		assert(fighter.Moves[moveName], "Missing baseline move " .. moveName)
	end
end)

test("request limiter consumes a finite burst then rejects spam", function()
	local bucket = { Tokens = 3, At = 1 }
	for _ = 1, 3 do
		equal(Rules.consumeToken(bucket, 1, 2, 3), true)
	end
	equal(Rules.consumeToken(bucket, 1, 2, 3), false)
	equal(bucket.Tokens, 0)
end)

test("request limiter refills fractionally and caps accumulated credit", function()
	local bucket = { Tokens = 0, At = 1 }
	equal(Rules.consumeToken(bucket, 1.25, 2, 3), false)
	equal(bucket.Tokens, 0.5)
	equal(Rules.consumeToken(bucket, 1.5, 2, 3), true)
	equal(bucket.Tokens, 0)
	equal(Rules.consumeToken(bucket, 100, 2, 3), true)
	equal(bucket.Tokens, 2)
end)

test("clock rollback grants no extra request credit", function()
	local bucket = { Tokens = 0, At = 10 }
	equal(Rules.consumeToken(bucket, 9, 2, 3), false)
	equal(bucket.At, 10)
	equal(bucket.Tokens, 0)
	equal(Rules.consumeToken(bucket, 10, 2, 3), false)
	equal(Rules.consumeToken(bucket, 10.5, 2, 3), true)
end)

if #failures > 0 then
	error(string.format("%d of %d combat rule tests failed:\n%s", #failures, total, table.concat(failures, "\n")))
end
print(string.format("All %d combat rule tests passed (0 failures, 0 skipped).", total))
