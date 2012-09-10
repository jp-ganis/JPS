function dk_frost(self)
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local rp = UnitPower("player",1)
	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local fr1 = select(3,GetRuneCooldown(3))
	local fr2 = select(3,GetRuneCooldown(4))
	local ur1 = select(3,GetRuneCooldown(5))
	local ur2 = select(3,GetRuneCooldown(6))
	local one_dr = dr1 or dr2
	local two_dr = dr1 and dr2
	local one_fr = fr1 or fr2
	local two_fr = fr1 and fr2
	local one_ur = ur1 or ur2
	local two_ur = ur1 and ur2
	local ff_dur = jps.debuffDuration("frost fever")
	local bp_dur = jps.debuffDuration("blood plague")
	
	local spellTable = 
	{
		-- Kicks
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "Strangulate",		jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",		jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },

		-- Buffs
		{ "horn of winter",		"onCD" },

		-- Cooldowns
		{ "Pillar of Frost",	jps.UseCDs },
		{jps.useTrinket(1),     jps.UseCds },
		{jps.useTrinket(2),     jps.UseCds },
		{ "Unholy Blight",       jps.UseCds and (ff_dur <= 2 or bp_dur <= 2) and CheckInteractDistance("target",3) },  --only if skilled!!!!
		{ "outbreak",			ff_dur <= 2 or bp_dur <= 2 },	
		{ jps.DPSRacial,		jps.UseCDs and jps["DPS Racial"]},
		{ "raise dead",			jps.UseCDs and jps["Raise Dead (DPS)"] },
		
		-- AoE
		{ "death and decay",	jps.MultiTarget },
		{"Pestilence",          jps.MultiTarget and (ff_dur > 10 and bp_dur > 10)},

		-- Mofes
		{ "howling blast",		ff_dur <= 2 },
		{ "plague strike",		bp_dur <= 2 },
		{ "obliterate",			one_dr and one_ur and one_fr },
		{ "obliterate",			(two_dr and two_fr) or (two_dr and two_ur) or (two_fr and two_ur) },
		{ "frost strike",		rp > 110 },
		{ "howling blast",		jps.buff("Freezing Fog") },
		{ "obliterate",			two_dr or two_ur or two_fr },
		{ "frost strike",		rp > 100 },
		{ "obliterate",			"onCD" },
		{ "frost strike",		"onCD" },
		{ "howling blast",		"onCD" },
		{ "Empower Rune Weapon",jps.UseCDs and not (one_dr or one_fr or one_ur) },

	}

	local spell = parseSpellTable( spellTable )

	if spell == "death and decay" then
		jps.Cast( spell )
		jps.groundClick()
		spell = nil
	end

	return spell
end