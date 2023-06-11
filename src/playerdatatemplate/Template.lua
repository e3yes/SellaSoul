local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EggConfig = require(ReplicatedStorage.Config.Eggs)
local IslandConfig = require(ReplicatedStorage.Config.Islands)

local DEFAULT_ISLANDS = {}
for island, info in IslandConfig.Config do
	DEFAULT_ISLANDS[island] = false
end


local Template = {
	Pets = {},
	Islands = DEFAULT_ISLANDS,
	
}

export type PlayerData = typeof(Template)

return Template
