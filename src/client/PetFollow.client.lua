local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local PetsConfig = require(ReplicatedStorage.Config.Pets)
local StateManager = require(ReplicatedStorage.Client.State)
local Remotes = ReplicatedStorage.Remotes.Pets

local GuiTemplate = ReplicatedStorage.PetGui

local TweenService = game:GetService("TweenService")

local EquippedPets: {[string]: {[string]: PetsConfig.PetInstance} } = {}

local PetPosition = {
	{
		Position = Vector3.new(0, 1 , 10),
		Orientation = Vector3.new(0, 0, 0)
	},
	
	{
		Position = Vector3.new(-7.5 , 1 ,8),
		Orientation = Vector3.new(0, -40, 0)
	},
	
	{
		Position = Vector3.new(7.5 , 1 ,8),
		Orientation = Vector3.new(0, 40, 0)
	},
}

local function GetRarityColor(rarity: string)
	local color
	if rarity == "Common" then
		color = Color3.fromRGB(255,255,255)
	elseif rarity == "Uncommon" then
		color = Color3.fromRGB(85, 225, 83)
	elseif rarity == "Rare" then
		color = Color3.fromRGB(40, 195, 198)
	elseif rarity == "Magic" then
		color = Color3.fromRGB(152, 0, 157)
	elseif rarity == "Legendary" then
		color = Color3.fromRGB(238, 220, 23)
	elseif rarity == "Heaven" then
		color = Color3.fromRGB(164, 215, 216)
	end

	return color

end

local function GetPetOrder(character: Model)
	local petFolder = character:FindFirstChild("Pets")
	if not petFolder then return 1 end
	
	if #petFolder:GetChildren() == 0 then
		return 1
	end
	
	local activeSlots = {}
	for _, pet in petFolder:GetChildren() do
		local order = pet.Order.Value
		activeSlots[order] = order
	end

	for availableSlot = 1, 4, 1 do
		if not activeSlots[availableSlot] then
			return availableSlot
		end
	end
end

local function PetFollow(player: Player, pet: PetsConfig.PetInstance)
	local character = player.Character or player.CharacterAdded:Wait()
	if not character then return end
	
	local humanoidRootPart: Part = character:WaitForChild('HumanoidRootPart')
	if not humanoidRootPart then return end
	
	local pets = EquippedPets[tostring(player.UserId)]
	if not pets then return end
	
	pets[pet.UUID] = pet
	
	local petsFolder = character:FindFirstChild("Pets")
	if not petsFolder then
		petsFolder = Instance.new("Folder", character)
		petsFolder.Name = "Pets"
	end
	
	local petModel: Model = PetsConfig.GetModel(pet)
	petModel:PivotTo(humanoidRootPart.CFrame)
	
	local charAttachment = Instance.new("Attachment", humanoidRootPart)
	charAttachment.Visible = false
	
	local petAttachment = Instance.new("Attachment", petModel.PrimaryPart)
	petAttachment.Visible = false
	
	local alignPositions = Instance.new("AlignPosition", petModel)
	alignPositions.MaxForce = 25_000
	alignPositions.Responsiveness = 25
	alignPositions.Attachment0 = petAttachment
	alignPositions.Attachment1 = charAttachment
	
	local alignOrientation = Instance.new("AlignOrientation", petModel)
	alignOrientation.MaxTorque = 25_000
	alignOrientation.Responsiveness = 25
	alignOrientation.Attachment0 = petAttachment
	alignOrientation.Attachment1 = charAttachment
	
	local order = Instance.new("IntValue", petModel)
	order.Name = "Order"
	order.Value = GetPetOrder(character)
	
	local petPosition = PetPosition[order.Value]
	charAttachment.Position = petPosition.Position
	charAttachment.Orientation = petPosition.Orientation
	
	petModel.Name = pet.UUID
	petModel.Parent = petsFolder
	
	local tweenInfo = TweenInfo.new(1)
	local upTween = TweenService:Create(charAttachment, tweenInfo, {
		Position = Vector3.new(charAttachment.Position.X, 1.5, charAttachment.Position.Z),
		Orientation = Vector3.new(charAttachment.Orientation.X, charAttachment.Orientation.Y, -2)
	})
	
	local downTween = TweenService:Create(charAttachment, tweenInfo, {
		Position = Vector3.new(charAttachment.Position.X, 0, charAttachment.Position.Z),
		Orientation = Vector3.new(charAttachment.Orientation.X, charAttachment.Orientation.Y, 2)
	})
	upTween.Completed:Connect(function()
		downTween:Play()
	end)
	downTween.Completed:Connect(function()
		upTween:Play()
	end)
	upTween:Play()
	
	local isUpgraded = pet.Cleanera or pet.Cursed or pet.Blazing or pet.Golden
	local currentUpgrade = PetsConfig.GetCurrentUpgrade(pet)
	
	
	local gui = GuiTemplate:Clone()
	gui.Parent = petModel.PrimaryPart
	gui.Frame.NamePet.Text = pet.Name
	gui.Frame.NamePet.TextColor3 = GetRarityColor(pet.Rarity)
	gui.Frame.LevelPet.Text = "Level: "..pet.Level
	gui.Frame.UpgradePet.Text = if currentUpgrade then `({currentUpgrade:upper()})` else ""
	gui.Frame.UpgradePet.TextColor3 = if currentUpgrade == "Cleanera" then Color3.fromRGB(219, 224, 255) elseif currentUpgrade == "Cursed" then Color3.fromRGB(42, 26, 26) elseif currentUpgrade == "Blazing" then Color3.fromRGB(2, 195, 189) else Color3.fromRGB(255, 247, 0) 
	gui.Frame.UpgradePet.Visible = isUpgraded
end

local function PetStopFollow(player: Player, uuid: string)
	local pets = EquippedPets[tostring(player.UserId)]
	if not pets then return end
	pets[uuid] = nil
	
	local character = player.Character
	if not character then return end
	
	local petsFolder = character:FindFirstChild("Pets")
	if not petsFolder then return end
	
	local model = petsFolder:FindFirstChild(uuid)
	if model then
		model:Destroy()
	end

end

local function InitalizePlayer(player: Player)
	local pets = EquippedPets[tostring(player.UserId)]
	if not pets then 
		EquippedPets[tostring(player.UserId)] = {}
		return
	end

	for uuid, pet in pets do
		PetFollow(player, pet)
	end
end

Remotes.EquipPet.OnClientEvent:Connect(function(uuid)
	local petInstance = StateManager.GetData().Pets[uuid]
	local pets = EquippedPets[tostring(Player.UserId)]
	pets[uuid] = petInstance
	PetFollow(Player, petInstance)
end)
Remotes.UnequipPet.OnClientEvent:Connect(function(uuid)
	PetStopFollow(Player, uuid)
end)
Remotes.ReplicateEquipPet.OnClientEvent:Connect(PetFollow)
Remotes.ReplicateUnequipPet.OnClientEvent:Connect(PetStopFollow)

StateManager.GetData()
EquippedPets = Remotes.GetEquippedPets:InvokeServer()
for _, player in Players:GetPlayers() do
	player.CharacterAdded:Connect(function(character)
		InitalizePlayer(player)
	end)
	InitalizePlayer(player)
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		InitalizePlayer(player)
	end)
	InitalizePlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	local pets = EquippedPets[tostring(player.UserId)]
	if pets then
		EquippedPets[tostring(player.UserId)] = nil
	end
end)