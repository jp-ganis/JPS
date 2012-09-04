function jps.MageSheepDuration_Eng(unit)
	if unit==nil then return false end
	local delay = 0
	local Class, _ = UnitClass(unit)
	local spell, _, _, _, startTime, endTime = UnitCastingInfo(unit)
	if Class== "Mage" and spell == "Polymorph" then -- 1.5 sec cast
		delay = jps.castTimeLeft(unit) - jps.Lag
	end
	if delay < 0 then return true end
return false
end

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
--jps.PVPInterrupt: Damage							/jps pint
--jps.UseCDs: group heal "Prayer of Healing"		/jps cds
--jps.Interrupts : "Pain Suppression"				/jps int

local AltKey_IsDown = false
if IsAltKeyDown() then AltKey_IsDown = true end

local spell = nil
local playerhealth_deficiency = UnitHealthMax("player")-UnitHealth("player")
local playerhealth_pct = UnitHealth("player") / UnitHealthMax("player")

-- number of party members having a significant health pct loss
local countInRaid = 3
local pctLOSS = 0.80
local COH_countInRaid = jps.countInRaidStatus(0.90)
local POH_countInRaid = jps.countInRaidStatus(pctLOSS)
local POH_Target = jps.findSubGroupToHeal(pctLOSS) -- returns the target to heal with POH in RAID
local borrowed = jps.buff("Borrowed Time", "player")

----------------------------
-- PriestHeal_Target_TANK
----------------------------

local PriestHeal_Target = jps.lowestInRaidStatus() -- jps.HealingTarget()
local health_deficiency = UnitHealthMax(PriestHeal_Target) - UnitHealth(PriestHeal_Target)
local health_pct = jps.hpInc(PriestHeal_Target) -- UnitHealth(PriestHeal_Target) / UnitHealthMax(PriestHeal_Target)

local Tanktable = {}
local PriestHeal_Target_TANK = nil
local switchtoLowestTarget = false

if UnitExists("focus") == nil then
	PriestHeal_Target_TANK = PriestHeal_Target
	switchtoLowestTarget = true
elseif (UnitExists("focus")==1 and UnitIsEnemy("player","focus")==1) then
	PriestHeal_Target_TANK = PriestHeal_Target
	switchtoLowestTarget = true
else
	table.insert(Tanktable,"player")
	if jps.canHeal("target") then table.insert(Tanktable,"target") end
	if jps.canHeal("focus") then table.insert(Tanktable,"focus") end
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

if (health_pct_TANK > 0.80) and jps.buff("Renew", PriestHeal_Target_TANK) then
	switchtoLowestTarget = true
elseif (health_pct_TANK > 0.80) and stackGrace_TANK > 2 then
	switchtoLowestTarget = true
elseif (health_pct < 0.60) and not jps.Defensive then -- Heal only Tank 
	switchtoLowestTarget = true
end

----------------------
-- EVENTS
----------------------

--local frame = CreateFrame('Frame')
--frame:RegisterEvent("UNIT_COMBAT")
--frame:SetScript("OnEvent",
--  function(self, event, ...)
--	local eventtable =  {...} 
-- 	if eventtable[2] == "SPELL__DAMAGE" and eventtable[9] == PriestHeal_Target then
-- 		print("|cff1eff00TARGET:",eventtable[1],"SPELLTYPE:",eventtable[2],"AMOUNT:",eventtable[4]) -- WOUND -- HEAL
-- 	end
--
--)

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

local castDeath = jps.MageSheepDuration_Eng(rangedTarget) -- return true/false
local stunMe = jps.isStun() or jps.checkTimer("PLAYER_CONTROL_LOST")>0 -- return true/false
local dispelOffensive_Target = jps.canDispellOffensive(rangedTarget) -- return true/false

local dispelMagic_Me = jps.MagicDispell("player") -- return true/false
local dispelMagic_TANK = jps.MagicDispell(PriestHeal_Target_TANK) -- return true/false
local dispelMagic_Target = jps.DispelMagicTarget() -- return unit

