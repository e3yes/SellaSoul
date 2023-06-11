local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Rewards = require(ServerScriptService.Utils.Rewards)
local Remotes = ReplicatedStorage.Remotes
local Manager = require(ServerScriptService.Manager)
local Stats = require(ServerScriptService.Utils.Stats)

local scribtableObjectsFolder = workspace:FindFirstChild("scritableObjects")

debounce = false


scribtableObjectsFolder.ShopOpen.ShopOpen.Touched:Connect(function(part)
	local player = Players:GetPlayerFromCharacter(part.Parent)
	if player then
		if not debounce then
			debounce = true
			Remotes.Shop.ShopOpen:FireClient(player)
			wait(1)
			debounce = false
		end
	end
end)

scribtableObjectsFolder.RankOpen.RankOpen.Touched:Connect(function(part)
	local player = Players:GetPlayerFromCharacter(part.Parent)
	if player then
		if not debounce then
			debounce = true
			Remotes.Shop.RankShopOpen:FireClient(player)
			wait(1)
			debounce = false
		end
	end
end)

scribtableObjectsFolder.SkinOpen.SkinOpen.Touched:Connect(function(part)
	local player = Players:GetPlayerFromCharacter(part.Parent)
	if player then
		if not debounce then
			debounce = true
			Remotes.Shop.SkinShopOpen:FireClient(player)
			wait(1)
			debounce = false
		end
	end
end)

scribtableObjectsFolder.WingsOpen.WingsOpen.Touched:Connect(function(part)
	local player = Players:GetPlayerFromCharacter(part.Parent)
	if player then
		if not debounce then
			debounce = true
			Remotes.Shop.WingsShopOpen:FireClient(player)
			wait(1)
			debounce = false
		end
	end
end)


scribtableObjectsFolder.Sell.Sell.Touched:Connect(function(part)
	local player = Players:GetPlayerFromCharacter(part.Parent)
	if player then
		if not debounce then
			debounce = true
			local essence = player.leaderstats.Essence.Value
			if essence > 0 then
				Manager.SellEssence(player, essence, true)
				player.leaderstats.Essence.Value = 0
				print("Sell" , essence)
			end
			wait(1)
			debounce = false
		end
	end
end)




