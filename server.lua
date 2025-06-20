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
                print("No more items to scrap")
                scrapping = false
                break
            end

            local foundSomething = false
            for k, v in pairs(items) do
                if v.slot >= 1 and v.slot <= 5 then
                    if IsItemScrappable(v.name, stashName) then
                        foundSomething = true
                        Wait(1500)
                        ScrappingItem(v.name, stashName, 1, v.slot)
                        break
                    else
                        print("Item not scrappable")
                    end
                end
            end

            if not foundSomething then
                print("No more items to scrap")
                scrapping = false
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
    local availableSpace = false
    local slot6 = false
    local slot7 = false
    local slot8 = false
    local slot9 = false
    local slot10 = false
    local availableSlot = 0
    for k, v in pairs(items) do
        if v.slot == 6 then
            print("Slot 6 found")
            slot6 = true
        elseif v.slot == 7 then
            print("Slot 7 found")
            slot7 = true
        elseif v.slot == 8 then
            print("Slot 8 found")
            slot8 = true
        elseif v.slot == 9 then
            print("Slot 9 found")
            slot9 = true
        elseif v.slot == 10 then
            print("Slot 10 found")
            slot10 = true
        end
    end
    if slot6 and slot7 and slot8 and slot9 and slot10 then
        availableSpace = false
    else
        availableSpace = true
        if not slot6 then
            availableSlot = 6
        elseif not slot7 then
            availableSlot = 7
        elseif not slot8 then
            availableSlot = 8
        elseif not slot9 then
            availableSlot = 9
        elseif not slot10 then
            availableSlot = 10
        end
    end
    if availableSpace then
        print(availableSlot)
        exports.ox_inventory:RemoveItem(stashName, item, amount, nil, slot, true)
        exports.ox_inventory:AddItem(stashName, "sandwich", 1, nil, availableSlot, true)
    else
        print("No available space in output slots (6-10)")
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
    print("Stop Recycling")
end)

CreateThread(function()
    RegisterRecycler()
end)