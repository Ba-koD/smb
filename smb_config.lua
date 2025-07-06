-- Smart Meat Bandage - Configuration Module
-- 설정 처리를 메인 로직과 분리하여 관리
local SMB_Config = {}

local VERSION = "1.0"

-- 기본값 정의
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

-- JSON (Repentance 내장 json 사용, 없으면 더미)
local json = nil
pcall(function() json = require("json") end)
if not json then
    json = {
        encode = function(data) return tostring(data) end,
        decode = function(str) return {} end,
    }
end

--------------------------------------------------
-- 초기화: 모드 객체에 Config 테이블 생성
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
-- 저장된 설정 불러오기
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
-- 설정 저장
--------------------------------------------------
function SMB_Config.Save(mod)
    Isaac.SaveModData(mod, json.encode(mod.Config))
end

--------------------------------------------------
-- 리셋: 기본값으로 되돌리고 저장
--------------------------------------------------
function SMB_Config.Reset(mod)
    for k, v in pairs(DefaultConfig) do
        mod.Config[k] = v
    end
    SMB_Config.Save(mod)
end

return SMB_Config 