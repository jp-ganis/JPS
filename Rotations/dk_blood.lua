function dk_blood()
	-- Talents:
	-- Tier 1: Roiling Blood
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
		
	local spellTable =
	{
		-- Blood presence
		{ "blood presence", 		not jps.buff("blood presence") },
		-- Moved DnD to the top so it will cast immediately
		{ "death and decay",		IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- GetCurrentKeyBoardFocus: Avoid casting while chat is open and you press shift
		-- { "army of the dead",		IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- todo

		-- Kick
		{ "mind freeze", 			jps.shouldKick() },
		{ "Strangulate", 			jps.shouldKick() and jps.LastCast ~= "mind freeze" },
		-- Aggro cooldowns
		{ "Raise Dead", 			jps.UseCDs and UnitExists("pet") == nil },
		{ "Dancing Rune Weapon", 	jps.UseCDs },
		-- Defensive cooldowns
		{ "Death Pact", 			jps.hp() < 0.5 and haveGhoul},
		{ "Icebound Fortitude", 	jps.hp() < 0.3 },
		{ "Vampiric Blood", 		jps.hp() < 0.5 },
		{ "Rune Tap", 				jps.hp() < 0.8 },
		-- Trinkets
		{ jps.useTrinket(0), 		jps.UseCDs }, 
		{ jps.useTrinket(1), 		jps.UseCDs }, 
		-- Buffs
		{ "Bone Shield", 			not jps.buff("bone shield") },
		-- Single target
		{ "outbreak",				ffDuration <= 2 or bpDuration <= 2 },
		{ "soul reaper",			jps.hp("target") <= 0.35 },
		{ "plague strike", 			not jps.debuff("blood plague") },
		{ "icy touch", 				not jps.debuff("frost fever") },
		{ "death strike", 			"onCD" },
		{ "blood boil", 			jps.buff("crimson scourge") },
		{ "heart strike", 			jps.debuff("blood plague") and jps.debuff("frost fever") },
		{ "rune strike", 			rp >= 40 },
		{ "horn of winter", 		"onCD" },
		{ "empower rune weapon" , 	not two_dr and not two_fr and not two_ur },
	}

	spell,target = parseSpellTable(spellTable) 
	return spell,target
end