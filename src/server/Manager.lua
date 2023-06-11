local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Stats = require(ServerScriptService.Utils.Stats)
local Remotes = ReplicatedStorage.Remotes
local PlayerDataTemplate = require(ReplicatedStorage.PlayerData.Template)

local Manager = {}

function Manager.SellEssence(player: Player, amount: number, useMultiplier: boolean)
	useMultiplier = if useMultiplier ~= nil then useMultiplier else true
	local multiplier = if useMultiplier == true then Stats.SoulMultiplier(player) else 1
	player.leaderstats.Soul.Value += amount * multiplier
end



return Manager