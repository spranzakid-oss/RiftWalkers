--!strict
-- Client prediction and presentation. Damage, combo acceptance, and hits stay on the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local CombatCamera = require(script.Parent:WaitForChild("CombatCamera"))
local remotes = ReplicatedStorage:WaitForChild("CombatRemotes")
local action = remotes:WaitForChild("Action") :: RemoteEvent
local feedback = remotes:WaitForChild("Feedback") :: RemoteEvent
local player = Players.LocalPlayer
local camera = CombatCamera.start(player)

local character: Model? = nil
local humanoid: Humanoid? = nil
local root: BasePart? = nil
local characterConnections: {RBXScriptConnection} = {}
local movement = Config.Movement
local sprinting = false
local dashUntil = 0
local nextDash = 0
local airDashes = 0
local dashDirection = Vector3.zero
local dashVertical = 0
local lastMove = "Ready"
local predictAttack: (() -> ())? = nil

local gui = Instance.new("ScreenGui")
gui.Name = "RiftWalkersHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

local function label(name: string, position: UDim2, size: UDim2, textSize: number): TextLabel
	local result = Instance.new("TextLabel")
	result.Name = name
	result.Position, result.Size = position, size
	result.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
	result.BackgroundTransparency = 0.2
	result.TextColor3 = Color3.fromRGB(240, 245, 255)
	result.Font = Enum.Font.GothamMedium
	result.TextSize = textSize
	result.TextWrapped = true
	result.BorderSizePixel = 0
	result.Parent = gui
	return result
end

local healthLabel = label("Health", UDim2.fromScale(0.02, 0.02), UDim2.fromScale(0.32, 0.065), 18)
local targetLabel = label("Target", UDim2.fromScale(0.66, 0.02), UDim2.fromScale(0.32, 0.065), 18)
local moveLabel = label("Move", UDim2.fromScale(0.35, 0.02), UDim2.fromScale(0.30, 0.065), 16)
local hints = label("Controls", UDim2.fromScale(0.08, 0.86), UDim2.fromScale(0.84, 0.11), 14)
hints.Text = "Move: WASD / Left stick   Jump: Space / A   Sprint: Shift / L3\nLight: Mouse 1 / X   Heavy: Mouse 2 / Y   Dash: Q / B   Cycle lock / unlock: Tab / R3"

local function now(): number return Workspace:GetServerTimeNow() end

local function untilAttribute(model: Model, name: string): number
	local value = model:GetAttribute(name)
	return if typeof(value) == "number" then value else 0
end

local function canAct(): boolean
	return character ~= nil and humanoid ~= nil and humanoid.Health > 0 and untilAttribute(character, "StunnedUntil") <= now()
end

local function setSprint(value: boolean)
	if sprinting == value then return end
	sprinting = value
	action:FireServer("Sprint", value)
end

local function cancelMovement()
	setSprint(false)
	dashUntil = 0
end

local function attach(newCharacter: Model)
	for _, connection in characterConnections do connection:Disconnect() end
	table.clear(characterConnections)
	cancelMovement()
	character, humanoid, root = nil, nil, nil
	local newHumanoid = newCharacter:WaitForChild("Humanoid", 10)
	local newRoot = newCharacter:WaitForChild("HumanoidRootPart", 10)
	if player.Character ~= newCharacter or newHumanoid == nil or not newHumanoid:IsA("Humanoid") or newRoot == nil or not newRoot:IsA("BasePart") then return end
	character, humanoid, root = newCharacter, newHumanoid, newRoot
	local fighterId = newCharacter:GetAttribute("FighterId")
	local definition = if typeof(fighterId) == "string" then Config.Fighters[fighterId] else nil
	movement = if definition then definition.Movement else Config.Movement
	airDashes, nextDash = 0, 0
	lastMove = "Ready"
	newHumanoid.UseJumpPower = true
	newHumanoid.JumpPower = movement.JumpPower
	table.insert(characterConnections, newHumanoid.Died:Connect(cancelMovement))
end

local function dash()
	local activeRoot, activeHumanoid, activeCharacter = root, humanoid, character
	if not canAct() or activeRoot == nil or activeHumanoid == nil or activeCharacter == nil or now() < nextDash then return end
	if untilAttribute(activeCharacter, "AttackingUntil") > now() then return end
	local airborne = activeHumanoid.FloorMaterial == Enum.Material.Air
	if airborne and airDashes >= movement.MaxAirDashes then return end
	local direction = activeHumanoid.MoveDirection
	if direction.Magnitude < 0.1 then direction = activeRoot.CFrame.LookVector end
	direction = Vector3.new(direction.X, 0, direction.Z)
	if direction.Magnitude < 0.1 then return end
	dashDirection = direction.Unit
	dashVertical = if airborne then math.clamp(activeRoot.AssemblyLinearVelocity.Y, -12, 12) else activeRoot.AssemblyLinearVelocity.Y
	dashUntil = now() + movement.DashDuration
	nextDash = now() + movement.DashCooldown
	if airborne then airDashes += 1 end
	action:FireServer("Dash", dashDirection)
