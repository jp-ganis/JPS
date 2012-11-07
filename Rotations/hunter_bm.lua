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
	{ "aspect of the iron hawk", not jps.Moving and not jps.buff("aspect of the iron hawk") },
	{ "aspect of the fox", jps.Moving and not jps.buff("aspect of the fox") },
	{ "hunter's mark", not jps.debuff("hunter's mark") },
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