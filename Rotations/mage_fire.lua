function mage_fire(self)
--pcmd
	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
	local spellTable = 
	{
	   --interrupt
		{ "Counterspell", jps.Interrupts and jps.shouldKick("target"), "target" },
		{ "Ice Barrier", (UnitHealth("player") / UnitHealthMax("player") < 0.40)  and not jps.buff("Ice Barrier","player"), "player" },
		
		--deff
		{ "Molten Armor", not jps.buff("Molten Armor","player"), "player" },
		
		--aoe
		{ "Dragon's Breath", CheckInteractDistance("target", 3) == 1, "target" }, 
		--{ "Flamestrike",	jps.MultiTarget }, --need groundClick demonstration
		
		--dots & opener
		{ "Combustion", jps.debuffDuration("Ignite") > 0 and jps.debuffDuration("Pyroblast") > 0  and jps.UseCDs, "target" },
		{ "Mirror Image", jps.UseCDs },
		--{ "Living Bomb", jps.debuffDuration("Living Bomb") == 0 , "target" },
		{ "Frost Bomb", jps.debuffDuration("Frost Bomb") == 0, "target" }, --depending on your talent tree
		
		--rotation
		{ "Inferno Blast", jps.buff("Heating Up","player"), "target" },
		{ "Pyroblast", jps.buff("Pyroblast!","player"), "target" },
		{ "Scorch", jps.Moving, "target" },
		{ "Fireball", "onCD", "target" },
		
		
	}

   return parseSpellTable(spellTable)
end