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
jps.raid.initialized = false
jps.UpdateRaidBarsInterval = 0.5 -- maybe we need a smaller value !
jps.raid.currentEncounterTable = {}

function jps.raid.initialize()
	jps.raid.initialized = true
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
    jps.raid.instance = {instance = name , enemy = targetName, difficulty = diffTable[difficultyID]}
    return jps.raid.instance
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
    if jps.raid.hasDBM == true then
        bars = _G.DBM.Bars.bars
        for bar in pairs(bars) do
            -- to-do : remove time from id
            jps.raid.encounterTimers[bar.id] = {timer = bar.timer, name= bar.id }
		end
    elseif jps.raid.hasBigWings == true then
        -- to do
    else
    end
end

function jps.raid.getTimer(ability) 
    for v,k in pairs(jps.raid.encounterTimers) do 
        if ability == v.name then
            return v.timer
        end
    end
    return 99999999
end
-- supported by jps
function jps.raid.isSupported()
	local supportedFight = false
	local supportedSpec = false
 local raidInfo = jps.raid.getInstanceInfo()
    if  jps.raid.supportedEncounters[raidInfo.instance] ~= nil then -- supported instance
        if jps.raid.supportedEncounters[raidInfo.instance][raidInfo.enemy] ~= nil then -- supported encounter
        	jps.raid.currentEncounterTable = jps.raid.supportedEncounters[raidInfo.instance][raidInfo.enemy]
            supportedFight = true
        end
    end
    if jps.raid.supportedAbilities[jps.Class] ~= nil then
	    if jps.raid.supportedAbilities[jps.Class][jps.Spec] ~= nil
	    jps.raid.currentAbilityTable = jps.raid.supportedAbilities[jps.Class][jps.Spec]
	    	supportedSpec = true
	    then
    end
    return supportedFight and supportedSpec
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
    if event == "PLAYER_REGEN_ENABLED" and jps.RaidMode then
        jps.raid.leaveFight()
    elseif event == "PLAYER_REGEN_DISABLED" and jps.RaidMode then
    	if not jps.raid.initialized then
    		jps.raid.initialize()
    	end
        jps.raid.fightEngaged()
    end
end
jps.raid.frame:SetScript("OnEvent", jps.raid.eventManager)
jps.raid.frame:SetScript("OnUpdate", function(self, elapsed)
	if jps.RaidMode then
		if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
		if (self.TimeSinceLastUpdate > jps.UpdateRaidBarsInterval and jps.raid.validFight) then
			jps.raid.getCurrentBossModTimers()
	   	end
   	end
end)

function jps.raid.shouldCast(ability)
	if jps.RaidMode and jps.raid.validFight then
		if type(ability) == "string" then spellname = ability end
		if type(ability) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
		for key,spellTable  in pairs(jps.raid.currentEncounterTable) do
			local encounterSpellName = spellTable[1]
			local typeOfAbility = spellTable[2]
			local conditionsToCheck = spellTable[3]
			if jps.raid.currentAbilityTable[spellname] ~= nil  and conditionsMatched(spellname, conditionsToCheck)  then
				if typeOfAbility == jps.raid.currentAbilityTable[ability]["spellType"] then
					return true
				end
			end
		end
	end
	return false
end


jps.raid.supportedAbilities = {
	{"Death Knight", 
		{"Blood", 
			{"anti-magic shell" = {spellType="magic", spellAction="absorb"}},
			{"anti-magic shell" = {spellType="dispelMagic", spellAction="dispel"}},
			{"Death's Advance" = {spellType="runspeed"}},
		},
		{"Frost", 
			{"anti-magic shell" = {spellType="magic", spellAction="absorb"}},
			{"anti-magic shell" = {spellType="dispelMagic", spellAction="dispel"}},
			{"Death's Advance" = {spellType="runspeed"}},
		},
		{"Unholy", 
			{"anti-magic shell" = {spellType="magic", spellAction="absorb"}},
			{"anti-magic shell" = {spellType="dispelMagic", spellAction="dispel"}},
			{"Death's Advance" = {spellType="runspeed"}},
		}
	},
	{"Paladin" 
		{"Holy", 
			{"Speed of Light" = {spellType="runspeed"}},
		}
	}
}

-- supported raids & encounters
jps.raid.supportedEncounters = {
    {"Throne Of Thunder", 
        {"Jin'rokh the Breaker", 
            {
                --{"Focused Lightning", "magic" , jps.debuff("Focused Lightning","player") }, 
                {"Focused Lightning", "runspeed" , jps.debuff("Focused Lightning","player") }, 
                {"Lightning Storm", "magic", jps.raid.getTimer("Lightning Storm") < 0.5 and jps.hp() < 0.85 },
                {"Ionization", "dispelMagic", jps.raid.getTimer("Ionization") < 1 and jps.isTank == false }, --- no ionization @ HC on tanks!
                {"Lightning Storm", "runspeed", jps.raid.getTimer("Lightning Storm") < 1 and jps.debuff("Fluidity", "player") }
            }
        },
        {"Horridon", 
            {
                { "charge", "physical", jps.debuff("charge") },
                { "Rampage", "physical", jps.buff("rampage", "target") and jps.hp() < 0.5 },
            }
        },
        {"Council Of Elders", 
            {
            }
        },
        {"Tortos", 
            {
            }
        },
        {"Megaera", 
            {
            }
        },
        {"Ji-Kun", 
            {
            }
        },
        {"Durumu The Forgotten", 
            {
            }
        }
    },
}