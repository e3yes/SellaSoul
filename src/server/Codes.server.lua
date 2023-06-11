local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = ReplicatedStorage.Remotes
local Codes = require(ReplicatedStorage.Config.Codes)
local Reward = require(ServerScriptService.Utils.Rewards)

local function RedeemCode(player: Player, code: string)
	if not Codes[code] then
		return "Does not exist"
	end
	
	if player.codes[code].Value then
		return "Already Redeemed"
	end
	
	player.codes[code].Value = true
	player.leaderstats.Soul.Value += Codes[code]
	return "Redeemed"
end

Remotes.RedeemCode.OnServerInvoke = RedeemCode
