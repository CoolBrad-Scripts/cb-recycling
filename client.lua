Bridge = exports.community_bridge:Bridge()

function CreateRecylcer()
    for k, v in pairs(Config.Recycler) do
        local coords = v.coords
        local prop = CreateObject(GetHashKey(v.model), coords.x, coords.y, coords.z, false, false, false)
        SetEntityInvincible(prop, true)
        SetEntityCoords(prop, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityRotation(prop, v.rotation.x, v.rotation.y, v.rotation.z, 0, false)
        FreezeEntityPosition(prop, true)
        local started = false
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
                    started = true
                    TriggerServerEvent('cb-recycling:server:StartRecycling', v.stashName)
                end,
                canInteract = function()
                    return not started
                end
            },
            {
                label = "Stop Recycling",
                icon = "fa-solid fa-recycle",
                iconColor = "red",
                onSelect = function()
                    started = false
                    TriggerServerEvent('cb-recycling:server:StopRecycling', v.stashName)
                end,
                canInteract = function()
                    return started
                end
            }
        }
        Bridge.Target.AddLocalEntity(prop, options)
    end
end

RegisterCommand('recycle', function()
    CreateRecylcer()
end, false)