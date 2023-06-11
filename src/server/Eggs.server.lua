local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes.Eggs
local EggsConfig = require(ReplicatedStorage.Config.Eggs)
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local PetsConfig = require(ReplicatedStorage.Config.Pets)

local PlayerData = require(ServerScriptService.ProfileService.Manager)
local PetsManager = require(ServerScriptService.Pets)

local SOUL_CURRENCY_ICON = "rbxassetid://10701474374"
local ROBUX_CURRENCY_ICON = "rbxassetid://11560341132"

local hatchCooldown = {}

local function ChoosePet(egg: string, playerData)
	local eggConfig = EggsConfig.GetConfig(egg)
	local totalWeight = 0
	for pet, props in eggConfig.Pets do
		totalWeight += props.Chance
	end
	
	local chance = math.random(0, totalWeight)
	local count = 0
	
	for pet, props in eggConfig.Pets do
		local hatchChance = EggsConfig.GetHatchChance(egg, pet, playerData)
		count += hatchChance
		
		if chance <= count then
			return pet
		end
	end
	
 end

local function Hatch(player: Player, egg: string, amount: number)
	local profile =  PlayerData.Profiles[player]
	if not profile then return end
	
	local onCooldown =  hatchCooldown[player]
	if onCooldown then return end
	
	local eggConfig = EggsConfig.GetConfig(egg)
	if not eggConfig then return end
	
	local hasTrippleHatch = true
	local amountOfHatches = 1
	
	if hasTrippleHatch and amount == 3 then
		amountOfHatches = 3
	end
	
	local price = eggConfig.Price * amountOfHatches
	local currency = eggConfig.Currency
	
	if currency ~= "Robux" then
		local money = player.leaderstats.Soul.Value
		local canAfford = money > price
		if not canAfford then return end
	end

	local storedPets = PetsConfig.GetTotalStoredPets(profile.Data)
	local maxStoredPets = PetsConfig.GetMaxStoredPets(profile.Data)
	local hasStorage = storedPets + amountOfHatches <= maxStoredPets
	if not hasStorage then return end
	
	hatchCooldown[player] = true
	task.delay(3, function()
		hatchCooldown[player] = nil
	end)
	
	local pets = {}
	while amountOfHatches > 0 do
		amountOfHatches -= 1
		local storedPets = PetsConfig.GetTotalStoredPets(profile.Data)
		local maxStoredPets = PetsConfig.GetMaxStoredPets(profile.Data)
		local hasStorage = storedPets + amountOfHatches <= maxStoredPets
		if not hasStorage then return pets end
		
		if currency == "Soul" then
			player.leaderstats.Soul.Value -= eggConfig.Price
			print(eggConfig.Price)
		end
		
		local pet = ChoosePet(egg, profile.Data)
		local rarity = eggConfig.Pets[pet].Rarity
		local petInstance = PetsManager.CreatePet(pet, rarity)
		PetsManager.GivePet(player, petInstance)
		table.insert(pets, pet)
		local hatchChance = EggsConfig.GetHatchChance(egg, pet, profile.Data)
		if hatchChance <= 5 then 
			Remotes.HatchedChat:FireAllClients(player.DisplayName, pet, hatchChance)
		end
	end
	return pets
	
end

Remotes.Hatch.OnServerInvoke = Hatch