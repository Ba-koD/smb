-- Smart Meat Bandage - Flying Head Form (smb_flyform.lua)
-- While the owner can fly, Meatboy / Bandage Girl (Lv3 & Lv4) drop their
-- walking body and only the head floats around.
--
-- All four vanilla anm2 files share the same layer layout:
--   Layer 0 = "body" (gfx/monsters/Classic/Monster_000_Bodies01b.png)
--   Layer 1 = "head" (familiar specific spritesheet)
-- so hiding layer 0 is enough. There is no layer visibility API in the
-- vanilla Lua bindings, so the body spritesheet is swapped for a fully
-- transparent one instead (same 512x160 size to keep the crops in bounds).

local SMB_FlyForm = {}

local game = Game()

local HEAD_ONLY_VARIANTS = {
    [46] = true,  -- CUBE_OF_MEAT_3
    [47] = true,  -- CUBE_OF_MEAT_4
    [71] = true,  -- BALL_OF_BANDAGES_3
    [72] = true,  -- BALL_OF_BANDAGES_4
}

local BODY_LAYER  = 0
local BODY_SHEET  = "gfx/monsters/Classic/Monster_000_Bodies01b.png"
local BLANK_SHEET = "gfx/smb_blank.png"

-- floating motion of the head
local BOB_SPEED     = 0.08  -- radians per update
local BOB_AMPLITUDE = 2     -- pixels
local BOB_LIFT      = 2     -- extra pixels above the ground position

--------------------------------------------------
-- Helper: owner of the familiar (same rule as smb_core)
--------------------------------------------------
local function getOwner(fam)
    if fam.Player and type(fam.Player) ~= "boolean" then
        local p = fam.Player:ToPlayer()
        if p then return p end
    end
    return game:GetNearestPlayer(fam.Position)
end

--------------------------------------------------
-- Helper: show/hide the walking body layer
--------------------------------------------------
local function setBodyVisible(fam, visible)
    local spr = fam:GetSprite()

    -- GetAnimation() only exists on Repentance+, so ask for it safely
    local ok, anim = pcall(function() return spr:GetAnimation() end)
    local frame = spr:GetFrame()

    spr:ReplaceSpritesheet(BODY_LAYER, visible and BODY_SHEET or BLANK_SHEET)
    spr:LoadGraphics()

    -- LoadGraphics may rewind the sprite, so restore where it was
    if ok and type(anim) == "string" and anim ~= "" then
        spr:SetFrame(anim, frame)
    end
end

--------------------------------------------------
-- Callback: familiar update
--------------------------------------------------
function SMB_FlyForm:OnFamiliarUpdate(fam)
    if not HEAD_ONLY_VARIANTS[fam.Variant] then return end

    local cfg = SmartMB and SmartMB.Config
    if not cfg then return end

    local data = fam:GetData()
    local headOnly = false
    if cfg.enabled and cfg.flightHeadOnly then
        local player = getOwner(fam)
        headOnly = (player ~= nil and player.CanFly)
    end

    if data.smbNeedsRefresh or headOnly ~= (data.smbHeadOnly == true) then
        setBodyVisible(fam, not headOnly)
        data.smbHeadOnly    = headOnly
        data.smbNeedsRefresh = nil
        if not headOnly then
            data.smbBobTime = nil
            fam.SpriteOffset = Vector(0, 0)
        end
    end

    if headOnly then
        data.smbBobTime = (data.smbBobTime or 0) + BOB_SPEED
        fam.SpriteOffset = Vector(0, math.sin(data.smbBobTime) * BOB_AMPLITUDE - BOB_LIFT)
    end
end

--------------------------------------------------
-- Callback: new room / new level
-- Familiar sprites can be reloaded between rooms, so re-apply the current
-- state once instead of trusting the cached one.
--------------------------------------------------
function SMB_FlyForm:OnNewRoom()
    local fams = Isaac.FindInRadius(Vector(0, 0), 100000, EntityPartition.FAMILIAR)
    for _, ent in ipairs(fams) do
        local fam = ent:ToFamiliar()
        if fam and HEAD_ONLY_VARIANTS[fam.Variant] then
            fam:GetData().smbNeedsRefresh = true
        end
    end
end

--------------------------------------------------
-- register
--------------------------------------------------
if SmartMB then
    SmartMB:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SMB_FlyForm.OnFamiliarUpdate)
    SmartMB:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,   SMB_FlyForm.OnNewRoom)
end

return SMB_FlyForm
