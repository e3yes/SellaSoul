local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ServerStorage = game:GetService("ServerStorage")
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local skinConfig = require(configFolder:FindFirstChild("SkinConfig"))
local remotes = ReplicatedStorage.Remotes
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local skinGui = script.Parent:FindFirstChild("SkinShop")
local frame = skinGui.Frame
local container = frame.Container
local skinTemplate = script.TemplateSkin
local infoFrame = frame.InfoFrame

local infoStatsFrame = infoFrame.StatsFrame
local buyButton = infoFrame.BuyButton
local infoSkinName = infoFrame.SkinName
local itemName = skinTemplate.Holder.NameSkin
local infoMultiply = infoStatsFrame.Multiply
local infoPrice = buyButton.Price
local infoPriceImage = buyButton.Currency
local infoIconFrame = infoFrame.IconFrame
local infoSkinIcon = infoIconFrame.SkinIcon
local iconSkin = skinTemplate.Holder.IconSkin
local infoHealthText = infoStatsFrame.Health

local clickedItem
local currentSkinShop

local SkinShop = {}
SkinShop.__index = SkinShop

local function ChangeInfoFrame(enable: boolean)
	infoSkinName.Visible = true
	infoMultiply.Visible = true
	infoHealthText.Visible = true
	infoSkinIcon.Visible = true
	infoPrice.Visible = true
	infoPriceImage.Visible = true
end

local function refreshGUI(itemName: string)
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("TextButton") then
			if child.Name == itemName then
				child.Holder.Equipped.Visible = true
			else
				child.Holder.Equipped.Visible = false
			end
		end
	end
	
	
end

local function hasEquipped(itemName: string, skinshop: string)
	if skinshop == "Skin" and itemName == player.inventory.EquippedSkin.Value then
		return true
	else
		return false
	end
end

local function ownsItem(itemName: string, skinshop: string)
	local directory = if skinshop == "Skin" then "OwnedSkins" else "OwnedSkins"


	return player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(itemName).Value
end


function SkinShop.Buy()
	local result = remotes.Shop.SkinShopBuy:InvokeServer(clickedItem.Name, currentSkinShop)
	print(result)

	if result == "Not enough souls" then
		print("no souls bro")
	elseif result == "Equipped" or result == "Purchased" then
		buyButton.BackgroundColor3 = Color3.fromRGB(209, 0, 0)
		infoPrice.Text = "Unequip"
		refreshGUI(clickedItem.Name)
		SkinShop.new(currentSkinShop)
	elseif result == "Unequipped" then
		buyButton.BackgroundColor3 = Color3.fromRGB(40, 209, 21)
		infoPrice.Text = "Equip"
		refreshGUI(clickedItem.Name)
	end
end

function SkinShop:Click()
	ChangeInfoFrame()
	clickedItem = self
	
	for _, image in ipairs(ReplicatedStorage.Images.Skins:GetChildren()) do
		if image.Name == self.Name then
			infoSkinIcon.Image = image.Image
		end
	end
	
	infoSkinName.Text = self.DisplayName
	infoMultiply.Text = "Essence Multiplier x"..self.Stat
	infoHealthText.Text = "Health: "..self.Health
	infoPrice.Text = FormatNumber.FormatCompact(self.Price)
	
	if ownsItem(self.Name, currentSkinShop) then
		if hasEquipped(self.Name, currentSkinShop) then
			buyButton.BackgroundColor3 = Color3.fromRGB(209, 0, 0)
			infoPrice.Text = "Unequip"
			infoPrice.Size = UDim2.new(0.9, 0,0.7, 0)
			infoPrice.Position = UDim2.new(0.5, 0,0.5, 0)
			infoPriceImage.Visible = false
		else
			buyButton.BackgroundColor3 = Color3.fromRGB(40, 209, 21)
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

function SkinShop.new(skinshop: string)
	clearContainer()
	currentSkinShop = skinshop

	for _, toolTable in ipairs(skinConfig) do
		local object = setmetatable({}, SkinShop)
		object.Name = toolTable.ID
		object.DisplayName = toolTable.Name
		object.Stat = toolTable.Stat
		object.Health = toolTable.Health
		object.Price = toolTable.Price

		local clone = skinTemplate:Clone()
		clone.Name = toolTable.ID
		local holder = clone.Holder
		clone.Parent = container

		
		for _, image in ipairs(ReplicatedStorage.Images.Skins:GetChildren()) do
			if image.Name == object.Name then
				holder.IconSkin.Image = image.Image
			end
		end
		clone.LayoutOrder = toolTable.Order
		holder.NameSkin.Text = object.DisplayName
		if skinshop == "Skin" and toolTable.ID == player.inventory.EquippedSkin.Value then
			holder.Equipped.Visible = true
		end

		local skinRequirement = toolTable.Requirement
		if skinRequirement then
			local isPreviousUnlocked = player.inventory.OwnedSkins[skinRequirement].Value
			if not isPreviousUnlocked then 
				holder.IconSkin.Visible = false
				holder.NameSkin.Visible = false
				holder.Equipped.Visible = false
				holder.Locked.Visible = true
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

return SkinShop


