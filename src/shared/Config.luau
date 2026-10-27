--!strict
-- All distances are studs; all times are seconds. No Roblox APIs: also testable in Luau CLI.
local Config = {
	Fighter = {
		Id = "TestFighter",
		MaxHealth = 100,
		ComboReset = 0.95,
		LightString = { "Jab", "Cross", "Kick" },
		HeavyFinishers = { [2] = "RisingHeavy", [3] = "Breaker" },
		Moves = {
			Jab = { Damage = 7, Windup = 0.10, Active = 0.13, Recovery = 0.17, Reach = 5, Width = 5, Height = 6, Stun = 0.22, Knockback = 9, Lift = 0 },
			Cross = { Damage = 8, Windup = 0.11, Active = 0.13, Recovery = 0.18, Reach = 5.5, Width = 5, Height = 6, Stun = 0.25, Knockback = 10, Lift = 0 },
			Kick = { Damage = 10, Windup = 0.15, Active = 0.15, Recovery = 0.24, Reach = 6, Width = 6, Height = 6, Stun = 0.30, Knockback = 19, Lift = 3 },
			Heavy = { Damage = 16, Windup = 0.28, Active = 0.16, Recovery = 0.34, Reach = 6.5, Width = 6, Height = 7, Stun = 0.42, Knockback = 30, Lift = 6 },
			RisingHeavy = { Damage = 13, Windup = 0.23, Active = 0.17, Recovery = 0.35, Reach = 6, Width = 6, Height = 9, Stun = 0.45, Knockback = 16, Lift = 23 },
			Breaker = { Damage = 18, Windup = 0.25, Active = 0.16, Recovery = 0.38, Reach = 7, Width = 6, Height = 7, Stun = 0.48, Knockback = 37, Lift = 5 },
			AirLight = { Damage = 6, Windup = 0.13, Active = 0.14, Recovery = 0.26, Reach = 5, Width = 5, Height = 8, Stun = 0.22, Knockback = 11, Lift = 2 },
			AirHeavy = { Damage = 12, Windup = 0.27, Active = 0.16, Recovery = 0.38, Reach = 6, Width = 6, Height = 9, Stun = 0.34, Knockback = 24, Lift = -8 },
		},
	},
	Movement = {
		WalkSpeed = 20, SprintSpeed = 30, JumpPower = 48,
		DashSpeed = 72, DashDuration = 0.18, DashCooldown = 0.9,
		AirDashMultiplier = 0.75, MaxAirDashes = 1,
		AirAcceleration = 34, MaxAirSpeed = 24,
	},
	Combat = {
		InputBuffer = 0.18,
		RequestsPerSecond = 18, RequestBurst = 24,
		MaxHitTravel = 14, -- Cancel an attack that has moved implausibly far since windup.
		TravelSlack = 7, -- Latency tolerance for the basic server travel audit.
		AuditInterval = 0.15,
		MaxTargetDistance = 12,
	},
	Camera = {
		LockRange = 90, FieldOfView = 65, Padding = 8, Height = 8,
		MinDistance = 18, MaxDistance = 120, Smoothness = 10,
	},
	Arena = { Size = 120, RespawnSeconds = 3, DummyResetSeconds = 3 },
}

-- Only one fighter ships. New definitions can choose their own combat data and
-- movement profile; the server selects this from its own model's FighterId.
local fighters: { [string]: any } = {
	TestFighter = { Combat = Config.Fighter, Movement = Config.Movement },
}
Config.Fighters = fighters

return Config
