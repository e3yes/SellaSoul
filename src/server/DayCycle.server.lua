local nightSound = game.SoundService.nightSound
local daySound = game.SoundService.daySound 

while true do
	local Time = game.Lighting.TimeOfDay
	Time = (Time:gsub("[:\r]", ""))
	Time = tonumber(Time)

	if Time >= 180000 or Time < 60000 then
		--Between 1800hrs and 0600hrs


		wait(0.1)
		if daySound.Playing then daySound:Stop()end
		if not nightSound.Playing then
			nightSound:Play()
		end

	else
		--Between 0600 hrs and 1800hrs

		if nightSound.Playing then nightSound:Stop() end
		wait(0.1)
		if not daySound.Playing then
			daySound:Play() 
		end
	end
end