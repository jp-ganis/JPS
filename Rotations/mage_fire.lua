function mage_fire(self)

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
	
--	local nBombe = UnitAura("target", "Living Bomb", nil, "PLAYER|HARMFUL") 
--	local nEnflam = UnitAura("target", "Ignite", nil, "PLAYER|HARMFUL") 
--	local nPyro = UnitAura("target", "Pyroblast", nil, "PLAYER|HARMFUL")

	local nBombe = false -- "Living Bomb" 44457 -- jps.debuff("Living Bomb","target")
	local nEnflam = false -- "Ignite" -- 12654 -- jps.debuff("Ignite","target")
	local nPyro = false -- "Pyroblast!" -- 92315 -- jps.debuff("Pyroblast!","target")
	local nFrost = false -- "Frostfire Bolt" 44614 -- jps.debuff("Frostfire Bolt","target")
	local nMass = false -- "Critical Mass" 22959 -- jps.debuff("Critical mass","target")

   	for i=1,40 do
    	local ID = select(11,UnitDebuff("target",i))
    	if ID  == 44457 then nBombe = true end
    	if ID  == 12654 then nEnflam = true end
    	if ID  == 92315 then nPyro = true end
    	if ID  == 44614 or ID  == 59638 then nFrost = true end
    	if ID  == 22959 then nMass = true end
   	end

	local spellTable = 
	{
		{ "Counterspell", jps.Interrupts and jps.shouldKick("target"), "target" },
		{ "Mana Shield", (UnitHealth("player") / UnitHealthMax("player") < 0.40) and CheckInteractDistance("target", 3) == 1 and not jps.buff("Mana Shield","player"), "player" },
		{ "Molten Armor", not jps.buff("Molten Armor","player"), "player" },
		{ "Frostfire Bolt", not nFrost and CheckInteractDistance("target", 4) ~= 1 , "target" }, -- > 28 yards
		{ "Dragon's Breath", UnitHealth("target")/UnitHealthMax("target") > 0.20 and CheckInteractDistance("target", 3) == 1, "target" }, -- < 10 yards
		{ "Fire Blast", jps.buff("Impact","player"), "target" },
		{ "Fire Blast", CheckInteractDistance("target", 3) == 1, "target" },
		{ "Scorch", not nMass, "target" },
		{ "Combustion", nBombe and nEnflam and nPyro and jps.UseCDs, "target" },
		{ "Mirror Image", jps.UseCDs },
		{ "Living Bomb", not nBombe, "target" },
		{ jps.DPSRacial, UnitHealth("target")/UnitHealthMax("target") > 0.50, "target" }, -- "Lifeblood"
		{ "Pyroblast", jps.buff("Hot Streak","player"), "target" },
		{ "Flame Orb", "onCD", "target" },
		{ "Scorch", jps.Moving, "target" },
		{ "Fireball", "onCD", "target" },
	}

	return parseSpellTable(spellTable)
end

--Spells
function mage_fire_spells()
	local SpellUseTable =
	{
		"Scorch",
		"Combustion",
		"Mirror Image",
		"Living Bomb",
		"Pyroblast",
		"Flame Orb",
		"Fireball",
		"Fire Blast",
		"Frostfire Bolt",
	}

	return SpellsUsedTable
end

--Config options
function mage_fire_config()
	--description
	--jps.NameOfOption
end

-- Scorch -- Brûlure
-- Critical mass -- Masse critique
-- Combustion -- Combustion
-- Living Bomb -- Bombe vivante
-- Ignite -- Enflammer
-- Pyroblast -- Explosion pyrotechnique
-- Hot Streak -- Chaleur continue
-- Flame orb -- Orbe enflammé
-- Fireball -- Boule de feu
-- Molten Armor -- Armure de la fournaise
-- Counterspell -- Contresort
-- Mana Shield -- Bouclier de mana
-- Frostfire Bolt -- Eclair de givrefeu
-- Dragon's Breath -- Souffle du dragon
-- Fire Blast -- Trait de feu
-- Flame Orb -- Orbe enflammé
-- Impact -- Impact
-- Lifeblood -- Sang-de-vie
-- Mirror Image -- Image miroir

-- Critical Mass 22959
-- Ignite 12654
-- Pyroblast! 92315
-- Pyroblast 11366
-- Living Bomb 44457
-- Impact 12355
-- Frosbolt 59638
-- Frostfire Bolt 44614