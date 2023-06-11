local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = ReplicatedStorage.Remotes
local Pets = require(ServerScriptService.Pets)
local PlayerData = require(ServerScriptService.ProfileService.Manager)

local Cooldown = {}

local CLICK_COOLDOWN = 0.5

local function Click(player: Player)
	if table.find(Cooldown, player) then return end
	
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	table.insert(Cooldown, player)
	task.delay(CLICK_COOLDOWN, function()
		local foundPlayer = table.find(Cooldown, player)
		if foundPlayer then
			table.remove(Cooldown, foundPlayer)
		end
	end)
	
	Pets.GivePetXP(player)
end


Remotes.Click.OnServerEvent:Connect(Click)

