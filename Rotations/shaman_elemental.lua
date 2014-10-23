--[[[
@rotation Default
@class SHAMAN
@spec ELEMENTAL
@talents W!22020. & PCMD
@author duplicate
@description
Updated for MoP
]]--

function weaponMainhandEnchant()
	return select(1, GetWeaponEnchantInfo())
end


function totemDuration(totemId)
	-- 1 = fire
	-- 2 = earth
	-- 3 = water
	-- 4 = air
	local haveTotem, totemName, startTime, duration = GetTotemInfo(totemId) 
	if not haveTotem then return 0 end
	return GetTime() - (startTime+duration)
end

local deactivateGhostWolfNotMovingSeconds = 0
function deactivateGhostWolfNotMoving(seconds)
	if not seconds then seconds = 0 end
	if jps.Moving or not jps.buff("Ghost Wolf") then
		deactivateGhostWolfNotMovingSeconds = 0
	else
		if deactivateGhostWolfNotMovingSeconds >= seconds then
			RunMacroText("/cancelaura Ghost Wolf")
		else
			deactivateGhostWolfNotMovingSeconds = deactivateGhostWolfNotMovingSeconds + jps.UpdateInterval
		end
	end
end

shaman = {}
shaman.got4pcT17 = false;
shaman.got4PCT16 = false;
shaman.ancestralswiftness = "ancestral swiftness";
shaman.arcanetorrent = "arcane torrent";
shaman.ascendance = "ascendance";
shaman.bloodfury = "blood fury";
shaman.bloodlust = "bloodlust";
shaman.callactionlist = "call action list";
shaman.chainlightning = "chain lightning";
shaman.cooldownremains = "cooldown remains";
shaman.earthshock = "earth shock";
shaman.elementalblast = "elemental blast";
shaman.elementalmastery = "elemental mastery";
shaman.enhancedchainlightning = "enhanced chain lightning";
shaman.fireelementaltotem = "fire elemental totem";
shaman.flameshock = "flame shock";
shaman.jadeserpent = "jade serpent";
shaman.lavabeam = "lava beam";
shaman.lavaburst = "lava burst";
shaman.lavasurge = "lava surge";
shaman.lightningbolt = "lightning bolt";
shaman.lightningshield = "lightning shield";
shaman.liquidmagma = "liquid magma";
shaman.masteryvalue = "mastery value";
shaman.maxstack = "max stack";
shaman.multistrikepct = "multistrike pct";
shaman.name = "name";
shaman.pccaster = "pc caster";
shaman.searingtotem = "searing totem";
shaman.setbonus = "set bonus";
shaman.spellhaste = "spell haste";
shaman.spiritwalkersgrace = "spiritwalker's grace";
shaman.stormelementaltotem = "storm elemental totem";
shaman.unleashedfury = "unleashed fury";
shaman.unleashflame = "unleash flame";
shaman.windshear = "wind shear";
shaman.astralshift = "Astral Shift";
shaman.shamanisticrage = "Shamanistic Rage";
shaman.healingstreamtotem = "Healing Stream Totem";
shaman.earthquake = "Earthquake";

local spellTable = {


-- cooldowns
	{windShear, 'jps.shouldKick("target")' },
	{windShear, 'jps.shouldKick("focus")' },
	{shaman.hex, 'keyPressed("shift","alt") and jps.canDPS("mouseover")' , 'mouseover' },
	{shaman.lightningshield,'not jps.buff(shaman.lightningshield)' },

	--{ "Earth Elemental Totem", 'jps.UseCDs and jps.bloodlusting()' },
	{"nested","jps.UseCDs",{
		{shaman.berserking, 'not jps.bloodlusting() and not jps.buff(shaman.elementalmastery) and jps.buffDuration(shaman.ascendance) == 0 and jps.myDebuffDuration(shaman.flameshock) > jps.buffDuration(shaman.ascendance)' },
		{shaman.bloodfury, 'jps.bloodlusting()' },
		{shaman.bloodfury, 'jps.buff(shaman.ascendance)' },
		{shaman.bloodfury, 'jps.cooldown(shaman.ascendance) > 10 and jps.cooldown(shaman.fireelementaltotem) > 10' },
		{shaman.elementalmastery, 'jps.spellCastTime(shaman.lavaburst) >= 1.2' },
		{shaman.stormelementaltotem, 'totemDuration(4) == 0' },
		{shaman.fireelementaltotem, 'totemDuration(1) == 0'},
		{shaman.ascendance, 'jps.myDebuffDuration(shaman.flameshock) > 15 and jps.cooldown(shaman.lavaburst) > 0' },
		{ jps.useTrinket(0),'jps.useTrinket(0) ~= ""'},
		{ jps.useTrinket(1),'jps.useTrinket(1) ~= ""'},
		{ shaman.lifeblood},
	}},
	
	{"nested","jps.Defensive",{
		{shaman.astralshift, 'jps.hp() < 0.35'},
		{shaman.shamanisticrage, 'jps.hp() < 0.55'},
		{shaman.healingsurge, 'jps.hp() < 0.35 and not jps.Moving' },
		{shaman.healingstreamtotem, 'jps.Defensive and totemDuration(3) == 0'},
	}},

	{shaman.ancestralswiftness, 'not jps.buff(shaman.ascendance)' },
	{shaman.searingtotem, 'not jps.talentInfo(shaman.liquidmagma) and totemDuration(1) == 0' },
	{shaman.liquidmagma, 'totemDuration(1) >= 15' },

	-- multitarget target, remove if empty

	{shaman.earthquake, "IsShiftKeyDown() == true  and not jps.Moving"},
	{'nested' , 'jps.MultiTarget', {
		{shaman.lavabeam, 'onCD' },
		{shaman.earthshock, 'jps.buff(shaman.lightningshield) == 15' },
--		{shaman.thunderstorm, 'onCD' },
		{shaman.chainlightning, 'onCD' },
		{shaman.lightningbolt, 'onCD' },
	}},

	-- single target, remove if empty

	{'nested' , 'not jps.MultiTarget', {
		{shaman.spiritwalkersgrace,' jps.Moving and jps.talentInfo(shaman.elementalblast) and jps.cooldown(shaman.elementalblast)==0' },
		{shaman.spiritwalkersgrace,' jps.Moving and jps.cooldown(shaman.lavaburst)==0 and not jps.buff(shaman.lavasurge)' },
		{shaman.unleashflame, 'jps.talentInfo(shaman.unleashedfury) and not jps.buff(shaman.ascendance)' },
		{shaman.spiritwalkersgrace,' jps.Moving and jps.buff(shaman.ascendance)' },
		{shaman.lavaburst, 'jps.myDebuffDuration(shaman.flameshock) > jps.spellCastTime(shaman.lavaburst)' },
		{shaman.flameshock, 'jps.myDebuffDuration(shaman.flameshock) <= 9' },
		{shaman.elementalblast, 'onCD' },
		{shaman.earthshock, 'jps.buffDuration(shaman.lightningshield) >= 12' },
		{shaman.flameshock, 'jps.myDebuffDuration(shaman.flameshock) <= 15' },
		{shaman.lightningbolt, 'onCD' },
	}},
}

jps.registerRotation("SHAMAN","ELEMENTAL",function()
local spell = nil
local target = nil
	
spell,target = parseStaticSpellTable(spellTable)

deactivateGhostWolfNotMoving(1)

if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
	SpellStopCasting()
	jps.NextSpell = nil
end

return spell,target
end, "Simcraft Shaman-ELEMENTAL")