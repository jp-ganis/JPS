--jpganis

function dk_frost(self)
	local rp = UnitPower("player")

	local spellTable = 
	{
		-- Kicks
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },

		-- Offence
		{ "pillar of frost",	jps.useCDs },
		{ jps.DPSRacial,		jps.useCDs },

		-- Defence
		{ "raise dead",			jps.hp() <= 0.4 and rp >= 50 },
		{ "death pact",			GetTotemTimeLeft(1) > 0 },
		{ "icebound fortitude",	jps.hp() < 0.5 or (jps.debuff("deep freeze","player") or jps.debuff("kidney shot","player")) and jps.UseCDs },
		{ "death strike",		jps.hp() < 0.6 },

		-- Horn of Winter
		{ "horn of winter",		not jps.buff("horn of winter") },

		-- AoE
		{ "death and decay",	jps.MultiTarget },

		-- Mofes
		{ "howling blast",		not jps.debuff("frost fever") or jps.buff("freezing fog")},
		{ "plague strike",		not jps.debuff("blood plague") },
		{ "obliterate",			"onCD" },
		{ "frost strike",		"onCD" },
		
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
