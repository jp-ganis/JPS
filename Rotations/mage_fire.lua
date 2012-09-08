function mage_fire(self)
--pcmd
	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local spellTable = 
	{
	   --interrupt
		{ "Counterspell",     jps.Interrupts and jps.shouldKick("target"), "target" },
		{ "Ice Barrier",      (UnitHealth("player") / UnitHealthMax("player") < 0.40)  and not jps.buff("Ice Barrier","player"), "player" },
		
		--buffs
		{ "Molten Armor",     not jps.buff("Molten Armor","player"), "player" },
		{ "Arcane Brilliance",     not jps.buff("Arcane Brilliance","player"), "player" },
		
		--aoe
		{ "Dragon's Breath",  CheckInteractDistance("target", 3) == 1, "target" }, 
		{ "Flamestrike",      jps.MultiTarget },
		
		--dots & opener
		{ "Combustion",       jps.debuffDuration("Ignite") > 0 and jps.debuffDuration("Pyroblast") > 0  and jps.UseCDs, "target" },
		
		--CDs
		{ "Mirror Image",     jps.UseCDs },
		{jps.useTrinket(1),     jps.UseCDs},
		{jps.useTrinket(2),     jps.UseCDs},
		{ jps.DPSRacial,    jps.UseCDs and jps["DPS Racial"]},

		--{ "Living Bomb",    jps.debuffDuration("Living Bomb") == 0 , "target" },
		{ "Frost Bomb",       jps.debuffDuration("Frost Bomb") == 0, "target" }, --depending on your talent tree
		
		--rotation
		{ "Inferno Blast",    jps.buff("Heating Up","player"), "target" },
		{ "Pyroblast",        jps.buff("Pyroblast!","player"), "target" },
		{ "Scorch",           jps.Moving, "target" },
		{ "Fireball",         "onCD", "target" },
		
		
	}
   local spell,target = parseSpellTable(spellTable)
   if spell == "Flamestrike" then
       jps.Cast( spell )
       jps.groundClick()
   end

   jps.Target = target
   return spell
end
