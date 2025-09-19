Bridge = exports.community_bridge:Bridge()
Recyclers = {}

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Bridge.Version.AdvancedVersionChecker("CoolBrad-Scripts/cb-patchnotes", resource)
end)

function RegisterRecycler()
    for k, v in pairs(Config.Recycler) do
        local stashName = v.stashName
        local stashWeight = 1000000
        Bridge.Inventory.RegisterStash(stashName, stashName, 10, stashWeight, nil, nil, nil)
    end
end

local function GetPlayerCoords(target)
    local playerPed = GetPlayerPed(target)
    return GetEntityCoords(playerPed)
end

local function tooFarAwayFromSomething(target, coords)
    local targetCoords = GetPlayerCoords(target)
    local dist = #(vec3(targetCoords.x, targetCoords.y, targetCoords.z) - vec3(coords.x, coords.y, coords.z))
    if dist > 5 then
        TriggerClientEvent('cb-gangsystem:client:Notify', target, "Too Far Away", "You are too far away from the recycler", "error")
        return true
    end
    return false
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
                if not Recyclers[stashName] then
                    scrapping = false
                    Recyclers[stashName] = false
                    TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
                    break
                end
                if v.slot >= 1 and v.slot <= 5 then
                    if IsItemScrappable(v.name, stashName) then
                        foundSomething = true
                        Wait(1500)
                        local success = ScrappingItem(v.name, stashName, 1, v.slot, efficiency)
                        if not success then
                            -- Stop scrapping if there's not enough space for rewards
                            scrapping = false
                            Recyclers[stashName] = false
                            TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
                            return
                        end
                    else
                        print("Item not scrappable")
                    end
                end
            end

            if not foundSomething then
                scrapping = false
                Recyclers[stashName] = false
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
    
    -- Check for bonus reward
    local bonusReward = nil
    if recyclable.bonusRewardChance and recyclable.bonusReward then
        local bonusChance = math.random(1, 100)
        if bonusChance <= recyclable.bonusRewardChance then
            local randomBonusItem = recyclable.bonusReward[math.random(1, #recyclable.bonusReward)]
            local bonusAmount = math.random(randomBonusItem.min, randomBonusItem.max)
            bonusReward = {item = randomBonusItem.item, amount = bonusAmount}
        end
    end
    
    -- Check if we can place all rewards (either in existing slots or new slots)
    local slotsNeeded = 0
    local uniqueNewItems = {}
    
    -- Check slots needed for regular rewards
    for _, reward in pairs(rewards) do
        if not existingItemSlots[reward.item] and not uniqueNewItems[reward.item] then
            uniqueNewItems[reward.item] = true
            slotsNeeded = slotsNeeded + 1
        end
    end
    
    -- Check slots needed for bonus reward if it exists
    if bonusReward and not existingItemSlots[bonusReward.item] and not uniqueNewItems[bonusReward.item] then
        uniqueNewItems[bonusReward.item] = true
        slotsNeeded = slotsNeeded + 1
    end
    
    -- Only proceed if we have enough slots for all rewards (including bonus)
    if slotsNeeded <= #availableSlots then
        exports.ox_inventory:RemoveItem(stashName, item, amount, nil, slot, false)
        
        local availableSlotIndex = 1
        
        -- Place regular rewards
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
        
        -- Place bonus reward if it exists
        if bonusReward then
            if existingItemSlots[bonusReward.item] then
                -- Bonus item already exists, add to existing slot
                exports.ox_inventory:AddItem(stashName, bonusReward.item, bonusReward.amount, nil, existingItemSlots[bonusReward.item], false)
            else
                -- New bonus item, use an available slot
                local targetSlot = availableSlots[availableSlotIndex]
                exports.ox_inventory:AddItem(stashName, bonusReward.item, bonusReward.amount, nil, targetSlot, false)
            end
        end
        
        return true -- Success
    else
        return false -- Failure - not enough slots for all rewards including bonus
    end
end

RegisterNetEvent('cb-recycling:server:OpenStash', function(stashName)
    local src = source
    if src == nil then return end
    if not Config.Recycler[stashName] then return end
    for _, v in pairs(Config.Recycler) do
        if v.stashName == stashName and tooFarAwayFromSomething(src, v.coords) then return end
    end
    Bridge.Inventory.OpenStash(src, "stash", stashName)
end)

RegisterNetEvent('cb-recycling:server:StartRecycling', function(stashName)
    local src = source
    if src == nil then return end
    for k, v in pairs(Config.Recycler) do
        if v.stashName == stashName then
            Bridge.Inventory.OpenStash(src, "stash", stashName)
            Scrapping(stashName, v.efficiency)
            Recyclers[stashName] = true
        end
    end
end)

RegisterNetEvent('cb-recycling:server:StopRecycling', function(stashName)
    local src = source
    if src == nil then return end
    TriggerClientEvent('cb-recycling:client:StopRecycling', -1, stashName)
    Recyclers[stashName] = false
end)

CreateThread(function()
    RegisterRecycler()
end)

function SwapItems(payload)
    for k, v in pairs(Config.Recycler) do
        if (payload.fromInventory == payload.source) and (payload.toInventory == v.stashName) then
            if payload.action == "move" then
                local item = payload.fromSlot.name
                local slot = payload.toSlot
                if slot == 6 or slot == 7 or slot == 8 or slot == 9 or slot == 10 then
                    return false
                end
                if IsItemScrappable(item, v.stashName) then
                    return true
                else
                    return false
                end
            elseif payload.action == "swap" then
                local item = payload.fromSlot.name
                local otherItem = payload.toSlot.name
                if IsItemScrappable(item, v.stashName) and IsItemScrappable(otherItem, v.stashName) then
                    return true
                else
                    return false
                end
            end
        elseif payload.fromInventory == v.stashName and payload.toInventory == payload.source then
            if Recyclers[v.stashName] then
                return false
            end
            if payload.action == "swap" then
                return false
            end
        end
    end
end

CreateThread( function()
    local hookId = exports.ox_inventory:registerHook('swapItems', function(payload)
        local result = SwapItems(payload)
        return result
    end, {})
end)