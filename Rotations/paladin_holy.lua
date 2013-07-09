	
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
	
	-- left ALT key		- for beacon of light on mouseover
	-- left Shift Key 		- for Light's Hammer
	-- left CTRL key for light of dawn
	
hpala = {}
hpala.interruptTable = {{"Flash of Light", 0.43}, {"Divine Light", 0.89},{ "Holy Light", 0.98}}

function hpala.updateValues()
	hpala.player = jpsName
	hpala.playerHealthPct = jps.hp(hpala.player)
	hpala.ourHealTarget = jps.LowestInRaidStatus()
	hpala.healTargetHPPct = jps.hp(hpala.ourHealTarget)
	hpala.mana = jps.mana()
	hpala.hPower = jps.holyPower()
	hpala.myLowestImportantUnit = jps.findMeATank()
	hpala.myRaidTanks = jps.findTanksInRaid() 
	hpala.importantHealTargets = hpala.myRaidTanks
	hpala.countInRaid = jps.CountInRaidStatus(0.8)
	
	--------------------------------------------------------------------------------------------
	---- myLowestImportantUnit = tanks / focus / target / player
	--------------------------------------------------------------------------------------------
	table.insert(hpala.importantHealTargets,player)
	if jps.canHeal("target") then table.insert(hpala.importantHealTargets,"target") end
	if jps.canHeal("focus") then table.insert(hpala.importantHealTargets,"focus") end
	
	hpala.lowestHP = 1
	for unitName, _ in ipairs(hpala.importantHealTargets) do
		local thisHP = jps.hp(unitName)
		if jps.canHeal(unitName) and thisHP <= hpala.lowestHP then 
				hpala.lowestHP = thisHP
				hpala.myLowestImportantUnit = unitName
		end
	end	
	--------------------------------------------------------------------------------------------
	---- myTank = tanks only for beacon ,sacred shield, eternal flame
	--------------------------------------------------------------------------------------------
	
	hpala.myTank = jps.findMeAggroTank("target")
	hpala.gotImportantHealTarget = false

	if hpala.lowestHP < hpala.healTargetHPPct or hpala.lowestHP < 0.5 then  -- heal our myLowestImportantUnit unit if myLowestImportantUnit hp < ourHealTarget HP or our important targets drop below 0.5
		hpala.ourHealTarget = hpala.myLowestImportantUnit
		hpala.gotImportantHealTarget = true
	end
	
	hpala.rangedTarget = "target"
	----------------------
	-- DAMAGE
	----------------------
	-- JPS.CANDPS IS WORKING ONLY FOR PARTYN.TARGET AND RAIDN.TARGET NOT FOR UNITNAME.TARGET
	
	if jps.canDPS("target") then
		hpala.rangedTarget = "target"
	elseif jps.canDPS("focustarget") then
		hpala.rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
		hpala.rangedTarget = "targettarget"
	end
	
	----------------------
	-- dont change beacon everytime you heal another tank
	----------------------
	if jps.beaconTarget ~=  nil then
		if not jps.buff("Beacon of Light", jps.beaconTarget) or not jps.canHeal(jps.beaconTarget) then
			jps.beaconTarget = nil
		end
	end
	
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
local spellTable = {}
spellTable[1] = {
	["ToolTip"] = "Holy Paladin PVE Full",
	-- Kicks                    
	{ "Rebuke",'jps.shouldKick(hpala.rangedTarget)', hpala.rangedTarget },
	{ "Rebuke",'jps.shouldKick("focus")', "focus" },
	{ "Fist of Justice",'jps.shouldKick(hpala.rangedTarget) and jps.cooldown("Rebuke")~=0', hpala.rangedTarget },
	
-- Cooldowns                     
	{ "Lay on Hands",'hpala.lowestHP < 0.20 and jps.UseCDs', hpala.myLowestImportantUnit, "casted lay on hands!" },
	{ "Divine Plea",'jps.mana() < 0.60 and jps.glyphInfo(45745) == false and jps.UseCDs', hpala.player },
	{ jps.useBagItem("Master Mana Potion"),'jps.mana() < 0.60 and jps.UseCDs', hpala.player },
	
	{ "Avenging Wrath",'jps.UseCDs', hpala.player },
	{ "Divine Favor",'jps.UseCDs', hpala.player },
	{ "Guardian of Ancient Kings",'jps.UseCDs', hpala.rangedTarget },
	{ jps.useTrinket(0),'jps.UseCDs'},
	{ jps.useTrinket(1),'jps.UseCDs'},
	
	-- Requires engineerins
	{ jps.useSynapseSprings(),'jps.UseCDs'},
	
	-- Requires herbalism
	{ "Lifeblood",'jps.UseCDs'},
	
	-- Multi Heals

	{ "Light's Hammer",'IsShiftKeyDown() ~= nil', hpala.ourHealTarget },
	{ "Light of Dawn",'IsLeftControlKeyDown() ~= nil and jps.holyPower() > 2', hpala.ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
	{ "Light of Dawn",'IsLeftControlKeyDown() ~= nil and jps.buff("Divine Purpose")', hpala.ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
		
	{ "Holy Radiance",'jps.MultiTarget and hpala.countInRaid > 2', hpala.ourHealTarget },  -- only here jps.MultiTarget since it is a jps.mana() inefficent spell
	{ "Holy Shock",'jps.buff("Daybreak") and hpala.healTargetHPPct < 0.9', hpala.ourHealTarget }, -- heals with daybreak buff other targets

	-- Buffs
	{ "Seal of Insight",'GetShapeshiftForm() ~= 3', hpala.player },
	{ "Beacon of Light",'jps.canHeal("mouseover") and IsAltKeyDown() ~= nil and not jps.buff("Beacon of Light","mouseover")', "mouseover" , "set beacon of light to our mouseover" },  -- set beacon of light on mouseover
	{ "Beacon of Light",'UnitIsUnit(hpala.myTank,hpala.player)~=1 and not jps.buff("Beacon of Light",hpala.myTank) and jps.beaconTarget == nil', hpala.myTank }, 
	{ "Eternal Flame",'jps.holyPower() > 2 and not jps.buff("Eternal Flame", hpala.myTank)', hpala.myTank },
	{ "Eternal Flame",'jps.buff("Divine Purpose") and not jps.buff("Eternal Flame", hpala.myTank)', hpala.myTank },
	{ "Sacred Shield",'UnitIsUnit(hpala.myTank,hpala.player)~=1 and not jps.buff("Sacred Shield",hpala.myTank)', hpala.myTank },
	
	{ "Divine Protection",'hpala.playerHealthPct < 0.50', hpala.player },
	{ "Divine Shield",'hpala.playerHealthPct < 0.30 and jps.cooldown("Divine Protection")~=0', hpala.player },
	
-- Infusion of Light Proc
	{ "Divine Light",'jps.buff("Infusion of Light") and hpala.healTargetHPPct < 0.5', hpala.ourHealTarget }, 

-- Divine Purpose Proc
	{ "Eternal Flame",'jps.holyPower() > 2 and not jps.buff("Eternal Flame", hpala.ourHealTarget)  and hpala.healTargetHPPct < 0.97', hpala.ourHealTarget },
	{ "Eternal Flame",'jps.buff("Divine Purpose") and not jps.buff("Eternal Flame", hpala.ourHealTarget)  and hpala.healTargetHPPct < 0.97', hpala.ourHealTarget },
	{ "Word of Glory",'jps.buff("Divine Purpose") and hpala.healTargetHPPct < 0.90', hpala.ourHealTarget }, 

-- Spells
	{ "Cleanse",'jps.dispelActive() and jps.DispelFriendlyTarget() ~= nil', jps.DispelFriendlyTarget()  , "dispelling unit " },
	-- dispel ALL DEBUFF of FriendUnit
	{ "Cleanse",'jps.dispelActive() and jps.DispelMagicTarget() ~= nil', jps.DispelMagicTarget() , "dispelling unit" },
	{ "Cleanse",'jps.dispelActive() and jps.DispelPoisonTarget() ~= nil', jps.DispelPoisonTarget() , "dispelling unit" },
	{ "Cleanse",'jps.dispelActive() and jps.DispelDiseaseTarget() ~= nil', jps.DispelDiseaseTarget() , "dispelling unit" },
	
	-- tank + focus + target
	{ "Flash of Light",'hpala.lowestHP < 0.35 and hpala.gotImportantHealTarget == true', hpala.ourHealTarget },
	{ "Divine Light",'hpala.lowestHP < 0.78  and hpala.gotImportantHealTarget == true', hpala.ourHealTarget },
	{ "Holy Shock",'hpala.lowestHP < 0.94  and hpala.gotImportantHealTarget == true', hpala.ourHealTarget },
	{ "Holy Light",'hpala.lowestHP < 0.90  and hpala.gotImportantHealTarget == true', hpala.ourHealTarget },
		
	-- other raid / party
	{ "Flash of Light",'hpala.healTargetHPPct < 0.30', hpala.ourHealTarget },
	{ "Divine Light",'hpala.healTargetHPPct < 0.55', hpala.ourHealTarget },
	{ "Holy Shock",'hpala.healTargetHPPct < 0.92', hpala.ourHealTarget },
	{ "Holy Light",'hpala.healTargetHPPct < 0.90', hpala.ourHealTarget },
	{ "Word of Glory",'jps.holyPower() > 2 and hpala.healTargetHPPct < 0.90', hpala.ourHealTarget },
	{ "Divine Plea",'jps.mana() < 0.60', hpala.player },
}

spellTable[2] = {
	["ToolTip"] = "Holy Paladin only tanks/Focus/self",
	-- Kicks                    
	{ "Rebuke",'jps.shouldKick(hpala.rangedTarget)', hpala.rangedTarget },
	{ "Rebuke",'jps.shouldKick("focus")', "focus" },
	{ "Fist of Justice",'jps.shouldKick(hpala.rangedTarget) and jps.cooldown("Rebuke")~=0', hpala.rangedTarget },
	
-- Cooldowns                     
	{ "Lay on Hands",'hpala.lowestHP < 0.20 and jps.UseCDs', hpala.myLowestImportantUnit, "casted lay on hands!" },
	{ "Divine Plea",'jps.mana() < 0.60 and jps.glyphInfo(45745) == false and jps.UseCDs', hpala.player },
	{ jps.useBagItem("Master Mana Potion"),'jps.mana() < 0.60 and jps.UseCDs', hpala.player },
	
	{ "Avenging Wrath",'jps.UseCDs', hpala.player },
	{ "Divine Favor",'jps.UseCDs', hpala.player },
	{ "Guardian of Ancient Kings",'jps.UseCDs', hpala.rangedTarget },
	{ jps.useTrinket(0),'jps.UseCDs'},
	{ jps.useTrinket(1),'jps.UseCDs'},
	
	-- Requires engineerins
	{ jps.useSynapseSprings(),'jps.UseCDs'},
	
	-- Requires herbalism
	{ "Lifeblood",'jps.UseCDs'},
	
	-- Multi Heals
	{ "Light's Hammer",'IsShiftKeyDown() ~= nil', hpala.ourHealTarget },
	{ "Light of Dawn",'jps.MultiTarget and jps.holyPower() > 2 and jps.countInRaidStatus(0.9) > 2', hpala.ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
	{ "Light of Dawn",'jps.MultiTarget and jps.buff("Divine Purpose") and jps.countInRaidStatus(0.9) > 2', hpala.ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
	{ "Holy Radiance",'jps.MultiTarget and hpala.countInRaid > 2', hpala.myLowestImportantUnit },  -- only here jps.MultiTarget since it is a jps.mana() inefficent spell
	{ "Holy Shock",'jps.buff("Daybreak") and hpala.lowestHP < 0.9', hpala.myLowestImportantUnit }, -- heals with daybreak buff other targets

	-- Buffs
	{ "Seal of Insight",'GetShapeshiftForm() ~= 3', hpala.player },
	{ "Beacon of Light",'jps.canHeal("mouseover") and IsAltKeyDown() ~= nil and not jps.buff("Beacon of Light","mouseover")', "mouseover" , "set beacon of light to our mouseover" },  -- set beacon of light on mouseover
	{ "Beacon of Light",'UnitIsUnit(hpala.myTank,hpala.player)~=1 and not jps.buff("Beacon of Light",hpala.myTank) and jps.beaconTarget == nil', hpala.myTank }, 
	{ "Eternal Flame",'jps.holyPower() > 2 and not jps.buff("Eternal Flame", hpala.myTank)', hpala.myTank },
	{ "Eternal Flame",'jps.buff("Divine Purpose") and not jps.buff("Eternal Flame", hpala.myTank)', hpala.myTank },
	{ "Sacred Shield",'UnitIsUnit(hpala.myTank,hpala.player)~=1 and not jps.buff("Sacred Shield",hpala.myTank)', hpala.myTank },
	
	{ "Divine Protection",'hpala.playerHealthPct < 0.50', hpala.player },
	{ "Divine Shield",'hpala.playerHealthPct < 0.30 and jps.cooldown("Divine Protection")~=0', hpala.player },
	
-- Infusion of Light Proc
	{ "Divine Light",'jps.buff("Infusion of Light") and hpala.lowestHP < 0.5', hpala.myLowestImportantUnit }, 

-- Divine Purpose Proc
	{ "Eternal Flame",'jps.holyPower() > 2 and not jps.buff("Eternal Flame", hpala.myLowestImportantUnit)  and hpala.lowestHP < 0.97', hpala.myLowestImportantUnit },
	{ "Eternal Flame",'jps.buff("Divine Purpose") and not jps.buff("Eternal Flame", hpala.myLowestImportantUnit)  and hpala.lowestHP < 0.97', hpala.myLowestImportantUnit },
	
	{ "Word of Glory",'jps.buff("Divine Purpose") and hpala.lowestHP < 0.90', hpala.myLowestImportantUnit }, 

-- Spells
	{ "Cleanse",'jps.dispelActive() and jps.DispelFriendlyTarget() ~= nil', jps.DispelFriendlyTarget()  , "dispelling unit " },
	-- dispel ALL DEBUFF of FriendUnit
	{ "Cleanse",'jps.dispelActive() and jps.DispelMagicTarget() ~= nil', jps.DispelMagicTarget() , "dispelling unit" },
	{ "Cleanse",'jps.dispelActive() and jps.DispelPoisonTarget() ~= nil', jps.DispelPoisonTarget() , "dispelling unit" },
	{ "Cleanse",'jps.dispelActive() and jps.DispelDiseaseTarget() ~= nil', jps.DispelDiseaseTarget() , "dispelling unit" },
	
	-- tank + focus + target
	{ "Flash of Light",'hpala.lowestHP < 0.35', hpala.myLowestImportantUnit },
	{ "Divine Light",'hpala.lowestHP < 0.78', hpala.myLowestImportantUnit },
	{ "Holy Shock",'hpala.lowestHP < 0.94', hpala.myLowestImportantUnit },
	{ "Holy Light",'hpala.lowestHP < 0.90', hpala.myLowestImportantUnit },
	{ "Divine Plea",'jps.mana() < 0.60', hpala.player },
}

function paladin_holy()
	-- By Sphoenix, PCMD
	local spell = nil
	local target = nil
	--------------------------------------------------------------------------------------------
	---- Stop Casting to save mana - curently no AOE spell support!
	--------------------------------------------------------------------------------------------
	hpala.updateValues()
	hpala.shouldInterruptCasting(hpala.interruptTable)
	
	local spellTableActive = jps.RotationActive(spellTable)

	spell,target = parseStaticSpellTable(spellTableActive)
	
	if spell == "Beacon of Light" then
		jps.beaconTarget = target
	end
	return spell,target
end