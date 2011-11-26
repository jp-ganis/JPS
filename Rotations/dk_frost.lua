--jpganis
--Ty to SIMCRAFT for this rotation
function dk_frost(self)
	local rp = UnitPower("player")
	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local fr1 = select(3,GetRuneCooldown(3))
	local fr2 = select(3,GetRuneCooldown(4))
	local ur1 = select(3,GetRuneCooldown(5))
	local ur2 = select(3,GetRuneCooldown(6))
	local 1dr = dr1 or dr2
	local 2dr = dr1 and dr2
	local 1fr = fr1 or fr2
	local 2fr = fr1 and fr2
	local 1ur = ur1 or ur2
	local 2ur = ur1 and ur2
	local ff_dur = jps.debuffDuration("frost fever")
	local bp_dur = jps.debuffDuration("blood plague")

	local spellTable = 
	{
		-- Kicks
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "Strangulate",		jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",		jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },

		-- Cooldowns
		{ "Pillar of Frost",	jps.UseCDs },
		{ jps.DPSRacial,		jps.UseCDs and jps["DPS Racial"]},
		{ "Blood Tap",			not (dr1 or dr2) },
		{ "raise dead",			jps.UseCDs and jps["Raise Dead (DPS)"] },
		{ "outbreak",			ff_dur <= 2 or bp_dur <= 2 },	
		-- AoE
		{ "death and decay",	jps.MultiTarget },
		-- Mofes
		{ "howling blast",		ff_dur <= 2 },
		{ "plague strike",		bp_dur <= 2 },
		{ "obliterate",			1dr and 1ur and 1fr },
		{ "obliterate",			(2dr and 2fr) or (2dr and 2ur) or (2fr and 2ur) },
		{ "frost strike",		rp > 110 },
		{ "howling blast",		jps.buff("Freezing Fog") },
		{ "obliterate",			2dr or 2ur or 2fr },
		{ "frost strike",		rp > 100 },
		{ "obliterate",			"onCD" },
		{ "frost strike",		"onCD" },
		{ "howling blast",		"onCD" },
		{ "Empower Rune Weapon",jps.UseCDs and not (1dr or 1fr or 1ur) },
		
		-- Refresh it while we're here
		{ "horn of winter",		"onCD" },
	}

	local spell = parseSpellTable( spellTable )

	if spell == "death and decay" then
		jps.Cast( spell )
		jps.groundClick()
		spell = nil
	end

	return spell
end
