--jpganis

function dk_frost(self)
	local rp = UnitPower("player")

	local spellTable = 
	{
		-- Kicks
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "strangulate",		jps.shouldKick() and jps.UseCDs and jps.Strangulate and IsSpellInRange("strangulate","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "strangulate",		jps.shouldKick("focus") and jps.UseCDs and jps.Strangulate and IsSpellInRange("strangulate","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },

		-- Cooldowns
		{ "pillar of frost",	jps.UseCDs and jps["Pillar of Frost"] },
		{ "empower rune weapon",jps.UseCDs and jps["Empower Rune Weapon"] },
		{ jps.DPSRacial,		jps.UseCDs and jps["DPS Racial"]},

		-- Defence
		{ "raise dead",			jps.UseCDs and jps["Raise Dead (DPS)"] },
		{ "raise dead",			jps.hp() < 0.4 and rp >= 50 and jps.UseCDs and jps["Raise Dead (Sacrifice)"] },
		{ "death pact",			GetTotemTimeLeft(1) > 0 and jps.hp() < 0.4 and jps["Raise Dead (Sacrifice)"] },
		{ "icebound fortitude",	jps.hp() < 0.5 and jps.UseCDs and jps["Icebound Fortitude"] },

		-- Horn of Winter
		{ "horn of winter",		not jps.buff("horn of winter") },

		-- AoE
		{ "death and decay",	jps.MultiTarget },

		-- Mofes
		{ "howling blast",		not jps.debuff("frost fever") or jps.buff("freezing fog")},
		{ "plague strike",		not jps.debuff("blood plague") },
		{ "obliterate",			"onCD" },
		{ "frost strike",		"onCD" },
		{ "blood tap",			"onCD" and jps["Blood Tap"] },
		
		-- Refresh it while we're here
		{ "horn of winter",		true },
	}

	local spell = parseSpellTable( spellTable )

	if spell == "death and decay" then
		jps.Cast( spell )
		CameraOrSelectOrMoveStart()
		CameraOrSelectOrMoveStop()
		spell = nil
	end

	return spell
end