local dispelDisease_Me = jps.DiseaseDispell("player") -- return true/false
local dispelDisease_TANK = jps.DiseaseDispell(PriestHeal_Target_TANK) -- return true/false
local dispelDisease_Target = jps.DispelDiseaseTarget() -- return unit

local Plasma = jps.FindMeADispelTarget({"Deathwing"}) -- return unit
local Corruption = jps.FindMeADispelTarget({"Yor'sahj"}) -- return unit
if UnitExists(Corruption)==1 and jps.debuffStacks("Deep Corruption", Corruption) > 4 then jps.BlacklistPlayer(Corruption) end

---------------------
-- TIMER
---------------------

local timerShield = jps.checkTimer( "Shield" )

-------------------
-- DEBUG
-------------------

if IsControlKeyDown() then
print("|cff0070ddFocus","|cffffffff",PriestHeal_Target_TANK,"|cff0070ddTANK: ","|cffffffff",GetUnitName(PriestHeal_Target_TANK),"HP: ",health_deficiency_TANK,"H%: ",health_pct_TANK)
print("|cff0070ddTarget: ","|cffffffff",PriestHeal_Target,"|cff0070ddNAME: ","|cffffffff",GetUnitName(PriestHeal_Target),"HP: ",health_deficiency,"H%: ",health_pct)
print("|cff0070ddDispelOffensive:","|cffffffff",dispelOffensive_Target,"|cff0070ddRangedTarget:","|cffffffff",rangedTarget)
print("|cff0070ddDispelMagic:","|cffffffff",dispelMagic_Target,"|cff0070ddDispelDisease:","|cffffffff",dispelDisease_Target)
--print("|cff0070ddDispelTANK:","|cffffffff",dispelMagic_TANK,"|cff0070ddDiseaseTANK:","|cffffffff",dispelDisease_TANK)
print("|cff0070ddPOHTarget:","|cffffffff",POH_Target,"|cff0070ddPOH_Count:","|cffffffff",POH_countInRaid)
print("|cff0070ddSwitch:","|cffffffff",switchtoLowestTarget,"|cff0070ddTimer: ","|cffffffff",timerShield)
print("|cff0070ddCONTROL_LOST:","|cffffffff",jps.checkTimer("PLAYER_CONTROL_LOST"),"|cff0070ddSTUN","|cffffffff",jps.isStun())
end

------------------------
-- TRINKETS ------------
------------------------

-- Shadow Word: Death on Polymorph
	if UnitExists(rangedTarget)==1 and UnitIsEnemy("player",rangedTarget)==1 and castDeath and jps.cooldown("Shadow Word: Death")==0 then 
		SpellStopCasting()
		jps.Target = rangedTarget
		spell = "Shadow Word: Death"
		print("castDeath",castDeath)
	return spell end
-- kick Spell Heal if LowHeath
	local spellstop = UnitCastingInfo("player")
	if spellstop == "Heal" and jps.castTimeLeft("player") > 1 and health_pct < 0.70 then
		SpellStopCasting()
	end

-- Trinket
	if  IsEquippedItem("Foul Gift of the Demon Lord") and select(1,GetItemCooldown(72898))==0 and IsUsableItem("Foul Gift of the Demon Lord") and UnitAffectingCombat("player")==1 then 
		RunMacroText("/use Foul Gift of the Demon Lord")
	elseif IsEquippedItem("Fiery Quintessence") and select(1,GetItemCooldown(69000))==0 and IsUsableItem("Fiery Quintessence") and UnitAffectingCombat("player")==1 then 
		RunMacroText("/use Fiery Quintessence")
	elseif stunMe and IsEquippedItem("Ruthless Gladiator's Medallion of Tenacity") and select(1,GetItemCooldown(72412))==0 
	and IsUsableItem("Ruthless Gladiator's Medallion of Tenacity") and UnitAffectingCombat("player")==1 then 
		RunMacroText("/use Ruthless Gladiator's Medallion of Tenacity")
	end

