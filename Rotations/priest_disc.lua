-- get average heal value from Recount
average_renew = 10000;
average_heal = 9000;
average_greater_heal = 24000; 
average_penitence = 22000;
average_flashheal = 18000;
average_POH = 7600;
average_bindingheal = 12000;
average_POM = 10000;

function priest_disc(self)

----------------------
-- HELPER
----------------------
--IsControlKeyDown(): debug print text
--jps.Defensive: Heal only the Tank et yourself
--jps.MultiTarget : Dispelling
--jps.PVPInterrupt: Damage and offensive dispell
--jps.UseCDs: group heal "Prayer of Healing"
--jps.Interrupts : "Pain Suppression"
--AltKey_IsDown : "Mass Dispel"

local spell = nil
local playerhealth_deficiency = UnitHealthMax("player")-UnitHealth("player")
local playerhealth_pct = UnitHealth("player") / UnitHealthMax("player")

local PriestHeal_Target = jps.lowestInRaidStatus() -- jps.HealingTarget()
local health_deficiency = UnitHealthMax(PriestHeal_Target) - UnitHealth(PriestHeal_Target)
local health_pct = jps.hpInc(PriestHeal_Target) -- UnitHealth(PriestHeal_Target) / UnitHealthMax(PriestHeal_Target)

-- number of party members having a significant health pct loss
local countInRaid = 2
local pctLOSS = 0.80
local POH_countInRaid = jps.countInRaidStatus(pctLOSS)
local COH_countInRaid = jps.countInRaidStatus(0.90) 
local findSubGroup, POH_Target = jps.findSubGroupToHeal(pctLOSS) -- returns the subgroup and the target to heal with POH in RAID

local borrowed = jps.buff("Borrowed Time", "player")
local div_Aegis = jps.buff("Divine Aegis", PriestHeal_Target)

local AltKey_IsDown = false
if IsAltKeyDown() then AltKey_IsDown = true end 

-- if jps.canHeal("focus") then FollowUnit("focus") end

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
	if (PriestHeal_Target_TANK == nil) or (PriestHeal_Target_TANK == "player" and playerhealth_pct > 0.90) or jps.Defensive then PriestHeal_Target_TANK = "focus" end
end

local health_deficiency_TANK = UnitHealthMax(PriestHeal_Target_TANK) - UnitHealth(PriestHeal_Target_TANK)
local health_pct_TANK = jps.hpInc(PriestHeal_Target_TANK) -- UnitHealth(PriestHeal_Target_TANK) / UnitHealthMax(PriestHeal_Target_TANK)
local stackGrace_TANK = jps.buffStacks("Grace",PriestHeal_Target_TANK)

local switchtoLowestTarget = false
if (health_pct < 0.60) or (health_pct_TANK > 0.90 and ub(PriestHeal_Target_TANK,"Renew")) or (health_pct_TANK > 0.90 and stackGrace_TANK > 2) then
	switchtoLowestTarget = true 
end
if jps.Defensive then switchtoLowestTarget = false end

----------------------
-- DAMAGE
----------------------

local rangedTarget = "target"
if  UnitExists("target")==1 and UnitCanAttack("player", "target")== 1 and UnitIsDeadOrGhost("target")~=1 then
rangedTarget = "target"
elseif UnitExists("focustarget")==1 and UnitCanAttack("player", "focustarget")== 1 and UnitIsDeadOrGhost("focustarget")~=1 then
rangedTarget = "focustarget"
elseif UnitExists("targettarget")==1 and UnitCanAttack("player", "targettarget")==1 and UnitIsDeadOrGhost("targettarget")~=1 then
rangedTarget = "targettarget"
end

---------------------
-- DISPEL
---------------------

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

local timer = jps.checkTimer( "Shield" )

