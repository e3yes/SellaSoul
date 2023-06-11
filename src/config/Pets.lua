local ReplicatedStorage = game:GetService("ReplicatedStorage")

export type PetUpgrade = "Golden" | "Blazing" | "Cursed" | "Cleanera"

local PlayerData = require(ReplicatedStorage.PlayerData.Template)

export type PetInstance = {
	UUID: string,
	Name: string,
	Model: string,
	Rarity: string,
	
	Level: number,
	Experience: number,
	
	Equipped: boolean,
	
	Golden: boolean,
	Blazing: boolean,
	Cursed: boolean,
	Cleanera: boolean
}

type PetConfig = {
	Essence: number,
	Soul: number,
	
	MaxLevel: number,
	MultiplierPerLevel: number?
	
}

local Config: { [string]: PetConfig } = {
	EmptyCrystal = {
		Essence = 2,
		Soul = 2,
		MaxLevel = 2,
		MultiplierPerLevel = 1
	},
	GrassCrystal = {
		Essence = 2.5,
		Soul = 2.5,
		MaxLevel = 2,
		MultiplierPerLevel = 1
	},
	RustyCrystal = {
		Essence = 2.9,
		Soul = 2.9,
		MaxLevel = 2,
		MultiplierPerLevel = 1
	},
	MetalCrystal = {
		Essence = 3.9,
		Soul = 3.9,
		MaxLevel = 3,
		MultiplierPerLevel = 1
	},
	LongSnowCrystal = {
		Essence = 4.5,
		Soul = 4.5,
		MaxLevel = 3,
		MultiplierPerLevel = 1.5
	},
	
	FoilCrystal = {
		Essence = 3,
		Soul = 3,
		MaxLevel = 2,
		MultiplierPerLevel = 1
	},
	GreenNeonCrystal = {
		Essence = 4,
		Soul = 4,
		MaxLevel = 2,
		MultiplierPerLevel = 1
	},
	YellowNeonCrystal = {
		Essence = 5,
		Soul = 5,
		MaxLevel = 2,
		MultiplierPerLevel = 1
	},
	DoubleGreenNeonCrystal = {
		Essence = 6,
		Soul = 6,
		MaxLevel = 3,
		MultiplierPerLevel = 1
	},
	TripplePinkNeonCrystal = {
		Essence = 7.3,
		Soul = 7.3,
		MaxLevel = 3,
		MultiplierPerLevel = 2
	},
	LightningCrystal = {
		Essence = 12,
		Soul = 12,
		MaxLevel = 4,
		MultiplierPerLevel = 2.5
	},
	
	HellCrystal = {
		Essence = 9,
		Soul = 9,
		MaxLevel = 2,
		MultiplierPerLevel = 1
	},
	TrippleHellCrystal = {
		Essence = 11,
		Soul = 11,
		MaxLevel = 3,
		MultiplierPerLevel = 1.5
	},
	HellSpirit = {
		Essence = 17,
		Soul = 17,
		MaxLevel = 4,
		MultiplierPerLevel = 2
	},
	Diavolo = {
		Essence = 25,
		Soul = 25,
		MaxLevel = 4,
		MultiplierPerLevel = 2
	},
	
	HeavenCrystal = {
		Essence = 40,
		Soul = 40,
		MaxLevel = 2,
		MultiplierPerLevel = 2
	},
	HeavenSpirit = {
		Essence = 75,
		Soul = 75,
		MaxLevel = 4,
		MultiplierPerLevel = 3
	},
	KeeperOfHeaven = {
		Essence = 777,
		Soul = 777,
		MaxLevel = 6,
		MultiplierPerLevel = 5
	},
	
}
	
local DEFAULT_MAX_STORED_PETS = 100
local DEFAULT_MAX_EQUIPPED_PETS = 3

local AMOUNT_TO_GOLDEN = 5
local AMOUNT_TO_BLAZING = 5
local AMOUNT_TO_CURSED = 4
local AMOUNT_TO_CLEANERA = 3


local Pets = {}

Pets.XPPerLevel = 120
Pets.XPPerClick = 1

Pets.Config = Config

function Pets.GetConfig(pet: PetInstance): PetConfig
	return Pets.Config[pet.Model]
end

function Pets.GetModel(pet: PetInstance): Model
	local model = ReplicatedStorage.PetsModels:FindFirstChild(pet.Model):Clone()
	
	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if not currentUpgrade then
		return model
	end
	
	for _, descendants in model:GetDescendants() do
		if descendants:IsA("MeshPart") then
			if currentUpgrade == "Cleanera" then
				descendants.Color = Color3.fromRGB(255, 255, 255)
				for _, aura in ipairs(ReplicatedStorage.CraftAura:GetChildren()) do
					if aura.Name == currentUpgrade then
						local auraClone = aura:Clone()
						auraClone.Parent = descendants
					end
				end
			elseif currentUpgrade == "Cursed" then
				for _, aura in ipairs(ReplicatedStorage.CraftAura:GetChildren()) do
					if aura.Name == currentUpgrade then
						local auraClone = aura:Clone()
						auraClone.Parent = descendants
					end
				end
			elseif currentUpgrade == "Blazing" then
				for _, aura in ipairs(ReplicatedStorage.CraftAura:GetChildren()) do
					if aura.Name == currentUpgrade then
						local auraClone = aura:Clone()
						auraClone.Parent = descendants
					end
				end
				descendants.Material = Enum.Material.Neon
			elseif currentUpgrade == "Golden" then
				descendants.Color = Color3.fromRGB(187, 190, 26)
				descendants.Material = Enum.Material.Neon
			end
		end
	end
	
	return model
