dkFrost = {}

--[[[
@rotation Frost 2h PVE 5.4
@class death knight
@spec Frost
@talents d!210011
@author PCMD
@description
This is a Raid-Rotation based on Simcraft results. While Bloodlusting it uses a potion of Mogu Power inside raids and a flask if you got one inside your bags.<br>
It switches automatically to Frost presence. Unit's in focus or target are automatically battle-rezzed
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Casts Death and Decay[br]
[*] [code]ALT[/code]:Places your Anti-Magic Zone[br]
[*] [code]jps.Interrupts[/code]: Casts from target, focus will be interrupted br]
[*] [code]jps.Defensive[/code]: uses Death Pact, Death Siphon(if skilled) and Death Strike(be careful this could reduce your dps)[br]
]]--

-- Talents:
-- Tier 1: Plague Leech or Unholy Blight
-- Tier 2: Anti-Magic Zone ( lichborne is a small dps loss , purgatory risky because of the debuff )
-- Tier 3: Death's Advance / for kiting chillbains / asphyxiate for another kick / cc
-- Tier 4: Death Pact
-- Tier 5: for 2h Runic Empowerment (others will also work , but Runic Empowerment provides us better burst)
-- Tier 6: Remorseless Winter or Desecrated Ground if you need some stun/cc remove
-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell

-- Usage info:
-- left shift for death and decay

-- Cooldowns: trinkets, raise dead, synapse springs, lifeblood, pillar of frost, racials

------------------------
-- SPELL TABLE ---------
------------------------


