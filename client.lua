Bridge = exports.community_bridge:Bridge()
local recyclers = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    for k, v in pairs(Config.Recycler) do
        local coords = v.coords
        local prop = CreateObject(GetHashKey(v.model), coords.x, coords.y, coords.z, false, true, false)
        SetEntityInvincible(prop, true)
        SetEntityCoords(prop, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityRotation(prop, v.rotation.x, v.rotation.y, v.rotation.z, 0, false)
        FreezeEntityPosition(prop, true)
        recyclers[v.stashName] = false
        local options = {
            {
                label = "Open Recycler",
                icon = "fa-solid fa-recycle",
                iconColor = "brown",
                onSelect = function()
                    TriggerServerEvent('cb-recycling:server:OpenStash', v.stashName)
                end,
                canInteract = function()
                    return true
                end
            },
            {
                label = "Start Recycling",
                icon = "fa-solid fa-recycle",
                iconColor = "green",
                onSelect = function()
                    recyclers[v.stashName] = true
                    TriggerServerEvent('cb-recycling:server:StartRecycling', v.stashName)
                end,
                canInteract = function()
                    return not recyclers[v.stashName]
                end
            },
            {
                label = "Stop Recycling",
                icon = "fa-solid fa-recycle",
                iconColor = "red",
                onSelect = function()
                    recyclers[v.stashName] = false
                    TriggerServerEvent('cb-recycling:server:StopRecycling', v.stashName)
                end,
                canInteract = function()
                    return recyclers[v.stashName]
                end
            }
        }
        Bridge.Target.AddLocalEntity(prop, options)
    end
end)

for k, v in pairs(Config.Recycler) do
    local coords = v.coords
    local prop = CreateObject(GetHashKey(v.model), coords.x, coords.y, coords.z, false, true, false)
    SetEntityInvincible(prop, true)
    SetEntityCoords(prop, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityRotation(prop, v.rotation.x, v.rotation.y, v.rotation.z, 0, false)
    FreezeEntityPosition(prop, true)
    recyclers[v.stashName] = false
    local options = {
        {
            label = "Open Recycler",
            icon = "fa-solid fa-recycle",
            iconColor = "brown",
            onSelect = function()
                TriggerServerEvent('cb-recycling:server:OpenStash', v.stashName)
            end,
            canInteract = function()
                return true
            end
        },
        {
            label = "Start Recycling",
            icon = "fa-solid fa-recycle",
            iconColor = "green",
            onSelect = function()
                recyclers[v.stashName] = true
                TriggerServerEvent('cb-recycling:server:StartRecycling', v.stashName)
            end,
            canInteract = function()
                return not recyclers[v.stashName]
            end
        },
        {
            label = "Stop Recycling",
            icon = "fa-solid fa-recycle",
            iconColor = "red",
            onSelect = function()
                recyclers[v.stashName] = false
                TriggerServerEvent('cb-recycling:server:StopRecycling', v.stashName)
            end,
            canInteract = function()
                return recyclers[v.stashName]
            end
        }
    }
    Bridge.Target.AddLocalEntity(prop, options)
end

RegisterNetEvent('cb-recycling:client:StopRecycling', function(stashName)
    print("No more items to scrap")
    recyclers[stashName] = false
end)