local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local ViewportModel = require(ReplicatedStorage.Libs.ViewportModel)
local StateManager = require(ReplicatedStorage.Client.State)
local PetUtils = require(ReplicatedStorage.Client.PetUtils)

local PetsConfig = require(ReplicatedStorage.Config.Pets)
local Remotes = ReplicatedStorage.Remotes.Pets
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local SoundService = game:GetService("SoundService")

local LeftGui = PlayerGui.Left
local OpenButton = LeftGui.Frame.Buttons.Pets

local Gui = PlayerGui:WaitForChild("PetInventory")
local Frame = Gui.Frame

local Storage = Frame.Storage
local Slots = Frame.Slots

local Container = Frame.Container
local Info = Frame.Info.InfoFrame

local PetTemplate = Container.Template

local selectedPet: string?
local selectedPets = {}
local isSelecting = false

local LEVEL_STRING = "Level AMOUNT"

local EQUIP_BUTTON_COLOR = Color3.fromRGB(185, 255, 180)
local UNEQUIP_BUTTON_COLOR = Color3.fromRGB(180, 124, 125)

local INFO_SOUL_STRING = "xAMOUNT"
local DELETE_SELECTED_TEXT = "Are you sure you want to delete AMOUNT pets?"
local INFO_STATS_TEXT = "xAMOUNT"


local function GetRarityColor(rarity: string)
	local color
	if rarity == "Common" then
		color = Color3.fromRGB(236, 234, 230)
	elseif rarity == "Uncommon" then
		color = Color3.fromRGB(53, 225, 0)
	elseif rarity == "Rare" then
		color = Color3.fromRGB(0, 181, 198)
	elseif rarity == "Magic" then
		color = Color3.fromRGB(163, 0, 185)
	elseif rarity == "Legendary" then
		color = Color3.fromRGB(238, 238, 0)
	elseif rarity == "Heaven" then
		color = Color3.fromRGB(164, 215, 216)
	end

	return color

end


local function UpdateInfo(uuid: string)
	local pet: PetsConfig.PetInstance = StateManager.GetData().Pets[uuid]
	if not pet then return end
	
	local xp = pet.Experience
	local requiredXP = PetsConfig.GetPetXPRequirement(pet)
	
	selectedPet = uuid
	
	local currentUpgrade = PetsConfig.GetCurrentUpgrade(pet)
	local prefix = if currentUpgrade then `({currentUpgrade:upper()}) ` else ""
	
	Info.Visible = true
	Info.NamePet.Text = pet.Name
	Info.Rarity.Text = pet.Rarity
	Info.Rarity.TextColor3 = GetRarityColor(pet.Rarity)
	Info.Level.Text = `{prefix}{LEVEL_STRING:gsub("AMOUNT", FormatNumber.FormatCompact(pet.Level))}`
	Info.ProgressBar.Amount.Text = if requiredXP == 0 then "Maxed Out" else FormatNumber.FormatCompact(xp).."/"..FormatNumber.FormatCompact(requiredXP)
	Info.ProgressBar.ProgressBar.Size = UDim2.fromScale(xp / requiredXP, 1)
	Info.ProgressBar.ProgressBar.Visible = xp > 0
	
	
	local model = PetsConfig.GetModel(pet)
	ViewportModel.CleanViewport(Info.ViewportFrame)
	ViewportModel.GenerateViewport(Info.ViewportFrame, model:Clone(), CFrame.Angles(0, math.rad(180), 0))
	
	local stat = PetsConfig.GetPerMultiplier(pet)
	Info.InfoStats.Soul.Visible = stat > 0
	Info.InfoStats.Soul.Text = INFO_SOUL_STRING:gsub("AMOUNT", FormatNumber.FormatCompact(stat))
	Info.InfoStats.Essence.Visible = stat > 0
	Info.InfoStats.Essence.Text = INFO_SOUL_STRING:gsub("AMOUNT", FormatNumber.FormatCompact(stat))
	
	Info.Equip.BackgroundColor3 = if pet.Equipped then UNEQUIP_BUTTON_COLOR else EQUIP_BUTTON_COLOR
	Info.Equip.Text = if pet.Equipped then "Unequip" else "Equip"
	
	local nextUpgrade = PetsConfig.GetNextUpgrade(pet)
	local canUpgrade = PetsConfig.CanUpgradePet(pet, StateManager.GetData())
	local duplicatePets = PetsConfig.GetDuplicatePets(pet, StateManager.GetData())
	local upgradeCost = PetsConfig.GetNextUpgradeCost(pet)
	Info.Craft.BackgroundColor3 = if canUpgrade then Color3.fromRGB(143, 203, 133) else Color3.fromRGB(62, 62, 62)
	Info.Craft.Text = if nextUpgrade == "Max Upgraded" then nextUpgrade else `{nextUpgrade} ({#duplicatePets}/{upgradeCost})`
	
end

local function GeneratePet(pet: PetsConfig.PetInstance)
	local button = PetUtils.GeneratePet(PetTemplate, Container, pet)
	button.MouseButton1Click:Connect(function()
		if isSelecting then
			local petState: PetsConfig.PetInstance = StateManager.GetData().Pets[pet.UUID]
			if petState.Equipped then return end
			
			local index = table.find(selectedPets, pet.UUID)
			button:FindFirstChild("Delete").Visible = not index
			if index then
				table.remove(selectedPets, index)
			else
				table.insert(selectedPets, pet.UUID)
			end
		else
			UpdateInfo(pet.UUID)
		end
	end)
end


