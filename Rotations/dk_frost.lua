-- Talents:
-- Tier 1: Plague Leech or Unholy Blight
-- Tier 2: Anti-Magic Zone ( lichborne is a small dps loss , purgatory risky because of the debuff ) 
-- Tier 3: Death's Advance / for kiting chillbains / asphyxiate for another kick / cc
-- Tier 4: Death Pact 
-- Tier 5: for 2h Runic Empowerment (others will also work , but Runic Empowerment provides us better burst) , blood tap for DW 
-- Tier 6: Remorseless Winter or Desecrated Ground if you need some stun/cc remove
-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell

-- Usage info:
-- left alt for battle rezz at your focus or (if focus is not death , or no focus or focus target out of range) mouseover	

-- Cooldowns: trinkets, raise dead, synapse springs, lifeblood, pillar of frost, racials

------------------------
-- SPELL TABLE ---------
------------------------
		
dkFrost = {}
dkFrost.spellTable = {}
dkFrost.spellTable[1] =
{	
	["ToolTip"] = "PVE 2H Simcraft",
	{"Frost Presence",'not jps.buff("Frost Presence", "player")'},
	{"Horn of Winter",'not jps.buff("Horn of Winter", "player")'},
	
	--AOE
	{ "Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget and IsLeftAltKeyDown == nil'},
	
	-- Battle Rezz
	{ "Raise Ally",'UnitIsDeadOrGhost("focus") == 1 and UnitPlayerControlled("focus") and jps.UseCds and IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil', "focus" },
	{ "Raise Ally",'UnitIsDeadOrGhost("mouseover") == 1 and UnitPlayerControlled("mouseover") and jps.UseCds and IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil', "mouseover"},
	
	-- Self heal
	{ "Death Pact",'jps.UseCDs and jps.hp() < 0.6 and UnitExists("pet") ~= nil'},
	-- Self heals
	{ "Death Siphon",'jps.Defensive and jps.hp() < 0.8'},
	{ "Death Strike",'jps.Defensive and jps.hp() < 0.7'},
	
	-- Interrupts
	{ "mind freeze",'jps.shouldKick()'},
	{ "mind freeze",'jps.shouldKick("focus")', "focus" },
	{ "Strangulate",'jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze"'},
	{ "Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "focus"},
	{ "Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"'},
	{ "Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "focus"},
	
	--CDs + Buffs
	{ "Pillar of Frost",'jps.UseCDs'},
	{ jps.useBagItem("Flask of Winter's Bite"),'jps.targetIsRaidBoss() and not jps.playerInLFR() and not jps.buff("Flask of Winter\'s Bite")'},
	{ jps.useBagItem("Potion of Mogu Power"),'jps.targetIsRaidBoss() and not jps.playerInLFR() and jps.bloodlusting()'}, 
	
	{ jps.getDPSRacial(),'jps.UseCDs'},
	
	{ "Raise Dead",'jps.UseCDs and UnitExists("pet") == nil'},
	-- On-use Trinkets.
	{ jps.useTrinket(0),'jps.UseCDs'},
	{ jps.useTrinket(1),'jps.UseCDs'},
	-- Requires engineerins
	{ jps.useSynapseSprings(),'jps.UseCDs'},
	-- Requires herbalism
	{ "Lifeblood",'jps.UseCDs'},
	
	--simcraft 5.3 T14
	{ "plague leech",'dk.canCastPlagueLeech(2)'},
	{ "outbreak",'jps.myDebuffDuration("Blood Plague") == 0'},
	{ "outbreak",'jps.myDebuffDuration("Frost Fever") == 0'},
	{ "unholy blight",'jps.myDebuffDuration("Blood Plague") == 0'},
	{ "unholy blight",'jps.myDebuffDuration("Frost Fever") == 0'},
	{ "howling blast",'jps.myDebuffDuration("Frost Fever") == 0'},
	{ "plague strike",'jps.myDebuffDuration("Blood Plague") == 0'},
	{ "soul reaper",'jps.hp("target") <= 0.35'},
	{ "blood tap",'jps.hp("target") <= 0.35 and jps.cooldown("soul reaper") == 0'},
	{ "howling blast",'jps.buff("Freezing Fog")'},
	{ "obliterate",'jps.buff("killing machine")'},
	{ "blood tap",'jps.buff("killing machine")'},
	{ "blood tap",'jps.buffStacks("blood charge")>10 and jps.runicPower() > 76'},
	{ "frost strike",'jps.runicPower() > 76'},
	{ "obliterate",'dk.rune("twoDr")'},
	{ "obliterate",'dk.rune("twoFr")'},
	{ "obliterate",'dk.rune("twoUr")'},
	{ "plague leech",'dk.canCastPlagueLeech(3)'},
	{ "outbreak",'jps.myDebuffDuration("Blood Plague") <3'},
	{ "outbreak",'jps.myDebuffDuration("Frost Fever") <3'},
	
	{ "unholy blight",'jps.myDebuffDuration("Frost Fever") < 3'},
	{ "unholy blight",'jps.myDebuffDuration("Blood Plague") < 3'},
	{ "frost strike",'not dk.rune("oneFr")'},
	{ "frost strike",'jps.buffStacks("blood charge")<=10'},
	{ "horn of winter"},
	{ "frost strike",'not jps.buff("runic corruption") and jps.IsSpellKnown("runic corruption")'},
	{ "obliterate",'"onCD"'},
	{ "empower rune weapon",'jps.buff("Potion of Mogu Power") and not dk.rune("twoDr") and not dk.rune("twoUr") and not dk.rune("twoFr") and jps.runicPower() < 60 and jps.UseCDs'},
	{ "empower rune weapon",'jps.bloodlusting() and not dk.rune("twoDr") and not dk.rune("twoUr") and not dk.rune("twoFr") and jps.runicPower() < 60 and jps.UseCDs'},
	{ "blood tap",'jps.buffStacks("blood charge")>10 and jps.runicPower()>=20'},
	{ "frost strike",'"onCD"'},
	{ "plague leech",'dk.canCastPlagueLeech(2)'},
	{ "empower rune weapon",'jps.targetIsRaidBoss() and jps.combatTime() < 35'}, -- so it will be ready at the end of most Raid fights
}
	
dkFrost.spellTable[2] =
{
	["ToolTip"] = "PVP 2h",

	{ "Horn of Winter",'not jps.buff("Horn of Winter")'},
	{ "Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget'},
			
	-- Self heal
	{ "Death Pact",'jps.UseCDs and jps.hp() < 0.6 and UnitExists("pet") ~= nil'},
	
	-- Rune Management
	{ "Plague Leech",'dk.canCastPlagueLeech(3)'}, 
	
	{ "Pillar of Frost",'jps.UseCDs'},
	{ jps.getDPSRacial(),'jps.UseCDs'},
	
	{ "Raise Dead",'jps.UseCDs and UnitExists("pet") == nil'},
	
		-- If our diseases are about to fall off.
 	{ "outbreak",'jps.myDebuffDuration("Blood Plague") <3'},
 	{ "outbreak",'jps.myDebuffDuration("Frost Fever") <3'},
	{ "Soul Reaper",'jps.hp("target") < 0.35'},
	
	-- Kick
	{ "mind freeze",'jps.shouldKick()'},
	{ "mind freeze",'jps.shouldKick("focus")', "focus"},
	{ "Strangulate",'jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze"'},
	{ "Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "focus"},
	{ "Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"'},
	{ "Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "focus"},
		
		-- Unholy Blight when our diseases are about to fall off. (talent based)
 	{ "unholy blight",'jps.myDebuffDuration("Frost Fever") < 3'},
 	{ "unholy blight",'jps.myDebuffDuration("Blood Plague") < 3'},		
	-- On-use Trinkets.
	{ jps.useTrinket(0),'jps.UseCDs'},
	{ jps.useTrinket(1),'jps.UseCDs'},
	
	-- Requires engineerins
	{ jps.useSynapseSprings(),'jps.UseCDs'},
	
	-- Requires herbalism
	{ "Lifeblood",'jps.UseCDs'},
	
	-- Diseases
	{ "Necrotic Strike",'not jps.mydebuff("Necrotic Strike",target)'},
	{ "Howling Blast",'jps.myDebuffDuration("Frost Fever") <= 1'},
	{ "Howling Blast",'jps.buff("Freezing Fog") and jps.runicPower() < 88'},
	{ "Plague Strike",'jps.myDebuffDuration("Blood Plague") <= 1'},
	
	-- Self heals
	{ "Death Siphon",'jps.hp() < 0.8'},
	{ "Death Strike",'jps.hp() < 0.7'},
	
	-- Dual wield specific. Disabling for now.
	-- Frost Strike when we have a Killing Machine proc.
	-- { "Frost Strike",'jps.buff("Killing Machin	e")'},
	{ "Obliterate",'jps.runicPower() <= 76'},
	{ "Obliterate",'jps.buff("Killing Machine")'},
	{ "Obliterate",'jps.bloodlusting()'},
	-- Filler.
	{ "Horn of Winter",'jps.runicPower() < 20'},
	
	{ "Frost Strike",'jps.runicPower() >= 76'}, 
	{ "Frost Strike",'jps.bloodlusting()'}, 
	{ "Frost Strike",'not dk.rune("oneFr")'}, 
	
	{ "Frost Strike",'not jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1'},
	{ "Frost Strike",'jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1'},
	{ "Obliterate"},
	{ "Frost Strike"},
	{ "Plague Leech",'dk.canCastPlagueLeech(2)'},
	{ "Empower Rune Weapon",'jps.UseCDs and jps.runicPower() <= 25 and not dk.rune("twoDr") and not dk.rune("twoFr") and not dk.rune("twoUr")'},
	{ "Empower Rune Weapon",'jps.UseCDs and jps.TimeToDie("target") < 60 and jps.buff("Potion of Mogu Power")'},
	{ "Empower Rune Weapon",'jps.UseCDs and jps.bloodlusting()'},
				
}
	
dkFrost.spellTable[3] =
{
	["ToolTip"] = "Kick Buff Debuff",
	
	-- Kicks
	{ "mind freeze",'jps.shouldKick()'},
	{ "mind freeze",'jps.shouldKick("focus")', "focus"},
	{ "Strangulate",'jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze"'},
	{ "Strangulate",'jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze"', "focus"},
	{ "Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"'},
	{ "Asphyxiate",'jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate"', "focus"},
	-- Buffs
	{ "frost presence",'not jps.buff("frost presence")'},
	{ "horn of winter",'"onCD"'},
	{ "Outbreak",'jps.myDebuffDuration("Frost Fever") < 3'},
	{ "Outbreak",'jps.myDebuffDuration("Blood Plague") < 3'},
	{ "Unholy Blight",'jps.myDebuffDuration("Frost Fever") < 3'},
	{ "Unholy Blight",'jps.myDebuffDuration("Blood Plague") < 3'},
	{ "Howling Blast",'jps.myDebuffDuration("Frost Fever") <= 1'},
	{ "Howling Blast",'jps.buff("Freezing Fog") and jps.runicPower() < 88'},
	{ "Plague Strike",'jps.myDebuffDuration("Blood Plague") <= 1'},
}

function dk_frost()
	return parseStaticSpellTable(jps.RotationActive(dkFrost.spellTable))
end