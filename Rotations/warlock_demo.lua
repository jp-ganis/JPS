--[[[
@rotation Demonology 6.0.2 Basic
@class warlock
@spec demonology
@description
Demo Rotation.<br>
ALT Key for instant casts.<br>
Shift+Control for enter meta at any time<br>
Shift+Alt to cancel meta<br>
Control for cataclysm
]]--

function wl.hasPowerfulDemoProc()
	if jps.buff(wl.spells.darkSoulKnowledge)
	or jps.buff(26297) -- berserking, haste
	or jps.bloodlusting()
	or jps.buff(105702) --potion of jade serpent
	or jps.buff(138786)--Wushoolay's Lightning,  int
	or jps.debuff(138002) --fluidity jinrokh, dmg
	or jps.buff(112879) -- primal nutriment jikun, dmg
	or jps.buff(138963) --Perfect Aim, 1005 crit
	then
		return true
	end
	return false
end

function wl.shouldMouseoverDoom()
	if not jps.canDPS("mouseover") then return false end
	if jps.debuff(wl.spells.doom, "mouseover") then return false end
	return true
end

local cdTable = {
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge)' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{ wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.useTrinket(0) ~= ""  and jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.useTrinket(1) ~= ""  and  jps.UseCDs' },
	{ wl.spells.impSwarm , 'jps.UseCDs and jps.buff(wl.spells.darkSoulKnowledge)'},
}

local demoSpellTable = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),

	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{wl.spells.lifeTap, 'jps.hp("player") > 0.6 and jps.mana() <= 0.3' },

	-- Soulstone
	wl.soulStone("target"),

	-- CD's
	{"nested", 'jps.demonicFury() >= 400', cdTable},
	{"nested", 'jps.buff(wl.spells.darkSoulKnowledge)', cdTable},
	
	{ wl.spells.grimoireFelguard,'jps.UseCDs'},

	{wl.spells.commandDemon, 'wl.hasPet() and jps.UseCDs'},

	-- rules for enter meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and IsAltKeyDown() == false', {
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 800'},
		{wl.spells.metamorphosis, 'IsShiftKeyDown() == true and IsControlKeyDown() == true'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 300 and jps.buff(wl.spells.darkSoulKnowledge)'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 420 and wl.hasProc(1)'},
		{wl.spells.metamorphosis, 'jps.myDebuffDuration(wl.spells.doom) < 15 and not jps.MultiTarget and jps.demonicFury() >= 350 and jps.combatTime() >= 9'},
	}},

	-- instant casts while moving
	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and not jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
	}},


	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.shadowBolt},
	}},


	--opener
	{"nested","jps.combatTime() < 10",{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
	}},
	
	-- single target without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2 and wl.hasProc(1)'},
	--	{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 1 and jps.buff(wl.spells.darkSoulKnowledge) and not jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 7  and not jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 3 and not jps.Moving'},
		{wl.spells.soulFire, 'jps.hp("target") < 0.25 and jps.buffStacks(wl.spells.moltenCore) >= 1 and not jps.Moving'},
		{wl.spells.shadowBolt,'not jps.Moving'},
	}},

	-- single target with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 40' },
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'IsShiftKeyDown() == true and IsAltKeyDown() == true' },
		--{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 300 and not wl.hasProc(1)' },
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) >= 1'},
		{wl.spells.shadowBolt, 'jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 1 and wl.hasProc(1) '},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 3'},
		{wl.spells.shadowBolt}, --touch of chaos
	}},

	-- aoe without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.metamorphosis, 'jps.demonicFury() > 800'},
		{wl.spells.hellfire, 'jps.hp() > 0.6'},
		{wl.spells.harvestLife},
	}},

	-- aoe with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.corruption, 'not jps.debuff(wl.spells.doom)'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.hellfire, 'not jps.buff(wl.spells.immolationAura)'},
		{wl.spells.carrionSwarm},
		{wl.spells.felFlame, 'jps.myDebuffDuration(wl.spells.corruption) < 4'},
		{wl.spells.chaosWave, 'jps.TimeToDie("target") < 13'},
		{wl.spells.felFlame, "onCD"},
	}},
}

