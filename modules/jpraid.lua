--[[
	JPS - WoW Protected Lua DPS AddOn
	Copyright (C) 2011 Jp Ganis

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--

--------------------------
-- LOCALIZATION
--------------------------
local L = MyLocalizationTable

----------------------
-- Find TANK
----------------------

function jps.targetIsRaidBoss(target) 
	if target == nil then target = "target" end
	if UnitLevel(target) == -1 and UnitPlayerControlled(target) == false then
		return true
	end
	return false
end

function jps.playerInLFR()
	local dungeon = jps.raid.getInstanceInfo()
	if dungeon.difficulty == "lfr25" then return true end
	return false
end

function jps.findMeAggroTank()
	local allTanks = jps.findTanksInRaid()
	local highestThreat = 0
	local aggroTank = "player"
	for _, possibleTankUnit in pairs(allTanks) do
		local unitThreat = UnitThreatSituation(possibleTankUnit)
		if unitThreat and unitThreat > highestThreat then
			highestThreat = unitThreat
			aggroTank = possibleTankUnit
		end
	end
	if jps.Debug then write("found Aggro Tank: "..aggroTank) end
	return aggroTank
end

function jps.unitGotAggro(unit) 
	if unit == nil then unit = "player" end
	if UnitThreatSituation(unit) == 3 then return true end
	return false
end

function jps.findMeATank()
	local allTanks = jps.findTanksInRaid() 
	if jps.tableLength(allTanks) == 0 then
		if jps.UnitExists("focus") then return "focus" end
	else
		return allTanks[1] 
	end
	return "player"
end

function jps.findTanksInRaid() 
	local myTanks = {}
	for unitName,_ in pairs(jps.RaidStatus) do
		local foundTank = false
		if UnitGroupRolesAssigned(unitName) == "TANK" then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("bear form",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("blood presence",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("righteous fury",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
	end
	return myTanks
end

function jps.targetTargetTank()
	if jps.buff("bear form","targettarget") then return true end
	if jps.buff("blood presence","targettarget") then return true end
	if jps.buff("righteous fury","targettarget") then return true end
	
	local _,_,_,_,_,_,_,caster,_,_ = UnitDebuff("target","Sunder Armor")
	if caster ~= nil then
		if UnitName("targettarget") == caster then return true end end
	return false
end

-----------------------
-- RAID ENEMY COUNT 
-----------------------
-- jps.RaidTarget[unittarget_guid] = { ["unit"] = unittarget, ["hpct"] = hpct_enemy, ["count"] = countTargets + 1 }
-- jps.EnemyTable[enemyGuid] = { ["friend"] = enemyFriend } -- TABLE OF ENEMY TARGETING FRIEND

-- COUNT ENEMY ONLY WHEN THEY DO DAMAGE TO inRange FRIENDLIES
function jps.RaidEnemyCount() 
	local enemycount = 0
	local targetcount = 0
	for unit,index in pairs(jps.EnemyTable) do 
		enemycount = enemycount + 1
	end
	for tar_unit,tar_index in pairs(jps.RaidTarget) do
		targetcount = targetcount + 1
	end
	return enemycount,targetcount
end

-- ENEMY UNIT with LOWEST HEALTH
function jps.LowestInRaidTarget() 
local mytarget = nil
local lowestHP = 1 
	for unit,index in pairs(jps.RaidTarget) do
		local unit_Hpct = index.hpct
		if unit_Hpct < lowestHP then
			lowestHP = unit_Hpct
			mytarget = index.unit
		end
	end
return mytarget
end

-- ENEMY MOST TARGETED
function jps.RaidTargetUnit()
	local maxTargets = 0
	local enemyWithMostTargets = "target"
	for enemyGuid, enemyName in pairs(jps.RaidTarget) do
		if enemyName["count"] > maxTargets then
			maxTargets = enemyName["count"]
			enemyWithMostTargets = enemyName.unit
		end
	end
	return enemyWithMostTargets
end

-- ENEMY TARGETING THE PLAYER
-- jps.EnemyTable[enemyGuid] = { ["friend"] = enemyFriend } -- TABLE OF ENEMY GUID TARGETING FRIEND NAME
-- jps.RaidTarget[unittarget_guid] = { ["unit"] = unittarget, ["hpct"] = hpct_enemy, ["count"] = countTargets + 1 }
function jps.IstargetMe()
	local enemy_guid = nil
	for unit,index in pairs(jps.EnemyTable) do 
		if index.friend == GetUnitName("player") then
			enemy_guid = unit
		end
	end
	for unit, index in pairs(jps.RaidTarget) do 
		if (unit == enemy_guid) then 
			return index.unit -- return "raid1target"
		end 
	end
	return nil
end

-------------------
-- RAIDS
-------------------

-- supported raids & encounters (only spell Ids for jps.raid.getTimer() !!! )

jps.raid.supportedEncounters = {
	["Isle of Giants"]= {
		["Oondasta"]= {
			{
				{"Frill Blast", "magicShortCD" , 'jps.IsCastingSpell("Frill Blast","target") and jps.CastTimeLeft("Oondasta") < 1'},
				{"Frill Blast", "reduceDamage" , 'jps.IsCastingSpell("Frill Blast","target") and jps.CastTimeLeft("Oondasta") < 1'},
			},
		},
	},
		
	["Throne of Thunder"]= {
		["Jin'rokh the Breaker"]=
			{
				{"Focused Lightning", "runspeed" , 'jps.debuff("Focused Lightning","player") '}, 
				{"Lightning Storm", "magicShortCD", 'jps.raid.getTimer(137313) < 0.5 and jps.hp() < 0.85 and jps.isTank == false '},
				{"Ionization", "dispelMagic", 'jps.raid.getTimer(138732) < 1 and jps.isTank == false and jps.hp("player","abs") > 480000 '}, --- no ionization @ HC on tanks!
				{"Static Burst", "dispelMagic",'jps.raid.getTimer(137162) < 2 and jps.isTank == true and jps.unitGotAggro() '}, --- we can prevent every 2nd static burst with ams
				{"Lightning Storm", "runspeed",' jps.raid.getTimer(137313) < 1 and jps.debuff("Fluidity", "player") '}
			},
		["Horridon"] = 
			{
			},
		["Council Of Elders"]= {},
		["Tortos"] = {},
		["Megaera"] = {},
		["Ji-Kun"] =
			{
				{"Quills", "magicShortCD" ,' jps.IsCastingSpell("Quills","target")'},
				{"Talor Rake", "reduceDamage", 'jps.debuffStacks("Talor Rake") >= 2 and jps.unitGotAggro() and jps.hp() < 0.90'},
				{"Downdraft", "runspeed" ,' jps.debuff("Downdraft") '}, 
			},
		["Durumu The Forgotten"] = {}
	},
	
	-- just for testing
	["Kalimdor"] = {
		["Raider's Training Dummy"] = {
			{"Demo", "magicShortCD", 'onCD'}, --casts an magic deff ability on cd @ raiders training dummy
		}
	},
	["Mogu'shan Palace"] = {
		["Haiyan the Unstoppable"] = {
			{"Meteor", "runspeed", 'jps.raid.getTimer(120195) < 5'},
			{"Conflagrate", "runspeed", 'jps.raid.getTimer(120201) < 5'},
		},
		["Kuai the Brute"] = {
			{"Shockwave", "runspeed", 'jps.raid.getTimer(119922) < 2'}
		},
		["Ming the Cunning"] = {
			{"Whirling Dervish CD", "runspeed", 'jps.raid.getTimer(119981) < 2'}
		}
	},
}

-- spell names lowercase (important)! 
jps.raid.supportedAbilities = {
	["Death Knight"] = {
		["Blood"] =
		{
			["anti-magic shell"] = {{spellType="magicShortCD", spellAction="absorb"},{spellType="dispelMagic", spellAction="dispel"}},
			["death's advance"] = {{spellType="runspeed"}},
			["icebound fortitude"] = {{spellType="reduceDamage"}},
			["icebound fortitude"] = {{spellType="breakStun"}},
		},
		["Frost"] =
		{
			["anti-magic shell"] = {{spellType="magicShortCD", spellAction="absorb"},{spellType="dispelMagic", spellAction="dispel"}},
			["death's advance"] = {{spellType="runspeed"}},
		},
		["Unholy"] = 
		{
			["anti-magic shell"] = {{spellType="magicShortCD", spellAction="absorb"},{spellType="dispelMagic", spellAction="dispel"}},
			["death's advance"] = {{spellType="runspeed"}},
		}
	}
	,
	["Paladin"] = {
		["Holy"] = 
		{
			["speed of light"] = {{spellType="runspeed"}},
		}
	}
}

-- cast player abilities(for instance deff cd's) if raid encounter applied us a debuff or a ability cd is near finishing or finished

jps.raid.hasDBM = false
jps.raid.hasBigWings = false
jps.raid.validFight = false
jps.raid.initialized = false
jps.UpdateRaidBarsInterval = 0.5 -- maybe we need a smaller value !
jps.foundBossLoopsLeft = 10
jps.foundBoss = false
jps.foundBossInterval = 2

function jps.raid.getTimer(ability)
	if type(ability) ~= number then
	
	end
	if jps.raid.hasDBM then
		bars = _G.DBM.Bars.bars
		for bar in pairs(bars) do
			-- to-do : remove time from id
			barFirst = string.sub(string.gsub(bar.id,"Timer",""), 1, string.len(ability))
			if tonumber(barFirst) == ability then
				return bar.timer
			end
		 end
	 end
	return 99999999
end

diffTable = {}
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

function jps.raid.initialize()
	jps.raid.initialized = true
	jps.raid.findEncounterAddon()
end

-- load instance info , we should read instance name & check if we fight an encounter
jps.raid.instance = {}
function jps.raid.getInstanceInfo()
	local name, instanceType , difficultyID = GetInstanceInfo()
	local targetName = UnitName("target")
	if targetName ~= nil and UnitPlayerControlled("target") == false then
		jps.foundBoss = true
	end
	jps.raid.instance["instance"] = name
	jps.raid.instance["enemy"] = targetName
	jps.raid.instance["difficulty"] = diffTable[difficultyID]

	return jps.raid.instance
end

function jps.raid.isValidEncounter()
	return jps.targetIsRaidBoss(jps.RaidTargetUnit()), jps.RaidTargetUnit()
end

-- supported by jps
function jps.raid.isSupported()
	local supportedFight = false
	local supportedSpec = false
	local raidInfo = jps.raid.getInstanceInfo()
	if jps.raid.supportedEncounters[jps.raid.instance.instance] ~= nil then -- supported instance
		if jps.raid.supportedEncounters[jps.raid.instance.instance][jps.raid.instance.enemy] ~= nil then -- supported encounter
			supportedFight = true
		end
	end
	if jps.raid.supportedAbilities[jps.Class] ~= nil then
		if jps.raid.supportedAbilities[jps.Class][jps.Spec] ~= nil then
			jps.raid.supportedAbilities[jps.Class][jps.Spec] = jps.raid.supportedAbilities[jps.Class][jps.Spec]
			supportedSpec = true
		end
	end
	return supportedFight and supportedSpec
end

-- fight start, read instance information , connect to boss mods, get timers
function jps.raid.fightEngaged()
	if jps.raid.isSupported() then
		jps.raid.validFight = true
		if jps.RaidMode then
			write("Welcome to JPS Raid Mode - this fight is supprted")
		end
	end
end

-- on Wipe, defeat, reset timers
function jps.raid.leaveFight()
	jps.raid.validFight = false
	jps.foundBossLoopsLeft = 5
	jps.foundBoss = false
end


function jps.raid.shouldCast(ability)
	if jps.RaidMode and jps.raid.validFight then
		local currentTarget = UnitName("target")
		if jps.raid.instance.enemy ~= currentTarget then
			jps.raid.instance.enemy = currentTarget
		end
		if type(ability) == "string" then spellname = ability end
		if type(ability) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
		spellname = string.lower(spellname)
		if jps.raid.supportedEncounters[jps.raid.instance.instance][jps.raid.instance.enemy] ~= nil then
			encounterSpellName, encounterTypeOfAbility = parseStaticRaidTable(jps.raid.supportedEncounters[jps.raid.instance.instance][jps.raid.instance.enemy])
			if encounterSpellName ~= nil then
				if jps.raid.supportedAbilities[jps.Class][jps.Spec][spellname] ~= nil then
					for spellnameTable, spellTable in pairs(jps.raid.supportedAbilities[jps.Class][jps.Spec][spellname]) do
						if encounterTypeOfAbility == spellTable["spellType"] then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

-- check if we're infight
jps.raid.frame = CreateFrame('Frame')
jps.raid.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
jps.raid.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
function jps.raid.eventManager(self, event, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		jps.raid.leaveFight()
	elseif event == "PLAYER_REGEN_DISABLED" then
		if not jps.raid.initialized then
			jps.raid.initialize()
		end
		jps.raid.fightEngaged()
	end
end
jps.raid.frame:SetScript("OnEvent", jps.raid.eventManager)
jps.raid.frame:SetScript("OnUpdate", function(self, elapsed)
	if jps.RaidMode and InCombatLockdown() == 1 then
		if self.TimeSinceLastBigUpdate == nil then self.TimeSinceLastBigUpdate = 0 end
		self.TimeSinceLastBigUpdate = self.TimeSinceLastBigUpdate + elapsed
			if self.TimeSinceLastBigUpdate > jps.foundBossInterval then
				if jps.raid.validFight == false and jps.foundBossLoopsLeft > 0 then
					jps.raid.fightEngaged()
					jps.foundBossLoopsLeft = jps.foundBossLoopsLeft - 1
					if jps.foundBossLoopsLeft == 0 and jps.foundBoss == false then
						jps.raid.validFight = false -- we do not found an valid ancounter after 3*5 secs infight.
					end
				end
				self.TimeSinceLastBigUpdate = 0
			end
		end
end)

