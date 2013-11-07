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
	local lacDuration = jps.debuffDuration("lacerate")
	local thrashDuration = jps.debuffDuration("thrash")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100
	local onCD = "onCD"

	local spellTable =
	{

		-- Buffs
		{ "mark of the wild",		 	not jps.hasStatsBuff("player") , player },
		--[[{nil,									IsSpellInRange("lacerate","target") ~= 1 },]]--

		-- Interrupts
		{"skull bash",						jps.Interrupts and jps.shouldKick() },
		{"mighty bash",					jps.Interrupts and jps.shouldKick() },

		-- Healing / Support
		{"heart of the wild",			IsControlKeyDown() ~= nil},
		{"rejuvenation",					jps.buff("heart of the wild") and hp < 75 and not jps.buff("rejuvenation")},
		{"rejuvenation", 				jps.buff("heart of the wild") and IsControlKeyDown() ~= nil and IsSpellInRange("rejuvenation", "mouseover"), "mouseover" },

		-- Defense
		{"barkskin",						hp < 75 and jps.UseCDs},
		{"survival instincts",			hp < 50 and jps.UseCDs},
		{"might of ursoc",				hp < 25 and jps.UseCDs},
		{"frenzied regeneration",	hp < 55 and jps.buff("savage defense")},
		{"savage defense",				hp < 90 and rage >= 60},
		{"renewal", 						hp < 20 and jps.UseCDs },
		{"nature’s swiftness", 			hp < 20 and jps.UseCDs },
		{"healing touch", 				hp < 20 and jps.buff("nature's swiftness") and jps.UseCDs },
		{"enrage",							rage <= 10 and hp > 95},

		-- Offense
		{"berserk",						jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},

		-- Multi-Target
		{"thrash",			jps.MultiTarget and not jps.debuff("thrash")},
		{"mangle",			jps.MultiTarget },
		{"swipe",			jps.MultiTarget },

		-- Single Target
		{"mangle",			onCD or jps.buff("berserk") },
		{"maul",			rage > 90 and hp >= 85 },
		{"faerie fire",		not jps.debuff("weakened armor") },
		{"thrash",			not jps.debuff("thrash") or thrashDuration < 3 },
		{"lacerate",		lacCount < 3 or lacDuration < 1 },
		{"faerie fire",		onCD },
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default")
