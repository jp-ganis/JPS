-- supported raids & encounters (only spell Ids for jps.raid.getTimer() !!! )

jps.raid.supportedEncounters = {
	["Throne of Thunder"]= {
		["Jin'rokh the Breaker"]=
			{
				{"Focused Lightning", "runspeed" , 'jps.debuff("Focused Lightning","player") '}, 
				{"Lightning Storm", "magicShortCD", 'jps.raid.getTimer(137313) < 0.5 and jps.hp() < 0.85 and jps.isTank == false '},
				{"Ionization", "dispelMagic", 'jps.raid.getTimer(138732) < 1 and jps.isTank == false and jps.hp("player","abs") > 480000 '}, --- no ionization @ HC on tanks!
				{"Static Burst", "dispelMagic",'jps.raid.getTimer(137162) < 2 and jps.isTank == true and jps.unitGotAggro() '}, --- we can prevent every 2nd static burst with ams
				{"Lightning Storm", "runspeed",' jps.raid.getTimer(137313) < 1 and jps.debuff("Fluidity", "player") '}
			},
		["Horridon"] = 
			{
			},
		["Council Of Elders"]= {},
		["Tortos"] = {},
		["Megaera"] = {},
		["Ji-Kun"] =
			{
				{"Quills", "magicShortCD" ,' jps.raid.getTimer("Quills") < 1 '}, 
				{"Quills", "magicShortCD" ,' jps.IsCastingSpell("Quills","target")'},
				{"Talor Rake", "physicalHighCD", 'jps.debuffStacks("Talor Rake") >= 2 and jps.unitGotAggro() and jps.glyphInfo(43536)'},
				{"Downdraft", "runspeed" ,' jps.debuff("Downdraft") '}, 
			},
		["Durumu The Forgotten"] = {}
	},
	
	-- just for testing
	["Kalimdor"] = {
		["Raider's Training Dummy"] = {
			{"Demo", "magicShortCD", 'onCD'}, --casts an magic deff ability on cd @ raiders training dummy
		}
	},
	["Mogu'shan Palace"] = {
		["Haiyan the Unstoppable"] = {
			{"Meteor", "runspeed", 'jps.raid.getTimer(120195) < 5'},
			{"Conflagrate", "runspeed", 'jps.raid.getTimer(120201) < 5'},
		},
		["Kuai the Brute"] = {
			{"Shockwave", "runspeed", 'jps.raid.getTimer(119922) < 2'}
		},
		["Ming the Cunning"] = {
			{"Whirling Dervish CD", "runspeed", 'jps.raid.getTimer(119981) < 2'}
		}
	},
}

-- spell names lowercase (important)! 
jps.raid.supportedAbilities = {
	["Death Knight"] = {
		["Blood"] =
		{
			["anti-magic shell"] = {{spellType="magicShortCD", spellAction="absorb"},{spellType="dispelMagic", spellAction="dispel"}},
			["death's advance"] = {{spellType="runspeed"}},
		},
		["Frost"] =
		{
			["anti-magic shell"] = {{spellType="magicShortCD", spellAction="absorb"},{spellType="dispelMagic", spellAction="dispel"}},
			["death's advance"] = {{spellType="runspeed"}},
		},
		["Unholy"] = 
		{
			["anti-magic shell"] = {{spellType="magicShortCD", spellAction="absorb"},{spellType="dispelMagic", spellAction="dispel"}},
			["death's advance"] = {{spellType="runspeed"}},
		}
	}
	,
	["Paladin"] = {
		["Holy"] = 
		{
			["speed of light"] = {{spellType="runspeed"}},
		}
	}
}