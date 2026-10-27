--!strict
-- A lock-on camera that frames both combatants without controlling combat rules.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local CombatCamera = {}

local function rootOf(model: Model?): BasePart?
	if model == nil then return nil end
	local root = model:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function alive(model: Model?): boolean
	if model == nil or model.Parent == nil then return false end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0 and rootOf(model) ~= nil
end

function CombatCamera.start(player: Player)
	local target: Model? = nil
	local unlocked = false
	local lastView = Vector3.new(0.5, 0, 1).Unit
	local previous: CFrame? = nil
	local binding = "RiftWalkersCombatCamera"

	local function candidates(): {Model}
		local list: {Model} = {}
		local root = rootOf(player.Character)
		local fighters = Workspace:FindFirstChild("Fighters")
		if root == nil or fighters == nil then return list end
		for _, fighter in fighters:GetChildren() do
			if fighter:IsA("Model") and fighter ~= player.Character and fighter:GetAttribute("Combatant") == true and alive(fighter) then
				local otherRoot = rootOf(fighter)
				if otherRoot and (otherRoot.Position - root.Position).Magnitude <= Config.Camera.LockRange then
					table.insert(list, fighter)
				end
			end
		end
		table.sort(list, function(a, b)
			local ar, br = rootOf(a), rootOf(b)
			return ar ~= nil and br ~= nil and (ar.Position - root.Position).Magnitude < (br.Position - root.Position).Magnitude
		end)
		return list
	end

	local function validTarget(): Model?
		local ownRoot, otherRoot = rootOf(player.Character), rootOf(target)
		if not alive(target) or ownRoot == nil or otherRoot == nil or (otherRoot.Position - ownRoot.Position).Magnitude > Config.Camera.LockRange then
			target = nil
		end
		if target == nil and not unlocked then target = candidates()[1] end
		return target
	end

	RunService:BindToRenderStep(binding, Enum.RenderPriority.Camera.Value + 1, function(dt: number)
		local camera = Workspace.CurrentCamera
		local ownRoot = rootOf(player.Character)
		if camera == nil then return end
		if ownRoot == nil or not alive(player.Character) then
			camera.CameraType = Enum.CameraType.Custom
			previous = nil
			target = nil
			return
		end
		camera.CameraType = Enum.CameraType.Scriptable
		local otherRoot = rootOf(validTarget())
		local center = ownRoot.Position + Vector3.new(0, 2, 0)
		local radius = Config.Camera.Padding
		if otherRoot then
			local separation = otherRoot.Position - ownRoot.Position
			center = (ownRoot.Position + otherRoot.Position) * 0.5 + Vector3.new(0, 2, 0)
			radius = separation.Magnitude * 0.5 + Config.Camera.Padding
			local side = Vector3.new(-separation.Z, 0, separation.X)
			if side.Magnitude > 0.1 then
				side = side.Unit
				-- Keep the same side of the fight when fighters cross each other.
				if side:Dot(lastView) < 0 then side = -side end
				lastView = lastView:Lerp(side, 1 - math.exp(-Config.Camera.Smoothness * dt)).Unit
			end
		else
			local behind = -Vector3.new(ownRoot.CFrame.LookVector.X, 0, ownRoot.CFrame.LookVector.Z)
			if behind.Magnitude > 0.1 then
				local blended = lastView:Lerp(behind.Unit, 1 - math.exp(-5 * dt))
				if blended.Magnitude > 0.01 then lastView = blended.Unit end
			end
		end

		local aspect = math.max(camera.ViewportSize.X / math.max(camera.ViewportSize.Y, 1), 0.25)
		local verticalHalf = math.rad(Config.Camera.FieldOfView * 0.5)
		local horizontalHalf = math.atan(math.tan(verticalHalf) * aspect)
		local fitDistance = radius / math.sin(math.min(verticalHalf, horizontalHalf))
		local distance = math.clamp(fitDistance, Config.Camera.MinDistance, Config.Camera.MaxDistance)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.RespectCanCollide = true
		local fighters = Workspace:FindFirstChild("Fighters")
		params.FilterDescendantsInstances = if fighters then {fighters} else {player.Character :: Model}
		local function obstruction(position: Vector3): RaycastResult?
			local offset = position - center
			return if offset.Magnitude > 0.01 then Workspace:Spherecast(center, 0.5, offset, params) else nil
		end
		local height = Config.Camera.Height + distance * 0.15
		local preferred = center + lastView * distance + Vector3.new(0, height, 0)
		local opposite = center - lastView * distance + Vector3.new(0, height, 0)
		-- Preserve framing distance before moving closer: the arena has an open top.
		local overhead = center + lastView * (distance * 0.18) + Vector3.new(0, distance + Config.Camera.Height, 0)
		local desiredPosition: Vector3? = nil
		local fallback = preferred
		local fallbackDistance = -1
		for _, position in {preferred, opposite, overhead} do
			local blocked = obstruction(position)
			if blocked == nil then desiredPosition = position; break end
			local safe = blocked.Position + blocked.Normal * 0.85
			local availableDistance = (safe - center).Magnitude
			if availableDistance > fallbackDistance then
				fallback, fallbackDistance = safe, availableDistance
			end
		end
		-- Enclosed future maps may leave no full-distance view. Prefer not clipping
		-- through geometry, then widen the lens; arbitrary enclosed spaces cannot
		-- guarantee that both fighters fit. Such maps need their own camera testing.
		local selectedPosition = desiredPosition or fallback
		local alpha = 1 - math.exp(-Config.Camera.Smoothness * dt)
		local finalPosition = selectedPosition
		if previous then
			local from = previous.Position - center
			local to = selectedPosition - center
			if from.Magnitude > 0.01 and to.Magnitude > 0.01 then
				-- Smooth around the focus on a sphere rather than cutting across its
				-- center when switching sides, which would temporarily crop fighters.
				local direction = from.Unit:Lerp(to.Unit, alpha)
				if direction.Magnitude > 0.01 then
					local length = math.max(to.Magnitude, from.Magnitude + (to.Magnitude - from.Magnitude) * alpha)
					finalPosition = center + direction.Unit * length
				end
			end
			-- A clear endpoint does not make its interpolated path clear. Snap to
			-- the selected safe view if smoothing would place the camera behind a wall.
			if obstruction(finalPosition) then finalPosition = selectedPosition end
		end
		local actualDistance = math.max((finalPosition - center).Magnitude, 0.1)
		local neededHalf = math.asin(math.clamp(radius / actualDistance, 0, 0.95))
		local neededFov = math.deg(2 * math.atan(math.tan(neededHalf) / math.min(aspect, 1)))
		camera.FieldOfView = math.clamp(math.max(Config.Camera.FieldOfView, neededFov), Config.Camera.FieldOfView, 100)
		local frame = CFrame.lookAt(finalPosition, center)
		previous = frame
		camera.CFrame = frame
		camera.Focus = CFrame.new(center)
	end)

	return {
		getTarget = validTarget,
		cycleTarget = function()
			local list = candidates()
			local index = if target then table.find(list, target) else nil
			if unlocked or index == nil then
				target = list[1]
				unlocked = false
			elseif index < #list then
				target = list[index + 1]
			else
				target = nil
				unlocked = true
			end
		end,
		destroy = function()
			RunService:UnbindFromRenderStep(binding)
			local camera = Workspace.CurrentCamera
			if camera then
				camera.CameraType = Enum.CameraType.Custom
				camera.FieldOfView = 70
			end
		end,
	}
end

return CombatCamera
