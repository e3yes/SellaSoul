local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
local id = 737746186

if Player.UserId == id then
	Cmdr:SetActivationKeys({Enum.KeyCode.F2})
else
	Cmdr:SetActivationKeys({})
end
