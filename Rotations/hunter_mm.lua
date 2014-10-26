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
[*][code]CONTROL:[/code] Snake Trap[br]
[*][code]SHIFT-CONTROL:[/code] Ice Trap[br]
]]--

-- cast_regen always returns zero even though it should be working (?)
-- the simcraft rotation uses it a lot to prevent focus capping
-- GetPowerRegen() stays constant despite haste changes (buffs, gear) - bug in the game (?)

-- _, focusPerSec = GetPowerRegen()
-- cast_regen = jps.CastTimeLeft("player") * GetPowerRegen()


-- Pool focus for "Rapid Fire" so we can spam "Aimed shot" with "Careful Aim" buff
function hunter.rapidfirepooling()
    if UnitMana("player") < 85
    and jps.cooldown(3045) < 8 and jps.cooldown(3045) ~= 0 then
        return true
    end
    return false
end

jps.registerStaticTable("HUNTER","MARKSMANSHIP", {

    -- Revive pet
    --{ hunter.spells.heartOfThePhoenix, 'UnitIsDead("pet") ~= nil and HasPetUI() ~= nil' }, -- Instant revive pet (only some pets, Ferocity)
    --{ hunter.spells.revivePet, '((UnitIsDead("pet") ~= nil and HasPetUI() ~= nil) or HasPetUI() == nil) and not jps.Moving' },

    -- Heal pet
    { hunter.spells.mendPet, 'jps.hp("pet") < 0.90 and not jps.buff(hunter.spells.mendPet, "pet") and UnitExists("pet") == true and not UnitIsDead("pet")' },

    -- Misdirection
    { hunter.spells.misdirection, 'jps.Defensive and not jps.buff(hunter.spells.misdirection) and UnitExists("focus") == nil and not IsInGroup() and UnitExists("pet") ~= nil', 'pet' }, -- IsInGroup() returns true/false. Works for any party/raid
    { hunter.spells.misdirection, 'jps.Defensive and not jps.buff(hunter.spells.misdirection) and UnitExists("focus") ~= nil', 'focus' },

    -- Interrupt
    --{ hunter.spells.counterShot, 'jps.shouldKick()' },
    { hunter.spells.counterShot, 'jps.shouldKick() and jps.CastTimeLeft("target") < 1.4' },

    -- Healthstone
    { jps.useBagItem(5512), 'jps.hp("player") < 0.30' },

    -- Trinkets and stuff
    { jps.useTrinket(0), 'jps.UseCDs' },
    { jps.useTrinket(1), 'jps.UseCDs' },
    { jps.DPSRacial, 'jps.UseCDs' },

    -- Traps
    { hunter.spells.trapLauncher, 'not jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.explosiveTrap, '(hunter.trapKey() == 1 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.freezingTrap, '(hunter.trapKey() == 2 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.snakeTrap, '(hunter.trapKey() == 4 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.iceTrap, '(hunter.trapKey() == 3 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    
    -- Rotation
    { hunter.spells.chimaeraShot },
    { hunter.spells.killShot },
    { hunter.spells.rapidFire, 'jps.UseCDs and jps.hp("target") < 0.80 and not jps.bloodlusting()' },
    { hunter.spells.stampede, 'jps.UseCDs and jps.TimeToDie("target") > 20' },
    {"nested", jps.buff(hunter.buffs.carefulAim), {
        { hunter.spells.glaiveToss, 'jps.Multitarget' },
        { hunter.spells.barrage, 'jps.Multitarget' },
        { hunter.spells.aimedShot },
        { hunter.spells.steadyShot },
    }},
    { hunter.spells.direBeast, 'jps.focus() < 90' },
    { hunter.spells.glaiveToss },
    { hunter.spells.powershot },
    { hunter.spells.aMurderOfCrows, 'jps.UseCDs' },
    { hunter.spells.barrage },
    --Pool max focus for rapid fire so we can spam AimedShot with Careful Aim buff
    { hunter.spells.steadyShot, 'hunter.rapidfirepooling()'},
    --Cast a second shot for steady focus if that won't cap us.
    { hunter.spells.steadyShot, 'jps.LastCast = hunter.spells.steadyShot and jps.focus() < 80'},
    { hunter.spells.aimedShot, 'jps.focus() > 90' },
    { hunter.spells.aimedShot, 'jps.buff(hunter.buffs.thrillOfTheHunt) and jps.focus() > 60' },
    { hunter.spells.steadyShot },

}, "MM Hunter PVE 6.0.2", true, false)