------------------------
-- SPELL TABLE ---------
------------------------

local spellTable_moving =
{
	{ "Pain Suppression", jps.Interrupts and (playerhealth_pct < 0.30), "player" },
	{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30), PriestHeal_Target },
	{ "Desperate Prayer", select(2,GetSpellBookItemInfo("Desperate Prayer"))~=nil and (playerhealth_pct < 0.40), "player" },
	{ "Power Word: Shield", (playerhealth_pct < 0.60) and not jps.buff("Power Word: Shield","player") and not jps.debuff("Weakened Soul","player"), "player" },
	{ "Power Word: Shield", (health_pct < 0.60) and not jps.buff("Power Word: Shield",PriestHeal_Target) and not jps.debuff("Weakened Soul",PriestHeal_Target), PriestHeal_Target },
	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (playerhealth_pct < 0.80), "player" },
	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (health_pct < 0.80), PriestHeal_Target },
	{ "Prayer of Mending", not jps.buff("Prayer of Mending","player") and (playerhealth_pct < 0.80), "player" },
	{ "Prayer of Mending", not jps.buff("Prayer of Mending",PriestHeal_Target) and (health_pct < 0.80), PriestHeal_Target },
	{ "Renew", not jps.buff("Renew","player") and (playerhealth_deficiency > average_renew), "player" },
	{ "Renew", not jps.buff("Renew",PriestHeal_Target) and (health_deficiency > average_renew), PriestHeal_Target },
	{ "Power Word: Shield", UnitIsPVP("player")==1 and not jps.buff("Power Word: Shield","player") and not jps.debuff("Weakened Soul","player"), "player" },
	{ "Psychic Scream", UnitIsPVP("player")==1 and UnitAffectingCombat("player")==1 and UnitExists("target")==1 and UnitIsEnemy("player", "target")==1 and CheckInteractDistance("target", 3) == 1, "target" },
 	{ "Inner Focus", UnitAffectingCombat("player")==1 , "player" },
	{ "Dispel Magic", jps.MultiTarget and dispelMagic_Me, "player" },
	{ "Dispel Magic", jps.MultiTarget and UnitExists(dispelMagic_Target)==1, dispelMagic_Target },
-- Offensive dispell
	{ "nested", UnitIsPVP("player")==1 and UnitExists(rangedTarget)==1 and UnitIsEnemy("player", rangedTarget)==1,
		{
			{"Shadow Word: Death", castDeath, rangedTarget }, 
			{"Dispel Magic", dispelOffensive_Target, rangedTarget },
		},
	},
-- Buff
	{ "Inner Fire", not jps.buff("Inner Fire","player") and not jps.buff("Inner Will","player"), "player" },
	{ "Fear Ward", UnitIsPVP("player")==1 and not jps.buff("Fear Ward","player"), "player" },
	{ "Leap of Faith", UnitIsPVP("player")==1 and (health_pct < 0.30) and (jps.cooldown("Pain Suppression") > 0) and (CheckInteractDistance(PriestHeal_Target, 4) == nil), PriestHeal_Target},
}

