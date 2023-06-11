local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AddEvent = ReplicatedStorage.Remotes.Zones.AddMultiplier
local RemoveEvent = ReplicatedStorage.Remotes.Zones.RemoveMultiplier
local player = game.Players.LocalPlayer
local debounce = false
local Garmony = workspace:WaitForChild("Garmony")
local Rage = workspace.Islands.Hell.Rage.Hitbox5xEssence
local Peacefulness = workspace.Islands.SmallHeaven.Peacefulness.Hitbox

Garmony.Touched:Connect(function(part)
	if not debounce then
		debounce = true
		local character = part.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			AddEvent:FireServer(Garmony.Name)
		end
	end
	
end)
Garmony.TouchEnded:Connect(function(part)
		debounce = false
		local character = part.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			RemoveEvent:FireServer(player)
		end
end)

Rage.Touched:Connect(function(part)
	if not debounce then
		debounce = true
		local character = part.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			AddEvent:FireServer(Rage.Parent.Name)
		end
	end

end)
Rage.TouchEnded:Connect(function(part)
	debounce = false
	local character = part.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		RemoveEvent:FireServer(player)
	end
end)

Peacefulness.Touched:Connect(function(part)
	if not debounce then
		debounce = true
		local character = part.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			AddEvent:FireServer(Peacefulness.Parent.Name)
		end
	end

end)
Peacefulness.TouchEnded:Connect(function(part)
	debounce = false
	local character = part.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		RemoveEvent:FireServer(player)
	end
end)

