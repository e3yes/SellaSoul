local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local TweenService = game:GetService("TweenService")
local rain = ReplicatedStorage.Weather.Rain

local stormEvent = ReplicatedStorage.Remotes.StormEvent

local rainsky = ReplicatedStorage.Weather.RainSky
local sunsky = ReplicatedStorage.Weather.SunSky

while true do
	local randWait1 = math.random(150,220)
	wait(randWait1)
	local clone = rain:Clone()
	local clonerainsky = rainsky:Clone()
	local clonesunsky = sunsky:Clone()
	local oldSky = Lighting:FindFirstChild("SunSky")
	
	oldSky:Destroy()
	clonerainsky.Parent = Lighting
	wait(6)
	stormEvent:FireAllClients("StartStorm")
	wait(3)
	clone.Parent = Workspace
	stormEvent:FireAllClients("PlayMusic1")
	wait(70)
	clone:Destroy()
	stormEvent:FireAllClients("StopMusic1")
	wait(15)
	clonerainsky:Destroy()
	clonesunsky.Parent = Lighting
	
	local randWait2 = math.random(400,550)
	wait(randWait2)
	local cloneSnow = ReplicatedStorage.Weather.Snow:Clone()
	cloneSnow.Parent = Workspace
	wait(7)
	for _, atmos in ipairs(Lighting:GetChildren()) do
		atmos.Parent = ReplicatedStorage.Weather.LightningDefault
	end
	for _, atm in ipairs(ReplicatedStorage.Weather.LightningSnow:GetChildren()) do
		atm.Parent = Lighting
	end
	wait(40)
	Workspace.Baseplate.Grass.Color = Color3.fromRGB(232, 232, 232)
	for _, tree in ipairs(Workspace.Trees:GetChildren()) do
		tree:FindFirstChild("grass").Color = Color3.fromRGB(255, 255, 255)
		if tree:FindFirstChild("grass"):FindFirstChildWhichIsA("ParticleEmitter") then
			tree.grass.ParticleEmitter.Enabled = false
		end
	end
	local randWait3 = math.random(60,190)
	wait(randWait3)--180
	cloneSnow:Destroy()
	wait(30)
	for _, tree in ipairs(Workspace.Trees:GetChildren()) do
		local randomColor1 = math.random(3,100)
		local randomColor2 = math.random(175,180)
		local randomColor3 = math.random(0,113)
		
		tree:FindFirstChild("grass").Color = Color3.fromRGB(randomColor1, randomColor2, randomColor3)
		if tree:FindFirstChild("grass"):FindFirstChildWhichIsA("ParticleEmitter") then
			tree.grass.ParticleEmitter.Enabled = true
		end
	end
	Workspace.Baseplate.Grass.Color = Color3.fromRGB(12, 111, 12)
	wait(20)
	for _, atmmtt in ipairs(Lighting:GetChildren()) do
		atmmtt.Parent = ReplicatedStorage.Weather.LightningSnow
	end
	for _, atmt in ipairs(ReplicatedStorage.Weather.LightningDefault:GetChildren()) do
		atmt.Parent = Lighting
	end

end