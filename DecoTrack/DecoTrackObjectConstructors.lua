---@class (partial) DecoTrack
local DT = DecoTrack

-- Object Constructors --

function DT.CreateHouse(iHouseId)
    local collectibleId = GetCollectibleIdForHouse(iHouseId)
    local name = GetCollectibleName(collectibleId)
    local nickname = GetCollectibleNickname(collectibleId)
    if nil ~= nickname and "" ~= nickname then
        name = string.format("%s (%s)", name, nickname)
    end
    return
    {
        HouseId = iHouseId,
        HouseName = name,
        ItemCount = 0,
        Items = {},
        BoundItemCount = 0,
        BoundItems = {},
    }
end

function DT.CreateBag(iBagId)
    if iBagId == nil then
        return
    end
    local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint
    local houseId

    if IsHouseBankBag(iBagId) then
        local collectibleId = GetCollectibleForBag(iBagId)
        name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleId)
        local nickname = GetCollectibleNickname(collectibleId)
        if nickname then
            name = name .. " (" .. nickname .. ")"
        else
            name = name
        end
        houseId = "BAG" .. tostring(iBagId)
    elseif iBagId == BAG_BACKPACK then
        name = GetUnitName("player")
        houseId = "BAG_BACKPACK_" .. tostring(GetCurrentCharacterId())
    else
        name = "Bank"
        houseId = "BAG" .. tostring(iBagId)
    end

    return
    {
        HouseId = houseId,
        HouseName = name,
        ItemCount = 0,
        Items = {},
        BoundItemCount = 0,
        BoundItems = {},
    }
end
