local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local toolConfig = require(configFolder:FindFirstChild("ToolConfig"))
local rankConfig = require(configFolder:FindFirstChild("RankConfig"))
local wingsConfig = require(configFolder:FindFirstChild("WingsConfig"))
local ServerScriptService = game:GetService("ServerScriptService")
local Manager = require(ServerScriptService.Manager)
local ServerStorage = game:GetService("ServerStorage")



local function getItem(itemName: string, shop: string)
	local list = if shop == "Essence" then toolConfig else toolConfig
	
	for _, toolTable in ipairs(list) do
		if itemName == toolTable.ID then
			return toolTable.ID, toolTable
		end
	end
end

local function hasEquipped(player: Player, toolName: string, shop: string)
	if shop == "Essence" and toolName == player.inventory.EquippedTool.Value then
		return true
	else
		return false
	end
end

local function giveTool(player: Player)
	local debounce = false
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

local function unequip(player: Player, shop: string)
	if shop == "Essence" then
		player.inventory.EquippedTool.Value = "1947Sword"
	end
	
	if shop == "Essence" then 
		giveTool(player)
	end
	
end


local function equip(player: Player, toolName: string, shop: string)
	if shop == "Essence" then
		player.inventory.EquippedTool.Value = toolName
	end
	
	if shop == "Essence" then 
		giveTool(player)
	end

end

local function ownsItem(player: Player, toolName: string, shop: string)
	local directory = if shop == "Essence" then "OwnedTools" else "OwnedTools"

	return player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value
end


local function purchase(player: Player, toolName: string, toolTable: table, shop: string)

	local directory = if shop == "Essence" then "OwnedTools" else "OwnedTools"

	player.leaderstats.Soul.Value -= toolTable.Price
	player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value = true

end

Remotes.Shop.ShopBuy.OnServerInvoke = function(player: Player, itemName: string, shop: string)
	local toolName, toolTable = getItem(itemName, shop)
	
	if toolName and toolTable then
		if ownsItem(player, toolName, shop) then
			if hasEquipped(player, toolName, shop) then
				if toolName ~= "1947Sword" then
					unequip(player, shop)
					return "Unequipped"
				end
			else
				equip(player, toolName, shop)
				return "Equipped"
			end
		elseif player.leaderstats.Soul.Value >= toolTable.Price then
			purchase(player, toolName, toolTable, shop)
			equip(player, toolName, shop)
			return "Purchased"
		else
			return "Not enough souls"
			
		end
		
	end
	return true	
end


Remotes.EquipItem.OnServerEvent:Connect(function(player: Player, itemName: string, itemType: string)
	if ownsItem(player, itemName, itemType) then
		equip(player, itemName, itemType)
	end
end)
