---@class (partial) DecoTrack
local DT = DecoTrack

function DT.Initialize()
    local SAVED_VAR_VERSION = 2
    DT.Data = ZO_SavedVars:NewAccountWide("DecoTrackSavedVars", SAVED_VAR_VERSION, nil, nil, GetWorldName(), zo_strformat(GetString(SI_UNIT_NAME), GetDisplayName()))
    DT.InitDataSettings(DT.Data)
    DT.InitSettings()
    DT.InitHouses(DT.Data)
    DT.RegisterTooltips()

    SLASH_COMMANDS["/deco"] = DT.SlashCommand
end
