---@class (partial) DecoTrack
local DT = DecoTrack
local LAM = LibAddonMenu2

-- Settings --

function DT.InitSettings()
    local panelName = DT.ADDON_NAME .. "LAM"
    local panelData =
    {
        type = "panel",
        name = DT.ADDON_NAME,
        displayName = DT.ADDON_NAME .. " - Settings",
        author = DT.ADDON_AUTHOR,
        version = DT.ADDON_VERSION,
        slashCommand = "/decotracksettings",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    local options = {}

    table.insert(options,
                 {
                     type = "custom",
                 })

    table.insert(options,
                 {
                     type = "header",
                     name = "Furniture Database",
                 })

    table.insert(options,
                 {
                     type = "button",
                     name = "Update All Homes",
                     func = function ()
                         if DT.UpdatingAllHouses then
                             DT.SlashCommand("cancel")
                         else
                             DT.SlashCommand("update")
                         end
                         SCENE_MANAGER:HideCurrentScene()
                     end,
                     tooltip = "Automatically visits every home that you own in order to update your furniture database with the items placed in each home.\n\n" ..
                         "NOTE:\n" ..
                         "This is typically only necessary when " .. DT.ADDON_NAME .. " is first installed or after clearing and resetting the furniture database.\n\n" ..
                         "Once each home has been visited once - by you or by using this feature - " .. DT.ADDON_NAME .. " automatically updates your database upon subsequent visits, provided that you keep the " .. DT.ADDON_NAME .. " add-on enabled for all characters.",
                     disabled = false,
                     requiresReload = false,
                 })

    table.insert(options,
                 {
                     type = "button",
                     name = "Clear and Reset",
                     func = function ()
                         DT.ResetEntireDatabase()
                     end,
                     tooltip = "Clears all furniture from your " .. DT.ADDON_NAME .. " database for your " .. GetDisplayName() .. " account, including your bank and characters, homes and storage chests.",
                     disabled = false,
                     isDangerous = true,
                     requiresReload = true,
                     warning = "Are you sure that you want to clear all furniture from your " .. DT.ADDON_NAME .. " database for your " .. GetDisplayName() .. " account, including your bank and characters, homes and storage chests?\n\n" ..
                         "You should only do this if you wish to start DecoTrack over completely fresh as this will require you to once again log into each character and visit each of your homes in order to rebuild your furniture database.\n\n" ..
                         "NOTE: This will require a UI reload.",
                 })

    table.insert(options,
                 {
                     type = "custom",
                 })

    for index, opt in ipairs(options) do
        if "string" == type(opt.key) and nil ~= opt.default then
            DT.SetDefaultSetting(opt.key, opt.default)
        end
    end

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, options)
end

function DT.SetDefaultSetting(settingName, value)
    if "string" == type(settingName) and "" ~= settingName then
        DT.DefaultSettings[settingName] = value
    end
end

function DT.GetSetting(settingName, suppressDefault)
    local value = DT.Data.Settings[settingName]
    if nil == value and not suppressDefault then
        value = DT.DefaultSettings[settingName]
    end
    return value
end

function DT.SetSetting(settingName, value)
    DT.Data.Settings[settingName] = value
end
