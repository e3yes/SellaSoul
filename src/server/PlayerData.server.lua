local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Manager = require(ServerScriptService.Manager)
local ProfileManager = require(ServerScriptService.ProfileService.Manager)
local Utils = require(ServerScriptService.Utils.Utils)
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local skinModels = ReplicatedStorage.SkinModels
local StarterPlayer = game:GetService("StarterPlayer")
local Player = Players.LocalPlayer

local toolConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("ToolConfig"))
local rankConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("RankConfig"))
local skinConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("SkinConfig"))
local wingsConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("WingsConfig"))
local upgradesConfig = require(ReplicatedStorage.Config.UpgradesConfig)
local gamepassConfig = require(ReplicatedStorage.Config.GamepassConfig).Passes
local codesConfig = require(ReplicatedStorage.Config.Codes)
local Utils = require(ServerScriptService.Utils.Utils)

local dataStore = DataStoreService:GetDataStore("Start1.0")


local function waitForRequestBudget(requestType)
	local currentBudget = DataStoreService:GetRequestBudgetForRequestType(requestType)
	while currentBudget < 1 do
		currentBudget = DataStoreService:GetRequestBudgetForRequestType(requestType)
		task.wait(5)
	end
end

local function setupPlayerData(player: player)
	local userID = player.UserId
	local key = "Player_"..userID

	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"

	local essence = Instance.new("NumberValue", leaderstats)
	essence.Name = "Essence"
	essence.Value = 0

	local soul = Instance.new("NumberValue", leaderstats)
	soul.Name = "Soul"
	soul.Value = 0
	
	local rank = Instance.new("StringValue", leaderstats)
	rank.Name = "Rank"
	rank.Value = "Newbie"
	
	local strength = Instance.new("NumberValue", leaderstats)
	strength.Name = "Strength"
	strength.Value = 0
	

	local inventoryFolder = Instance.new("Folder", player)
	inventoryFolder.Name = "inventory"


	local equippedTool = Instance.new("StringValue", inventoryFolder)
	equippedTool.Name = "EquippedTool"
	equippedTool.Value = "1947Sword"


	local ownedToolsFolder = Instance.new("Folder", inventoryFolder)
	ownedToolsFolder.Name = "OwnedTools"

	for _, toolTable in ipairs(toolConfig) do
		local toolBoolean = Instance.new("BoolValue", ownedToolsFolder)
		toolBoolean.Name = toolTable.ID
		if toolTable.ID == "1947Sword" then
			toolBoolean.Value = true
		else 
			toolBoolean.Value = false
		end

	end
	
	--local ownedUpgradesFolder = Instance.new("Folder", inventoryFolder)
	--ownedUpgradesFolder.Name = "OwnedUpgrades"
	
	--for _, toolTable in ipairs(upgradesConfig) do
	--	local toolBoolean = Instance.new("BoolValue", ownedUpgradesFolder)
	--	toolBoolean.Name = toolTable.ID
	--	if toolTable.ID == "Weakness" then
	--		toolBoolean.Value = true
	--	else 
	--		toolBoolean.Value = false
	--	end

	--end
	
	local equippedRank = Instance.new("StringValue", inventoryFolder)
	equippedRank.Name = "EquippedRank"
	equippedRank.Value = "Newbie"
	
	local ownedRanksFolder = Instance.new("Folder", inventoryFolder)
	ownedRanksFolder.Name = "OwnedRanks"

	for _, rankTable in ipairs(rankConfig) do
		local rankBoolean = Instance.new("BoolValue", ownedRanksFolder)
		rankBoolean.Name = rankTable.ID
		if rankTable.ID == "Newbie" then
			rankBoolean.Value = true
		end
	end
	
	local equippedSkin = Instance.new("StringValue", inventoryFolder)
	equippedSkin.Name = "EquippedSkin"
	equippedSkin.Value = "Soulless"


	local ownedSkinsFolder = Instance.new("Folder", inventoryFolder)
	ownedSkinsFolder.Name = "OwnedSkins"

	for _, skinTable in ipairs(skinConfig) do
		local skinBoolean = Instance.new("BoolValue", ownedSkinsFolder)
		skinBoolean.Name = skinTable.ID
		if skinTable.ID == "Soulless" then
			skinBoolean.Value = true
		else 
			skinBoolean.Value = false
		end

	end
	
	local equippedWings = Instance.new("StringValue", inventoryFolder)
	equippedWings.Name = "EquippedWings"
	equippedWings.Value = "Nothing"


	local ownedWingsFolder = Instance.new("Folder", inventoryFolder)
	ownedWingsFolder.Name = "OwnedWings"

	for _, wingsTable in ipairs(wingsConfig) do
		local wingsBoolean = Instance.new("BoolValue", ownedWingsFolder)
		wingsBoolean.Name = wingsTable.ID
		if wingsTable.ID == "Soulless" then
			wingsBoolean.Value = true
		else 
			wingsBoolean.Value = false
		end

	end
	
	local timeInventory = Instance.new("Folder", player)
	timeInventory.Name = "timeInventory"
	
	local times = Instance.new("NumberValue", timeInventory)
	times.Name = "Times"
	times.Value = 0
	
	local locationInventory = Instance.new("Folder", player)
	locationInventory.Name = "locationInventory"
	
	local multiplier = Instance.new("NumberValue", locationInventory)
	multiplier.Name = "Multiplier"
	multiplier.Value = 1
	
	local codesFolder = Instance.new("Folder", player)
	codesFolder.Name = "codes"
	
	for code, reward in pairs(codesConfig) do
		local codeInstance = Instance.new("BoolValue", codesFolder)
		codeInstance.Name = code
	end
	
	local gamepasses = Instance.new("Folder", player)
	gamepasses.Name = "gamepasses"
	
	for _, config in ipairs(gamepassConfig) do
		local passBool = Instance.new("BoolValue", gamepasses)
		passBool.Name = config.ID
	end
	
	
	local success, returnValue
	repeat
		waitForRequestBudget(Enum.DataStoreRequestType.GetAsync)
		success, returnValue = pcall(dataStore.GetAsync, dataStore, key)
	until success or not Players:FindFirstChild(player.Name)	

	if success then
		if returnValue ~= nil then
		player.leaderstats.Essence.Value = if returnValue.Essence ~= nil then returnValue.Essence else 0
		player.leaderstats.Soul.Value = if returnValue.Soul ~= nil then returnValue.Soul else 0
		player.leaderstats.Strength.Value = if returnValue.Strength ~= nil then returnValue.Strength else 0
		player.leaderstats.Rank.Value = if returnValue.Rank ~= nil then returnValue.Rank else "Newbie"
		player.timeInventory.Times.Value = if returnValue.Times ~= nil then returnValue.Times else 0
		player.locationInventory.Multiplier.Value = if returnValue.Multiplier ~= nil then returnValue.Multiplier else 1
			
			player.inventory.EquippedTool.Value = if returnValue.Inventory.EquippedTool ~= nil then returnValue.Inventory.EquippedTool else "1947Sword"
		
		for _, tool in ipairs(player.inventory.OwnedTools:GetChildren()) do
			tool.Value = if returnValue.Inventory.OwnedTools[tool.Name] ~= nil then returnValue.Inventory.OwnedTools[tool.Name] else false
		end
			
		--for _, upgrade in ipairs(player.inventory.OwnedUpgrades:GetChildren()) do
		--		upgrade.Value = if returnValue.Inventory.OwnedUpgrades[upgrade.Name] ~= nil then returnValue.Inventory.OwnedUpgrades[upgrade.Name] else false
		--end
		
		player.inventory.EquippedRank.Value = if returnValue.Inventory.EquippedRank ~= nil then returnValue.Inventory.EquippedRank else "Newbie"
		
		if returnValue.Inventory.OwnedRanks then
			for _, rank in ipairs(player.inventory.OwnedRanks:GetChildren()) do
				rank.Value = if returnValue.Inventory.OwnedRanks[rank.Name] ~= nil then returnValue.Inventory.OwnedRanks[rank.Name] else false
			end
		end
			
		player.inventory.EquippedSkin.Value = if returnValue.Inventory.EquippedSkin ~= nil then returnValue.Inventory.EquippedSkin else "Soulless"

		if returnValue.Inventory.OwnedSkins then
			for _, skin in ipairs(player.inventory.OwnedSkins:GetChildren()) do
				skin.Value = if returnValue.Inventory.OwnedSkins[skin.Name] ~= nil then returnValue.Inventory.OwnedSkins[skin.Name] else false
			end
		end
			
		player.inventory.EquippedWings.Value = if returnValue.Inventory.EquippedWings ~= nil then returnValue.Inventory.EquippedWings else "Nothing"
			
		if returnValue.Inventory.OwnedWings then
			for _, wings in ipairs(player.inventory.OwnedWings:GetChildren()) do
				wings.Value = if returnValue.Inventory.OwnedWings[wings.Name] ~= nil then returnValue.Inventory.OwnedWings[wings.Name] else false
			end
		end

			
			if returnValue.Codes then
				for _, code in ipairs(codesFolder:GetChildren()) do
					code.Value = if returnValue.Codes[code.Name] ~= nil then returnValue.Codes[code.Name] else false
				end
			end 
			
			if returnValue.Gamepasses then 
				for _, pass in ipairs(gamepasses:GetChildren()) do
					pass.Value = if returnValue.Gamepasses[pass.Name] ~= nil then returnValue.Gamepasses[pass.Name] else false
				end
			end
			
	end		
		
	else
		player:Kick("Error loading Data")
		print(player.Name.."Data Error")
	end

	Utils.getItems(player)
	
