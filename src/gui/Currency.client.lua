local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui

local Remotes = ReplicatedStorage.Remotes

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local Gui = PlayerGui:WaitForChild("Left")
local Frame = Gui.Frame.Currency

local Essence = Frame.Essence.Amount
local BuyEssence = Frame.Essence.Buy
local BuySoul = Frame.Soul.Buy
local Soul = Frame.Soul.Amount
local Strength = Frame.Strength.Amount

local function UpdateCurrency(labels: "Essence" | "Soul" | "Strength", amount: number)
	amount = FormatNumber.FormatCompact(amount, ".#")
	if labels == "Essence" then
		Essence.Text = amount
	elseif labels == "Soul" then
		Soul.Text = amount
	elseif labels == "Strength" then
		Strength.Text = amount
	end
end

repeat wait(1) until player.leaderstats

UpdateCurrency("Essence", player.leaderstats.Essence.Value)
UpdateCurrency("Soul", player.leaderstats.Soul.Value)
UpdateCurrency("Strength", player.leaderstats.Strength.Value)

player.leaderstats.Essence.Changed:Connect(function()
	UpdateCurrency("Essence", player.leaderstats.Essence.Value)
	end)
player.leaderstats.Soul.Changed:Connect(function()
	UpdateCurrency("Soul", player.leaderstats.Soul.Value)
end)

player.leaderstats.Strength.Changed:Connect(function()
	UpdateCurrency("Strength", player.leaderstats.Strength.Value)
end)