local spellTable_main =
{
-- Buff
	--{{"macro","/cast Inner Fire"}, not jps.buff("Inner Fire","player") and not jps.buff("Inner Will","player"), "player" },
 	{ "Inner Fire", not jps.buff("Inner Fire","player") and not jps.buff("Inner Will","player"), "player" },
 	{ "Fade", UnitIsPVP("player")~=1 and UnitThreatSituation("player")==3, "player" },
 	{ "Desperate Prayer", select(2,GetSpellBookItemInfo("Desperate Prayer"))~=nil and (playerhealth_pct < 0.40), "player" },
 	{ "Psychic Scream", UnitIsPVP("player")==1 and UnitAffectingCombat("player")==1 and UnitExists("target")==1 and UnitIsEnemy("player", "target")==1 and CheckInteractDistance("target", 3)==1, "target" },
 	{ "Inner Focus", UnitAffectingCombat("player")==1 , "player" },
 	{ "Power Infusion", UnitAffectingCombat("player")==1 and (health_pct < 0.40), "player"},
 	{ "Fear Ward", UnitIsPVP("player")==1 and (health_pct > 0.40) and not jps.buff("Fear Ward","player"), "player" },
 	{ "Power Word: Shield", timerShield == 0 and not jps.debuff("Weakened Soul", PriestHeal_Target_TANK) and not jps.buff("Power Word: Shield", PriestHeal_Target_TANK), PriestHeal_Target_TANK },
 	{ "Power Word: Shield", UnitIsUnit(PriestHeal_Target_TANK, "focustargettarget")~=1 and jps.canHeal("focustargettarget") and not jps.debuff("Weakened Soul","focustargettarget") and not jps.buff("Power Word: Shield","focustargettarget"), "focustargettarget"},
	{ "Flash Heal", UnitIsPVP("player")==1 and jps.buff("Inner Focus","player") and health_deficiency > (average_flashheal + average_renew), PriestHeal_Target },
-- Mass Dispell
 	{ "Mass Dispel", AltKey_IsDown, "player" },
-- Offensive dispell
	{ "nested", UnitIsPVP("player")==1 and UnitExists(rangedTarget)==1 and UnitIsEnemy("player", rangedTarget)==1 and (health_pct_TANK > 0.60),
		{
			{"Shadow Word: Death", castDeath, rangedTarget }, 
			{"Dispel Magic", dispelOffensive_Target, rangedTarget },
		},
	},
-- Dispell
 	{ "nested", (health_pct_TANK > 0.60) and jps.MultiTarget,
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
	{ "nested", jps.PVPInterrupt and UnitExists(rangedTarget)==1 and UnitIsEnemy("player", rangedTarget)==1 and (health_pct_TANK > 0.60),
        {
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
			{ "Prayer of Mending", not jps.buff("Prayer of Mending",PriestHeal_Target), PriestHeal_Target },
			{ "Pain Suppression", jps.Interrupts and (health_pct_TANK < 0.30), PriestHeal_Target_TANK },
			{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30), PriestHeal_Target },
			{ "Penance", (health_pct_TANK < 0.40), PriestHeal_Target_TANK },
			{ "Penance", (health_pct < 0.40), PriestHeal_Target },
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target, "player")~=1 and (health_pct < 0.60) and (playerhealth_deficiency > average_flashheal), PriestHeal_Target},
    		{ "Power Word: Shield", not jps.debuff("Weakened Soul",PriestHeal_Target_TANK) and not jps.buff("Power Word: Shield",PriestHeal_Target_TANK), PriestHeal_Target_TANK },
    		{ "Power Word: Shield", not borrowed and not jps.debuff("Weakened Soul",PriestHeal_Target) and not jps.buff("Power Word: Shield",PriestHeal_Target), PriestHeal_Target },
        },
    },
	{ "nested", jps.UseCDs and (POH_countInRaid > countInRaid),
        {
            { "Prayer of Healing", (GetNumGroupMembers() > 0) and jps.canHeal(POH_Target), POH_Target}, -- Raid
			{ "Prayer of Healing", (GetNumGroupMembers()==0) and jps.canHeal(PriestHeal_Target), PriestHeal_Target}, -- Party
    		{ "Prayer of Healing", (GetNumGroupMembers()==0), "player"}, -- Party
        },
    },
