local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LightiningService = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local Remotes = ReplicatedStorage.Remotes.Eggs

local EggsConfig = require(ReplicatedStorage.Config.Eggs)
local PetsConfig = require(ReplicatedStorage.Config.Pets)
local ViewportModel = require(ReplicatedStorage.Libs.ViewportModel)
local StateManager = require(ReplicatedStorage.Client.State)
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local Gui = PlayerGui:WaitForChild("PetEgg")
local EggGui = Gui.Egg

local AnimationFrame = Gui.Animation
local Info = EggGui.Info
local Container = EggGui.Container
local Buttons = EggGui.Buttons

local GUI_BLACKLIST = {"PetEgg", "Left", }

local Template = Container.Template

local SOUL_CURRENCY_ICON = "rbxassetid://13428280085"
local ROBUX_CURRENCY_ICON = "rbxassetid://11560341132"
local eggModels = EggsConfig.GetEggStandModels()

local selectedEgg = nil
local isHatching = false
local hatchMode = 1
local isAutoHatching = false

local function GetRarityColor(rarity: string)
	local color
	if rarity == "Common" then
		color = Color3.fromRGB(255,255,255)
	elseif rarity == "Uncommon" then
		color = Color3.fromRGB(85, 225, 83)
	elseif rarity == "Rare" then
		color = Color3.fromRGB(40, 195, 198)
	elseif rarity == "Magic" then
		color = Color3.fromRGB(156, 0, 148)
	elseif rarity == "Legendary" then
		color = Color3.fromRGB(238, 220, 23)
	elseif rarity == "Heaven" then
		color = Color3.fromRGB(164, 215, 216)
	end

	return color

end

local function HideGui()
	LightiningService.Blur.Enabled = true
	
	local enabledGuis = {}
	for _, gui in PlayerGui:GetChildren() do
		if not gui:IsA("ScreenGui") or table.find(GUI_BLACKLIST, gui.Name) then continue end
		if gui.Enabled then
			table.insert(enabledGuis, gui)
			gui.Enabled = false
		end
	end
	task.delay(3, function()
		for _, gui in enabledGuis do 
			gui.Enabled = true
		end
		LightiningService.Blur.Enabled = false
	end)
end

local function HatchAnimation(egg: string, pet: string, rarity: string)
	isHatching = true
	HideGui()
	local petModel = ReplicatedStorage.PetsModels:FindFirstChild(pet):Clone()
	local eggModel = ReplicatedStorage.Eggs[egg]:Clone()
	
	local template = AnimationFrame.Template:Clone()
	template.Pet.Text = pet
	--template.Rarity.Text = rarity
	template.Parent = AnimationFrame
	template.Visible = true
	
	ViewportModel.GenerateViewport(template, eggModel)
	eggModel.PrimaryPart.Orientation = Vector3.new(10,20,-70)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut, 1, true)
	local tween = TweenService:Create(eggModel.PrimaryPart, tweenInfo, {
		Orientation = Vector3.new(60,100,70)
		
	})
	tween:Play()
	
	tween.Completed:Connect(function()
		ViewportModel.CleanViewport(template)
		template.Pet.Visible = true
		--template.Rarity.Visible = true
		ViewportModel.GenerateViewport(template, petModel, CFrame.Angles(0, math.rad(180), 0))
		task.wait(1)
		template:Destroy()
		isHatching = false
		EggGui.Enabled = true
	end)
	
end
	
	

local function UpdatePet(pet: string)
	local template = Container:FindFirstChild(pet)
	if not template then return end
	
	local chance =  EggsConfig.GetHatchChance(selectedEgg, pet, StateManager.GetData())
	template.Chance.Text = chance.."%"
end

local function GeneratePet(egg: string, pet: string)
	local eggConfig = EggsConfig.GetConfig(egg)
	local template = Template:Clone()
	template.Name = pet
	template.Parent = Container
	
	local chance =  EggsConfig.GetHatchChance(egg, pet, StateManager.GetData())
	template.Chance.Text = chance.."%"
	template.Rarity.Text = eggConfig.Pets[pet].Rarity
	template.Rarity.TextColor3 = GetRarityColor(eggConfig.Pets[pet].Rarity)
	
	local model = ReplicatedStorage.PetsModels:FindFirstChild(pet):Clone()
	task.delay(0.01, function()
		ViewportModel.GenerateViewport(template.ViewportFrame, model, CFrame.Angles(0, math.rad(180), 0))
	end)
	
	template.LayoutOrder = -chance
	template.Visible = true
	
	
