
-- SwollNMember
-- A rudimentary WoD arms warrior rotation based on Icy Veins guidelines
-- Talents: Double Time, Impending Victory, Taste for Blood, Storm Bolt
-- Glyphs: Unending Rage, Bull Rush, Sweeping Strikes, Subtle Defender

jps.registerStaticTable("WARRIOR","ARMS", {
-- Interrupts
{"nested","jps.Interrupts",{
	{"spell reflection", 'UnitThreatSituation("player","target") == 3 and (UnitCastingInfo("target") or UnitChannelInfo("target"))'},
	{"pummel", 'not jps.targetIsRaidBoss() and jps.shouldKick()'},
}},

-- Damage Mitigation
{"nested",'jps.Defensive',{
	{"lifeblood", 'jps.hp("player") < 0.95'},
	{"impending victory", 'jps.hp("player") <= 0.85'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.30'}, -- Healthstone
	{"die by the sword", 'UnitThreatSituation("player","target") == 3 and IsSpellInRange("execute","target") == 1 and jps.hp("player") < 0.30 and jps.UseCDs'},
	{"shield barrier", 'jps.hp() < 0.30 and jps.UseCDs'},
	{"defensive stance", 'not jps.buff("defensive stance") and jps.hp() < 0.20'},
}},

{"battle stance", 'not jps.buff("battle stance") and jps.hp() > 0.20'},

{"battle shout", 'jps.raidIsBuffed("Battle Shout") == false '},

{"nested",'IsSpellInRange("execute","target") == 1 and jps.UseCDs', {
	{jps.useTrinket(0), 'jps.UseCDs'},
	{jps.useTrinket(1),   'jps.UseCDs'},
	{jps.DPSRacial},
	{"bloodbath"},
	{"recklessness"},
}},


-- MULTI-TARGET
{"nested","jps.MultiTarget",{
	{"sweeping strikes",'not jps.myDebuff("sweeping strikes")'},
	{"rend", 'jps.myDebuffDuration("rend") <= 4'},
	{"Dragon Roar"},
	{"whirlwind"},
}},

-- SINGLE TARGET
{"rend", 'not jps.debuff("rend")'},
{"mortal strike", 'jps.rage() > 60'},
{"colossus smash", 'not jps.debuff("colossus smash") and jps.rage() >= 60'},

-- Rotation > 20% Health
-- Without Colossus Smash
{"nested",' not jps.debuff("colossus smash") and jps.hp("target") > 0.20', {
	{"rend", 'jps.myDebuffDuration("rend") <= 4'},
	{"whirlwind", 'jps.rage() > 40'},
	{"mortal strike"},
	{"colossus smash"},
	{"storm bolt"},
	{"Dragon Roar"},
}},

-- With Colossus Smash
{"nested",' jps.debuff("colossus smash") and jps.hp("target") > 0.20', {
	{"mortal strike"},
	{"storm bolt", 'jps.rage() > 70'},
	{"whirlwind"},
}},
-- Execute Phase < 20% Health
{"nested",'jps.hp("target") <= 0.20 and not jps.debuff("colossus smash")', {
	{"rend", 'jps.myDebuffDuration("rend") <= 4'},
	{"execute", 'jps.rage() > 60'},
	{"colossus smash"},
	{"storm bolt"},
	{"Dragon Roar"},
}},

-- With Colossus Smash
{"nested",'jps.hp("target") <= 0.20 and jps.debuff("colossus smash")', {
	{"storm bolt", 'jps.rage() < 70'},
	{"execute"},
}},

} , "6.0.2 Arms PVE 90")
