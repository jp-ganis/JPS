--TO DO : tranquility detection

if not druid then druid = {} end
function toSpellName(id) name = GetSpellInfo(id); return name end
if not druid.spells then druid.spells = {} end
druid.spells["removeCorruption"] = toSpellName(2782)
druid.spells["naturesCure"] = toSpellName(88423)
druid.spells["rebirth"] = toSpellName(20484)
druid.spells["markOfTheWild"] = toSpellName(1126)
druid.spells["barkskin"] = toSpellName(22812)
druid.spells["incarnation"] = toSpellName(33891)
druid.spells["lifebloom"] = toSpellName(33763)
druid.spells["swiftmend"] = toSpellName(18562)
druid.spells["wildGrowth"] = toSpellName(48438)
druid.spells["rejuvination"] = toSpellName(774)
druid.spells["germinationTalent"] = toSpellName(155675)
druid.spells["rejuvenationGermination"] = toSpellName(155777)
druid.spells["regrowth"] = toSpellName(8936)
druid.spells["naturesSwiftness"] = toSpellName(132158)
druid.spells["healingTouch"] = toSpellName(5185)
druid.spells["clearcasting"] = toSpellName(16870)
druid.spells["harmony"] = toSpellName(100977)
druid.spells["soulOfTheForrest"] = toSpellName(158478)
druid.spells["ironbark"] = toSpellName(102342)
druid.spells["wildMushroom"] = toSpellName(145205)

druid.groupHealTable = {"NoSpell", false, "player"}
function druid.groupHealTarget()
	local tank = jps.findMeATank()
	local healTarget = jps.LowestInRaidStatus()
	if jps.canHeal(tank) and jps.hp(tank) <= 0.5 then healTarget = tank end
	if jps.hpInc("player") < 0.2 then healTarget = "player" end
	return healTarget
end

function druid.hastSotF()
	local selected, talentIndex = GetTalentRowSelectionInfo(4)
	return talentIndex == 10
end

function groupHeal()
	local healTarget = druid.groupHealTarget()
	local healSpell = nil
	if jps.canCast(druid.spells.wildGrowth, healTarget) then
		healSpell = druid.spells.wildGrowth
	elseif jps.canCast(druid.spells.swiftmend, healTarget) and jps.buff(druid.spells.rejuvination,healTarget) or jps.buff(druid.spells.regrowth,healTarget) then
		healSpell = druid.spells.swiftmend
	elseif not jps.buff(druid.spells.rejuvination,healTarget) then
		healSpell = druid.spells.rejuvination
	end
	druid.groupHealTable[1] = healSpell
	druid.groupHealTable[2] = healSpell ~= nil
	druid.groupHealTable[3] = healTarget
	return druid.groupHealTable
end

druid.focusHealTable = {"NoSpell", false, "player"}
druid.focusHealTargets = {"target", "targettarget", "focus", "focustarget"}
function druid.focusHealTarget()
	if jps.hpInc("player") < 0.2 then return "player" end
	-- First Check for low targets
	for _,healTarget in pairs(druid.focusHealTargets) do
		if jps.hpInc(healTarget) < 0.5 and jps.canHeal(healTarget) then return healTarget end
	end
	-- All above 50% -> take first possible target
	for _,healTarget in pairs(druid.focusHealTargets) do
		if jps.canHeal(healTarget) then return healTarget end
	end
	return nil
end



local dispelTable = {druid.spells.naturesCure}
function druid.dispel()
	local cleanseTarget = nil -- jps.FindMeDispelTarget({"Poison"},{"Curse"},{"Magic"})
	if jps.DispelMagicTarget() then
		cleanseTarget = jps.DispelMagicTarget()
	elseif jps.DispelCurseTarget() then
		cleanseTarget = jps.DispelCurseTarget()
	elseif jps.DispelPoisonTarget() then
		cleanseTarget = jps.DispelPoisonTarget()
	end
	dispelTable[2] = cleanseTarget ~= nil
	dispelTable[3] = cleanseTarget
	return dispelTable
