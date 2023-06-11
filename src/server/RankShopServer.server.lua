local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local rankConfig = require(configFolder:FindFirstChild("RankConfig"))
local ServerScriptService = game:GetService("ServerScriptService")
--local Manager = require(ServerScriptService.Manager)
local ServerStorage = game:GetService("ServerStorage")
local Utils = require(ServerScriptService.Utils.Utils)
local ShopServer = ServerScriptService.ShopServer


local function hasEquipped(player: Player, toolName: string, rankshop: string) --Щас Надето
	if rankshop == "Rank" and toolName == player.leaderstats.Rank.Value then
		return true
	else
		return false
	end
end


local function giveTool(player: Player)
	for _, child in ipairs(player.Backpack:GetChildren()) do
		child:Destroy()
	end

	local equippedTool = player.Character:FindFirstChildWhichIsA("Tool")
	if equippedTool then
		equippedTool:Destroy()
	end

	local tool = player.inventory.EquippedTool.Value
	local toolClone = ServerStorage:FindFirstChild("Tools"):FindFirstChild(tool):Clone()
	toolClone.Parent = player.Backpack
end

local function unequip(player: Player, rankshop: string)	
	if rankshop == "Rank" then
		player.inventory.EquippedRank.Value = "Newbie"
	elseif rankshop == "Essence" then 
		player.inventory.EquippedTool.Value = "1947Sword"
	elseif rankshop == "Wings" then
		player.inventory.EquippedWings.Value = "Nothing" 
	else
		player.inventory.EquippedSkin.Value = "Soulless" 
	end
	if rankshop == "Rank" then
		Utils.equipRank(player)
	end
	if rankshop == "Essence" then
		giveTool(player)
	end
	if rankshop == "Wings" then
		Utils.equipWings(player)
	end
	if rankshop == "Skin" then
		Utils.equipSkin(player)
	end
end

local function equip(player: Player, toolName: string, rankshop: string)
	if rankshop == "Rank" then
		player.inventory.EquippedRank.Value = toolName
		player.leaderstats.Rank.Value = toolName
	end
	
	if rankshop == "Rank" then
		Utils.equipRank(player)
	end
	if rankshop == "Skin" then
		Utils.equipSkin(player)
	end
end

local function ownsItem(player: Player, toolName: string, rankshop: string)  --Имеющиеся ранги
	local directory = if rankshop == "Rank" then "OwnedRanks" else "OwnedRanks"
	
	return player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value
end

local function rankBuyReset(player: Player)
	for _, child: BoolValue in ipairs(player.inventory.OwnedTools:GetChildren()) do
		if child.Name ~= "1947Sword" then
			child.Value = false
		end
	end
	for _, child: BoolValue in ipairs(player.inventory.OwnedWings:GetChildren()) do
		if child.Name ~= "Nothing" then
			child.Value = false
		end
	end
	for _, child: BoolValue in ipairs(player.inventory.OwnedSkins:GetChildren()) do
		if child.Name ~= "Soulless" then
			child.Value = false
		end
	end
	unequip(player, "Essence")
	unequip(player, "Wings")
	unequip(player, "Skin")
	player.leaderstats.Soul.Value = 0
	player.leaderstats.Essence.Value = 0
	player.leaderstats.Strength.Value = 0
end


local function purchase(player: Player, toolName: string, toolTable: table, rankshop: string)
	local directory = if rankshop == "Rank" then "OwnedRanks" else "OwnedRanks"
	player.leaderstats.Soul.Value -= toolTable.Price
	player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value = true

	
	if rankshop == "Rank" then
		rankBuyReset(player)
	end

end

Remotes.Shop.RankShopBuy.OnServerInvoke = function(player: Player, itemName: string, rankshop: string)
	local toolName, toolTable = Utils.getItem(itemName, rankshop)
	
	if toolName and toolTable then
		if ownsItem(player, toolName, rankshop) then
			if hasEquipped(player, toolName, rankshop) then
				if toolName ~= "Newbie" then
					unequip(player, rankshop)
					return "Unequipped"
				end
			else
				equip(player, toolName, rankshop)
				return "Equipped"
			end
		elseif player.leaderstats.Soul.Value >= toolTable.Price and player.leaderstats.Strength.Value >= toolTable.Strength then
			purchase(player, toolName, toolTable, rankshop)
			equip(player, toolName, rankshop)
			return "Purchased"
		else
			return "Not enough souls"
			
		end
		
	end
	return true	
end


Remotes.EquipRank.OnServerEvent:Connect(function(player: Player, itemName: string, itemType: string)
	if ownsItem(player, itemName, itemType) then
		equip(player, itemName, itemType)
	end
end)
