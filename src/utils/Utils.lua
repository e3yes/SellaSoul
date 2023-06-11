local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local SkinShopServer = ServerScriptService.SkinShopServer
--local Manager = require(ServerScriptService.Manager)
local skinModels = ReplicatedStorage.SkinModels
local rankConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("RankConfig"))
local skinConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("SkinConfig"))
local wingsConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("WingsConfig"))
local toolConfig = require(ReplicatedStorage.Config.ToolConfig)
local DEFAULT_HEALTH = 100
local DEFAULT_SPEED = 16
local WingsFolder = ServerStorage.Wings
local AuraFolder = ServerStorage.RankAura
local GuiTemplate = ReplicatedStorage.PlayerTop


local Utils = {}


local function GetRankColor(rank: string)
	local color
	
	if rank == "Ninja" then
		color = Color3.new(0, 0.129412, 0.407843)
	elseif rank == "Sensei" then
		color = Color3.new(0, 1, 0.933333)
	elseif rank == "MasterSensei" then
		color = Color3.new(0.615686, 0, 1)
	elseif rank == "Demon" then
		color = Color3.new(0.603922, 0, 0)
	elseif rank == "CursedDemon" then
		color = Color3.new(0.1, 0, 0)
	elseif rank == "MadSpirit" then
		color = Color3.new(0, 0.517647, 1)
	elseif rank == "Lost" then
		color = Color3.new(0, 0, 0)
	elseif rank == "MysteriousCreature" then
		color = Color3.new(0.933333, 0, 1)
	elseif rank == "Absolute" then
		color = Color3.new(0.984314, 1, 0)
	elseif rank == "Godlike" then
		color = Color3.new(1, 1, 1)
	else 
		color = Color3.new(0, 1, 0.117647)
	end

	return color

end

local function GetRankTextColor(rank: string)
	local color
	
	if rank == "Ninja" then
		color = Color3.new(0, 0, 0)
	elseif rank == "Sensei" then
		color = Color3.new(0, 0, 0)
	elseif rank == "MasterSensei" then
		color = Color3.new(0, 0, 0)
	elseif rank == "Demon" then
		color = Color3.new(0, 0, 0)
	elseif rank == "CursedDemon" then
		color = Color3.new(1, 0, 0)
	elseif rank == "MadSpirit" then
		color = Color3.new(1, 1, 1)
	elseif rank == "Lost" then
		color = Color3.new(0, 0.0745098, 0.117647)
	elseif rank == "MysteriousCreature" then
		color = Color3.new(0, 0.184314, 1)
	elseif rank == "Absolute" then
		color = Color3.new(0, 0, 0)
	elseif rank == "Godlike" then
		color = Color3.new(0, 0, 0)
	else 
		color = Color3.new(0, 0, 0)
	end

	return color

end


function Utils.PlayerTop(player: Player)
	if player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("PlayerTop") then
		player.Character.HumanoidRootPart.PlayerTop:Destroy()
		local gui = GuiTemplate:Clone()
		gui.Parent = player.Character:FindFirstChild("HumanoidRootPart")
		gui.Frame.PlayerName.Text = player.Name
		gui.Frame.Rank.TextColor3 = GetRankColor(player.inventory.EquippedRank.Value)
		gui.Frame.Rank.TextStrokeColor3 = GetRankTextColor(player.inventory.EquippedRank.Value)
		gui.Frame.Rank.Text = player.inventory.EquippedRank.Value
	else
		local gui = GuiTemplate:Clone()
		gui.Parent = player.Character:FindFirstChild("HumanoidRootPart")
		gui.Frame.PlayerName.Text = player.Name
		gui.Frame.Rank.TextColor3 = GetRankColor(player.inventory.EquippedRank.Value)
		gui.Frame.Rank.TextStrokeColor3 = GetRankTextColor(player.inventory.EquippedRank.Value)
		gui.Frame.Rank.Text = player.inventory.EquippedRank.Value
	end
end


function Utils.getItems(player: Player)
	local tool = player.inventory.EquippedTool.Value
	repeat task.wait() until player.Character
	local toolClone = ServerStorage:FindFirstChild("Tools"):FindFirstChild(tool):Clone()
	toolClone.Parent = player:FindFirstChild("Backpack")
	
	local character = player.Character
	character.Archivable = true
	character:FindFirstChild("ForceField"):Destroy()
	local ParticleEmitter = ServerStorage.RankAura.ParticleEmitter:Clone()
	ParticleEmitter.Parent = character:FindFirstChild("UpperTorso")
	
	if skinModels:FindFirstChild("Soulless") then
		skinModels:FindFirstChild("Soulless"):Destroy()
		local characterClone = character:Clone()
		characterClone.Name = "Soulless"
		characterClone.Parent = skinModels
	else
		local characterClone = character:Clone()
		characterClone.Name = "Soulless"
		characterClone.Parent = skinModels
	end
	
	character.Archivable = false
	Utils.equipSkin(player)
	Utils.equipRank(player)
	Utils.equipWings(player)
	Utils.PlayerTop(player)
