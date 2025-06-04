---@class (partial) DecoTrack
local DT = DecoTrack

-- Housing Methods --

---@return boolean isOwner True if the player owns the current house
function DT.IsHouseOwner()
    return IsOwnerOfCurrentHouse()
end

---@param bagId Bag The bag ID to check
---@return boolean isAccessible True if the bag is accessible (has items or empty slots)
function DT.IsBagAccessible(bagId)
    return not (0 == GetNumBagUsedSlots(bagId) and 0 == FindFirstEmptySlotInBag(bagId))
end

---@param itemId integer|string The ID to check if it's a collectible
---@return boolean isCollectible True if the ID is a valid collectible
---@return string name The collectible name if valid, empty string otherwise
---@return string link The collectible link if valid, empty string otherwise
function DT.IsItemIdCollectible(itemId)
    local collectibleId = tonumber(itemId)
    if collectibleId then
        local cName = GetCollectibleName(collectibleId)
        local cLink = GetCollectibleLink(collectibleId, LINK_STYLE_DEFAULT)
        return "" ~= cName, cName, cLink
    end
    return false, "", ""
end

---@param itemId integer|string The ID to check if it's furniture
---@return boolean isFurniture True if the ID is valid furniture
---@return string|nil name The furniture name if valid, nil otherwise
---@return string|nil link The furniture link if valid, nil otherwise
function DT.IsItemIdFurniture(itemId)
    local fLink = DT.GetFurnitureItemIdLink(itemId)
    if IsItemLinkPlaceableFurniture(fLink) then
        local fName = GetItemLinkName(fLink)
        return true, fName, fLink
    end
    return false, nil, nil
end

---@param id id64 The placed furniture ID
---@return string link The furniture link, or collectible link if furniture link is not available
function DT.GetFurnitureLink(id)
    local link, collectibleLink = GetPlacedFurnitureLink(id, LINK_STYLE_BRACKETS)
    if nil == link or "" == link then
        return collectibleLink
    end
    return link
end

---@param link string The furniture or collectible link to parse
---@return string|integer|nil itemId The extracted item ID from the link, or nil if invalid
function DT.GetFurnitureLinkItemId(link)
    if nil == link or "" == link then
        return nil
    end

    local startIndex

    if string.sub(link, 4, 9) == ":item:" then
        startIndex = 10
    elseif string.sub(link, 4, 16) == ":collectible:" then
        startIndex = 17
    else
        return link
    end

    local colonIndex = string.find(link, ":", startIndex + 1)
    local pipeIndex = string.find(link, "|", startIndex + 1)

    if nil == colonIndex and nil == pipeIndex then return nil end
    if nil ~= colonIndex and nil ~= pipeIndex then colonIndex = math.min(colonIndex, pipeIndex) end

    return tonumber(string.sub(link, startIndex, (nil ~= colonIndex and colonIndex or pipeIndex) - 1))
end

---@param id id64 The placed furniture ID
---@return integer|nil itemId The furniture item ID if found, nil otherwise
---@return string|nil link The furniture link if found, nil otherwise
function DT.GetFurnitureItemId(id)
    local link = DT.GetFurnitureLink(id)
    return DT.GetFurnitureLinkItemId(link), link
end

---@param itemId integer|string The item ID to create a link for
---@return string|nil link The created furniture or collectible link, or nil if invalid
function DT.GetFurnitureItemIdLink(itemId)
    itemId = tonumber(itemId)
    if nil == itemId then
        return nil
    end

    if 10000 > itemId then
        return "|H1:collectible:" .. tostring(itemId) .. "|h|h"
    else
        return "|H1:item:" .. tostring(itemId) .. string.rep(":0", 20) .. "|h|h"
    end
end

---@param itemId integer|nil The ID of the furniture or collectible item to get info for
---@return integer|nil itemId The original item ID if furniture, or nil if not found
---@return string|nil name The display name of the furniture/collectible
---@return string|nil link The item link for the furniture/collectible
---@return string|nil category The furniture category name
---@return string|nil subcategory The furniture subcategory name
---@return integer|nil id The item ID if furniture, or collectible ID if collectible
function DT.GetFurnitureInfo(itemId)
    if nil == itemId then
        return nil
    end

    local category, link, isFurniture, isCollectible, name, subcategory

    isFurniture, name, link = DT.IsItemIdFurniture(itemId)
    if isFurniture then
        local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(GetItemLinkFurnitureDataId(link))

        category = GetFurnitureCategoryInfo(categoryId)
        subcategory = GetFurnitureCategoryInfo(subcategoryId)

        return itemId, name, link, category, subcategory, itemId
    end

    isCollectible, name, link = DT.IsItemIdCollectible(itemId)
    if isCollectible then
        local collectibleId = GetCollectibleIdFromLink(link)
        local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(GetCollectibleFurnitureDataId(collectibleId))

        category = GetFurnitureCategoryInfo(categoryId)
        subcategory = GetFurnitureCategoryInfo(subcategoryId)

        return itemId, name, link, category, subcategory, collectibleId
    end

    return nil
end

function DT.GetItemId(idOrLink)
    if idOrLink == nil then
        return nil
    end

    local itemId

    if "string" == type(idOrLink) then
        itemId = DT.GetFurnitureLinkItemId(idOrLink)
    else
        itemId = DT.GetFurnitureItemId(idOrLink)
    end

    if nil ~= itemId then
        if not DT.IsItemIdCollectible(itemId) then
            return itemId
        end
    end
end

function DT.GetLimitType(link)
    local itemId = DT.GetItemId(link)
    local dataId

    if GetCollectibleLink(itemId, LINK_STYLE_DEFAULT) then
        dataId = GetCollectibleFurnitureDataId(itemId)
    else
        dataId = GetItemLinkFurnitureDataId(link)
    end

    if dataId then
        local _, _, _, limitType = GetFurnitureDataInfo(dataId)
        local limitName = DT.LIMITS[limitType]

        return limitName, limitType
    end
end
