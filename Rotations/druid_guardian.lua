--[[[
@rotation Default
@class druid
@spec guardian
@author jpganis, Attip, peanutbird
@description
Guardian Rotation
]]--
jps.registerRotation("DRUID","GUARDIAN",function()
	local spell = nil
	local target = nil

	-- Other stuff
	local rage = UnitMana("player")
	local lacCount = jps.debuffStacks("lacerate")
	local lacDuration = jps.myDebuffDuration("lacerate")
	local thrashDuration = jps.myDebuffDuration("thrash")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100
	local onCD = "onCD"

	local spellTable =
	{

		-- Buffs
		{ "mark of the wild",		 	not jps.hasStatsBuff("player") and not jps.buff("Bear Form"), player },
		--[[{nil,									IsSpellInRange("lacerate","target") ~= 1 },]]--
		{"Bear Form", not jps.buff("Bear Form")},
		
		-- Interrupts
		{"skull bash",						jps.shouldKick() },

		-- Defense
		{"barkskin",						hp < 75 and jps.UseCDs},
		{"survival instincts",			hp < 50 and jps.UseCDs},
		{"frenzied regeneration",	hp < 55 and jps.buff("savage defense")},
		{"savage defense",				hp < 90 and rage >= 60},
		{"renewal", 						hp < 20 and jps.UseCDs },
		{"healing touch", 				hp < 20 and jps.buff("nature's swiftness") and jps.UseCDs },

		-- Offense
		{"berserk",						jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},

		-- Multi-Target
		{"thrash",			jps.MultiTarget and not jps.debuff("thrash")},
		{"mangle",			jps.MultiTarget },

		-- Single Target
		{"mangle",			onCD or jps.buff("berserk") },
		{"maul",			rage > 90 and hp >= 85 },
		{"thrash",			not jps.debuff("thrash") or thrashDuration < 3 },
		{"lacerate",		lacCount < 3 or lacDuration < 1 },
		--{"trash"},
	
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default")
