---@class (partial) DecoTrack
local DT = DecoTrack
local chat = DT.chat
local eventManager = GetEventManager()

-- Slash Commands --

function DT.SlashCommand(commandArgs)
    local options = {}
    local searchResult = { string.match(commandArgs, "^(%S*)%s*(.-)$") }

    for i, v in pairs(searchResult) do
        if v ~= nil and v ~= "" then
            options[#options + 1] = string.lower(v)
        end
    end

    if #options == 0 then
        local slash = "/deco"

        chat:Printf("%s Commands...", DT.ADDON_NAME)
        chat:Print("__________________________")
        chat:Print("GENERAL")
        chat:Printf("%s update", slash)
        chat:Printf("  Automatically visits every house that you own,")
        chat:Printf("  updating the furniture database for each house.")
        chat:Printf("%s totals", slash)
        chat:Printf("  Reports item count totals for each character, house and bank.")
        chat:Print("__________________________")
        chat:Print("SEARCHES")
        chat:Printf("%s item", slash)
        chat:Printf("  Searches all items for the specified item name.")
        chat:Printf("  You may also use part of the item name.")
        chat:Printf("%s bank", slash)
        chat:Printf("  Searches all items in your bank.")
        chat:Printf("%s category", slash)
        chat:Printf("  Searches all items in the specified category.")
        chat:Printf("  You may use part of the category name.")
        chat:Printf("%s character", slash)
        chat:Printf("  Searches all items in the specified character's inventory.")
        chat:Printf("%s coffer", slash)
        chat:Printf("  Searches all items in the specified house storage coffer or chest.")
        chat:Printf("  You may use part of the coffer or chest's name or nickname.")
        chat:Printf("%s house", slash)
        chat:Printf("  Searches all items in the specified house.")
        chat:Printf("  You may use part of the house name.")
        chat:Printf("|r\nDecoTrack version " .. DT.ADDON_VERSION .. " installed.")

        return
    end

    if "update" == options[1] then
        DT.UpdateAllHouses()
        return
    end

    if "total" == options[1] or "totals" == options[1] then
        DT.ReportTotals()
        return
    end

    if "cancel" == options[1] then
        if DT.UpdatingAllHouses then
            chat:Printf("Update process has been aborted.")
            DT.UpdatingAllHouses = nil
            eventManager:UnregisterForEvent(DT.ADDON_NAME, EVENT_ADD_ON_LOADED)
            CancelCast()

            return
        end

        chat:Printf("There is no update in progress.")
        return
    end

    DT.SearchItems(commandArgs)
end
