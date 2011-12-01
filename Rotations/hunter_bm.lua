function hunter_bm(self)
	-- jpganis
	-- simcraft
	local spell = nil
	local sps_duration = jps.debuffDuration("serpent sting")
	local focus = UnitMana("player")
	local pet_focus = UnitMana("pet")
	local pet_frenzy = jps.buffStacks("Frenzy Effect","pet")
	local pet_attacking = IsPetAttackActive()

	local spellTable = 
	{
		{ {"macro","/petattack"}, not IsPetAttackActive() },
		{ "aspect of the hawk", not jps.buff("aspect of the hawk") and not jps.Moving },
		{ "aspect of the fox", not jps.buff("aspect of the fox") and jps.Moving },
		{ jps.DPSRacial, jps.UseCDs },
		{ "bestial wrath", focus > 60 },
		{ "serpent sting", not jps.debuff("serpent sting") },
		{ "kill shot", "onCD" },
		{ "rapid fire", not jps.buff("bloodlust") and not jps.buff("the beast within") and not jps.buff("heroism") and not jps.buff("time warp") },
		{ "kill command", "onCD" },
		{ "fervor",	focus <= 37 },
		{ "focus fire", pet_frenzy==5 and not jps.buff("the beast within")},
		{ "arcane shot", focus >= 59 or jps.buff("the beast within") },
		{ "cobra shot", "onCD" },
	}

	return parseSpellTable(spellTable)
end

	
