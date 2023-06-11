local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local ServerStorage = game:GetService("ServerStorage")
local tools = ServerStorage.Tools
local scripts = ServerStorage.Scripts
local toolConfig = require(ReplicatedStorage:FindFirstChild("Config"):FindFirstChild("ToolConfig"))
local Stats = require(ServerScriptService.Utils.Stats)
local Rewards = require(ServerScriptService.Utils.Rewards)
local animations = ServerStorage.Animations

Remotes.ToolActivated.OnServerEvent:Connect(function(player: Player)
		Rewards.Essence(player, Stats.Essence(player))
		Rewards.Strength(player, Stats.Strength(player))
end)

for _, tool in ipairs(tools:GetChildren()) do
	local script = scripts.Click:Clone()
	script.Parent = tool

	local combatscript = scripts.CombatLocal:Clone()
	combatscript.Parent = tool

	local anim1 = animations.Attack1:Clone()
	local anim2 = animations.Attack2:Clone()
	anim1.Parent = tool
	anim2.Parent = tool
	
	local fastAttack1 = animations.FastAttack1:Clone()
	local fastAttack2 = animations.FastAttack2:Clone()
	local fastAttack3 = animations.FastAttack3:Clone()
	fastAttack1.Parent = tool
	fastAttack2.Parent = tool
	fastAttack3.Parent = tool

	
	local equipped = animations.Equipped:Clone()
	equipped.Parent = tool
end


