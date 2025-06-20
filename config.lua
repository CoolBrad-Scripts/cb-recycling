Config = {}
Config.Recycler = {
    [1] = {
        coords = vec3(2021.62, 4972.9, 40.27),
        model = "prop_cooker_03",
        rotation = vec3(0.0, 0.0, 0.0),
        stashName = "recycler1",
    }
}

Config.ItemPool = {
    ["recycler1"] = {
        {
            item = "weapon_pistol",
            recycleAmount = 1,
            recycleTime = 2.5,
            pool = {
                {item = "metalscrap", chance = 10},
                {item = "steel", chance = 10},
                {item = "aluminum", chance = 10},
                {item = "copper", chance = 10},
                {item = "iron", chance = 10},
                {item = "plastic", chance = 10},
                {item = "rubber", chance = 10},
                {item = "glass", chance = 10},
            }
        }
    }
}