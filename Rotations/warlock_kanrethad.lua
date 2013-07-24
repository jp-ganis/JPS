-- GUIDE: http://us.battle.net/wow/en/forum/topic/8197181984
local LOG = jps.Logger(jps.LogLevel.WARN)

wlk = {}

wlk.showWarning = false
wlk.showError = false
wlk.messageInterval = 1
wlk.lastMessageTime = 0
wlk.currentPhase = 0
wlk.felhunters = {}
wlk.felhunterCount = 0
wlk.wildImpsDead = false
wlk.haltJPS = false
wlk.targets = {}
wlk.doomLordBanishGUID = nil
wlk.doomLordBanishFree = false
wlk.doomLordFearGUID = nil
wlk.doomLordFearFree = false
wlk.cataclysm = false
function wlk.init()
	local function resetValues()
		wlk.showWarning = false
		wlk.showError = false
		wlk.messageInterval = 1
		wlk.lastMessageTime = 0
		wlk.currentPhase = 0
		wlk.felhunters = {}
		wlk.felhunterCount = 0
		wlk.wildImpsDead = false
		wlk.haltJPS = false
		wlk.targets = {}
		wlk.doomLordBanishGUID = nil
		wlk.doomLordBanishFree = false
		wlk.doomLordFearGUID = nil
		wlk.doomLordFearFree = false
		wlk.cataclysm = false
	end
	local function fearOrBanishBroken(...)
		local sourceGUID = select(4,...)
		local targetGUID = select(8,...)
		local spellID = select(12,...)
		local spellName = select(13,...)
		if sourceGUID == UnitGUID("player") then
			if spellID == 5782 then -- Fear
				wlk.doomLordFearFree = true
				SpellStopCasting()
				jps.NextSpell = nil
			elseif spellID == 710 then -- Banish
				wlk.doomLordBanishFree = true
				SpellStopCasting()
				jps.NextSpell = nil
			end
		end
	end
	local function fearOrBanishApplied(...)
		local sourceGUID = select(4,...)
		local targetGUID = select(8,...)
		local spellID = select(12,...)
		local spellName = select(13,...)
		if sourceGUID == UnitGUID("player") then
			if spellID == 5782 then -- Fear
				wlk.doomLordFearFree = false
			elseif spellID == 710 then -- Banish
				wlk.doomLordBanishFree = false
			end
		end
	end
	jps.registerEvent("PLAYER_REGEN_DISABLED", resetValues)
	jps.registerEvent("PLAYER_REGEN_ENABLED", resetValues)
	jps.registerEvent("PLAYER_UNGHOST", resetValues)
	jps.registerCombatLogEventUnfiltered("SPELL_AURA_REMOVED", fearOrBanishBroken)
	jps.registerCombatLogEventUnfiltered("SPELL_AURA_APPLIED", fearOrBanishApplied)
	jps.registerCombatLogEventUnfiltered("SPELL_AURA_REFRESH", fearOrBanishApplied)
end

local requiredTalents = {
	{"Sacrificial Pact", 3, 8},
	{"Grimoire of Sacrifice", 5, 15},
	{"Kil'jaeden's Cunning", 6, 17},
}

local mobs = {}
mobs["kanrethad"] = 69964
mobs["pitLord"] = 70075
mobs["felhunter"] = 70072
mobs["wildImp"] = 70071
mobs["doomLord"] = 70073
wlk.mobs = mobs

local function toSpell(id) return GetSpellInfo(id) end
wlk.kanrethadSpells = {}
wlk.kanrethadSpells["cataclysm"] = toSpell(138565)
wlk.kanrethadSpells["chaosBolt"] = toSpell(138559)
wlk.kanrethadSpells["curseOfUltimateDoom"] = toSpell(138558)
wlk.kanrethadSpells["rainOfFire"] = toSpell(138561)
wlk.kanrethadSpells["excrutiatingAgony"] = toSpell(138560)
wlk.kanrethadSpells["seedOfTerribleDestruction"] = toSpell(138587)
wlk.kanrethadSpells["summonPitLord"] = toSpell(138789)
wlk.kanrethadSpells["summonWildImps"] = toSpell(138685)
wlk.kanrethadSpells["summonFelhunters"] = toSpell(138751)
wlk.kanrethadSpells["summonDoomLord"] = toSpell(138755)
wlk.pitLordSpells = {}
wlk.pitLordSpells["charge"] = toSpell(138827) -- should be 138827 which applies 138796
wlk.pitLordSpells["demonicSiphon"] = toSpell(138829)
wlk.pitLordSpells["felFlameBreath"] = toSpell(138813)



