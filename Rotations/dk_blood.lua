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
	-- left alt for anti magic zone
	-- left ctrl for army of death
	-- shift + left alt for battle rezz at your focus or (if focus is not death , or no focus or focus target out of range) mouseover	
	-- Cooldowns: trinkets, raise dead, dancing rune weapon, synapse springs, lifeblood 

	-- focus on other tank in raids !

	
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

	-- function for checking diseases on target for plague leech, because we need fresh dot time left
	function canCastPlagueLeech(timeLeft)  
		if not jps.debuff("frost fever") or not jps.debuff("blood plague") then return false end
		if jps.debuffDuration("Frost Fever") > timeLeft or jps.debuffDuration("Blood Plague") > timeLeft then
			return false
		end
		if jps.debuffDuration("Frost Fever") == 0 or jps.debuffDuration("Blood Plague") == 0 then
			return false
		end
		return true
	end

	local spellTable = {}
	
	spellTable[1] = {
		["ToolTip"] = "DK Blood Main",			
		
		-- Blood presence
		{ "Blood Presence",			 not jps.buff("Blood Presence") },
		
    	-- Battle Rezz
    	{ "Raise Ally",			UnitIsDeadOrGhost("focus") == 1 and UnitPlayerControlled("focus") == true and jps.UseCds and IsLeftAltKeyDown()  ~= nil and GetCurrentKeyBoardFocus() == nil  , "focus" },
    	{ "Raise Ally",			UnitIsDeadOrGhost("mouseover") == 1 and UnitPlayerControlled("mouseover") == true and jps.UseCds and IsLeftAltKeyDown()  ~= nil  and GetCurrentKeyBoardFocus() == nil , "mouseover" },

		-- Shift is pressed
		{ "Death and Decay",			IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and not IsLeftAltKeyDown() },
		{ "Anti-Magic Zone",			IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and not IsShiftKeyDown() },
		
		-- Cntrol is pressed
		{ "Army of the Dead",			IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		-- Defensive cooldowns
		{ "Death Pact",			jps.hp() < .5 and haveGhoul },
		{ "Lichborne",			jps.hp() < 0.5 and rp >= 40 and jps.IsSpellKnown("Lichborne") },
		{ "Death Coil",			 		jps.hp() < 0.5 and rp >= 40 and jps.buff("lichborne"), "player" }, 
		{ "Rune Tap",			jps.hp() < .8 },
		{ "Icebound Fortitude",			jps.hp() < .3 and jps.UseCDs},
		{ "Vampiric Blood",			jps.hp() < .4 },
		
		-- Interrupts
		{ "Mind Freeze",			jps.shouldKick() and jps.LastCast ~= "Strangulate" and jps.LastCast ~= "Asphyxiate" },
		{ "Strangulate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Asphyxiate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		
		-- Aggro cooldowns
		-- { "Dark Command",			 --	targetThreatStatus ~= 3 and not jps.targetTargetTank() },
		{ "Raise Dead",			jps.UseCDs and UnitExists("pet") == nil },
		{ "Dancing Rune Weapon",			jps.UseCDs },
		
		-- Requires engineering
		{ jps.useSynapseSprings(),		jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood",			jps.UseCDs },
		
		-- Racials
    	{ jps.DPSRacial, 		jps.UseCDs },
		
		-- Buff
		{ "Bone Shield",			not jps.buff("Bone Shield") },
				
		-- Diseases
		{ "Outbreak",			ffDuration <= 2 or bpDuration <= 2 },
		{ "Plague Strike",			not jps.debuff("Blood Plague") },
		{ "Icy Touch",			not jps.debuff("Frost Fever") },
		
		{ "Plague Leech",			canCastPlagueLeech(3)},
		
		{ "Soul Reaper",			jps.hp("target") <= .35 },

		-- Multi target
		{ "Blood Boil",			jps.MultiTarget or jps.buff("Crimson Scourge")},
		
		-- Rotation
		{ "Death Strike",			 	jps.hp() < .7 or jps.buffDuration("Blood Shield") < 3 },
		{ "Rune Strike",			rp >= 80 and not two_fr and not two_ur },
		{ "Death Strike" },

		-- Death Siphon when we need a bit of healing. (talent based)
		{ "Death Siphon",			jps.hp() < .6 }, -- moved here, because we heal often more with Death Strike than Death Siphon

		{ "Heart Strike",			jps.debuff("Blood Plague") and jps.debuff("Frost Fever") },
		
		{ "Rune Strike",			rp >= 40 and jps.hp() > 0.5 and not jps.buff("lichborne") }, -- stop casting Rune Strike if Lichborne is up
		
		{ "Horn of Winter" },
		
		{ "Empower Rune Weapon",			not two_dr and not two_fr and not two_ur },
	}
	
	spellTable[2] = {
		["ToolTip"] = "DK Diseases",			


		-- Kicks
		{ "mind freeze",			jps.shouldKick() },
		{ "mind freeze",			jps.shouldKick("focus"), "focus" },
		{ "Strangulate",			jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze",			"target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",			jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze",			"focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate",			 "focus" },

		-- Buffs
		{ "blood presence",			 not jps.buff("blood presence") },
		{ "horn of winter",			 "onCD" },
		{ "Outbreak",			 ffDuration < 2 or bpDuration < 2 },
		{ "Unholy Blight",			 ffDuration < 2 or bpDuration < 2 },
		
		-- Diseases
		{ "Plague Strike",			not jps.debuff("Blood Plague") },
		{ "Icy Touch",			not jps.debuff("Frost Fever") },
		
	}

	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)

	return spell,target
end
