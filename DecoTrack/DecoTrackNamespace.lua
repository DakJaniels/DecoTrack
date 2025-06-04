---@class (partial) DecoTrack
DecoTrack =
{
    ADDON_NAME = "DecoTrack",
    ADDON_VERSION = "2.6",
    ADDON_AUTHOR = "@Cardinal05, @Architectura",
    JUMP_TIMEOUT = 1000 * 15,
    UPDATE_DELAY = 1000 * 1,
    UPDATE_NEXT_HOUSE_DELAY = 1000 * 1.5,
    PRIORITY_SAVE_INTERVAL = 1000 * 60,
    MAX_HOUSE_ID = 250,
    DefaultSettings = {},
    BAG_IDS =
    {
        [BAG_BACKPACK] = true,
        [BAG_BANK] = true,
        [BAG_SUBSCRIBER_BANK] = true,
        [BAG_HOUSE_BANK_ONE] = true,
        [BAG_HOUSE_BANK_TWO] = true,
        [BAG_HOUSE_BANK_THREE] = true,
        [BAG_HOUSE_BANK_FOUR] = true,
        [BAG_HOUSE_BANK_FIVE] = true,
        [BAG_HOUSE_BANK_SIX] = true,
        [BAG_HOUSE_BANK_SEVEN] = true,
        [BAG_HOUSE_BANK_EIGHT] = true,
        [BAG_FURNITURE_VAULT] = true,
    },
    LIMITS =
    {
        [HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE] = "Special Collectibles",
        [HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM] = "Special Furnishings",
        [HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE] = "Collectible Furnishings",
        [HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM] = "Traditional Furnishings",
    },
    BOUND_TEXTURE = zo_iconFormat("esoui/art/tutorial/gamepad/gp_crowns.dds", 20, 20),
    UNBOUND_TEXTURE = zo_iconFormat("esoui/art/inventory/inventory_tradable_icon.dds", 16, 20),
    Data =
    {
        Houses = {},
        Settings = {},
        UpdateCompleted = nil,
    },
    JumpToHouseId = 0,
    UpdateCount = 0,
    IsDirty = false,
    chat = LibChatMessage.Create("DecoTrack", "DT")
}

DecoTrack.__index = DecoTrack
