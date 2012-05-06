function priest_disc(self)

-- get average heal value from healtable
local average_renew = getaverage_heal("Renew")
local average_heal = getaverage_heal("Heal")
local average_greater_heal = getaverage_heal("Greater Heal") 
local average_penitence = getaverage_heal("Penance")
local average_flashheal = getaverage_heal("Flash Heal")
local average_POH = getaverage_heal("Prayer of Healing")

----------------------
-- HELPER
----------------------
--IsControlKeyDown(): debug print text
--AltKey_IsDown : "Mass Dispel"
--jps.Defensive: Heal only the Tank et yourself 	/jps def
--jps.MultiTarget : Dispelling 						/jps multi
--jps.PVPInterrupt: Damage and offensive dispell	/jps pint
--jps.UseCDs: group heal "Prayer of Healing"		/jps cds
--jps.Interrupts : "Pain Suppression"				/jps int

local spell = nil
local playerhealth_deficiency = UnitHealthMax("player")-UnitHealth("player")
local playerhealth_pct = UnitHealth("player") / UnitHealthMax("player")

local PriestHeal_Target = jps.lowestInRaidStatus() -- jps.HealingTarget()
local health_deficiency = UnitHealthMax(PriestHeal_Target) - UnitHealth(PriestHeal_Target)
local health_pct = jps.hpInc(PriestHeal_Target) -- UnitHealth(PriestHeal_Target) / UnitHealthMax(PriestHeal_Target)

-- number of party members having a significant health pct loss
local countInRaid = 3
local pctLOSS = 0.80
local POH_countInRaid = jps.countInRaidStatus(pctLOSS) 
local findSubGroup, POH_Target = jps.findSubGroupToHeal(pctLOSS) -- returns the subgroup and the target to heal with POH in RAID

local borrowed = jps.buff("Borrowed Time", "player")
local div_Aegis = jps.buff("Divine Aegis", PriestHeal_Target)

local AltKey_IsDown = false
if IsAltKeyDown() then AltKey_IsDown = true end 

----------------------------
-- PriestHeal_Target_TANK
----------------------------

local Tanktable = {}
local PriestHeal_Target_TANK = nil
if UnitExists("focus") == nil then 
	PriestHeal_Target_TANK = PriestHeal_Target
elseif UnitExists("focus")==1 and UnitIsEnemy("player","focus")==1 then
	PriestHeal_Target_TANK = PriestHeal_Target
else
	table.insert(Tanktable,"player")
	if UnitExists("target") and UnitIsFriend("player","target") then table.insert(Tanktable,"target") end
	if UnitExists("focus")==1 and UnitIsFriend("player","focus")==1 then table.insert(Tanktable,"focus") end
	local lowestHP = 1
	for i,j in ipairs(Tanktable) do
		local thisHP = UnitHealth(j) / UnitHealthMax(j)
		--if IsControlKeyDown() then print(i,j,thisHP) end
		if UnitExists(j) and thisHP <= lowestHP then 
				lowestHP = thisHP
				PriestHeal_Target_TANK = j
		end
	end
	if jps.Defensive then PriestHeal_Target_TANK = "focus" end
end

local health_deficiency_TANK = UnitHealthMax(PriestHeal_Target_TANK) - UnitHealth(PriestHeal_Target_TANK)
local health_pct_TANK = jps.hpInc(PriestHeal_Target_TANK) -- UnitHealth(PriestHeal_Target_TANK) / UnitHealthMax(PriestHeal_Target_TANK)
local stackGrace_TANK = jps.buffStacks("Grace",PriestHeal_Target_TANK)

local switchtoLowestTarget = false
if (health_pct < 0.60) or (health_pct_TANK > 0.90 and jps.buff("Renew", PriestHeal_Target_TANK)) or (health_pct_TANK > 0.90 and stackGrace_TANK > 2) then
	switchtoLowestTarget = true 
end
if jps.Defensive then switchtoLowestTarget = false end

----------------------
-- DAMAGE
----------------------

