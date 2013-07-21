	
	--------------------------------------------------------------------------------------------
	---- Information                     
	--------------------------------------------------------------------------------------------
	---- Talents:
	---- Tier 1: Pursuit of Justice
	---- Tier 2: Fist of Justice
	---- Tier 3: Sacred Shield / Eternal Flame
	---- Tier 4: Unbreakable Spirit
	---- Tier 5: Divine Purpose
	---- Tier 6: Light's Hammer
	
		
	--------------------------------------------------------------------------------------------
	---- Key modifiers
	--------------------------------------------------------------------------------------------
	
	-- left Shift Key 		- for Light's Hammer
	-- left CTRL key for light of dawn
	
hpala = {}
hpala.interruptTable = {{"Flash of Light", 0.43}, {"Divine Light", 0.89},{ "Holy Light", 0.98}}
hpala.importantHealTargetsValue =  {}
hpala.UpdateInterval = 0.2
hpala.timestamp = GetTime()

function hpala.update()
	hpala.jpsNameValue = jpsName
	hpala.rangedTargetValue = "target"
	-- JPS.CANDPS IS WORKING ONLY FOR PARTYN.TARGET AND RAIDN.TARGET NOT FOR UNITNAME.TARGET
	if jps.canDPS("target") then
		hpala.rangedTargetValue = "target"
	elseif jps.canDPS("focustarget") then
		hpala.rangedTargetValue = "focustarget"
	elseif jps.canDPS("targettarget") then
		hpala.rangedTargetValue = "targettarget"
	end
	hpala.myTankValue = jps.findMeAggroTank("target")
	
	hpala.myLowestImportantUnitValue = hpala.jpsName

	hpala.tanksValue = jps.findTanksInRaid() 
	hpala.importantHealTargetsValue = hpala.tanksValue
	hpala.myTankValue = jps.findMeAggroTank()
	--------------------------------------------------------------------------------------------
	---- myLowestImportantUnit = tanks / focus / target / player
	--------------------------------------------------------------------------------------------
	if jps.canHeal("target") then table.insert(hpala.importantHealTargetsValue,"target") end
	if jps.canHeal("focus") then table.insert(hpala.importantHealTargetsValue,"focus") end
	
	local lowestHP = jps.hp("player")
	for unitName, _ in ipairs(hpala.importantHealTargetsValue) do
		local thisHP = jps.hp(unitName)
		if jps.canHeal(unitName) and thisHP <= lowestHP then 
				lowestHP = thisHP
				hpala.myLowestImportantUnitValue = unitName
		end
	end
	hpala.ourHealTargetValue = jps.LowestInRaidStatus()
	local healTargetHPPct = jps.hp(hpala.ourHealTargetValue)
	local importantUnit = hpala.myLowestImportantUnitValue
	local importantTargetHP = jps.hp(importantUnit)
	if importantTargetHP < healTargetHPPct or importantTargetHP < 0.5 then  -- heal our myLowestImportantUnit unit if myLowestImportantUnit hp < ourHealTarget HP or our important targets drop below 0.5
		hpala.ourHealTargetValue = importantUnit
	end
end

function hpala.player()
	return hpala.jpsNameValue
end

function hpala.rangedTarget()
	return hpala.rangedTargetValue
end

function hpala.myTank()
	return hpala.myTankValue
end

function hpala.myLowestImportantUnit()
	return hpala.myLowestImportantUnitValue
end


function hpala.ourHealTarget()
	return hpala.ourHealTargetValue
end

function hpala.unitIsImportant(unit)
	if unit == jpsName or unit == "player" or unit == "focus" or unit =="target" then return true end
	if inArray(unit, hpala.tanksValue) then return true end
	return false
end

function hpala.unitIsTank(unit)
	if inArray(unit, hpala.tanksValue) then return true end
	return false
end

local L = MyLocalizationTable

