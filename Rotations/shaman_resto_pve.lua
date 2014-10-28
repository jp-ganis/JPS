jps.registerRotation("SHAMAN","RESTORATION",function()

	local spell = nil
	local target = nil

	local lsStacks = jps.buffStacks("lightning shield")
	local focus = "focus"
	local me = "player"
	local tank = nil


	-- Totems
	local _, fireName, _, _, _ = GetTotemInfo(1)
	local _, earthName, _, _, _ = GetTotemInfo(2)
	local _, waterName, _, _, _ = GetTotemInfo(3)
	local _, airName, _, _, _ = GetTotemInfo(4)

	local haveFireTotem = fireName ~= ""
	local haveEarthTotem = earthName ~= ""
	local haveWaterTotem = waterName ~= ""
	local haveAirTotem = airName ~= ""

	tank = jps.findMeATank()
	--assumes that focus is the tank

	-- Check if we should Purify
	local cleanseTarget = nil
	cleanseTarget = jps.FindMeDispelTarget({"Curse"},{"Magic"})


	-- lowest friendly
	local defaultTarget = jps.LowestInRaidStatus()
	local defaultHP = jps.hp(defaultTarget)


	-- Priority Table
	local spellTable =
	{
		{ "fire elemental totem", 	jps.UseCDs },
		{ "spiritwalker's grace", 	jps.Moving and defaultHP < 0.75 },

		-- Buffs
		{ "water shield", 			not jps.buff("water shield"), me  },

		-- Set focus to put Earth Shield on focus target
		{ "earth shield",			tank ~= me and not jps.buff("earth shield",tank), tank },


		{ "Purify spirit",			cleanseTarget~=nil and jps.Interrupts, cleanseTarget },


		--Cooldowns
		{"Ancestral Swiftness", jps.UseCDs and jps.hpInc(tank) <= 0.50, me },
		{"ascendance", jps.UseCDs and not moving and (jps.CountInRaidStatus(0.4) >= 8 or (jps.CountInRaidStatus(0.4) >= 4 and GetNumGroupMembers < 10)), me },
		{"Acestral Guidance", jps.UseCDs and not moving and (jps.CountInRaidStatus(0.4) >= 8 or (jps.CountInRaidStatus(0.4) >= 4 and GetNumGroupMembers < 10)), me },
		{"spirit link totem", jps.UseCDs and jps.CountInRaidStatus(0.4) >= 5, me },
		{"unleashed fury", jps.UseCDs and jps.hpInc(tank) <= 0.50, me },

		--AoE rain
		{"healing rain", IsShiftKeyDown() == true and GetCurrentKeyBoardFocus() == nil },
		{"chain heal",	IsLeftControlKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.canHeal("mouseover"), "mouseover" },
		{"chain heal",	IsLeftControlKeyDown() == true and GetCurrentKeyBoardFocus() == nil and defaultHP < 0.90, defaultTarget },
		
		--main rotation
		{"riptide", defaultHP <= 0.90, defaultTarget },
		{"healing stream totem", not haveWaterTotem },
		{"unleash elements", defaultHP <= 0.75, defaultTarget },
		{"healing surge", not moving and jps.hpInc(tank) <= 0.40, tank },
		{"healing surge", not moving and defaultHP <= 0.50 and defaultTarget ~= tank, defaultTarget },
		{"healing wave", not moving and jps.hpInc(tank) <= 0.60, tank },
		{"healing wave", not moving and defaultHP <= 0.40, defaultTarget },
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default", true, false)