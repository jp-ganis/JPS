function dk_blood()
	-- Talents:
	-- Tier 1: Roiling Blood (for trash / add fights) or Plague Leech for Single Target
	-- Tier 2: Anti-Magic Zone
	-- Tier 3: Death's Advance
	-- Tier 4: Death Pact
	-- Tier 5: Runic Corruption
	-- Tier 6: Remorseless Winter
	-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell
	
	-- Usage info:
	-- Shift to DnD at mouse
	-- Cooldowns: trinkets, raise dead, dancing rune weapon

	-- Todo:
	-- Left Ctrl to use Army of the Dead

	-- Change: add UnitExists("pet") == nil for raise dead. In some rare situations the cooldown gets reset and it can try to cast it again (last boss in End of Time)
	
	local spell = nil
	local target = nil
	
	local rp = jps.runicPower();
	local ffDuration = jps.debuffDuration("frost fever")
	local bpDuration = jps.debuffDuration("blood plague")
	local bcStacks = jps.buffStacks("blood charge") --Blood Stacks
	local haveGhoul, _, _, _, _ = GetTotemInfo(1) --Information about Ghoul pet
	
	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local ur1 = select(3,GetRuneCooldown(3))
	local ur2 = select(3,GetRuneCooldown(4))
	local fr1 = select(3,GetRuneCooldown(5))
	local fr2 = select(3,GetRuneCooldown(6))
	local one_dr = dr1 or dr2
	local two_dr = dr1 and dr2
	local one_fr = fr1 or fr2
	local two_fr = fr1 and fr2
	local one_ur = ur1 or ur2
	local two_ur = ur1 and ur2
		
	local spellTable = {}
	
	spellTable[1] = {
		["ToolTip"] = "DK Blood Main",
		
		-- Blood presence
		{ "Blood Presence", not jps.buff("Blood Presence") },
		
		-- Shift is pressed
		{ "Death and Decay", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ "Anti-Magic Zone",		IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		-- Cntrol is pressed
		{ "Army of the Dead",		IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		-- Defensive cooldowns
		{ "Death Pact",		jps.hp() < .5 and haveGhoul },
		{ { "macro",  "/cast !Lichborne \r\n/cast [@player] Death Coil" }, jps.hp() < 0.5 and rp >= 40 and (jps.cooldown("Lichborne") == 0 or jps.buff("lichborne") )},
		{ "Rune Tap",		jps.hp() < .8 },
		{ "Icebound Fortitude",		jps.hp() < .3 },
		{ "Vampiric Blood",		jps.hp() < .4 },
		
		-- Interrupts
		{ "Mind Freeze",		jps.shouldKick() and jps.LastCast ~= "Strangulate" and jps.LastCast ~= "Asphyxiate" },
		{ "Strangulate",		jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Asphyxiate" },
		{ "Asphyxiate",		jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		
		-- Aggro cooldowns
		-- { "Dark Command",	 --	targetThreatStatus ~= 3 and not jps.targetTargetTank() },
		{ "Raise Dead",		jps.UseCDs and UnitExists("pet") == nil },
		{ "Dancing Rune Weapon",		jps.UseCDs },
		
		-- Death Siphon when we need a bit of healing. (talent based)
		{ "Death Siphon",		jps.hp() < .8 },
		
		-- Requires engineering
		{ jps.useSynapseSprings(),		jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood",		jps.UseCDs },
		
		-- Buff
		{ "Bone Shield",		not jps.buff("Bone Shield") },
				
		-- Diseases
		{ "Outbreak",	ffDuration <= 2 or bpDuration <= 2 },
		{ "Plague Strike",		not jps.debuff("Blood Plague") },
		{ "Icy Touch",		not jps.debuff("Frost Fever") },
		
		{ "Plague Leech",	ffDuration > 0	and bpDuration > 0 and ffDuration < 3 and bpDuration < 3},
		
		{ "Soul Reaper",		jps.hp("target") <= .35 },

		-- Multi target
		{ "Blood Boil",		jps.MultiTarget or jps.buff("Crimson Scourge")},
		
		-- Rotation
		{ "Death Strike", 	jps.hp() < .7 or jps.buffDuration("Blood Shield") < 3 },
		{ "Rune Strike",		rp >= 80 and not two_fr and not two_ur },
		{ "Death Strike" },

		{ "Heart Strike",		jps.debuff("Blood Plague") and jps.debuff("Frost Fever") },
		
		{ "Rune Strike",		rp >= 40 },
		
		{ "Horn of Winter" },
		
		{ "Empower Rune Weapon",	not two_dr and not two_fr and not two_ur },
	}
	
	spellTable[2] = {
		["ToolTip"] = "DK Diseases",

		-- Kicks
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "Strangulate",		jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",		jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },

		-- Buffs
		{ "blood presence",	 not jps.buff("blood presence") },
		{ "horn of winter",	 "onCD" },
		{ "Outbreak", ffDuration < 2 or bpDuration < 2 },
		{ "Unholy Blight", ffDuration < 2 or bpDuration < 2 },
		
		-- Diseases
		{ "Plague Strike",		not jps.debuff("Blood Plague") },
		{ "Icy Touch",		not jps.debuff("Frost Fever") },
		
	}

	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)

	return spell,target
end