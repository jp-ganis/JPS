local L = MyLocalizationTable

function shouldInterruptCasting(spellsToCheck)
	local spellsWeShouldInterrupt = spellsToCheck
	
	local healTargetHP = jps.hp(jps.Target)
	local spellCasting = spell, _, _, _, _, endTime, _ = UnitCastingInfo("unit")
	if spellCasting == nil then return false end
	if not jps.canHeal(jps.Target) then return true end

	for healSpellTable, _ in pairs(spellsWeShouldInterrupt) do
		local breakpoint = healSpellTable[2]
		local spellName = healSpellTable[1] 
		local AOEHealBreakpoint = Ternary(healSpellTable[3] ~=nil, healSpellTable[3], false)
		if isAOESpell == false then 
			if healTargetHP > breakpoint then
				return true
			end
		else
			local targetsBelowAOEBreakpoint = jps.CountInRaidStatus(breakpoint)
			if AOEHealBreakpoint < targetsBelowAOEBreakpoint and  then
				return true
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
	-- left Shift Key 		- for Light's Hammer
	-- left Control Key	- for Light of Dawn

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
	local myLowestImportantUnit = jps.findMeATank() -- if not "focus" return "player" as default
	local myRaidTanks = jps.findTanksInRaid() -- get all players marked as tanks or with tank specific auras  
	local importantHealTargets = myRaidTanks -- tanks / focus / target / player
	local countInRaid = jps.CountInRaidStatus(0.70) -- number of players below 70% for AOE heals
	
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
	if shouldInterruptCasting({{"Holy Radiance", 0.7, 2}, {"Flash of Light", 0.5}, {"Divine Light", 0.7},{ "Holy Light", 0.85}}) then
		SpellStopCasting()
	return

	--------------------------------------------------------------------------------------------
	---- myLowestImportantUnit = tanks / focus / target / player
	--------------------------------------------------------------------------------------------
	table.insert(importantHealTargets,player)
	if jps.canHeal("target") then table.insert(importantHealTargets,"target") end
	if jps.canHeal("focus") then table.insert(importantHealTargets,"focus") end
	local lowestHP = 1
	for i,j in ipairs(importantHealTargets) do
		local thisHP = UnitHealth(j) / UnitHealthMax(j)
		if jps.canHeal(j) and thisHP <= lowestHP then 
				lowestHP = thisHP
				myLowestImportantUnit = GetUnitName(j)
		end
	end
	
	--------------------------------------------------------------------------------------------
	---- myLowestTank = tanks only for beacon ,sacred shield, eternal flame
	--------------------------------------------------------------------------------------------
	local lowestTankHP = 1
	for i,j in ipairs(myRaidTanks) do
		local thisHP = UnitHealth(j) / UnitHealthMax(j)
		if jps.canHeal(j) and thisHP <= lowestTankHP then 
				lowestTankHP = thisHP
				myLowestTank = GetUnitName(j)
		end
	end

	if lowestHP < healTargetHPPct then  -- heal our myLowestImportantUnit unit if myLowestImportantUnit hp < ourHealTarget HP
		ourHealTarget = myLowestImportantUnit
	end

	--------------------------------------------------------------------------------------------
	---- RAID HEAL                          
	--------------------------------------------------------------------------------------------
	
	-- COUNTS THE NUMBER OF PARTY MEMBERS INRANGE HAVING A SIGNIFICANT HEALTH PCT LOSS by default % health loss = 0.80
	----------------------
	-- DAMAGE
	----------------------
	-- JPS.CANDPS IS WORKING ONLY FOR PARTYN..TARGET AND RAIDN..TARGET NOT FOR UNITNAME..TARGET
	local EnemyUnit = {}
	for name, _ in pairs(jps.RaidTarget) do table.insert(EnemyUnit,name) end
	
	local rangedTarget = "target"
	if jps.canDPS("target") then
		rangedTarget = "target"
	elseif jps.canDPS("focustarget") then
		rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
		rangedTarget = "targettarget"
	elseif jps.canDPS(EnemyUnit[1]) then
		rangedTarget = EnemyUnit[1]
	end
	
	----------------------
	-- dont change beacon everytime you heal another tank
	----------------------
	if not jps.beaconTarget then
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
	local spellTable =
	{
	-- Kicks                    
	
		{ "Rebuke", jps.shouldKick(rangedTarget) , rangedTarget },
		{ "Rebuke", jps.shouldKick("focus"), "focus" },
		{ "Fist of Justice", jps.shouldKick(rangedTarget) and jps.cooldown("Rebuke")~=0 , rangedTarget },
		
	-- Cooldowns                     
		{ "Lay on Hands", lowestHP < 0.20 and jps.UseCDs , myLowestImportantUnit, "casted lay on hands!" },
		{ "Divine Plea", mana < 0.60 , player },
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

		{ "Light's Hammer", IsShiftKeyDown()  and jps.UseCDs and countInRaid > 2, rangedTarget },
		{ "Light of Dawn", IsLeftControlKeyDown() and (hPower > 2 or jps.buff("Divine Purpose")) and countInRaid > 2 , ourHealTarget }, -- since mop you don't have to face anymore a target! 30y radius
		{ "Holy Radiance", jps.MultiTarget and countInRaid > 2 , ourHealTarget },  -- only here jps.MultiTarget since it is a mana inefficent spell
		{ "Holy Shock", jps.buff("Daybreak") and healTargetHPPct < .9 , ourHealTarget }, -- heals with daybreak buff other targets

		-- Buffs
		{ "Seal of Insight", stance ~= 3 , player },
		{ "Beacon of Light", jps.canHeal("mouseover") and IsAltKeyDown() ~= nil not jps.buff("Beacon of Light","mouseover") , "mouseover" , "set beacon of light to our mouseover" }  -- set beacon of light on mouseover
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
		{ "Cleanse", jps.DispelFriendlyTarget() ~= nil  , jps.DispelFriendlyTarget()  , "dispelling unit " },
		-- dispel ALL DEBUFF of FriendUnit
		{ "Cleanse", jps.DispelMagicTarget() ~= nil , jps.DispelMagicTarget() , "dispelling unit" },
		
		{ "Flash of Light", (healTargetHPPct < 0.30) , ourHealTarget },
		{ "Divine Light", (healTargetHPPct < 0.50) , ourHealTarget },
		{ "Holy Light", (healTargetHPPct < 0.80) , ourHealTarget },
		{ "Holy Shock", (healTargetHPPct < 0.85) , ourHealTarget },
		{ "Word of Glory", (hPower > 2) and (healTargetHPPct < 0.90) , ourHealTarget },
		
	}
	
	spell,target = parseSpellTable(spellTable)

	if spell == "Beacon of Light" and target == "mouseover" then
		jps.beaconTarget = target
	end
   return spell,target 
end