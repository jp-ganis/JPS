function warrior_fury(self)

if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local spell = nil
	local playerHealth = UnitHealth("player")/UnitHealthMax("player")
	local targetHealth = UnitHealth("target")/UnitHealthMax("target")
	local nPower = UnitPower("Player",1) -- Rage est PowerType 1
	local stackExec = jps.buffStacks("Executioner","player") -- UnitAura("player", "Bourreau", nil, "PLAYER|HARMFUL")
	
-------------
-- BUFF
-------------

	local nRafale = jps.buff("Rafale","player")
	local nSang = jps.buff("Bloodsurge","player")
	local nRage = jps.buff("Berserker Rage","player")
	local nEnrage = jps.buff("Enrage","player")
	local nTrance = jps.buff("Battle Trance","player")
	local nEmul = jps.buff("Incite","player")
	local nMortal = jps.buff("Death Wish","player")
	local nVict = jps.buff("Victorious","player")
	local nExec = jps.buff("Executioner","player")

-------------
-- DEBUFF
-------------  	
  
   	local nColossus = false -- Colossus Smash
   	local nHamstr = false -- Hamstring
   	
   	if jps.checkTimer(86346) > 0 then nColossus = true end -- Colossus Smash
   	if jps.checkTimer(1715) > 0 then nHamstr = true end -- Hamstring

-------------------
-- DEBUG
-------------------

--if IsControlKeyDown() then
--print("|cff0070ddAfflux sanguin","|cffffffff",nSang,"|cff0070ddTranse: ","|cffffffff",nTrance)
--print("|cff0070ddEnrager: ","|cffffffff",nEnrage,"|cff0070ddRage berserker: ","|cffffffff",nRage)
--print("|cff0070ddRafale:","|cffffffff",nRafale,"|cff0070ddEmulation:","|cffffffff",nEmul)
--print("|cff0070ddPower:","|cffffffff",nPower)
--end

-------------
-- TRINKET
-------------  

	if IsEquippedItem("Appareil de Khaz'goroth") and select(1,GetItemCooldown(68972))==0 and IsUsableItem("Appareil de Khaz'goroth") and UnitHealth("target") > 500000 then 
		RunMacroText("/use Appareil de Khaz'goroth")
	elseif IsEquippedItem("Apparatus of Khaz'goroth") and select(1,GetItemCooldown(68972))==0 and IsUsableItem("Apparatus of Khaz'goroth") and UnitHealth("target") > 500000 then 
		RunMacroText("/use Apparatus of Khaz'goroth")
	end

------------------------
-- CONDITIONS ----------
------------------------

local spellTable_single = 
	{
		{ "Battle Shout", not ub("player","Battle Shout") and not ub("player","Roar of Courage") and not ub("player","Horn of Winter") and not ub("player","Strength of earth totem"), "player" },
		{ "Battle Shout", nPower < 10, "player" },
		{ "Commanding Shout", playerHealth < 0.25, "player" },
		{ "Berserker Rage", not nRage, "player" },
		{ "Intercept", jps.UseCDs, "target" },
		{ "Enraged Regeneration", playerHealth < 0.60 and nEnrage, "player" },
		{ "Pummel", jps.Interrupts and jps.shouldKick("target"), "target" },
		{ "Victory Rush", nVict, "target" },
		{ "Lifeblood", (UnitHealth("target") > 500000) and nRafale, "target" },
	-- Offensive Cooldowns
		{ "Heroic Throw", nPower>29 and UnitThreatSituation("player", "target")~=3, "target" },
		{ "Sunder Armor", (UnitHealth("target") > 500000) and (jps.debuffStacks("Sunder Armor","target") < 3), "target" },
		{ "Colossus Smash", nPower>39 and jps.cooldown("Death Wish") > 20, "target" },
		{ "Colossus Smash", nPower>39 and jps.cooldown("Death Wish") == 0, "target" },
		{ "Death Wish",	nPower>9 and (jps.checkTimer( 86346 ) > 0), "target" }, -- Colossus Smash (86346)
		{ "Recklessness", (UnitHealth("target") > 500000) and jps.checkTimer( 12292 ) > 0, "target" }, -- Death Wish (12292)
	-- Execution
		{ "Execute", targetHealth < 0.20 and ((stackExec==nil) or (stackExec<5)), "target" },
	-- Buff Death Wish and Colossus Smash
		{ "nested", nColossus and nMortal,
			{
				{ "Execute", targetHealth < 0.20 and ((stackExec==nil) or (stackExec<5)), "target" },
				{ "Bloodthirst", nPower>19, "target" },
				{ "Raging Blow", nPower>19 and (nEnrage or nRage), "target" },
				{ "Slam", nPower>14 and nSang, "target" },
				{ "Heroic Strike", nEmul and nPower>29, "target" },
			}
		},
	-- Normal moves
		{ "Bloodthirst", nPower>19, "target" },
		{ "Raging Blow", nPower>19 and (nEnrage or nRage), "target" },
		{ "Slam", nPower>14 and nSang, "target" },
		{ "Heroic Strike", nEmul and nPower>29, "target" }, 
		{ "Heroic Strike", nPower>89, "target" },
		{ "Hamstring", not nHamstr, "target" }, -- UnitIsPVP("player")==1
		-- { {"macro","/startattack"}, "onCD", "target" }, 
	}
	
local spellTable_multi = 
	{
		{ "Battle Shout", not ub("player","Battle Shout") and not ub("player","Roar of Courage") and not ub("player","Horn of Winter") and not ub("player","Strength of earth totem"), "player" },
		{ "Battle Shout", nPower < 10, "player" },
		{ "Commanding Shout", playerHealth < 0.25, "player" },
		{ "Berserker Rage", not nRage, "player" },
		{ "Intercept", jps.UseCDs, "target" },
		{ "Enraged Regeneration", playerHealth < 0.60 and nEnrage, "player" },
		{ "Pummel", jps.Interrupts and jps.shouldKick("target"), "target" },
		{ "Victory Rush", nVict, "target" },
		{ "Lifeblood", (UnitHealth("target") > 500000) and nRafale, "target" },
-- MultiTarget
		{ "Inner Rage", "onCD", "target" },
		{ "Cleave",	nPower>54, "target" },
		{ "Whirlwind",	nPower>24, "target" },
		{ "Bloodthirst", nPower>19, "target" },
		{ "Death Wish",	nPower>9, "target" },
	}

	local target = nil	
	if jps.MultiTarget then 
		spell, target = parseSpellTable(spellTable_multi)
	else
		spell, target = parseSpellTable(spellTable_single)
	end

	jps.Target = target
	return spell
end