function hpala.shouldInterruptCasting(spellsToCheck)	
	local healTargetHP = jps.hp(jps.LastTarget)
	local spellCasting, _, _, _, _, endTime, _ = UnitCastingInfo("player")
	if spellCasting == nil then return false end
	if not jps.canHeal(jps.LastTarget) then return true end

	for key, healSpellTable  in pairs(spellsToCheck) do
		local breakpoint = healSpellTable[2]
		local spellName = healSpellTable[1]
		if spellName == spellCasting then
			if healTargetHP > breakpoint then
				print("interrupt "..spellName.." , unit "..jps.LastTarget.. " has enough hp!");
				SpellStopCasting()
			end
		end
	end
end

------------------------
-- SPELL TABLE -----
------------------------
hpala.spellTable = {
	-- Kicks                    
	{ "Rebuke",'jps.shouldKick(hpala.rangedTarget())', hpala.rangedTarget },
	{ "Rebuke",'jps.shouldKick("focus")', "focus" },
	{ "Fist of Justice",'jps.shouldKick(hpala.rangedTarget()) and jps.cooldown("Rebuke")~=0', hpala.rangedTarget },

-- Spells
	{ "Cleanse",'jps.dispelActive() and jps.DispelFriendlyTarget() ~= nil', jps.DispelFriendlyTarget()  , "dispelling unit " },
	-- dispel ALL DEBUFF of FriendUnit
	{ "Cleanse",'jps.dispelActive() and jps.DispelMagicTarget() ~= nil', jps.DispelMagicTarget() , "dispelling unit" },
	{ "Cleanse",'jps.dispelActive() and jps.DispelPoisonTarget() ~= nil', jps.DispelPoisonTarget() , "dispelling unit" },
	{ "Cleanse",'jps.dispelActive() and jps.DispelDiseaseTarget() ~= nil', jps.DispelDiseaseTarget() , "dispelling unit" },
	
-- Cooldowns                     
	{ "Lay on Hands",'jps.hp(hpala.myLowestImportantUnit()) < 0.20 and jps.UseCDs', hpala.myLowestImportantUnit, "casted lay on hands!" },
	{ "Divine Plea",'jps.mana() < 0.60 and jps.glyphInfo(45745) == false and jps.UseCDs', hpala.player },
	{ jps.useBagItem("Master Mana Potion"),'jps.mana() < 0.60 and jps.UseCDs', hpala.player },
	
	{ "Avenging Wrath",'jps.UseCDs and jps.CountInRaidStatus(0.7) > 2', hpala.player },
	{ "Avenging Wrath",'jps.UseCDs and jps.hp(hpala.ourHealTarget()) < 0.5 and hpala.unitIsImportant(hpala.ourHealTarget())', hpala.player },
	{ "Divine Favor",'jps.UseCDs and jps.CountInRaidStatus(0.7) > 2', hpala.player },
	{ "Divine Favor",'jps.UseCDs and jps.hp(hpala.ourHealTarget()) < 0.5 and hpala.unitIsImportant(hpala.ourHealTarget())', hpala.player },

	{ jps.useTrinket(0),'jps.UseCDs and not jps.isManaRegTrinket(0) and jps.useTrinket(0) ~= nil', "player"},
	{ jps.useTrinket(1),'jps.UseCDs and not jps.isManaRegTrinket(1) and jps.useTrinket(1) ~= nil', "player"},
	{ jps.useTrinket(0),'jps.UseCDs and jps.isManaRegTrinket(0) and jps.mana() < 0.8 and jps.useTrinket(0) ~= nil', "player"},
	{ jps.useTrinket(1),'jps.UseCDs and jps.isManaRegTrinket(1) and jps.mana() < 0.8 and jps.useTrinket(1) ~= nil', "player"},	
	-- Requires engineerins
	{ jps.useSynapseSprings(),'jps.UseCDs'},
	
	-- Requires herbalism
	{ "Lifeblood",'jps.UseCDs'},
	
	-- Multi Heals

	{ "Light's Hammer",'IsShiftKeyDown() ~= nil', hpala.ourHealTarget },
	{ "Light of Dawn",'jps.CountInRaidStatus(0.7) > 2 and jps.holyPower() > 2', hpala.ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
	{ "Light of Dawn",'jps.CountInRaidStatus(0.7) > 2 and jps.buff("Divine Purpose")', hpala.ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
	--{ "Holy Radiance",'jps.CountInRaidStatus(0.7) > 4', hpala.ourHealTarget },  	
	{ "Holy Radiance",'jps.MultiTarget and jps.CountInRaidStatus(0.71) > 2', hpala.ourHealTarget },  	

	-- Buffs
	{ "Seal of Insight",'GetShapeshiftForm() ~= 3', hpala.player },
	{ "Beacon of Light",'UnitIsUnit(hpala.myTank(),hpala.player())~=1 and not jps.buff("Beacon of Light",hpala.myTank()) and jps.beaconTarget == nil', hpala.myTank }, 
	{ "Eternal Flame",'jps.holyPower() > 2 and not jps.buff("Eternal Flame", hpala.myTank())', hpala.myTank },
	{ "Eternal Flame",'jps.buff("Divine Purpose") and not jps.buff("Eternal Flame", hpala.myTank())', hpala.myTank },
	{ "Sacred Shield",'UnitIsUnit(hpala.myTank(),hpala.player())~=1 and not jps.buff("Sacred Shield",hpala.myTank())', hpala.myTank },
	
	{ "Divine Protection",'jps.hp(hpala.player()) < 0.50', hpala.player },
	{ "Divine Shield",'jps.hp(hpala.player()) < 0.30 and jps.cooldown("Divine Protection")~=0', hpala.player },
	
-- Infusion of Light Proc
	{ "Divine Light",'jps.buff("Infusion of Light") and jps.hp(hpala.ourHealTarget()) < 0.6', hpala.ourHealTarget }, 

-- Divine Purpose Proc
	{ "Eternal Flame",'jps.buff("Divine Purpose") and not jps.buff("Eternal Flame", hpala.ourHealTarget())  and jps.hp(hpala.ourHealTarget()) < 0.97', hpala.ourHealTarget },
	{ "Word of Glory",'jps.buff("Divine Purpose") and jps.hp(hpala.ourHealTarget()) < 0.90', hpala.ourHealTarget }, 

-- Daybreak Proc
	{ "Holy Shock",'jps.buff("Daybreak") and jps.hp(hpala.ourHealTarget()) < 0.9', hpala.ourHealTarget }, -- heals with daybreak buff other targets

	-- tank + focus + target
	{ "Flash of Light",'jps.hp(hpala.ourHealTarget()) < 0.35 and hpala.unitIsImportant(hpala.ourHealTarget())', hpala.ourHealTarget },
	{ "Divine Light",'jps.hp(hpala.ourHealTarget()) < 0.78  and hpala.unitIsImportant(hpala.ourHealTarget())', hpala.ourHealTarget },
	{ "Holy Shock",'jps.hp(hpala.ourHealTarget()) < 0.94  and hpala.unitIsImportant(hpala.ourHealTarget())', hpala.ourHealTarget },
	{ "Holy Light",'jps.hp(hpala.ourHealTarget()) < 0.90  and hpala.unitIsImportant(hpala.ourHealTarget())', hpala.ourHealTarget },
		
	-- other raid / party
	{ "Flash of Light",'jps.hp(hpala.ourHealTarget()) < 0.30', hpala.ourHealTarget },
	{ "Divine Light",'jps.hp(hpala.ourHealTarget()) < 0.55', hpala.ourHealTarget },
	{ "Holy Shock",'jps.hp(hpala.ourHealTarget()) < 0.92', hpala.ourHealTarget },
	{ "Holy Light",'jps.hp(hpala.ourHealTarget()) < 0.90', hpala.ourHealTarget },
	{ "Word of Glory",'jps.holyPower() > 2 and jps.hp(hpala.ourHealTarget()) < 0.90', hpala.ourHealTarget },
	{ "Divine Plea",'jps.mana() < 0.60 and jps.CountInRaidStatus(0.8) < 1', hpala.player },
}

jps.registerRotation("PALADIN","HOLY",function()
	-- By Sphoenix, PCMD
	local spell = nil
	local target = nil
	
	if (GetTime() - hpala.timestamp) > hpala.UpdateInterval then
		hpala.update()
		hpala.timestamp = GetTime()
		hpala.shouldInterruptCasting(hpala.interruptTable)
	end

	spell,target = parseStaticSpellTable(hpala.spellTable)

	return spell,target
end, "Default")