local Player = game.Players.LocalPlayer
local Character = workspace:WaitForChild(Player.Name)
local Humanoid = Character:WaitForChild('Humanoid')

local ID = 13044787618 --with hands
local ID2 = 13205671970 --with weapon
local RunningSpeed = 6 --Running speed--
local NormalSpeed = 16  --Normal speed/walkspeed--
local FieldOfView = 100  --Field of view when running--
local key = "LeftShift"  --Sprint/Run key--


local RunAnimation = Instance.new('Animation')
RunAnimation.AnimationId = 'rbxassetid://'..ID
RAnimation = Humanoid:LoadAnimation(RunAnimation)

local RunAnimation2 = Instance.new('Animation')
RunAnimation2.AnimationId = 'rbxassetid://'..ID2
RAnimation2 = Humanoid:LoadAnimation(RunAnimation2)

Running = false


local mouse = Player:GetMouse()
local Info = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local Properties = {FieldOfView = FieldOfView}
local T = game:GetService("TweenService"):Create(game.Workspace.CurrentCamera, Info, Properties)
local rProperties = {FieldOfView = 70}
local rInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local rT = game:GetService("TweenService"):Create(game.Workspace.CurrentCamera, rInfo, rProperties)


function DefaultSpeed()
	local speed 
	if Player.inventory.EquippedWings.Value == "Nothing" then
		speed = NormalSpeed + 0
	elseif Player.inventory.EquippedWings.Value == "Skeleton" then
		speed = NormalSpeed + 3
	elseif Player.inventory.EquippedWings.Value == "HellSkeleton" then
		speed = NormalSpeed + 6
	elseif Player.inventory.EquippedWings.Value == "Fairy" then
		speed = NormalSpeed + 9
	elseif Player.inventory.EquippedWings.Value == "QueenFairy" then
		speed = NormalSpeed + 15
	elseif Player.inventory.EquippedWings.Value == "OneWingedDemon" then
		speed = NormalSpeed + 20
	elseif Player.inventory.EquippedWings.Value == "Demon" then
		speed = NormalSpeed + 25
	elseif Player.inventory.EquippedWings.Value == "Vampire" then
		speed = NormalSpeed + 28
	elseif Player.inventory.EquippedWings.Value == "Dracula" then
		speed = NormalSpeed + 32
	elseif Player.inventory.EquippedWings.Value == "Speedster" then
		speed = NormalSpeed + 38
	elseif Player.inventory.EquippedWings.Value == "UltraSpeedster" then
		speed = NormalSpeed + 45
	elseif Player.inventory.EquippedWings.Value == "Angel" then
		speed = NormalSpeed + 50
	elseif Player.inventory.EquippedWings.Value == "Archangel" then
		speed = NormalSpeed + 55
	end
	return speed
end


function Handler(BindName, InputState)
	if InputState == Enum.UserInputState.Begin and BindName == 'RunBind' then
		Running = true
		Humanoid.WalkSpeed += RunningSpeed
		T:Play()
	elseif InputState == Enum.UserInputState.End and BindName == 'RunBind' then
		Running = false
		if RAnimation.IsPlaying then
			RAnimation:Stop()
		end
		if RAnimation2.IsPlaying then
			RAnimation2:Stop()
		end
		Humanoid.WalkSpeed = DefaultSpeed()
		rT:Play()
	end
end


Humanoid.Running:connect(function(Speed)
	if Player.Backpack:FindFirstChildOfClass("Tool") then
		if Speed >= 10 and Running and not RAnimation.IsPlaying then
			RAnimation:Play()
			Humanoid.WalkSpeed += RunningSpeed
		elseif Speed >= 10 and not Running and RAnimation.IsPlaying then
			RAnimation:Stop()
			Humanoid.WalkSpeed = DefaultSpeed()
		elseif Speed < 10 and RAnimation.IsPlaying then
			RAnimation:Stop()
			Humanoid.WalkSpeed = DefaultSpeed()
		end
	else
		if Speed >= 10 and Running and not RAnimation2.IsPlaying then
			RAnimation2:Play()
			Humanoid.WalkSpeed += RunningSpeed
		elseif Speed >= 10 and not Running and RAnimation2.IsPlaying then
			RAnimation2:Stop()
			Humanoid.WalkSpeed = DefaultSpeed()
		elseif Speed < 10 and RAnimation2.IsPlaying then
			RAnimation2:Stop()
			Humanoid.WalkSpeed = DefaultSpeed()
		end
	end	
	
end)

Humanoid.Changed:connect(function()
	if Humanoid.Jump and RAnimation.IsPlaying then
		RAnimation:Stop()
		RAnimation2:Stop()
		local speeds = RunningSpeed * 2 + DefaultSpeed()
		Humanoid.WalkSpeed = speeds
	end
end)

game:GetService('ContextActionService'):BindAction('RunBind', Handler, true, Enum.KeyCode.LeftShift)