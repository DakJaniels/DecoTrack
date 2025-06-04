---@class (partial) DecoTrack
local DT = DecoTrack
local eventManager = GetEventManager()

-- Event Subscriptions --
function DT:RegisterEvents()
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_ADD_ON_LOADED, self.OnAddOnLoaded)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, self.OnFurniturePlaced)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED, self.OnFurnitureRemoved)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_COLLECTIBLE_UPDATED, self.OnCollectibleUpdated)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_JUMP_FAILED, self.OnJumpFailed)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_OPEN_BANK, self.OnBankAccess)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_CLOSE_BANK, self.OnBankAccess)
    eventManager:RegisterForEvent(self.ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.OnItemSlotChanged)
end

DT:RegisterEvents()
