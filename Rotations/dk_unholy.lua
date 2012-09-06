-- tropic (original by jpganis)
-- Ty to SIMCRAFT for this rotation
function dk_unholy(self)
	-- INFO --
	-- Shift-key to cast Death and Decay
	-- Ctrl-key to heal ghoul pet with death coil
	-- Alt-key + mouseover to combat ress another player (Raise Ally) - You can mouseover the 
	--   player corpse or player frame in the party/raid frame
	-- Set "focus" for dark simulacrum (duplicate spell) (this is optional, default is current target)
	-- Automatically raise ghoul if dead

	local rp = UnitPower("player") 

	local ffDuration = jps.debuffDuration("frost fever")
	local bpDuration = jps.debuffDuration("blood plague")
	local siStacks = jps.buffStacks("shadow infusion","pet")
	local superPet = jps.buff("dark transformation","pet")

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

	-- Dark Simulacrum in raids and dungeons (+ misc. mainly PvP)
	-- Hagara 			- Dragon Soul: 			Shattered Ice
	-- Ragnaros			- Firelands:			Hand of Ragnaros
	-- Ivoroc 			- Blackwing Descent:	Shadowflame, Curse of Mending
	-- Echo of Jaina 	- End Time: 			Pyroblast
	-- ??				- Throne of the Tides:	Chain lightning
	-- Zanzil 			- Zul'Gurub: 			Zanzili Fire

	local spellBeingCastByTarget = nil
	local castDarkSim = false
	local DarkSimTarget = "target"
	if UnitExists("focus") and UnitIsEnemy("focus","player") then
		spellBeingCastByTarget = select(1,UnitCastingInfo("focus"))
		DarkSimTarget = "focus"
	else
		spellBeingCastByTarget = select(1,UnitCastingInfo("target"))
		DarkSimTarget = "target"		
	end
	
	-- Spells have to be written exactly how they are spelled, case sensitive
	if spellBeingCastByTarget == "Shattered Ice" or spellBeingCastByTarget == "Hand of Ragnaros" or spellBeingCastByTarget == "Shadowflame" or spellBeingCastByTarget == "Curse of Mending" or spellBeingCastByTarget == "Pyroblast" or spellBeingCastByTarget == "Chain Lightning" or spellBeingCastByTarget == "Zanzili Fire" or spellBeingCastByTarget == "Polymorph" or spellBeingCastByTarget == "Hex" or spellBeingCastByTarget == "Mind Control" or spellBeingCastByTarget == "Cyclone" then
		castDarkSim = true
	end	
	
	local spellTable =
	{
		{ "death and decay",		IsShiftKeyDown() ~= nil },
		{ "unholy frenzy" },
		{ "outbreak",				ffDuration < 3 or bpDuration < 3 },
		{ "soul reaper",			jps.hp("target") <= 0.35 },
		{ "unholy blight",			ffDuration < 3 or bpDuration < 3 },
		{ "icy touch",				ffDuration <= 0 },
		{ "plague strike",			bpDuration <= 0 },
		{ "plague leech",			jps.cd("outbreak") < 1 },
		{ "summon gargoyle" },
		{ "dark transformation" },
		{ "empower rune weapon" },
		{ "scourge strike",			two_ur and rp < 90 },
		{ "festering strike",		two_dr and two_fr and rp < 90 },
		{ "death coil",				rp > 90 },
		{ "death coil",				jps.buff("sudden doom") },
		{ "blood tap" },
		{ "scourge strike" },
		{ "festering strike" },
		{ "death coil", 			jps.cd("summon gargoyle") > 8 },
		{ "horn of winter" },
		{ "empower rune weapon" },
	}

	local spell = parseSpellTable( spellTable ) 
	
	if spell == "death and decay" then jps.groundClick() end
	
	return spell

end
