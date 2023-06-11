local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local toolConfig = require(configFolder:FindFirstChild("ToolConfig"))
local wingsConfig = require(configFolder:FindFirstChild("WingsConfig"))
local rankConfig = require(configFolder:FindFirstChild("RankConfig"))
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local RankConfig = require(ReplicatedStorage.Config.RankConfig)

local shopGui = script.Parent:FindFirstChild("WeaponShop")
local frame = shopGui.Frame
local container = frame.Container
local itemTemplate = script.Template
local infoFrame = frame.InfoFrame
local remotes = ReplicatedStorage:FindFirstChild("Remotes")

local infoImage = infoFrame.ImageWeapon
local infoStatsFrame = infoFrame.StatsFrame
local buyButton = infoFrame.BuyButton
local infoItemName = infoFrame.NameText
local infoStat = infoStatsFrame.Stat
local infoPrice= buyButton.Price
local infoPriceImage = buyButton.Currency
local infoClassName = infoFrame.ClassText

local clickedItem
local currentShop

local Shop = {}
Shop.__index = Shop


local function ChangeInfoFrame()
	infoItemName.Visible = true
	infoClassName.Visible = true
	infoStat.Visible = true
	infoPrice.Visible = true
	infoPriceImage.Visible = true
	infoImage.Visible = true
	buyButton.Visible = true
	infoStatsFrame.Strength.Visible = true
end

local function refreshGUI(itemName: string)
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("TextButton") then
			if child.Name == itemName then
				child.Holder.Equipped.Visible = true
				infoPriceImage.Visible = false
				infoPrice.Size = UDim2.new(0.9, 0,0.7, 0)
				infoPrice.Position = UDim2.new(0.5, 0,0.5, 0)
			else
				child.Holder.Equipped.Visible = false
				infoPriceImage.Visible = false
				infoPrice.Size = UDim2.new(0.9, 0,0.7, 0)
				infoPrice.Position = UDim2.new(0.5, 0,0.5, 0)
			end
		end
	end
end


local function hasEquipped(toolName: string, shop: string)
	if shop == "Essence" and toolName == player.inventory.EquippedTool.Value then
		return true
	else
		return false
	end
end


local function ownsItem(toolName: string, shop: string)
	local directory = if shop == "Essence" then "OwnedTools" else nil
	

	return player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(toolName).Value
end

local function bestItem()
	local list = if currentShop == "Essence" then toolConfig else nil
	local item
	for _, toolTable in ipairs(list) do
		if ownsItem(toolTable.ID, currentShop) then
			item = toolTable.ID
		else
			break
		end
	end
	return item
end

function Shop.Buy()
	local result = remotes.Shop.ShopBuy:InvokeServer(clickedItem.Name, currentShop)
	if result == "Not enough souls" then
		print("no souls bro")
	elseif result == "Equipped" or result == "Purchased" then
		buyButton.BackgroundColor3 = Color3.fromRGB(209, 125, 125)
		infoPrice.Text = "Unequip"
		refreshGUI(clickedItem.Name)
		Shop.new(currentShop)
	elseif result == "Unequipped" then
		buyButton.BackgroundColor3 = Color3.fromRGB(144, 209, 141)
		infoPrice.Text = "Equip"
		refreshGUI(clickedItem.Name)
	end
end

function Shop.BuyAll()
	local list = if currentShop == "Essence" then toolConfig else toolConfig
	for _, toolTable  in ipairs(list) do 
		if not ownsItem(toolTable.ID, currentShop) then
			if toolTable.Price <= player.leaderstats.Soul.Value then
				local toolRank = toolTable.Rank
				if toolRank then
					local isPreviousRankUnlocked = player.inventory.OwnedRanks[toolRank].Value
					if not isPreviousRankUnlocked then return end
				end
				local result = remotes.Shop.ShopBuy:InvokeServer(toolTable.ID, currentShop)
				if result == "Purchased" then
					Shop.new(currentShop)
					refreshGUI(toolTable.ID)
				end
			else
				break
			end
		end
	end
	local bestItem = bestItem()
	remotes.EquipItem:FireServer(bestItem, currentShop)
	refreshGUI(bestItem)
end

function Shop:Click()
	ChangeInfoFrame()
	
	clickedItem = self
	
	for _, image in ipairs(ReplicatedStorage.Images.Weapons:GetChildren()) do
		if image.Name == self.Name then
			infoImage.Image = image.Image
		end
	end
	
	infoItemName.Text = self.DisplayName
	infoStat.Text = FormatNumber.FormatCompact(self.Stat).." Essence"
	infoPrice.Text = FormatNumber.FormatCompact(self.Price)
	infoStatsFrame.Strength.Text = FormatNumber.FormatCompact(self.Strength).." Strength"
	infoClassName.Text = self.Class
	infoClassName.TextStrokeTransparency = 0
	infoClassName.TextColor3 = if self.Class == "Magic" then Color3.new(1, 0.67451, 0.996078) elseif self.Class == "HellMagic" then Color3.new(1, 0.52549, 0.52549) elseif self.Class == "Void" then Color3.new(0.152941, 0.105882, 0.152941) elseif self.Class == "Heaven" then Color3.new(1, 1, 1) else Color3.new(0.764706, 1, 0.72549)

	
	if ownsItem(self.Name, currentShop) then
		if hasEquipped(self.Name, currentShop) then
			buyButton.BackgroundColor3 = Color3.fromRGB(209, 125, 125)
			infoPrice.Text = "Unequip"
			infoPrice.Size = UDim2.new(0.9, 0,0.7, 0)
			infoPrice.Position = UDim2.new(0.5, 0,0.5, 0)
			infoPriceImage.Visible = false
		else
			buyButton.BackgroundColor3 = Color3.fromRGB(144, 209, 141)
			infoPrice.Text = "Equip"
			infoPrice.Size = UDim2.new(0.9, 0,0.7, 0)
			infoPrice.Position = UDim2.new(0.5, 0,0.5, 0)
			infoPriceImage.Visible = false
		end
	else
		buyButton.BackgroundColor3 = Color3.fromRGB(40, 209, 21)
		infoPrice.Text = FormatNumber.FormatCompact(self.Price)
		infoPrice.Size = UDim2.new(0.63, 0,0.7, 0)
		infoPrice.Position = UDim2.new(0.6, 0,0.5, 0)
		infoPriceImage.Visible = true
	end
