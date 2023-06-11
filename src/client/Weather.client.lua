local ReplicatedStorage = game:GetService("ReplicatedStorage")
local stormEvent = ReplicatedStorage.Remotes.StormEvent
local stormSound = ReplicatedStorage.Weather.Storm
local rainSound = ReplicatedStorage.Weather.Music1

stormEvent.OnClientEvent:Connect(function(action)
	if action == "StartStorm" then
		stormSound:Play()
	elseif action == "PlayMusic1" then
		rainSound:Play()
	elseif action == "StopMusic1" then
		rainSound:Stop()
	end
end)