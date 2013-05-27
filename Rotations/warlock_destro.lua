function noSpamCotE () -- stop spam curse of the elements at invalid targets @ mop
	 local table_noSpamCotE =
	{		
		"Twilight Sapper", 
		"Burning Tendons",
		"Corrupted Blood",
		"Energy Charge",
		"Celestial Protector",
	}
	 for i,j in pairs(table_noSpamCotE) do
	 	if UnitName("target") == j then return true end
	 end
	 return false
end

function warlock_destro()

	 local burningEmbersStacks = UnitPower("player",14)
	 local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
	 local imoDuration = jps.debuffDuration("immolate")
	 local curDuration = jps.debuffDuration("curse of the elements")
	 local focusHavoc = UnitExists("focus")
	 local isCotEBlacklist = noSpamCotE ()

	local	spell1,_,_,_,_,end1,_,_,_ = UnitCastingInfo("player")
	if endtimeImo == nil then endtimeImo = 0 end
	if spell1 == "Immolate" then endtimeImo = (end1/1000) end

------------------------
-- SPELL TABLE ---------
------------------------

local spellTable = {}	 
spellTable[1] =
{	
	["ToolTip"] = "Warlock Normal",
	
	{ "fel flame", currentSpeed > 0 },
		
	{ "curse of the elements", curDuration == 0 and not isCotEBlacklist	},
	{ "rain of fire",		IsAltKeyDown() ~= nil },
	--mise de la cible en focus --
	
	{ {"macro","/focus [target=mouseover,exists,nodead]"}, IsShiftKeyDown() ~= nil },
	-- doomguard--
	{ "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.bloodlusting() },
	{ "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.hp("target") < 0.25 and jps.UseCDs },
	
	{ jps.useTrinket(0), jps.UseCds },
	{ jps.useTrinket(1), jps.UseCds },
	
	{ {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and	burningEmbersStacks > 3	},
	{ {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and	jps.Opening	},
	{ {"macro","/use 10"}, jps.glovesCooldown() == 0 },
	{ jps.DPSRacial },
	
	-- Requires engineerins
	{ jps.useSynapseSprings(), jps.UseCDs },
	
	-- Requires herbalism
	{ "Lifeblood", jps.UseCDs },
	
	--Survie cd --
	{ "sacrificial pact", jps.hp() < 0.50 },
	{ "mortal coil", jps.hp() < 0.6 },
	{ "ember tap", jps.hp() <= 0.25 and burningEmbersStacks > 0 },
	
	--aoe--
	{ "fire and brimstone", burningEmbersStacks > 0 and not jps.debuff("fire and brimstone") and jps.MultiTarget },
	
	-- 2 cible/avec 1 cible en focus--
	{ "havoc",		focusHavoc == 1 and jps.cooldown("havoc") == 0, "focus"	},
	
	--mono--
	{ "shadowburn", jps.hp("target") <= 0.20 and burningEmbersStacks > 0 },
	{ "conflagrate", not jps.buff("backdraft") },
	{ "immolate", imoDuration < 2 and endtimeImo+2 < GetTime() },
	
	{ "chaos bolt", lcChaosBolting and jps.hp("target") > 0.23 and not jps.debuff("chaos bolt") and jps.buffStacks("backdraft") < 3	},
	{ "incinerate", jps.buff("backdraft") },
	{ "incinerate" },
}
 

	if burningEmbersStacks == 1 or jps.hp("target") <= 0.20 then lcChaosBolting = false end
	if burningEmbersStacks > 3 then lcChaosBolting = true end
	if jps.buff("backdraft") then jps.Opening = false end

	local spellTableActive = jps.RotationActive(spellTable)
	local spell,target = parseSpellTable(spellTableActive)
	
	return spell,target
end