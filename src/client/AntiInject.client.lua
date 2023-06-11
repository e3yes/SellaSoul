local player = game.Players.LocalPlayer

local function checkForInjection()
	for i, v in pairs(getfenv()) do
		if type(v) == "function" and string.find(debug.getinfo(v).source, "rbxasset") == nil then
			player:Kick("Inject Detected")
			return
		end
	end
end

game:GetService("RunService").Stepped:Connect(function()
	checkForInjection()
end)