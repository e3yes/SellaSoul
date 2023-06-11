local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

export type EggConfig = {
	Price: number,
	Currency: string,
	Pets: {
		[string]: {
			Chance: number,
			Rarity: string
		}
	}
}

local Config: { [string]: EggConfig } = {
	Basic = {
		Price = 5000,
		Currency = "Soul",
		Pets = {
			EmptyCrystal = {
				Chance = 50,
				Rarity = "Common"
			},
			GrassCrystal = {
				Chance = 45,
				Rarity = "Common"
			},
			RustyCrystal = {
				Chance = 30,
				Rarity = "Uncommon"
			},
			MetalCrystal = {
				Chance = 20,
				Rarity = "Rare"
			},
			LongSnowCrystal = {
				Chance = 5,
				Rarity = "Magic"
			},
		}
	},
	Extra = {
		Price = 10000000,
		Currency = "Soul",
		Pets = {
			FoilCrystal = {
				Chance = 50,
				Rarity = "Common"
			},
			GreenNeonCrystal = {
				Chance = 40,
				Rarity = "Uncommon"
			},
			YellowNeonCrystal = {
				Chance = 30,
				Rarity = "Uncommon"
			},
			DoubleGreenNeonCrystal = {
				Chance = 19,
				Rarity = "Rare"
			},
			TripplePinkNeonCrystal = {
				Chance = 5.5,
				Rarity = "Magic"
			},
			LightningCrystal = {
				Chance = 1.0007,
				Rarity = "Legendary"
			},
		}
	},
	
	Hell = {
		Price = 200000000000000000,
		Currency = "Soul",
		Pets = {
			HellCrystal = {
				Chance = 55,
				Rarity = "Common"
			},
			TrippleHellCrystal = {
				Chance = 35,
				Rarity = "Uncommon"
			},
			HellSpirit = {
				Chance = 10,
				Rarity = "Rare"
			},
			Diavolo = {
				Chance = 2.666,
				Rarity = "Legendary"
			},
		}
	},
	SmallHeaven = {
		Price = 50000000000000000000000000,
		Currency = "Soul",
		Pets = {
			HeavenCrystal = {
				Chance = 50,
				Rarity = "Uncommon"
			},
			HeavenSpirit = {
				Chance = 20,
				Rarity = "Rare"
			},
			KeeperOfHeaven = {
				Chance = 0.2,
				Rarity = "Heaven"
			},
		}
	},
	
}


local Eggs = {}

Eggs.Config = Config

function Eggs.GetConfig(egg: string): EggConfig
	return Config[egg]
end

function Eggs.GetEggStandModels()
	local models = {}
	
	for _, descendant in Workspace:GetDescendants() do
		if descendant.Name == "Egg Stand" then
			local egg = descendant:GetAttribute("egg")
			if egg then
				models[egg] = descendant
			end
		end
	end
	return models
end

function Eggs.GetHatchChance(egg: string, pet: string, data)
	local config = Eggs.GetConfig(egg)
	if not config then return end
	
	local luskStat = 1 --do gamepass check here
	local chance = config.Pets[pet].Chance
	if chance < 10 then
		chance *= luskStat
	end
	
	return chance
end

local function GenerateEggModels()
	local models = Eggs.GetEggStandModels()
	for egg, model in models do
		local part = model.EggMain:Clone()
		local newModel = Instance.new("Model")
		newModel.Name = egg
		newModel.Parent = ReplicatedStorage.Eggs
		newModel.PrimaryPart = part
		
		part.Parent = newModel
		
	end
end

if RunService:IsClient() then
	GenerateEggModels()
end

return Eggs