-------------------
-- DEBUG
-------------------
-- IsMouseButtonDown([button]) 1 or LeftButton - 2 or RightButton - 3 or MiddleButton or clickable scroll control
-- shiftDown = IsShiftKeyDown() ctrlDown  = IsControlKeyDown() altDown   = IsAltKeyDown()
if IsControlKeyDown() then
print("|cff0070ddFocus","|cffffffff",PriestHeal_Target_TANK,"|cff0070ddTANK: ","|cffffffff",GetUnitName(PriestHeal_Target_TANK),"HP: ",health_deficiency_TANK,"H%: ",health_pct_TANK)
print("|cff0070ddTarget: ","|cffffffff",PriestHeal_Target,"|cff0070ddNAME: ","|cffffffff",GetUnitName(PriestHeal_Target),"HP: ",health_deficiency,"H%: ",health_pct)
print("|cff0070ddDispelMagic:","|cffffffff",dispelMagic_Target,"|cff0070ddDispelOffensive:","|cffffffff",dispelOffensive_Target,"|cff0070ddRangedTarget:","|cffffffff",rangedTarget)
print("|cff0070ddCOH_Count:","|cffffffff",COH_countInRaid,"|cff0070ddPOH_Count:","|cffffffff",POH_countInRaid)
print("|cff0070ddSubGroup:","|cffffffff",findSubGroup,"|cff0070ddPOHTarget:","|cffffffff",POH_Target)
print("|cff0070ddSwitch:","|cffffffff",switchtoLowestTarget,"|cff0070ddTimer: ","|cffffffff",timer)
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
	if  IsEquippedItem("Don souillé du seigneur démon") and select(1,GetItemCooldown(72898))==0 and IsUsableItem("Don souillé du seigneur démon") and UnitAffectingCombat("player")==1 and div_Aegis then 
		RunMacroText("/use Don souillé du seigneur démon")
	elseif IsEquippedItem("Quintessence embrasée") and select(1,GetItemCooldown(69000))==0 and IsUsableItem("Quintessence embrasée") and UnitAffectingCombat("player")==1 then 
		RunMacroText("/use Quintessence embrasée")
	end

------------------------
-- SPELL TABLE ---------
------------------------

local spellTable =
{
-- Buff
	--{{"macro","/cast Inner Fire"}, not ub("player","Inner Fire") and not ub("player","Inner Will"), "player" },
 	{"Inner Fire", not ub("player","Inner Fire") and not ub("player","Inner Will"), "player" },
 	{"Fade", UnitIsPVP("player")~=1 and UnitThreatSituation("player")==3, "player" },
 	{"Power Infusion", (playerhealth_pct < 0.50 or health_pct < 0.50), "player" },
 	{"Inner Focus", UnitAffectingCombat("player")==1 , "player" },
 	{"Fear Ward", UnitIsPVP("player")==1 and not ub("player","Fear Ward"), "player" },
 	{"Power Word: Shield", timer == 0 and not ud(PriestHeal_Target_TANK,"Weakened Soul") and not ub(PriestHeal_Target_TANK,"Power Word: Shield"), PriestHeal_Target_TANK },
-- Moving
 	{"nested", (GetUnitSpeed("player") / 7) > 0,
        {
            	{ "Pain Suppression", jps.Interrupts and (playerhealth_pct < 0.30), "player" },
            	{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30), PriestHeal_Target },
            	{ "Desperate Prayer", (playerhealth_pct < 0.40) , "player" },
            	{ "Power Word: Shield", (playerhealth_pct < 0.60) and not ub("player","Power Word: Shield") and not ud("player","Weakened Soul") , "player" },
         	{ "Power Word: Shield", (health_pct < 0.60) and not ud(PriestHeal_Target,"Weakened Soul") and not ub(PriestHeal_Target,"Power Word: Shield") , PriestHeal_Target },
         	{ "Dispel Magic", jps.MultiTarget and UnitExists(dispelMagic_Target)==1 , dispelMagic_Target },
         	{ "Renew", not ub("player","Renew") and (playerhealth_deficiency > average_renew), "player" },
         	{ "Renew", not ub(PriestHeal_Target,"Renew") and (health_deficiency > average_renew), PriestHeal_Target },
         	{ "Prayer of Mending", not ub("player","Prayer of Mending") and (playerhealth_pct < 0.60), "player" },
         	{ "Prayer of Mending", not ub(PriestHeal_Target,"Prayer of Mending") and (health_pct < 0.60), PriestHeal_Target },
         	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru")) and (playerhealth_pct < 0.80) , "player" },
         	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru")) and (health_pct < 0.80) , PriestHeal_Target }, 	
        },
    	},