end


function druid.activeMushrooms()
	local first = GetTotemInfo(1) and 1 or 0
	local second = GetTotemInfo(2) and 1 or 0
	local third = GetTotemInfo(3) and 1 or 0
	return first + second + third
end


function druid.legacyDefaultTarget()
	--healer
	local tank = nil
	local me = "player"
	
	-- Tank is focus.
	tank = jps.findMeATank()
	
	--Default to healing lowest partymember
	local defaultTarget = jps.LowestInRaidStatus()
	
	--Check that the tank isn't going critical, and that I'm not about to die
	if jps.canHeal(tank) and jps.hp(tank) <= 0.5 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end
	
	return defaultTarget
end

function druid.legacyDefaultHP()
	return jps.hpInc(druid.legacyDefaultTarget())
end

--[[[
@rotation Legacy Rotation
@class DRUID
@spec RESTORATION
@description 
Makes you Top Healer...until you run out of mana. You have to use Tranquility manually![br]
[*] [code]SHIFT[/code]: Place Wild Mushroom[br]
[*] [code]CONTROL + ALT[/code]: Incarnation Tree of Life[br]
[*] [code]ALT[/code]: combat resurrection @ mouseover[br]
]]--


jps.registerStaticTable("DRUID","RESTORATION",{
	-- rebirth Ctrl-key + mouseover
	{ druid.spells.rebirth, 'IsAltKeyDown() == true and not IsControlKeyDown() and UnitIsDeadOrGhost("mouseover") == true and IsSpellInRange("rebirth", "mouseover")', "mouseover" },
	
	-- Buffs
	{ druid.spells.markOfTheWild, 'not jps.buff(druid.spells.markOfTheWild)', player },
	
	-- CDs
	{ druid.spells.barkskin, 'jps.hp() < 0.50' },
	{ druid.spells.incarnation, 'IsControlKeyDown() == true and IsAltKeyDown() GetCurrentKeyBoardFocus() == nil and not jps.buff(druid.spells.incarnation)' },
	
	{druid.spells.wildMushroom, 'IsShiftKeyDown() == true'  },
	
	druid.dispel,
	{ druid.spells.lifebloom, 'jps.buffDuration(druid.spells.lifebloom,jps.findMeATank()) < 3', jps.findMeATank },
	{ druid.spells.swiftmend, 'druid.legacyDefaultHP() < 0.85 and (jps.buff(druid.spells.rejuvination,druid.legacyDefaultTarget()) or jps.buff(druid.spells.regrowth,druid.legacyDefaultTarget()))', druid.legacyDefaultTarget },
	{ druid.spells.wildGrowth, 'druid.legacyDefaultHP() < 0.95 and jps.MultiTarget', druid.legacyDefaultTarget },
	{ druid.spells.rejuvination, 'druid.legacyDefaultHP() < 0.95 and not jps.buff(druid.spells.rejuvination,druid.legacyDefaultTarget())', druid.legacyDefaultTarget },
	{ druid.spells.rejuvination, 'jps.buffDuration(druid.spells.rejuvination,jps.findMeATank()) < 3', jps.findMeATank },
	{ druid.spells.regrowth, 'druid.legacyDefaultHP() < 0.55 or jps.buff(druid.spells.clearcasting)', druid.legacyDefaultTarget },
	{ druid.spells.naturesSwiftness, 'druid.legacyDefaultHP() < 0.40' },
	{ druid.spells.healingTouch, '(jps.buff(druid.spells.naturesSwiftness) or not jps.Moving) and druid.legacyDefaultHP() < 0.55', druid.legacyDefaultTarget },	
}, "Legacy Rotation")


--[[[
@rotation Advanced Rotation
@class DRUID
@spec RESTORATION
@talents UY!002010!gUTSPF
@author Kirk24788
@description 
This is a Raid-Rotation, don't use it for PvP!. It's focus is mana conserve and minimum overheal. You might not end up as top healer but you shouldn't
run out of mana. Don't worry, if there is something to heal, it will heal! Use Tranquility manually.
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Place Wild Mushroom[br]
[*] [code]ALT[/code]: combat resurrection @ mouseover[br]

]]--

jps.registerStaticTable("DRUID","RESTORATION",{
	-- rebirth Ctrl-key + mouseover
	{ druid.spells.rebirth, 'IsAltKeyDown() == true and UnitIsDeadOrGhost("target") == true and IsSpellInRange("rebirth", "target")', "target" },
	{ druid.spells.rebirth, 'IsAltKeyDown() == true and UnitIsDeadOrGhost("mouseover") == true and IsSpellInRange("rebirth", "mouseover")', "mouseover" },
	
	-- Buffs
	{ druid.spells.markOfTheWild, 'not jps.buff(druid.spells.markOfTheWild)', player },
	
	-- CDs
	{ druid.spells.barkskin, 'jps.hp() < 0.50' },

	-- Dispel
	druid.dispel,

	-- Wild Mushrooms
	{druid.spells.wildMushroom, 'IsShiftKeyDown() == true'  },
	
	-- Group Heal
	{"nested", 'jps.MultiTarget', {
		-- Lifebloom on tank
		{ druid.spells.lifebloom, 'jps.buffDuration(druid.spells.lifebloom,jps.findMeATank()) < 3', jps.findMeATank },
		
		
		-- Group Heal
		{ druid.spells.rejuvination, 'jps.hpInc(druid.groupHealTarget()) < 0.80 and not jps.buff(druid.spells.rejuvination,druid.groupHealTarget())', druid.groupHealTarget },
		{ druid.spells.swiftmend, 'jps.buff(druid.spells.rejuvination,druid.groupHealTarget()) or jps.buff(druid.spells.regrowth,druid.groupHealTarget())', druid.groupHealTarget },
		{ druid.spells.wildGrowth, 'druid.hastSotF() and jps.buff(druid.spells.soulOfTheForrest) or not druid.hastSotF()', druid.groupHealTarget },
	}},

	-- Focus Heal
	{"nested", 'not jps.MultiTarget and druid.focusHealTarget() ~= nil', {
		{ druid.spells.regrowth, 'jps.buffDuration(druid.spells.harmony) < 2 and not jps.buff(druid.spells.regrowth, druid.focusHealTarget())', druid.focusHealTarget },
		{ druid.spells.lifebloom, 'jps.buffDuration(druid.spells.lifebloom,jps.findMeATank()) < 3', jps.findMeATank },
		{ druid.spells.rejuvination, 'jps.buffDuration(druid.spells.rejuvination,druid.focusHealTarget()) < 2', druid.focusHealTarget },
		{ druid.spells.swiftmend, 'jps.buff(druid.spells.rejuvination,druid.focusHealTarget()) or jps.buff(druid.spells.regrowth,druid.focusHealTarget())', druid.focusHealTarget },
		{ druid.spells.naturesSwiftness, 'jps.hpInc(druid.focusHealTarget()) < 0.40' },
		{ druid.spells.healingTouch, 'jps.buff(druid.spells.naturesSwiftness) and jps.hpInc(druid.focusHealTarget()) < 0.55', druid.focusHealTarget },
		{ druid.spells.regrowth, 'jps.hpInc(druid.focusHealTarget()) < 0.75 and jps.buff(druid.spells.clearcasting)', druid.focusHealTarget },
		{ druid.spells.regrowth, 'jps.hpInc(druid.focusHealTarget()) < 0.6 and not jps.buff(druid.spells.regrowth, druid.focusHealTarget())', druid.focusHealTarget },
	}},
},"Advanced Rotation")