end

local function clearContainer()
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

function Shop.new(shop: string)
	clearContainer()
	currentShop = shop
	local list = if shop == "Essence" then toolConfig else toolConfig
	
	for _, toolTable in ipairs(list) do
		local object = setmetatable({}, Shop)
		object.Name = toolTable.ID
		object.DisplayName = toolTable.Name
		object.Stat = toolTable.Stat
		object.Price = toolTable.Price
		object.Strength = toolTable.Strength
		object.Class = toolTable.Class
		
		local clone = itemTemplate:Clone()
		clone.Name = toolTable.ID
		local holder = clone.Holder
		clone.Parent = container
		
		
		for _, image in ipairs(ReplicatedStorage.Images.Weapons:GetChildren()) do
			if image.Name == object.Name then
				holder.ImageWeapon.Image = image.Image
			end
		end
		
		holder.Class.Image = "rbxassetid://"..if object.Class == "Magic" then "13266188797" elseif object.Class == "HellMagic" then "13259563340" elseif object.Class == "Void" then "13265345320" elseif object.Class == "Heaven" then "13266228693" else "13266234066"
			
		if object.Class == "Magic" then
			holder.Class.BackgroundColor3 = Color3.new(1, 0.670588, 1)
		elseif object.Class == "HellMagic" then
			holder.Class.BackgroundColor3 = Color3.new(0.4, 0.211765, 0.211765)
		elseif object.Class == "Void" then
			holder.Class.BackgroundColor3 = Color3.new(0.505882, 0.360784, 0.541176)
		elseif object.Class == "Heaven" then
			holder.Class.BackgroundColor3 = Color3.new(1, 1, 1)
		else
			holder.Class.BackgroundColor3 = Color3.new(0.690196, 1, 0.741176)
		end
		clone.LayoutOrder = toolTable.Order
		holder.ItemName.Text = object.DisplayName
		if shop == "Essence" and toolTable.ID == player.inventory.EquippedTool.Value then
			holder.Equipped.Visible = true
		end

		local toolRequirement = toolTable.Requirement
		local toolRank = toolTable.Rank
		
		if toolRank and toolRequirement then
			local isPreviousRankUnlocked = player.inventory.OwnedRanks[toolRank].Value
			local isPreviousUnlocked = player.inventory.OwnedTools[toolRequirement].Value
			if not isPreviousRankUnlocked and not isPreviousUnlocked then
				holder.ImageWeapon.Visible = false
				holder.ItemName.Visible = false
				holder.Equipped.Visible = false
				holder.Class.Visible = false
				holder.Locked.Visible = true
				holder.IslandUnlock.Visible = if not isPreviousRankUnlocked then true else false
				holder.IslandUnlock.Text = "Unlock "..toolRank.." Rank"
				object.TemplateButton = clone
			elseif not isPreviousRankUnlocked or not isPreviousUnlocked then
				holder.ImageWeapon.Visible = false
				holder.ItemName.Visible = false
				holder.Equipped.Visible = false
				holder.Class.Visible = false
				holder.Locked.Visible = true
				holder.IslandUnlock.Visible = if not isPreviousRankUnlocked then true else false
				holder.IslandUnlock.Text = "Unlock "..toolRank.." Rank"
				object.TemplateButton = clone
			else
				object.TemplateButton = clone
				object.TemplateButton.MouseButton1Click:Connect(function()
					object:Click()

				end)
			end
		elseif toolRank then
			local isPreviousRankUnlocked = player.inventory.OwnedRanks[toolRank].Value
			if not isPreviousRankUnlocked then
				holder.ImageWeapon.Visible = false
				holder.ItemName.Visible = false
				holder.Equipped.Visible = false
				holder.Class.Visible = false
				holder.Locked.Visible = true
				holder.IslandUnlock.Visible = if not isPreviousRankUnlocked then true else false
				holder.IslandUnlock.Text = "Unlock "..toolRank.." Rank"
				object.TemplateButton = clone
			else
				object.TemplateButton = clone
				object.TemplateButton.MouseButton1Click:Connect(function()
					object:Click()

				end)
			end
		else
			object.TemplateButton = clone
			object.TemplateButton.MouseButton1Click:Connect(function()
				object:Click()

			end)
		end
		
	end
end

return Shop
