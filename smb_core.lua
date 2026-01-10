-- Smart Meat Bandage - Core Logic (smb_core.lua)
-- include config & MCM modules
local SMB_Config = include("smb_config")
local SMB_MCM   = include("smb_mcm")

SmartMB = SmartMB or RegisterMod("Smart Meat & Bandage", 1)
SMB_Config.Init(SmartMB) -- Initialize with default config immediately to prevent nil errors.
local game = Game()

-- Log version info
Isaac.ConsoleOutput("Smart Meat & Bandage v" .. SMB_Config.VERSION .. " initializing...\n")

--------------------------------------------------
-- Familiar Variants we control
--------------------------------------------------
-- Familiar variant to config key mapping
-- Format: [variant_id] = "configKey"
local FAMILIAR_CONFIG_MAP = {
    -- Meatboy (Cube of Meat Lv3=46, Lv4=47)
    [46] = "famMeatboy",  -- CUBE_OF_MEAT_3
    [47] = "famMeatboy",  -- CUBE_OF_MEAT_4
    -- Bandage (Ball of Bandages Lv3=71, Lv4=72)
    [71] = "famBandage",  -- BALL_OF_BANDAGES_3
    [72] = "famBandage",  -- BALL_OF_BANDAGES_4
    -- Additional Familiars (MCM categories)
    [14] = "famDeadBird",      -- DEAD_BIRD
    [15] = "famEvesBirdFoot",  -- EVES_BIRD_FOOT
    [48] = "famIsaacsBody",    -- ISAACS_BODY
    [50] = "famSmartFly",      -- SMART_FLY
    [56] = "famLeech",         -- LEECH
    [63] = "famLilHaunt",      -- LIL_HAUNT
    [79] = "famGemini",        -- GEMINI
    [118] = "famAngryFly",     -- ANGRY_FLY
    [210] = "famBirdCage",     -- BIRD_CAGE
    [218] = "famBotFly",       -- BOT_FLY
    [224] = "famBabyPlum",     -- BABY_PLUM
    [228] = "famMinisaac",     -- MINISAAC
    [241] = "famBloodPuppy",   -- BLOOD_PUPPY
}

-- Banlist: Familiars that should NEVER be controlled (even with famAll)
local FAMILIAR_BANLIST = {
    [78] = true,   -- SCISSORS
    [102] = true,  -- SUPER_BUM
    [201] = true,  -- DIP
    [225] = true,  -- FRUITY_PLUM
    [233] = true,  -- WORM_FRIEND
}

--------------------------------------------------
-- Helper: Check if familiar should be controlled
--------------------------------------------------
local function shouldControlFamiliar(fam)
    if not SmartMB.Config or not SmartMB.Config.enabled then
        return false
    end
    
    -- Always skip banned familiars
    if FAMILIAR_BANLIST[fam.Variant] then
        return false
    end
    
    -- famAll = true -> control ALL familiars (except banlist)
    if SmartMB.Config.famAll then
        return true
    end
    
    -- Check individual settings via config map
    local configKey = FAMILIAR_CONFIG_MAP[fam.Variant]
    if configKey and SmartMB.Config[configKey] then
        return true
    end
    
    return false
end

-- round-robin index
local targetCycle = 0

-- flag for performance optimization: entity change detection
local needsTargetReassignment = false
local lastEnemyCount = 0

--------------------------------------------------
-- Helper: get alive enemies in current room
--------------------------------------------------
local function getAliveEnemies(position, radius)
    local entities = Isaac.GetRoomEntities()
    local list = {}
    for _, ent in ipairs(entities) do
        if ent:IsActiveEnemy(false) and not ent:IsDead() then
            -- invincible entities are excluded
            if not ent:IsInvincible() and ent:IsVulnerableEnemy() then
                if position and radius then
                    if ent.Position:Distance(position) <= radius then
                        table.insert(list, ent)
                    end
                else
                    table.insert(list, ent)
                end
            end
        end
    end
    return list
end

--------------------------------------------------
-- entity change detection function
--------------------------------------------------
local function checkEntityChanges()
    local enemies = getAliveEnemies()
    local currentCount = #enemies
    
    if currentCount ~= lastEnemyCount then
        needsTargetReassignment = true
        lastEnemyCount = currentCount
    end
