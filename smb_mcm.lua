-- Smart Meat Bandage - Mod Config Menu Module
local SMB_MCM = {}

-- include config
local SMB_Config = include("smb_config")

function SMB_MCM.Setup(mod)
    if not ModConfigMenu then return end

    local category = "SMB v" .. SMB_Config.VERSION
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
        Minimum = 1,
        Maximum = 20,
        Display = function() return "Detection Radius: " .. mod.Config.detectionRadius .. " Grid" end,
        OnChange = function(n) mod.Config.detectionRadius = n end,
        Info = {"Set the detection radius in Grid units (1 Grid = 40 pixels) for the Smart Meat Bandage mod."},
    })

    -- Flight Assist toggle
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.flightAssist end,
        Display = function() return "Flight Assist: " .. (mod.Config.flightAssist and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.flightAssist = b end,
        Info = {"Enable or disable the flight assist for the Smart Meat Bandage mod."},
    })

    -- Flying Head Form toggle
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.flightHeadOnly end,
        Display = function() return "Flying Head Form: " .. (mod.Config.flightHeadOnly and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.flightHeadOnly = b end,
        Info = {"While the owner can fly, Meatboy / Bandage (Lv3 & Lv4)", "hide their walking body and only the head floats."},
    })

    -- Reset Button
    ModConfigMenu.AddSpace(category, "General")
    ModConfigMenu.AddSetting(category, "General", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return false end,
        Display = function() return "Reset To Defaults" end,
        OnChange = function(b)
            if b then
                SMB_Config.Reset(mod)
                return false
            end
        end,
        Info = {"Reset the settings to their default values."},
    })

    -- Familiars Settings
    ModConfigMenu.AddSpace(category, "Familiars")
    ModConfigMenu.AddText(category, "Familiars", "--- Familiar Targeting ---")

    -- ALL Familiars (master toggle)
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famAll end,
        Display = function() return "All Familiars: " .. (mod.Config.famAll and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famAll = b end,
        Info = {"Enable smart targeting for ALL familiars.", "Overrides individual settings below."},
    })

    ModConfigMenu.AddSpace(category, "Familiars")

    -- Cube of Meat (Lv3 & Lv4)
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famMeatboy end,
        Display = function() return "Meatboy: " .. (mod.Config.famMeatboy and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famMeatboy = b end,
        Info = {"Enable smart targeting for Cube of Meat (Lv3 & Lv4)."},
    })

    -- Ball of Bandages (Lv3 & Lv4)
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famBandage end,
        Display = function() return "Bandage: " .. (mod.Config.famBandage and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famBandage = b end,
        Info = {"Enable smart targeting for Ball of Bandages (Lv3 & Lv4)."},
    })

    ModConfigMenu.AddSpace(category, "Familiars")

    -- 14: DEAD_BIRD
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famDeadBird end,
        Display = function() return "Dead Bird: " .. (mod.Config.famDeadBird and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famDeadBird = b end,
        Info = {"Enable smart targeting for Dead Bird."},
    })

    -- 15: EVES_BIRD_FOOT
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famEvesBirdFoot end,
        Display = function() return "Eve's Bird Foot: " .. (mod.Config.famEvesBirdFoot and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famEvesBirdFoot = b end,
        Info = {"Enable smart targeting for Eve's Bird Foot."},
    })

    -- 48: ISAACS_BODY
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famIsaacsBody end,
        Display = function() return "Isaac's Body: " .. (mod.Config.famIsaacsBody and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famIsaacsBody = b end,
        Info = {"Enable smart targeting for Isaac's Body."},
    })

    -- 50: SMART_FLY
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famSmartFly end,
        Display = function() return "Smart Fly: " .. (mod.Config.famSmartFly and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famSmartFly = b end,
        Info = {"Enable smart targeting for Smart Fly."},
    })

    -- 56: LEECH
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famLeech end,
        Display = function() return "Leech: " .. (mod.Config.famLeech and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famLeech = b end,
        Info = {"Enable smart targeting for Leech."},
    })

    -- 63: LIL_HAUNT
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famLilHaunt end,
        Display = function() return "Lil Haunt: " .. (mod.Config.famLilHaunt and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famLilHaunt = b end,
        Info = {"Enable smart targeting for Lil Haunt."},
    })

    -- 79: GEMINI
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famGemini end,
        Display = function() return "Gemini: " .. (mod.Config.famGemini and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famGemini = b end,
        Info = {"Enable smart targeting for Gemini."},
    })

    -- 118: ANGRY_FLY
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famAngryFly end,
        Display = function() return "Angry Fly: " .. (mod.Config.famAngryFly and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famAngryFly = b end,
        Info = {"Enable smart targeting for Angry Fly."},
    })

    -- 210: BIRD_CAGE
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famBirdCage end,
        Display = function() return "Bird Cage: " .. (mod.Config.famBirdCage and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famBirdCage = b end,
        Info = {"Enable smart targeting for Bird Cage."},
    })

    -- 218: BOT_FLY
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famBotFly end,
        Display = function() return "Bot Fly: " .. (mod.Config.famBotFly and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famBotFly = b end,
        Info = {"Enable smart targeting for Bot Fly."},
    })

    -- 224: BABY_PLUM
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famBabyPlum end,
        Display = function() return "Baby Plum: " .. (mod.Config.famBabyPlum and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famBabyPlum = b end,
        Info = {"Enable smart targeting for Baby Plum."},
    })

    -- 228: MINISAAC
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famMinisaac end,
        Display = function() return "Minisaac: " .. (mod.Config.famMinisaac and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famMinisaac = b end,
        Info = {"Enable smart targeting for Minisaac."},
    })

    -- 241: BLOOD_PUPPY
    ModConfigMenu.AddSetting(category, "Familiars", {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function() return mod.Config.famBloodPuppy end,
        Display = function() return "Blood Puppy: " .. (mod.Config.famBloodPuppy and "ON" or "OFF") end,
        OnChange = function(b) mod.Config.famBloodPuppy = b end,
        Info = {"Enable smart targeting for Blood Puppy."},
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