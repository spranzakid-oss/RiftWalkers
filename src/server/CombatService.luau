--!strict
-- Server-owned combat. Clients request actions, never hits, targets, damage, or move IDs.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local Rules = require(ReplicatedStorage.Shared.CombatRules)
local Combat = {}
local records: { [Model]: any } = {}
local buckets: { [Player]: { Tokens: number, At: number } } = {}
local action: RemoteEvent
local feedback: RemoteEvent
local started = false

local function now(): number
	return Workspace:GetServerTimeNow()
end

local function finite(value: number): boolean
	return value == value and math.abs(value) < 1e6
end

local function alive(record: any): boolean
	return record.Model.Parent ~= nil and record.Root.Parent ~= nil and record.Humanoid.Health > 0
end

local function grounded(record: any): boolean
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { Workspace.Fighters }
	params.RespectCanCollide = true
	local hit = Workspace:Raycast(record.Root.Position, Vector3.new(0, -3.6, 0), params)
	return hit ~= nil and math.abs(record.Root.AssemblyLinearVelocity.Y) < 9
end

local function publish(record: any)
	record.Model:SetAttribute("AttackingUntil", record.State.NextAttackAt)
	record.Model:SetAttribute("StunnedUntil", record.State.StunnedUntil)
	record.Model:SetAttribute("DashingUntil", record.State.DashingUntil)
	record.Model:SetAttribute("ComboCount", record.State.ComboIndex)
end

local function reject(player: Player, requested: string)
	feedback:FireClient(player, { Kind = "Rejected", Action = requested })
end

local function updateMovement(record: any, time: number)
	local blocked = time < record.State.StunnedUntil
	local attacking = time < record.State.NextAttackAt
	local dummy = record.Model:GetAttribute("TrainingDummy") == true
	record.Humanoid.WalkSpeed = if blocked or dummy then 0
		elseif attacking then record.Movement.WalkSpeed * 0.4
		elseif record.Sprinting then record.Movement.SprintSpeed else record.Movement.WalkSpeed
	record.Humanoid.JumpPower = if blocked or attacking or dummy then 0 else record.Movement.JumpPower
end

function Combat.register(model: Model, player: Player?)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	assert(humanoid and root and root:IsA("BasePart"), "Fighter needs a Humanoid and root")
	local definition = Config.Fighters[model:GetAttribute("FighterId")]
	assert(definition, "Server spawned an unknown FighterId")
	humanoid.MaxHealth = definition.Combat.MaxHealth
	humanoid.Health = humanoid.MaxHealth
	local record = {
		Model = model, Player = player, Humanoid = humanoid, Root = root,
		Fighter = definition.Combat, Movement = definition.Movement,
		State = Rules.newState(), Sprinting = false, Swing = nil, Queued = nil,
		LastAuditAt = now(), LastGood = root.CFrame, KnockbackUntil = 0,
	}
	records[model] = record
	publish(record)
	model:SetAttribute("Sprinting", false)
	model.Destroying:Once(function() records[model] = nil end)
	humanoid.Died:Once(function()
		record.Swing = nil
		record.Queued = nil
		record.Sprinting = false
	end)
end

local function beginAttack(record: any, input: string, time: number): (boolean, string?)
	local moveName, reason = Rules.attack(record.Fighter, record.State, input, time, grounded(record))
	if not moveName then return false, reason end
	local move = record.Fighter.Moves[moveName]
	record.Swing = {
		Move = move, MoveName = moveName, Start = time,
		Origin = record.Root.Position, Hit = {}, LastSample = 0,
	}
	publish(record)
	updateMovement(record, time)
	feedback:FireAllClients({
		Kind = "Attack", Actor = record.Model, Move = moveName,
		Duration = move.Windup + move.Active + move.Recovery,
	})
	return true, nil
end

local function clearLine(attacker: any, target: any): boolean
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { attacker.Model, target.Model }
	params.RespectCanCollide = true
	local offset = Vector3.new(0, 0.5, 0)
	return Workspace:Raycast(attacker.Root.Position + offset, target.Root.Position - attacker.Root.Position, params) == nil
end

