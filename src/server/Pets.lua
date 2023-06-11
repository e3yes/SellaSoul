local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local PetsConfig = require(ReplicatedStorage.Config.Pets)
local PlayerData = require(ServerScriptService.ProfileService.Manager)

local Remotes = ReplicatedStorage.Remotes.Pets

local Pets = {}

function Pets.GivePet(player: Player, pet: PetsConfig.PetInstance)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No Profile Found" end
	
	local storedPets = PetsConfig.GetTotalStoredPets(profile.Data)
	local maxStoredPets = PetsConfig.GetMaxStoredPets(profile.Data)
	if storedPets + 1 > maxStoredPets then return "Cannot hold more Pets!" end
	profile.Data.Pets[pet.UUID] = pet
	Remotes.GivePet:FireClient(player, pet)
	return "Pet Given!"
end

function Pets.DeletePet(player: Player, uuid: string)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No Profile Found" end
	
	local pet: PetsConfig.PetInstance = profile.Data.Pets[uuid]
	if not pet then return "No Pet Found!" end
	if pet.Equipped then
		return Pets.UnequipPet(player, uuid)
	end
	
	profile.Data.Pets[uuid] = nil
	Remotes.DeletePet:FireClient(player, uuid)
end

function Pets.DeletePets(player: Player, uuids: {string})
	for _, uuid in uuids do
		Pets.DeletePet(player, uuid)
	end
end


function Pets.EquipPet(player: Player, uuid: string)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No Profile Found" end

	local pet: PetsConfig.PetInstance = profile.Data.Pets[uuid]
	if not pet then return "No Pet Found!" end

	if pet.Equipped then
		return Pets.UnequipPet(player, uuid)
	end
	
	local equippedPets = #PetsConfig.GetEquippedPets(profile.Data)
	local maxEquippedPets = PetsConfig.GetMaxEquippedPets(profile.Data)
	if equippedPets + 1 > maxEquippedPets then return "Cannot equip more Pets!" end
	pet.Equipped = true
	Remotes.EquipPet:FireClient(player, uuid)
	for _, loopPlayer in Players:GetPlayers() do
		if player == loopPlayer then continue end
		Remotes.ReplicateEquipPet:FireClient(loopPlayer, player, pet)
	end
end

function Pets.EquipBestPets(player: Player)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No Profile Found" end
	
	local pets = {}
	for uuid, pet: PetsConfig.PetInstance in profile.Data.Pets do
		local petInfo = {
			UUID = pet.UUID,
			Soul = PetsConfig.GetPerMultiplier(pet)
		}
		table.insert(pets, petInfo)
	end
	
	table.sort(pets, function(a, b)
		return a.Soul > b.Soul
	end)
	
	Pets.UnequipAllPets(player)
	
	local maxEquippedPets = PetsConfig.GetMaxEquippedPets(profile.Data)
	local total = if #pets < maxEquippedPets then #pets else maxEquippedPets
	for i = 1, total, 1 do
		local uuid = pets[i].UUID
		Pets.EquipPet(player, uuid)
	end
end

function Pets.UnequipPet(player: Player, uuid: string)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No Profile Found" end

	local pet: PetsConfig.PetInstance = profile.Data.Pets[uuid]
	if not pet then return "No Pet Found!" end

	if not pet.Equipped then
		return Pets.EquipPet(player, uuid)
	end
	
	pet.Equipped = false
	Remotes.UnequipPet:FireClient(player, uuid)
	for _, loopPlayer in Players:GetPlayers() do
		if player == loopPlayer then continue end
		Remotes.ReplicateUnequipPet:FireClient(loopPlayer, player, uuid)
	end
end

function Pets.UnequipAllPets(player: Player)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No Profile Found" end
	
	local equippedPets = PetsConfig.GetEquippedPets(profile.Data)
	for _, pet in equippedPets do
		Pets.UnequipPet(player, pet.UUID)
	end
end




function Pets.CreatePet(pet: string, rarity: string?): PetsConfig.PetInstance
	return {
		UUID = HttpService:GenerateGUID(false),
		Name = pet,
		Model = pet,
		Rarity = if rarity then rarity else "Common",
		
		Level = 0,
		Experience = 0,
		Equipped = false
	}
end

function Pets.GivePetXP(player: Player)
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	local equippedPets = PetsConfig.GetEquippedPets(profile.Data)
	for uuid, pet in equippedPets do
		local petConfig = PetsConfig.GetConfig(pet)
		local maxLevel = petConfig.MaxLevel
		local level = pet.Level
		
		if level == maxLevel then continue end
		
		pet.Experience += PetsConfig.XPPerClick
		
		local nextLevelXPRequirement = PetsConfig.GetPetXPRequirement(pet)
		if pet.Experience >= nextLevelXPRequirement then
			pet.Experience = 0
			pet.Level += 1
			Remotes.UpdatePetLevel:FireClient(player, pet.UUID, pet.Level)
		end
		Remotes.UpdatePetXp:FireClient(player, pet.UUID, pet.Experience)
	end
end

function Pets.GetEquippedPets()
	local allEquippedPets = {}
	
	for _, player in Players:GetPlayers() do
		allEquippedPets[player.UserId] = {}
		
		local profile = PlayerData.Profiles[player]
		if not profile then return end
		
		local equippedPets = PetsConfig.GetEquippedPets(profile.Data)
		for _, pet in equippedPets do
			allEquippedPets[player.UserId][pet.UUID] = pet
		end
	end
	
	return allEquippedPets
end

function Pets.UpgradePet(player: Player, uuid: string)
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	local pet: PetsConfig.PetInstance = profile.Data.Pets[uuid]
	if not pet then return end
	
	local canUpgrade = PetsConfig.CanUpgradePet(pet, profile.Data)
	if not canUpgrade then return end
	
	local amountToUpgrade = PetsConfig.GetNextUpgradeCost(pet)
	local duplicatePets = PetsConfig.GetDuplicatePets(pet, profile.Data)
	
	local amountDeleted = 0
	for _, petInstance in duplicatePets do
		if petInstance.UUID == uuid then continue end
		if amountDeleted == amountToUpgrade then break end

		
		Pets.UnequipAllPets(player)
		Pets.DeletePet(player, petInstance.UUID)
		
		amountDeleted += 1
	end
	
	local nextUpgrade = PetsConfig.GetNextUpgrade(pet)
	
	pet[nextUpgrade] = true
	Remotes.UpgradePet:FireClient(player, uuid, nextUpgrade)
end

Remotes.DeletePets.OnServerEvent:Connect(Pets.DeletePets)
Remotes.DeletePet.OnServerEvent:Connect(Pets.DeletePet)
Remotes.EquipPet.OnServerEvent:Connect(Pets.EquipPet)
Remotes.EquipBestPets.OnServerEvent:Connect(Pets.EquipBestPets)
Remotes.UnequipAllPets.OnServerEvent:Connect(Pets.UnequipAllPets)
Remotes.UnequipPet.OnServerEvent:Connect(Pets.UnequipPet)
Remotes.UpgradePet.OnServerEvent:Connect(Pets.UpgradePet)

Remotes.GetEquippedPets.OnServerInvoke = Pets.GetEquippedPets

PlayerData.ProfileLoaded.Event:Connect(function(player: Player, data)
	local equippedPets = PetsConfig.GetEquippedPets(data)
	for uuid, pet in equippedPets do
		for _, loopPlayer in Players:GetPlayers() do
			if player == loopPlayer then continue end
			Remotes.ReplicateUnequipPet:FireClient(loopPlayer, player, uuid)
		end
	end
end)

return Pets
