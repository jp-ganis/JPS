local L = MyLocalizationTable

function shouldInterruptCasting(spellsToCheck)	
	local healTargetHP = jps.hp(jps.LastTarget)
	local spellCasting, _, _, _, _, endTime, _ = UnitCastingInfo("player")
	if spellCasting == nil then return false end
	if not jps.canHeal(jps.LastTarget) then return true end

	for key, healSpellTable  in pairs(spellsToCheck) do
		local breakpoint = healSpellTable[2]
		local spellName = healSpellTable[1]
		if spellName == spellCasting then
			if healTargetHP > breakpoint then
				return true
			end
			
		end
	end
	return false
end

function paladin_holy()
	-- By Sphoenix, PCMD
	local spell = nil
	local target = nil
	
	--------------------------------------------------------------------------------------------
	---- Information                     
	--------------------------------------------------------------------------------------------
	---- Talents:
	---- Tier 1: Pursuit of Justice
	---- Tier 2: Fist of Justice
	---- Tier 3: Sacred Shield
	---- Tier 4: Unbreakable Spirit
	---- Tier 5: Divine Purpose
	---- Tier 6: Light's Hammer
	
		
	--------------------------------------------------------------------------------------------
	---- Key modifiers
	--------------------------------------------------------------------------------------------
	
	-- left ALT key		- for beacon of light on mouseover
	-- left Control Key 		- for Light's Hammer

	--------------------------------------------------------------------------------------------
	---- Declarations                    
	--------------------------------------------------------------------------------------------
	
	local player = jpsName
	local playerHealthPct = jps.hp(player)
	
	local ourHealTarget = jps.LowestInRaidStatus() -- return Raid unit name with LOWEST PERCENTAGE in RaidStatus
	local healTargetHPPct = jps.hp(ourHealTarget) -- hp percentage of ourHealTarget
	local mana = UnitPower(player,0)/UnitPowerMax(player,0) -- our mana
	local hPower = UnitPower("player",9) -- SPELL_POWER_HOLY_POWER = 9 
	local stance = GetShapeshiftForm() -- stance
	local myLowestImportantUnit = jps.findMeATank() -- if not "tank" or  "focus" returns "player" as default
	local myRaidTanks = jps.findTanksInRaid() -- get all players marked as tanks or with tank specific auras  
	local importantHealTargets = myRaidTanks -- tanks / focus / target / player
	local countInRaid = jps.CountInRaidStatus(0.8) -- number of players below 70% for AOE heals
	
	--Paladin stance 
	--3 = Seal of Insight - Seal of Justice if retribution  

	--------------------------------------------------------------------------------------------
	---- Stop Casting to save mana
	--------------------------------------------------------------------------------------------
	--[[ 
		{ 
			{
				spellName,
				 maxHealthBeforStopCasting, 
				 AOE only, number of players below maxHealthBeforStopCasting
			}, 
			{{"Holy Radiance", 0.7, 2}, {"Flash of Light", 0.5}, {"Divine Light", 0.7},{ "Holy Light", 0.85}}
			{.....},
		} 
	]]--
	if shouldInterruptCasting({{"Flash of Light", 0.43}, {"Divine Light", 0.89},{ "Holy Light", 0.95}}) then
		print("interrupt cast, unit "..jps.LastTarget.. " has enough hp!");
		SpellStopCasting()
	end

	--------------------------------------------------------------------------------------------
	---- myLowestImportantUnit = tanks / focus / target / player
	--------------------------------------------------------------------------------------------
	table.insert(importantHealTargets,player)
	if jps.canHeal("target") then table.insert(importantHealTargets,"target") end
	if jps.canHeal("focus") then table.insert(importantHealTargets,"focus") end
	local lowestHP = 1
	for unitName, _ in ipairs(importantHealTargets) do
		local thisHP = jps.hp(unitName)
		if jps.canHeal(unitName) and thisHP <= lowestHP then 
				lowestHP = thisHP
				myLowestImportantUnit = unitName
		end
	end
	
	--------------------------------------------------------------------------------------------
	---- myLowestTank = tanks only for beacon ,sacred shield, eternal flame
	--------------------------------------------------------------------------------------------
	local lowestTankHP = 1
	local myLowestTank = jps.findMeATank()
	for unitName, _ in ipairs(myRaidTanks) do
		local thisHP = jps.hp(unitName)
		if jps.canHeal(unitName) and thisHP <= lowestTankHP then 
				lowestTankHP = thisHP
				myLowestTank = unitName
		end
	end
	
	local ourHealTargetIsTank = false
	if lowestHP < healTargetHPPct then  -- heal our myLowestImportantUnit unit if myLowestImportantUnit hp < ourHealTarget HP
		ourHealTarget = myLowestImportantUnit
		ourHealTargetIsTank = true
	end

	----------------------
	-- DAMAGE
	----------------------
	-- JPS.CANDPS IS WORKING ONLY FOR PARTYN..TARGET AND RAIDN..TARGET NOT FOR UNITNAME..TARGET
	local EnemyUnit = {}
	for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end
	
	local rangedTarget = "target"
	if jps.canDPS("target") then
		rangedTarget = "target"
	elseif jps.canDPS("focustarget") then
		rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
		rangedTarget = "targettarget"
	end
	
	----------------------
	-- dont change beacon everytime you heal another tank
	----------------------
	if jps.beaconTarget == nil then
		jps.beaconTarget = nil
	end
	local haveUnitWithBeacon = false
	if jps.beaconTarget ~=  nil then
		if jps.buff("Beacon of Light", jps.beaconTarget) == true then
			haveUnitWithBeacon = true
		end
	else
		jps.beaconTarget = myLowestImportantUnit
	end
	------------------------
	-- SPELL TABLE -----
	------------------------
	local spellTable = {}
	spellTable[1] = {
    	["ToolTip"] = "Holy Paladin PVE Full",
		-- Kicks                    
		{ "Rebuke", jps.shouldKick(rangedTarget) , rangedTarget },
		{ "Rebuke", jps.shouldKick("focus"), "focus" },
		{ "Fist of Justice", jps.shouldKick(rangedTarget) and jps.cooldown("Rebuke")~=0 , rangedTarget },
		
	-- Cooldowns                     
		{ "Lay on Hands", lowestHP < 0.20 and jps.UseCDs , myLowestImportantUnit, "casted lay on hands!" },
		{ "Divine Plea", mana < 0.60 and jps.glyphInfo(45745) == false , player },
		
		{ "Avenging Wrath", jps.UseCDs , player },
		{ "Divine Favor", jps.UseCDs , player },
		{ "Guardian of Ancient Kings", jps.UseCDs , rangedTarget },
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood", jps.UseCDs },
		
		-- Multi Heals

		{ "Light's Hammer", IsShiftKeyDown() ~= nil, rangedTarget },
		{ "Light of Dawn",  hPower > 2 or jps.buff("Divine Purpose") and jps.CountInRaidStatus(0.9) > 2 , ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
		{ "Holy Radiance", jps.MultiTarget and countInRaid > 2 , ourHealTarget },  -- only here jps.MultiTarget since it is a mana inefficent spell
		{ "Holy Shock", jps.buff("Daybreak") and healTargetHPPct < .9 , ourHealTarget }, -- heals with daybreak buff other targets

		-- Buffs
		{ "Seal of Insight", stance ~= 3 , player },
		{ "Beacon of Light", jps.canHeal("mouseover") and IsAltKeyDown() ~= nil and not jps.buff("Beacon of Light","mouseover") , "mouseover" , "set beacon of light to our mouseover" },  -- set beacon of light on mouseover
		{ "Beacon of Light", (UnitIsUnit(myLowestTank,player)~=1) and not jps.buff("Beacon of Light",myLowestTank) and haveUnitWithBeacon == false, myLowestTank }, 
		{ "Eternal Flame", (hPower > 2) and not jps.buff("Eternal Flame", myLowestTank) , myLowestTank },
		{ "Sacred Shield", (UnitIsUnit(myLowestTank,player)~=1) and not jps.buff("Sacred Shield",myLowestTank), myLowestTank },
		
		{ "Divine Protection", (playerHealthPct < 0.50) , player },
		{ "Divine Shield", (playerHealthPct < 0.30) and jps.cooldown("Divine Protection")~=0 , player },
		
	-- Infusion of Light Proc
		{ "Divine Light", jps.buff("Infusion of Light") and (healTargetHPPct < 0.5), ourHealTarget }, 

	-- Divine Purpose Proc
		{ "Word of Glory", jps.buff("Divine Purpose") and (healTargetHPPct < 0.90), ourHealTarget }, 

	-- Spells
		{ "Cleanse", jps.dispelActive() and jps.DispelFriendlyTarget() ~= nil  , jps.DispelFriendlyTarget()  , "dispelling unit " },
		-- dispel ALL DEBUFF of FriendUnit
		{ "Cleanse", jps.dispelActive() and jps.DispelMagicTarget() ~= nil , jps.DispelMagicTarget() , "dispelling unit" },
		{ "Cleanse", jps.dispelActive() and jps.DispelPoisonTarget() ~= nil , jps.DispelPoisonTarget() , "dispelling unit" },
		{ "Cleanse", jps.dispelActive() and jps.DispelDiseaseTarget() ~= nil , jps.DispelDiseaseTarget() , "dispelling unit" },
		
		-- tank + focus + target
		{ "Flash of Light", lowestHP < 0.35 and ourHealTargetIsTank == true , ourHealTarget },
		{ "Divine Light", lowestHP < 0.78  and ourHealTargetIsTank == true, ourHealTarget },
		{ "Holy Shock", lowestHP < 0.94  and ourHealTargetIsTank == true, ourHealTarget },
		{ "Holy Light", lowestHP < 0.90  and ourHealTargetIsTank == true, ourHealTarget },
		
		-- other raid / party
		{ "Flash of Light", (healTargetHPPct < 0.30) , ourHealTarget },
		{ "Divine Light", healTargetHPPct < 0.55, ourHealTarget },
		{ "Holy Shock", healTargetHPPct < 0.92 , ourHealTarget },
		{ "Holy Light", healTargetHPPct < 0.90 , ourHealTarget },
		{ "Word of Glory", (hPower > 2) and (healTargetHPPct < 0.90) , ourHealTarget },
		{ "Divine Plea", mana < 0.60, player },
	}

	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)
	if spell == "Beacon of Light" and target == "mouseover" then
		jps.beaconTarget = target
	end
	return spell,target
end