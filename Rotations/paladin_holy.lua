local L = MyLocalizationTable
	
	function paladin_holy()
	-- By Sphoenix
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
	---- Declarations                    
	--------------------------------------------------------------------------------------------
	
	local player = jpsName
	local playerhealth_pct = jps.hp(player)
	
	local Heal_Target = jps.LowestInRaidStatus() -- return Raid unit name with LOWEST PERCENTAGE in RaidStatus
	local health_deficiency = UnitHealthMax(Heal_Target) - UnitHealth(Heal_Target)
	local health_pct = jps.hp(Heal_Target) 
	
	local hPower = UnitPower("player",9) -- SPELL_POWER_HOLY_POWER = 9 
	local stance = GetShapeshiftForm()
	--Paladin (only when arg1 is nil)
	--1 = Seal of Truth
	--2 = Seal of Righteousness
	--3 = Seal of Insight - Seal of Justice if retribution
	--4 = Seal of Insight if retribution
	
	--------------------------------------------------------------------------------------------
	---- TANK                           
	--------------------------------------------------------------------------------------------
	
	local healMyTank = jps.findMeATank() -- if not "focus" return "player" as default
	local Tanktable = {}
	if jps.canHeal("focus") then -- WARNING FOCUS RETURN FALSE IF NOT IN GROUP OR RAID BECAUSE OF UNITINRANGE(UNIT)
		table.insert(Tanktable,player)
		if jps.canHeal("target") then table.insert(Tanktable,"target") end
		if jps.canHeal("focus") then table.insert(Tanktable,"focus") end
		local lowestHP = 1
		for i,j in ipairs(Tanktable) do
			local thisHP = UnitHealth(j) / UnitHealthMax(j)
			if jps.canHeal(j) and thisHP <= lowestHP then 
					lowestHP = thisHP
					healMyTank = GetUnitName(j)
			end
		end
	end
	
	--------------------------------------------------------------------------------------------
	---- RAID HEAL                          
	--------------------------------------------------------------------------------------------
	
	local countInRaid = jps.CountInRaidStatus(0.80)
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
		{ "Lay on Hands", health_pct < 0.20 and jps.UseCDs , Heal_Target },
		{ "Divine Plea", UnitPower (player,0)/UnitPowerMax (player,0) < 0.60 , player }, -- gain 12% of your total mana over 9 sec, but the amount healed by your healing spells is reduced by 50%.
		{ "Avenging Wrath", jps.UseCDs , player }, -- Increases all damage and healing caused by 20% for 20 sec
		{ "Divine Favor", jps.UseCDs , player }, -- Increases your spell casting haste by 20% and spell critical chance by 20% for 20 sec
		{ "Guardian of Ancient Kings", jps.UseCDs , rangedTarget }, -- Summons a Guardian of Ancient Kings to help you deal damage for 30 sec.The Guardian of Ancient Kings will attack your current enemy
		{ jps.useTrinket(1), jps.UseCDs },
		{ jps.useTrinket(2), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood", jps.UseCDs },
		
	-- Multi Heals
	
		{ "Light's Hammer", IsShiftKeyDown()  and jps.UseCDs, rangedTarget }, -- Deals 3268 to 3993 (+ 32.1% of SpellPower) Holy damage to enemies within the area and 3268 to 3993 (+ 32.1% of SpellPower) healing to allies within the area every 2 sec.
		{ "Light of Dawn", IsLeftControlKeyDown() and (hPower > 1) and (countInRaid > 2) , Heal_Target }, -- Consumes up to 3 Holy Power to emanate a wave of healing energy, healing up to 6 of the most injured targets in your party or raid within 30 yards 
		{ "Holy Radiance", jps.MultiTarget and (countInRaid > 2) , Heal_Target }, -- Imbues a friendly target with radiant energy, healing that target for 5098 to 6230 (+ 67.5% of SpellPower) and all allies within 10 yards for 50% of that amount. Grants a charge of Holy Power.
		{ "Holy Shock", jps.buff("Daybreak"), Heal_Target }, 	-- "Holy Shock" Blasts the target with Holy energy, causing 1371 to 1484 (+ 136% of SpellPower) Holy damage to an enemy, or 9014 to 9764 (+ 83.3% of SpellPower) healing to an ally, and granting a charge of Holy Power
																--						 "Daybreak" After casting Holy Radiance, your next Holy Shock will also heal other allies within 10 yards of the target for an amount equal to the original healing done, divided evenly among all targets
	-- Buffs
		{ "Seal of Insight", stance ~= 3 , player }, -- "Seal of Insight" Fills you with Holy Light, increasing your casting speed by 10%, improving healing spells by 5% 
		{ "Beacon of Light", (UnitIsUnit(healMyTank,player)~=1) and not jps.buff("Beacon of Light",healMyTank) , healMyTank }, -- "Beacon of Light" Your Holy Light will also heal the Beacon for 100% of the amount healed. Your Holy Radiance, Light of Dawn, Light's Hammer, and Holy Prism will heal for 15% of the amount healed. All other heals will heal for 50% of the amount healed.
		{ "Eternal Flame", (hPower > 2) and (not jps.buff("Eternal Flame")) , healMyTank }, -- "Eternal Flame" Consumes up to 3 Holy Power to place a protective Holy flame on a friendly target, which heals them for 5240 to 5837. Replaces Word of Glory.
		{ "Sacred Shield", (UnitIsUnit(healMyTank,player)~=1) and not jps.buff("Sacred Shield",healMyTank), healMyTank }, -- "Sacred Shield" Protects the target with a shield of Holy Light for 30 sec.
		
		{ "Divine Protection", (playerhealth_pct < 0.50) , player }, -- "Divine Protection" Reduces magical damage taken by 40% for 10 sec.
		{ "Divine Shield", (playerhealth_pct < 0.40) and jps.cooldown("Divine Protection")~=0 , player }, -- "Divine Shield" protects you from all damage and spells for 8 sec, but reduces all damage you deal by 50%
		
	-- Infusion of Light Proc
		{ "Divine Light", jps.buff("Infusion of Light") and (health_pct < 0.95), Heal_Target }, 	-- "Divine Light" A large heal that heals a friendly target for 15910 to 17725
																																	-- "Infusion of Light" reduces the cast time of your next Holy Light, Divine Light or Holy Radiance by 1.5 sec
		
	-- Divine Purpose Proc
		{ "Word of Glory", jps.buff("Divine Purpose") and (health_pct < 0.95), Heal_Target }, 	-- "Word of Glory" Consumes up to 3 Holy Power to heal a friendly target for 4803 to 5350 
																																	-- "Divine Purpose" Your next Holy Power ability will consume no Holy Power and will cast as if 3 Holy Power were consumed. Lasts 8 sec.
	-- Spells
		-- dispel SOME DEBUFF of FriendUnit according to a debuff table jps_DebuffToDispel_Name
		{ "Cleanse", jps.DispelFriendlyTarget() ~= nil  , jps.DispelFriendlyTarget()  , "Cleanse_Friendly_" },-- 4. Parameter for Debug only
		
		-- dispel ALL DEBUFF of FriendUnit
		{ "Cleanse", jps.DispelMagicTarget() ~= nil , jps.DispelMagicTarget() , "Cleanse_Magic_" },  -- 4. Parameter for Debug only
		{ "Holy Shock", (health_pct < 0.95) , Heal_Target },
		{ "Word of Glory", (hPower > 2) and (health_pct < 0.95) , Heal_Target },
		{ "Flash of Light", (health_pct < 0.30) , Heal_Target },
		{ "Divine Light", (health_pct < 0.50) , Heal_Target },
		{ "Holy Light", (health_pct < 0.95) , Heal_Target },
	
	}
	-- if you're only dps "target" you can let spell alone.
	-- if you want to cast some healing spell on others targets you must return the spell and target
	-- you don't need to add jps.Target = target because in fct combat jps.ThisCast,jps.Target = jps.Rotation()
   spell,target = parseSpellTable(spellTable)
   return spell,target 
end