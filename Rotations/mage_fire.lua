--Rotation
function mage_fire(self)
	--jpganis + SIMCRAFT
	--easiest rotation in game :P
	local spellTable = 
	{
		{ "scorch", not jps.debuff("critical mass") },
		{ "combustion", jps.myDebuff("living bomb") and jps.myDebuff("ignite") and jps.myDebuff("pyroblast") and jps.UseCDs },
		{ "mirror image", jps.UseCDs },
		{ "living bomb", not jps.debuff("living bomb") },
		{ "pyroblast", jps.buff("hot streak") },
		{ "flame orb" },
		{ "scorch", jps.Moving },
		{ "fireball" },
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
	}

	return SpellsUsedTable
end

--Config options
function mage_fire_config()
	--description
	--jps.NameOfOption
end
