local tool = script.Parent
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local Shit1 = SoundService.Hit1
local Shit2 = SoundService.Hit2

local Attack = 1
local Debounce = false

tool.Activated:Connect(function()
	if not Debounce then
		Debounce = true
		local Humanoid = script.Parent.Parent:WaitForChild("Humanoid")
		if Player.inventory.EquippedSkin.Value == "MoonDevil" then
			local FastAnim1 = Humanoid:LoadAnimation(script.Parent.FastAttack1)
			local FastAnim2 = Humanoid:LoadAnimation(script.Parent.FastAttack2)
			if Attack == 1 then
				FastAnim1:Play()
				Shit1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				wait(0.3)
				Debounce = false
			elseif Attack == 2 then
				Shit2:Play()
				FastAnim2:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				wait(0.4)
				Debounce = false
			end
		elseif Player.inventory.EquippedSkin.Value == "RageMoonDevil" then
			local FastAnim1 = Humanoid:LoadAnimation(script.Parent.FastAttack1)
			local FastAnim2 = Humanoid:LoadAnimation(script.Parent.FastAttack2)
			if Attack == 1 then
				FastAnim1:Play()
				Shit1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				wait(0.2)
				Debounce = false
			elseif Attack == 2 then
				Shit2:Play()
				FastAnim2:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				wait(0.1)
				Debounce = false
			end
		elseif Player.inventory.EquippedSkin.Value == "Chosen" then
			local FastAnim1 = Humanoid:LoadAnimation(script.Parent.FastAttack1)
			local FastAnim2 = Humanoid:LoadAnimation(script.Parent.FastAttack2)
			if Attack == 1 then
				FastAnim1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				wait(0.08)
				Debounce = false
			elseif Attack == 2 then
				FastAnim2:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				wait(0.08)
				Debounce = false
			end
		elseif Player.inventory.EquippedSkin.Value == "DIO" then
			local FastAnim1 = Humanoid:LoadAnimation(script.Parent.FastAttack1)
			local FastAnim2 = Humanoid:LoadAnimation(script.Parent.FastAttack2)
			if Attack == 1 then
				FastAnim1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				wait(0.03)
				Debounce = false
			elseif Attack == 2 then
				FastAnim2:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				wait(0.02)
				Debounce = false
			end
		elseif Player.inventory.EquippedSkin.Value == "Konoboyashi" then
			local FastAnim1 = Humanoid:LoadAnimation(script.Parent.FastAttack1)
			local FastAnim2 = Humanoid:LoadAnimation(script.Parent.FastAttack2)
			local FastAnim3 = Humanoid:LoadAnimation(script.Parent.FastAttack3)
			if Attack == 1 then
				FastAnim1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				Debounce = false
			elseif Attack == 2 then
				FastAnim2:Play()
				Attack = 3
				Remotes.ToolActivated:FireServer()
				Debounce = false
			elseif Attack == 3 then
				FastAnim3:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				Debounce = false
			end
		elseif Player.inventory.EquippedSkin.Value == "Reaper" then
			local FastAnim1 = Humanoid:LoadAnimation(script.Parent.FastAttack1)
			local FastAnim2 = Humanoid:LoadAnimation(script.Parent.FastAttack2)
			if Attack == 1 then
				FastAnim1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				Debounce = false
			elseif Attack == 2 then
				FastAnim2:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				Debounce = false
			end
		elseif Player.inventory.EquippedSkin.Value == "GuardianAngel" then
			local FastAnim1 = Humanoid:LoadAnimation(script.Parent.FastAttack1)
			local FastAnim2 = Humanoid:LoadAnimation(script.Parent.FastAttack2)
			if Attack == 1 then
				FastAnim1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				Debounce = false
			elseif Attack == 2 then
				FastAnim2:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				Debounce = false
			end
		else
			local Anim1 = Humanoid:LoadAnimation(script.Parent.Attack1)
			local Anim2 = Humanoid:LoadAnimation(script.Parent.Attack2)
			if Attack == 1 then
				Anim1:Play()
				Shit1:Play()
				Attack = 2
				Remotes.ToolActivated:FireServer()
				wait(0.6)
				Debounce = false
			elseif Attack == 2 then
				Shit2:Play()
				Anim2:Play()
				Attack = 1
				Remotes.ToolActivated:FireServer()
				wait(0.8)
				Debounce = false
			end
		end
	end

end)

tool.Equipped:Connect(function()
	if not Debounce then
		Debounce = true
		local Humanoid = script.Parent.Parent:WaitForChild("Humanoid")
		local equip = Humanoid:LoadAnimation(script.Parent:FindFirstChild("Equipped"))
		if equip then
			SoundService.EquipTool:Play()
			equip:Play()
			wait(0.2)
			Debounce = false
		end
	end
end)

tool.Unequipped:Connect(function()
	local Unequip = ReplicatedStorage.Unequip:Clone()
	Unequip.Parent = Player.Character.RightHand
	wait(0.65)
	Player.Character.RightHand.Unequip:Destroy()

	
end)