-- Dispell
 	{"Mass Dispel", AltKey_IsDown, "player" },
 	{"nested", (health_pct > 0.60) and jps.MultiTarget,
        {
		{"Dispel Magic", dispelMagic_Me and jps.MultiTarget, "player" },
		{"Cure Disease", dispelDisease_Me and jps.MultiTarget, "player" },
		{"Dispel Magic", UnitExists(dispelMagic_Target)==1 and jps.MultiTarget, dispelMagic_Target },
		{"Dispel Magic", dispelMagic_TANK and jps.MultiTarget, PriestHeal_Target_TANK },
		{"Cure Disease", dispelDisease_TANK and jps.MultiTarget, PriestHeal_Target_TANK },
		{"Cure Disease", dispelDisease_Target and jps.MultiTarget, PriestHeal_Target },
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
	{ "Power Infusion", (health_pct < 0.40), "player"},
	{ "Prayer of Mending", (health_pct < 0.60) and not ub(PriestHeal_Target,"Prayer of Mending") and (jps.LastCast=="Prayer of Healing"), PriestHeal_Target },
	{ "Pain Suppression", jps.Interrupts and (health_pct_TANK < 0.30) and (jps.LastCast=="Prayer of Healing"), PriestHeal_Target_TANK },
	{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30) and (jps.LastCast=="Prayer of Healing"), PriestHeal_Target },
	{ "Penance", (health_pct_TANK < 0.40) and (jps.LastCast=="Prayer of Healing"), PriestHeal_Target_TANK },
	{ "Penance", (health_pct < 0.40) and (jps.LastCast=="Prayer of Healing"), PriestHeal_Target },
	{ "Binding Heal", UnitIsUnit(PriestHeal_Target, "player")~=1 and (health_pct < 0.30) and (playerhealth_deficiency > 2*average_bindingheal) and (jps.LastCast=="Prayer of Healing"), PriestHeal_Target},
 	{ "nested", jps.UseCDs and (GetNumRaidMembers() > 0) and (findSubGroup > 0),
        {
            	{ "Prayer of Healing", jps.canHeal(POH_Target), POH_Target},
            	{ "Prayer of Healing", "onCD", "player"},
        },
   	},
   	{ "nested", jps.UseCDs and (GetNumRaidMembers()==0) and (POH_countInRaid > countInRaid),
        {
            	{ "Prayer of Healing", jps.canHeal(PriestHeal_Target), PriestHeal_Target},
            	{ "Prayer of Healing", "onCD", "player"},
        },
    	},
-- Emergency player
    	{"Desperate Prayer", select(2,GetSpellBookItemInfo("Desperate Prayer")) and (playerhealth_pct < 0.40), "player" },
    	{"Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru")) and (playerhealth_pct < 0.80), "player" },
    	{"nested", jps.Defensive and (playerhealth_pct < 0.60),
        {
            	{ "Pain Suppression", jps.Interrupts and (playerhealth_pct < 0.30), "player"},
            	{ "Flash Heal", jps.buff("Inner Focus","player"), "player"},
            	{ "Penance", "onCD" , "player"},
            	{ "Power Word: Shield", not ub("player","Power Word: Shield") and not ud("player","Weakened Soul"), "player"},
            	{ "Greater Heal", borrowed, "player" },
            	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru")) and (playerhealth_pct < 0.80) , "player" },
            	{ "Prayer of Mending", not ub("player","Prayer of Mending") ,"player"},
            	{ "Binding Heal", UnitIsUnit(PriestHeal_Target, "player")~=1 and (playerhealth_deficiency > 2*average_bindingheal), PriestHeal_Target},
            	{ "Flash Heal", "onCD", "player"},
        },
    	},
