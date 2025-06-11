---@class (partial) DecoTrack
local DT = DecoTrack

-- Interoperability --
local Interop = DT.Interop

-- Utility Methods --

---
---@param s string
---@return string|nil
local function trim(s)
    if s then
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    else
        return nil
    end
end

local CALLBACK_MANAGER = ZO_CallbackObject:Subclass()
Interop.CallbackManager = CALLBACK_MANAGER:New()

function Interop.CallbackManager:OnFullUpdate()
    if not self.IsFiringCallbacks then
        self.IsFiringCallbacks = true
        self:FireCallbacks("FullUpdate", self)
        self.IsFiringCallbacks = false
    end
end

function Interop.GetAPI()
    return 5
end

function Interop.GetCountsByItemId(pItemId)
    local containers = {}
    local boundContainers = {}

    if nil == pItemId then
        return containers, boundContainers
    end

    for containerId, container in pairs(DT.Data.Houses) do
        local count = container.Items[pItemId]
        if nil ~= count then
            containers[container.HouseName] = count
        end

        local boundCount = container.BoundItems[pItemId]
        if nil ~= boundCount then
            boundContainers[container.HouseName] = boundCount
        end
    end

    return containers, boundContainers
end

function Interop.AddSearchResult(results, category, link, count, boundCount, containerName)
    local categoryObj = results.Categories[category]
    if not categoryObj then
        categoryObj =
        {
            Count = 0,
            BoundCount = 0,
            Items = {}
        }
        results.Categories[category] = categoryObj
    end

    local itemObj = categoryObj.Items[link]
    if not itemObj then
        itemObj =
        {
            Count = 0,
            BoundCount = 0,
            Containers = {},
            BoundContainers = {},
        }
        categoryObj.Items[link] = itemObj
    end

    results.Count = results.Count + count
    results.BoundCount = results.BoundCount + boundCount
    categoryObj.Count = categoryObj.Count + count
    categoryObj.BoundCount = categoryObj.BoundCount + boundCount
    itemObj.Count = itemObj.Count + count
    itemObj.BoundCount = itemObj.BoundCount + boundCount
    itemObj.Containers[containerName] = count
    itemObj.BoundContainers[containerName] = boundCount
end

local function CompileFilter(filter)
    if not filter then
        return
    end

    filter = string.lower(trim(filter))
    if "" == filter then
        return
    end

    filter = (string.gsub((string.gsub(filter, "\\+ +", "\\+")), "\\- +", "\\-"))

    local terms =
    {
        SplitString(" ", filter)
    }
    if not terms then
        return
    end

    local anyTerms = {}
    local includeTerms = {}
    local excludeTerms = {}
    local term

    for index = 1, #terms do
        term = trim(terms[index])

        if term and "" ~= term then
            if "-" == string.sub(term, 1, 1) then
                term = string.sub(term, 2)
                table.insert(excludeTerms, term)
            elseif "+" == string.sub(1, 1) then
                term = string.sub(term, 2)
                table.insert(includeTerms, term)
            else
                -- table.insert( anyTerms, term )
                table.insert(includeTerms, term)
            end
        end
    end

    local t =
    {
        anyTerms,
        includeTerms,
        excludeTerms
    }

    return t
end

local function IsMatch(compiledFilter, expression)
    if not compiledFilter then
        return true
    end

    local anyTerms = compiledFilter[1]
    local include = compiledFilter[2]
    local exclude = compiledFilter[3]
    local hasAny = 0 == #anyTerms

    expression = string.lower(trim(expression or ""))

    for index = 1, #anyTerms do
        if PlainStringFind(expression, anyTerms[index]) then
            hasAny = true
            break
        end
    end

    if not hasAny then
        return false
    end

    for index = 1, #include do
        if not PlainStringFind(expression, include[index]) then
            return false
        end
    end

    for index = 1, #exclude do
        if PlainStringFind(expression, exclude[index]) then
            return false
        end
    end

    return true
end

function Interop.Search(search)
    local results = { Count = 0, BoundCount = 0, Categories = {} }
    local matched

    if nil == search then return results end
    local filter = CompileFilter(search)
    local _, name, link, category, subcategory

    for containerId, container in pairs(DT.Data.Houses) do
        for itemId, count in pairs(container.Items) do
            _, name, link, category, subcategory = DT.GetFurnitureInfo(itemId)

            if IsMatch(filter, string.format("%s\n%s\n%s", tostring(name), tostring(category), tostring(container.HouseName))) then
                local boundCount = container.BoundItems[itemId] or 0
                Interop.AddSearchResult(results, category, link, count, boundCount, container.HouseName)
            end
        end
    end

    return results
end

function Interop.HasVisitedAllOwnedHomes()
    if nil == DT.hasVisitedAllOwnedHomes then
        DT.hasVisitedAllOwnedHomes = {}

        for houseId = 1, DT.MAX_HOUSE_ID do
            local collectibleId = GetCollectibleIdForHouse(houseId)
            if 0 ~= collectibleId and IsCollectibleUnlocked(collectibleId) then
                local house = DT.Data.Houses[houseId]
                if not house or nil == house.ItemCount or nil == house.BoundItemCount then
                    table.insert(DT.hasVisitedAllOwnedHomes, houseId)
                end
            end
        end
    end

    return #DT.hasVisitedAllOwnedHomes == 0
end

DT.Interop = Interop
