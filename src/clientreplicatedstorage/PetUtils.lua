local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local ViewportModel = require(ReplicatedStorage.Libs.ViewportModel)
local PetsConfig = require(ReplicatedStorage.Config.Pets)
local Remotes = ReplicatedStorage.Remotes.Pets
local StateManager = require(ReplicatedStorage.Client.State)

local INFO_STATS_TEXT = "xAMOUNT"

local PetUtils = {}

function PetUtils.UpdateLayout(container: ScrollingFrame)
	local pets = {}
	for _, child in container:GetChildren() do
		if child:IsA("TextButton") and child.Visible then
			local uuid = child.Name
			local petInstance: PetsConfig.PetInstance = StateManager.GetData().Pets[uuid]
			if not petInstance then continue end
			
			local multiplier = PetsConfig.GetPerMultiplier(petInstance)
			table.insert(pets, {
				uuid = uuid,
				equipped = petInstance.Equipped,
				multiplier = multiplier
			})
		end
	end
	
	table.sort(pets, function(a, b)
		if a.equipped and not b.equipped then 
			return true
		elseif not a.equipped and b.equipped then
			return false
		else
			return a.multiplier > b.multiplier
		end
	end)
	
	for i, petData in pets do
		local button = container:FindFirstChild(petData.uuid)
		button.LayoutOrder = i
	end
end

function PetUtils.GetUpgradeColor(pet: PetsConfig.PetInstance)
	local currentUpgrade = PetsConfig.GetCurrentUpgrade(pet)
	return if currentUpgrade == "Cleanera" then Color3.fromRGB(205, 212, 255)
		elseif currentUpgrade == "Cursed" then Color3.fromRGB(154, 76, 76)
		elseif currentUpgrade == "Blazing" then Color3.fromRGB(135, 221, 221)
		elseif currentUpgrade == "Golden" then Color3.fromRGB(197, 199, 89)
		else Color3.fromRGB(122, 103, 103)
end

function PetUtils.GetRarityColor(rarity: string)
	local color
	if rarity == "Common" then
		color = Color3.fromRGB(255,255,255)
	elseif rarity == "Uncommon" then
		color = Color3.fromRGB(85, 225, 83)
	elseif rarity == "Rare" then
		color = Color3.fromRGB(40, 195, 198)
	elseif rarity == "Magic" then
		color = Color3.fromRGB(154, 0, 185)
	elseif rarity == "Legendary" then
		color = Color3.fromRGB(238, 220, 23)
	elseif rarity == "Heaven" then
		color = Color3.fromRGB(164, 215, 216)
	end

	return color

end

function PetUtils.GeneratePet(template: TextButton, container: ScrollingFrame, pet: PetsConfig.PetInstance)
	local clone = template:Clone()
	clone.Parent = container
	clone.Visible = true
	clone.Name = pet.UUID

	clone.NamePet.Text = pet.Name
	clone.NamePet.TextColor3 = PetUtils.GetRarityColor(pet.Rarity)
	clone.Equipped.Visible = pet.Equipped
	clone.StatsPet.Text = INFO_STATS_TEXT:gsub("AMOUNT", FormatNumber.FormatCompact(PetsConfig.GetPerMultiplier(pet)))
	clone.BackgroundColor3 = PetUtils.GetUpgradeColor(pet)

	local model = PetsConfig.GetModel(pet)
	ViewportModel.GenerateViewport(clone.ViewportFrame, model:Clone(), CFrame.Angles(0, math.rad(180), 0))
	
	PetUtils.UpdateLayout(container)
	
	return clone
end

return PetUtils