local function hit(attacker: any, target: any, move: any, time: number)
	target.State.StunnedUntil = math.max(target.State.StunnedUntil, time + move.Stun)
	target.State.ComboIndex = 0
	target.State.DashingUntil = time
	target.Swing = nil -- Getting hit interrupts windup, active frames, and buffered follow-ups.
	target.Queued = nil
	target.KnockbackUntil = target.State.StunnedUntil
	target.Humanoid:TakeDamage(move.Damage)
	publish(target)
	updateMovement(target, time)
	if not target.Root.Anchored and target.Humanoid.Health > 0 then
		-- Temporarily own hit physics so a client cannot negate server knockback.
		target.Root:SetNetworkOwner(nil)
		local displacement = target.Root.Position - attacker.Root.Position
		local flat = Vector3.new(displacement.X, 0, displacement.Z)
		local direction = if flat.Magnitude > 0.01 then flat.Unit else attacker.Root.CFrame.LookVector
		target.Root.AssemblyLinearVelocity = direction * move.Knockback + Vector3.new(0, move.Lift, 0)
		local untilTime = target.State.StunnedUntil
		task.delay(move.Stun + 0.05, function()
			if alive(target) and target.Player and target.Player.Parent == Players and now() >= target.State.StunnedUntil
				and target.State.StunnedUntil == untilTime then
				target.Root:SetNetworkOwner(target.Player)
			end
		end)
	end
	feedback:FireAllClients({ Kind = "Hit", Actor = attacker.Model, Target = target.Model, Damage = move.Damage })
end

local function sampleSwing(record: any, time: number)
	local swing = record.Swing
	if not swing then return end
	local elapsed = time - swing.Start
	local move = swing.Move
	if time < record.State.StunnedUntil or (record.Root.Position - swing.Origin).Magnitude > Config.Combat.MaxHitTravel then
		record.Swing = nil
		return
	end
	local shouldSample = Rules.activeSample(swing.LastSample, elapsed, move)
	swing.LastSample = elapsed
	local finished = elapsed > move.Windup + move.Active
	if finished then record.Swing = nil end
	if not shouldSample then return end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { Workspace.Fighters }
	local frame = record.Root.CFrame * CFrame.new(0, 0, -(move.Reach + 1) / 2)
	local parts = Workspace:GetPartBoundsInBox(frame, Vector3.new(move.Width, move.Height, move.Reach + 1), params)
	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		local target = if model then records[model] else nil
		if target and target ~= record and not swing.Hit[model] and alive(target) then
			local delta = record.Root.CFrame:PointToObjectSpace(target.Root.Position)
			if (target.Root.Position - record.Root.Position).Magnitude <= Config.Combat.MaxTargetDistance
				and Rules.insideHitbox(-delta.Z, delta.X, delta.Y, move) and clearLine(record, target) then
				swing.Hit[model] = true
				hit(record, target, move, time)
			end
		end
	end
end

local function auditTravel(record: any, time: number, force: boolean?): boolean
	local elapsed = time - record.LastAuditAt
	if not record.Player then return true end
	if not force and elapsed < Config.Combat.AuditInterval then return true end
	-- Lenient latency envelope, not a complete anti-cheat. Server never trusts submitted positions.
	local previous = record.LastGood.Position
	local current = record.Root.Position
	local delta = Vector3.new(current.X - previous.X, 0, current.Z - previous.Z).Magnitude
	local allowance = record.Movement.SprintSpeed * elapsed + Config.Combat.TravelSlack
	if time < record.State.DashingUntil + Config.Combat.AuditInterval then
		allowance += record.Movement.DashSpeed * record.Movement.DashDuration
	end
	if time < record.KnockbackUntil + 0.3 then allowance += 20 end
	local verticalAllowance = record.Movement.JumpPower * elapsed + Config.Combat.TravelSlack
	if time < record.KnockbackUntil + 0.3 then verticalAllowance += 20 end
	local invalid = not finite(current.X) or not finite(current.Y) or not finite(current.Z)
		or delta > allowance or current.Y - previous.Y > verticalAllowance
	if invalid then
		record.Root.CFrame = record.LastGood
		record.Root.AssemblyLinearVelocity = Vector3.zero
		record.Swing = nil
		record.Queued = nil
	elseif elapsed >= Config.Combat.AuditInterval then
		record.LastGood = record.Root.CFrame
	end
	-- A flood of requests must not refresh the slack allowance for each packet.
	if invalid or elapsed >= Config.Combat.AuditInterval then record.LastAuditAt = time end
	return not invalid
