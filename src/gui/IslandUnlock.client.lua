local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local Gui = PlayerGui:WaitForChild("IslandUnlock")
local Frame = Gui.Frame

local UnlockedLabel = Frame.Unlocked

local UNLOCK_TEXT = "You unlocked 'REPLACE Island'"

local function UnlockIsland(island: string)
	UnlockedLabel.Text = UNLOCK_TEXT:gsub("REPLACE", island)
	Gui.Enabled = true
	task.delay(3, function()
		Gui.Enabled = false
	end)
end

Remotes.UpdateIsland.OnClientEvent:Connect(function(island: string, unlocked: boolean)
	if not unlocked then return end
	UnlockIsland(island)
end)
