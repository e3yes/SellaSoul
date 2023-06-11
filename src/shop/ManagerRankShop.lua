local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local configFolder = ReplicatedStorage:FindFirstChild("Config")
local rankConfig = require(configFolder:FindFirstChild("RankConfig"))
local remotes = ReplicatedStorage.Remotes
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local rankGui = script.Parent:FindFirstChild("RankShop")
local frame = rankGui.Frame
local container = frame.Container
local rankTemplate = script.TemplateRank
local infoFrame = frame.InfoFrame

local infoStatsFrame = infoFrame.StatsFrame
local buyButton = infoFrame.BuyButton
local infoItemName = infoFrame.RankName
local itemName = rankTemplate.Holder.RankName
local infoMultiply = infoStatsFrame.Multiply
local infoPrice = buyButton.Price
local infoPriceImage = buyButton.Currency
local infoIconFrame = infoFrame.IconFrame
local infoRankIcon = infoIconFrame.RankIcon


local iconRank = rankTemplate.Holder.IconRank
local locked = rankTemplate.Holder.Locked

local clickedItem
local currentRankShop

local RankShop = {}
RankShop.__index = RankShop

local function GetRankColor(rank: string)
	local color

	if rank == "Ninja" then
		color = Color3.new(0, 0.129412, 0.407843)
	elseif rank == "Sensei" then
		color = Color3.new(0, 1, 0.933333)
	elseif rank == "MasterSensei" then
		color = Color3.new(0.615686, 0, 1)
	elseif rank == "Demon" then
		color = Color3.new(0.603922, 0, 0)
	elseif rank == "CursedDemon" then
		color = Color3.new(0.1, 0, 0)
	elseif rank == "MadSpirit" then
		color = Color3.new(0, 0.517647, 1)
	elseif rank == "Lost" then
		color = Color3.new(0, 0, 0)
	elseif rank == "MysteriousCreature" then
		color = Color3.new(0.933333, 0, 1)
	elseif rank == "Absolute" then
		color = Color3.new(0.984314, 1, 0)
	elseif rank == "Godlike" then
		color = Color3.new(1, 1, 1)
	else 
		color = Color3.new(0, 1, 0.117647)
	end

	return color

end

local function GetRankTextColor(rank: string)
	local color

	if rank == "Ninja" then
		color = Color3.new(0, 0, 0)
	elseif rank == "Sensei" then
		color = Color3.new(0, 0, 0)
	elseif rank == "MasterSensei" then
		color = Color3.new(0, 0, 0)
	elseif rank == "Demon" then
		color = Color3.new(0, 0, 0)
	elseif rank == "CursedDemon" then
		color = Color3.new(1, 0, 0)
	elseif rank == "MadSpirit" then
		color = Color3.new(1, 1, 1)
	elseif rank == "Lost" then
		color = Color3.new(0, 0.0745098, 0.117647)
	elseif rank == "MysteriousCreature" then
		color = Color3.new(0, 0.184314, 1)
	elseif rank == "Absolute" then
		color = Color3.new(0, 0, 0)
	elseif rank == "Godlike" then
		color = Color3.new(0, 0, 0)
	else 
		color = Color3.new(0, 0, 0)
	end

	return color

end

local function ChangeInfoFrame(enable: boolean)
	infoItemName.Visible = true
	infoMultiply.Visible = true
	infoRankIcon.Visible = true
	infoPrice.Visible = true
	infoPriceImage.Visible = true
	infoStatsFrame.Strength.Visible = true
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

local function hasEquipped(itemName: string, rankshop: string)
	if rankshop == "Rank" and itemName == player.inventory.EquippedRank.Value then
		return true
	else
		return false
	end
end

local function ownsItem(itemName: string, rankshop: string)
	local directory = if rankshop == "Rank" then "OwnedRanks" else "OwnedRanks"


	return player:FindFirstChild("inventory"):FindFirstChild(directory):FindFirstChild(itemName).Value
end

function RankShop.Buy()
	local result = remotes.Shop.RankShopBuy:InvokeServer(clickedItem.Name, currentRankShop)

	if result == "Not enough souls" then
		print("no souls bro")
	elseif result == "Equipped" or result == "Purchased" then
		buyButton.BackgroundColor3 = Color3.fromRGB(209, 0, 0)
		infoPrice.Text = "Unequip"
		refreshGUI(clickedItem.Name)
		RankShop.new(currentRankShop)
	elseif result == "Unequipped" then
		buyButton.BackgroundColor3 = Color3.fromRGB(40, 209, 21)
		infoPrice.Text = "Equip"
		refreshGUI(clickedItem.Name)
	end
end

function RankShop:Click()
	ChangeInfoFrame()
	clickedItem = self
	
	for _, image in ipairs(ReplicatedStorage.Images.Ranks:GetChildren()) do
		if image.Name == self.Name then
			infoRankIcon.Image = image.Image
		end
	end
	infoItemName.Text = self.Name
	infoItemName.TextColor3 = GetRankColor(clickedItem.Name)
	infoItemName.TextStrokeColor3 = GetRankTextColor(clickedItem.Name)
	infoMultiply.Text = "Essence, Soul, Multiplier x"..self.Stat
	infoPrice.Text = FormatNumber.FormatCompact(self.Price)
	infoFrame.StatsFrame.Strength.Text = "Need Strength: "..FormatNumber.FormatCompact(self.Strength)
	
	if ownsItem(self.Name, currentRankShop) then
		if hasEquipped(self.Name, currentRankShop) then
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

function RankShop.new(rankshop: string)
	clearContainer()
	currentRankShop = rankshop
	local list = if rankshop == "Rank" then rankConfig else rankConfig

	for _, toolTable in ipairs(list) do
		local object = setmetatable({}, RankShop)
		object.Name = toolTable.ID
		object.DisplayName = toolTable.Name
		object.Stat = toolTable.Stat
		object.Price = toolTable.Price
		object.Strength = toolTable.Strength

		local clone = rankTemplate:Clone()
		clone.Name = toolTable.ID
		local holder = clone.Holder
		clone.Parent = container



		
		for _, image in ipairs(ReplicatedStorage.Images.Ranks:GetChildren()) do
			if image.Name == object.Name then
				holder.IconRank.Image= image.Image
			end
		end
		
		clone.LayoutOrder = toolTable.Order
		holder.RankName.Text = object.DisplayName
		holder.RankName.TextColor3 = GetRankColor(clone.Name)
		holder.RankName.TextStrokeColor3 = GetRankTextColor(clone.Name)
		if rankshop == "Rank" and toolTable.ID == player.inventory.EquippedRank.Value then
			holder.Equipped.Visible = true
		end

		local rankRequirement = toolTable.Requirement
		if rankRequirement then
			local isPreviousUnlocked = player.inventory.OwnedRanks[rankRequirement].Value
			if not isPreviousUnlocked then 
				holder.IconRank.Visible = false
				holder.RankName.Visible = false
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

return RankShop


