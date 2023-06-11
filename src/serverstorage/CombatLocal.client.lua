local tool = script.Parent
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local safeZonePart = workspace:FindFirstChild("SafeZone")

local debounceAttack = false

local attackEvent = ReplicatedStorage.Remotes.Attacked
local safeZoneCheckEvent = ReplicatedStorage.Remotes.SafeZoneCheck
local updateSafeStateEvent = ReplicatedStorage.Remotes.UpdateSafeState
local updateHealth = ReplicatedStorage.Remotes.UpdateHealthBar

local function isInSafeZone(player)
	local isSafe = safeZoneCheckEvent:InvokeServer(player)
	return isSafe
end

local function onTouched(part)
	local Character = script.Parent
	
	local Player = game.Players:GetPlayerFromCharacter(Character)
	
	local character = part.Parent
	if character == Character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	local player = game.Players:GetPlayerFromCharacter(character)
	tool.Activated:Connect(function()
		if not debounceAttack then
			debounceAttack = true
			if not isInSafeZone(player) then
				local damage = math.random(10,50)
				attackEvent:FireServer(humanoid, Player, damage)
			else
				print("IsSafe")
			end
			wait(1)
			debounceAttack = false
		end
	end)

end

local function updateSafeTextVisibility(character, isVisible)
	local billboardGui = character.HumanoidRootPart:FindFirstChild("PlayerTop")
	if billboardGui then
		local safeText = billboardGui:FindFirstChild("Frame"):FindFirstChild("Safe")
		if safeText then
			safeText.Visible = isVisible
		end
	end
end

updateSafeStateEvent.OnClientEvent:Connect(function(player, character, isSafe)
    if player == game.Players.LocalPlayer then
        updateSafeTextVisibility(character, isSafe)
	end
	if isSafe then
		updateSafeTextVisibility(character, true)
	else
		updateSafeTextVisibility(character, false)
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		updateSafeTextVisibility(character, isInSafeZone(player))
	end)
end)


tool.Hitbox.Touched:Connect(onTouched)

--character рот ебал , это и есть damage 

attackEvent.OnClientEvent:Connect(function(player, character, damage)
	local DamageGui = ReplicatedStorage:FindFirstChild("Damage"):Clone()
	local textLabel = DamageGui.TextLabel
	DamageGui.Parent = player
	textLabel.Text = if character == "Safe" then "Safe" else character
	textLabel.TextColor3 = if character ~= "Safe" then Color3.new(1, 0, 0) else Color3.new(0.215686, 1, 0)
	local TweenService = game:GetService("TweenService")
	local duration = 0.7

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

	textLabel.TextTransparency = 1

	local tweenIn = TweenService:Create(textLabel, tweenInfo, {
		TextTransparency = 0
	})

	local tweenOut = TweenService:Create(textLabel, tweenInfo, {
		TextTransparency = 1
	})
	tweenIn:Play()
	wait(duration)
	tweenOut:Play()
	wait(0.4)
	DamageGui:Destroy()
end)

script.Parent.Parent.Parent.CharacterAdded:Wait().Humanoid.Health.Changed:Connect(function()
	print(script.Parent.Parent.Parent)
	updateHealth:FireServer()
end)