local rangedTarget = "target"
if  UnitExists("target")==1 and UnitIsEnemy("player","target")==1 and UnitIsDeadOrGhost("target")~=1 then
rangedTarget = "target"
elseif UnitExists("focustarget")==1 and UnitIsEnemy("player","focustarget")==1 and UnitIsDeadOrGhost("focustarget")~=1 then
rangedTarget = "focustarget"
elseif UnitExists("targettarget")==1 and UnitIsEnemy("player","targettarget")==1 and UnitIsDeadOrGhost("targettarget")~=1 then
rangedTarget = "targettarget"
end

---------------------
-- DISPEL
---------------------

local stunMe = jps.isStun() -- return true/false
local dispelOffensive_Target = jps.canDispellOffensive(rangedTarget) -- return true/false

local dispelMagic_Me = jps.MagicDispell("player") -- return true/false
local dispelMagic_TANK = jps.MagicDispell(PriestHeal_Target_TANK) -- return true/false
local dispelMagic_Target = jps.DispelMagicTarget() -- return unit

local dispelDisease_Me = jps.DiseaseDispell("player") -- return true/false
local dispelDisease_TANK = jps.DiseaseDispell(PriestHeal_Target_TANK) -- return true/false
local dispelDisease_Target = jps.DispelDiseaseTarget() -- return unit

local Plasma = jps.FindMeADispelTarget({"Deathwing"}) -- return unit
local Corruption = jps.FindMeADispelTarget({"Yor'sahj"}) -- return unit
if UnitExists(Corruption)==1 and jps.debuffStacks("Deep Corruption", Corruption) > 3 then jps.BlacklistPlayer(Corruption) end

---------------------
-- TIMER
---------------------

local timerShield = jps.checkTimer( "Shield" )

-------------------
-- DEBUG
-------------------
-- IsMouseButtonDown([button]) 1 or LeftButton - 2 or RightButton - 3 or MiddleButton or clickable scroll control
-- shiftDown = IsShiftKeyDown() ctrlDown  = IsControlKeyDown() altDown   = IsAltKeyDown()
if IsControlKeyDown() then
print("|cff0070ddFocus","|cffffffff",PriestHeal_Target_TANK,"|cff0070ddTANK: ","|cffffffff",GetUnitName(PriestHeal_Target_TANK),"HP: ",health_deficiency_TANK,"H%: ",health_pct_TANK)
print("|cff0070ddTarget: ","|cffffffff",PriestHeal_Target,"|cff0070ddNAME: ","|cffffffff",GetUnitName(PriestHeal_Target),"HP: ",health_deficiency,"H%: ",health_pct)
print("|cff0070ddDispelOffensive:","|cffffffff",dispelOffensive_Target,"|cff0070ddRangedTarget:","|cffffffff",rangedTarget)
print("|cff0070ddDispelMagic:","|cffffffff",dispelMagic_Target,"|cff0070ddDispelDisease:","|cffffffff",dispelDisease_Target)
print("|cff0070ddDispelTANK:","|cffffffff",dispelMagic_TANK,"|cff0070ddDiseaseTANK:","|cffffffff",dispelDisease_TANK)
print("|cff0070ddSubGroup:","|cffffffff",findSubGroup,"|cff0070ddPOHTarget:","|cffffffff",POH_Target,"|cff0070ddPOH_Count:","|cffffffff",POH_countInRaid)
print("|cff0070ddSwitch:","|cffffffff",switchtoLowestTarget,"|cff0070ddTimer: ","|cffffffff",timerShield)
end

------------------------
-- TRINKETS ------------
------------------------

	local spellstop, _, _, _, _, endTime = UnitCastingInfo("player")
-- kick Spell Heal if LowHeath
	if spellstop == "Heal" and (endTime-GetTime()) > 1 and health_pct < 0.70 then SpellStopCasting() end
-- Don't kick Casting
	if UnitCastingInfo("player") or UnitChannelInfo("player") then return nil end

-- Trinket
	if  IsEquippedItem("Foul Gift of the Demon Lord") and select(1,GetItemCooldown(72898))==0 and IsUsableItem("Foul Gift of the Demon Lord") and UnitAffectingCombat("player")==1 and div_Aegis then 
		RunMacroText("/use Foul Gift of the Demon Lord")
	elseif IsEquippedItem("Fiery Quintessence") and select(1,GetItemCooldown(69000))==0 and IsUsableItem("Fiery Quintessence") and UnitAffectingCombat("player")==1 then 
		RunMacroText("/use Fiery Quintessence")
	end

