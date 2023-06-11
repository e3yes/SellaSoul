local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local StateManager = require(ReplicatedStorage.Client.State)
local IslandsConfig = require(ReplicatedStorage.Config.Islands)
local Remotes = ReplicatedStorage.Remotes

local Gui = PlayerGui:WaitForChild("Portals")
local Template = Gui.Template

local Price_Text = "Amount ☠"
local Rank_Text = "Need Amount"

local function GeneratePortal(island: string)
	local clone = Template:Clone()
	clone.Parent = Gui
	clone.Name = island
	clone.Adornee = Workspace.Portals[island].Info
	
end

local function UpdatePortals()
	for _, portalGui in Gui:GetChildren() do
		if portalGui.Name == "Template" then continue end
		
		local islandInfo = IslandsConfig.Config[portalGui.Name]
		local isUnlocked = IslandsConfig.IsIslandUnlocked(StateManager.GetData(), portalGui.Name)
		
		portalGui.Enabled = true
		portalGui.Price.Text = Price_Text:gsub("Amount", FormatNumber.FormatCompact(islandInfo.Price))
		portalGui.Rank.Text = Rank_Text:gsub("Amount", islandInfo.Rank)
		portalGui.Previous.Text = "Unlock Previous Island"
		
		if islandInfo.Requirement then
			local isRequirementUnlocked = IslandsConfig.IsIslandUnlocked(StateManager.GetData(), islandInfo.Requirement)
			if isRequirementUnlocked then
				portalGui.Previous.Text = "Buy Island"
			end
		else
			portalGui.Previous.Text = "Buy Island"
		end
		
		if isUnlocked then
			portalGui.Enabled = false
		end
	end
end

for island, props in IslandsConfig.Config do
	GeneratePortal(island)	
end

UpdatePortals()

Remotes.UpdateIsland.OnClientEvent:Connect(function()
	task.delay(0, UpdatePortals)
end)