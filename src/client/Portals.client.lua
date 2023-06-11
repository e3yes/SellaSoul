local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local StateManager = require(ReplicatedStorage.Client.State)
local IslandsConfig = require(ReplicatedStorage.Config.Islands)
local Remotes = ReplicatedStorage.Remotes

local PurchaseIsland = require(PlayerScripts:WaitForChild("Gui").PurchaseIsland)

local debounce = false

local function TeleportToIsland(island: string)
	local teleportPart = Workspace.Islands[island].Spawn
	local character = Player.Character
	if character then
		character:PivotTo(teleportPart.CFrame)
	end
end

local function RegisterPortalTouch()
	for _, portal in Workspace.Portals:GetChildren() do
		local touchPart: Part = portal.Portal
		touchPart.Touched:Connect(function(otherPart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)
			if not player or player ~= Player then return end
			if debounce then return end
			
			local isIslandUnlocked = IslandsConfig.IsIslandUnlocked(StateManager.GetData(), portal.Name)
			if isIslandUnlocked then
				TeleportToIsland(portal.Name)
			else
				local requirement = IslandsConfig.Config[portal.Name].Requirement
				if requirement then
					local isRequirementUnlocked = IslandsConfig.IsIslandUnlocked(StateManager.GetData(), requirement)
					if isRequirementUnlocked then
						PurchaseIsland.DisplayGui(portal.Name)
					end
				else
					PurchaseIsland.DisplayGui(portal.Name)
				end
			end
			
			debounce = true
			task.delay(0.5, function()
				debounce = false
			end)
		end)
	end
end

local function RegisterReturnPortalTouch()
	local spawnpart = Workspace.SpawnLocation
	for _, island in Workspace.Islands:GetChildren() do
		local portalPart: Part = island.Portal.Portal
		portalPart.Touched:Connect(function(otherPart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)
			if not player or player ~= Player then return end
			otherPart.Parent:PivotTo(spawnpart.CFrame)
		end)
	end
end

RegisterPortalTouch()
RegisterReturnPortalTouch()

