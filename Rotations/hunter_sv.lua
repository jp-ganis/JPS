function hunter_sv(self)
	-- jpganis
	-- simcraft
	local spell = nil
	local sps_duration = jps.debuffDuration("serpent sting")
	local focus = UnitMana("player")
	local pet_attacking = IsPetAttackActive()

	local spellTable = 
	{
		{ {"macro","/petattack"}, not IsPetAttackActive() },
		{ "aspect of the hawk", not jps.buff("aspect of the hawk") and not jps.Moving },
		{ "aspect of the fox", not jps.buff("aspect of the fox") and jps.Moving },
		{ jps.DPSRacial, jps.UseCDs },
		{ "serpent sting", not jps.debuff("serpent sting") },
		{ "rapid fire", "onCD" },
		{ "explosive shot", jps.debuffDuration("explosive shot") < 0.3 },
		{ "black arrow" },
		{ "kill shot" },
		{ "arcane shot", focus >= 67 },
		{ "cobra shot" },
	}

	return parseSpellTable(spellTable)
end
