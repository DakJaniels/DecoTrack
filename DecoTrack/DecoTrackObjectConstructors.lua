---@class (partial) DecoTrack
local DT = DecoTrack

-- Object Constructors --

-- Constants for bag prefixes
local BAG_PREFIX = "BAG"
local BAG_BACKPACK_PREFIX = "BAG_BACKPACK_"

-- Base object factory function
local function CreateBaseContainer(houseId, houseName)
    return
    {
        HouseId = houseId,
        HouseName = houseName or "",
        ItemCount = 0,
        Items = {},
        BoundItemCount = 0,
        BoundItems = {},
    }
end

-- Helper function to format collectible name with nickname
local function FormatCollectibleName(collectibleId)
    local name = GetCollectibleName(collectibleId)
    local nickname = GetCollectibleNickname(collectibleId)

    if nickname and nickname ~= "" then
        return string.format("%s (%s)", name, nickname)
    end

    return name
end

-- Bag type handlers
local BagTypeHandlers =
{
    [function (bagId) return IsFurnitureVault(bagId) end] = function (bagId)
        return "Furniture Vault", BAG_PREFIX .. tostring(bagId)
    end,

    [function (bagId) return IsHouseBankBag(bagId) end] = function (bagId)
        local collectibleId = GetCollectibleForBag(bagId)
        local name = FormatCollectibleName(collectibleId)
        return name, BAG_PREFIX .. tostring(bagId)
    end,

    [function (bagId) return bagId == BAG_BACKPACK end] = function (bagId)
        local playerName = GetUnitName("player")
        local characterId = GetCurrentCharacterId()
        return playerName, BAG_BACKPACK_PREFIX .. tostring(characterId)
    end
}

-- Default bag handler
local function GetDefaultBagInfo(bagId)
    return "Bank", BAG_PREFIX .. tostring(bagId)
end

-- Determine bag type and get appropriate name/ID
local function ResolveBagInfo(bagId)
    for condition, handler in pairs(BagTypeHandlers) do
        if condition(bagId) then
            return handler(bagId)
        end
    end

    return GetDefaultBagInfo(bagId)
end

function DT.CreateHouse(iHouseId)
    if not iHouseId then
        return nil
    end

    local collectibleId = GetCollectibleIdForHouse(iHouseId)
    if not collectibleId or collectibleId == 0 then
        return nil
    end

    local houseName = FormatCollectibleName(collectibleId)
    return CreateBaseContainer(iHouseId, houseName)
end

function DT.CreateBag(iBagId)
    if not iBagId then
        return nil
    end

    local name, houseId = ResolveBagInfo(iBagId)
    return CreateBaseContainer(houseId, name)
end