end

--------------------------------------------------
-- Assign a new target to familiar (round-robin)
--------------------------------------------------

-- Helper to find the best target from a list for a given familiar
local function findBestTarget(fam, targetList)
    if not targetList or #targetList == 0 then return nil end

    local counts = {}
    local allFams = Isaac.FindInRadius(Vector(0,0), 100000, EntityPartition.FAMILIAR)
    for _, fe in ipairs(allFams) do
        local f2 = fe:ToFamiliar()
        if f2 and shouldControlFamiliar(f2) and f2.Target and f2.Target:Exists() then
            local is_in_list = false
            for _, t in ipairs(targetList) do
                if t.InitSeed == f2.Target.InitSeed then
                    is_in_list = true
                    break
                end
            end
            if is_in_list then
                counts[f2.Target.InitSeed] = (counts[f2.Target.InitSeed] or 0) + 1
            end
        end
    end

    local minCount = math.huge
    for _, enemy in ipairs(targetList) do
        local c = counts[enemy.InitSeed] or 0
        if c < minCount then minCount = c end
    end

    local nearest = nil
    local minDist = math.huge
    for _, enemy in ipairs(targetList) do
        local c = counts[enemy.InitSeed] or 0
        if c == minCount then
            local dist = fam.Position:Distance(enemy.Position)
            if dist < minDist then
                minDist = dist
                nearest = enemy
            end
        end
    end

    return nearest or targetList[1]
end

