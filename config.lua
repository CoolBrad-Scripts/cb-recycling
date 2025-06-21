Config = {}
Config.Recycler = {
    [1] = {
        coords = vec3(2021.62, 4972.9, 40.27),
        model = "prop_cooker_03",
        rotation = vec3(0.0, 0.0, 0.0),
        stashName = "recycler1",
        efficiency = 60,
        items = {
            "weapon_pistol"
        },
    }
}

Config.Recyclables = {
    ["weapon_pistol"] = {
        recycleAmount = 1,
        recycleTime = 2.5,
        minReward = 1,
        maxReward = 3,
        rewards = {
            {item = "metalscrap", chance = 10, min = 5, max = 10},
            {item = "copper", chance = 10, min = 2, max = 3},
        },
        bonusRewardChance = 100,
        bonusReward = {
            {item = "steel", chance = 10, min = 1, max = 1},
        }
    }
}