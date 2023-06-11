local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Remotes = ReplicatedStorage.Remotes
local weaponShop = script.Parent:FindFirstChild("WeaponShop")
local rankShop = script.Parent:FindFirstChild("RankShop")
local skinShop = script.Parent:FindFirstChild("SkinShop")
local wingsShop = script.Parent:FindFirstChild("WingsShop")

local FrameWea = weaponShop.Frame
local FrameSkin = skinShop.Frame
local FrameR = rankShop.Frame
local FrameWin = wingsShop.Frame

local infoFrameWea = FrameWea.InfoFrame
local infoFrameSkin = FrameSkin.InfoFrame
local infoFrameR = FrameR.InfoFrame
local infoFrameWin = FrameWin.InfoFrame
local managerSkin = require(script.Parent:FindFirstChild("ManagerSkinShop"))
local managerRank = require(script.Parent:FindFirstChild("ManagerRankShop"))
local managerWings = require(script.Parent:FindFirstChild("ManagerWingsShop"))
local manager = require(script.Parent:FindFirstChild("Manager"))

local warningFrameRank = rankShop.WarningFrame
local acceptRank = warningFrameRank.Accept
local denyRank = warningFrameRank.Deny

local exitButtonWea = FrameWea.Exit
local exitButtonSkin = FrameSkin.Exit
local exitButtonR = FrameR.Exit
local exitButtonWin = FrameWin.Exit

local buyButtonWeapon = infoFrameWea.BuyButton
local buyAllButtonWeapon = FrameWea.BuyAll

local buyButtonRank = infoFrameR.BuyButton

local buyButtonSkin = infoFrameSkin.BuyButton

local buyButtonWings = infoFrameWin.BuyButton

warningFrameRank.TextLabel.Text = "When you buy this, you lose all the essences, souls, strength, weapons, skins, wings"


Remotes.Shop.ShopOpen.OnClientEvent:Connect(function()
	if weaponShop.Enabled == false then
		manager.new("Essence")
		FrameWea:TweenPosition(
			UDim2.new(0.5, 0, 0.5, 0),
			"Out",
			"Quart",
			1,
			false
		)
		weaponShop.Enabled = true
	end
end)

Remotes.Shop.RankShopOpen.OnClientEvent:Connect(function()
	if rankShop.Enabled == false then
		managerRank.new("Rank")
		FrameR:TweenPosition(
			UDim2.new(0.54, 0, 0.5, 0),
			"Out",
			"Quart",
			1,
			false
		)
		rankShop.Enabled = true
	end
end)

Remotes.Shop.SkinShopOpen.OnClientEvent:Connect(function()
	if skinShop.Enabled == false then
		FrameSkin:TweenPosition(
			UDim2.new(0.54, 0, 0.5, 0),
			"Out",
			"Quart",
			1,
			false
		)
		skinShop.Enabled = true
		managerSkin.new("Skin")
	end
end)

Remotes.Shop.WingsShopOpen.OnClientEvent:Connect(function()
	if wingsShop.Enabled == false then
		FrameWin:TweenPosition(
			UDim2.new(0.54, 0, 0.5, 0),
			"Out",
			"Quart",
			1,
			false
		)
		wingsShop.Enabled = true
		managerWings.new("Wings")
	end
end)


exitButtonSkin.MouseButton1Click:Connect(function()
	FrameSkin:TweenPosition(
		UDim2.new(-0.54, 0,0.5, 0),
		"Out",
		"Quart",
		1,
		false)
	wait(1)
	skinShop.Enabled = false
	SoundService.SfxButton:Play()
end)

exitButtonR.MouseButton1Click:Connect(function()
	FrameR:TweenPosition(
		UDim2.new(2, 0,0.5, 0),
		"Out",
		"Quart",
		1,
		false)
	wait(1)
	rankShop.Enabled = false
	SoundService.SfxButton:Play()
end)

exitButtonWea.MouseButton1Click:Connect(function()
	FrameWea:TweenPosition(
		UDim2.new(-0.5, 0,0.5, 0),
		"Out",
		"Quart",
		1,
		false)
	wait(1)
	weaponShop.Enabled = false
	SoundService.SfxButton:Play()
	
end)

exitButtonWin.MouseButton1Click:Connect(function()
	FrameWin:TweenPosition(
		UDim2.new(0.54, 0, -0.5, 0),
		"Out",
		"Quart",
		1,
		false)
	wait(1)
	wingsShop.Enabled = false
	SoundService.SfxButton:Play()
end)

buyAllButtonWeapon.MouseButton1Click:Connect(function()
	manager.BuyAll()
	SoundService.SfxButton:Play()
end)

buyAllButtonWeapon.MouseEnter:Connect(function()
	buyAllButtonWeapon:TweenSize(
		UDim2.new(0, 186,0, 60),
		"Out",
		"Quart",
		1,
		false)

end)

buyAllButtonWeapon.MouseLeave:Connect(function()
	buyAllButtonWeapon:TweenSize(
		UDim2.new(0, 136,0, 50),
		"Out",
		"Quart",
		0.3,
		false)
end)

buyButtonWeapon.MouseButton1Click:Connect(function()
	manager.Buy()
	SoundService.SfxButton:Play()
end)

buyButtonRank.MouseButton1Click:Connect(function()
	if buyButtonRank.Price.Text ~= "Equip" and buyButtonRank.Price.Text ~= "Unequip" then
		warningFrameRank.Visible = true
		SoundService.SfxButton:Play()
	else
		warningFrameRank.Visible = false
		managerRank.Buy()
		SoundService.SfxButton:Play()
	end
end)

acceptRank.MouseButton1Click:Connect(function()
	managerRank.Buy()
	warningFrameRank.Visible = false
	SoundService.SfxButton:Play()
end)

denyRank.MouseButton1Click:Connect(function()
	warningFrameRank.Visible = false
	SoundService.SfxButton:Play()
end)

buyButtonSkin.MouseButton1Click:Connect(function()
	managerSkin.Buy()
	SoundService.SfxButton:Play()
end)

buyButtonWings.MouseButton1Click:Connect(function()
	managerWings.Buy()
	SoundService.SfxButton:Play()
end)