function wlk.measure(fn,...)
	debugprofilestart()
	fn(...)
	e = debugprofilestop()
	LOG.debug("Function took "..e.." ms")
end

function wlk.hasDebuffs()
	return jps.debuff(wlk.kanrethadSpells.excrutiatingAgony,"player") or jps.debuff(wlk.kanrethadSpells.seedOfTerribleDestruction,"player")
end

-- 
-- Spell can be PET_ACTION_ATTACK/FOLLOW/MOVE_TO any pet spell or PET_MODE_ASSIST/DEFENSIVE/PASSIVE - will return 1 or nil
local function isPetSkillActive(skill)
   for i = 1,NUM_PET_ACTION_SLOTS do
	  name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
	  if name==skill then
		 return isActive   
	  end
   end
   return false
end
wlk.isPetSkillActive = isPetSkillActive

local function spamRaidWarning(message, times)
	if not times then times=1 end
	for i=1,times do
		PlaySoundFile("Sound\\Interface\\RaidWarning.wav")
		RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
	end
end

local function hasRequiredTalents()
	for _,requiredTalent in pairs(requiredTalents) do
		local selected, talentIndex = GetTalentRowSelectionInfo(requiredTalent[2])
		if talentIndex ~= requiredTalent[3] then
			return false, requiredTalent[1]
		end
	end
	return true
end


local function npcId(unit)
	if UnitExists(unit) then return tonumber(UnitGUID(unit):sub(6, 10), 16) end
	return -1
end
wlk.npcId = npcId


local function scanTargets(fn,...)
	LOG.debug("Scanning Targets...")
	local maxTargetSwitches = 10
	local nextTargetMacro = "/targetenemy"
	if not UnitExists("target") then
		LOG.debug("No target set!")
		jps.Macro(nextTargetMacro)
	end
	local startingGUID = UnitGUID("target")
	local newTargetsFound = 0
	for i=1,maxTargetSwitches do
		jps.Macro(nextTargetMacro)
		local targetGUID = UnitGUID("target")
		local targetID = npcId("target")
		local targetName = UnitName("target")
		if targetGUID then
			if not wlk.targets[targetGUID] then
				wlk.targets[targetGUID] = {id=targetID, name=targetName}
				newTargetsFound = newTargetsFound+1
			end
			if fn and fn(targetGUID, targetID, targetName, ...) then
				LOG.debug("Function matched after %s switches, found %s new targets", i, newTargetsFound)
				return true, i
			end
			if UnitGUID("target") == startingGUID then
				LOG.debug("Reached origin target after %s switches, found %s new targets", i, newTargetsFound)
				return not fn, i
			end
		end
	end
	LOG.debug("Max targets scanned (%s) - aborting, found %s new targets", maxTargetSwitches, newTargetsFound)
	return false, maxTargetSwitches
end

local function targetByID(targetGUID, targetID, targetName, unitid)
	if targetID==unitid then
		LOG.debug("Found %s (%s)", targetName, targetID)
		return true
	end
	return false
end

local function targetByGUID(targetGUID, targetID, targetName, unitguid)
	if targetGUID==unitguid then
		LOG.debug("Found %s (%s)", targetName, targetID)
		return true
	end
	return false
end

local function focusByGUID(targetGUID, targetID, targetName, focusguid)
   if targetGUID==focusguid then
	  LOG.info("Focus @ %s (%s)", targetName, targetID)
	  RunMacroText("/focus")
	  return true
   end
   return false
end

local function focusByID(targetGUID, targetID, targetName, focusid)
   if targetID==focusid then
	  LOG.info("Focus @ %s (%s)", targetName, targetID)
	  RunMacroText("/focus")
	  return true
   end
   return false
end

local spellTable = {
	
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player")' },

}

