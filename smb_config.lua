local SMB_Config = {}

-- ⚠️  VERSION update guide  ⚠️
-- 1. Check <version> value in metadata.xml
-- 2. Update VERSION below to match
-- 3. Keep both files at the same version!

local VERSION = "1.1"

SMB_Config.VERSION = VERSION

-- default config
local DefaultConfig = {
    enabled = true,
    detectionRadius = 400,
    flightAssist = true,
    -- debug
    showScreenDebug = false,
    showSMBDebugInfo = true,
    showFamiliarTargets = true,
    showLinkNumbers = true,
    debugOffsetX = 60,
    debugOffsetY = 40,
}

local json = nil
pcall(function() json = require("json") end)
if not json then
    json = {
        encode = function(data) return tostring(data) end,
        decode = function(str) return {} end,
    }
end

--------------------------------------------------
-- initialize: create Config table in mod object
--------------------------------------------------
function SMB_Config.Init(mod)
    mod.Config = mod.Config or {}
    for k, v in pairs(DefaultConfig) do
        if mod.Config[k] == nil then
            mod.Config[k] = v
        end
    end
    mod.Config.Version = VERSION
    return mod.Config
end

--------------------------------------------------
-- load saved config
--------------------------------------------------
function SMB_Config.Load(mod)
    if mod:HasData() then
        local ok, data = pcall(function() return json.decode(Isaac.LoadModData(mod)) end)
        if ok and type(data) == "table" then
            for k, v in pairs(DefaultConfig) do
                if data[k] ~= nil then
                    mod.Config[k] = data[k]
                end
            end
            return true
        end
    end
    return false
end

--------------------------------------------------
-- save config
--------------------------------------------------
function SMB_Config.Save(mod)
    Isaac.SaveModData(mod, json.encode(mod.Config))
end

--------------------------------------------------
-- reset: restore to default values and save
--------------------------------------------------
function SMB_Config.Reset(mod)
    for k, v in pairs(DefaultConfig) do
        mod.Config[k] = v
    end
    SMB_Config.Save(mod)
end

return SMB_Config 