end

function Pets.GetEquippedSoul(data: PlayerData.PlayerData)
	local equippedPets = Pets.GetEquippedPets(data)
	local soul = 1
	
	for _, pet in equippedPets do
		soul += Pets.GetPerMultiplier(pet)
	end
	
	return soul
end

function Pets.GetPerMultiplier(pet: PetInstance)
	local config = Pets.GetConfig(pet)
	local multiplierPerLevel = config.MultiplierPerLevel or 1
	
	local multiplier = (multiplierPerLevel * pet.Level) + config.Soul
	
	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if currentUpgrade == "Golden" then 
		multiplier += multiplier * 1.5
	elseif currentUpgrade == "Blazing" then
		multiplier += multiplier * 2.5
	elseif currentUpgrade == "Cursed" then
		multiplier += multiplier * 5
	elseif currentUpgrade == "Cleanera" then
		multiplier += multiplier * 10
	end
	
	return multiplier
end

function Pets.GetEquippedPets(data: PlayerData.PlayerData): {PetInstance}
	local equipped = {}
	for uuid, petInstance: PetInstance in data.Pets do
		if petInstance.Equipped then
			table.insert(equipped, petInstance)
		end
	end
	
	return equipped
end

function Pets.GetPetXPRequirement(pet: PetInstance)
	local config = Pets.GetConfig(pet)
	if not config then return end
	
	local maxLevel = config.MaxLevel
	local level = pet.Level
	if level == maxLevel then return 0 end
	
	return if level == 0 then Pets.XPPerLevel else level * Pets.XPPerLevel
end

function Pets.GetTotalStoredPets(data: PlayerData.PlayerData)
	local amount = 0
	for uuid, petInstance: PetInstance in data.Pets do
		amount += 1
	end
	return amount
end

function Pets.GetMaxStoredPets(data: PlayerData.PlayerData)
	local amount = DEFAULT_MAX_STORED_PETS
	--do gamepass check
	return amount
end

function Pets.GetMaxEquippedPets(data: PlayerData.PlayerData)
	local amount = DEFAULT_MAX_EQUIPPED_PETS
	--do gamepass check
	return amount
end

function Pets.GetDuplicatePets(pet: PetInstance, data)
	local duplicatePets = {}
	for uuid, petInstance: PetInstance in data.Pets do
		if petInstance.Model ~= pet.Model or petInstance.Rarity ~= pet.Rarity then continue end
		if (petInstance.Golden and not pet.Golden) or (petInstance.Blazing and not pet.Blazing) or (petInstance.Cursed and not pet.Cursed) or (petInstance.Cleanera and not pet.Cleanera) then continue end
		if (not petInstance.Golden and pet.Golden) or (not petInstance.Blazing and pet.Blazing) or (not petInstance.Cursed and pet.Cursed) or (not petInstance.Cleanera and pet.Cleanera) then continue end
		
		table.insert(duplicatePets, petInstance)
	end
	
	return duplicatePets
end

function Pets.GetCurrentUpgrade(pet: PetInstance): PetUpgrade?
	if pet.Cleanera then
		return "Cleanera"
	elseif pet.Cursed then
		return "Cursed"
	elseif pet.Blazing then
		return "Blazing"
	elseif pet.Golden then
		return "Golden"
	end
	return nil
end

function Pets.GetNextUpgrade(pet: PetInstance): "Max Upgraded" | "Golden" | "Blazing" | "Cursed" | "Cleanera"
	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if pet.Cleanera then
		return "Max Upgraded"
	elseif pet.Cursed then
		return "Cleanera"
	elseif pet.Blazing then
		return "Cursed"	
	elseif pet.Golden then
		return "Blazing"	
	else
		return "Golden"
	end
end

function Pets.GetNextUpgradeCost(pet: PetInstance): number
	local nextUpgrade = Pets.GetNextUpgrade(pet)
	if nextUpgrade == "Cleanera" then
		return AMOUNT_TO_CLEANERA
	elseif nextUpgrade == "Cursed" then
		return AMOUNT_TO_CURSED
	elseif nextUpgrade == "Blazing" then
		return AMOUNT_TO_BLAZING
	elseif nextUpgrade == "Golden" then
		return AMOUNT_TO_GOLDEN
	end
end

function Pets.CanUpgradePet(pet: PetInstance, data)
	local nextUpgrade = Pets.GetNextUpgrade(pet)
	if nextUpgrade == "Max Upgraded" then return false end
	
	local duplicatePets = Pets.GetDuplicatePets(pet, data)
	
	if nextUpgrade == "Golden" and #duplicatePets >= AMOUNT_TO_GOLDEN then
		return true
	elseif nextUpgrade == "Blazing" and #duplicatePets >= AMOUNT_TO_BLAZING then
		return true
	elseif nextUpgrade == "Cursed" and #duplicatePets >= AMOUNT_TO_CURSED then
		return true
	elseif nextUpgrade == "Cleanera" and #duplicatePets >= AMOUNT_TO_CLEANERA then
		return true
	end
	
	return false
end

return Pets
