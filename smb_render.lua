-- Smart Meat Bandage - Render Module (smb_render.lua)
local SMB_Render = {}

local game = Game()

--------------------------------------------------
-- Helper to render text line by line
--------------------------------------------------
local function renderLine(text, x, y, r, g, b)
    Isaac.RenderText(text, x, y, r or 255, g or 255, b or 255, 255)
end

--------------------------------------------------
-- Render number above world position (with border)
--------------------------------------------------
local function renderWorldNumber(num, pos)
    local screen = Isaac.WorldToScreen(pos)
    local text = tostring(num)
    local scale = 0.8
    local offsetY = -25
    -- border
    for dx=-1,1 do
        for dy=-1,1 do
            if dx~=0 or dy~=0 then
                Isaac.RenderScaledText(text, screen.X+dx, screen.Y+offsetY+dy, scale, scale, 0,0,0,1)
            end
        end
    end
    Isaac.RenderScaledText(text, screen.X, screen.Y+offsetY, scale, scale, 1,1,1,1)
end

--------------------------------------------------
function SMB_Render:PostRender()
    local mod = SmartMB -- global from smb_core
    if not mod or not mod.Config or not mod.Config.showScreenDebug then return end

    local x = mod.Config.debugOffsetX or 60
    local y = mod.Config.debugOffsetY or 40
    local lineH = 14

    local fams = Isaac.FindInRadius(Vector(0,0), 100000, EntityPartition.FAMILIAR)

    if mod.Config.showSMBDebugInfo then
        renderLine("=== SMB Debug ===", x, y, 255, 255, 0); y = y + lineH
        renderLine("Enabled: " .. tostring(mod.Config.enabled), x, y); y = y + lineH
        renderLine("FlightAssist: " .. tostring(mod.Config.flightAssist), x, y); y = y + lineH
        renderLine("DetectionRadius: " .. tostring(mod.Config.detectionRadius), x, y); y = y + lineH

        local players = Isaac.FindByType(EntityType.ENTITY_PLAYER)
        local playerEnt = players[1] and players[1]:ToPlayer() or nil
        local canFlyStr = "nil"
        if playerEnt and playerEnt.CanFly ~= nil then
             canFlyStr = tostring(playerEnt.CanFly)
        end
        renderLine("PlayerCanFly: " .. canFlyStr, x, y, 150,150,255); y = y + lineH

        -- Count familiars in room
        local famCount = 0
        local activeCount = 0
        for _, ent in ipairs(fams) do
            if ent:ToFamiliar() then
                famCount = famCount + 1
                if ent.Target then activeCount = activeCount + 1 end
            end
        end
        renderLine("Familiars: " .. famCount .. " (active " .. activeCount .. ")", x, y); y = y + lineH

        renderLine("Frame: " .. game:GetFrameCount(), x, y, 150,150,255); y = y + lineH
    end

    if mod.Config.showFamiliarTargets then
    -- Familiar target info
    local famsInfoShown = 0
    renderLine("-- Familiar Targets --", x, y, 255,255,0); y = y + lineH
    for _, ent in ipairs(fams) do
        local fam = ent:ToFamiliar()
        if fam and fam.Variant and SmartMB.ControlledVariants then
            for _, v in ipairs(SmartMB.ControlledVariants) do
                if fam.Variant == v then
                    local tgt = fam.Target
                    local tgtStr = "nil"
                    if tgt and tgt:Exists() then
                        tgtStr = string.format("ID:%d HP:%.1f", tgt.InitSeed or 0, tgt.HitPoints or 0)
                    end
                    renderLine(string.format("Fam(%d) -> %s", fam.InitSeed, tgtStr), x, y, 200,200,200)
                    y = y + lineH
                    famsInfoShown = famsInfoShown + 1
                    if famsInfoShown >= 6 then break end
                end
            end
        end
        if famsInfoShown >= 6 then break end
    end

    end -- end of showFamiliarTargets block

    -- ===== Familiar-Target Link Numbers =====
    if mod.Config.showLinkNumbers then
        if game:IsPaused() or (ModConfigMenu and ModConfigMenu.IsVisible) then return end

        local famPairs = {}
        local tgtIdMap = {}
        local nextId = 1
        for _, ent in ipairs(fams) do
            local fam = ent:ToFamiliar()
            if fam and SmartMB.ControlledVariants then
                for _, v in ipairs(SmartMB.ControlledVariants) do
                    if fam.Variant == v then
                        local tgt = fam.Target
                        if tgt and tgt:Exists() and not tgt:IsDead() then
                            local key = tgt.InitSeed
                            if not tgtIdMap[key] then
                                tgtIdMap[key] = nextId
                                nextId = nextId + 1
                            end
                            local id = tgtIdMap[key]
                            table.insert(famPairs,{fam=fam,tgt=tgt,id=id})
                        end
                    end
                end
            end
        end

        for _, pair in ipairs(famPairs) do
            renderWorldNumber(pair.id, pair.fam.Position)
            renderWorldNumber(pair.id, pair.tgt.Position)
        end
    end
end

-- Register to PostRender callback
SmartMB:AddCallback(ModCallbacks.MC_POST_RENDER, function() SMB_Render:PostRender() end) 

return SMB_Render 