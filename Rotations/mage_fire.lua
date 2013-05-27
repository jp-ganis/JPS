function mage_fire()
--pcmd

local spellTable = 
{
   --interrupt
	{ "Counterspell",     jps.Interrupts and jps.shouldKick("target"), "target" },
	{ "Counterspell",     jps.Interrupts and jps.shouldKick("focus"), "focus" },
	
	-- Deff 
	{ "Ice Barrier",      (UnitHealth("player") / UnitHealthMax("player") < 0.50)  and not jps.buff("Ice Barrier","player"), "player" },
	{ "Healthstone",      jps.hp() < .7 and GetItemCount("Healthstone", 0, 1) > 0 },

	--buffs
	{ "Molten Armor",     not jps.buff("Molten Armor","player"), "player" },
	{ "Arcane Brilliance",not jps.buff("Arcane Brilliance","player"), "player" },
	
	--aoe
	{ "Dragon's Breath",  CheckInteractDistance("target", 3) == 1, "target" }, 
	{ "Flamestrike",      jps.MultiTarget },
	
	--dots & opener
	{ "Combustion",       jps.debuffDuration("Ignite") > 0 and jps.debuffDuration("Pyroblast") > 0  and jps.UseCDs, "target" },
	
	--CDs
	{ "Mirror Image",     jps.UseCDs },
	{ jps.DPSRacial, jps.UseCDs },
	{ jps.useTrinket(1), jps.UseCDs },
	{ jps.useTrinket(2), jps.UseCDs },
	
	-- Requires engineerins
	{ jps.useSynapseSprings(), jps.UseCDs },
	
	-- Requires herbalism
	{ "Lifeblood", jps.UseCDs },

	{ "Living Bomb",    jps.debuffDuration("Living Bomb") == 0 , "target" }, --depending on your talent tree
	{ "Frost Bomb",       jps.debuffDuration("Frost Bomb") == 0, "target" }, --depending on your talent tree
	
	--rotation
	{ "Inferno Blast",    jps.buff("Heating Up","player"), "target" },
	{ "Pyroblast",        jps.buff("Pyroblast!","player"), "target" },
	{ "Scorch",           jps.Moving, "target" },
	{ "Fireball",         "onCD", "target" },
	
	
}
	
	local spell,target = parseSpellTable(spellTable)
	return spell,target
end
