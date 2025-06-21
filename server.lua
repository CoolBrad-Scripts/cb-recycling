Bridge = exports.community_bridge:Bridge()

function RegisterRecycler()
    for k, v in pairs(Config.Recycler) do
        local stashName = v.stashName
        local stashWeight = 10000
        Bridge.Inventory.RegisterStash(stashName, stashName, 10, stashWeight, nil, nil, nil)
    end
end

function Scrapping(stashName)
    local scrapping = true
    CreateThread(function()
        while scrapping do
            local items = exports.ox_inventory:GetInventoryItems(stashName)
            if not next(items) then
                scrapping = false
                TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
                break
            end

            local foundSomething = false
            for k, v in pairs(items) do
                if v.slot >= 1 and v.slot <= 5 then
                    if IsItemScrappable(v.name, stashName) then
                        foundSomething = true
                        Wait(1500)
                        local success = ScrappingItem(v.name, stashName, 1, v.slot)
                        if not success then
                            -- Stop scrapping if there's not enough space for rewards
                            scrapping = false
                            TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
                            print("Stopping recycling due to insufficient output space")
                            return
                        end
                    else
                        print("Item not scrappable")
                    end
                end
            end

            if not foundSomething then
                scrapping = false
                TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
                break
            end
            Wait(100)
        end
    end)
end

function IsItemScrappable(item, stashName)
    for k, v in pairs(Config.ItemPool) do
        if k == stashName then
            local itemFound = false
            for a, b in pairs(v) do
                if b.item == string.lower(item) then
                    itemFound = true
                    break
                end
            end
            if itemFound then
                return true
            end
        end
    end
    return false
end

function ScrappingItem(item, stashName, amount, slot)
    local items = exports.ox_inventory:GetInventoryItems(stashName)
    local availableSlots = {}
    
    -- Check which output slots (6-10) are available
    for i = 6, 10 do
        local slotOccupied = false
        for k, v in pairs(items) do
            if v.slot == i then
                slotOccupied = true
                break
            end
        end
        if not slotOccupied then
            table.insert(availableSlots, i)
        end
    end
    
    -- Calculate how many rewards we'll give
    local rewardAmount = math.random(Config.ItemPool[stashName][1].minReward, Config.ItemPool[stashName][1].maxReward)
    
    -- Check if we have enough available slots for all rewards
    if #availableSlots >= rewardAmount then
        exports.ox_inventory:RemoveItem(stashName, item, amount, nil, slot, false)
        
        for i = 1, rewardAmount do
            local randomItem = Config.ItemPool[stashName][1].pool[math.random(1, #Config.ItemPool[stashName][1].pool)]
            local randomAmount = math.random(randomItem.min, randomItem.max)
            local targetSlot = availableSlots[i] -- Use a different slot for each reward
            exports.ox_inventory:AddItem(stashName, randomItem.item, randomAmount, nil, targetSlot, false)
        end
        return true -- Success
    else
        print("Not enough available space in output slots (6-10) for " .. rewardAmount .. " rewards. Available slots: " .. #availableSlots)
        return false -- Failure
    end
end

RegisterNetEvent('cb-recycling:server:OpenStash', function(stashName)
    local src = source
    if src == nil then return end
    Bridge.Inventory.OpenStash(src, "stash", stashName)
end)

RegisterNetEvent('cb-recycling:server:StartRecycling', function(stashName)
    local src = source
    if src == nil then return end
    Bridge.Inventory.OpenStash(src, "stash", stashName)
    Scrapping(stashName)
end)

RegisterNetEvent('cb-recycling:server:StopRecycling', function(stashName)
    local src = source
    if src == nil then return end
    TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
end)

CreateThread(function()
    RegisterRecycler()
end)