local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local skinConfig = require(configFolder:FindFirstChild("SkinConfig"))
local ServerScriptService = game:GetService("ServerScriptService")
--local Manager = require(ServerScriptService.Manager)
local ServerStorage = game:GetService("ServerStorage")
local Utils = require(ServerScriptService.Utils.Utils)
local Players = game:GetService("Players")
local skinModels = ReplicatedStorage.SkinModels

local function hasEquipped(player: Player, toolName: string, shop: string) --Щас Надето
	if shop == "Skin" and toolName == player.inventory.EquippedSkin.Value then
		return true
	else
		return false
	end
end


local function unequip(player: Player, shop: string)	
	if shop == "Skin" then
		player.inventory.EquippedSkin.Value = "Soulless"
	end
	if shop == "Skin" then
		Utils.equipSkin(player)
	end
end

local function equip(player: Player, toolName: string, shop: string)
	if shop == "Skin" then
		player.inventory.EquippedSkin.Value = toolName
	end
	
	if shop == "Skin" then
		Utils.equipSkin(player)
	end
end

local function ownsItem(player: Player, toolName: string, shop: string)  --Имеющиеся ранги
	
	return player:FindFirstChild("inventory"):FindFirstChild("OwnedSkins"):FindFirstChild(toolName).Value
end



local function purchase(player: Player, toolName: string, toolTable: table, shop: string)
	local directory = if shop == "Skin" then "OwnedSkins" else "OwnedSkins"
	player.leaderstats.Soul.Value -= toolTable.Price
	player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value = true

end

Remotes.Shop.SkinShopBuy.OnServerInvoke = function(player: Player, itemName: string, shop: string)
	local toolName, toolTable = Utils.getItem(itemName, shop)
	
	if toolName and toolTable then
		if ownsItem(player, toolName, shop) then
			if hasEquipped(player, toolName, shop) then
				if toolName ~= "Soulless" then
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


Remotes.EquipSkin.OnServerEvent:Connect(function(player: Player, itemName: string, itemType: string)
	if ownsItem(player, itemName, itemType) then
		equip(player, itemName, itemType)
	end
end)
