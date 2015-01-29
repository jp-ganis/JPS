--[[@rotation Demonology 6.0.2 Basic
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
	{ {"macro","/use 13"}, 'jps.useEquipSlot(13) and jps.UseCDs'},
	{ {"macro","/use 14"}, 'jps.useEquipSlot(14) and jps.UseCDs'},
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
	{wl.spells.lifeTap, 'jps.hp("player") > 0.4 and jps.mana() <= 0.3' },

	-- Soulstone
	wl.soulStone("target"),

	-- CD's
	{"nested", 'jps.buff(wl.spells.metamorphosis)', cdTable},
	
	{ wl.spells.grimoireFelguard,'jps.UseCDs'},

	{wl.spells.commandDemon, 'wl.hasPet() and jps.UseCDs'},

	-- rules for enter meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and IsAltKeyDown() == false', {
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 880'},
		{wl.spells.metamorphosis, 'jps.demonicFury() >= 600  and jps.combatTime() < 25'},
	--	{wl.spells.metamorphosis, 'not IsAltKeyDown() == true and IsControlKeyDown() == true and not IsShiftKeyDown() == true'},
		{wl.spells.metamorphosis, 'jps.myDebuffDuration(wl.spells.doom) < 15 and not jps.MultiTarget and jps.demonicFury() >= 450 and jps.combatTime() < 20'},
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

	
	-- single target without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		jps.dotTracker.castTableStatic("corruption"),
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.handOfGuldan) >= 1 and jps.myDebuffDuration(wl.spells.handOfGuldan) < 4'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 2'},
		{wl.spells.shadowBolt},
	}},

	-- single target with meta
	{"nested", 'jps.buff(wl.spells.metamorphosis) and not jps.MultiTarget',{
		{wl.spells.corruption, 'jps.myDebuffDuration(wl.spells.doom) < 18'},
		{wl.spells.corruption, 'wl.shouldMouseoverDoom()',"mouseover"},
		{wl.spells.demonBolt, 'jps.debuffStacks(wl.spells.demonBolt,"player") < 4'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) >= 1'},
		--{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 200' },
		{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'IsShiftKeyDown() == true and IsControlKeyDown() == true and not IsAltKeyDown() == true' },
		--{ {"macro","/cancelaura " .. wl.spells.metamorphosis}, 'jps.demonicFury() <= 300 and not wl.hasProc(1)' },
		{wl.spells.shadowBolt, 'jps.Moving'},
		{wl.spells.soulFire, 'jps.buffStacks(wl.spells.moltenCore) >= 1'},
		{wl.spells.shadowBolt}, --touch of chaos
	}},

	-- aoe without meta
	{"nested", 'not jps.buff(wl.spells.metamorphosis) and jps.MultiTarget',{
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 2'},
		{wl.spells.handOfGuldan, 'select(1,GetSpellCharges(wl.spells.handOfGuldan)) == 1 and jps.myDebuffDuration(wl.spells.handOfGuldan) >= 2 and jps.myDebuffDuration(wl.spells.handOfGuldan) < 4'},
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
		{wl.spells.chaosWave, 'jps.demonicFury() > 500'},
		{wl.spells.chaosWave, 'jps.TimeToDie("target") < 13'},
	}},
}

