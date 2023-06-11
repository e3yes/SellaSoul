local ServerScriptService = game:GetService("ServerScriptService")
--local Manager = require(ServerScriptService.Manager)
local Stats = require(ServerScriptService.Utils.Stats)
local HttpService = game:GetService("HttpService")

local Rewards = {}

function Rewards.Essence(player: Player, amount: number, useMultiplier: boolean)
	useMultiplier = if useMultiplier ~= nil then useMultiplier else true

	local multiplier = if useMultiplier == true then Stats.EssenceMultiplier(player) else 1
	player.leaderstats.Essence.Value += amount * multiplier
	print(amount, multiplier, "Multiplier = ", amount*multiplier)
end


function Rewards.Soul(player: Player, amount: number, useMultiplier: boolean)
	useMultiplier = if useMultiplier ~= nil then useMultiplier else true

	local multiplier = if useMultiplier == true then Stats.SoulMultiplier(player) else 1
	player.leaderstats.Soul.Value += amount * multiplier
	print(amount, multiplier, amount*multiplier)
	
end

function Rewards.Strength(player: Player, amount: number, useMultiplier: boolean)
	useMultiplier = if useMultiplier ~= nil then useMultiplier else true

	local multiplier = if useMultiplier == true then Stats.StrengthMultiplier(player) else 1
	player.leaderstats.Strength.Value += amount * multiplier
end


return Rewards
