local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Template = require(ReplicatedStorage.PlayerData.Template)

local IsDataLoaded = false

local PlayerData: Template.PlayerData

local function LoadData()
	if IsDataLoaded then return end
	
	while not PlayerData do
		PlayerData = Remotes.GetAllData:InvokeServer()
		task.wait(1)
	end
	
	IsDataLoaded = true
end

LoadData()

local State = {}

function State.GetData(): Template.PlayerData
	while not IsDataLoaded do
		task.wait(0.5)
	end
	return PlayerData
end

Remotes.Pets.GivePet.OnClientEvent:Connect(function(petInstance)
	PlayerData.Pets[petInstance.UUID] = petInstance
end)

Remotes.Pets.DeletePet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid] = nil
end)

Remotes.Pets.EquipPet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid].Equipped = true
end)

Remotes.Pets.UnequipPet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid].Equipped = false
end)

Remotes.Pets.UpdatePetXp.OnClientEvent:Connect(function(uuid: string, xp: number)
	PlayerData.Pets[uuid].Experience = xp
end)

Remotes.Pets.UpdatePetLevel.OnClientEvent:Connect(function(uuid: string, level: number)
	PlayerData.Pets[uuid].Level = level
end)

Remotes.Pets.UpgradePet.OnClientEvent:Connect(function(uuid: string, upgrade: string)
	PlayerData.Pets[uuid][upgrade] = true
end)

Remotes.UpdateIsland.OnClientEvent:Connect(function(island: string, unlocked: boolean)
	PlayerData.Islands[island] = unlocked
end)

return State
