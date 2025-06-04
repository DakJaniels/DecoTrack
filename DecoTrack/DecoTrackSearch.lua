---@class (partial) DecoTrack
local DT = DecoTrack
local chat = DT.chat
local eventManager = GetEventManager()

-- Search --

function DT.CreateSearchResults(sSearchText)
    return { ItemCount = 0, BoundItemCount = 0, SearchText = sSearchText, Categories = {} }
end

function DT.AddSearchResult(oResults, sContainerName, sItemCategory, sItemName, sLink, count, boundCount)
    if oResults ~= nil and sContainerName ~= nil and sItemName ~= nil then
        if not count then
            count = 1
        end

        oResults.ItemCount = oResults.ItemCount + count
        oResults.BoundItemCount = oResults.BoundItemCount + boundCount

        sItemCategory = sItemCategory or "Miscellaneous"
        sItemName = sItemName or ""
        sLink = sLink or ""
        sContainerName = sContainerName or ""

        local cat = oResults.Categories[sItemCategory]
        if not cat then
            cat = { Name = sItemCategory, NameLower = string.lower(sItemCategory), ItemCount = 0, BoundItemCount = 0, Items = {} }
            oResults.Categories[sItemCategory] = cat
        end
        cat.ItemCount = cat.ItemCount + count
        cat.BoundItemCount = cat.BoundItemCount + boundCount

        local item = cat.Items[sItemName]
        if not item then
            item = { ItemCount = 0, BoundItemCount = 0, ItemName = sItemName, NameLower = string.lower(sItemName), ItemLink = sLink, Containers = {}, BoundContainers = {}, }
            cat.Items[sItemName] = item
        end
        item.ItemCount = item.ItemCount + count
        item.BoundItemCount = item.BoundItemCount + boundCount

        item.Containers[sContainerName] = (item.Containers[sContainerName] or 0) + count
        item.BoundContainers[sContainerName] = (item.BoundContainers[sContainerName] or 0) + boundCount

        return true
    end

    return false
end

do
    local function CategoryComparer(left, right)
        return left.NameLower < right.NameLower
    end

    local function ItemComparer(left, right)
        return left.NameLower < right.NameLower
    end

    local function ContainerComparer(left, right)
        return left.NameLower < right.NameLower
    end

    function DT.SearchItems(itemName)
        eventManager:UnregisterForUpdate("DecoTrack_SearchItems")

        if DT.IsDirty then
            chat:Print("One moment please...")
            eventManager:RegisterForUpdate("DecoTrack_SearchItems", 2000, function () DT.SearchItems(itemName) end)
            return
        end

        itemName = string.lower(itemName)
        local results = DT.CreateSearchResults(itemName)
        local bFound

        chat:Printf("%s is searching for '%s' ...", DT.ADDON_NAME, itemName)

        for zoneId, house in pairs(DT.Data.Houses) do
            for itemId, count in pairs(house.Items) do
                local _, name, link, category, subcategory = DT.GetFurnitureInfo(itemId)
                local boundCount = house.BoundItems[itemId] or 0

                bFound, _, _ = PlainStringFind(string.lower(name), itemName)
                if bFound then
                    DT.AddSearchResult(results, house.HouseName, category, name, link, count, boundCount)
                end

                if not bFound then
                    bFound, _, _ = PlainStringFind(string.lower(category), itemName)
                    if bFound then
                        DT.AddSearchResult(results, house.HouseName, category, name, link, count, boundCount)
                    end
                end

                if not bFound then
                    bFound, _, _ = PlainStringFind(string.lower(house.HouseName), itemName)
                    if bFound then
                        DT.AddSearchResult(results, house.HouseName, category, name, link, count, boundCount)
                    end
                end
            end
        end

        do
            local categories = results.Categories
            local newCategories = {}
            results.SortedCategories = newCategories
            for catName, cat in pairs(categories) do
                table.insert(newCategories, cat)

                local items = cat.Items
                local newItems = {}
                cat.SortedItems = newItems
                for itemKey, item in pairs(items) do
                    table.insert(newItems, item)

                    local containers = item.Containers
                    local newContainers = {}
                    item.SortedContainers = newContainers
                    for containerName, count in pairs(containers) do
                        table.insert(newContainers,
                                     {
                                         Name = containerName,
                                         NameLower = string.lower(containerName),
                                         ItemCount = count,
                                         BoundItemCount = item.BoundContainers[containerName] or 0
                                     })
                    end
                    table.sort(newContainers, ContainerComparer)
                end
                table.sort(newItems, ItemComparer)
            end
            table.sort(newCategories, CategoryComparer)
        end

        for _, cat in ipairs(results.SortedCategories) do
            chat:Printf(DT.GenerateItemCountLine("      " .. string.upper(cat.Name), cat.ItemCount, cat.BoundItemCount, 0))

            for _, item in ipairs(cat.SortedItems) do
                chat:Printf(DT.GenerateItemCountLine(item.ItemLink, item.ItemCount, item.BoundItemCount, 0))

                for _, container in ipairs(item.SortedContainers) do
                    chat:Printf(DT.GenerateItemCountLine(container.Name, container.ItemCount, container.BoundItemCount, 1))
                end
            end
        end

        chat:Printf(DT.GenerateItemCountLine("Total", results.ItemCount, results.BoundItemCount))
    end
end

do
    local NormalColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
    local SelectedColor = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))

    function DT.GenerateItemCountLine(label, totalCount, boundCount, indent)
        totalCount, boundCount = totalCount or 0, boundCount or 0
        local unboundCount = totalCount - boundCount
        local unboundString = unboundCount <= 0 and "" or tostring(unboundCount) .. DT.UNBOUND_TEXTURE
        local boundString = boundCount <= 0 and "" or tostring(boundCount) .. DT.BOUND_TEXTURE
        local nameString = NormalColor:Colorize(string.format("%s%s", indent and indent > 0 and "+ " or "", label or ""))
        local quantityString = SelectedColor:Colorize(string.format(" x%s%s|r", unboundString, boundString))
        return nameString .. quantityString
    end
end

function DT.GenerateTooltipInfo(itemLink)
    local tooltip = {}
    local total = 0
    local totalBound = 0
    local totalString = ""

    if itemLink and DT.Data and DT.Data.Houses then
        local itemId = DT.GetItemId(itemLink)

        if itemId then
            for zoneId, house in pairs(DT.Data.Houses) do
                if house.Items then
                    local count = house.Items[itemId]
                    if count and 0 < count then
                        local boundCount = house.BoundItems[itemId] or 0
                        total = total + count
                        totalBound = totalBound + boundCount
                        table.insert(tooltip, DT.GenerateItemCountLine(house.HouseName, count, boundCount))
                    end
                end
            end
        end
    end

    if 1 < #tooltip then
        table.sort(tooltip)

        if 0 < total then
            totalString = DT.GenerateItemCountLine("Total", total, totalBound)
        end
    end

    return table.concat(tooltip, "\n"), totalString
end
