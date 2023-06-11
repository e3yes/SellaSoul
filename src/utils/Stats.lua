local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ToolConfig = require(ReplicatedStorage.Config.ToolConfig)
local RankConfig = require(ReplicatedStorage.Config.RankConfig)
local SkinConfig = require(ReplicatedStorage.Config.SkinConfig)
local WingsConfig = require(ReplicatedStorage.Config.WingsConfig)
local PetsConfig = require(ReplicatedStorage.Config.Pets)
local PlayerDataTemplate = require(ReplicatedStorage.PlayerData.Template)
local Manager = require(ServerScriptService.ProfileService.Manager)

local Stats = {}

local function getItemStat(name: string, type: string)
	local list = if type == "Essence" then ToolConfig elseif type == "Rank" then RankConfig elseif type == "Wings" then WingsConfig else SkinConfig
	for _, toolTable in ipairs(list) do
		if toolTable.ID == name then
			return toolTable.Stat
		end
	end
end


function Stats.EssenceMultiplier(player: Player)
	local profile = Manager.Profiles[player]
	if not profile then return end
	
	local total = 1
	local rank = Stats.Rank(player)
	local skin = Stats.Skin(player)
	total *= rank
	total *= skin
	
	local petMultiplier = PetsConfig.GetEquippedSoul(profile.Data)
	total *= petMultiplier
	
	return total
end

function Stats.Essence(player: Player)
	local total = 0
	local item = getItemStat(player.inventory.EquippedTool.Value, "Essence")
	total += item
	
	local multiplier = player.locationInventory.Multiplier.Value
	
	total *= multiplier
	
	local ownsGamepassx2 = player.gamepasses.x2_Essence.Value
	if ownsGamepassx2 then
		total *= 2
	end
	
	local ownsGamepassx10 = player.gamepasses.x10_Essence.Value
	if ownsGamepassx10 then
		total *= 10
	end
	return total
end

function Stats.SoulMultiplier(player: Player)
	local profile = Manager.Profiles[player]
	if not profile then return end
	
	local total = 1
	local rank = Stats.Rank(player)
	local wings = Stats.Wings(player)
	total *= rank
	total *= wings
	
	local petMultiplier = PetsConfig.GetEquippedSoul(profile.Data)
	total *= petMultiplier
	
	local ownsGamepassx2 = player.gamepasses.x2_Soul.Value
	if ownsGamepassx2 then
		total *= 2
	end
	return total
end

function Stats.StrengthMultiplier(player: Player)
	local profile = Manager.Profiles[player]
	if not profile then return end
	local total = 1
	local rank = Stats.Rank(player)
	total *= rank
	
	local petMultiplier = PetsConfig.GetEquippedSoul(profile.Data)
	total *= petMultiplier
	return total
end

function Stats.Soul(player: Player)
	local total = 0
	return total
end

function Stats.Strength(player: Player)
	local total = 0
	
	local multiplier = player.locationInventory.Multiplier.Value

	total *= multiplier
	
	local item = getItemStat(player.inventory.EquippedTool.Value, "Essence")
	total += item
	
	return total
end

function Stats.Rank(player: Player)
	return getItemStat(player.inventory.EquippedRank.Value, "Rank")
end

function Stats.Skin(player: Player)
	return getItemStat(player.inventory.EquippedSkin.Value, "Skin")
end

function Stats.Wings(player: Player)
	return getItemStat(player.inventory.EquippedWings.Value, "Wings")
end


return Stats
