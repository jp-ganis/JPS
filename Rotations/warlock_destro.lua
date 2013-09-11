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
	-- COE Debuff
	{wl.spells.curseOfTheElements, 'not jps.debuff(wl.spells.curseOfTheElements) and not wl.isTrivial("target") and not wl.isCotEBlacklisted("target")' },
	{wl.spells.curseOfTheElements, 'wl.attackFocus() and not jps.debuff(wl.spells.curseOfTheElements, "focus") and not wl.isTrivial("focus") and not wl.isCotEBlacklisted("focus")' , "focus" },
	
	{wl.spells.fireAndBrimstone, 'jps.burningEmbers() > 0 and not jps.buff(wl.spells.fireAndBrimstone, "player") and jps.MultiTarget and not jps.isRecast(wl.spells.fireAndBrimstone, "target")' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.burningEmbers() == 0' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },
	
	-- On the move
	{wl.spells.felFlame, 'jps.Moving and not wl.hasKilJaedensCunning()' },
	
	-- CD's
	{ {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and jps.UseCDs' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useSynapseSprings(), 'jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.UseCDs' },
	
	-- Shadowburn mouseover!
	{wl.spells.shadowburn, 'jps.hp("mouseover") < 0.20 and jps.burningEmbers() > 0 and jps.myDebuffDuration(wl.spells.shadowburn, "mouseover")<=0.5', "mouseover"  },

	{"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
		{wl.spells.havoc, 'not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
		{wl.spells.havoc, 'not jps.Moving and wl.attackFocus()', "focus" },
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.burningEmbers() > 0 and	jps.buffStacks(wl.spells.havoc)>=3'},
		{"nested", 'not jps.Moving', {
			jps.dotTracker.castTableStatic("immolate"),
		}},
		{wl.spells.conflagrate },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.buff(wl.spells.darkSoulInstability) and jps.emberShards() >= 19' },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.TimeToDie("target", 0.2) > 5.0 and jps.burningEmbers() >= 3 and jps.buffStacks(wl.spells.backdraft) < 3'},
		{wl.spells.chaosBolt, 'not jps.Moving and jps.emberShards() >= 35'},
		{wl.spells.incinerate },
	}},
	
	{"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.conflagrate },
		{wl.spells.felFlame },
	}},
	{"nested", 'jps.MultiTarget', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and jps.LastCast ~= wl.spells.immolate'},
		{wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player")' },
		{wl.spells.incinerate },
	}},
}


--[[[
@rotation Destruction 5.4
@class warlock
@spec destruction
@talents Vb!112101!ZbS
@author Kirk24788
@description 
This is a Raid-Rotation, which will do fine on normal mobs, even while leveling but might not be optimal for PvP.
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Cast Rain of Fire @ Mouse - [b]ONLY[/b] if RoF Duration is less than 1 seconds[br]
[*] [code]CTRL-SHIFT[/code]: Cast Rain of Fire @ Mouse - ignoring the current RoF duration[br]
[*] [code]CTRL[/code]: If target is dead or ghost cast Soulstone, else cast Havoc @ Mouse[br]
[*] [code]ALT[/code]: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)[br]
[*] [code]jps.Interrupts[/code]: Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)[br]
[*] [code]jps.Defensive[/code]: Create Healthstone if necessary, cast mortal coil and use ember tap[br]
[*] [code]jps.UseCDs[/code]: Use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated![br]
]]--
jps.registerRotation("WARLOCK","DESTRUCTION",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	return parseStaticSpellTable(spellTable)
end,"Destruction 5.3")


--[[[
@rotation Interrupt Only
@class warlock
@spec destruction
@author Kirk24788
@description 
This is Rotation will only take care of Interrupts. [i]Attention:[/i] [code]jps.Interrupts[/code] still has to be active!
]]--
jps.registerStaticTable("WARLOCK","DESTRUCTION",wl.interruptSpellTable,"Interrupt Only")
