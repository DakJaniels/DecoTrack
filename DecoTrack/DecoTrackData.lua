---@class (partial) DecoTrack
local DT = DecoTrack

-- Data --

function DT.InitHouses(data)
    if nil == data.Houses then
        data.Houses = {}
    end

    -- Initialize each house with the required structure
    for houseId, house in pairs(data.Houses) do
        if not house.BoundItems then
            house.BoundItems = {}
        end
        if not house.Items then
            house.Items = {}
        end
        if not house.ItemCount then
            house.ItemCount = 0
        end
        if not house.BoundItemCount then
            house.BoundItemCount = 0
        end
    end
end

function DT.InitDataSettings(data)
    if nil == data.Settings then
        data.Settings = {}
    end
end

function DT.UpdateTooltip(control, link)
    local addenda, total = DT.GenerateTooltipInfo(link)

    if (addenda and "" ~= addenda) then
        ZO_Tooltip_AddDivider(control)
        control:AddLine(addenda, "$(MEDIUM_FONT)|$(KB_16)")

        if total and "" ~= total then
            control:AddLine(total, "$(MEDIUM_FONT)|$(KB_16)", nil, nil, nil, nil, nil, TEXT_ALIGN_CENTER)
        end
    end
end

do
    local function ShadowTooltipMethod(control, method, linkFunction)
        local original = control[method]

        control[method] = function (object, ...)
            if original then
                original(object, ...)
            end

            local link = linkFunction(...)
            if link then
                DT.UpdateTooltip(object, link)
            end
        end
    end

    function DT.RegisterTooltips()
        ShadowTooltipMethod(PopupTooltip, "SetLink", function (link) return link end)
        ShadowTooltipMethod(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
        ShadowTooltipMethod(ItemTooltip, "SetBagItem", GetItemLink)
        ShadowTooltipMethod(ItemTooltip, "SetLootItem", GetLootItemLink)
        ShadowTooltipMethod(ItemTooltip, "SetStoreItem", GetStoreItemLink)
        ShadowTooltipMethod(ItemTooltip, "SetTradeItem", GetTradeItemLink)
        ShadowTooltipMethod(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
        ShadowTooltipMethod(ItemTooltip, "SetPlacedFurniture", function (id) return DT.GetFurnitureLink(id) end)

        if AwesomeGuildStore then
            AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_INITIAL_SETUP, function ()
                ShadowTooltipMethod(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
            end)
        else
            ShadowTooltipMethod(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
        end
    end
end


function DT.AddHouseItem(house, itemId, stackSize, bound)
    if house ~= nil and house.Items ~= nil and itemId ~= nil then
        stackSize = stackSize or 1

        house.Items[itemId] = (house.Items[itemId] or 0) + stackSize
        house.ItemCount = (house.ItemCount or 0) + stackSize

        if bound then
            house.BoundItems[itemId] = (house.BoundItems[itemId] or 0) + stackSize
            house.BoundItemCount = (house.BoundItemCount or 0) + stackSize
        else
            house.BoundItems[itemId] = (house.BoundItems[itemId] or 0)
            house.BoundItemCount = (house.BoundItemCount or 0)
        end
    end
end

do
    local CachedKeys = {}

    function DT.GetHouseByCollectibleId(collectibleId)
        collectibleId = tonumber(collectibleId)
        if collectibleId then
            local key = CachedKeys[collectibleId]

            if not key then
                local bagId = GetBagForCollectible(collectibleId)
                if bagId then
                    key = string.format("BAG%d", bagId)
                end

                if not key then
                    for houseId = 1, DT.MAX_HOUSE_ID do
                        local houseCollectibleId = GetCollectibleIdForHouse(houseId)
                        if houseCollectibleId == collectibleId then
                            key = houseId
                            break
                        end
                    end
                end

                if not key then
                    local characterId = collectibleId
                    key = string.format("BAG%d", characterId)
                end

                if key then
                    CachedKeys[collectibleId] = key
                end
            end

            return DT.Data.Houses[key]
        end

        return nil
    end
end

function DT.ResetEntireDatabase()
    DT.Data.Houses = {}
    DT.InitHouses(DT.Data)
end
