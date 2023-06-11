local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local StateManager = require(ReplicatedStorage.Client.State)
local IslandsConfig = require(ReplicatedStorage.Config.Islands)
local Remotes = ReplicatedStorage.Remotes

local Gui = PlayerGui:WaitForChild("PurchaseIsland")
local Frame = Gui.Frame

local Price = Frame.Price
local Rank = Frame.Rank
local Exit = Frame.Exit
local Purchase = Frame.Purchase

local Price_Text = "Amount"
local Rank_Text = "Need Amount"

local PurchaseIsland = {}

PurchaseIsland.Island = nil

function PurchaseIsland.DisplayGui(island: string)
	local islandInfo = IslandsConfig.Config[island]
	local price = islandInfo.Price
	local rank = islandInfo.Rank
	
	Price.Text = Price_Text:gsub("Amount", FormatNumber.FormatCompact(price))
	Rank.Text = Rank_Text:gsub("Amount", rank)
	Gui.Enabled = true
	PurchaseIsland.Island = island
end

Exit.MouseButton1Click:Connect(function()
	Gui.Enabled = false
	PurchaseIsland.Island = false
end)

Purchase.MouseButton1Click:Connect(function()
	if PurchaseIsland.Island then
		Remotes.PurchaseIsland:FireServer(PurchaseIsland.Island)
	end
	Gui.Enabled = false
	PurchaseIsland.Island = false
end)

return PurchaseIsland
