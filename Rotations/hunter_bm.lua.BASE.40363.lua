function hunter_bm(self)
-- valve
local spell = nil
local sps_duration = jps.debuffDuration("serpent sting")
local focus = UnitMana("player")
local pet_focus = UnitMana("pet")
local pet_frenzy = jps.buffStacks("Frenzy Effect","pet")
local pet_attacking = IsPetAttackActive()


local spellTable = 
{
	-- Aspect of the Iron Hawk if you have it and are not moving.
	{ "Aspect of the Iron Hawk", 
		not jps.Moving 
		and not jps.buff("Aspect of the Iron Hawk")
		and not jps.buff("Aspect of the Hawk") },

	-- Aspect of the Hawk otherwise if you're not moving.
	{ "Aspect of the Hawk", 
		not jps.Moving 
		and not jps.buff("Aspect of the Iron Hawk")
		and not jps.buff("Aspect of the Hawk") },

	-- Aspect of the Fox if you're moving.
	{ "Aspect of the Fox", 
		jps.Moving
		and not jps.buff("Aspect of the Fox") },

	-- Hunters Mark always.
	{ "Hunter's Mark", 
		not jps.debuff("Hunter's Mark") },

	{ "multi-shot", jps.MultiTarget },
	{ "serpent sting", not jps.debuff("serpent sting") },
	{ "fervor", focus < 65 and not jps.buff("fervor") },
	{ jps.DPSRacial, jps.UseCDs },
	{ "bestial wrath", focus > 60 and not jps.buff("the beast within") },
	{ "rapid fire", not jps.buff("rapid fire") and not jps.buff("the beast within") and not jps.bloodlusting() },
	{ "Stampede", jps.UseCDs, },
	{ "kill shot", },
	{ "kill command", },
	{ "a murder of crows", not jps.debuff("a murder of crows") },
	{ "glaive toss", },
	{ "lynx rush", },
	{ "dire beast", },
	{ "barrage", },
	{ "powershot", },
	{ "blink strike", },
	{ "arcane shot", jps.buff("thrill of the hunt") },
	{ "focus fire", pet_frenzy==5 },
	{ "cobra shot", focus <= 45 },
	{ "arcane shot", focus >= 46 },
}

return parseSpellTable(spellTable)
end