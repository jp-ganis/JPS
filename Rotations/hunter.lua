hunter = {}

local function toSpellName(id) name = GetSpellInfo(id); return name end
hunter.spells = {}
hunter.spells["explosiveShot"] = toSpellName(53301)
hunter.spells["glaiveToss"] = toSpellName(117050)
hunter.spells["multiShot"] = toSpellName(2643)
hunter.spells["cobraShot"] = toSpellName(77767)
hunter.spells["killShot"] = toSpellName(53351)
hunter.spells["serpentSting"] = toSpellName(1978)
hunter.spells["blackArrow"] = toSpellName(3674)
hunter.spells["arcaneShot"] = toSpellName(3044)
hunter.spells["aspectOfTheHawk"] = toSpellName(13165)
hunter.spells["aspectOfTheIronHawk"] = toSpellName(109260)
hunter.spells["mendPet"] = toSpellName(136)
hunter.spells["aMurderOfCrows"] = toSpellName(131894)
hunter.spells["direBeast"] = toSpellName(120679)
hunter.spells["rabid"] = toSpellName(53401)
hunter.spells["rapidFire"] = toSpellName(36828)
hunter.spells["stampede"] = toSpellName(121818)
hunter.spells["trapLauncher"] = toSpellName(77769)
hunter.spells["explosiveTrap"] = toSpellName(13813)
hunter.spells["iceTrap"] = toSpellName(13809)
hunter.spells["snakeTrap"] = toSpellName(34600)
hunter.spells["freezingTrap"] = toSpellName(1499)
hunter.spells["heartOfThePhoenix"] = toSpellName(55709)
hunter.spells["revivePet"] = toSpellName(982)
hunter.spells["counterShot"] = toSpellName(147362)
hunter.spells["misdirection"] = toSpellName(34477)
hunter.spells["focusFire"] = toSpellName(82692)
hunter.spells["fervor"] = toSpellName(82726)
hunter.spells["bestialWrath"] = toSpellName(19574)
hunter.spells["killCommand"] = toSpellName(34026)
hunter.spells["lynxRush"] = toSpellName(120697)
hunter.spells["barrage"] = toSpellName(120360)
hunter.spells["powershot"] = toSpellName(109259)
hunter.spells["blinkStrikes"] = toSpellName(130392)

-- Professions
hunter.spells["lifeblood"] = toSpellName(121279)

hunter.buffs = {}
hunter.buffs["lockAndLoad"] = toSpellName(56343)
hunter.buffs["frenzy"] = toSpellName(19623)
hunter.buffs["theBeastWithin"] = toSpellName(34692)
hunter.buffs["thrillOfTheHunt"] = toSpellName(109306)

function hunter.petIsPassive()
    local _, _, _, _, petIsPassive, _, _ = GetPetActionInfo(10) -- Slot 10 is PassiveMode on the pet actionbar
    return petIsPassive
end

function hunter.petShouldAttackMyTarget()
    local petTargetID = UnitGUID("pettarget")                 -- get unique ID on pettarget
    local playerTargetID = UnitGUID("target")                 -- get unique ID on playertarget
    if playerTargetID ~= nil                                -- 1) check if player has target,
    and playerTargetID ~= petTargetID                        -- 2) check petarget is equal to playertarget,
    and UnitCanAttack("player", "target") ~= nil then        -- 3) check that player can attack current target
        return true
    end
    return false
end

-- Binary key combinations
-- 1 = Shift
-- 2 = Alt
-- 3 = Shift + Alt
-- 4 = Control
-- 5 = Shift + Control
-- 6 = Alt + Control
-- 7 = Shift + Alt + Control
function hunter.trapKey()
    -- Reset keys to zero
    local shiftKEY_binary = 0
    local altKEY_binary = 0
    local controlKEY_binary = 0

    -- Register key downs
    if IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil then shiftKEY_binary = 1 end
    if IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil then altKEY_binary = 2 end
    if IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil then controlKEY_binary = 4 end

    -- Binary calculation
    return shiftKEY_binary + altKEY_binary + controlKEY_binary
end