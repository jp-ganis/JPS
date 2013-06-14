-- tropic (original by jpganis)
-- Ty to SIMCRAFT for this rotation
function dk_unholy()

	-- Shift-key to cast Death and Decay
	-- shift + left alt for battle rezz at your focus or (if focus is not death , or no focus or focus target out of range) mouseover
	-- Set "focus" for dark simulacrum (duplicate spell) (this is optional, default is current target)
	-- Automatically raise ghoul if dead
	
	local spell = nil
	local target = nil

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
	local oneDr = dr1 or dr2
	local twoDr = dr1 and dr2
	local oneFr = fr1 or fr2
	local twoFr = fr1 and fr2
	local oneUr = ur1 or ur2
	local twoUr = ur1 and ur2
	local timeToDie = jps.TimeToDie("target")

	-- Dark Simulacrum in raids and dungeons (+ misc. mainly PvP)
	-- Hagara 			- Dragon Soul: 			Shattered Ice
	-- Ragnaros			- Firelands:			Hand of Ragnaros
	-- Ivoroc 			- Blackwing Descent:	Shadowflame, Curse of Mending
	-- Echo of Jaina 	- End Time: 			Pyroblast
	-- ??				- Throne of the Tides:	Chain lightning
	-- Zanzil 			- Zul'Gurub: 			Zanzili Fire

	local spellBeingCastByTarget = nil
	local castDarkSim = false
	-- [[ need update for MoP 
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

	
	local spellTable =
	{
	   -- Kick
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "Strangulate",		jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",		jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },
		
		-- Self heals
		{ "Death Siphon", jps.hp() < .8 },
		{ "Death Strike", jps.hp() < .7 },
		{ "Death Pact", jps.UseCDs and jps.hp() < .6 and UnitExists("pet") ~= nil },
		
		-- Battle Rezz
    	{ "Raise Ally",		UnitIsDeadOrGhost("focus") == 1 and jps.UseCds and IsShiftKeyDown() ~= nil and IsLeftAltKeyDown()  ~= nil and GetCurrentKeyBoardFocus() == nil  , "focus" },
    	{ "Raise Ally",		UnitIsDeadOrGhost("mouseover") == 1 and jps.UseCds and IsShiftKeyDown()  ~= nil  and IsLeftAltKeyDown()  ~= nil  and GetCurrentKeyBoardFocus() == nil , "mouseover" },

		-- AOE
		{ "Death and Decay", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget },
		
		-- spell steal
		
		{"Dark Simulacrum ", castDarkSim == true , DarkSimTarget},
		
		-- CDs
		{ "unholy frenzy" },
		{ jps.DPSRacial, jps.UseCDs },
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood", jps.UseCDs },
		
		-- rezz pet
		{ "Raise Dead", jps.UseCDs and UnitExists("pet") == nil },
		
		-- DOT CDs
		{ "outbreak",				ffDuration < 3 or bpDuration < 3 },
		{ "unholy blight",			ffDuration < 3 or bpDuration < 3 },
		
		-- Execute
		{ "soul reaper",			jps.hp("target") <= 0.35 },
		
		-- renew Dots
		{ "icy touch",				ffDuration <= 0 },
		{ "plague strike",			bpDuration <= 0 },
		
		-- get Runes
		{ "Plague Leech",			canCastPlagueLeech(3)}, 		
		{ "summon gargoyle" },
    	{ "empower rune weapon",		(not twoDr and not twoFr and not twoUr)  and jps.UseCDs },
		
		{ "dark transformation",	siStacks >= 5 and not superPet },
		
		-- 
		{ "scourge strike",			twoUr and rp < 90 },
		{ "festering strike",		twoDr and twoFr and rp < 90 },
		{ "death coil",				rp > 90 },
		{ "death coil",				jps.buff("sudden doom") },
		{ "blood tap",            jps.buffStacks("blood charge") >= 5 and (not oneDr or not oneUr or not oneFr )},
		{ "scourge strike" },
		{ "festering strike" },
		{ "death coil", 			jps.cooldown("summon gargoyle") > 8 },
		{ "horn of winter" },
		{ "empower rune weapon" , jps.UseCDs},
	}

	spell,target = parseSpellTable(spellTable) 
	return spell,target
end
