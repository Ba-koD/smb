-- Smart Meat Bandage - Mod Config Menu Module
local SMB_MCM = {}

local ConfigModule = include("smb_config")

function SMB_MCM.Setup(mod)
    if not ModConfigMenu then return end

    local category = "Smart Meat Bandage"
    ModConfigMenu.RemoveCategory(category)

    -- General Settings
    ModConfigMenu.AddSpace(category, "General")
    ModConfigMenu.AddText(category, "General", "--- General Settings ---")

    -- Enabled toggle
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.enabled end,
        Display = function() return "Mod Enabled: " .. (mod.Config.enabled and "ON" or "OFF") end,
        Info = {"Enable or disable the Smart Meat Bandage mod."},
        OnChange = function(b) mod.Config.enabled = b end,
    })

    -- Detection radius
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return mod.Config.detectionRadius end,
        Minimum = 100,
        Maximum = 800,
        Display = function() return "Detection Radius: " .. mod.Config.detectionRadius end,
        OnChange = function(n) mod.Config.detectionRadius = n end,
        Info = {"Set the detection radius for the Smart Meat Bandage mod."},
    })

    -- Flight Assist toggle
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.flightAssist end,
        Display = function() return "Flight Assist: " .. (mod.Config.flightAssist and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.flightAssist = b end,
        Info = {"Enable or disable the flight assist for the Smart Meat Bandage mod."},
    })

    -- Reset Button
    ModConfigMenu.AddSpace(category, "General")
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return false end,
        Display = function() return "Reset To Defaults" end,
        OnChange = function(b)
            if b then
                ConfigModule.Reset(mod)
                return false
            end
        end,
        Info = {"Reset the settings to their default values."},
    })

    -- Debug Settings
    ModConfigMenu.AddSpace(category, "Debug")
    ModConfigMenu.AddText(category, "Debug", "--- Debug Settings ---")

    ModConfigMenu.AddSetting(category, "Debug", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.showScreenDebug end,
        Display = function() return "Show Screen Debug: " .. (mod.Config.showScreenDebug and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.showScreenDebug = b end,
    })

    ModConfigMenu.AddSetting(category, "Debug", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return mod.Config.debugOffsetX end,
        Minimum = 0,
        Maximum = 800,
        Display = function() return "Debug X Offset: " .. mod.Config.debugOffsetX end,
        OnChange = function(n) mod.Config.debugOffsetX = n end,
    })

    ModConfigMenu.AddSetting(category, "Debug", {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function() return mod.Config.debugOffsetY end,
        Minimum = 0,
        Maximum = 450,
        Display = function() return "Debug Y Offset: " .. mod.Config.debugOffsetY end,
        OnChange = function(n) mod.Config.debugOffsetY = n end,
    })

    ModConfigMenu.AddSetting(category, "Debug", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.showSMBDebugInfo end,
        Display = function() return "Show SMB Debug Info: " .. (mod.Config.showSMBDebugInfo and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.showSMBDebugInfo = b end,
    })

    ModConfigMenu.AddSetting(category, "Debug", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.showFamiliarTargets end,
        Display = function() return "Show Familiar Targets: " .. (mod.Config.showFamiliarTargets and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.showFamiliarTargets = b end,
    })

    ModConfigMenu.AddSetting(category, "Debug", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.showLinkNumbers end,
        Display = function() return "Show Link Numbers: " .. (mod.Config.showLinkNumbers and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.showLinkNumbers = b end,
    })
end

return SMB_MCM 