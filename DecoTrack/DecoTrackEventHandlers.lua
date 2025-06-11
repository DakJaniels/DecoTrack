---@class (partial) DecoTrack
local DT = DecoTrack
local chat = DT.chat
local eventManager = GetEventManager()

-- Event Handlers --

function DT.OnAddOnLoaded(event, addonName)
    if addonName == DT.ADDON_NAME then
        eventManager:UnregisterForEvent(DT.ADDON_NAME, EVENT_ADD_ON_LOADED)
        DT.Initialize()
    end
end

function DT.OnPlayerActivated()
    DT.QueueUpdate(0)

    if DT.Data.UpdateCompleted then
        DT.Data.UpdateCompleted = false
        chat:Print("DecoTrack has updated your furniture inventory for all of your homes.")
        chat:Print("Please remember to also do the following:")
        chat:Print(" - Visit the bank to update its inventory.")
        chat:Print(" - Open each house storage chest and coffer to update their inventories.")
        chat:Print(" - Enable DecoTrack for each character and log in with them to update their inventories.")
    elseif DT.UpdatingAllHouses then
        eventManager:UnregisterForUpdate(DT.ADDON_NAME .. "JumpFailed")

        DT.UpdatingAllHousesJumpFailures = 0
        table.remove(DT.UpdatingAllHouses, 1)

        zo_callLater(DT.UpdateNextHouse, DT.UPDATE_NEXT_HOUSE_DELAY)
    end
end

function DT.OnFurniturePlaced()
    DT.QueueUpdate(1)
end

function DT.OnFurnitureRemoved()
    DT.QueueUpdate(-1)
end

function DT.OnCollectibleUpdated(eventId, collectibleId)
    local data = DT.Data
    if data then
        local house = DT.GetHouseByCollectibleId(collectibleId)
        if house then
            local name = GetCollectibleName(collectibleId)
            local nickname = GetCollectibleNickname(collectibleId)
            if nil ~= nickname and "" ~= nickname then
                name = string.format("%s (%s)", name, nickname)
            end
            house.HouseName = name
        end
    end
end

function DT.OnBankAccess(event, bagId)
    if nil ~= bagId and DT.BAG_IDS[bagId] then
        DT.QueueUpdate(0)
    end
end

--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function DT.OnItemSlotChanged(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    DT.QueueUpdate(stackCountChange)
end

function DT.OnJumpFailedCallback()
    eventManager:UnregisterForUpdate("DT.OnJumpFailed")

    if DT.UpdatingAllHouses then
        if GetCurrentZoneHouseId() ~= DT.JumpToHouseId then
            chat:Printf("Jump failed.")

            if 5 >= DT.UpdatingAllHousesJumpFailures then
                DT.UpdatingAllHousesJumpFailures = DT.UpdatingAllHousesJumpFailures + 1
                chat:Printf("Retrying jump to next house (Attempt %d)...", DT.UpdatingAllHousesJumpFailures)
                zo_callLater(DT.UpdateNextHouse, DT.UPDATE_NEXT_HOUSE_DELAY)

                return
            end

            chat:Printf("Too many attempts have failed. Process will resume after you leave this zone.")
            chat:Printf("Type |cffffff/DECO CANCEL|r at any time to abort.")
        end
    end
end

function DT.OnJumpFailed()
    eventManager:RegisterForUpdate("DT.OnJumpFailed", 2000, DT.OnJumpFailedCallback)
end
