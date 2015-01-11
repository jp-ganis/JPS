--[[[
@rotation MM Hunter PVE 6.0.2
@class HUNTER
@spec MARKSMANSHIP
@author tropic, updated by peanutbird
@description
Talents/gear:[br]
[*] Weapon DPS >>> Crit > Haste > Mastery > Multistrike > Agility[br]
[*] Thrill of the Hunt[br]
[*] Stampede[br]
[*] Barrage > Glaive Toss[br]
[br]
Features:[br]
[*] "Defensive" button toggles misdirect to pet if soloing, misdirect to "focus" e.g. in party/raid[br]
[*] Auto use "Healthstone" at 30% hp[br]
[*] mend pet when hp is less than 90%[br]
[*] interrupt spellcasting with Counter Shot[br]
[*] Use CDs: Blows all cooldowns: trinkets, eng. gloves pots (if boss) etc.[br]
[br]
Trap Keys:[br]
[*][code]SHIFT:[/code] Explosive Trap[br]
[*][code]ALT:[/code] Freezing Trap[br]
[*][code]CONTROL:[/code] Binding Shot[br]
[*][code]SHIFT-CONTROL:[/code] Ice Trap[br]
]]--

-- cast_regen always returns zero even though it should be working (?)
-- the simcraft rotation uses it a lot to prevent focus capping
-- GetPowerRegen() stays constant despite haste changes (buffs, gear) - bug in the game (?)

-- _, focusPerSec = GetPowerRegen()
-- cast_regen = jps.CastTimeLeft("player") * GetPowerRegen()


-- Pool focus for "Rapid Fire" so we can spam "Aimed shot" with "Careful Aim" buff
function hunter.rapidfirepooling()
    if UnitMana("player") < 85 and jps.cooldown(3045) < 8 and jps.cooldown(3045) ~= 0 then
        return true
    end
    return false
end

function hunter.isBoss()
	if UnitExists("target") then
		return UnitLevel("target") == -1
	end
	return false
end
spellTableMM =  {

    -- Revive pet
    --{ hunter.spells.heartOfThePhoenix, 'UnitIsDead("pet") == true and HasPetUI() == true' }, -- Instant revive pet (only some pets, Ferocity)
    --{ hunter.spells.revivePet, '((UnitIsDead("pet") == true and HasPetUI() == true) or HasPetUI() == false) and not jps.Moving' },

    -- Heal pet
    { hunter.spells.mendPet, 'jps.hp("pet") < 0.90 and not jps.buff(hunter.spells.mendPet, "pet") and UnitExists("pet") == true and not UnitIsDead("pet")' },

    -- Misdirection
    { hunter.spells.misdirection, 'jps.Defensive and not jps.buff(hunter.spells.misdirection) and UnitExists("focus") == false and not IsInGroup() and UnitExists("pet") == true', 'pet' }, -- IsInGroup() returns true/false. Works for any party/raid
    { hunter.spells.misdirection, 'jps.combatTime() < 24 and  jps.Defensive and not jps.buff(hunter.spells.misdirection) and UnitExists("focus") == true', 'focus' },

    -- Interrupt
    { hunter.spells.counterShot, 'jps.shouldKick()' },
    --{ hunter.spells.counterShot, 'jps.shouldKick() and jps.CastTimeLeft("target") < 1.4' },

    -- Healthstone
    { jps.useBagItem(5512), 'jps.hp("player") < 0.30' },

    -- Trinkets and stuff
	{ jps.useTrinket(0), 'jps.UseCDs and jps.useTrinketBool(0) ' },
	{ jps.useTrinket(1), 'jps.UseCDs and jps.useTrinketBool(1) ' },	
    { "Berserking", 'jps.UseCDs' },
	{ "Blood Fury", 'jps.UseCDs' },
    { hunter.spells.barrage, 'jps.UseCDs and jps.hp("target") <= 0.8' },
	{ hunter.spells.aMurderOfCrows, 'jps.UseCDs' },

    -- Traps
    { hunter.spells.trapLauncher, 'not jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.explosiveTrap, '(hunter.trapKey() == 1 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.freezingTrap, '(hunter.trapKey() == 2 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.iceTrap, '(hunter.trapKey() == 3 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },

    -- Rotation
    { hunter.spells.chimaeraShot },
    { hunter.spells.killShot },
	{ hunter.spells.barrage, 'hunter.isBoss() and jps.hp("target") < 0.80' },
    { hunter.spells.rapidFire, 'jps.UseCDs and jps.hp("target") < 0.80 and not jps.bloodlusting()' },
	
    { hunter.spells.stampede, 'jps.UseCDs and jps.TimeToDie("target") > 20' },
	{ hunter.spells.glaiveToss, 'jps.MultiTarget and jps.UseCDs' },
	{ hunter.spells.barrage, 'jps.MultiTarget and jps.UseCDs' },
	{ hunter.spells.multiShot,'jps.MultiTarget and jps.buff("Bombardment") '},
	{ hunter.spells.multiShot,'jps.MultiTarget and jps.cooldown("barrage") > 5'},

    {"nested", jps.buff(hunter.buffs.carefulAim), {
        { hunter.spells.aimedShot },
        { hunter.spells.steadyShot },
    }},
    { hunter.spells.direBeast, 'jps.focus() < 90' },
    { hunter.spells.glaiveToss },
    { hunter.spells.powershot },

    --Pool max focus for rapid fire so we can spam AimedShot with Careful Aim buff
    { hunter.spells.steadyShot, 'hunter.rapidfirepooling()'},
    --Cast a second shot for steady focus if that won't cap us.
    { hunter.spells.steadyShot, 'jps.LastCast = hunter.spells.steadyShot and jps.focus() < 80'},
	{ hunter.spells.aimedShot, 'jps.hp("target") >= 0.8' },
    { hunter.spells.aimedShot, 'jps.focus() > 90' },
	{ hunter.spells.aimedShot,' jps.cooldown(hunter.spells.barrage) > 5 and jps.hp("target") < 0.80 ' },

    { hunter.spells.aimedShot, 'jps.buff(hunter.buffs.thrillOfTheHunt) and jps.focus() > 60' },
    { hunter.spells.steadyShot },

}

jps.registerRotation("HUNTER","MARKSMANSHIP",function()

	if jps.IsSpellKnown(hunter.spells.bindingShot) and jps.cooldown(hunter.spells.bindingShot) == 0 and IsControlKeyDown() == true and not GetCurrentKeyBoardFocus() and  IsShiftKeyDown() == false and IsAltKeyDown() then
		jps.Cast(hunter.spells.bindingShot)
	end --spells out of spelltable are currently necessary when they come from talents :(

	return parseStaticSpellTable(spellTableMM)
end,"MM Hunter 6.0.2")




spellTableOOCMM = {
	{"Aspect of the Cheetah" ,'IsShiftKeyDown() and jps.glyphInfo(119462) and not jps.buff("Aspect of the Cheetah") and not jps.buff("Aspect of the Fox") and not jps.buff("Aspect of the Pack") ',"player"},
}
jps.registerRotation("HUNTER","MARKSMANSHIP",function()
	
	return parseStaticSpellTable(spellTableOOCMM)
end,"Out of Combat",false,false,nil, true)
