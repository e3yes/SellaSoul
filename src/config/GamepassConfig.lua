local module = {}

module.Passes = {
	{ID = "x2_Essence",Name = "x2 Essence Forever", Price = 3, Pass = 150397410},
	{ID = "x2_Soul", Name = "x2 Soul Forever",Price = 3,  Pass = 150398495},
	{ID = "x10_Essence", Name = "x10 Essence Forever",Price = 49,  Pass = 150440564},
}

module.Currencies = {
	{ID = "10K", Name = "+10K Soul",Price = 49,  Product = 1502919770, Reward = 10_000},
	{ID = "1M", Name = "+1M Soul",Price = 79,  Product = 1502950116, Reward = 1_000_000},
	{ID = "1B", Name = "+1B Soul",Price = 119,  Product = 1502961556, Reward = 1_000_000_000},
	{ID = "x10_Your_Souls", Name = "+(x10 Your souls)",Price = 149,  Product = 1514522998, Reward = 10},
}
module.Booster = {
	{ID = "", Price = 0, Time = 0, Image = ""},
}

module.Pets = {
	{ID = "", Price = 0, Stat = 0, Image = ""},
}


return module