jps.registerRotation("WARLOCK","DEMONOLOGY",function()
	wl.deactivateBurningRushIfNotMoving(1)
	
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() and not IsControlKeyDown() == true then
		jps.Cast("Shadowfury")
	end
	
	if IsAltKeyDown() == true and jps.CastTimeLeft("player") >= 0 and IsShiftKeyDown() == false then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	if UnitChannelInfo("player") == wl.spells.hellfire and jps.hp() < 0.59 then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	if jps.IsSpellKnown(wl.spells.cataclysm) and jps.cooldown(wl.spells.cataclysm) == 0 and IsShiftKeyDown() and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() then
		jps.Cast(wl.spells.cataclysm)
	end --spells out of spelltable are currently necessary when they come from talents :(
	

	
	nextSpell,target  = parseStaticSpellTable(demoSpellTable)
	return nextSpell,target
end,"Demonology 6.0.2 Advanced")



--[[

warlockdemonology = {}

warlockdemonology.archimondesDarkness = "archimondes darkness";
warlockdemonology.cancelMetamorphosis = {"macro","/cancelaura " .. wl.spells.metamorphosis}
warlockdemonology.chaosWave = "chaos wave";
warlockdemonology.corruption = "corruption";
warlockdemonology.darkIntent = "dark intent";
warlockdemonology.darkSoul = "dark soul";
warlockdemonology.demonbolt = "demonbolt";
warlockdemonology.demonicFury = jps.demonicFury();
warlockdemonology.demonicServitude = "demonic servitude";
warlockdemonology.doom = "doom";
warlockdemonology.executeTime = "execute time";
warlockdemonology.grimoireOfSacrifice = "grimoire of sacrifice";
warlockdemonology.grimoireOfService = "grimoire of service";
warlockdemonology.hellfire = "hellfire";
warlockdemonology.immolationAura = "immolation aura";
warlockdemonology.interrupt = "interrupt";
warlockdemonology.kiljaedensCunning = "kiljaedens cunning";
warlockdemonology.lifeTap = "life tap";
warlockdemonology.metamorphosis = "metamorphosis";
warlockdemonology.metamorphosis = "metamorphosis";
warlockdemonology.moltenCore = "molten core";
warlockdemonology.servicePet = "service pet";
warlockdemonology.shadowBolt = "shadow bolt";
warlockdemonology.sleeperSurprise = "sleeper surprise";
warlockdemonology.soulFire = "soul fire";
warlockdemonology.spellPowerMultiplier = "spell power multiplier";
warlockdemonology.summonDoomguard = "summon doomguard";
warlockdemonology.summonInfernal = "summon infernal";
warlockdemonology.summonPet = "summon pet";
warlockdemonology.touchOfChaos = "touch of chaos";
warlockdemonology.shadowflame = "Hand of Gul'dan";

warlockdemonology.spellHaste = UnitSpellHaste("player")


local cdTable = {
	{ {"macro","/cast " .. wl.spells.darkSoulKnowledge}, 'jps.cooldown(wl.spells.darkSoulKnowledge) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulKnowledge)' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{ wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.useTrinket(0) ~= ""  and jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.useTrinket(1) ~= ""  and  jps.UseCDs' },
	{ wl.spells.impSwarm , 'jps.UseCDs and jps.buff(wl.spells.darkSoulKnowledge)'},
}

if jps.TimeToDie == nil then
	jps.TimeToDie = function(unit) end	
end


warlockdemonology.shouldDarkSoulNoDemonbolt = function()

	if not jps.talentInfo(warlockdemonology.demonbolt) and select(1,GetSpellCharges(warlockdemonology.darkSoul))==2 or not jps.talentInfo(warlockdemonology.archimondesDarkness) or (jps.TimeToDie("target") <= 20 and  not jps.glyphInfo(warlockdemonology.darkSoul) or jps.TimeToDie("target") <= 10) or (jps.TimeToDie("target") <= 60 and warlockdemonology.demonicFury() > 400) or (wl.hasProc(1) and warlockdemonology.demonicFury() >= 400) then
		return true
	end
	return false
end

warlockdemonology.demonicFury = function()
	return jps.demonicFury()
end


-- so there are some problems:

-- 2) we need a wow api function for spellhaste

warlockdemonology.shouldCancelMeta = function()
	local shouldCancel = false
		if not jps.buff(warlockdemonology.metamorphosis) then return false end
		if ((warlockdemonology.demonicFury() < 650 and  not jps.glyphInfo(warlockdemonology.darkSoul)) or warlockdemonology.demonicFury() < 450) and not jps.buff(warlockdemonology.darkSoul) and (not wl.hasProc(1) or warlockdemonology.demonicFury() < (800-jps.cooldown(warlockdemonology.darkSoul)*(10%warlockdemonology.spellHaste))) and jps.TimeToDie("target") > 20 then
			shouldCancel = true
		elseif warlockdemonology.charges(warlockdemonology.handOfGuldan) > 0 and jps.myDebuffDuration(warlockdemonology.shadowflame) < jps.spellCastTime(warlockdemonology.shadowBolt) and warlockdemonology.demonicFury() < 100 and jps.buffDuration(warlockdemonology.darkSoul) > 10 then
			shouldCancel = true
		elseif warlockdemonology.charges(warlockdemonology.handOfGuldan)==3 and (jps.buffDuration(warlockdemonology.darkSoul) < 1 or jps.cooldown(warlockdemonology.metamorphosis) < 1) then
			shouldCancel = true
		end
	return shouldCancel
end


warlockdemonology.shouldMetaDB = function()

	if jps.buffDuration(warlockdemonology.darkSoul) > 1 and warlockdemonology.demonicFury() >= 240 and (not jps.buff(warlockdemonology.demonbolt) or jps.TimeToDie("target") < jps.debuffDuration(warlockdemonology.demonbolt,"player") or (jps.buffDuration(warlockdemonology.darkSoul) > 3 and warlockdemonology.demonicFury() >= 175)) then 
		return true 
	end
--	if not jps.debuff(warlockdemonology.demonbolt,"player") and warlockdemonology.demonicFury() >= 480 and (action.warlockdemonology.darkSoul.select(1,GetSpellCharges(warlockdemonology.metamorphosis))==0 or  not jps.talentInfo(warlockdemonology.archimondesDarkness) and jps.cooldown(warlockdemonology.darkSoul)) then 
	--	return true 
--	end
	 
	if (warlockdemonology.demonicFury()/80)*2 >= jps.TimeToDie("target") and jps.TimeToDie("target") < jps.debuffDuration(warlockdemonology.demonbolt,"player") then
		return true
	end
	
	if jps.TimeToDie("target") >= 30 and not jps.myDebuff(warlockdemonology.doom) and not jps.buff(warlockdemonology.darkSoul) then
		return true
	end
	
	if warlockdemonology.demonicFury() > 750 and jps.debuffDuration(warlockdemonology.demonbolt,"player") >= jps.cooldown(warlockdemonology.metamorphosis) then
		return true
	end
	
	if (((warlockdemonology.demonicFury()-120)/800) > (jps.debuffDuration(warlockdemonology.demonbolt,"player")%(40*warlockdemonology.spellHaste))) and jps.debuffDuration(warlockdemonology.demonbolt,"player") >= 10 and jps.myDebuffDuration(warlockdemonology.doom) <= dot.warlockdemonology.doom.duration*0.3 then
		return true
	end
	return false
end


	
	meta:
	HoG  = Chaos Wave
	Corruption = Doom
	Hellfire = Immolation Aura
	Shadow Bolt = Touch of Chaos
	
	t17 set bonus:
	2pc: Hand of Gul'dan has a 50% chance empower your inner demon, temporarily bringing your Metamorphosis form out even while you are not transformed
	4pc: Hand of Gul'dan now has 1 additional maximum charge, and Corruption has a 2% chance to generate 1 charge of Hand of Gul'dan when dealing damage
	
	


jps.diff = function(v1,v2)
	return v1/v2
end
warlockdemonology.charges = function(spell)
	return select(1,GetSpellCharges(spell))
end

warlockdemonologyDemonBoltTable = {
	{warlockdemonology.immolationAura, 'warlockdemonology.demonicFury() > 450 and jps.MultiTarget and not jps.buff(warlockdemonology.immolationAura)'},
	{warlockdemonology.doom, 'jps.buff(warlockdemonology.metamorphosis) and jps.MultiTarget and jps.TimeToDie("target") >= jps.myDebuffDuration(warlockdemonology.doom,"target") and not jps.buff(warlockdemonology.darkSoul)'},
	{warlockdemonology.doom, 'jps.buff(warlockdemonology.metamorphosis) and jps.MultiTarget and jps.TimeToDie("target") >= jps.myDebuffDuration(warlockdemonology.doom,"target") and not jps.glyphInfo(warlockdemonology.darkSoul)'},
	
	{warlockdemonology.demonbolt, 'jps.debuffStacks(warlockdemonology.demonbolt,"player")==0'},
	{warlockdemonology.demonbolt, 'jps.debuffStacks(warlockdemonology.demonbolt,"player") < 4'},
	{warlockdemonology.corruption, 'jps.TimeToDie("target") >= 6 and jps.myDebuffDuration(warlockdemonology.corruption) < 4 and not jps.buff(warlockdemonology.metamorphosis)'},
	{warlockdemonology.cancelMetamorphosis, 'jps.buff(warlockdemonology.metamorphosis) and jps.debuffStacks(warlockdemonology.demonbolt,"player") > 3 and warlockdemonology.demonicFury() <= 600 and jps.TimeToDie("target") > jps.debuffDuration(warlockdemonology.demonbolt,"player") and not jps.buff(warlockdemonology.darkSoul)'},
	{warlockdemonology.chaosWave, 'jps.buff(warlockdemonology.metamorphosis) and jps.buff(warlockdemonology.darkSoul) and jps.MultiTarget and warlockdemonology.demonicFury() > 450'},

	{warlockdemonology.soulFire, 'jps.buff(warlockdemonology.metamorphosis) and jps.buff(warlockdemonology.moltenCore) and jps.buffDuration(warlockdemonology.darkSoul) > jps.spellCastTime(warlockdemonology.soulFire) and warlockdemonology.demonicFury() >= 175'},
	{warlockdemonology.soulFire, 'jps.buff(warlockdemonology.metamorphosis) and jps.buff(warlockdemonology.moltenCore) and jps.TimeToDie("target") < jps.debuffDuration(warlockdemonology.demonbolt,"player")'},
--actions.db+=/soul_fire,if=buff.metamorphosis.up&buff.molten_core.react&(((buff.dark_soul.remains>execute_time)&demonic_fury>=175)|(target.time_to_die<buff.demonbolt.remains))
--actions.db+=/soul_fire,if=buff.metamorphosis.up&buff.molten_core.react&target.health.pct<=25&(((demonic_fury-80)%800)>(buff.demonbolt.remains%(40*spell_haste)))&demonic_fury>=750

--{warlockdemonology.soulFire, 'jps.buff(warlockdemonology.metamorphosis) and jps.buff(warlockdemonology.moltenCore) and jps.hp("target") <= 0.25 and (((warlockdemonology.demonicFury()-80)%800) > (jps.debuffDuration(warlockdemonology.demonbolt,"player")%(40*warlockdemonology.spellHaste))) and warlockdemonology.demonicFury() >= 750'},

	{warlockdemonology.touchOfChaos, 'jps.buff(warlockdemonology.metamorphosis) and jps.myDebuffDuration(warlockdemonology.corruption) < 17 and warlockdemonology.demonicFury() > 750'},
	{warlockdemonology.touchOfChaos, 'jps.buff(warlockdemonology.metamorphosis) and jps.TimeToDie("target") < jps.debuffDuration(warlockdemonology.demonbolt,"player")'},
	{warlockdemonology.touchOfChaos, 'jps.buff(warlockdemonology.metamorphosis) and warlockdemonology.demonicFury() >= 750 and jps.debuffDuration(warlockdemonology.demonbolt,"player") > '},
	
--	{warlockdemonology.touchOfChaos, 'jps.buff(warlockdemonology.metamorphosis) and (((warlockdemonology.demonicFury()-40)%800) > (jps.debuffDuration(warlockdemonology.demonbolt,"player")%(40*warlockdemonology.spellHaste))) and warlockdemonology.demonicFury() >= 750'},
	--actions.db+=/touch_of_chaos,cycle_targets=1,if=buff.metamorphosis.up&dot.corruption.remains<17.4&demonic_fury>750
	--actions.db+=/touch_of_chaos,if=buff.metamorphosis.up&(target.time_to_die<buff.demonbolt.remains|demonic_fury>=750&buff.demonbolt.remains)
	--actions.db+=/touch_of_chaos,if=buff.metamorphosis.up&(((demonic_fury-40)%800)>(buff.demonbolt.remains%(40*spell_haste)))&demonic_fury>=750
	





	{warlockdemonology.cancelMetamorphosis, 'onCD'},
	{warlockdemonology.soulFire, 'jps.buff(warlockdemonology.moltenCore) and (jps.buffDuration(warlockdemonology.darkSoul) < jps.spellCastTime(warlockdemonology.shadowBolt) or jps.buffDuration(warlockdemonology.darkSoul) > jps.CastTimeLeft("player"))'},
	{warlockdemonology.lifeTap, 'jps.Mana() < 40'},
	{warlockdemonology.shadowBolt, 'onCD'},
	{warlockdemonology.hellfire, 'jps.MultiTarget'},
}

warlockdemonologyspellTable = {

	{"nested",'jps.UseCDs',{
		{jps.getDPSRacial(), 'onCD'},
		{warlockdemonology.mannorothsFury, 'onCD'},
		{warlockdemonology.darkSoul, 'jps.talentInfo(warlockdemonology.demonbolt) and (jps.TimeToDie("target") < jps.debuffDuration(warlockdemonology.demonbolt,"player")'},
		{warlockdemonology.darkSoul, 'jps.talentInfo(warlockdemonology.demonbolt) and warlockdemonology.charges(warlockdemonology.darkSoul)==2'},
		{warlockdemonology.darkSoul, 'jps.talentInfo(warlockdemonology.demonbolt) and jps.debuffDuration(warlockdemonology.demonbolt,"player") == 0 and warlockdemonology.demonicFury() >= 790)'},
		{warlockdemonology.darkSoul, 'warlockdemonology.shouldDarkSoulNoDemonbolt()'},

		{warlockdemonology.impSwarm, 'jps.buff(warlockdemonology.darkSoul) and jps.combatTime() > 3'},
		{warlockdemonology.impSwarm, 'jps.cooldown(warlockdemonology.darkSoul) > jps.TimeToDie("target")'}, -- not everything can be perfect:P

	--	{felguard:felstorm, 'onCD'},
	--	{wrathguard:wrathstorm, 'onCD'},  -- we look later into this
	}},

	--this look shit lets do the easy work first 
	{warlockdemonology.handOfGuldan, ', and jps.myDebuffDuration(warlockdemonology.shadowflame) < jps.spellCastTime(warlockdemonology.shadowBolt) and (((warlockdemonology.setBonus.tier174warlockdemonology.pc==0 and (warlockdemonology.charges(warlockdemonology.handOfGuldan)==1 and rechargetime < 4) or warlockdemonology.charges(warlockdemonology.handOfGuldan)==2) or (warlockdemonology.charges(warlockdemonology.handOfGuldan)==3 or (warlockdemonology.charges(warlockdemonology.handOfGuldan)==2 and rechargetime < 13.8-1*2)) and (jps.cooldown(warlockdemonology.cataclysm) > dot.warlockdemonology.shadowflame.duration or  not jps.talentInfo(warlockdemonology.cataclysm)) and jps.cooldown(warlockdemonology.darkSoul) > dot.warlockdemonology.shadowflame.duration) or jps.myDebuffDuration(warlockdemonology.shadowflame) > 1)'},
	{warlockdemonology.handOfGuldan, ', and jps.myDebuffDuration(warlockdemonology.shadowflame) < jps.spellCastTime(warlockdemonology.shadowBolt) and jps.talentInfo(warlockdemonology.demonbolt) and ((warlockdemonology.setBonus.tier174warlockdemonology.pc==0 and ((warlockdemonology.charges(warlockdemonology.handOfGuldan)==1 and rechargetime < 4) or warlockdemonology.charges(warlockdemonology.handOfGuldan)==2)) or (warlockdemonology.charges(warlockdemonology.handOfGuldan)==3 or (warlockdemonology.charges(warlockdemonology.handOfGuldan)==2 and rechargetime < 13.8-1*2)) or jps.myDebuffDuration(warlockdemonology.shadowflame) > 1)'},
	{warlockdemonology.handOfGuldan, ', and jps.myDebuffDuration(warlockdemonology.shadowflame) < 3 and jps.debuffDuration(warlockdemonology.demonbolt,"player") < 1*2 and warlockdemonology.charges(warlockdemonology.handOfGuldan) >= 2 and action.warlockdemonology.darkSoul.warlockdemonology.charges(warlockdemonology.handOfGuldan) >= 1'},

	{warlockdemonology.servicePet, 'jps.talentInfo(warlockdemonology.grimoireOfService) and wl.hasPet()'},
	{"nested", 'jps.talentInfo(warlockdemonology.demonbolt)' , warlockdemonologyDemonBoltTable},

	{warlockdemonology.kiljaedenscunning, 'not jps.cooldown(warlockdemonology.cataclysm) and jps.buff(warlockdemonology.metamorphosis) and jps.talentInfo(warlockdemonology.kiljaedenscunning)'},
	{warlockdemonology.cataclysm, 'jps.buff(warlockdemonology.metamorphosis) '} , --- later this spell needs a key modifier because it is a ground spell
	
	{warlockdemonology.immolationaura, 'warlockdemonology.demonicFury() > 450 and jps.MultiTarget and not jps.buff(immolationaura)'},
	{warlockdemonology.doom, 'jps.buff(warlockdemonology.metamorphosis) and jps.TimeToDie("target") >= jps.myDebuffDuration(warlockdemonology.doom,"target") and (remains < jps.cooldown(warlockdemonology.cataclysm) or  not jps.talentInfo(warlockdemonology.cataclysm)) and (not jps.buff(warlockdemonology.darkSoul) or  not jps.glyphInfo(warlockdemonology.darkSoul)) and trinket.warlockdemonology.stackingProc.multistrike.react < 10'}, --this is shit simcraft logic... let's make this easier
	
	-- doom
	{warlockdemonology.corruption, 'jps.buff(warlockdemonology.metamorphosis) and jps.myDebuffDuration(warlockdemonology.doom) < jps.TimeToDie("target")'}, -- we should always keep doom up
	{warlockdemonology.corruption, 'jps.buff(warlockdemonology.metamorphosis) and jps.myDebuffDuration(warlockdemonology.doom) < jps.cooldown(warlockdemonology.cataclysm) and jps.talentInfo(warlockdemonology.cataclysm)'}, -- so we don't run out of doom during casting cataclysm

	{"nested",  'jps.buff(warlockdemonology.metamorphosis)' , {  -- we need this hack because for simcraft doom = corruption due the spell id system / change of spells
		jps.dotTracker.castTableStatic("corruption"), --corruption multi target
	}},
	
	-- cancel meta, let's do a function for this shit
	{warlockdemonology.cancelMetamorphosis, 'warlockdemonology.shouldCancelMeta()'},
	{{"macro", "/cancelaura "..warlockdemonology.hellfire},'not jps.MultiTarget'},

	{warlockdemonology.chaoswave, 'jps.buff(warlockdemonology.metamorphosis) and (jps.buff(warlockdemonology.darkSoul) and jps.MultiTarget or (select(1,GetSpellCharges(chaoswave))==3 or warlockdemonology.setBonus.tier174warlockdemonology.pc==0 and select(1,GetSpellCharges(chaoswave))==2))'},
	{warlockdemonology.soulFire, 'jps.buff(warlockdemonology.metamorphosis) and jps.buff(moltencore) and (jps.buffDuration(warlockdemonology.darkSoul) > executetime or jps.hp("target") <= 25) and (((jps.buffStacks(moltencore)*executetime >= trinket.warlockdemonology.stackingProc.multistrike.remains-1 or warlockdemonology.demonicFury() <= ceil((trinket.warlockdemonology.stackingProc.multistrike.remains-jps.buffStacks(moltencore)*executetime)*40)+80*jps.buffStacks(moltencore)) or jps.hp("target") <= 25) and trinket.warlockdemonology.stackingProc.multistrike.remains >= executetime or trinket.warlockdemonology.stackingProc.multistrike.down or  not trinket.haswarlockdemonology.stackingProc.multistrike)'},
	{warlockdemonology.touchofchaos, 'jps.buff(warlockdemonology.metamorphosis) and jps.myDebuffDuration(warlockdemonology.corruption) < 17.4 and warlockdemonology.demonicFury() > 750'},
	{warlockdemonology.touchofchaos, 'jps.buff(warlockdemonology.metamorphosis)'},

	{warlockdemonology.metamorphosis, 'jps.buffDuration(warlockdemonology.darkSoul) > 1 and (warlockdemonology.demonicFury() > 300 or  not jps.glyphInfo(warlockdemonology.darkSoul)) and (warlockdemonology.demonicFury() >= 80 and jps.buffStacks(moltencore) >= 1 or warlockdemonology.demonicFury() >= 40)'},
	{warlockdemonology.metamorphosis, '(trinket.warlockdemonology.stackingProc.multistrike.react or trinket.proc.any.react) and ((warlockdemonology.demonicFury() > 450 and action.warlockdemonology.darkSoul.rechargetime >= 10 and jps.glyphInfo(warlockdemonology.darkSoul)) or (warlockdemonology.demonicFury() > 650 and jps.cooldown(warlockdemonology.darkSoul) >= 10))'},
	{warlockdemonology.metamorphosis, 'not jps.cooldown(warlockdemonology.cataclysm) and jps.talentInfo(warlockdemonology.cataclysm)'},
	{warlockdemonology.metamorphosis, 'not jps.myDebuff(warlockdemonology.doom) and jps.TimeToDie("target") >= 30%(1%warlockdemonology.spellHaste) and warlockdemonology.demonicFury() > 300'},
	{warlockdemonology.metamorphosis, '(warlockdemonology.demonicFury() > 750 and (action.warlockdemonology.handOfGuldan.select(1,GetSpellCharges(warlockdemonology.metamorphosis))==0 or ( not jps.myDebuff(warlockdemonology.shadowflame) and  not action.warlockdemonology.handOfGuldan.inflighttotarget))) or floor(warlockdemonology.demonicFury()%80)*action.warlockdemonology.soulFire.executetime >= jps.TimeToDie("target")'},
	{warlockdemonology.metamorphosis, 'warlockdemonology.demonicFury() >= 950'},
	
	-- dont know if this is good... we need to check this later ingame
	{warlockdemonology.cancelMetamorphosis},

	--the cancel function comes at another point
	{warlockdemonology.hellfire, 'jps.MultiTarget'},
	{warlockdemonology.soulFire, 'jps.buff(moltencore) and (jps.buffStacks(moltencore) >= 7 or jps.hp("target") <= 25 or (jps.buffDuration(warlockdemonology.darkSoul) and jps.cooldown(warlockdemonology.metamorphosis) > jps.buffDuration(warlockdemonology.darkSoul)) or trinket.proc.any.remains > executetime or trinket.warlockdemonology.stackingProc.multistrike.remains > executetime) and (jps.buffDuration(warlockdemonology.darkSoul) < jps.spellCastTime(warlockdemonology.shadowBolt) or jps.buffDuration(warlockdemonology.darkSoul) > executetime)'},
	{warlockdemonology.soulFire, 'jps.buff(moltencore) and jps.TimeToDie("target") < (time+jps.TimeToDie("target"))*0.25+jps.cooldown(warlockdemonology.darkSoul)'},
	{lifetap, 'jps.Mana() < 40'},
	{warlockdemonology.shadowBolt, 'onCD'},



}

jps.registerRotation("WARLOCK","DEMONOLOGY",function()
	local spell = nil
	local target = nil
	
	-- add here cancel hellfire stuff
	
	spell,target = parseStaticSpellTable(warlockdemonologyspellTable)
	return spell,target
end, "Simcraft Warlock-DEMONOLOGY")

]]--