end

local function handleInput(name: string, state: Enum.UserInputState, _input: InputObject): Enum.ContextActionResult
	if name == "RiftSprint" and (state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel) then
		setSprint(false)
		return Enum.ContextActionResult.Sink
	end
	if UserInputService:GetFocusedTextBox() ~= nil or GuiService.MenuIsOpen then return Enum.ContextActionResult.Pass end
	if state ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
	if name == "RiftLock" then
		camera.cycleTarget()
	elseif name == "RiftSprint" and canAct() then
		setSprint(true)
	elseif name == "RiftDash" then
		dash()
	elseif canAct() then
		action:FireServer("Attack", if name == "RiftLight" then "Light" else "Heavy")
		lastMove = if name == "RiftLight" then "Light input" else "Heavy input"
		if predictAttack then predictAttack() end
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority("RiftLight", handleInput, false, 3000, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonX)
ContextActionService:BindActionAtPriority("RiftHeavy", handleInput, false, 3000, Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonY)
ContextActionService:BindActionAtPriority("RiftSprint", handleInput, false, 3000, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
ContextActionService:BindActionAtPriority("RiftDash", handleInput, false, 3000, Enum.KeyCode.Q, Enum.KeyCode.ButtonB)
ContextActionService:BindActionAtPriority("RiftLock", handleInput, false, 3000, Enum.KeyCode.Tab, Enum.KeyCode.ButtonR3)
UserInputService.WindowFocusReleased:Connect(cancelMovement)
GuiService.MenuOpened:Connect(cancelMovement)
player.CharacterAdded:Connect(attach)
if player.Character then task.spawn(attach, player.Character) end

type Pose = { attackStarted: number, attackUntil: number, hitUntil: number, predicted: boolean }
local poses: {[Model]: Pose} = setmetatable({}, {__mode = "k"}) :: any

local function flash(model: Model, color: Color3)
	local highlight = Instance.new("Highlight")
	highlight.FillColor, highlight.OutlineColor = color, color
	highlight.FillTransparency = 0.35
	highlight.OutlineTransparency = 0.4
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Adornee = model
	highlight.Parent = model
	TweenService:Create(highlight, TweenInfo.new(0.22), {FillTransparency = 1, OutlineTransparency = 1}):Play()
	Debris:AddItem(highlight, 0.25)
end

predictAttack = function()
	local actor = character
	if actor == nil or untilAttribute(actor, "AttackingUntil") > now() then return end
	local existing = poses[actor]
	if existing and not existing.predicted and existing.attackUntil > now() then return end
	-- Predict presentation only. A rejected input cannot cause damage or grant a combo.
	poses[actor] = {attackStarted = now(), attackUntil = now() + 0.2, hitUntil = 0, predicted = true}
end

feedback.OnClientEvent:Connect(function(payload: any)
	if typeof(payload) ~= "table" then return end
	if payload.Kind == "Rejected" then
		if payload.Actor ~= nil and payload.Actor ~= character then return end
		if payload.Action == "Dash" then
			dashUntil = 0
			if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
		elseif payload.Action == "Sprint" then
			sprinting = false
		elseif payload.Action == "Attack" and character then
			local pose = poses[character]
			if pose and pose.predicted then pose.attackStarted, pose.attackUntil = 0, 0 end
		end
		return
	end
	local actor = payload.Actor
	if typeof(actor) ~= "Instance" or not actor:IsA("Model") then return end
	if payload.Kind == "Attack" then
		local duration = if typeof(payload.Duration) == "number" then math.clamp(payload.Duration, 0.08, 2) else 0.3
		local old = poses[actor]
		poses[actor] = {attackStarted = now(), attackUntil = now() + duration, hitUntil = if old then old.hitUntil else 0, predicted = false}
		flash(actor, Color3.fromRGB(85, 205, 255))
		if actor == character and typeof(payload.Move) == "string" then lastMove = payload.Move end
	elseif payload.Kind == "Hit" then
		local victim = payload.Target
		if typeof(victim) ~= "Instance" or not victim:IsA("Model") then return end
		local old = poses[victim]
		poses[victim] = {attackStarted = if old then old.attackStarted else 0, attackUntil = if old then old.attackUntil else 0, hitUntil = now() + 0.24, predicted = if old then old.predicted else false}
		flash(victim, Color3.fromRGB(255, 85, 90))
		local head = victim:FindFirstChild("Head")
		if head and head:IsA("BasePart") and typeof(payload.Damage) == "number" then
			local billboard = Instance.new("BillboardGui")
			billboard.Adornee = head
			billboard.Size = UDim2.fromOffset(100, 45)
			billboard.StudsOffset = Vector3.new(0, 3, 0)
			billboard.AlwaysOnTop = true
			billboard.Parent = gui
			local text = Instance.new("TextLabel")
			text.Size, text.BackgroundTransparency = UDim2.fromScale(1, 1), 1
			text.Font, text.TextSize = Enum.Font.GothamBold, 26
			text.TextColor3 = Color3.fromRGB(255, 220, 120)
			text.Text = string.format("-%d", payload.Damage)
			text.Parent = billboard
			TweenService:Create(billboard, TweenInfo.new(0.6), {StudsOffset = Vector3.new(0, 5, 0)}):Play()
			TweenService:Create(text, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
			Debris:AddItem(billboard, 0.65)
		end
	elseif payload.Kind == "Dash" then
		flash(actor, Color3.fromRGB(150, 255, 210))
	end
end)

RunService.RenderStepped:Connect(function(dt: number)
	local activeCharacter, activeHumanoid, activeRoot = character, humanoid, root
	local target = camera.getTarget()
	if activeCharacter and activeHumanoid and activeRoot and activeHumanoid.Health > 0 then
		local time = now()
		local stunned = untilAttribute(activeCharacter, "StunnedUntil") > time
		local attacking = untilAttribute(activeCharacter, "AttackingUntil") > time
		local airborne = activeHumanoid.FloorMaterial == Enum.Material.Air
		if not airborne then airDashes = 0 end
		activeHumanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, not stunned and not attacking)
		if stunned then
			activeHumanoid.WalkSpeed = 0
			activeHumanoid.Jump = false
			dashUntil = 0
		elseif not attacking then
			activeHumanoid.WalkSpeed = if sprinting then movement.SprintSpeed else movement.WalkSpeed
		end
		if not stunned and dashUntil > time then
			local speed = movement.DashSpeed * (if airborne then movement.AirDashMultiplier else 1)
			activeRoot.AssemblyLinearVelocity = dashDirection * speed + Vector3.new(0, dashVertical, 0)
		elseif airborne and not stunned and activeHumanoid.MoveDirection.Magnitude > 0.05 then
			local velocity = activeRoot.AssemblyLinearVelocity
			local flat = Vector3.new(velocity.X, 0, velocity.Z)
			local desired = activeHumanoid.MoveDirection * movement.MaxAirSpeed
			local difference = desired - flat
			local acceleration = movement.AirAcceleration * math.min(dt, 0.1)
			if difference.Magnitude > acceleration then difference = difference.Unit * acceleration end
			-- Steering does not remove a server-applied knockback impulse while stunned.
			flat += difference
			activeRoot.AssemblyLinearVelocity = flat + Vector3.new(0, velocity.Y, 0)
		end
		local targetRoot = if target then target:FindFirstChild("HumanoidRootPart") else nil
		if targetRoot and targetRoot:IsA("BasePart") and not stunned then
			activeHumanoid.AutoRotate = false
			local flat = Vector3.new(targetRoot.Position.X - activeRoot.Position.X, 0, targetRoot.Position.Z - activeRoot.Position.Z)
			if flat.Magnitude > 0.1 then
				activeRoot.CFrame = activeRoot.CFrame:Lerp(CFrame.lookAt(activeRoot.Position, activeRoot.Position + flat), 1 - math.exp(-20 * dt))
			end
		else
			activeHumanoid.AutoRotate = true
		end
		healthLabel.Text = string.format("Test Fighter  %d / %d", math.ceil(activeHumanoid.Health), activeHumanoid.MaxHealth)
	else
		healthLabel.Text = "Waiting for fighter / respawn…"
	end
	local targetHumanoid = if target then target:FindFirstChildOfClass("Humanoid") else nil
	targetLabel.Text = if target and targetHumanoid then string.format("%s  %d / %d", target.Name, math.ceil(targetHumanoid.Health), targetHumanoid.MaxHealth) else "No target · Tab / R3 to lock"
	local combo = if activeCharacter then activeCharacter:GetAttribute("ComboCount") else nil
	moveLabel.Text = lastMove .. (if typeof(combo) == "number" and combo > 0 then string.format(" · Chain %d", combo) else "")

	-- Placeholder R6 poses make attacks and stagger readable without uploaded assets.
	for model, pose in poses do
		if model.Parent == nil then poses[model] = nil; continue end
		local shoulder = model:FindFirstChild("Right Shoulder", true)
		local waist = model:FindFirstChild("RootJoint", true)
		if shoulder and shoulder:IsA("Motor6D") then
			local duration = math.max(pose.attackUntil - pose.attackStarted, 0.01)
			local progress = math.clamp((now() - pose.attackStarted) / duration, 0, 1)
			shoulder.Transform = CFrame.Angles(-math.sin(progress * math.pi) * 1.8, 0, -math.sin(progress * math.pi) * 0.6)
		end
		if waist and waist:IsA("Motor6D") then
			waist.Transform = if pose.hitUntil > now() then CFrame.Angles(0.12, 0, math.sin(now() * 55) * 0.12) else CFrame.identity
		end
		if now() > math.max(pose.attackUntil, pose.hitUntil) then poses[model] = nil end
	end
end)