end

local function onAction(player: Player, requested: any, value: any)
	local time = now()
	local bucket = buckets[player]
	if not bucket then
		bucket = { Tokens = Config.Combat.RequestBurst, At = time }
		buckets[player] = bucket
	end
	if not Rules.consumeToken(bucket, time, Config.Combat.RequestsPerSecond, Config.Combat.RequestBurst) then return end
	if typeof(requested) ~= "string" then return end
	local record = if player.Character then records[player.Character] else nil
	if not record or not alive(record) then reject(player, requested) return end
	-- Check movement before accepting combat, not just after damage has been applied.
	if not auditTravel(record, time, true) then reject(player, requested) return end
	if requested == "Attack" then
		if value ~= "Light" and value ~= "Heavy" then reject(player, requested) return end
		local accepted, reason = beginAttack(record, value, time)
		if not accepted then
			if reason == "recovery" and record.State.NextAttackAt - time <= Config.Combat.InputBuffer
				and time >= record.State.StunnedUntil then
				record.Queued = { Input = value, Expires = time + Config.Combat.InputBuffer }
			else reject(player, requested) end
		end
	elseif requested == "Sprint" then
		if typeof(value) ~= "boolean" then reject(player, requested) return end
		record.Sprinting = value
		record.Model:SetAttribute("Sprinting", value)
		updateMovement(record, time)
	elseif requested == "Dash" then
		if typeof(value) ~= "Vector3" or not finite(value.X) or not finite(value.Y) or not finite(value.Z)
			or math.abs(value.Y) > 0.01 or value.Magnitude < 0.9 or value.Magnitude > 1.1 then
			reject(player, requested) return
		end
		local onGround = grounded(record)
		local accepted = Rules.dash(record.Movement, record.State, time, onGround)
		if not accepted then reject(player, requested) return end
		local speed = record.Movement.DashSpeed * (if onGround then 1 else record.Movement.AirDashMultiplier)
		record.DashDirection = value.Unit
		record.DashSpeed = speed
		record.Root.AssemblyLinearVelocity = value.Unit * speed + Vector3.new(0, record.Root.AssemblyLinearVelocity.Y, 0)
		publish(record)
		feedback:FireAllClients({ Kind = "Dash", Actor = record.Model })
	else
		reject(player, requested)
	end
end

function Combat.start()
	assert(not started, "Combat.start must only be called once")
	started = true
	local folder = Instance.new("Folder")
	folder.Name = "CombatRemotes"
	folder.Parent = ReplicatedStorage
	action = Instance.new("RemoteEvent")
	action.Name = "Action"
	action.Parent = folder
	feedback = Instance.new("RemoteEvent")
	feedback.Name = "Feedback"
	feedback.Parent = folder
	action.OnServerEvent:Connect(onAction)
	Players.PlayerRemoving:Connect(function(player) buckets[player] = nil end)
	RunService.Heartbeat:Connect(function()
		local time = now()
		for model, record in records do
			if not model.Parent then records[model] = nil continue end
			if not alive(record) then continue end
			auditTravel(record, time)
			if grounded(record) then record.State.AirDashes = 0 end
			if record.Queued then
				local queued = record.Queued
				if time > queued.Expires then record.Queued = nil
				elseif time >= record.State.NextAttackAt then
					record.Queued = nil
					beginAttack(record, queued.Input, time)
				end
			end
			if record.DashDirection and time < record.State.DashingUntil and time >= record.State.StunnedUntil then
				record.Root.AssemblyLinearVelocity = record.DashDirection * record.DashSpeed
					+ Vector3.new(0, record.Root.AssemblyLinearVelocity.Y, 0)
			else record.DashDirection = nil end
			sampleSwing(record, time)
			updateMovement(record, time)
		end
	end)
end

return Combat
