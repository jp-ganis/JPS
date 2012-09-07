function dk_frost(self)
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local rp = UnitPower("player",1)
	local ff_dur = jps.debuffDuration("frost fever")
	local bp_dur = jps.debuffDuration("blood plague")
	local wholeRuneCount = 0
	
	function getRunes()
	   wholeRuneCount = 0
	   local runes = {}
	   local runeNames = {"dr","dr","fr","fr","ur","ur"}
	   for i = 0, 6,1 do 
	       local value = if select(3,GetRuneCooldown(i)) then 1 else 0 end
	       wholeRuneCount = if value == 1 then wholeRuneCount+1 else wholeRuneCount end
	       runes[runeNames[i]] = if runes[runeNames[i]] not nil then runes[runeNames[i]] + value else runes[runeNames[i]] end
	   end
	   return runes
	end
	
	function canCastObliterate()
	   local runes = getRunes()
	   if runes["fr"] >= 1 and runes["ur"] >= 1 then return true end
	   if runes["dr"] >= 1 and runes["ur"] >= 1 then return true end
	   if runes["fr"] >= 1 and runes["dr"] >= 1 then return true end
	   return false
	end

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
		{ "raise dead",			jps.UseCDs and jps["Raise Dead (DPS)"] },
		{ "outbreak",			ff_dur <= 2 or bp_dur <= 2 },	
		
		-- AoE
		{ "death and decay",	jps.MultiTarget and jps.cooldown("Death and Decas") == 0},
		
		-- Mofes
		{ "howling blast",		ff_dur <= 2 },
		{ "plague strike",		bp_dur <= 2 },
		{ "obliterate",			canCastObliterate() },
		{ "frost strike",		rp > 110 },
		{ "howling blast",		jps.buff("Freezing Fog") },
		{ "obliterate",			canCastObliterate() },
		{ "frost strike",		rp > 100 },
		{ "obliterate",			"onCD" },
		{ "frost strike",		"onCD" },
		{ "howling blast",		"onCD" },
		{ "Empower Rune Weapon",jps.UseCDs and (wholeRuneCount  < 4 or (getRunes()["fr"] < 2 and getRunes()["ur"] < 2)) },

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