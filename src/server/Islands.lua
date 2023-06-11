local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ServerScriptService.ProfileService.Manager)
local IslandsConfig = require(ReplicatedStorage.Config.Islands)
local Remotes = ReplicatedStorage.Remotes

local Islands = {}

function Islands.UnlockIsland(player: Player, island: string, useCurrency: boolean)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No Profile Found" end
	
	local islandInfo = IslandsConfig.Config[island]
	if not islandInfo then return "No Island Found" end
	
	local isUnlocked = IslandsConfig.IsIslandUnlocked(profile.Data, island)
	if isUnlocked then return "Already Unlocked" end
	
	local isIslandRank = islandInfo.Rank
	if isIslandRank then
		local rank = player.inventory.OwnedRanks[isIslandRank].Value
		if not rank then return "Unlock Required Rank" end
	end
	
	local islandRequirement = islandInfo.Requirement
	if islandRequirement then
		local isPreviousUnlocked = IslandsConfig.IsIslandUnlocked(profile.Data, islandRequirement)
		if not isPreviousUnlocked then return "Unlock Previous Island" end
	end
	
	
	if useCurrency then
		local price = islandInfo.Price
		local soul = player.leaderstats.Soul.Value
		if price > soul then return "Cannot Afford" end
		player.leaderstats.Soul.Value = player.leaderstats.Soul.Value - price
	end

	profile.Data.Islands[island] = true
	Remotes.UpdateIsland:FireClient(player, island, true)
	return "Island Unlocked"
end

Remotes.PurchaseIsland.OnServerEvent:Connect(function(player, island)
	Islands.UnlockIsland(player, island, true)
end)

return Islands


