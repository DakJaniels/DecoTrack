---@class (partial) DecoTrack
local DT = DecoTrack
local Interop = DT.Interop
local chat = DT.chat
local eventManager = GetEventManager()

local function requestPrioritySave()
    if GetAddOnManager then
        local manager = GetAddOnManager()

        if manager and manager.RequestAddOnSavedVariablesPrioritySave then
            manager:RequestAddOnSavedVariablesPrioritySave(DT.ADDON_NAME)
        end
    end
end

-- Housing --

function DT.UpdateNextHouse()
    if nil == DT.UpdatingAllHouses then return end
    eventManager:UnregisterForUpdate("DT.OnJumpFailed")

    local house = DT.UpdatingAllHouses[1]
    if nil == house then
        chat:Print(" ")
        chat:Printf("%s has finished updating the furniture inventory database for all houses.", DT.ADDON_NAME)
        chat:Print("The game will reload in 10 seconds to save your furniture data to disk.")

        DT.Data.UpdateCompleted = true
        DT.UpdatingAllHouses = nil
        ReloadUI("ingame")

        return
    end

    chat:Print(" ")
    chat:Printf("%s's next stop: %s (%d houses remaining)", DT.ADDON_NAME, house.HouseName, #DT.UpdatingAllHouses)
    chat:Printf("Type |cffffff/DECO CANCEL|r at any time to abort.")

    if GetCurrentZoneHouseId() == house.HouseId then
        chat:Print(" ")
        chat:Print("Nevermind! You're already here. Moving on to the next house...")
        table.remove(DT.UpdatingAllHouses, 1)
        zo_callLater(DT.UpdateNextHouse, 1000)
    else
        DT.JumpToHouseId = house.HouseId
        eventManager:RegisterForUpdate(DT.ADDON_NAME .. "JumpFailed", DT.JUMP_TIMEOUT, DT.OnJumpFailed)
        RequestJumpToHouse(house.HouseId, false)
    end
end

function DT.UpdateAllHouses()
    if nil ~= DT.UpdatingAllHouses then
        chat:Printf("An update is already in progress.")
        chat:Printf("Type |cffffff/DECO CANCEL|r at any time to abort.")
        return
    end

    DT.UpdatingAllHouses = {}
    DT.UpdatingAllHousesJumpFailures = 0

    for houseId = 1, DT.MAX_HOUSE_ID do
        local collectibleId = GetCollectibleIdForHouse(houseId)
        if nil ~= collectibleId and 0 ~= collectibleId then
            if IsCollectibleUnlocked(collectibleId) then
                local houseName = GetCollectibleName(collectibleId)
                table.insert(DT.UpdatingAllHouses, { HouseId = houseId, HouseName = houseName })
            end
        end
    end

    if 0 >= #DT.UpdatingAllHouses then
        chat:Printf("You currently do not own any houses.")
        DT.UpdatingAllHouses = nil
        return
    end

    chat:Printf("%s is visiting each of your homes to update the furniture database.", DT.ADDON_NAME)
    DT.UpdateNextHouse()
end

function DT.UpdateCurrentHouse()
    if DT.IsHouseOwner() ~= true then return nil end

    local houseId = GetCurrentZoneHouseId()
    local house = DT.CreateHouse(houseId)
    local furnitureId = nil
    local itemId = nil

    repeat
        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
        if furnitureId ~= nil then
            itemId = DT.GetItemId(furnitureId)
            if nil ~= itemId then
                local link = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_DEFAULT)
                local bound = IsItemLinkBound(link)
                DT.AddHouseItem(house, itemId, nil, bound)
            end
        end
    until furnitureId == nil

    DT.Data.Houses[house.HouseId] = house
    DT.hasVisitedAllOwnedHomes = nil
end

