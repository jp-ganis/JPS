--[[
|cffe5cc80 = beige (artifact)
|cffff8000 = orange (legendary)
|cffa335ee = purple (epic)
|cff0070dd = blue (rare)
|cff1eff00 = green (uncommon)
|cffffffff = white (normal)
|cff9d9d9d = gray (crappy)
|cFFFFff00 = yellow
|cFFFF0000 = red
]]

-----------------------
-- FUNCTION TEST 
-----------------------


-----------------------
-- RAID FUNCTIONS TESTING 
-----------------------

-- cast player abilities if raid encounter applied us a debuff or a ability cd is near finishing or finished
-- 

jps.RaidMode = true
jps.raid = {}
jps.raid.engageTime = nil
jps.raid.encounterTimers = {}
jps.raid.hasDBM = false
jps.raid.hasBigWings = false
jps.raid.validFight = false

function jps.raid.initialize()
    jps.findEncounterAddon()
end

-- load instance info , we should read instance name & check if we fight an encounter
function jps.raid.getInstanceInfo()
    local name, instanceType , difficultyID = GetInstanceInfo()
    local targetName = UnitName("target")
    local diffTable = {}
    diffTable[0] = "none"
    diffTable[1] = "normal5"
    diffTable[2] = "heroic5"
    diffTable[3] = "normal10"
    diffTable[4] = "normal25"
    diffTable[5] = "heroic10"
    diffTable[6] = "heroic25"
    diffTable[7] = "lfr25"
    diffTable[8] = "challenge"
    diffTable[9] = "normal40"
    diffTable[10] = "none"
    diffTable[11] = "normal3"
    diffTable[12] = "heroic3" 
    return {instance = name , enemy = targetName, difficulty = diffTable[difficultyID]}
end

-- look for encounter addon
function jps.raid.findEncounterAddon()
    -- check for DBM
    if _G.DBM ~=nil then
        if _G.DBM.ReleaseRevision > 9000 then
            jps.raid.hasDBM = true
            return "dbm"
        end
    end
end

-- read boss mod timers
function jps.raid.getCurrentBossModTimers()
    jps.raid.encounterTimers = {}
    if jps.raid.hasDBM == true then
        bars = _G.DBM.Bars.bars
        for bar in pairs(bars) do
            --remove time from id
            local newTimer = {}
            newTimer["timer"] = bar.timer
            newTimer["name"] = bar.id
            table.insert(jps.raid.encounterTimers, newTimer)
		end
    elseif jps.raid.hasBigWings == true then
        -- to do
    else
    end
end

function jps.raid.encounterTimer(ability) 
    for v,k in pairs(jps.raid.encounterTimers) do 
        if ability == v.name then
            return v.timer
        end
    end
    return 99999999
end
-- supported by jps
function jps.raid.isSupported()
 local raidInfo = jps.raid.getInstanceInfo()
    if  jps.raid.supported[raidInfo.instance] ~= nil then -- supported instance
        if jps.raid.supported[raidInfo.instance][raidInfo.enemy] ~= nil then -- supported encounter
            return true
        end
    end
    return false
end

-- fight start, read instance information , connect to boss mods, get timers
function jps.raid.fightEngaged()
    if jps.raid.isSupported() then
        jps.raid.validFight = true
        jps.raid.getCurrentBossModTimers()
    end
end

-- on Wipe, defeat, reset timers
function jps.raid.leaveFight()
    jps.raid.validFight = false
end

-- check if we're infight
jps.raid.frame = CreateFrame('Frame')
jps.raid.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
jps.raid.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
function jps.raid.eventManager(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        jps.raid.leaveFight()
    elseif event == "PLAYER_REGEN_DISABLED" then
        jps.raid.fightEngaged()
    end
end
jps.raid.frame:SetScript("OnEvent", jps.raid.eventManager)

-- supported raids & encounters
jps.raid.supported = {
    {"Throne Of Thunder", 
        {"Jin'rokh the Breaker", 
            {
                {"Focused Lightning", "magic" , jps.debuff("Focused Lightning","player") },
                {"Lightning Storm", "magic", jps.raid.encounterTimer("Lightning Storm") < 0.5 }
            }
        },
        {"Horridon", 
            {
                { "charge", "physical", jps.debuff("charge") },
                { "Rampage", "physical", jps.buff("rampage", "target") and jps.hp() < 0.5 },
                { "Triple Puncture", "physical" , jps.debuffStacks("Triple Puncture","player") > 5 and jps.hp() < .6 },
            }
        },
    },
}
