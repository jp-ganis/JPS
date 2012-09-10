function new_dk_blood(self)
	-- Talents:
	-- Tier 1: Roiling Blood
	-- Tier 2: ...
	-- Tier 3: Death's Advance
	-- Tier 4: ...
	-- Tier 5: Runic Corruption
	-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell
	
	-- Usage info:
	-- Shift to DnD at mouse
	-- Cooldowns: trinkets, raise dead, dancing rune weapon

	-- Todo:
	-- Left Ctrl to use Army of the Dead

	local targetThreatStatus = UnitThreatSituation("player","target")
	if not targetThreatStatus then targetThreatStatus = 0 end

	local rp = UnitPower("player") 

	local ffDuration = jps.debuffDuration("frost fever")
	local bpDuration = jps.debuffDuration("blood plague")
	local bcStacks = jps.buffStacks("blood charge") --Blood Stacks

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

	-- Intelligent trinkets
	local trinket1ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket0Slot"))
	local canUseTrinket1,_ = GetItemSpell(trinket1ID)
	local _,Trinket1ready,_ = GetItemCooldown(trinket1ID)

	local trinket2ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket1Slot"))
	local canUseTrinket2,_ = GetItemSpell(trinket2ID)
	local _,Trinket2ready,_ = GetItemCooldown(trinket2ID)
	
	local spellTable =
	{
		-- Blood presence
		{ "blood presence", 		not jps.buff("blood presence") },
		-- Moved DnD to the top so it will cast immediately
		{ "death and decay",		IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- GetCurrentKeyBoardFocus: Avoid casting while chat is open and you press shift
--		{ "army of the dead",		IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- todo
		-- Taunt
		{ "dark command", 			targetThreatStatus ~= 3 and not jps.targetTargetTank() },
		-- Kick
		{ "mind freeze", 			jps.shouldKick() },
		{ "Strangulate", 			jps.shouldKick() and jps.LastCast ~= "mind freeze" },
		-- Aggro cooldowns
		{ "Raise Dead", 			jps.UseCDs },
		{ "Dancing Rune Weapon", 	jps.UseCDs },
		-- Defensive cooldowns
		{ "Icebound Fortitude", 	jps.hp() < 0.3 },
		{ "Vampiric Blood", 		jps.hp() < 0.5 },
		{ "Rune Tap", 				jps.hp() < 0.8 },
		-- Trinkets
		{ {"macro","/use 13"}, 		jps.UseCDs and canUseTrinket1 ~= nil and Trinket1ready == 0 }, -- 0 = no CD = trinket is ready 
		{ {"macro","/use 14"}, 		jps.UseCDs and canUseTrinket2 ~= nil and Trinket2ready == 0 }, 		
		-- Buffs
		{ "Bone Shield", 			not jps.buff("bone shield") },
		-- Single target
		{ "outbreak",				ffDuration <= 2 or bpDuration <= 2 },
		{ "plague strike", 			not jps.debuff("blood plague") },
		{ "icy touch", 				not jps.debuff("frost fever") },
		{ "death strike", 			"onCD" },
		{ "blood boil", 			jps.buff("crimson scourge") },
		{ "heart strike", 			jps.debuff("blood plague") and jps.debuff("frost fever") },
		{ "rune strike", 			rp >= 40 },
		{ "horn of winter", 		"onCD" },
		{ "empower rune weapon" , 	not two_dr and not two_fr and not two_ur },
	}

	spell = parseSpellTable(spellTable)
	if spell == "death and decay" then jps.groundClick() end

	return spell
end