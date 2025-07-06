-- Smart Meat Bandage - Core Logic (smb_core.lua)
SmartMB = SmartMB or RegisterMod("Smart Meat Bandage", 1)
local game = Game()

-- include config & MCM modules
local SMB_Config = include("smb_config")
local SMB_MCM   = include("smb_mcm")

--------------------------------------------------
-- Familiar Variants we control
--------------------------------------------------
local CONTROLLED_VARIANTS = {
    FamiliarVariant.CUBE_OF_MEAT_3,
    FamiliarVariant.CUBE_OF_MEAT_4,
    FamiliarVariant.BALL_OF_BANDAGES_3,
    FamiliarVariant.BALL_OF_BANDAGES_4,
}

SmartMB.ControlledVariants = CONTROLLED_VARIANTS

-- quick lookup
local CONTROLLED_LOOKUP = {}
for _, v in ipairs(CONTROLLED_VARIANTS) do
    CONTROLLED_LOOKUP[v] = true
end

-- round-robin index
local targetCycle = 0

--------------------------------------------------
-- Helper: get alive enemies in current room
--------------------------------------------------
local function getAliveEnemies()
    local entities = Isaac.GetRoomEntities()
    local list = {}
    for _, ent in ipairs(entities) do
        if ent:IsActiveEnemy(false) and not ent:IsDead() then
            table.insert(list, ent)
        end
    end
    return list
end

--------------------------------------------------
-- Assign a new target to familiar (round-robin)
--------------------------------------------------
function SmartMB:AssignNewTarget(fam)
    local enemies = getAliveEnemies()
    if #enemies == 0 then
        fam.Target = nil
        return
    end

    -- 현재 패밀리어 배정 현황 파악 (간단히)
    local counts = {}
    local allFams = Isaac.FindInRadius(Vector(0,0), 100000, EntityPartition.FAMILIAR)
    for _, fe in ipairs(allFams) do
        local f2 = fe:ToFamiliar()
        if f2 and CONTROLLED_LOOKUP[f2.Variant] and f2.Target and f2.Target:Exists() then
            counts[f2.Target.InitSeed] = (counts[f2.Target.InitSeed] or 0) + 1
        end
    end

    -- 최소 배정 수 찾기
    local minCount = math.huge
    for _, enemy in ipairs(enemies) do
        local c = counts[enemy.InitSeed] or 0
        if c < minCount then minCount = c end
    end

    -- 그중에서 가장 가까운 적 선택
    local nearest = nil
    local minDist = math.huge
    for _, enemy in ipairs(enemies) do
        local c = counts[enemy.InitSeed] or 0
        if c == minCount then
            local dist = fam.Position:Distance(enemy.Position)
            if dist < minDist then
                minDist = dist
                nearest = enemy
            end
        end
    end

    fam.Target = nearest or enemies[1]
end

--------------------------------------------------
-- Callback: Familiar init
--------------------------------------------------
function SmartMB:FamiliarInit(fam)
    -- store original collision class
    fam:GetData().origGridColl = fam.GridCollisionClass
    self:AssignNewTarget(fam)
end

--------------------------------------------------
-- Callback: Familiar update
--------------------------------------------------
function SmartMB:FamiliarUpdate(fam)
    -- 아직 Config 가 초기화되지 않았을 수 있으므로 안전 검사
    if not SmartMB.Config or not SmartMB.Config.enabled then return end

    -- flight assist: ignore pits/spikes if player can fly
    if SmartMB.Config.flightAssist then
        local player = game:GetNearestPlayer(fam.Position)
        if fam.Player and type(fam.Player) ~= "boolean" then
            local tmp = fam.Player:ToPlayer()
            if tmp then player = tmp end
        end

        if player and player.CanFly then
            if fam.GridCollisionClass ~= EntityGridCollisionClass.GRIDCOLL_NONE then
                fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            end
            -- 부유 플래그 부여 (FLAG_FLYING 상수가 있는 경우에만)
            if EntityFlag and EntityFlag.FLAG_FLYING then
                if not fam:HasEntityFlags(EntityFlag.FLAG_FLYING) then
                    fam:AddEntityFlags(EntityFlag.FLAG_FLYING)
                end
            end

            -- 목표 방향으로 직접 위치 추적 (벽/패스파인더 무시)
            if fam.Target then
                local dir = fam.Target.Position - fam.Position
                if dir:Length() > 0 then
                    fam.Velocity = dir:Resized(12) -- 강제 속도
                end
                -- 매우 가까우면 스Nap to target
                if dir:Length() < 5 then
                    fam.Position = fam.Target.Position + Vector(0,1)
                    fam.Velocity = Vector.Zero
                end
            end
        else
            -- 원래 충돌/플래그 복원
            local orig = fam:GetData().origGridColl
            if orig and fam.GridCollisionClass ~= orig then
                fam.GridCollisionClass = orig
            end
            if EntityFlag and EntityFlag.FLAG_FLYING then
                if fam:HasEntityFlags(EntityFlag.FLAG_FLYING) then
                    fam:ClearEntityFlags(EntityFlag.FLAG_FLYING)
                end
            end
        end
    end

    local target = fam.Target
    if (not target) or target:IsDead() or fam.Position:Distance(target.Position) > SmartMB.Config.detectionRadius then
        self:AssignNewTarget(fam)
        target = fam.Target
    end

    if target then
        fam.Target = target
    end
end

--------------------------------------------------
-- Register familiar callbacks
--------------------------------------------------
for _, variant in ipairs(CONTROLLED_VARIANTS) do
    SmartMB:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,   SmartMB.FamiliarInit,   variant)
    SmartMB:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SmartMB.FamiliarUpdate, variant)
end

--------------------------------------------------
-- Game callbacks: load/save config & setup MCM
--------------------------------------------------
function SmartMB:OnGameStart(isSave)
    SMB_Config.Init(SmartMB)
    SMB_Config.Load(SmartMB)
    SMB_MCM.Setup(SmartMB)
end

function SmartMB:OnGameExit()
    SMB_Config.Save(SmartMB)
end

SmartMB:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SmartMB.OnGameStart)
SmartMB:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SmartMB.OnGameExit)

-- expose API (optional)
return SmartMB 