------------------------
-- SPELL TABLE ---------
------------------------
local spellTable_moving =
{
	{ "Pain Suppression", jps.Interrupts and (playerhealth_pct < 0.30), "player" },
	{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30), PriestHeal_Target },
	{ "Desperate Prayer", select(2,GetSpellBookItemInfo("Desperate Prayer"))~=nil and (playerhealth_pct < 0.40) , "player" },
	{ "Power Word: Shield", (playerhealth_pct < 0.60) and not jps.buff("Power Word: Shield","player") and not jps.debuff("Weakened Soul","player") , "player" },
	{ "Power Word: Shield", (health_pct < 0.60) and not jps.debuff("Weakened Soul",PriestHeal_Target) and not jps.buff("Power Word: Shield",PriestHeal_Target) , PriestHeal_Target },
	{ "Renew", not jps.buff("Renew","player") and (playerhealth_deficiency > average_renew), "player" },
	{ "Renew", not jps.buff("Renew",PriestHeal_Target) and (health_deficiency > average_renew), PriestHeal_Target },
	{ "Prayer of Mending", not jps.buff("Prayer of Mending","player") and (playerhealth_pct < 0.60), "player" },
	{ "Prayer of Mending", not jps.buff("Prayer of Mending",PriestHeal_Target) and (health_pct < 0.60), PriestHeal_Target },
	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (playerhealth_pct < 0.80) , "player" },
	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (health_pct < 0.80) , PriestHeal_Target },
	{ "Dispel Magic", jps.MultiTarget and UnitExists(dispelMagic_Target)==1 , dispelMagic_Target },
}

local spellTable_def =
{
-- Emergency player
	{"nested", (playerhealth_pct < 0.60),
		{
			{ "Desperate Prayer", select(2,GetSpellBookItemInfo("Desperate Prayer"))~=nil and (playerhealth_pct < 0.40), "player" }, -- IsSpellKnown(spellID)
			{ "Pain Suppression", jps.Interrupts and (playerhealth_pct < 0.30), "player"},
			{ "Flash Heal", jps.buff("Inner Focus","player"), "player"},
			{ "Penance", "onCD" , "player"},
			{ "Power Word: Shield", not jps.buff("Power Word: Shield","player") and not jps.debuff("Weakened Soul","player"), "player"},
			{ "Greater Heal", borrowed, "player" },
			{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (playerhealth_pct < 0.80) , "player" },
			{ "Prayer of Mending", not jps.buff("Prayer of Mending","player") ,"player"},
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target, "player")~=1 and (playerhealth_deficiency > average_flashheal), PriestHeal_Target},
			{ "Flash Heal", "onCD", "player"},
		},
	},
-- Focus Heal
	{"nested", jps.canHeal(PriestHeal_Target_TANK),
		{
			{ "Pain Suppression", jps.Interrupts and (health_pct_TANK < 0.30), PriestHeal_Target_TANK },
			{ "Penance", stackGrace_TANK < 3 and UnitAffectingCombat("player")==1, PriestHeal_Target_TANK }, 
			{ "Flash Heal", jps.buff("Inner Focus","player") and health_deficiency_TANK > (average_flashheal + average_renew) , PriestHeal_Target_TANK },
			{ "Power Word: Shield", not jps.debuff("Weakened Soul",PriestHeal_Target_TANK) and not jps.buff("Power Word: Shield",PriestHeal_Target_TANK), PriestHeal_Target_TANK },
			{ "Penance", health_deficiency_TANK > (average_penitence + average_renew), PriestHeal_Target_TANK },
			{ "Greater Heal", borrowed and health_deficiency_TANK > (average_greater_heal + average_renew), PriestHeal_Target_TANK },
			{ "Prayer of Mending", not jps.buff("Prayer of Mending",PriestHeal_Target_TANK), PriestHeal_Target_TANK },
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target_TANK, "player")~=1 and (playerhealth_deficiency > average_flashheal), PriestHeal_Target_TANK },
			{ "Flash Heal", health_pct_TANK < 0.60 , PriestHeal_Target_TANK },
			{ "Greater Heal", health_deficiency_TANK > (average_greater_heal + average_renew), PriestHeal_Target_TANK },
			{ "Renew", not jps.buff("Renew",PriestHeal_Target_TANK), PriestHeal_Target_TANK },
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target,"player")~=1 and (playerhealth_deficiency > average_flashheal), PriestHeal_Target },
			{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (health_pct_TANK < 0.80), PriestHeal_Target_TANK },
			{ "Heal", (health_pct_TANK < 1), PriestHeal_Target_TANK },
		},
	},
}