end


function Utils.getWeapon(player: Player)
	local tool = player.inventory.EquippedTool.Value
	repeat task.wait() until player.Character
	local toolClone = ServerStorage:FindFirstChild("Tools"):FindFirstChild(tool):Clone()
	toolClone.Parent = player:FindFirstChild("Backpack")
end


function Utils.getItem(itemName: string, shop: string)
	local list = if shop == "Rank" then rankConfig elseif shop == "Wings" then wingsConfig elseif shop == "Essence" then toolConfig else skinConfig

	for _, toolTable in ipairs(list) do
		if itemName == toolTable.ID then
			return toolTable.ID, toolTable
		end
	end
end


function Utils.equipWings(player: Player)
	local wings = player.inventory.EquippedWings.Value
	local humanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
	if humanoid then
		local _, toolTableWings = Utils.getItem(wings, "Wings")
		local multiplier = toolTableWings.Speed
		humanoid.WalkSpeed = multiplier + DEFAULT_SPEED
	end
	
	for _, accessory in ipairs(WingsFolder:GetChildren()) do
		if wings == accessory.Name then
			for i, char in pairs(player.Character:GetChildren()) do
				if char:IsA("Accessory") then
					if char.Handle:FindFirstChild("BodyBackAttachment") then
							char:Destroy()
					end
				end
			end
			humanoid:AddAccessory(accessory:Clone())
			
		end
	end
	
end

function Utils.equipSkin(player: Player)
	local skin = player.inventory.EquippedSkin.Value
	local wings = player.inventory.EquippedWings.Value
	local rank = player.inventory.EquippedRank.Value
	local _, toolTable = Utils.getItem(rank, "Rank")
	local _, toolTableSkin = Utils.getItem(skin, "Skin")
	local _, toolTableWings = Utils.getItem(wings, "Wings")
	
	for _, model in ipairs(skinModels:GetChildren()) do
		if model.Name == skin then
			local oldCharacter = player.Character
			local newCharacter = model:Clone()
			----
			newCharacter.HumanoidRootPart.Anchored = false
			newCharacter:SetPrimaryPartCFrame(oldCharacter.PrimaryPart.CFrame)
			newCharacter.Name = player.Name
			----
			player.Character = newCharacter
			
			newCharacter.Parent = workspace
			----Tool----
			local tool = player.inventory.EquippedTool.Value
			repeat task.wait() until player.Character
			local toolClone = ServerStorage:FindFirstChild("Tools"):FindFirstChild(tool):Clone()
			toolClone.Parent = player:FindFirstChild("Backpack")
			----Tool--
			
			----Health----
			local humanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				local multiplier = toolTable.Stat
				local speed = toolTableWings.Speed
				local health = toolTableSkin.Health
				humanoid.MaxHealth = health
				humanoid.Health = humanoid.MaxHealth
				humanoid.WalkSpeed = speed + DEFAULT_SPEED
			end
			----Health----
			----Wings-----
			for _, accessory in ipairs(WingsFolder:GetChildren()) do
				if wings == accessory.Name then
					for i, char in pairs(player.Character:GetChildren()) do
						if char:IsA("Accessory") then
							if char.Handle:FindFirstChild("BodyBackAttachment") then
								char:Destroy()
							end
						end
					end
					humanoid:AddAccessory(accessory:Clone())

				end
			end
			
			---Wings----
			
			----Rank----
			for _, aura in ipairs(AuraFolder:GetChildren()) do
				if aura.Name == rank then
					if player.Character:FindFirstChild("UpperTorso") then
						for _, particle in ipairs(player.Character:FindFirstChild("UpperTorso"):GetDescendants()) do
							if particle:IsA("ParticleEmitter") then
								particle:Destroy()
							end
						end
						for _, newParticle in ipairs(aura:Clone():GetDescendants()) do
							newParticle.Parent = player.Character:FindFirstChild("UpperTorso")
						end
					end
				end
			end
		end
		Utils.PlayerTop(player)
	end	
end

function Utils.equipRank(player: Player)
	
	local skin = player.inventory.EquippedSkin.Value
	local rank = player.inventory.EquippedRank.Value
	local _, toolTable = Utils.getItem(rank, "Rank")
	Utils.PlayerTop(player)
	local humanoid: Humanoid = player.Character:FindFirstChild("Humanoid")
	for _, aura in ipairs(AuraFolder:GetChildren()) do
		if aura.Name == rank then
			if player.Character:FindFirstChild("UpperTorso") then
				for _, particle in ipairs(player.Character:FindFirstChild("UpperTorso"):GetDescendants()) do
					if particle:IsA("ParticleEmitter") then
						particle:Destroy()
					end
				end
				for _, newParticle in ipairs(aura:Clone():GetDescendants()) do
					newParticle.Parent = player.Character:FindFirstChild("UpperTorso")
				end
			end
		end
	end
	
end


return Utils
