local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local wingsConfig = require(configFolder:FindFirstChild("WingsConfig"))
local remotes = ReplicatedStorage.Remotes
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local wingsGui = script.Parent:FindFirstChild("WingsShop")
local frame = wingsGui.Frame
local container = frame.Container
local wingsTemplate = script.TemplateWings
local infoFrame = frame.InfoFrame

local infoStatsFrame = infoFrame.StatsFrame
local buyButton = infoFrame.BuyButton
local infoWingsName = infoFrame.WingsName
local itemName = wingsTemplate.Holder.NameWings
local infoMultiply = infoStatsFrame.Multiply
local infoSpeed = infoStatsFrame.Speed
local infoPrice = buyButton.Price
local infoPriceImage = buyButton.Currency
local infoIconFrame = infoFrame.IconFrame
local infoWingsIcon = infoIconFrame.WingsIcon
local iconWings = wingsTemplate.Holder.IconWings

local clickedItem
local currentWingsShop

local WingsShop = {}
WingsShop.__index = WingsShop

local function ChangeInfoFrame(enable: boolean)
	infoWingsName.Visible = true
	infoMultiply.Visible = true
	infoSpeed.Visible = true
	infoWingsIcon.Visible = true
	infoPrice.Visible = true
	infoPriceImage.Visible = true
end

local function refreshGUI(itemName: string)
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("TextButton") then
			if child.Name == itemName then
				child.Holder.Equipped.Visible = true
				infoPrice.Size = UDim2.new(0.9, 0,0.7, 0)
				infoPrice.Position = UDim2.new(0.5, 0,0.5, 0)
				infoPriceImage.Visible = false
			else
				child.Holder.Equipped.Visible = false
				infoPrice.Size = UDim2.new(0.9, 0,0.7, 0)
				infoPrice.Position = UDim2.new(0.5, 0,0.5, 0)
				infoPriceImage.Visible = false
			end
		end
	end
	
	
end

local function hasEquipped(itemName: string, wingsshop: string)
	if wingsshop == "Wings" and itemName == player.inventory.EquippedWings.Value then
		return true
	else
		return false
	end
end

local function ownsItem(itemName: string, wingsshop: string)
	local directory = if wingsshop == "Wings" then "OwnedWings" else "OwnedWings"


	return player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(itemName).Value
end

function WingsShop.Buy()
	local result = remotes.Shop.WingsShopBuy:InvokeServer(clickedItem.Name, currentWingsShop)

	if result == "Not enough souls" then
		print("no souls bro")
	elseif result == "Equipped" or result == "Purchased" then
		buyButton.BackgroundColor3 = Color3.fromRGB(209, 0, 0)
		infoPrice.Text = "Unequip"
		refreshGUI(clickedItem.Name)
		WingsShop.new(currentWingsShop)
	elseif result == "Unequipped" then
		buyButton.BackgroundColor3 = Color3.fromRGB(40, 209, 21)
		infoPrice.Text = "Equip"
		refreshGUI(clickedItem.Name)
	end
end

function WingsShop:Click()
	ChangeInfoFrame()
	clickedItem = self

	
	for _, image in ipairs(ReplicatedStorage.Images.Wings:GetChildren()) do
		if image.Name == self.Name then
			infoWingsIcon.Image = image.Image
		end
	end
	
	infoWingsName.Text = self.Name
	infoMultiply.Text = "Souls Multiplier x"..self.Stat
	infoSpeed.Text = "Speed "..self.Speed
	
	infoPrice.Text = FormatNumber.FormatCompact(self.Price)
	
	if ownsItem(self.Name, currentWingsShop) then
		if hasEquipped(self.Name, currentWingsShop) then
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

function WingsShop.new(wingsshop: string)
	clearContainer()
	currentWingsShop = wingsshop

	for _, toolTable in ipairs(wingsConfig) do
		local object = setmetatable({}, WingsShop)
		object.Name = toolTable.ID
		object.DisplayName = toolTable.Name
		object.Stat = toolTable.Stat
		object.Price = toolTable.Price
		object.Speed = toolTable.Speed

		local clone = wingsTemplate:Clone()
		clone.Name = toolTable.ID
		local holder = clone.Holder
		clone.Parent = container


		
		for _, image in ipairs(ReplicatedStorage.Images.Wings:GetChildren()) do
			if image.Name == object.Name then
				holder.IconWings.Image = image.Image
			end
		end
		
		clone.LayoutOrder = toolTable.Order
		holder.NameWings.Text = object.DisplayName
		if wingsshop == "Wings" and toolTable.ID == player.inventory.EquippedWings.Value then
			holder.Equipped.Visible = true
		end

		local wingsRequirement = toolTable.Requirement
		if wingsRequirement then
			local isPreviousUnlocked = player.inventory.OwnedWings[wingsRequirement].Value
			if not isPreviousUnlocked then 
				holder.IconWings.Visible = false
				holder.NameWings.Visible = false
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

return WingsShop


