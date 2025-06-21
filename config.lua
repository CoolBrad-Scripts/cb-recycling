Config = {}
Config.Recycler = {
    [1] = {
        coords = vec3(2024.76, 4979.31, 40.70),
        model = "bzzz_prop_recycler_a",
        rotation = vec3(0.0, 0.0, -45.0),
        stashName = "recycler1",
        efficiency = 60,
        items = {
            "weapon_pistol",
            "phone",
            "weapon_assaultrifle",
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
            {item = "metalscrap", chance = 10, min = 10, max = 10},
            {item = "copper", chance = 10, min = 10, max = 10},
        },
        bonusRewardChance = 100,
        bonusReward = {
            {item = "steel", chance = 10, min = 1, max = 1},
        }
    },
    ["phone"] = {
        recycleAmount = 1,
        recycleTime = 2.5,
        minReward = 1,
        maxReward = 3,
        rewards = {
            {item = "glass", chance = 10, min = 10, max = 10},
            {item = "copper", chance = 10, min = 10, max = 10},
        },
    },
    ["weapon_assaultrifle"] = {
        recycleAmount = 1,
        recycleTime = 2.5,
        minReward = 1,
        maxReward = 3,
        rewards = {
            {item = "metalscrap", chance = 10, min = 10, max = 10},
            {item = "steel", chance = 10, min = 10, max = 10},
            {item = "aluminum", chance = 10, min = 10, max = 10},
            {item = "copper", chance = 10, min = 10, max = 10},
            {item = "iron", chance = 10, min = 10, max = 10},
        },
        bonusRewardChance = 100,
        bonusReward = {
            {item = "steel", chance = 10, min = 5, max = 10},
        }
    },
}