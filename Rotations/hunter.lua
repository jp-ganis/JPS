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

-- Professions
hunter.spells["lifeblood"] = toSpellName(121279)

hunter.buffs = {}
hunter.buffs["lockAndLoad"] = toSpellName(56343)

function hunter.petIsPassive()
    local _, _, _, _, petIsPassive, _, _ = GetPetActionInfo(10) -- Slot 10 is PassiveMode on the pet actionbar
    return petIsPassive
end

function hunter.petShouldAttackMyTarget()
    local petTargetID = UnitGUID("pettarget") 		-- get unique ID on pettarget
    local playerTargetID = UnitGUID("target") 		-- get unique ID on playertarget
    if playerTargetID ~= nil				-- 1) check if player has target,
    and playerTargetID ~= petTargetID			-- 2) check petarget is equal to playertarget,
    and UnitCanAttack("player", "target") ~= nil then	-- 3) check that player can attack current target
        return true
    end
    return false
end
