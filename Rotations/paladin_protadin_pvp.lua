function paladin_protadin_pvp()
-- Conor663 (begged, borrowed, stolen)
local spell = nil

local holyPower = UnitPower("player",9)
   
local spellTable_single =
{    
	 -- Kicks
	{ "Rebuke",                     jps.shouldKick() },
	{ "Rebuke",                     jps.shouldKick("focus"), "focus" },
	{ "Avenger's Shield",            jps.shouldKick() and jps.UseCDs and IsSpellInRange("Avenger's Shield","target")==0 and jps.LastCast ~= "Rebuke" },
	{ "Avenger's Shield",            jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("Avenger's Shield","focus")==0 and jps.LastCast ~= "Rebuke" , "focus" },
	
	-- Aggro Cooldowns
	{ "Holy Avenger",               jps.UseCDs },
	{ "Avenging Wrath",               jps.UseCDs },
	
	-- Defensive Cooldowns
	{ "Lay on Hands",                jps.hp() < 0.3 and jps.UseCDs },
	{ "Ardent Defender",             jps.hp() < 0.5 and jps.UseCDs },
	{ "Divine Protection",             jps.hp() < 0.8 and jps.UseCDs },
	
	-- Self Heal   
	{ {"macro","/cast Word of Glory"},    jps.hp() < 0.7 and holyPower > 2 },       
	  
	-- Buffs
	{ "Righteous Fury",             not jps.buff("Righteous Fury") },
	{ "Sacred Shield",                not jps.buff("Sacred shield") },  
	
	-- Single Target 
	{ "Avenger's Shield" },
	{ "Hammer of the Righteous",      not jps.debuff("Weakened Blows") }, 
	{ "Shield of the Righteous",      holyPower > 3 },  
	{ "Judgment" },      
	{ "Crusader Strike" },
	{ "Consecration" },
	{ "Holy Wrath" },
	
	-- Execute
	{ "hammer of wrath",       jps.hp("target") <= 0.20 },   
}

 local spellTable_multi =
{    
	 -- Kicks
	{ "Rebuke",                     jps.shouldKick() },
	{ "Rebuke",                     jps.shouldKick("focus"), "focus" },
	{ "Avenger's Shield",            jps.shouldKick() and jps.UseCDs and IsSpellInRange("Avenger's Shield","target")==0 and jps.LastCast ~= "Rebuke" },
	{ "Avenger's Shield",            jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("Avenger's Shield","focus")==0 and jps.LastCast ~= "Rebuke" , "focus" },
	
	-- Aggro Cooldowns
	{ "Holy Avenger",               jps.UseCDs },
	{ "Avenging Wrath",               jps.UseCDs },
	
	-- Defensive Cooldowns
	{ "Lay on Hands",                jps.hp() < 0.3 and jps.UseCDs },
	{ "Ardent Defender",             jps.hp() < 0.5 and jps.UseCDs },
	{ "Divine Protection",             jps.hp() < 0.8 and jps.UseCDs },
	
	-- Self Heal   
	{ {"macro","/cast Word of Glory"},    jps.hp() < 0.7 and holyPower > 2 },
	         
	-- Buffs
	{ "Righteous Fury",             not jps.buff("Righteous Fury") },
	{ "Sacred Shield",                not jps.buff("Sacred shield") },  
	-- Multi Target 
	
	{ "Hammer of the Righteous" }, 
	{ "Avenger's Shield" },   
	{ "Consecration" },
	{ "Holy Wrath" },
	{ "Shield of the Righteous",      holyPower > 3 },  
	{ "Judgment" },   
	
	-- Execute
	{ "hammer of wrath",       jps.hp("target") <= 0.20 },   
}
   
	if jps.MultiTarget then
		spell, target = parseSpellTable(spellTable_multi)
	else
		spell, target = parseSpellTable(spellTable_single)
	end
	return spell,target
end
