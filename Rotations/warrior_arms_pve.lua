--gig3m
jps.registerStaticTable("WARRIOR","ARMS",
{

	-- Interrupts
	{ "Pummel", ' jps.shouldKick() '},
	{ "Pummel", ' jps.shouldKick("focus")', "focus" },
	{ "Disrupting Shout", ' jps.shouldKick() '},
	{ "Disrupting Shout", ' jps.shouldKick("focus")', "focus" },

	-- Pots and Flasks
	{ jps.useBagItem("Flask of Winter's Bite"), 'jps.targetIsRaidBoss() and not jps.playerInLFR() and not jps.buff("Flask of Winter\'s Bite") '},
	{ jps.useBagItem("Potion of Mogu Power"), 'jps.targetIsRaidBoss() and not jps.playerInLFR() and jps.bloodlusting()'},

	-- Trinkets
	{ jps.useTrinket(0), 'jps.UseCDs' },
	{ jps.useTrinket(1), 'jps.UseCDs '},
	-- Engi
	{ jps.useSynapseSprings() , 'jps.useSynapseSprings() ~= "" and jps.UseCDs '},

	-- Herb
	{ "Lifeblood", 'jps.UseCDs '},
	-- Racial
	{ jps.DPSRacial, 'jps.UseCDs '},

	{ "Heroic Throw", 'IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil', "target" },
	-- Multi target
	{ "Thunder Clap", 'jps.MultiTarget and jps.myDebuff("Deep Wounds")'},
	{ "Sweeping Strikes", ' jps.MultiTarget and jps.rage() >= 30'},
	{ "Whirlwind", 'jps.MultiTarget and IsShiftKeyDown() ~= nil and jps.rage() >= 30'},
	{ "Dragon Roar", 'jps.MultiTarget and IsShiftKeyDown() ~= nil'},
	{ "Bladestorm", ' jps.MultiTarget and IsShiftKeyDown() ~= nil'},

	-- Cooldowns
	{ "Bloodbath", 'jps.UseCDs '},
	{ "Avatar", 'jps.UseCDs '},
	{ "Skull Banner", ' jps.UseCDs '},
	{ "Recklessness", ' jps.UseCDs '},
	{ "Berserker Rage", ' jps.UseCDs '},


	-- pop a heal when solo
	{ "Impending Victory", ' jps.hp() <= 0.7 and GetNumSubgroupMembers() == 0', "target" },

	{ "Colossus Smash", ' jps.buff("Sudden Death") ', "target" }, -- Sudden Death procs
	{ "Execute", "onCD", "target" }, -- only available less than 20% health, no need to check
	{ "Mortal Strike", "onCD", "target" },
	{ "Colossus Smash", "onCD", "target" },
	{ "Heroic Strike", 'jps.rage() >= 70' },
	{ "Overpower", 'jps.buff("Taste for Blood")', "target"},
	{ "Slam", ' jps.rage() >= 40 '},
	{ "Battle Shout", ' jps.rage() <= 70' , "player" },
}
, "5.3 Arms PVE")