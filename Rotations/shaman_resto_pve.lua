jps.registerRotation("SHAMAN","RESTORATION",function()

	local spell = nil
	local target = nil

	local lsStacks = jps.buffStacks("lightning shield")
	local focus = "focus"
	local me = "player"
	local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()
	local engineering ="/use 10"
	local r = jps.Macro
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
		{ "Earthliving Weapon", 	not mh, me},

		-- Set focus to put Earth Shield on focus target
		{ "earth shield",			tank ~= me and not jps.buff("earth shield",tank), tank },

		-- Heals
		-- Shift key
		{ "Healing Rain",			IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		-- Left Control key
		{ "chain heal",				IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and defaultHP < 0.7, defaultTarget },

		{ "riptide", 				defaultHP < 0.95 and not jps.buff("RipTide"), defaultTarget },
		{ "greater healing wave", 	defaultHP < 0.4, defaultTarget },
		{ "healing wave",			defaultHP < 0.8, defaultTarget },

		{ "Purify spirit",			cleanseTarget~=nil, cleanseTarget },
		-- Totems.
		{ "call of the elements",	not haveWaterTotem and not haveFireTotem and not haveEarthTotem and not haveAirTotem },
		{ "healing stream totem",	not haveWaterTotem and jps.mana() > 0.5 },
		{ "mana spring totem",		jps.mana() < 0.5 and (not haveWaterTotem or waterName == "healing stream totem") },
		{ "water shield",			not jps.buff("water shield") and not jps.buff("earth shield") },
		{ "wrath of air totem",		not haveAirTotem },
		{ "stoneskin totem",		not haveEarthTotem },
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default", true, false)



--[[[
@rotation Shaman Resto PVE 5.3
@class Shaman
@spec Restoration
@author shadowstepster & pgnomeian
@description

Modifiers:<br>
Alt Key: spiritwalker's grace<br>
Shift Key: healing rain<br>
Left Control Key: purify spirit

]]--

jps.registerRotation("SHAMAN","RESTORATION",function()
	--healer
	local tank = nil
	local me = "player"
	local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()

	-- Tank is focus.
	tank = jps.findMeATank()

	-- Check if we should Purify
	local cleanseTarget = nil
	cleanseTarget = jps.FindMeDispelTarget({"Curse"},{"Magic"})

	--Default to healing lowest partymember
	local defaultTarget = jps.LowestInRaidStatus()

	--Check that the tank isn't going critical, and that I'm not about to die
	if jps.canHeal(tank) and jps.hpInc(tank) <= 0.2 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then defaultTarget = me end

	--Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)

	-- Totems
	local _, fireName, _, _, _ = GetTotemInfo(1)
	local _, earthName, _, _, _ = GetTotemInfo(2)
	local _, waterName, _, _, _ = GetTotemInfo(3)
	local _, airName, _, _, _ = GetTotemInfo(4)
	local haveFireTotem = fireName ~= ""
	local haveEarthTotem = earthName ~= ""
	local haveWaterTotem = waterName ~= ""
	local haveAirTotem = airName ~= ""

	--Spiritwalker's Grace stuff
	local moving = jps.Moving and not jps.buff("spiritwalker's grace")

	local spellTable =
		{
		--Buffs
		{"water shield", not jps.buff("water shield") },
		{ "Earthliving Weapon", not mh, me},

		{ "earth shield",			tank ~= me and not jps.buff("earth shield",tank), tank },



		--Cooldowns
		{"Ancestral Swiftness", jps.UseCDs and jps.hpInc(tank) <= 0.50, me },
		{"ascendance", jps.UseCDs and not moving and (jps.CountInRaidStatus(0.4) >= 8 or (jps.CountInRaidStatus(0.4) >= 4 and GetNumGroupMembers < 10)), me },
		{"spirit link totem", jps.UseCDs and (jps.CountInRaidStatus(0.4) >= 8 or (jps.CountInRaidStatus(0.4) >= 4 and GetNumGroupMembers < 10)), me },
		{"stormlash totem", jps.buff("bloodlust") or jps.buff("time warp") or jps.buff("ancient hysteria") },
		{"unleashed fury", jps.UseCDs and jps.hpInc(tank) <= 0.50, me },
		{"mana tide totem", jps.UseCDs and jps.mana() <= 0.40 },
		{"spiritwalker's grace", IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

		--AoE rain
		{"healing rain", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

		--Dispells
		{"purify spirit", IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and cleanseTarget~=nil, cleanseTarget },

		--main rotation
		{"riptide", defaultHP <= 0.90, defaultTarget },
		{"healing stream totem", not haveWaterTotem },
		{"healing surge", not moving and jps.hpInc(tank) <= 0.40, tank },
		{"greater healing wave", not moving and jps.hpInc(tank) <= 0.70, tank },
		{"healing surge", not moving and defaultHP <= 0.50 and defaultTarget ~= tank, defaultTarget },
		{"chain heal", jps.CountInRaidStatus(0.8) >= 3, defaultTarget },
		{"unleash elements", defaultHP <= 0.75, defaultTarget },
		{"greater healing wave", not moving and defaultHP <= 0.70, defaultTarget },
		{"healing wave", not moving and defaultHP <= 0.85, defaultTarget },

		--Filler heal the tank
		{"riptide", jps.hpInc(tank) <= 0.95, tank},
		{"healing wave", not moving and jps.hpInc(tank) <= 0.85, tank },
	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end, "chainheal", true, true)
