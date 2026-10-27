--!strict
-- Pure decision rules: no Instances, remotes, clocks, or client-supplied damage.
local Rules = {}

export type State = {
	NextAttackAt: number,
	LastAttackAt: number,
	ComboIndex: number,
	StunnedUntil: number,
	DashingUntil: number,
	NextDashAt: number,
	AirDashes: number,
}

function Rules.newState(): State
	return {
		NextAttackAt = 0, LastAttackAt = -math.huge, ComboIndex = 0,
		StunnedUntil = 0, DashingUntil = 0, NextDashAt = 0, AirDashes = 0,
	}
end

function Rules.attack(fighter: any, state: State, input: string, now: number, grounded: boolean): (string?, string?)
	if input ~= "Light" and input ~= "Heavy" then return nil, "invalid-input" end
	if now < state.StunnedUntil then return nil, "stunned" end
	if now < state.DashingUntil then return nil, "dashing" end
	if now < state.NextAttackAt then return nil, "recovery" end
	local index = if now - state.LastAttackAt <= fighter.ComboReset then state.ComboIndex else 0
	local moveName: string
	if not grounded then
		moveName = if input == "Light" then "AirLight" else "AirHeavy"
		index = 0
	elseif input == "Light" then
		index = (index % #fighter.LightString) + 1
		moveName = fighter.LightString[index]
	else
		moveName = fighter.HeavyFinishers[index] or "Heavy"
		index = 0
	end
	local move = fighter.Moves[moveName]
	if not move then return nil, "unknown-move" end
	state.ComboIndex = index
	state.LastAttackAt = now
	state.NextAttackAt = now + move.Windup + move.Active + move.Recovery
	return moveName, nil
end

function Rules.dash(movement: any, state: State, now: number, grounded: boolean): (boolean, string?)
	if now < state.StunnedUntil then return false, "stunned" end
	if now < state.NextAttackAt then return false, "attacking" end
	if now < state.NextDashAt then return false, "cooldown" end
	if grounded then state.AirDashes = 0 end
	if not grounded and state.AirDashes >= movement.MaxAirDashes then return false, "air-limit" end
	if not grounded then state.AirDashes += 1 end
	state.NextDashAt = now + movement.DashCooldown
	state.DashingUntil = now + movement.DashDuration
	return true, nil
end

-- Finite vector checks occur before this scalar policy is used.
function Rules.insideHitbox(forward: number, sideways: number, vertical: number, move: any): boolean
	return forward >= 0 and forward <= move.Reach + 1
		and math.abs(sideways) <= move.Width * 0.5
		and math.abs(vertical) <= move.Height * 0.5
end

-- Sample when an active window was crossed, even if a short server stall skipped
-- its individual frames. Never turn an entirely stale swing into a delayed hit.
function Rules.activeSample(previousElapsed: number, elapsed: number, move: any): boolean
	local activeEnd = move.Windup + move.Active
	return previousElapsed >= 0 and elapsed >= previousElapsed
		and elapsed >= move.Windup and previousElapsed <= activeEnd
		and elapsed <= activeEnd + move.Recovery
end

function Rules.consumeToken(bucket: { Tokens: number, At: number }, now: number, rate: number, burst: number): boolean
	bucket.Tokens = math.min(burst, bucket.Tokens + math.max(0, now - bucket.At) * rate)
	bucket.At = math.max(now, bucket.At)
	if bucket.Tokens < 1 then return false end
	bucket.Tokens -= 1
	return true
end

return Rules