jps.registerStaticTable("DEATHKNIGHT","FROST",{
	{"Frost Presence",'not jps.buff("Frost Presence", "player")'},
	{"Horn of Winter",'not jps.buff("Horn of Winter", "player")'},

	--AOE
	{ "Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'},
	{"Anti-Magic Zone",'IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil '},

	-- Battle Rezz
	{ "Raise Ally",'UnitIsDeadOrGhost("focus") == 1 and UnitPlayerControlled("focus") and jps.UseCds', "focus" },
	{ "Raise Ally",'UnitIsDeadOrGhost("target") == 1 and UnitPlayerControlled("target") and jps.UseCds', "target"},

	-- Self heal
	{ "Death Pact",'jps.Defensive and jps.hp() < 0.4 and UnitExists("pet") ~= nil'},
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
	{ jps.useTrinket(0),'jps.useTrinket(0) ~= nil and jps.UseCDs'},
	{ jps.useTrinket(1),'jps.useTrinket(1) ~= nil and jps.UseCDs'},
	-- Requires engineerins
	{ jps.useSynapseSprings,'jps.useSynapseSprings() ~= "" and jps.UseCDs'},
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
	{ "blood tap",'jps.buffStacks("Blood Charge") >= 5 and jps.hp("target") <= 0.35 and jps.cooldown("soul reaper") == 0'},
	{ "howling blast",'jps.buff("Freezing Fog") or jps.MultiTarget'},
	{ "obliterate",'jps.buff("killing machine")'},
	{ "blood tap",'jps.buffStacks("Blood Charge") >= 5 and jps.buff("killing machine")'},
	{ "blood tap",'jps.buffStacks("blood charge") >10 and jps.runicPower() > 76'},
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
}, "PVE 2H Simcraft")


--[[[
@rotation Frost DW PVE 5.4
@class death knight
@spec Frost
@talents d!210011
@author PCMD
@description
This is a Raid-Rotation based on testing. While Bloodlusting it uses a potion of Mogu Power inside raids and a flask if you got one inside your bags.<br>
It switches automatically to Frost presence. Unit's in focus or target are automatically battle-rezzed
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Casts Death and Decay[br]
[*] [code]ALT[/code]:Places your Anti-Magic Zone[br]
[*] [code]jps.Interrupts[/code]: Casts from target, focus will be interrupted br]
[*] [code]jps.Defensive[/code]: uses Death Pact, Death Siphon(if skilled) and Death Strike(be careful this could reduce your dps)[br]
]]--

-- Talents:
-- Tier 1: Plague Leech or Unholy Blight
-- Tier 2: Anti-Magic Zone ( lichborne is a small dps loss , purgatory risky because of the debuff )
-- Tier 3: Death's Advance / for kiting chillbains / asphyxiate for another kick / cc
-- Tier 4: Death Pact
-- Tier 5: blood tap for DW
-- Tier 6: Remorseless Winter or Desecrated Ground if you need some stun/cc remove
-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell

-- Usage info:
-- left shift for death and decay

-- Cooldowns: trinkets, raise dead, synapse springs, lifeblood, pillar of frost, racials

------------------------
-- SPELL TABLE ---------
------------------------


jps.registerStaticTable("DEATHKNIGHT","FROST",{
	{"Frost Presence",'not jps.buff("Frost Presence", "player")'},
	{"Horn of Winter",'not jps.buff("Horn of Winter", "player")'},

	--AOE
	{ "Death and Decay",'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'},
	{"Anti-Magic Zone",'IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil '},

	-- Battle Rezz
	{ "Raise Ally",'UnitIsDeadOrGhost("focus") == 1 and UnitPlayerControlled("focus") and jps.UseCds', "focus" },
	{ "Raise Ally",'UnitIsDeadOrGhost("target") == 1 and UnitPlayerControlled("target") and jps.UseCds', "target"},

	-- Self heal
	{ "Death Pact",'jps.Defensive and jps.hp() < 0.4 and UnitExists("pet") ~= nil'},
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
	{ jps.useTrinket(0),'jps.useTrinket(0) ~= nil and jps.UseCDs'},
	{ jps.useTrinket(1),'jps.useTrinket(1) ~= nil and jps.UseCDs'},
	-- Requires engineerins
	{ jps.useSynapseSprings,'jps.useSynapseSprings() ~= "" and jps.UseCDs'},
	-- Requires herbalism
	{ "Lifeblood",'jps.UseCDs'},

	--TESTING
	{ "plague leech",'dk.canCastPlagueLeech(2)'},
	{ "outbreak",'jps.myDebuffDuration("Blood Plague") == 0'},
	{ "outbreak",'jps.myDebuffDuration("Frost Fever") == 0'},
	{ "unholy blight",'jps.myDebuffDuration("Blood Plague") == 0'},
	{ "unholy blight",'jps.myDebuffDuration("Frost Fever") == 0'},
	{ "howling blast",'jps.myDebuffDuration("Frost Fever") == 0'},
	{ "plague strike",'jps.myDebuffDuration("Blood Plague") == 0'},
	{ "soul reaper",'jps.hp("target") <= 0.35'},
	{ "blood tap",'jps.buffStacks("Blood Charge") >= 5 and jps.hp("target") <= 0.35 and jps.cooldown("soul reaper") == 0'},
	{ "howling blast",'jps.buff("Freezing Fog") or jps.MultiTarget'},
	{ "frost strike",'jps.buff("killing machine")'},
	{ "frost strike",'jps.runicPower() > 88'},
	{ "blood tap",'jps.buffStacks("Blood Charge") >= 5 and jps.runicPower() > 20 and jps.buff("killing machine")'},
	{ "blood tap",'jps.buffStacks("blood charge") >10 and jps.runicPower() > 76'},
	{ "howling blast",'dk.rune("twoUr")'},
	{ "howling blast",'dk.rune("twoFr")'},
	{ "frost strike",'jps.runicPower() > 76'},
	{ "obliterate",'dk.rune("oneUr") and not jps.buff("killing machine")'},
	{ "Howling Blast",'onCD'},
	{ "plague leech",'dk.canCastPlagueLeech(3)'},
	{ "outbreak",'jps.myDebuffDuration("Blood Plague") <3'},
	{ "outbreak",'jps.myDebuffDuration("Frost Fever") <3'},
	{ "unholy blight",'jps.myDebuffDuration("Frost Fever") < 3'},
	{ "unholy blight",'jps.myDebuffDuration("Blood Plague") < 3'},
	{ "frost strike",'jps.buffStacks("blood charge")>=8'},
	{ "horn of winter"},
	{ "frost strike",'not jps.buff("runic corruption") and jps.IsSpellKnown("runic corruption")'},
	{ "frost strike",'"onCD"'},
	{ "empower rune weapon",'jps.buff("Potion of Mogu Power") and not dk.rune("twoDr") and not dk.rune("twoUr") and not dk.rune("twoFr") and jps.runicPower() < 60 and jps.UseCDs'},
	{ "empower rune weapon",'jps.bloodlusting() and not dk.rune("twoDr") and not dk.rune("twoUr") and not dk.rune("twoFr") and jps.runicPower() < 60 and jps.UseCDs'},
	{ "blood tap",'jps.buffStacks("blood charge")>10 and jps.runicPower()>=20'},
	{ "obliterate",'"onCD"'},
	{ "plague leech",'dk.canCastPlagueLeech(2)'},
	{ "empower rune weapon",'jps.targetIsRaidBoss() and jps.combatTime() < 35'}, -- so it will be ready at the end of most Raid fights
}, "PVE DW")


--[[[
@rotation Frost PVP 5.3
@class death knight
@spec Frost
@talents d!210011
@author PCMD
@description
This is a small PVP Rotation without big changes to the normal but it allows you to choose the presence and it casts Necrotic Strike.
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Casts Death and Decay[br]
]]--
jps.registerStaticTable("DEATHKNIGHT","FROST",{
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


	-- Requires engineerins
	{ jps.useSynapseSprings,'jps.useSynapseSprings() ~= "" and jps.UseCDs'},

	-- Requires herbalism
	{ "Lifeblood",'jps.UseCDs'},

	-- Diseases
	{ "Necrotic Strike",'not jps.mydebuff("Necrotic Strike",target)'},
	{ "Howling Blast",'jps.myDebuffDuration("Frost Fever") <= 1'},
	{ "Howling Blast",'jps.buff("Freezing Fog") and jps.runicPower() < 88'},
	{ "Plague Strike",'jps.myDebuffDuration("Blood Plague") <= 1'},

	-- Self heals
	{ "Death Siphon",'jps.hp() < 0.8 and jps.Defensive'},
	{ "Death Strike",'jps.hp() < 0.7 and jps.Defensive'},

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

}, "PVP 2h", false, true)
--[[[
@rotation Diseases & Interrupt Rotation 5.3
@class death knight
@spec Frost
@talents d!210011
@author PCMD
@description
This Rotation only spread's your diseases & interrupt units. The rest you have to do on your own.
<br> [i]Attention:[/i] [code]jps.Interrupts[/code] still has to be active!
]]--
jps.registerStaticTable("DEATHKNIGHT","FROST",{
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
}, "Kick Buff Debuff")