jps.registerRotation("WARLOCK","DEMONOLOGY",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if IsAltKeyDown() == true and jps.CastTimeLeft("player") >= 0 and IsShiftKeyDown() == false then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() then
		jps.Cast("Shadowfury")
	end
	if UnitChannelInfo("player") == wl.spells.hellfire and jps.hp() < 0.59 then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	nextSpell,target  = parseStaticSpellTable(demoSpellTable)


	return nextSpell,target
end,"Demonology 6.0.2 Basic")


--[[[
@rotation Demonology 6.0.2 Advanced
@class warlock
@spec demonology
@description
Demo Rotation.<br>
ALT Key for instant casts.<br>
Shift+Control for enter meta at any time<br>
Shift+Alt to cancel meta<br>
Control for cataclysm
]]--



local cdTable = {
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge)' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{ wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.useTrinket(0) ~= ""  and jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.useTrinket(1) ~= ""  and  jps.UseCDs' },
	{ wl.spells.impSwarm , 'jps.UseCDs and jps.buff(wl.spells.darkSoulKnowledge)'},
}

local demoSpellTable = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),

	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{wl.spells.lifeTap, 'jps.hp("player") > 0.6 and jps.mana() <= 0.3' },

	-- Soulstone
	wl.soulStone("target"),


	-- CD's
	{"nested", 'jps.demonicFury() >= 350', cdTable},
	{"nested", 'jps.buff(wl.spells.darkSoulKnowledge)', cdTable},
	
	{ wl.spells.grimoireFelguard,'jps.UseCDs'},

	{wl.spells.commandDemon, 'wl.hasPet() and jps.UseCDs'},

	-- rules for enter meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and IsAltKeyDown() == false', {
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 800'},
		{wl.spells.metamorphosis, 'IsShiftKeyDown() == true and IsControlKeyDown() == true'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 300 and jps.buff(wl.spells.darkSoulKnowledge)'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 300 and wl.hasProc(4)'},
		{wl.spells.metamorphosis, 'jps.myDebuffDuration(wl.spells.doom) < 15 and not jps.MultiTarget and jps.demonicFury() >= 350'},
	}},

	-- instant casts while moving
	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and not jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
	}},

	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.shadowBolt},
	}},

	--opener
	{"nested","jps.combatTime() < 10",{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
	}},
	
	-- single target without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2 and wl.hasProc(1)'},
	--	{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 1 and jps.buff(wl.spells.darkSoulKnowledge) and not jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 4  and not jps.Moving'},
		{wl.spells.soulFire, 'jps.hp("target") < 0.25 and jps.buffStacks(wl.spells.moltenCore) >= 1 and not jps.Moving'},
		{wl.spells.shadowBolt,'not jps.Moving'},
	}},

	-- single target with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 40' },
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'IsShiftKeyDown() == true and IsAltKeyDown() == true' },
		--{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 300 and not wl.hasProc(1)' },
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) >= 1'},
		{wl.spells.shadowBolt, 'jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 2 and jps.buff(wl.spells.darkSoulKnowledge) and not jps.Moving'},
	--	{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 1 and wl.hasProc(1) '},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 7'},
		{wl.spells.shadowBolt}, --touch of chaos
	}},

	-- aoe without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.metamorphosis, 'jps.demonicFury() > 800'},
		{wl.spells.hellfire, 'jps.hp() > 0.6'},
		{wl.spells.harvestLife},
	}},

	-- aoe with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.corruption, 'not jps.debuff(wl.spells.doom)'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.hellfire, 'not jps.buff(wl.spells.immolationAura)'},
		{wl.spells.carrionSwarm},
		{wl.spells.felFlame, 'jps.myDebuffDuration(wl.spells.corruption) < 4'},
		{wl.spells.chaosWave, 'jps.TimeToDie("target") < 13'},
		{wl.spells.felFlame, "onCD"},
	}},
}

jps.registerRotation("WARLOCK","DEMONOLOGY",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if IsAltKeyDown() == true and jps.CastTimeLeft("player") >= 0 and IsShiftKeyDown() == false then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	if UnitChannelInfo("player") == wl.spells.hellfire and jps.hp() < 0.59 then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() then
		jps.Cast("Shadowfury")
	end
	
	nextSpell,target  = parseStaticSpellTable(demoSpellTable)
	return nextSpell,target
end,"Demonology 6.0.2 Advanced")



