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
dkBloodSpellTable = {}
dkBloodSpellTable[1] = {
	-- Blood presence
	{"Blood Presence",'not jps.buff("Blood Presence")'},

	-- Battle Rezz
	{ "Raise Ally",'UnitIsDeadOrGhost("focus") == 1 and jps.UseCds', "focus" },
	{ "Raise Ally",'UnitIsDeadOrGhost("target") == 1 and jps.UseCds', "target"},

	-- Shift is pressed
	{"Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'},
	{"Anti-Magic Zone",'IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil '},

	-- Cntrol is pressed
	--{"Army of the Dead",'IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'},

	-- Defensive cooldowns

	{"Death Pact",'jps.hp() < 0.5 and dk.hasGhoul()'},
	{"Lichborne",'jps.UseCDs and jps.hp() < 0.5 and jps.runicPower() >= 40 and jps.IsSpellKnown("Lichborne")'},
	{"Death Coil",'jps.hp() < 0.9 and jps.runicPower() >= 40 and jps.buff("lichborne")', "player"},
	{"Rune Tap",'jps.hp() < 0.8'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.70'},
	{"Icebound Fortitude",'jps.UseCDs and jps.hp() <= 0.3'},
	{"Vampiric Blood",'jps.UseCDs and jps.hp() < 0.4'},

	
	-- Interrupts
	{"mind freeze",'jps.shouldKick()'},
	{"mind freeze",'jps.shouldKick("focus")', "focus"},
	{"Strangulate",'jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze"'},
	{"Strangulate",'jps.shouldKick("mouseover") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "mouseover" },
	{"Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "focus" },
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"'},
	{"Asphyxiate",'jps.shouldKick("mouseover") and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "mouseover"},
	{"Asphyxiate",'jps.shouldKick("focus") and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "focus"},
	
	-- Spell Steal
	{"Dark Simulacrum ", 'dk.shouldDarkSimTarget()' , "target"},
	{"Dark Simulacrum ", 'dk.shouldDarkSimFocus()' , "focus"},

	{"Raise Dead",'jps.UseCDs and not dk.hasGhoul()'},
	
	{"nested", 'IsSpellInRange("Rune Strike","target") == 1',{
		{"Dancing Rune Weapon",'jps.UseCDs'},
	
		-- Requires engineering
		{ jps.useSynapseSprings(),'jps.useSynapseSprings() ~= "" and jps.UseCDs'},
	
		-- Requires herbalism
		{"Lifeblood",'jps.UseCDs'},
	
		-- Racials
		{ jps.getDPSRacial(),'jps.UseCDs'},
	}},


	-- Buff
	{"Bone Shield",'not jps.buff("Bone Shield")'},

	-- Diseases
	{"Unholy Blight",'jps.myDebuffDuration("frost fever") < 2'},
	{"Unholy Blight",'jps.myDebuffDuration("blood plague") < 2'},
	{"Outbreak",'jps.myDebuffDuration("frost fever") < 2'},
	{"Outbreak",'jps.myDebuffDuration("blood plague") < 2'},

	-- Multi target
	{"Blood Boil",'jps.MultiTarget and jps.IsSpellInRange("Blood Boil","target")'},
	{"Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.buff("Crimson Scourge")'},
	{"Blood Boil",'jps.buff("Crimson Scourge") and jps.IsSpellInRange("Blood Boil","target")'},

	-- Rotation
	{"Death Strike",'jps.hp() < 0.7'},
	{"Death Strike",'jps.buffDuration("Blood Shield") <= 4'},
	{"Soul Reaper",'jps.hp("target") <= 0.35'},
	{"Plague Strike",'not jps.mydebuff("Blood Plague")'},
	{"Icy Touch",'not jps.mydebuff("Frost Fever")'},
	{"Rune Strike",'jps.runicPower() >= 80 and not dk.rune("twoFr") and not dk.rune("twoUr")'},
	{"Death Strike", "onCD"},

	-- Death Siphon when we need a bit of healing. (talent based)
	{"Death Siphon",'jps.hp() < 0.6'}, -- moved here, because we heal often more with Death Strike than Death Siphon

	{"Heart Strike",'jps.mydebuff("Blood Plague") and jps.mydebuff("Frost Fever") and GetRuneType(1) ~= 4 and GetRuneType(2) ~= 4'},

	{"Rune Strike",'jps.runicPower() >= 30 and not jps.buff("lichborne")'}, -- stop casting Rune Strike if Lichborne is up

	{"Horn of Winter", "onCD"},
	{"Plague Leech",'dk.canCastPlagueLeech(3)'},
	{"Blood Tap", 'jps.buffStacks("Blood Charge") >= 5'},
	{"Empower Rune Weapon",'jps.UseCDs and IsSpellInRange("Rune Strike","target") == 1 and not dk.rune("oneDr") and not dk.rune("oneFr") and not dk.rune("oneUr") and jps.runicPower() < 30'},
}

dkBloodSpellTable[4] = {
	-- Blood presence
	{"Blood Presence",'not jps.buff("Blood Presence")'},

	-- Battle Rezz
	{ "Raise Ally",'UnitIsDeadOrGhost("focus") == 1 and jps.UseCds', "focus" },
	{ "Raise Ally",'UnitIsDeadOrGhost("target") == 1 and jps.UseCds', "target"},

	{"Anti-Magic Zone",'IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil '},

	-- Cntrol is pressed
	{"Army of the Dead",'IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'},

	-- Defensive cooldowns

	{"Death Pact",'jps.hp() < 0.5 and dk.hasGhoul()'},
	{"Lichborne",'jps.UseCDs and jps.hp() < 0.5 and jps.runicPower() >= 40 and jps.IsSpellKnown("Lichborne")'},
	{"Death Coil",'jps.hp() < 0.9 and jps.runicPower() >= 40 and jps.buff("lichborne")', "player"},
	{"Rune Tap",'jps.hp() < 0.8'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.70'},
	{"Icebound Fortitude",'jps.UseCDs and jps.hp() <= 0.3'},
	{"Vampiric Blood",'jps.UseCDs and jps.hp() < 0.4'},

	-- Interrupts
	{"mind freeze",'jps.shouldKick()'},
	{"mind freeze",'jps.shouldKick("focus")', "focus"},
	{"Strangulate",'jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze"'},
	{"Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "mouseover" },
	{"Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "focus" },
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"'},
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "mouseover"},
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "focus"},

	{"Raise Dead",'jps.UseCDs and not dk.hasGhoul()'},
	
	{"nested", 'IsSpellInRange("Rune Strike","target") == 1',{	
		-- Requires engineering
		{ jps.useSynapseSprings(),'jps.useSynapseSprings() ~= "" and jps.UseCDs'},
	
		-- Requires herbalism
		{"Lifeblood",'jps.UseCDs'},
	
		-- Racials
		{ jps.getDPSRacial(),'jps.UseCDs'},
	}},


	-- Buff
	{"Bone Shield",'not jps.buff("Bone Shield")'},

	-- Diseases
	{"Outbreak",'jps.myDebuffDuration("frost fever") < 2'},
	{"Outbreak",'jps.myDebuffDuration("blood plague") < 2'},

	-- Rotation
	{"Death Strike",'jps.hp() < 0.7'},
	{"Death Strike",'jps.buffDuration("Blood Shield") <= 4'},
	{"Soul Reaper",'jps.hp("target") <= 0.35'},
	{"Plague Strike",'not jps.mydebuff("Blood Plague")'},
	{"Icy Touch",'not jps.mydebuff("Frost Fever")'},
	{"Rune Strike",'jps.runicPower() >= 80 and not dk.rune("twoFr") and not dk.rune("twoUr")'},
	{"Death Strike", "onCD"},

	-- Death Siphon when we need a bit of healing. (talent based)
	{"Death Siphon",'jps.hp() < 0.6'}, -- moved here, because we heal often more with Death Strike than Death Siphon

	{"Rune Strike",'jps.runicPower() >= 30 and not jps.buff("lichborne")'}, -- stop casting Rune Strike if Lichborne is up

	{"Horn of Winter", "onCD"},
	{"Plague Leech",'dk.canCastPlagueLeech(3)'},
	{"Blood Tap", 'jps.buffStacks("Blood Charge") >= 5'},
	{"Empower Rune Weapon",'jps.UseCDs and IsSpellInRange("Rune Strike","target") == 1 and not dk.rune("oneDr") and not dk.rune("oneFr") and not dk.rune("oneUr") and jps.runicPower() < 30'},
}


dkBloodSpellTable[2] = {
	-- Blood presence
	{"Blood Presence",'not jps.buff("Blood Presence")'},

	{"Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'},
	{"Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.buff("Crimson Scourge")'},

	-- Battle Rezz
	{ "Raise Ally",'UnitIsDeadOrGhost("focus") == 1 and UnitPlayerControlled("focus") and jps.UseCds and IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil', "focus" },
	{ "Raise Ally",'UnitIsDeadOrGhost("target") == 1 and UnitPlayerControlled("mouseover") and jps.UseCds and IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil', "target"},

	-- Defensive cooldowns
	{"Death Pact",'jps.hp() < 0.5 and dk.hasGhoul()'},
	{"Lichborne",'jps.UseCDs and jps.hp() < 0.5 and jps.runicPower() >= 40 and jps.IsSpellKnown("Lichborne")'},
	{"Death Coil",'jps.hp() < 0.9 and jps.runicPower() >= 40 and jps.buff("lichborne")', "player"},
	{"Rune Tap",'jps.hp() < 0.8'},
	{"Icebound Fortitude",'jps.UseCDs and jps.hp() <= 0.4'},
	{"Vampiric Blood",'jps.UseCDs and jps.hp() < 0.55'},

	-- Interrupts
	{"mind freeze",'jps.shouldKick()'},
	{"mind freeze",'jps.shouldKick("focus")', "focus"},
	{"Strangulate",'jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze"'},
	{"Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "focus" },
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"'},
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "focus"},

	-- Aggro cooldowns
	{"Raise Dead",'jps.UseCDs and dk.hasGhoul() and jps.hp() < 0.6'},

	-- Requires engineering
	{ jps.useSynapseSprings() ,'jps.useSynapseSprings() ~= nil and jps.UseCDs'},

	-- Requires herbalism
	{"Lifeblood",'jps.UseCDs'},
	-- Racials
	{ jps.getDPSRacial(),'jps.UseCDs'},
	-- Buff
	{"Bone Shield",'not jps.buff("Bone Shield")'},
	-- Diseases
	{"Unholy Blight",'jps.myDebuffDuration("frost fever") < 2'},
	{"Unholy Blight",'jps.myDebuffDuration("blood plague") < 2'},
	{"Outbreak",'jps.myDebuffDuration("frost fever") < 2'},
	{"Outbreak",'jps.myDebuffDuration("blood plague") < 2'},

	{"Horn of Winter",'jps.runicPower() < 40 and jps.hp()> 0.90'},
	{"Blood Boil",'jps.buff("Crimson Scourge") and jps.IsSpellInRange("Blood Boil","target")'},

}

dkBloodSpellTable[3] = {
	-- Kicks
	{"mind freeze",'jps.shouldKick()'},
	{"mind freeze",'jps.shouldKick("focus")', "focus"},
	{"Strangulate",'jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze"'},
	{"Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "focus" },
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"'},
	{"Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "focus"},


	-- Buffs
	{"blood presence",'not jps.buff("blood presence")'},
	{"horn of winter",'onCD'},
	{"Outbreak",'jps.myDebuffDuration("frost fever") < 2'},
	{"Outbreak",'jps.myDebuffDuration("blood plague") < 2'},
	{"Unholy Blight",'jps.myDebuffDuration("frost fever") < 2'},
	{"Unholy Blight",'jps.myDebuffDuration("blood plague") < 2'},

	-- Diseases
	{"Plague Strike",'not jps.mydebuff("Blood Plague")'},
	{"Icy Touch",'not jps.mydebuff("Frost Fever")'},
}

jps.registerRotation("DEATHKNIGHT","BLOOD",function()
	local spell = nil
	local target = nil
	spell,target = parseStaticSpellTable(dkBloodSpellTable[1])
	if jps.canCast("Gorefiend's Grasp") and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil then
		jps.Macro("/target "..jpsName)
		jps.Cast("Gorefiend's Grasp")
		jps.Macro("/targetlasttarget")
	end
		
	return spell,target
end, "DK Blood Main")
jps.registerRotation("DEATHKNIGHT","BLOOD",function()
	local spell = nil
	local target = nil
	spell,target = parseStaticSpellTable(dkBloodSpellTable[4])
	return spell,target
end, "DK Blood No Cleave / AoE")

jps.registerRotation("DEATHKNIGHT","BLOOD",function()
	local spell = nil
	local target = nil
	spell,target = parseStaticSpellTable(dkBloodSpellTable[2])
	return spell,target
end, "DK Blood CDs+interrupts only")

jps.registerRotation("DEATHKNIGHT","BLOOD",function()
	local spell = nil
	local target = nil
	spell,target = parseStaticSpellTable(dkBloodSpellTable[3])
	return spell,target
end, "DK Diseases+interrupts only")