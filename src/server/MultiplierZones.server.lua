local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AddEvent = ReplicatedStorage.Remotes.Zones.AddMultiplier
local RemoveEvent = ReplicatedStorage.Remotes.Zones.RemoveMultiplier
local Players = game:GetService("Players")

local function AddMulti(player, PartName)
	print(player)
	print(PartName)
	if PartName == "Garmony" then
		player.locationInventory.Multiplier.Value = 2
	elseif PartName == "Rage" then
		player.locationInventory.Multiplier.Value = 5
	elseif PartName == "Peacefulness" then
		player.locationInventory.Multiplier.Value = 15
	end
	
end

local function RemoveMulti(player)
	player.locationInventory.Multiplier.Value = 1
end

Players.PlayerRemoving:Connect(function(player)
	player.locationInventory.Multiplier.Value = 1
end)

AddEvent.OnServerEvent:Connect(AddMulti)
RemoveEvent.OnServerEvent:Connect(RemoveMulti)
