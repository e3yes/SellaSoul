local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Template = require(ReplicatedStorage.PlayerData.Template)
local Manager = require(ServerScriptService.ProfileService.Manager)
local ProfileService = require(ServerScriptService.Libs.ProfileService)
local Utils = require(ServerScriptService.Utils.Utils)

local ProfileStore = ProfileService.GetProfileStore("Update1.0", Template)

local function LoadProfile(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId)
	if not profile then
		player:Kick("Data issue! Try again")
		return
	end
	
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		Manager.Profiles[player] = nil
		player:Kick("Data issue! Try again")
	end)
	
	if player:IsDescendantOf(Players) == true then
		Manager.Profiles[player] = profile
		Manager.ProfileLoaded:Fire(player, profile.Data)
	else
		profile:Release()
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(LoadProfile, player)
end

Players.PlayerAdded:Connect(LoadProfile)
Players.PlayerRemoving:Connect(function(player)
	local profile = Manager.Profiles[player]
	if profile then
		profile:Release()
	end
end)