local function UpdatePet(uuid: string)
	local pet: PetsConfig.PetInstance = StateManager.GetData().Pets[uuid]
	local button = Container:FindFirstChild(uuid)
	
	button.NamePet.Text = pet.Name
	button.NamePet.TextColor3 = GetRarityColor(pet.Rarity)
	button.Equipped.Visible = pet.Equipped
	button.StatsPet.Text = INFO_STATS_TEXT:gsub("AMOUNT", FormatNumber.FormatCompact(PetsConfig.GetPerMultiplier(pet)))
	button.BackgroundColor3 = PetUtils.GetUpgradeColor(pet)
	
	PetUtils.UpdateLayout(Container)
	
	if selectedPet == uuid then
		UpdateInfo(uuid)
	end
end

local function UpdateStorage()
	local equipped = #PetsConfig.GetEquippedPets(StateManager.GetData())
	local maxEquipped = PetsConfig.GetMaxEquippedPets(StateManager.GetData())
	Storage.Text = equipped.."/"..maxEquipped
	
	local stored = PetsConfig.GetTotalStoredPets(StateManager.GetData())
	local maxStored = PetsConfig.GetMaxStoredPets(StateManager.GetData())
	Slots.Text = stored.."/"..maxStored
end

local function DeletePet(uuid: string)
	local button = Container:FindFirstChild(uuid)
	button:Destroy()

	if selectedPet == uuid then
		selectedPet = nil
		Info.Visible = false
	end
	task.delay(0, function()
		UpdateStorage()
	end)
end

local function SelectMode(enabled: boolean)
	isSelecting = enabled
	Frame.MultiDelete.BackgroundColor3 = if isSelecting then EQUIP_BUTTON_COLOR else UNEQUIP_BUTTON_COLOR
	if not isSelecting then
		for _, children in Container:GetChildren() do
			if not children:IsA("GuiButton") then continue end
			children:FindFirstChild("Delete").Visible = false
		end
		selectedPets = {}
	end
end

Info.Equip.MouseButton1Click:Connect(function()
	SelectMode(false)
	if selectedPet then
		Remotes.EquipPet:FireServer(selectedPet)
	end
end)

Info.Craft.MouseButton1Click:Connect(function()
	if not selectedPet then return end
	local petInstance: PetsConfig.PetInstance = StateManager.GetData().Pets[selectedPet]
	local canUpgrade = PetsConfig.CanUpgradePet(petInstance, StateManager.GetData())
	if canUpgrade then
		Remotes.UpgradePet:FireServer(selectedPet)
	end
end)

Info.DeleteThisPet.MouseButton1Click:Connect(function()
	if not selectedPet then return end
	
	local pet: PetsConfig.PetInstance = StateManager.GetData().Pets[selectedPet]
	Remotes.DeletePet:FireServer(selectedPet)
end)


Frame.UnequipAll.MouseButton1Click:Connect(function()
	SelectMode(false)
	Remotes.UnequipAllPets:FireServer()
end)



Frame.EquipBest.MouseButton1Click:Connect(function()
	SelectMode(false)
	Remotes.EquipBestPets:FireServer()
end)

Frame.MultiDelete.MouseButton1Click:Connect(function()
	if isSelecting then
		if #selectedPets == 0 then
			SelectMode(false)
		else
			Frame.Warning.Selected.Text = DELETE_SELECTED_TEXT:gsub("AMOUNT", FormatNumber.FormatCompact(#selectedPets))
			Frame.Warning.Visible = true
		end
	else
		SelectMode(true)
	end
end)

Frame.Warning.Delete.MouseButton1Click:Connect(function()
	if isSelecting then
		Remotes.DeletePets:FireServer(selectedPets)
		SelectMode(false)
	end
	Frame.Warning.Visible = false
end)

Frame.Warning.Back.MouseButton1Click:Connect(function()
	Frame.Warning.Visible = false
	if isSelecting then
		SelectMode(false)
	end
end)


OpenButton.MouseButton1Click:Connect(function()
	Gui.Enabled = not Gui.Enabled
	SoundService.SfxButton:Play()
end)


Remotes.GivePet.OnClientEvent:Connect(function(pet: PetsConfig.PetInstance)
	task.delay(0, function()
		GeneratePet(pet)
		UpdateStorage()
	end)
end)
Remotes.DeletePet.OnClientEvent:Connect(DeletePet)
Remotes.EquipPet.OnClientEvent:Connect(function(uuid: string)
	task.delay(0, function()
		UpdatePet(uuid)
		UpdateStorage()
	end)
end)
Remotes.UnequipPet.OnClientEvent:Connect(function(uuid: string)
	task.delay(0, function()
		UpdatePet(uuid)
		UpdateStorage()
	end)
end)

Remotes.UpdatePetXp.OnClientEvent:Connect(function(uuid: string, xp: number)
	task.delay(0, function()
		if selectedPet == uuid then
			UpdateInfo(uuid)
		end
	end)
end)

Remotes.UpdatePetLevel.OnClientEvent:Connect(function(uuid: string, level: number)
	task.delay(0, function()
		if selectedPet == uuid then
			UpdateInfo(uuid)
		end
	end)
end)

Remotes.UpgradePet.OnClientEvent:Connect(function(uuid: string, upgrade: PetsConfig.PetUpgrade)
	task.delay(0, function()
		UpdatePet(uuid)
		if selectedPet == uuid then
			UpdateInfo(uuid)
		end
	end)
end)

UpdateStorage()
for uuid, pet in StateManager.GetData().Pets do
	GeneratePet(pet)
end