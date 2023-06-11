local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local wingsConfig = require(configFolder:FindFirstChild("WingsConfig"))
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Utils = require(ServerScriptService.Utils.Utils)

local function hasEquipped(player: Player, toolName: string, shop: string) --Щас Надето
	if shop == "Wings" and toolName == player.inventory.EquippedWings.Value then
		return true
	else
		return false
	end
end


local function unequip(player: Player, shop: string)	
	if shop == "Wings" then
		player.inventory.EquippedWings.Value = "Nothing"
	end
	if shop == "Wings" then
		Utils.equipWings(player)
	end
end

local function equip(player: Player, toolName: string, shop: string)
	if shop == "Wings" then
		player.inventory.EquippedWings.Value = toolName
	end
	
	if shop == "Wings" then
		Utils.equipWings(player)
	end
end

local function ownsItem(player: Player, toolName: string, shop: string)  --Имеющиеся ранги
	local directory = if shop == "Wings" then "OwnedWings" else "OwnedWings"
	
	return player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value
end



local function purchase(player: Player, toolName: string, toolTable: table, shop: string)
	local directory = if shop == "Wings" then "OwnedWings" else "OwnedWings"
	player.leaderstats.Soul.Value -= toolTable.Price
	player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value = true

end

Remotes.Shop.WingsShopBuy.OnServerInvoke = function(player: Player, itemName: string, shop: string)
	local toolName, toolTable = Utils.getItem(itemName, shop)
	
	if toolName and toolTable then
		if ownsItem(player, toolName, shop) then
			if hasEquipped(player, toolName, shop) then
				if toolName ~= "Nothing" then
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


Remotes.EquipWings.OnServerEvent:Connect(function(player: Player, itemName: string, itemType: string)
	if ownsItem(player, itemName, itemType) then
		equip(player, itemName, itemType)
	end
end)
