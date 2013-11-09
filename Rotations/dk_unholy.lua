-- tropic (original by jpganis)
-- Ty to SIMCRAFT for this rotation
jps.registerRotation("DEATHKNIGHT","UNHOLY",function()

	-- Shift-key to cast Death and Decay
	-- Set "focus" for dark simulacrum (duplicate spell) (this is optional, default is current target)
	-- Automatically raise ghoul if dead
	
	local spell = nil
	local target = nil

	local rp = UnitPower("player") 

	local ffDuration = jps.myDebuffDuration("frost fever")
	local bpDuration = jps.myDebuffDuration("blood plague")
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

	-- function for checking diseases on target for plague leech, because we need fresh dot time left
	function canCastPlagueLeech(timeLeft)  
		if not jps.myDebuff("Frost Fever") or not jps.myDebuff("Blood Plague") then return false end
		if jps.myDebuffDuration("Frost Fever") <= timeLeft then
			return true
		end
		if jps.myDebuffDuration("Blood Plague") <= timeLeft then
			return true
		end
		return false
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
		{ "Death Siphon", jps.hp() < .8 and jps.Defensive },
		{ "Death Strike", jps.hp() < .7 and jps.Defensive },
		{ "Death Pact", jps.UseCDs and jps.hp() < .6 and UnitExists("pet") ~= nil },
		
		-- Battle Rezz
    	{ "Raise Ally", UnitIsDeadOrGhost("focus") == 1 and jps.UseCds, "focus" },
    	{ "Raise Ally", UnitIsDeadOrGhost("target") == 1 and jps.UseCds, "target"},

		-- AOE
		{ "Death and Decay", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil},
		
		-- spell steal
		
		{"Dark Simulacrum ", dk.shouldDarkSimTarget() , "target"},
		{"Dark Simulacrum ", dk.shouldDarkSimFocus() , "focus"},
		
		-- CDs
		{ "unholy frenzy" },
		{ jps.getDPSRacial(), jps.UseCDs },
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and jps.UseCDs},
		
		-- Requires herbalism
		{ "Lifeblood", jps.UseCDs },
		
		-- rezz pet
		{ "Raise Dead", jps.UseCDs and UnitExists("pet") == nil },
		
		-- DOT CDs

		{ "outbreak",				not jps.myDebuff("frost fever") or not jps.myDebuff("blood plague") or dk.shouldRefreshDot("frost fever") or dk.shouldRefreshDot("blood plague") },
		{ "unholy blight",			not jps.myDebuff("frost fever") or not jps.myDebuff("blood plague") or dk.shouldRefreshDot("frost fever") or dk.shouldRefreshDot("blood plague") },
		
		-- Execute
		{ "soul reaper",			jps.hp("target") <= 0.35 },
		
		-- renew Dots
		--{ "icy touch",				ffDuration <= 0 },
		{ "plague strike",			bpDuration <= 0 or ffDuration <= 0 or dk.shouldRefreshDot("frost fever") or dk.shouldRefreshDot("blood plague")  },
		
		-- get Runes
		{ "summon gargoyle" },
		
		{ "dark transformation",	siStacks >= 5 and not superPet },
		
		-- 
		{ "scourge strike",			twoUr and rp < 90 },
		{ "festering strike",		twoDr and twoFr and rp < 90 },
		{ "Blood Tap", jps.buffStacks("Blood Charge") >= 5},
		{ "death coil",				rp > 90 },
		{ "death coil",				jps.buff("sudden doom") },
		{ "blood tap",            jps.buffStacks("blood charge") >= 5 and (not oneDr or not oneUr or not oneFr )},
		--{ "festering strike",		(dk.shouldExtendDot("frost fever") or dk.shouldExtendDot("blood plague")) and (ffDuration < 20 or bpDuration < 20)},
		{ "scourge strike" },
		{ "festering strike" },
		{ "death coil", 			jps.cooldown("summon gargoyle") > 8 },
		{ "horn of winter" },
		{ "empower rune weapon" , jps.UseCDs},
	}

	spell,target = parseSpellTable(spellTable) 
	return spell,target
end, "Default")