-- Helper to calculate how many familiars should attack non-bosses
local function calculateNonBossAttackers(boss, totalFams, allNonBosses)
    if not boss or boss.MaxHitPoints <= 0 or #allNonBosses == 0 then
        return 0
    end

    local hpRatio = boss.HitPoints / boss.MaxHitPoints
    local nonBossCount = 0

    if hpRatio > 0.8 then
        nonBossCount = 1
    elseif hpRatio > 0.5 then
        nonBossCount = math.max(1, math.floor(totalFams * 0.25))
    elseif hpRatio > 0.2 then
        nonBossCount = math.max(1, math.floor(totalFams * 0.5))
    else
        nonBossCount = math.max(1, math.floor(totalFams * 0.75))
    end
    
    return math.min(nonBossCount, #allNonBosses)
end

function SmartMB:AssignNewTarget(fam)
    -- Get player position for detection radius calculation
    local player = game:GetNearestPlayer(fam.Position)
    if fam.Player and type(fam.Player) ~= "boolean" then
        local tmp = fam.Player:ToPlayer()
        if tmp then player = tmp end
    end
    
    if not player then return end
    
    -- Only get enemies within the detection radius from the player
    local gridRadius = SmartMB.Config.detectionRadius
    local pixelRadius = gridRadius * 40  -- 1 Grid = 40 pixels
    local enemies = getAliveEnemies(player.Position, pixelRadius)
    if #enemies == 0 then
        fam.Target = nil
        return
    end

    -- check current familiar assignment status (simply)
    local counts = {}
    local allFams = Isaac.FindInRadius(Vector(0,0), 100000, EntityPartition.FAMILIAR)
    for _, fe in ipairs(allFams) do
        local f2 = fe:ToFamiliar()
        if f2 and shouldControlFamiliar(f2) and f2.Target and f2.Target:Exists() then
            counts[f2.Target.InitSeed] = (counts[f2.Target.InitSeed] or 0) + 1
        end
    end

    -- find minimum assignment count
    local minCount = math.huge
    for _, enemy in ipairs(enemies) do
        local c = counts[enemy.InitSeed] or 0
        if c < minCount then minCount = c end
    end

    -- select the nearest enemy among the minimum assignment count
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
-- reassign all targets for all familiars
--------------------------------------------------
function SmartMB:ReassignAllTargets()
    local allFams = Isaac.FindInRadius(Vector(0,0), 100000, EntityPartition.FAMILIAR)
    for _, fe in ipairs(allFams) do
        local f2 = fe:ToFamiliar()
        if f2 and shouldControlFamiliar(f2) then
            self:AssignNewTarget(f2)
        end
    end
    needsTargetReassignment = false
end

--------------------------------------------------
-- Callback: Familiar init
--------------------------------------------------
function SmartMB:FamiliarInit(fam)
    -- Check if this familiar should be controlled
    if not shouldControlFamiliar(fam) then return end
    
    -- store original collision class
    fam:GetData().origGridColl = fam.GridCollisionClass
    self:AssignNewTarget(fam)
end

--------------------------------------------------
-- Callback: Familiar update
--------------------------------------------------
function SmartMB:FamiliarUpdate(fam)
    -- Check if this familiar should be controlled
    if not shouldControlFamiliar(fam) then return end

    -- reassign targets only when entity change is detected
    if needsTargetReassignment then
        self:ReassignAllTargets()
    end

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
            -- add floating flag (if EntityFlag.FLAG_FLYING exists)
            if EntityFlag and EntityFlag.FLAG_FLYING then
                if not fam:HasEntityFlags(EntityFlag.FLAG_FLYING) then
                    fam:AddEntityFlags(EntityFlag.FLAG_FLYING)
                end
            end

            -- track target directly (ignore walls/passers)
            if fam.Target then
                local dir = fam.Target.Position - fam.Position
                if dir:Length() > 0 then
                    fam.Velocity = dir:Resized(12) -- force velocity
                end
                -- very close? snap to target
                if dir:Length() < 5 then
                    fam.Position = fam.Target.Position + Vector(0,1)
                    fam.Velocity = Vector.Zero
                end
            end
        else
            -- restore original collision/flag
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
    -- reassign target only when individual familiar's target is invalid, unattackable, or too far from player
    local player = game:GetNearestPlayer(fam.Position)
    if fam.Player and type(fam.Player) ~= "boolean" then
        local tmp = fam.Player:ToPlayer()
        if tmp then player = tmp end
    end
    
    if not player then return end
    
    local gridRadius = SmartMB.Config.detectionRadius
    local pixelRadius = gridRadius * 40  -- 1 Grid = 40 pixels
    if (not target) or target:IsDead() or not target:Exists() or target:IsInvincible() or not target:IsVulnerableEnemy() or player.Position:Distance(target.Position) > pixelRadius then
        self:AssignNewTarget(fam)
        target = fam.Target
    end

    if target then
        fam.Target = target
    end
end

--------------------------------------------------
-- entity change detection callbacks
--------------------------------------------------
function SmartMB:OnEntityKill(entity)
    if entity:IsActiveEnemy(false) then
        needsTargetReassignment = true
    end
end

function SmartMB:OnEntityRemove(entity)
    if entity:IsActiveEnemy(false) then
        needsTargetReassignment = true
    end
end

function SmartMB:OnNPCInit(npc)
    if npc:IsActiveEnemy(false) then
        needsTargetReassignment = true
    end
end

function SmartMB:OnNewRoom()
    needsTargetReassignment = true
    lastEnemyCount = 0
end

--------------------------------------------------
-- Register familiar callbacks (for ALL familiars, filtering done in callback)
--------------------------------------------------
SmartMB:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,   SmartMB.FamiliarInit)
SmartMB:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, SmartMB.FamiliarUpdate)

--------------------------------------------------
-- register entity change detection callbacks
--------------------------------------------------
SmartMB:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, SmartMB.OnEntityKill)
SmartMB:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, SmartMB.OnEntityRemove)
SmartMB:AddCallback(ModCallbacks.MC_POST_NPC_INIT, SmartMB.OnNPCInit)
SmartMB:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SmartMB.OnNewRoom)

--------------------------------------------------
-- Game callbacks: load/save config & setup MCM
--------------------------------------------------
function SmartMB:OnGameStart(isSave)
    SMB_Config.Load(SmartMB)
    SMB_MCM.Setup(SmartMB)
    
    Isaac.ConsoleOutput("Smart Meat & Bandage v" .. SMB_Config.VERSION .. " loaded successfully!\n")
end

function SmartMB:OnGameExit()
    SMB_Config.Save(SmartMB)
    Isaac.ConsoleOutput("Smart Meat & Bandage v" .. SMB_Config.VERSION .. " settings saved.\n")
end

SmartMB:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SmartMB.OnGameStart)
SmartMB:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SmartMB.OnGameExit)

-- expose API (optional)
return SmartMB 