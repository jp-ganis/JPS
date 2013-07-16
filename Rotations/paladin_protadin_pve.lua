jps.registerRotation("PALADIN","PROTECTION",function()
	local spell = nil
	local target = nil
	local holyPower = jps.holyPower()
	local stance = GetShapeshiftForm()
	--Paladin (only when arg1 is nil)
	--1 = Seal of Truth
	--2 = Seal of Righteousness
	--3 = Seal of Insight - Seal of Justice if retribution
	--4 = Seal of Insight if retribution
	
	local spellTable = {	
		-- Seal
		{ "Seal of Insight", stance ~= 3 , player },
		
		-- Interrupt
		{ "Rebuke", jps.shouldKick() },
		
		-- Interrupt    
		{ "Avenger's Shield",	jps.shouldKick() and jps.UseCDs and IsSpellInRange("Avenger's Shield","target") == 0 and jps.LastCast ~= "Rebuke" },
		
		-- Stun
		{ "Hammer of Justice",	jps.shouldKick() },
		
		-- Stun
		{ "Fist of Justice",	jps.shouldKick() },
		
		-- Aggro
		{ "Holy Avenger",	jps.UseCDs },
		
		-- Aggro
		{ "Avenging Wrath",	jps.UseCDs },
		
		-- Oh shit button
		{ "Lay on Hands",	jps.hp() < 0.3  and jps.UseCDs },
		
		-- Mitigation
		{ "Ardent Defender",	jps.hp() < 0.5  and jps.UseCDs },
		
		-- Mitigation
		{ "Divine Protection",	jps.hp() < 0.8  and jps.UseCDs },
		
		-- Heal
		{ "Word of Glory",	jps.hp() < 0.7 and holyPower > 2 },
		
		-- Heal
		{ "Hand of Purity",	jps.hp() < .6 and jps.UseCDs, "player" },
		
		-- Heal
		{ "Holy Prism",	jps.hp() < .6  and jps.UseCDs, "player" },
		
		-- Heal / Damage
		{ "Light's Hammer", IsShiftKeyDown()  and jps.UseCDs },
	
		-- Buff
		{ "Righteous Fury",	not jps.buff("Righteous Fury") },
		
		-- Buff
		{ "Sacred Shield",	not jps.buff("Sacred shield") },
		
		-- Execute
		{ "Hammer of Wrath",	jps.hp("target") <= .2 }, 
		
		-- Damage
		{ "Avenger's Shield" },	
		
		-- Damage (Multi target or missing debuff)
		{ "Hammer of the Righteous", not jps.debuff("Weakened Blows") or jps.MultiTarget }, 
		
		-- Damage
		{ "Shield of the Righteous",	holyPower > 3 },
		
		-- Damage
		{ "Judgment" },      	
		-- Damage (Single target)
		{ "Crusader Strike", not jps.MultiTarget },
		
		-- Damage
		{ "Consecration" },	
		-- Damage
		{ "Holy Wrath" },   
	}
	   
	local spell, target = parseSpellTable(spellTable)
	return spell, target
end, "Default",true,false)
