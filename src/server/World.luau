--!strict
-- Asset-free test world and one reusable R6 test fighter; no avatar downloads.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local World = {}
local started = false

local function part(parent: Instance, name: string, size: Vector3, color: Color3, anchored: boolean): Part
	local result = Instance.new("Part")
	result.Name = name
	result.Size = size
	result.Color = color
	result.Material = Enum.Material.SmoothPlastic
	result.TopSurface = Enum.SurfaceType.Smooth
	result.BottomSurface = Enum.SurfaceType.Smooth
	result.Anchored = anchored
	result.Parent = parent
	return result
end

local function joint(name: string, first: BasePart, second: BasePart, c0: CFrame, c1: CFrame)
	local motor = Instance.new("Motor6D")
	motor.Name = name
	motor.Part0 = first
	motor.Part1 = second
	motor.C0 = c0
	motor.C1 = c1
	motor.Parent = first
end

local function makeFighter(name: string, color: Color3, position: Vector3, dummy: boolean): (Model, Humanoid, Part)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("FighterId", "TestFighter")
	model:SetAttribute("Combatant", true)
	model:SetAttribute("TrainingDummy", dummy)
	local root = part(model, "HumanoidRootPart", Vector3.new(2, 2, 1), color, dummy)
	root.Transparency = 1
	root.CanCollide = false
	local torso = part(model, "Torso", Vector3.new(2, 2, 1), color, false)
	local head = part(model, "Head", Vector3.new(2, 1, 1), Color3.fromRGB(235, 207, 166), false)
	head.Position = Vector3.new(0, 1.5, 0)
	local leftArm = part(model, "Left Arm", Vector3.new(1, 2, 1), color, false)
	local rightArm = part(model, "Right Arm", Vector3.new(1, 2, 1), color, false)
	local leftLeg = part(model, "Left Leg", Vector3.new(1, 2, 1), Color3.fromRGB(43, 49, 66), false)
	local rightLeg = part(model, "Right Leg", Vector3.new(1, 2, 1), Color3.fromRGB(43, 49, 66), false)
	leftArm.Position = Vector3.new(-1.5, 0, 0)
	rightArm.Position = Vector3.new(1.5, 0, 0)
	leftLeg.Position = Vector3.new(-0.5, -2, 0)
	rightLeg.Position = Vector3.new(0.5, -2, 0)
	for _, limb in { leftArm, rightArm, leftLeg, rightLeg } do
		limb.CanCollide = false
		limb.Massless = true
	end
	joint("RootJoint", root, torso, CFrame.identity, CFrame.identity)
	joint("Neck", torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0))
	joint("Left Shoulder", torso, leftArm, CFrame.new(-1, 0.5, 0), CFrame.new(0.5, 0.5, 0))
	joint("Right Shoulder", torso, rightArm, CFrame.new(1, 0.5, 0), CFrame.new(-0.5, 0.5, 0))
	joint("Left Hip", torso, leftLeg, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))
	joint("Right Hip", torso, rightLeg, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = if dummy then "Training Dummy" else name
	humanoid.MaxHealth = Config.Fighter.MaxHealth
	humanoid.Health = humanoid.MaxHealth
	humanoid.UseJumpPower = true
	humanoid.JumpPower = Config.Movement.JumpPower
	humanoid.WalkSpeed = if dummy then 0 else Config.Movement.WalkSpeed
	humanoid.AutoRotate = not dummy
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.NameDisplayDistance = 100
	humanoid.HealthDisplayDistance = 100
	humanoid.Parent = model
	model.PrimaryPart = root
	model:PivotTo(CFrame.lookAt(position, position + Vector3.new(0, 0, if dummy then 1 else -1)))
	return model, humanoid, root
end

local function buildArena()
	local arena = Instance.new("Folder")
	arena.Name = "TestArena"
	arena.Parent = Workspace
	local size = Config.Arena.Size
	local floor = part(arena, "Floor", Vector3.new(size, 2, size), Color3.fromRGB(54, 63, 82), true)
	floor.Position = Vector3.new(0, -1, 0)
	for index, spec in {
		{ Vector3.new(size + 4, 10, 2), Vector3.new(0, 5, -size / 2) },
		{ Vector3.new(size + 4, 10, 2), Vector3.new(0, 5, size / 2) },
		{ Vector3.new(2, 10, size), Vector3.new(-size / 2, 5, 0) },
		{ Vector3.new(2, 10, size), Vector3.new(size / 2, 5, 0) },
	} do
		local wall = part(arena, "Boundary" .. index, spec[1], Color3.fromRGB(30, 36, 51), true)
		wall.Position = spec[2]
	end
	for _, offset in { -size / 4, 0, size / 4 } do
		for _, alongX in { true, false } do
			local stripe = part(arena, "GridLine", if alongX then Vector3.new(size - 4, 0.04, 0.12) else Vector3.new(0.12, 0.04, size - 4), Color3.fromRGB(106, 126, 151), true)
			stripe.CanCollide = false
			stripe.Position = if alongX then Vector3.new(0, 0.03, offset) else Vector3.new(offset, 0.03, 0)
		end
	end
	for _, z in { -14, 14 } do
		local pad = part(arena, "FighterStart", Vector3.new(6, 0.05, 6), Color3.fromRGB(49, 131, 163), true)
		pad.Position = Vector3.new(0, 0.04, z)
		pad.CanCollide = false
	end
	Workspace.FallenPartsDestroyHeight = -50
end

function World.start(onFighterReady: (Model, Player?) -> ())
	assert(not started, "World.start must only be called once")
	started = true
	Players.CharacterAutoLoads = false
	buildArena()
	local fighters = Instance.new("Folder")
	fighters.Name = "Fighters"
	fighters.Parent = Workspace
	local slots: { [Player]: number } = {}
	local nextSlot = 0

	local function spawnPlayer(player: Player)
		if player.Parent ~= Players then
			return
		end
		if player.Character then
			player.Character:Destroy()
		end
		if not slots[player] then
			nextSlot += 1
			slots[player] = nextSlot
		end
		local angle = ((slots[player] - 1) % 8) * math.pi / 4
		-- The first two players stand on opposite sides of the central dummy.
		if slots[player] == 2 then
			angle = math.pi
		end
		local position = Vector3.new(math.sin(angle) * 14, 3.1, math.cos(angle) * 14)
		local model, humanoid, root = makeFighter(player.DisplayName, Color3.fromRGB(62, 164, 225), position, false)
		model:PivotTo(CFrame.lookAt(position, Vector3.new(0, position.Y, 0)))
		model.Parent = fighters
		player.Character = model
		root:SetNetworkOwner(player)
		onFighterReady(model, player)
		humanoid.Died:Connect(function()
			task.delay(Config.Arena.RespawnSeconds, function()
				if player.Parent == Players and player.Character == model then
					spawnPlayer(player)
				end
			end)
		end)
	end

	local function spawnDummy()
		local model, humanoid = makeFighter("TrainingDummy", Color3.fromRGB(230, 142, 51), Vector3.new(0, 3.1, 0), true)
		model.Parent = fighters
		onFighterReady(model, nil)
		humanoid.Died:Connect(function()
			task.delay(Config.Arena.DummyResetSeconds, function()
				model:Destroy()
				spawnDummy()
			end)
		end)
	end

	spawnDummy()
	Players.PlayerAdded:Connect(spawnPlayer)
	Players.PlayerRemoving:Connect(function(player)
		slots[player] = nil
		if player.Character then
			player.Character:Destroy()
		end
	end)
	for _, player in Players:GetPlayers() do
		spawnPlayer(player)
	end
end

return World
