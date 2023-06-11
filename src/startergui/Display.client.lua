local player = game.Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local essence = leaderstats:WaitForChild("Essence")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Stars"
screenGui.Parent = player.PlayerGui

local tweenService = game:GetService("TweenService")
local textService = game:GetService("TextService")

local lastValue = essence.Value

essence.Changed:Connect(function(newValue)
	local change = newValue - lastValue
	lastValue = newValue

	if change <= 0 then return end

	local starCount = 8
	local starSize = 30
	local stars = {}

	for i = 1, starCount do
		local star = Instance.new("ImageLabel")
		star.BackgroundTransparency = 1
		star.Image = "rbxassetid://5946093983"
		star.Size = UDim2.new(0, starSize, 0, starSize)
		star.Position = UDim2.new(math.random(), 0, math.random(), 0)
		star.Parent = screenGui

		local starTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local starGoal = {
			Position = UDim2.new(math.random(), -starSize/2, math.random(), -starSize/2),
			Size = UDim2.new(0, starSize/2, 0, starSize/2),
			ImageTransparency = 1
		}

		local starTween = tweenService:Create(star, starTweenInfo, starGoal)
		starTween:Play()

		table.insert(stars, star) 
	end

	local floatingText = Instance.new("TextLabel")
	local textSize = textService:GetTextSize("+" ..FormatNumber.FormatCompact(change), 40, Enum.Font.FredokaOne, Vector2.new(math.huge, math.huge))
	floatingText.Size = UDim2.new(0, textSize.X, 0, textSize.Y)
	floatingText.Position = UDim2.new(math.random(), math.random(-50, 50), math.random(), math.random(-50, 50))
	floatingText.BackgroundTransparency = 1
	floatingText.Font = Enum.Font.FredokaOne
	floatingText.TextSize = 40
	floatingText.TextColor3 = Color3.new(255, 255, 255)
	floatingText.TextStrokeTransparency = 0
	floatingText.TextStrokeColor3 = Color3.new(0,0,0)
	floatingText.Text = "+" ..FormatNumber.FormatCompact(change)
	floatingText.Parent = screenGui

	local startScale = UDim2.new(0, 0, 0, 0)
	local endScale = UDim2.new(1, 0, 1)

	local textTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local textGoal = {
		Position = floatingText.Position,
		Size = floatingText.Size,
		TextTransparency = 1
	}

	local floatingTextTween = tweenService:Create(floatingText, textTweenInfo, textGoal)
	floatingTextTween:Play()

	floatingTextTween.Completed:Connect(function()
		for _, star in ipairs(stars) do
			star:Destroy()
		end

		floatingText:Destroy()
	end)
end)