end

local function DisplayEgg(egg: string)
	local eggModel = eggModels[egg]
	EggGui.Adornee = eggModel
	EggGui.Enabled = true
	
	local eggConfig = EggsConfig.GetConfig(egg)
	local currency = eggConfig.Currency
	Info.Egg.Egg.Text = egg.." Egg"
	Info.Price.Price.Text = FormatNumber.FormatCompact(eggConfig.Price)
	Info.Price.Icon.Image = if currency == "Robux" then ROBUX_CURRENCY_ICON else SOUL_CURRENCY_ICON
	
	for _, child in Container:GetChildren() do
		if child:IsA("GuiButton") and child.Visible then
			child:Destroy()
		end
	end
	
	for pet, petInfo in eggConfig.Pets do
		GeneratePet(egg, pet)
	end
end

local function Hatch(amount: number?)
	if not selectedEgg then return end
	if amount then
		hatchMode = amount
	end
	
	local eggConfig = EggsConfig.GetConfig(selectedEgg)
	
	local isTrippleHatch = false
	
	local storedPets = PetsConfig.GetTotalStoredPets(StateManager.GetData())
	local maxStoredPets = PetsConfig.GetMaxStoredPets(StateManager.GetData())
	local hasStorage = storedPets + hatchMode <= maxStoredPets
	if not hasStorage then return end
	
	local price = eggConfig.Price * hatchMode
	local currency = eggConfig.Currency
	
	if currency == "Robux" then
		--Gamepass
	else
		local money = Player.leaderstats.Soul.Value
		local canAfford = money > price
		if not canAfford then return end
		
		local pets = Remotes.Hatch:InvokeServer(selectedEgg, hatchMode)
		if pets then
			for _, pet in pets do
				HatchAnimation(selectedEgg, pet)
			end
		end
	end
end

local function AutoHatch()
	isAutoHatching = not isAutoHatching
	if not isAutoHatching then return end
	
	local character = Player.Character
	if not character then return end
	
	local primaryPart = character.PrimaryPart
	if not primaryPart then return end
	
	local startPosition = primaryPart.Position
	while isAutoHatching and selectedEgg do
		Hatch()
		
		local currentCharacter = Player.Character
		if not currentCharacter then return end

		local currentPrimaryPart = currentCharacter.PrimaryPart
		if not currentPrimaryPart then return end
		
		if (startPosition - currentPrimaryPart.Position).Magnitude > 5 then
			isAutoHatching =  false
			break
		end
		
		task.wait(0.5)
	end
	isAutoHatching = false
	
end

local function GetClosestEgg()
	local character = Player.Character
	if not character then return end
	
	local primaryPart = character.PrimaryPart
	if not primaryPart then return end
	
	for egg, model: Model in eggModels do
		local part = model.PrimaryPart
		local distanceBetween = (part.Position - primaryPart.Position).Magnitude
		if distanceBetween <= 10 then
			return egg
		end
	end
end

Buttons.x1.MouseButton1Click:Connect(function()
	Hatch(1)
end)

Buttons.x3.MouseButton1Click:Connect(function()
	local ownsGamepass = true
	if ownsGamepass then
		Hatch(3)
	end
end)

Buttons.Auto.MouseButton1Click:Connect(function()
	local ownsGamepass = true
	if ownsGamepass then
		AutoHatch()
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if not selectedEgg or processed then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		Hatch(1)
	elseif input.KeyCode == Enum.KeyCode.R then
		local ownsGamepass = true
		if ownsGamepass then
			Hatch(3)
		end
	elseif input.KeyCode == Enum.KeyCode.T then
		local ownsGamepass = true
		if ownsGamepass then
			AutoHatch()
		end
	end

end)

RunService.Stepped:Connect(function()
	local closestEgg = GetClosestEgg()
	if closestEgg and not isHatching then
		if closestEgg ~= selectedEgg then
			DisplayEgg(closestEgg)
		end
	else
		EggGui.Enabled = false
	end
	
	selectedEgg = closestEgg
end)

Remotes.HatchedChat.OnClientEvent:Connect(function(playerDisplayName: string, pet: string, hatchChance: number)
	local color = if hatchChance > 5 then Color3.fromRGB(15, 243, 255) else Color3.fromRGB(255, 0, 44)
	local text = `{playerDisplayName} hatched a {pet} with a {hatchChance}% chance!!!!!!!!!!`
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = text,
		Color = color
	})
end)