--[[[
@rotation Demonology 6.0.2 Advanced HoG
@class warlock
@spec demonology
@description
Demo Rotation.<br>
ALT Key for instant casts.<br>
Shift+Control for enter meta at any time<br>
Shift+Alt to cancel meta<br>
Control for cataclysm
]]--



local cdTable = {
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge)' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{ wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.useTrinket(0) ~= ""  and jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.useTrinket(1) ~= ""  and  jps.UseCDs' },
	{ wl.spells.impSwarm , 'jps.UseCDs and jps.buff(wl.spells.darkSoulKnowledge)'},
}

local demoSpellTable = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),

	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{wl.spells.lifeTap, 'jps.hp("player") > 0.6 and jps.mana() <= 0.3' },

	-- Soulstone
	wl.soulStone("target"),


	-- CD's
	{"nested", 'jps.demonicFury() >= 350', cdTable},
	{"nested", 'jps.buff(wl.spells.darkSoulKnowledge)', cdTable},
	
	{ wl.spells.grimoireFelguard,'jps.UseCDs'},

	{wl.spells.commandDemon, 'wl.hasPet() and jps.UseCDs'},

	-- rules for enter meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and IsAltKeyDown() == false', {
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 800'},
		{wl.spells.metamorphosis, 'IsShiftKeyDown() == true and IsControlKeyDown() == true'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 300 and jps.buff(wl.spells.darkSoulKnowledge)'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 300 and wl.hasProc(4)'},
		{wl.spells.metamorphosis, 'jps.myDebuffDuration(wl.spells.doom) < 15 and not jps.MultiTarget and jps.demonicFury() >= 350'},
	}},

	-- instant casts while moving
	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and not jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
	}},

	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and jps.buff(wl.spells.metamorphosis) and not IsShiftKeyDown()', {
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.shadowBolt},
	}},

	--opener
	{"nested","jps.combatTime() < 10",{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
	}},
	
	-- single target without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 1 and jps.buff(wl.spells.darkSoulKnowledge) and not jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 1 and wl.hasProc(1) '},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 4  and not jps.Moving'},
		{wl.spells.soulFire, 'jps.hp("target") < 0.25 and jps.buffStacks(wl.spells.moltenCore) >= 1 and not jps.Moving'},
		{wl.spells.shadowBolt,'not jps.Moving'},
	}},

	-- single target with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 40' },
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'IsShiftKeyDown() == true and IsAltKeyDown() == true' },
		--{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 300 and not wl.hasProc(1)' },
		{wl.spells.shadowBolt, 'jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 2 and jps.buff(wl.spells.darkSoulKnowledge) and not jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 1 and wl.hasProc(1) '},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 7'},
		{wl.spells.shadowBolt}, --touch of chaos
	}},

	-- aoe without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.metamorphosis, 'jps.demonicFury() > 800'},
		{wl.spells.hellfire, 'jps.hp() > 0.6'},
		{wl.spells.harvestLife},
	}},

	-- aoe with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.corruption, 'not jps.debuff(wl.spells.doom)'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.hellfire, 'not jps.buff(wl.spells.immolationAura)'},
		{wl.spells.carrionSwarm},
		{wl.spells.felFlame, 'jps.myDebuffDuration(wl.spells.corruption) < 4'},
		{wl.spells.chaosWave, 'jps.TimeToDie("target") < 13'},
		{wl.spells.felFlame, "onCD"},
	}},
}

jps.registerRotation("WARLOCK","DEMONOLOGY",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if IsAltKeyDown() == true and jps.CastTimeLeft("player") >= 0 and IsShiftKeyDown() == false then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	if UnitChannelInfo("player") == wl.spells.hellfire and jps.hp() < 0.59 then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() then
		jps.Cast("Shadowfury")
	end
	
	nextSpell,target  = parseStaticSpellTable(demoSpellTable)
	return nextSpell,target
end,"Demonology 6.0.2 Advanced HoG")
