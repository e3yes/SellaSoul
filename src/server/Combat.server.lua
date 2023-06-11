local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackEvent = ReplicatedStorage.Remotes.Attacked
local SafeZoneCheckEvent = ReplicatedStorage.Remotes.SafeZoneCheck
local ServerScriptService = game:GetService("ServerScriptService")
local safeZone = workspace.SafeZone
local safeZoneHell = workspace.Islands.Hell.SafeZoneHell
local safeZoneSmallHeaven = workspace.Islands.SmallHeaven.SafeZoneSmallHeaven
local Utils = require(ServerScriptService.Utils.Utils)
local updateSafeStateEvent = ReplicatedStorage.Remotes.UpdateSafeState
local updateHealthBar = ReplicatedStorage.Remotes.UpdateHealthBar

local function updatePlayerSafeState(character, isSafe)
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		updateSafeStateEvent:FireAllClients(player, character, isSafe)
	end
end

local playersInSafeZone = {}



local function checkPlayerInSafeZone(character)
	return playersInSafeZone[character] == true
end


local function onSafeZoneTouched(hit)
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	if player and character:FindFirstChild("Humanoid") then
		playersInSafeZone[character] = true
	end
end

local function onSafeZoneTouchEnded(hit)
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)

	if player and character:FindFirstChild("Humanoid") then
		playersInSafeZone[character] = false
	end
end


safeZone.Touched:Connect(function(hit)
	onSafeZoneTouched(hit)
	updatePlayerSafeState(hit.Parent, true)
end)
safeZone.TouchEnded:Connect(function(hit)
	onSafeZoneTouchEnded(hit)
	updatePlayerSafeState(hit.Parent, false)
end)
safeZoneHell.Touched:Connect(function(hit)
	onSafeZoneTouched(hit)
	updatePlayerSafeState(hit.Parent, true)
end)
safeZoneHell.TouchEnded:Connect(function(hit)
	onSafeZoneTouchEnded(hit)
	updatePlayerSafeState(hit.Parent, false)
end)
safeZoneSmallHeaven.Touched:Connect(function(hit)
	onSafeZoneTouched(hit)
	updatePlayerSafeState(hit.Parent, true)
end)
safeZoneSmallHeaven.TouchEnded:Connect(function(hit)
	onSafeZoneTouchEnded(hit)
	updatePlayerSafeState(hit.Parent, false)
end)

local function onAttack(humanoid, otherPlayer)
	local character = otherPlayer.Parent
	local damage = math.random(10,50)
	
	if not checkPlayerInSafeZone(character) then
		if otherPlayer.Health > 0 then
			otherPlayer:TakeDamage(damage)
		elseif otherPlayer.Health <= 0 then
			otherPlayer.Health = 0
		end
		attackEvent:FireAllClients(character, damage)
	else
		local SafeText = "Safe"
		attackEvent:FireAllClients(character, SafeText)
	end
end

attackEvent.OnServerEvent:Connect(onAttack)
SafeZoneCheckEvent.OnServerInvoke = checkPlayerInSafeZone

updateHealthBar.OnServerEvent:Connect(function(player: Player)
	Utils.PlayerTop(player)
end)

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:SetPrimaryPartCFrame(CFrame.new(workspace.SpawnLocation.Position+Vector3.new(0,3,0)))
		character.Humanoid.Died:Connect(function()
			player.CharacterAdded:Wait()
			Utils.getItems(player)
		end)
	end)
end)