-- Focus Heal
    	{"Power Word: Shield", UnitIsUnit(PriestHeal_Target_TANK, "focustargettarget")~=1 and jps.canHeal("focustargettarget") and not ud("focustargettarget","Weakened Soul") and not ub("focustargettarget","Power Word: Shield"), "focustargettarget"}, 
    	{"nested", not switchtoLowestTarget and jps.canHeal(PriestHeal_Target_TANK) and (not jps.PlayerIsBlacklisted(PriestHeal_Target_TANK)),
        {
        	{ "Pain Suppression", jps.Interrupts and (health_pct_TANK < 0.30), PriestHeal_Target_TANK },
            	{ "Penance", stackGrace_TANK < 3 and UnitAffectingCombat("player")==1, PriestHeal_Target_TANK }, 
            	{ "Flash Heal", jps.buff("Inner Focus","player") and health_deficiency_TANK > (average_flashheal + average_renew) , PriestHeal_Target_TANK },
            	{ "Power Word: Shield", not ud(PriestHeal_Target_TANK,"Weakened Soul") and not ub(PriestHeal_Target_TANK,"Power Word: Shield"), PriestHeal_Target_TANK },
            	{ "Penance", health_deficiency_TANK > average_penitence, PriestHeal_Target_TANK },
            	{ "Greater Heal", borrowed and health_deficiency_TANK > (average_greater_heal + average_renew), PriestHeal_Target_TANK },
            	{ "Prayer of Mending", not ub(PriestHeal_Target_TANK,"Prayer of Mending"), PriestHeal_Target_TANK },
            	{ "Binding Heal", UnitIsUnit(PriestHeal_Target_TANK, "player")~=1 and (playerhealth_deficiency > 2*average_bindingheal), PriestHeal_Target_TANK },
            	{ "Flash Heal", health_pct_TANK < 0.60 , PriestHeal_Target_TANK },
            	{ "Greater Heal", health_deficiency_TANK > (average_greater_heal + average_renew), PriestHeal_Target_TANK },
            	{ "Renew", not ub(PriestHeal_Target_TANK,"Renew"), PriestHeal_Target_TANK },
            	{ "Binding Heal", UnitIsUnit(PriestHeal_Target,"player")~=1 and (playerhealth_deficiency > 2*average_bindingheal), PriestHeal_Target },
            	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru")) and (health_pct_TANK < 0.80), PriestHeal_Target_TANK },
            	{ "Heal", (health_pct_TANK < 1), PriestHeal_Target_TANK },
        },
    	},
-- Emergency Target
    	{ "Pain Suppression", jps.Interrupts and (health_pct < 0.30) , PriestHeal_Target },
    	{ "Penance", health_deficiency > (average_penitence + average_renew), PriestHeal_Target },
    	{ "Flash Heal", jps.buff("Inner Focus","player") and health_deficiency > (average_flashheal + average_renew) , PriestHeal_Target },
    	{ "Greater Heal", borrowed and health_deficiency > (average_greater_heal + average_renew), PriestHeal_Target },
    	{ "Binding Heal", UnitIsUnit(PriestHeal_Target,"player")~=1 and (playerhealth_deficiency > 2*average_bindingheal), PriestHeal_Target },
    	{ "Power Word: Shield", (health_pct < 0.60) and not ud(PriestHeal_Target,"Weakened Soul") and not ub(PriestHeal_Target,"Power Word: Shield"), PriestHeal_Target },
    	{ "Prayer of Mending", (health_pct < 0.60) and not ub(PriestHeal_Target,"Prayer of Mending"), PriestHeal_Target }, 
    	{ "Flash Heal", (health_pct < 0.60), PriestHeal_Target },
-- Boss Debuff
	{ "Greater Heal", UnitExists(Plasma)==1 , Plasma }, -- "Deathwing"
-- Basic    
	{ "Gift of the Naaru", select(2,GetSpellBookItemInfo("Gift of the Naaru")) and (health_pct < 0.80), PriestHeal_Target },
    	{ "nested", health_deficiency > (average_greater_heal + average_renew), 
	{
		{ "Greater Heal", ub(PriestHeal_Target,"Renew") and jps.buffDuration("Renew", PriestHeal_Target) < 3 , PriestHeal_Target },
		{ "Greater Heal", not ub(PriestHeal_Target,"Renew") , PriestHeal_Target },
		{ "Greater Heal", "onCD" , PriestHeal_Target },
	}
	},
	{ "Renew", not ub(PriestHeal_Target,"Renew") and (health_deficiency > average_renew) , PriestHeal_Target },
	{ "Renew", ub(PriestHeal_Target,"Power Word: Shield") and health_deficiency < (average_penitence + average_renew) and health_deficiency > average_heal and not ub(PriestHeal_Target,"Renew") , PriestHeal_Target },
	{ "Heal", ub(PriestHeal_Target,"Renew") and jps.buffDuration("Renew", PriestHeal_Target) < 3 and health_deficiency > (average_heal + average_renew) , PriestHeal_Target },
	{ "Heal", (health_deficiency > average_renew) , PriestHeal_Target },
}

	local spell,target = parseSpellTable(spellTable)
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