local spellTable_main =
{
-- Buff
	--{{"macro","/cast Inner Fire"}, not jps.buff("Inner Fire","player") and not jps.buff("Inner Will","player"), "player" },
 	{ "Inner Fire", not jps.buff("Inner Fire","player") and not jps.buff("Inner Will","player"), "player" },
 	{ "Fade", UnitIsPVP("player")~=1 and UnitThreatSituation("player")==3, "player" },
 	{ "Inner Focus", UnitAffectingCombat("player")==1 , "player" },
 	{ "Fear Ward", UnitIsPVP("player")==1 and not jps.buff("Fear Ward","player"), "player" },
 	{ "Desperate Prayer", select(2,GetSpellBookItemInfo("Desperate Prayer"))~=nil and (playerhealth_pct < 0.40), "player" },
 	{ "Power Word: Shield", timerShield == 0 and not jps.debuff("Weakened Soul", PriestHeal_Target_TANK) and not jps.buff("Power Word: Shield", PriestHeal_Target_TANK), PriestHeal_Target_TANK },
	{ "Power Word: Shield", UnitIsUnit(PriestHeal_Target_TANK, "focustargettarget")~=1 and jps.canHeal("focustargettarget") and not jps.debuff("Weakened Soul","focustargettarget") and not jps.buff("Power Word: Shield","focustargettarget"), "focustargettarget"},
-- Dispell
 	{ "Mass Dispel", AltKey_IsDown, "player" },
 	{ "nested", (health_pct > 0.60) and jps.MultiTarget,
        {
			{"Dispel Magic", dispelMagic_Me, "player" },
			{"Cure Disease", dispelDisease_Me, "player" },
			{"Dispel Magic", dispelMagic_TANK, PriestHeal_Target_TANK },
			{"Cure Disease", dispelDisease_TANK, PriestHeal_Target_TANK },
			{"Dispel Magic", UnitExists(dispelMagic_Target)==1, dispelMagic_Target },
			{"Cure Disease", UnitExists(dispelDisease_Target)==1, dispelDisease_Target },
		},
    },
-- Damage
	{ "nested", jps.PVPInterrupt and UnitExists(rangedTarget)==1,
        {
        	{ "Dispel Magic", dispelOffensive_Target, rangedTarget },
            { "Shadow Word: Death", UnitHealth(rangedTarget)/UnitHealthMax(rangedTarget) < 0.25, rangedTarget },
            { "Holy Fire", "onCD", rangedTarget },
            { "Penance", "onCD", rangedTarget },
            { "Smite", "onCD", rangedTarget },
        },
    },
-- Group Heal
    { "nested", jps.UseCDs and (POH_countInRaid > countInRaid) and (jps.LastCast=="Prayer of Healing"),
        {
        	{ "Power Infusion", (health_pct < 0.40), "player"},
			{ "Prayer of Mending", (health_pct < 0.60) and not jps.buff("Prayer of Mending",PriestHeal_Target), PriestHeal_Target },
			{ "Pain Suppression", jps.Interrupts and (health_pct_TANK < 0.30), PriestHeal_Target_TANK },
			{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30), PriestHeal_Target },
			{ "Penance", (health_pct_TANK < 0.40), PriestHeal_Target_TANK },
			{ "Penance", (health_pct < 0.40), PriestHeal_Target },
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target, "player")~=1 and (health_pct < 0.30) and (playerhealth_deficiency > average_flashheal), PriestHeal_Target},
    		{ "Power Word: Shield", not jps.debuff("Weakened Soul",PriestHeal_Target_TANK) and not jps.buff("Power Word: Shield",PriestHeal_Target_TANK), PriestHeal_Target_TANK },
    		{ "Power Word: Shield", not borrowed and not jps.debuff("Weakened Soul",PriestHeal_Target) and not jps.buff("Power Word: Shield",PriestHeal_Target), PriestHeal_Target },
        },
    },
	{ "nested", jps.UseCDs and (POH_countInRaid > countInRaid),
        {
            { "Prayer of Healing", jps.UseCDs and (findSubGroup > 0) and jps.canHeal(POH_Target), POH_Target},
    		{ "Prayer of Healing", jps.UseCDs and (findSubGroup > 0), "player"},
			{ "Prayer of Healing", jps.UseCDs and (findSubGroup == 0) and jps.canHeal(PriestHeal_Target), PriestHeal_Target},
    		{ "Prayer of Healing", jps.UseCDs and (findSubGroup == 0), "player"},
        },
    },
