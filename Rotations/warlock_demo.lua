-- TO-DO : simcraft this
--[[[
@rotation Demonology 6.0.2 T16 PVE
@class warlock
@spec demonology
@description
Demo Rotation.<br>
ALT Key for instant casts.<br>
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

	-- Shadowfury
	{wl.spells.shadowfury, 'IsShiftKeyDown() == true and GetCurrentKeyBoardFocus() == nil' },

	-- CD's
	{"nested", 'jps.demonicFury() >= 400', {
		{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge)' },
		{ jps.getDPSRacial(), 'jps.UseCDs' },
		{ wl.spells.lifeblood, 'jps.UseCDs' },
		{ jps.useTrinket(0),	   'jps.useTrinket(0) ~= ""  and jps.UseCDs' },
		{ jps.useTrinket(1),	   'jps.useTrinket(1) ~= ""  and  jps.UseCDs' },
		{ wl.spells.impSwarm , 'jps.UseCDs and jps.buff(wl.spells.darkSoulKnowledge)'},
	}},
	
	{ wl.spells.grimoireFelguard,'jps.UseCDs'},

	{wl.spells.commandDemon, 'wl.hasPet() and jps.UseCDs'},

	-- rules for enter meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis)', {
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 950'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 300 and jps.buffDuration(wl.spells.darkSoulKnowledge) > 2'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 450 and wl.hasProc(1)'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 400 and wl.hasProc(2)'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 400 and jps.cooldown("Cataclysm") == 0'},
		{wl.spells.metamorphosis, 'jps.myDebuffDuration(wl.spells.doom) < 15 and not jps.MultiTarget and jps.demonicFury() >= 300'},
	}},

	-- instant casts while moving
	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and not jps.buff(wl.spells.metamorphosis)', {
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
	}},


	{"nested", 'not jps.MultiTarget and IsAltKeyDown() and jps.buff(wl.spells.metamorphosis)', {
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.shadowBolt},
	}},

	-- single target without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.shadowflame) >= 2 and jps.myDebuffDuration(wl.spells.shadowflame) < 4'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 2 '},
		{wl.spells.soulFire, 'jps.hp("target") < 0.25 and jps.buffStacks(wl.spells.moltenCore) >= 1'},
		{wl.spells.shadowBolt},
	}},

	-- single target with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 15'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.cataclysm,"IsControlKeyDown() and GetCurrentKeyBoardFocus() == nil"},
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 100' },
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 300 and not wl.hasProc(1)' },
		{wl.spells.shadowBolt, 'jps.myDebuffDuration(wl.spells.corruption) < 5'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 1 and wl.hasProc(1)'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) > 1 and jps.hp("target") < 0.25'},
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

	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	if UnitChannelInfo("player") == wl.spells.hellfire and jps.hp() < 0.59 then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	return parseStaticSpellTable(demoSpellTable)
end,"Demonology 6.0.2 T16")
