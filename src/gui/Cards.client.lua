local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local ViewportModel = require(ReplicatedStorage.Libs.ViewportModel)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local LeftGui = PlayerGui:WaitForChild("Left")
local OpenButton = LeftGui.Frame.Buttons.Cards

local Gui = PlayerGui:WaitForChild("Cards")
local Frame = Gui.Frame
local container = Frame.Container
local exit = Frame.Exit


local ViewPortFrame = container.ViewportFrame

local function UpdateInfo(player: Player)
	local model = ReplicatedStorage.SkinModels:WaitForChild("Soulless")
	ViewportModel.CleanViewport(ViewPortFrame)
	ViewportModel.GenerateViewport(ViewPortFrame, model:Clone(), CFrame.Angles(0, math.rad(180), 0))
	container.PlayerName.Text = player.Name
	container.Rank.Text = player.leaderstats.Rank.Value

	local essence = player.leaderstats.Essence.Value
	local soul = player.leaderstats.Soul.Value
	local strength = player.leaderstats.Strength.Value
	
	container.Timer.Text = "Time Played: "..Player.timeInventory.Times.Value.." Min"

	container.Strength.Text = "Strength: "..FormatNumber.FormatCompact(strength)
end

local function GenerateInfo(player: Player)
	local model = ReplicatedStorage.SkinModels:WaitForChild("Soulless")
	ViewportModel.GenerateViewport(ViewPortFrame, model:Clone(), CFrame.Angles(0, math.rad(180), 0))
	
	container.PlayerName.Text = player.Name
	container.Rank.Text = player.leaderstats.Rank.Value
	
	local essence = player.leaderstats.Essence.Value
	local soul = player.leaderstats.Soul.Value
	local strength = player.leaderstats.Strength.Value
	
	container.Timer.Text = "Time Played: "..Player.timeInventory.Times.Value.." Min"

	container.Strength.Text = "Strength: "..FormatNumber.FormatCompact(strength)
	
	
end


GenerateInfo(Player)

OpenButton.MouseButton1Click:Connect(function()
	Gui.Enabled = not Gui.Enabled
	SoundService.SfxButton:Play()
	UpdateInfo(Player)
end)


exit.MouseButton1Click:Connect(function()
	Gui.Enabled = false
	SoundService.SfxButton:Play()
end)