end

local function save(player)
	local userID = player.UserId
	local key = "Player_"..userID
	
	local essence = player.leaderstats.Essence.Value
	local soul = player.leaderstats.Soul.Value
	local rank = player.leaderstats.Rank.Value
	local equippedTool = player.inventory.EquippedTool.Value
	local equippedRank = player.inventory.EquippedRank.Value
	local equippedSkin = player.inventory.EquippedSkin.Value
	local equippedWings = player.inventory.EquippedWings.Value
	local strength = player.leaderstats.Strength.Value
	local times = player.timeInventory.Times.Value
	local multiplier = player.locationInventory.Multiplier.Value
	
	
	local ownedToolsTable = {}

	for _, tool in ipairs(player.inventory.OwnedTools:GetChildren()) do
		ownedToolsTable[tool.Name] = tool.Value
	end
	
	--local ownedUpgradesTable = {}
	
	--for _, upgrade in ipairs(player.inventory.OwnedUpgrades:GetChildren()) do
	--	ownedUpgradesTable[upgrade.Name] = upgrade.Value
	--end

	local ownedRanksTable = {}

	for _, rank in ipairs(player.inventory.OwnedRanks:GetChildren()) do
		ownedRanksTable[rank.Name] = rank.Value
	end
	
	local ownedSkinsTable = {}

	for _, skin in ipairs(player.inventory.OwnedSkins:GetChildren()) do
		ownedSkinsTable[skin.Name] = skin.Value
	end
	
	local ownedWingsTable = {}

	for _, wings in ipairs(player.inventory.OwnedWings:GetChildren()) do
		ownedWingsTable[wings.Name] = wings.Value
	end

	
	local timeInventory = {}
	local locationInventory = {}
	
	local codes = {}
	for _, code in  ipairs(player.codes:GetChildren()) do
		codes[code.Name] = code.Value
	end
	
	local gamepasses = {}
	for _, pass in ipairs(player.gamepasses:GetChildren()) do
		gamepasses[pass.Name] = pass.Value
	end
	
	local dataTable = {
		Essence = essence,
		Soul = soul,
		Rank = rank,
		Strength = strength,
		Inventory = {
			EquippedTool = equippedTool,
			OwnedTools = ownedToolsTable,
			EquippedRank = equippedRank,
			OwnedRanks = ownedRanksTable,
			EquippedSkin = equippedSkin,
			OwnedSkins = ownedSkinsTable,
			EquippedWings = equippedWings,
			OwnedWings = ownedWingsTable,
			--OwnedUpgrades = ownedUpgradesTable
		},
		TimeInventory = timeInventory,
		Times = times,
		LocationInventory = locationInventory,
		Multiplier = multiplier,
		Codes = codes,
		Gamepasses = gamepasses,
	} 
	
	local success, returnValue
	repeat
		waitForRequestBudget(Enum.DataStoreRequestType.UpdateAsync)
		success, returnValue = pcall(dataStore.UpdateAsync, dataStore, key, function()
			return dataTable
		end)
	until success
	
	if success then
		print("Data Saved")
	else
		print("Data Save Error")
	end
	
end

local function onShutDown()
	if RunService:IsStudio() then
		task.wait(2)
	else
		local finished = Instance.new("BindableEvent")
		local allPlayers = Players:GetPlayers()
		local leftPlayers = #allPlayers
		
		for _, player in ipairs(allPlayers) do
			coroutine.wrap(function()
				save(player)
				leftPlayers -= 1
				if leftPlayers == 0 then
					finished:Fire()
				end
			end) ()
		end
		finished.Event:Wait()
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	coroutine.wrap(setupPlayerData)(player)
end


Players.PlayerAdded:Connect(setupPlayerData)
Players.PlayerRemoving:Connect(save)
game:BindToClose(onShutDown)

while true do
	task.wait(600)
	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(save)(player)
	end
end