--!strict
local Players = game:GetService("Players")
-- Prevent an automatic avatar spawn while the prototype's world initializes.
Players.CharacterAutoLoads = false

local Combat = require(script.Parent.CombatService)
local World = require(script.Parent.World)
Combat.start()
World.start(Combat.register)
