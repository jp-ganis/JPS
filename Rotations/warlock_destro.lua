
function unitNotGarroshMCed(unit)
	if UnitExists(unit) then
		if UnitDebuff(unit,GetSpellInfo(145832))
		or UnitDebuff(unit,GetSpellInfo(145171))
		or UnitDebuff(unit,GetSpellInfo(145065))
		or UnitDebuff(unit,GetSpellInfo(145071))
		then return false else return true end
	end
	return true
end

local spellTable = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),
	
	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{wl.spells.createHealthstone, 'jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= wl.spells.createHealthstone'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	
	{wl.spells.emberTap, 'jps.Defensive and jps.hp() <= 0.30 and jps.burningEmbers() > 0' },

	-- Soulstone
	wl.soulStone("target"),

	-- Rain of Fire
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1 and not GetCurrentKeyBoardFocus()'	},
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },

	{wl.spells.cataclysm, 'IsShiftKeyDown() and IsAltKeyDown() and not GetCurrentKeyBoardFocus()'},


	{wl.spells.fireAndBrimstone, 'jps.burningEmbers() > 0 and not jps.buff(wl.spells.fireAndBrimstone, "player") and jps.MultiTarget and not jps.isRecast(wl.spells.fireAndBrimstone, "target")' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.burningEmbers() == 0' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },

	-- CD's
	{"nested", 'jps.canDPS("target") and not jps.Moving', {
		{ {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and not jps.buff(wl.spells.darkSoulInstability) and jps.UseCDs' },
		{ jps.getDPSRacial(), 'jps.UseCDs' },
		{wl.spells.lifeblood, 'jps.UseCDs' },
		{ {"macro","/use 10"}, 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
		{ jps.useTrinket(0),	   'jps.UseCDs' },
		{ jps.useTrinket(1),	   'jps.UseCDs' },	
	}},
	-- Shadowburn mouseover!
	{wl.spells.shadowburn, 'jps.hp("mouseover") < 0.20 and jps.burningEmbers() > 0 and jps.myDebuffDuration(wl.spells.shadowburn, "mouseover")<=0.5  and unitNotGarroshMCed("target")', "mouseover"  },

	{"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
		{wl.spells.havoc, 'not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
		{wl.spells.havoc, 'not jps.Moving and wl.attackFocus()', "focus" },
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0  and unitNotGarroshMCed("target")'  },
		{wl.spells.chaosBolt, 'jps.burningEmbers() > 0 and	jps.buffStacks(wl.spells.havoc)>=3'},
		{"nested", 'not jps.Moving', {
			jps.dotTracker.castTableStatic("immolate"),
		}},
		{wl.spells.conflagrate },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.buff(wl.spells.darkSoulInstability) and jps.emberShards() >= 19 and UnitHealth("target") > 600000' ,"target" },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.TimeToDie("target", 0.2) > 5.0 and jps.burningEmbers() >= 3 and jps.buffStacks(wl.spells.backdraft) < 3 and UnitHealth("target") > 600000' ,"target"},
		{wl.spells.chaosBolt, 'not jps.Moving and jps.emberShards() >= 35 and UnitHealth("target") > 600000' ,"target"},
		{wl.spells.chaosBolt, 'not jps.Moving and wl.hasProc(1) and jps.emberShards() >= 10 and jps.buffStacks(wl.spells.backdraft) < 3 and UnitHealth("target") > 600000' ,"target"},
		{wl.spells.incinerate },
	}},

	{"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.conflagrate },
	}},
	
	{"nested", 'jps.MultiTarget', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and jps.LastCast ~= wl.spells.immolate'},
		{wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player")' },
		{wl.spells.chaosBolt, 'jps.emberShards() > 30 and wl.gotCharredRemains()'},
		{wl.spells.incinerate },
	}},
}


jps.registerRotation("WARLOCK","DESTRUCTION",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() and not GetCurrentKeyBoardFocus() and wl.btn("altShadowfury") then
		jps.Cast("Shadowfury")
	end
	
	return parseStaticSpellTable(spellTable)
end,"Destruction 6.0b")



local spellTableCharred = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),
	
	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{wl.spells.createHealthstone, 'jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= wl.spells.createHealthstone'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	
	{wl.spells.emberTap, 'jps.Defensive and jps.hp() <= 0.30 and jps.burningEmbers() > 0' },

	-- Soulstone
	wl.soulStone("target"),

	-- Rain of Fire
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1 and not GetCurrentKeyBoardFocus()'	},
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },

	{wl.spells.cataclysm, 'IsShiftKeyDown() and IsAltKeyDown() and not GetCurrentKeyBoardFocus()'},


	{wl.spells.fireAndBrimstone, 'jps.emberShards() > 15 and not jps.buff(wl.spells.fireAndBrimstone, "player") and jps.MultiTarget and not jps.isRecast(wl.spells.fireAndBrimstone, "target")' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.burningEmbers() == 0' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },

	-- CD's
	{"nested", 'jps.canDPS("target") and not jps.Moving', {
		{ {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and not jps.buff(wl.spells.darkSoulInstability) and jps.UseCDs' },
		{ jps.getDPSRacial(), 'jps.UseCDs' },
		{wl.spells.lifeblood, 'jps.UseCDs' },
		{ {"macro","/use 10"}, 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
		{ jps.useTrinket(0),	   'jps.UseCDs' },
		{ jps.useTrinket(1),	   'jps.UseCDs' },	
	}},
	-- Shadowburn mouseover!
	{wl.spells.shadowburn, 'jps.hp("mouseover") < 0.20 and jps.burningEmbers() > 0 and jps.myDebuffDuration(wl.spells.shadowburn, "mouseover")<=0.5  and unitNotGarroshMCed("target")', "mouseover"  },

	{"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
		{wl.spells.havoc, 'not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
		{wl.spells.havoc, 'not jps.Moving and wl.attackFocus()', "focus" },
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0  and unitNotGarroshMCed("target")'  },
		{wl.spells.chaosBolt, 'jps.burningEmbers() > 0 and jps.buffStacks(wl.spells.havoc)>=3'},
		{"nested", 'not jps.Moving', {
			jps.dotTracker.castTableStatic("immolate"),
		}},
		{wl.spells.conflagrate },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.buff(wl.spells.darkSoulInstability) and jps.emberShards() >= 10' ,"target" },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.emberShards() >= 20' ,"target"},
		{wl.spells.chaosBolt, 'not jps.Moving and wl.hasProc(1) and jps.emberShards() >= 10 and jps.buffStacks(wl.spells.backdraft) < 3' ,"target"},
		{wl.spells.incinerate },
	}},

	{"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.conflagrate },
	}},
	
	{"nested", 'jps.MultiTarget', {
		{wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and jps.LastCast ~= wl.spells.immolate'},
		{wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.emberShards() < 35' },
		{wl.spells.chaosBolt, 'jps.emberShards() >= 30'}, 
		{wl.spells.incinerate },
	}},
}

jps.registerRotation("WARLOCK","DESTRUCTION",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() and not GetCurrentKeyBoardFocus() and wl.btn("altShadowfury") then
		jps.Cast("Shadowfury")
	end
	
	return parseStaticSpellTable(spellTableCharred)
end,"Destruction Charred Remais 6.0b")