-- Emergency Target
	{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30), PriestHeal_Target },
	{ "Penance", health_deficiency > (average_penitence + average_renew), PriestHeal_Target },
	{ "Flash Heal", jps.buff("Inner Focus","player") and health_deficiency > (average_flashheal + average_renew), PriestHeal_Target },
	{ "Greater Heal", borrowed and health_deficiency > (average_greater_heal + average_renew), PriestHeal_Target },
	{ "Binding Heal", UnitIsUnit(PriestHeal_Target,"player")~=1 and (playerhealth_deficiency > average_flashheal), PriestHeal_Target },
	{ "Power Word: Shield", (health_pct < 0.60) and not jps.debuff("Weakened Soul",PriestHeal_Target) and not jps.buff("Power Word: Shield",PriestHeal_Target), PriestHeal_Target },
	{ "Prayer of Mending", (health_pct < 0.60) and not jps.buff("Prayer of Mending",PriestHeal_Target), PriestHeal_Target }, 
	{ "Flash Heal", (health_pct < 0.60), PriestHeal_Target },
-- Boss Debuff
	{ "Greater Heal", UnitExists(Plasma)==1 , Plasma }, -- "Deathwing"
-- Basic    
	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (health_pct < 0.80), PriestHeal_Target },
	{ "Greater Heal", health_deficiency > (average_greater_heal + average_renew) and jps.buff("Renew",PriestHeal_Target) and jps.buffDuration("Renew", PriestHeal_Target) < 3, PriestHeal_Target },
	{ "Greater Heal", health_deficiency > (average_greater_heal + average_renew) and not jps.buff("Renew",PriestHeal_Target), PriestHeal_Target },
	{ "Greater Heal", health_deficiency > (average_greater_heal + average_renew), PriestHeal_Target },
	{ "Renew", not jps.buff("Renew",PriestHeal_Target) and (health_deficiency > average_renew) , PriestHeal_Target },
	{ "Renew", jps.buff("Power Word: Shield",PriestHeal_Target) and health_deficiency < (average_penitence + average_renew) and health_deficiency > average_heal and not jps.buff("Renew",PriestHeal_Target), PriestHeal_Target },
	{ "Heal", jps.buff("Renew",PriestHeal_Target) and jps.buffDuration("Renew", PriestHeal_Target) < 3 and health_deficiency > (average_heal + average_renew), PriestHeal_Target },
	{ "Heal", (health_deficiency > average_renew), PriestHeal_Target },
}

local target = nil
if (GetUnitSpeed("player") / 7) > 0 then
	spell, target = parseSpellTable(spellTable_moving)
elseif jps.Defensive then
	spell, target = parseSpellTable(spellTable_def)
else
	spell, target = parseSpellTable(spellTable_main)
end

	jps.Target = target
	return spell
end

--[[
function jps_deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local spellTable = {}
if (GetUnitSpeed("player") / 7) > 0 then
	spellTable = jps_deepcopy(spellTable_moving) 
else
	spellTable = jps_deepcopy(spellTable_main) 
end 
local spell,target = parseSpellTable(spellTable)
]]