function DT.UpdateBag(bagId)
    if nil == bagId or not DT.BAG_IDS[bagId] then return end
    if not DT.IsBagAccessible(bagId) then return end

    if bagId == BAG_SUBSCRIBER_BANK then bagId = BAG_BANK end

    local house = DT.CreateBag(bagId)
    if house == nil then
        return
    end
    local itemId, stackSize

    -- Use ZO_IterateBagSlots for robust slot iteration (no fallback needed)
    for slotIndex in ZO_IterateBagSlots(bagId) do
        if IsItemPlaceableFurniture(bagId, slotIndex) then
            itemId = GetItemId(bagId, slotIndex)
            stackSize = GetSlotStackSize(bagId, slotIndex)
            if nil ~= itemId and "" ~= itemId and 0 ~= itemId then
                local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                local bound = IsItemLinkBound(link)
                DT.AddHouseItem(house, itemId, stackSize, bound)
            end
        end
    end

    if bagId == BAG_BANK then
        bagId = BAG_SUBSCRIBER_BANK

        for slotIndex in ZO_IterateBagSlots(bagId) do
            if IsItemPlaceableFurniture(bagId, slotIndex) then
                itemId = GetItemId(bagId, slotIndex)
                stackSize = GetSlotStackSize(bagId, slotIndex)
                if nil ~= itemId and "" ~= itemId and 0 ~= itemId then
                    local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                    local bound = IsItemLinkBound(link)
                    DT.AddHouseItem(house, itemId, stackSize, bound)
                end
            end
        end

        DT.Data.Houses["BAG" .. tostring(BAG_SUBSCRIBER_BANK)] = nil
    end

    DT.Data.Houses[house.HouseId] = house
end

function DT.DeferredPrioritySave()
    eventManager:UnregisterForUpdate("DecoTrack.PrioritySave")
    requestPrioritySave()
end

function DT.UpdateCallback()
    eventManager:UnregisterForUpdate("DecoTrack.Update")
    DT.UpdateCurrentHouse()

    for bagId, _ in pairs(DT.BAG_IDS) do
        if bagId ~= BAG_SUBSCRIBER_BANK then
            DT.UpdateBag(bagId)
        end
        if bagId == BAG_FURNITURE_VAULT then
            DT.UpdateBag(bagId)
        end
    end

    DT.IsDirty = false
    DT.UpdateCount = 0
    eventManager:RegisterForUpdate("DecoTrack.PrioritySave", DT.PRIORITY_SAVE_INTERVAL, DT.DeferredPrioritySave)
    Interop.CallbackManager:OnFullUpdate()
end

function DT.QueueUpdate(changeCount)
    eventManager:UnregisterForUpdate("DecoTrack.Update")
    DT.UpdateCount = DT.UpdateCount + 1
    DT.IsDirty = true
    eventManager:RegisterForUpdate("DecoTrack.Update", DT.UPDATE_DELAY, DT.UpdateCallback)
end

function DT.GetItemTotals()
    local itemCounts = {}
    local boundItemCounts = {}
    local totalCount = 0

    for houseId, house in pairs(DT.Data.Houses) do
        if tostring(houseId) ~= "BAG" .. tostring(BAG_SUBSCRIBER_BANK) then
            for itemId, count in pairs(house.Items) do
                totalCount = totalCount + count
                itemCounts[itemId] = (itemCounts[itemId] or 0) + count
                boundItemCounts[itemId] = (boundItemCounts[itemId] or 0) + (house.BoundItems[itemId] or 0)
            end
        end
    end

    return totalCount, itemCounts, boundItemCounts
end

function DT.ReportTotals()
    local total, totalBound = 0, 0
    local totals = {}

    for houseId, house in pairs(DT.Data.Houses) do
        if house.HouseName and house.ItemCount and 0 < house.ItemCount then
            table.insert(totals, { house.HouseName or "", house.ItemCount or 0, house.BoundItemCount or 0 })
            total = total + (house.ItemCount or 0)
            totalBound = totalBound + (house.BoundItemCount or 0)
        end
    end

    table.sort(totals, function (a, b) return a[1] < b[1] end)

    chat:Print("__________________")
    chat:Print("Total Items Report")
    chat:Print("__________________")

    for _, entry in ipairs(totals) do
        chat:Printf("|c00ffff%s |cffffff(|cffff00%d|cffffff item%s, %s|cffff00%d|cffffff)", entry[1], entry[2], 1 == entry[2] and "" or "s", DT.BOUND_TEXTURE, entry[3])
    end

    chat:Printf("|c00ffff* Total items |cffff00%d%s |cffffff(|cffff00%d%s |cffffff) |c00ffff*", (total - totalBound), DT.UNBOUND_TEXTURE, totalBound, DT.BOUND_TEXTURE)
end