-- Emergency player
	{ "nested", (playerhealth_pct < 0.60),
		{
			{ "Desperate Prayer", select(2,GetSpellBookItemInfo("Desperate Prayer"))~=nil and (playerhealth_pct < 0.40), "player" }, -- IsSpellKnown(spellID)
			{ "Pain Suppression", jps.Interrupts and (playerhealth_pct < 0.30), "player"},
			{ "Flash Heal", jps.buff("Inner Focus","player"), "player"},
			{ "Penance", "onCD" , "player"},
			{ "Prayer of Mending", not jps.buff("Prayer of Mending","player") ,"player"},
			{ "Power Word: Shield", not jps.buff("Power Word: Shield","player") and not jps.debuff("Weakened Soul","player"), "player"},
			{ "Greater Heal", borrowed, "player" },
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target, "player")~=1 and (playerhealth_deficiency > average_flashheal) and (jps.LastCast~="Binding Heal"), PriestHeal_Target},
			{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (playerhealth_pct < 0.80) , "player" },
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target, "player")~=1 and (playerhealth_deficiency > average_flashheal), PriestHeal_Target},
			{ "Renew", not jps.buff("Renew", "player"), "player"},
			{ "Power Word: Shield", (health_pct < 0.60) and not jps.debuff("Weakened Soul",PriestHeal_Target) and not jps.buff("Power Word: Shield", PriestHeal_Target) , PriestHeal_Target },
			{ "Flash Heal", "onCD", "player"},
		},
	},
-- Boss Debuff
	{ "Greater Heal", UnitExists(Plasma)==1, Plasma }, -- "Deathwing"
-- Focus Heal
	{ "nested", not switchtoLowestTarget and jps.canHeal(PriestHeal_Target_TANK),
		{
			{ "Pain Suppression", jps.Interrupts and (health_pct_TANK < 0.30), PriestHeal_Target_TANK },
			{ "Penance", stackGrace_TANK < 3 and UnitAffectingCombat("player")==1, PriestHeal_Target_TANK }, 
			{ "Flash Heal", jps.buff("Inner Focus","player") and (health_deficiency_TANK > average_flashheal), PriestHeal_Target_TANK },
			{ "Power Word: Shield", not jps.debuff("Weakened Soul",PriestHeal_Target_TANK) and not jps.buff("Power Word: Shield",PriestHeal_Target_TANK), PriestHeal_Target_TANK },
			{ "Penance", health_deficiency_TANK > (average_penitence + average_renew), PriestHeal_Target_TANK },
			{ "Greater Heal", borrowed and health_deficiency_TANK > (average_flashheal + average_renew), PriestHeal_Target_TANK },
			{ "Prayer of Mending", not jps.buff("Prayer of Mending",PriestHeal_Target_TANK), PriestHeal_Target_TANK },
			{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (health_pct_TANK < 0.80), PriestHeal_Target_TANK },
			{ "Renew", not jps.buff("Renew",PriestHeal_Target_TANK) and (health_deficiency_TANK > average_renew), PriestHeal_Target_TANK },
			{ "Binding Heal", UnitIsUnit(PriestHeal_Target_TANK, "player")~=1 and (playerhealth_deficiency > average_flashheal), PriestHeal_Target_TANK },
			{ "Flash Heal", health_pct_TANK < 0.50 , PriestHeal_Target_TANK },
			{ "Greater Heal", health_deficiency_TANK > (average_flashheal + average_renew), PriestHeal_Target_TANK },
			{ "Heal", (health_pct_TANK < 1), PriestHeal_Target_TANK },
		},
	},
