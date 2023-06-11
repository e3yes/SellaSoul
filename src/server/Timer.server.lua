local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function Timer(player: Player)
	while wait(60) do
		player.timeInventory.Times.Value += 1
	end
end

Players.PlayerAdded:Connect(Timer)