-- Cooldown Spell Table - executed in Felhunter Phase 2 or 5 - and anytime in Endless Phase 7
local cdSpellTable = {
		{{"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0' },
		{jps.DPSRacial },
		{wl.spells.lifeblood },
		{jps.useSynapseSprings() },
		{jps.useTrinket(0) },
		{jps.useTrinket(1) },
}

-- Generic Spell Table - executed for all Phases
local genericSpellTable = {
	-- Rain of Fire
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1 and not GetCurrentKeyBoardFocus()'	},
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },
	-- COE Debuff @ Focus
	{wl.spells.curseOfTheElements, 'not jps.debuff(wl.spells.curseOfTheElements, "focus")' , "focus" },

	-- Enslave Pit Lord if target and not enslaved
	{wl.spells.enslaveDemon, 'not jps.debuff("Enslave Demon","pet") and wlk.npcId("target")==wlk.mobs.pitLord and not jps.isRecast(wl.spells.enslaveDemon,"target")'},
	--Let Pit Lord Attack Kanrethad, if not in Felhunter Phase - if in felhunter phase only attack if
	--If Kenrethad casts Cataclysm (138565) counter with Charge
	{wlk.pitLordSpells.charge, 'jps.IsChannelingSpell(wlk.kanrethadSpells.cataclysm,"focus")', "focus"},
	--If Curse of Ultimate Doom (138558) is at <25 seconds and debuffs are present, cast fel flame on self
	{wlk.pitLordSpells.felFlameBreath, 'jps.debuffDuration(wlk.kanrethadSpells.curseOfUltimateDoom,"player") <25 and wlk.hasDebuffs()', "player"},
	--If Curse of Ultimate Doom (138558) is at <25 seconds and no debuffs are present, use purification potion (13462)
	{jps.useBagItem(13462), 'jps.debuffDuration(wlk.kanrethadSpells.curseOfUltimateDoom,"player") <25 and not wlk.hasDebuffs()'},
	--If Kenrethad casts Chaos Bolt (138559) and player is target, pop Unending Resolve (104773) and Twilight Ward (6229)
	{"nested", 'jps.IsCastingSpell(wlk.kanrethadSpells.chaosBolt,"focus") and UnitGUID("player") == UnitGUID("focustarget") and jps.CastTimeLeft(unit) < 5', {
		{wl.spells.unendingResolve, 'not jps.buff(wl.spells.sacrificialPact) and not jps.isRecast(wl.spells.sacrificialPact,"player")', "player"},
		{wl.spells.sacrificialPact, 'not jps.buff(wl.spells.unendingResolve) and not jps.isRecast(wl.spells.unendingResolve,"player")', "player"},
		{wl.spells.twilightWard},
	}},
	--Dispell Dots, if possible
	{wl.spells.commandDemon, 'wlk.hasDebuffs()', "player"},
	--Ember Tap / Demonic Siphon / ... self heal
	{wl.spells.mortalCoil, 'jps.hp() <= 0.80' },
	{wl.spells.createHealthstone, 'GetItemCount(5512, false, false) == 0 and jps.LastCast ~= wl.spells.createHealthstone'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{wlk.pitLordSpells.demonicSiphon, 'jps.hp("player") < 0.55' }, -- Pit Lord's Demonic Siphon heals ~200k
	{wl.spells.emberTap, 'jps.hp() <= 0.30 and jps.burningEmbers() > 0' },
	--Cast Dark Intent if not already done
	{wl.spells.darkIntent, 'not jps.buff(wl.spells.darkIntent,"player")', "player"},
	-- Cast Banish on Doomlord 1 if in Target and not banished
	{wl.spells.banish, 'UnitGUID("mouseover")==wlk.doomLordBanishGUID and not jps.debuff(wl.spells.banish, "mouseover") and not jps.isRecast(wl.spells.banish,"mouseover")', "mouseover"},
	-- Cast Fear on Doomlord 2 if in Target and not feared
	{wl.spells.fear, 'UnitGUID("mouseover")==wlk.doomLordFearGUID and not jps.debuff(wl.spells.fear, "mouseover") and not jps.isRecast(wl.spells.fear,"mouseover")', "mouseover"},
	-- Ignore all adds at 15% and phase 7
	{wl.spells.shadowburn, 'wlk.currentPhase==7 and jps.burningEmbers() > 0 and jps.hp("focus")<0.15', "focus"},
}

local dpsFelhunterTable = {
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and wlk.npcId("target") ~= wlk.mobs.wildImp' },
	{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
	{wl.spells.havoc, 'wlk.npcId("mouseover") == wlk.mobs.felhunter', "mouseover" },
	{wl.spells.chaosBolt, 'jps.burningEmbers() > 0 and	jps.buffStacks(wl.spells.havoc)>=3'},
	{wl.spells.immolate, 'jps.myDebuffDuration(wl.spells.immolate) < 2 and not jps.isRecast(wl.spells.immolate,"target")' },
	{wl.spells.conflagrate },
	{wl.spells.chaosBolt, 'jps.TimeToDie("target", 0.2) > 5.0 and jps.buff(wl.spells.darkSoulInstability) and jps.emberShards() >= 19' },
	{wl.spells.chaosBolt, 'jps.TimeToDie("target", 0.2) > 5.0 and jps.burningEmbers() >= 3 and jps.buffStacks(wl.spells.backdraft) < 3'},
	{wl.spells.chaosBolt, 'jps.TimeToDie("target", 0.2) > 5.0 and jps.emberShards() >= 35'},
	{wl.spells.incinerate },
}

local dpsKanrethadTable = {
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and wlk.npcId("target") ~= wlk.mobs.wildImp' },
	{wlk.pitLordSpells.felFlameBreath, 'jps.debuff("Enslave Demon","pet") and not wlk.isPetSkillActive("PET_ACTION_MOVE_TO")', "focus"},
	{wl.spells.shadowburn, 'jps.hp("focus") <= 0.20 and jps.burningEmbers() > 0', "focus"  },
	{wl.spells.immolate, 'jps.myDebuffDuration(wl.spells.immolate, "focus") < 2 and not jps.isRecast(wl.spells.immolate,"focus")', "focus"},
	{wl.spells.conflagrate, true, "focus"},
	--If not Waiting for Felhunter Phase and Kenrethad is stunned by Charge (138796) throw out chaos bolts
	{wl.spells.chaosBolt, 'wlk.currentPhase~=1 and wlk.currentPhase~=4 and jps.burningEmbers() > 0 and jps.debuffDuration(wlk.pitLordSpells.charge, "focus") > 4', "focus"},
	{wl.spells.chaosBolt, 'jps.burningEmbers() >= 3 and jps.buffStacks(wl.spells.backdraft) < 3', "focus"},
	{wl.spells.chaosBolt, 'jps.emberShards() >= 35', "focus"},
	{wl.spells.incinerate, true, "focus"},
} 

local dpsWildImpTable = {
		{wlk.pitLordSpells.felFlameBreath, 'wlk.npcId("target")==70071', "target"},
		{wl.spells.fireAndBrimstone, 'jps.burningEmbers() > 0 and not jps.buff(wl.spells.fireAndBrimstone, "player")' },
		{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.burningEmbers() == 0' },
	--	  {wl.spells.rainOfFire, 'wlk.npcId("mouseover")==70071 and jps.buffDuration(wl.spells.rainOfFire) < 1'	 },
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and not jps.isRecast(wl.spells.immolate,"target")'},
		{wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player")' },
		{wl.spells.incinerate },
}
--[[[
@rotation Kanrethad Ebonlocke
@class warlock
@spec destruction
@author Kirk24788
@description 
As the name already suggest - this is a special Rotation designed for the green fire questline endboss. It has been tested it with 
iLvl 495 and 529 - both iLvl will work without Purification Potions. If you go below 495 you should consider Buff-Food, Flask and
a Purification Potion and you should be fine.
The Rotation will take care of targeting and your Rotation, you only have to move!
For more information please visit the PG Forums. There you can find a detailed explanation with images.
]]--
jps.registerStaticTable("WARLOCK","DESTRUCTION",{
	-- Fake Spell to execute updateState() -- HACK: init() will be only executed once, when the condition is parsed!!!
	{"No Spell", 'wlk.updateState() and wlk.init()'},
	-- Actual Spell Table, executed if JPS shouldn't halt
	{"nested", 'not wlk.showError and not wlk.haltJPS', {
		-- Generic stuff for all phases
		{"nested", 'true', genericSpellTable},
		-- CD's for Felhunter Phase 2 and 5 or 7
		{ "nested", 'wlk.currentPhase==2 or wlk.currentPhase==5 or wlk.currentPhase==7', cdSpellTable},
		-- Phase 1/4/7 - DPS Imps if in target, Cast Soul Shatter on Summon Felhunters
		{"nested", 'wlk.npcId("target") == wlk.mobs.wildImp', dpsWildImpTable},	   
		-- Phase 2/5 - DPS Felhunter, Havoc on Target!
		{"nested", 'wlk.npcId("target") == wlk.mobs.felhunter', dpsFelhunterTable},	   
		-- DPS Kanrethad if nothing else to do
		{"nested", 'true', dpsKanrethadTable},
	}},
	{"nested", 'wlk.haltJPS', {		   
		{wl.spells.demonicCircleTeleport, 'wlk.felhunterCount==0' },
		{wl.spells.demonicCircleSummon, 'jps.buffDuration(wl.spells.demonicCircleSummon,"player")<240 and GetSpellCooldown(wl.spells.demonicCircleTeleport) > 0' },
		{wl.spells.soulshatter },
	}},
},"Kanrethad Ebonlocke")

local function petAttackIfEnslaved() 
	if jps.debuff("Enslave Demon","pet")then
		RunMacroText("/petattack [target=focus]")
	end
end

-- Updates the state machine
function wlk.updateState()
	local elapsed = GetTime() - wlk.lastMessageTime
	--errors
	local talentsOk, missingTalent = hasRequiredTalents()
	local hasDemonicCircle = jps.buff(wl.spells.demonicCircleSummon, "player")
	local hasDemonicGateway = jps.buff(wl.spells.demonicGateway, "player") -- Buff! Shows the stacks and duration of DG
	local hasSacrificed = jps.buff(wl.spells.grimoireOfSacrifice), "player"
	wlk.showError = not (talentsOk and hasDemonicCircle and hasDemonicGateway and hasSacrificed)
	--warnings
	local gatewayDebuffLeft =  math.floor(jps.debuffDuration(wl.spells.demonicGateway, "player"))
	local missingGatewayDebuff = gatewayDebuffLeft < 4 and wlk.currentPhase > 0-- DE-Buff! No aggro if debuffed, and can't enter DG
	local standingInFire = jps.debuff(wlk.kanrethadSpells.rainOfFire, "player")
	wlk.showWarning = missingGatewayDebuff or standingInFire or wlk.haltJPS
	--display warnings or errors if necessary, throttled so you actually can see them!
	if elapsed >= wlk.messageInterval then
		wlk.lastMessageTime = GetTime()
		if wlk.showError then
			local msg = "Your Rotation will continue, if you have fixed following errors:\n\n"
			if not talentsOk then msg = msg .. "Your Talents are wrong! You MUST skill " .. missingTalent .. "!\n" end
			if not hasDemonicCircle then msg = msg .. "You forgot to set your Demonic Circle - you have to set it at the right place - if you don't know where look at the Rotation file!\n" end
			if not hasDemonicGateway then msg = msg .. "You forgot to set your Demonic Gateway - you have to set it at the right place - if you don't know where look at the Rotation file!\n" end
			if not hasScrificed then msg = msg .. "You forgot to sacrifice your Imp!\n" end
			spamRaidWarning(msg)
		elseif wlk.showWarning then
			local msg = ""
			if missingGatewayDebuff then 
				msg = msg .. "Walk through the Gateway - " 
				if gatewayDebuffLeft==0 then
					msg = msg .. "NOW!!!\n"
				else
					msg = msg .. gatewayDebuffLeft .. "\n"
				end
			end
		   -- if standingInFire then msg = msg .. "Walk out of the f***ing Fire - NOW!!!" end
			if wlk.haltJPS then msg = msg .. "Move Pit Lord to Safe Spot - NOW!!!\n" end
			spamRaidWarning(msg)
		end
	end
	-- Set Focus to Kenrethad, if not already
	if npcId("focus") ~= mobs.kanrethad then
		scanTargets(focusByID, mobs.kanrethad)
	end
	
	


	-- State detection
	if wlk.currentPhase == 0 then
		-- Switch to 0.5 @ Summon Pit Lord
		if jps.IsChannelingSpell(wlk.kanrethadSpells.summonPitLord,"focus") then 
			wlk.currentPhase = 0.5 
			LOG.warn("Switchting to Phase " .. wlk.currentPhase)
		end
	elseif wlk.currentPhase == 0.5 then
		petAttackIfEnslaved()
		-- Switch to 1 @ Summon Wild Imps
		if jps.IsChannelingSpell(wlk.kanrethadSpells.summonWildImps,"focus") then 
			wlk.currentPhase = 1 
			LOG.warn("Switchting to Phase " .. wlk.currentPhase)
		end
	elseif wlk.currentPhase == 1 or wlk.currentPhase == 4 or wlk.currentPhase == 7 then
		-- Target Wild Imp, if not target and Imps left
		if npcId("target") == mobs.wildImp then wlk.wildImpsDead = false end
		if npcId("target") ~= mobs.wildImp and not wlk.wildImpsDead then
			wlk.wildImpsDead = scanTargets(targetByID, mobs.wildImp)
		end
		if wlk.currentPhase == 1 or wlk.currentPhase == 4 then
			if jps.IsChannelingSpell(wlk.kanrethadSpells.cataclysm,"focus") then
				wlk.cataclysm = true
			elseif wlk.cataclysm == true then
				wlk.haltJPS = true
				wlk.cataclysm = false
				SpellStopCasting()
				jps.NextSpell = nil
			elseif isPetSkillActive("PET_ACTION_MOVE_TO") then
				wlk.haltJPS = false
			end
			teleportCD,_ = GetSpellCooldown(wl.spells.demonicCircleTeleport)
			soulshatterCD,_ = GetSpellCooldown(wl.spells.soulshatter)
			if wlk.haltJPS and teleportCD > 0 and soulshatterCD > 0 then
				PetMoveTo()
			end
		end
		-- Switch to next Phase @ Summon Felhunter - reset Felhunter Count
		if jps.IsChannelingSpell(wlk.kanrethadSpells.summonFelhunters,"focus") then 
			wlk.currentPhase = wlk.currentPhase + 1
			wlk.felhunterCount = 0
			wlk.wildImpsDead = false
			LOG.warn("Switchting to Phase " .. wlk.currentPhase)
		end
	elseif wlk.currentPhase == 2 or wlk.currentPhase == 5 then
		-- Count Felhunters till all three of them are found
		if wlk.felhunterCount < 3 then
			scanTargets(function (targetGUID, targetID, targetName)
				if targetID == wlk.mobs.felhunter then
					if not wlk.felhunters[targetGUID] then
						wlk.felhunters[targetGUID] = targetGUID
						wlk.felhunterCount = wlk.felhunterCount + 1
						LOG.warn("Found new Felhunter: %s", targetGUID)
					end
				end
				return false
			end)
		end
		if npcId("target") ~= mobs.felhunter then
			scanTargets(targetByID, mobs.felhunter)
			wlk.haltJPS = false
		end
		-- Switch to next Phase @ Summon Doom Lord - target and release pet so enslave can be renewed
		if jps.IsChannelingSpell(wlk.kanrethadSpells.summonDoomLord,"focus") then 
			wlk.currentPhase = wlk.currentPhase + 1
			LOG.warn("Switchting to Phase " .. wlk.currentPhase)
			PetFollow()
			petAttackIfEnslaved()
			--RunMacroText("/target pet")
			--PetDismiss()
		end
	elseif wlk.currentPhase == 3 then
		petAttackIfEnslaved()
		-- Find Doom Lord 1 and save as Banish Target
		if not wlk.doomLordBanishGUID then
			scanTargets(function (targetGUID, targetID, targetName)
				if targetID == wlk.mobs.doomLord then
					wlk.doomLordBanishGUID = targetGUID
					wlk.doomLordBanishFree = true
					LOG.warn("Found DoomLord Banish: %s", targetGUID)
					return true
				end
				return false
			end)
		end
		-- Switch to 4 @ Summon Wild Imps
		if jps.IsChannelingSpell(wlk.kanrethadSpells.summonWildImps,"focus") then 
			wlk.currentPhase = wlk.currentPhase + 1
			LOG.warn("Switchting to Phase " .. wlk.currentPhase)
		end
	elseif wlk.currentPhase == 6 then
		petAttackIfEnslaved()
		-- Find Doom Lord 2 and save as Fear Target
		if not wlk.doomLordFearGUID then
			scanTargets(function (targetGUID, targetID, targetName)
				if targetID == wlk.mobs.doomLord and targetGUID~=wlk.doomLordBanishGUID then
					wlk.doomLordFearGUID = targetGUID
					wlk.doomLordFearFree = true
					LOG.warn("Found DoomLord Fear: %s", targetGUID)
					return true
				end
				return false
			end)
		end
		-- Switch to 7 @ Summon Wild Imps
		if jps.IsChannelingSpell(wlk.kanrethadSpells.summonWildImps,"focus") then 
			wlk.currentPhase = wlk.currentPhase + 1
			LOG.warn("Switchting to Phase " .. wlk.currentPhase)
		end
	end
	
	-- Target Pit Lord so it can be enslaved, if player has no pet
	if not jps.debuff("Enslave Demon","pet") and wlk.currentPhase > 0 then
		if not jps.IsCastingSpell(wl.spells.enslaveDemon, "player") and scanTargets(targetByID, mobs.pitLord) then
			SpellStopCasting()
			jps.NextSpell = nil
			return false
		end
	end

	-- return false - to make sure the pseudo spell isn't cast!
	return false
end