-- Emergency Target
	{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30), PriestHeal_Target },
	{ "Penance", health_deficiency > (average_penitence + average_renew), PriestHeal_Target },
	{ "Flash Heal", jps.buff("Inner Focus","player") and (health_deficiency > average_flashheal), PriestHeal_Target },
	{ "Binding Heal", UnitIsUnit(PriestHeal_Target,"player")~=1 and (playerhealth_deficiency > average_flashheal) and (jps.LastCast~="Binding Heal"), PriestHeal_Target },
	{ "Prayer of Mending", (COH_countInRaid > countInRaid) and not jps.buff("Prayer of Mending", PriestHeal_Target), PriestHeal_Target },
	{ "Prayer of Mending", (health_pct < 0.80) and not jps.buff("Prayer of Mending",PriestHeal_Target), PriestHeal_Target },
	{ "Power Word: Shield", (health_pct < 0.60) and not jps.debuff("Weakened Soul",PriestHeal_Target) and not jps.buff("Power Word: Shield",PriestHeal_Target), PriestHeal_Target },
	{ "Greater Heal", borrowed and health_deficiency > (average_flashheal + average_renew), PriestHeal_Target },
	{ "Binding Heal", UnitIsUnit(PriestHeal_Target,"player")~=1 and (playerhealth_deficiency > average_flashheal), PriestHeal_Target },
	{ "Flash Heal", (health_pct < 0.50), PriestHeal_Target },
-- Basic    
	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru"))~=nil and (health_pct < 0.80), PriestHeal_Target },
	{ "Greater Heal", health_deficiency > (average_flashheal + average_renew) and jps.buff("Renew",PriestHeal_Target) and jps.buffDuration("Renew", PriestHeal_Target) < 3, PriestHeal_Target },
	{ "Greater Heal", health_deficiency > (average_flashheal + average_renew), PriestHeal_Target },
	{ "Renew", not jps.buff("Renew",PriestHeal_Target) and (health_deficiency > average_renew), PriestHeal_Target },
	{ "Renew", jps.buff("Power Word: Shield",PriestHeal_Target) and not jps.buff("Renew",PriestHeal_Target) and health_deficiency < (average_flashheal + average_renew) and health_deficiency > average_heal, PriestHeal_Target },
	{ "Heal", jps.buff("Renew",PriestHeal_Target) and jps.buffDuration("Renew", PriestHeal_Target) < 3 and health_deficiency > (average_heal + average_renew), PriestHeal_Target },
	{ "Heal", health_deficiency > average_renew, PriestHeal_Target },
}

local target = nil
if jps.Moving then
	spell, target = parseSpellTable(spellTable_moving)
else
	spell, target = parseSpellTable(spellTable_main)
end

	jps.Target = target
	return spell
end

-- Inner Focus - Focalisation intérieure
-- Power Infusion - Infusion de puissance
-- Fade - Oubli
-- Mass Dispel - Dissipation de masse
-- Pain Suppression - Suppression de la douleur
-- Gift of the Naaru - Don des naaru
-- Penance - Pénitence
-- Grace - Grâce
-- Divine Aegis - Egide divine - Critical heals and all heals from Prayer of Healing create a protective shield on the target
-- Weakened Soul - Ame affaiblie
-- Divine Hymn - Hymne divin
-- Dispel Magic - Dissipation de la magie
-- Inner Fire - Feu intérieur
-- Serendipity - Heureux hasard
-- Power Word: Fortitude - Mot de pouvoir : Robustesse
-- Fear Ward - Gardien de peur
-- Chakra: Serenity - Chakra : Sérénité
-- Chakra - Chakra
-- Heal - Soins
-- Flash Heal - Soins rapides
-- Binding Heal - Soins de lien
-- Greater Heal - Soins supérieurs
-- Renew - Rénovation
-- Circle of Healing - Cercle de soins
-- Prayer of Healing - Prière de soins
-- Prayer of Mending - Prière de guérison
-- Guardian Spirit - Esprit gardien
-- Cure Disease - Guérison des maladies
-- Desperate Prayer - Prière du désespoir
-- Surge of light - Vague de Lumière
-- Holy Word: Serenity - Mot sacré : Sérénité SpellID 88684
-- Power Word: Shield - Mot de pouvoir : Bouclier
-- Borrowed Time - Sursis - votre prochain sort d'un bonus à la hâte des sorts après avoir lancé Mot de pouvoir : Bouclier. Dure 6 sec.
