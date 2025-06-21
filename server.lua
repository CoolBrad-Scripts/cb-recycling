Bridge = exports.community_bridge:Bridge()

function RegisterRecycler()
    for k, v in pairs(Config.Recycler) do
        local stashName = v.stashName
        local stashWeight = 10000
        Bridge.Inventory.RegisterStash(stashName, stashName, 10, stashWeight, nil, nil, nil)
    end
end

function Scrapping(stashName, efficiency)
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
                        local success = ScrappingItem(v.name, stashName, 1, v.slot, efficiency)
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
    for k, v in pairs(Config.Recycler) do
        if v.stashName == stashName then
            local itemFound = false
            for a, b in pairs(v.items) do
                if b == string.lower(item) then
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

function ScrappingItem(item, stashName, amount, slot, efficiency)
    local items = exports.ox_inventory:GetInventoryItems(stashName)
    local availableSlots = {}
    local existingItemSlots = {}
    
    -- Check which output slots (6-10) are available and track existing items
    for i = 6, 10 do
        local slotOccupied = false
        for k, v in pairs(items) do
            if v.slot == i then
                slotOccupied = true
                -- Track what items are in which slots
                existingItemSlots[v.name] = i
                break
            end
        end
        if not slotOccupied then
            table.insert(availableSlots, i)
        end
    end
    
    -- Calculate how many rewards we'll give
    item = string.lower(item)
    local recyclable = Config.Recyclables[item]
    local rewardAmount = math.random(recyclable.minReward, recyclable.maxReward)
    
    -- Generate all rewards first
    local rewards = {}
    for i = 1, rewardAmount do
        local randomItem = Config.Recyclables[item].rewards[math.random(1, #Config.Recyclables[item].rewards)]
        local randomAmount = math.ceil(math.random(randomItem.min, randomItem.max) * (efficiency / 100))
        table.insert(rewards, {item = randomItem.item, amount = randomAmount})
    end
    
    -- Check if we can place all rewards (either in existing slots or new slots)
    local slotsNeeded = 0
    local uniqueNewItems = {}
    for _, reward in pairs(rewards) do
        if not existingItemSlots[reward.item] and not uniqueNewItems[reward.item] then
            uniqueNewItems[reward.item] = true
            slotsNeeded = slotsNeeded + 1
        end
    end
    if slotsNeeded <= #availableSlots then
        exports.ox_inventory:RemoveItem(stashName, item, amount, nil, slot, false)
        
        local availableSlotIndex = 1
        for _, reward in pairs(rewards) do
            if existingItemSlots[reward.item] then
                -- Item already exists, add to existing slot
                exports.ox_inventory:AddItem(stashName, reward.item, reward.amount, nil, existingItemSlots[reward.item], false)
            else
                -- New item, use an available slot
                local targetSlot = availableSlots[availableSlotIndex]
                exports.ox_inventory:AddItem(stashName, reward.item, reward.amount, nil, targetSlot, false)
                -- Track this new item in case we get more of the same type
                existingItemSlots[reward.item] = targetSlot
                availableSlotIndex = availableSlotIndex + 1
            end
        end
        return true -- Success
    else
        print("Not enough available space in output slots (6-10) for " .. slotsNeeded .. " unique new items. Available slots: " .. #availableSlots)
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
    for k, v in pairs(Config.Recycler) do
        if v.stashName == stashName then
            Bridge.Inventory.OpenStash(src, "stash", stashName)
            Scrapping(stashName, v.efficiency)
        end
    end
end)

RegisterNetEvent('cb-recycling:server:StopRecycling', function(stashName)
    local src = source
    if src == nil then return end
    TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
end)

CreateThread(function()
    RegisterRecycler()
end)