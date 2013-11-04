local L = MyLocalizationTable

--function priest_disc_pve()
jps.registerRotation("PRIEST","DISCIPLINE",function()

----------------------
-- Average heal
----------------------

-- local average_renew = getaverage_heal(L["Renew"])
-- local average_heal = getaverage_heal(L["Heal"])
-- local average_greater_heal = getaverage_heal(L["Greater Heal"])
-- local average_penitence = getaverage_heal(L["Penance"])
local average_flashheal = math.max(90000 , getaverage_heal(L["Flash Heal"]))

----------------------
-- HELPER
----------------------

local SpiritShell = tostring(select(1,GetSpellInfo(114908))) -- buff target Spirit Shell 114908
local PrayerofHealing = tostring(select(1,GetSpellInfo(596))) -- "Prière de soins" 596
local NaaruGift = tostring(select(1,GetSpellInfo(59544))) -- NaaruGift 59544
local Desesperate = tostring(select(1,GetSpellInfo(19236))) -- "Prière du désespoir" 19236
local BindingHeal = tostring(select(1,GetSpellInfo(32546))) -- "Soins de lien" 32546
local Grace = tostring(select(1,GetSpellInfo(77613))) -- Grâce 77613 -- jps.buffStacks(Grace,jps_TANK)
local DivineAegis =  tostring(select(1,GetSpellInfo(47753))) -- Egide Divine 47515 - 47753

----------------------------
-- TANK
----------------------------

local spell = nil
local target = nil
local player = jpsName
local playerhealth_deficiency =  jps.hpAbs(player,"abs") -- UnitHealthMax(player) - UnitHealth(player)
local playerhealth_pct = jps.hpAbs(player)
local manapool = UnitPower(player,0)/UnitPowerMax (player,0)
local TimeToDiePlayer = jps.UnitTimeToDie("player")

local jps_TANK = priest.jpsTank()
local health_deficiency_TANK = jps.hpAbs(jps_TANK,"abs") -- UnitHealthMax(jps_TANK) - UnitHealth(jps_TANK)
local health_pct_TANK = jps.hpAbs(jps_TANK)

---------------------
-- TIMER
---------------------

-- Number of party members having a significant health pct loss
local countInRange = jps.CountInRaidStatus(0.90)
local countInRaid = jps.CountInRaidStatus(0.75)
local POH_Target = jps.FindSubGroupTarget(0.75) -- Target to heal with POH in RAID AT LEAST 3 RAID UNIT of the SAME GROUP IN RANGE with HEALTH pct < 0.80
local groupToHeal = (IsInGroup() and not IsInRaid() and (countInRaid > 2)) or (IsInRaid() and type(POH_Target) == "string") -- return true false
local Shell_Target = priest.FindSubGroupAura(114908,jps_TANK) -- buff target Spirit Shell 114908 need SPELLID
-- Timer
local timerShield = jps.checkTimer("Shield")
local player_Aggro = jps.checkTimer("Player_Aggro")
local player_IsInterrupt = jps.checkTimer("Spell_Interrupt")
-- Local
local stunMe = jps.StunEvents() -- return true/false ONLY FOR PLAYER
local isAlone = (GetNumGroupMembers() == 0) and UnitAffectingCombat(player)==1
local isInBG = (((GetNumGroupMembers() > 0) and (UnitIsPVP(player) == 1) and UnitAffectingCombat(player)==1)) or isAlone
local isInPvE = (GetNumGroupMembers() > 0) and (UnitIsPVP(player) ~= 1) and UnitAffectingCombat(player)==1
local enemycount,targetcount = jps.RaidEnemyCount()

----------------------
-- DAMAGE
----------------------

local FriendTable = {}  -- Table of Friends Name targeted by an Enemy
for unit,index in pairs(jps.EnemyTable) do 
	FriendTable[index.friend] = { ["enemy"] = unit }
end

local FriendUnit = {}
for name,index in pairs(jps.RaidStatus) do 
if (index["inrange"] == true) then table.insert(FriendUnit,name) end
end

-- JPS.CANDPS NE MARCHE QUE POUR PARTYn et RAIDn..TARGET PAS POUR UNITNAME..TARGET
local EnemyUnit = {}
for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end
local rangedTarget = priest.rangedTarget()

local isBoss = (UnitLevel(rangedTarget) == -1) or (UnitClassification(rangedTarget) == "elite")
local isEnemy = jps.canDPS(rangedTarget) and (jps.UnitTimeToDie(rangedTarget) > 12) -- jps.TimeToDie(rangedTarget)
local canCastShadowfiend = isEnemy  or isBoss

---------------------
-- FIREHACK
---------------------

local canFear = false 
if isInBG and jps.canDPS(rangedTarget) and (CheckInteractDistance(rangedTarget,3) == 1) then canFear = true end

local knownTypes = {[0]="player", [1]="world object", [3]="NPC", [4]="pet", [5]="vehicle"}
local rangedTargetGuid = UnitGUID(rangedTarget)
if jps.FaceTarget and jps.canDPS(rangedTarget) then 
	if FireHack and rangedTargetGuid ~= nil then
		local rangedTargetObject = GetObjectFromGUID(rangedTargetGuid)
		local knownType = tonumber(rangedTargetGuid:sub(5,5), 16) % 8
		if (knownTypes[knownType] ~= nil) then
			rangedTargetObject:Target()
			if (rangedTargetObject:GetDistance() > 8) then canFear = false end
		end
	else
		jps.Macro("/target "..rangedTarget)
	end
end

---------------------
-- CROWD CONTROL & DEBUFF
---------------------


local function unitFor_InnerFocus_Event() -- Target is targeting Me with a CC spell
	local parse_CrowdControl = { 89485 , false , nil , "Foca_Event_CC_" }
	if jps.cooldown(89485) ~= 0 then return parse_CrowdControl end
	if jps.CrowdControl == true then
		if UnitIsUnit( jps.CrowdControlTarget.."target", "player")==1 then 
			parse_CrowdControl[2] = true
			parse_CrowdControl[3] = jps.CrowdControlTarget
		end
	end
	return parse_CrowdControl
end

local function unitFor_InnerFocus_Enemy() -- Enemy is targeting Me with a CC spell
	local Foca_Table = { 89485, false , nil , "Foca_MultiUnit_" }
	if jps.cooldown(89485) ~= 0 then return Foca_Table end
	if  jps.tableLength(EnemyUnit) == 0 then return Foca_Table end
	for _,unit in pairs(EnemyUnit) do
		local iscasting = jps.IsCastingControl(unit)
		if iscasting and (UnitIsUnit(unit.."target","player")==1) then 
			Foca_Table[2] = true
			Foca_Table[3] = unit
		break end
	end
	return Foca_Table
end

local function unitLoseControl(unit) -- {"CC", "Snare", "Root", "Silence", "Immune", "ImmuneSpell", "Disarm"}
	if jps.LoseControl(unit,"CC") then return true end
	if jps.LoseControl(unit,"Silence") then return true end
	return false
end

-------------------
-- DEBUG
-------------------

 if IsControlKeyDown() then
	--print("|cff0070ddTimeToDiePlayer:","|cffffffff",TimeToDiePlayer)
	print("|cff0070ddTANK","|cffffffff",jps_TANK,"|cff0070ddHpct:","|cffffffff",health_pct_TANK)
	print("|cff0070ddcountInRange:","|cffffffff",countInRange,"|cff0070ddcountInRaid:","|cffffffff",countInRaid)
	print("|cff0070ddShell_Target:","|cffffffff",Shell_Target,"|cff0070ddPOH_Target: ","|cffffffff",POH_Target)
	print("|cff0070ddTimer:","|cffffffff",timerShield,"|cff0070ddFlash_Heal","|cffffffff",average_flashheal)
 end

------------------------
-- LOCAL FUNCTIONS DMG
------------------------

local function unitFor_ShadowWordDeath(unit)
	if unit == nil then return false end
	if isInPvE then return false end
	if not jps.canDPS(unit) then return false end
	if jps.cooldown(32379) ~= 0 then return false end
	if (UnitHealth(unit)/UnitHealthMax(unit) > 0.20) then return false end
	return true
end

------------------------
-- LOCAL FUNCTIONS HEAL
------------------------

local function unitFor_Flash()
	local Foca_Table = { 2061, false , nil , "Soins Rapides_Foca_MultiUnit_" }
	for _,unit in pairs(FriendUnit) do
		if jps.buff(114255) and (jps.buffDuration(114255) < 4) then
			Foca_Table[2] = true
			Foca_Table[3] = unit
		elseif jps.buffId(89485) and (jps.hp(unit,"abs") > average_flashheal) then 
			Foca_Table[2] = true
			Foca_Table[3] = unit
		elseif jps.buffId(89485) and not jps.buff(DivineAegis,unit) then
			Foca_Table[2] = true
			Foca_Table[3] = unit
		break end
	end
	return Foca_Table
end

local function unitFor_Foca_Flash()
	local Foca_Table = { 2061, false , jps_TANK , "FOCA_BUFF" }
	if not jps.buffId(96267) then return Foca_Table end
	-- "Soins supérieurs" 2060 -- buff player 96267 Immune to Silence, Interrupt and Dispel effects 5 seconds remaining
	if isInBG and jps.buffId(96267) and (jps.buffDuration(96267) > 2.5) and (health_pct_TANK > 0.35) then
		Foca_Table[1] =  2060
		Foca_Table[2] =  true
	-- "Soins rapides" 2061 -- buff player 96267 Immune to Silence, Interrupt and Dispel effects 5 seconds remaining
	elseif isInBG and jps.buffId(96267) and (jps.buffDuration(96267) > 1.5) then
		Foca_Table[1] =  2061
		Foca_Table[2] =  true
	end
return Foca_Table
end

local function unitFor_SpiritShell(unit) -- Applied to FriendUnit
	if unit == nil then return false end
	if countInRaid > 0 then return false end
	if (FriendTable[unit] == nil) then return false end
	if jps.hp(unit) < 0.95 then return false end
	return true
end

local function unitFor_Binding(unit)
	if unit == nil then return false end
	if (UnitIsUnit(unit,"player")==1) then return false end
	if (UnitHealthMax(unit) - UnitHealth(unit)) < average_flashheal  then return false end
	if (playerhealth_deficiency < average_flashheal) then return false end 
	if (jps.LastCast == BindingHeal) then return false end
	return true
end

local function unitFor_Mending(unit)
	if unit == nil then return false end
	if (FriendTable[unit] == nil) then return false end
	if (jps.cooldown(33076) > 0) then return false end
	if jps.buff(33076,unit) then return false end
	if UnitGetTotalAbsorbs(unit) > average_flashheal then return false end
	return true
end

local function unitFor_Leap(unit) -- {"CC", "Snare", "Root", "Silence", "Immune", "ImmuneSpell", "Disarm"}
	if isInPvE then return false end
	if (UnitIsUnit(unit,"player")==1) then return false end
	if jps.glyphInfo(119850) and unitLoseControl(unit) then return true end
	return false
end

local function unitFor_Dispel(unit) -- {"CC", "Snare", "Root", "Silence", "Immune", "ImmuneSpell", "Disarm"}
	if jps.MagicDispel(unit,"Magic") and jps.LoseControl(unit,"CC") then return true end
	if jps.MagicDispel(unit,"Magic") and jps.LoseControl(unit,"Snare") then return true end
	if jps.MagicDispel(unit,"Magic") and jps.LoseControl(unit,"Root") then return true end
	return false
end

local function unitFor_Shield(unit)
	if timerShield > 0 then return false end
	if (FriendTable[unit] == nil) then return false end
	if not jps.debuff(6788,unit) and not jps.buff(17,unit) then return true end
	return false
end

------------------------
-- LOCAL TABLE FUNCTIONS
------------------------

local function parse_dispel()
	-- "Purifier" 527 Purify -- WARNING THE TABLE NEED A VALID MASSAGE TO CONCATENATE IN PARSEMULTIUNITTABLE
	-- function jps.DispelFriendlyTarget() returns same unit & condition as jps.DispelFriendly(unit) 
	-- These two functions dispel SOME DEBUFF of FriendUnit according to a debuff table jps_DebuffToDispel_Name 
	-- EXCEPT if unit is affected by some debuffs "Unstable Affliction" , "Lifebloom" , "Vampiric Touch"
	-- we can add others cond like UnitIsPVP(player)==1 with jps.DispelFriendlyTarget() -- { "Purify", jps.canHeal(dispelFriendly_Target) and (UnitIsPVP(player) == 1) , dispelFriendly_Target },
	-- jps.DispelFriendly(unit) is a function must be alone in condition but the target can be a table 
	-- { "Purify", jps.DispelFriendly , FriendUnit },  or { "Purify", jps.DispelFriendly , {player,Heal_TANK} },

	-- function jps.DispelMagicTarget() returns same unit & condition as jps.MagicDispel(unit)
	-- these two functions dispel ALL DEBUFF of FriendUnit
	-- we can add others cond. like UnitIsPVP(player)==1 with jps.DispelMagicTarget() -- { "Purify" , jps.canHeal(dispelMagic_Target) and (UnitIsPVP(player) == 1) , dispelMagic_Target}, 
	-- jps.MagicDispel(unit) is a function must be alone in condition but the target can be a table 
	-- { "Purify", jps.MagicDispel , FriendUnit }, or { "Purify", jps.MagicDispel , {player,"focus","mouseover"} },
local table=
{
	-- "Mass Dispel" 32375 "Dissipation de masse"

	-- "Leap of Faith" 73325 -- "Saut de foi" -- "Leap of Faith" with Glyph dispel Stun -- jps.glyphInfo(119850)
	{ 73325 , unitFor_Leap , FriendUnit , "Leap_LoseControl_MultiUnit_" }, -- unitFor_Leap includes if isInPvE then return false end
	-- OFFENSIVE Dispel -- "Dissipation de la magie" 528 -- FARMING OR PVP -- NOT PVE
	{ 528, isInBG and jps.DispelOffensive(rangedTarget) , rangedTarget, "|cFFFF0000dispel_Offensive_"..rangedTarget },
	{ 528 , jps.DispelOffensive , EnemyUnit , "|cFFFF0000dispel_Offensive_MultiUnit_" },
	-- Dispel "Purifier" 527
	{ 527, jps.DispelFriendly , FriendUnit , "|cFFFF0000dispelFriendly_MultiUnit_" }, -- jps.DispelFriendly is a function must be alone in condition
	{ 527, unitFor_Dispel , FriendUnit , "|cFFFF0000dispelMagic_MultiUnit_" },
	{ 527, jps.MagicDispel , {player,jps_TANK} , "|cFFFF0000dispelMagic_MultiUnit_" }, -- jps.MagicDispel is a function must be alone in condition -- Dispel all Magic debuff

}
return table
end

local function parse_dmg()
local table=
{
	-- DAMAGE "Mot de l'ombre : Mort" 32379 -- FARMING OR PVP -- NOT PVE
	{ 32379, isInBG and jps.IsCastingPoly(rangedTarget) and unitFor_ShadowWordDeath(rangedTarget) , rangedTarget , "|cFFFF0000castDeath_Polymorph_"..rangedTarget },
	{ 32379, unitFor_ShadowWordDeath, EnemyUnit , "|cFFFF0000castDeath_MultiUnit_" },
	{ 32379, isInBG and jps.canDPS(rangedTarget) and (UnitHealth(rangedTarget)/UnitHealthMax(rangedTarget) < 0.20) , rangedTarget, "|cFFFF0000castDeath_"..rangedTarget },
	-- "Flammes sacrées" 14914 -- "Evangélisme" 81661
	{ 14914, jps.canDPS(rangedTarget) , rangedTarget , "|cFFFF0000DPS_Flammes_"..rangedTarget },
	{ 14914, jps.canDPS , EnemyUnit , "|cFFFF0000DPS_Flammes_MultiUnit_" },
	-- "Mot de pouvoir : Réconfort" -- "Power Word: Solace" 129250 -- REGEN MANA
	--{ 129250, jps.canDPS(rangedTarget) , rangedTarget, "|cFFFF0000DPS_Solace_"..rangedTarget },
	--{ 129250, jps.canDPS , EnemyUnit, "|cFFFF0000DPS_Solace_MultiUnit_" },
	-- "Pénitence" 47540
	{ 47540, jps.canDPS(rangedTarget) , rangedTarget, "|cFFFF0000DPS_Penance_"..rangedTarget },
	-- "Mot de l'ombre: Douleur" 589
	{ 589, isInBG and jps.canDPS(rangedTarget) and jps.myDebuffDuration(589,rangedTarget) == 0 , rangedTarget , "|cFFFF0000DPS_Douleur_"..rangedTarget },
	-- "Cascade" 121135 "Escalade"
	{ 121135, isInBG and jps.canDPS(rangedTarget) and (enemycount > 2) , rangedTarget , "|cFFFF0000DPS_Cascade_"..rangedTarget },
	-- "Châtiment" 585	
	{ 585, jps.canDPS(rangedTarget) , rangedTarget, "|cFFFF0000DPS_Chatiment_"..rangedTarget },
}
return table
end

local function parse_player_aggro() -- return table
	local table=
	{
		-- "Suppression" 33206 "Shield" 17 
		{ {"macro",{33206,17},"player"}, (playerhealth_pct < 0.40) and jps.cooldown(33206)==0 and (jps.cooldown(17) == 0) and not jps.debuff(6788,player) and not jps.buff(17,player) , player , "|cff0070ddSequence_Pain_Shield_"..player  },
		-- "Suppression de la douleur" 33206 Pain Suppression
		{ 33206, stunMe and (playerhealth_pct < 0.55) , player , "Stun_Pain_" },
		{ 33206, (playerhealth_pct < 0.35) , player , "Aggro_Pain_" },
		-- "Oubli" 586 "Shield" 17 -- PVP
		{ {"macro",{586,17},"player"}, IsSpellKnown(108942) and (jps.cooldown(586) == 0) and (jps.cooldown(17) == 0) and not jps.debuff(6788,player) and not jps.buff(17,player) , player , "|cff0070ddSequence_Oubli_Shield_"..player },
		-- "Oubli" 586 -- PVP -- Fantasme 108942 -- vous dissipez tous les effets affectant le déplacement sur vous-même et votre vitesse de déplacement ne peut être réduite pendant 5 s
		{ 586, IsSpellKnown(108942) and (not jps.buffId(96267)), player , "Aggro_Oubli_" },
		-- "Shield" 17 
		{ 17, (playerhealth_deficiency > average_flashheal) and not jps.buff(17,player) and not jps.debuff(6788,player) , player , "Aggro_Shield_" },
		-- "Focalisation intérieure" 89485 -- buff player 96267 Immune to Silence, Interrupt and Dispel effects 5 seconds remaining
		{ 89485, UnitAffectingCombat(player)==1 , player , "Aggro_Foca_" },
	}
return table
end

local function parse_emergency_TANK() -- return table -- (health_pct_TANK < 0.55)
	local table=
	{
		-- "Suppression de la douleur" 33206
		{ 33206, (health_pct_TANK < 0.35) , jps_TANK , "Emergency_Pain_"..jps_TANK },
		-- "Soins supérieurs" 2060 -- buff player 96267 Immune to Silence, Interrupt and Dispel effects 5 seconds remaining
		{ 2060, isInBG and (health_pct_TANK > 0.35) and jps.buffId(96267) and (jps.buffDuration(96267) > 2.5) , jps_TANK , "Emergency_Soins Sup_FocaBuff_"..jps_TANK },
		-- "Soins rapides" 2061 -- buff player 96267 Immune to Silence, Interrupt and Dispel effects 5 seconds remaining
		{ 2061, isInBG and jps.buffId(96267) and (jps.buffDuration(96267) > 1.5) , jps_TANK , "Emergency_Soins Rapides_FocaBuff_"..jps_TANK },
		-- "Soins rapides" 2061 "From Darkness, Comes Light" 109186 gives buff -- "Vague de Lumière" 114255 "Surge of Light"
		{ 2061, jps.buff(114255) , jps_TANK, "Emergency_Soins Rapides_Waves_"..jps_TANK },
		-- "Shield" 17
		{ 17, not jps.debuff(6788,jps_TANK) and not jps.buff(17,jps_TANK) , jps_TANK , "Emergency_Shield_"..jps_TANK },
		-- "Soins supérieurs" 2060 -- "Sursis" 59889 "Borrowed"
		{ 2060, (health_pct_TANK > 0.35) and jps.buff(59889,player) , jps_TANK , "Emergency_Soins Sup_Borrowed_"..jps_TANK },
		-- "Soins rapides" 2061 -- "Sursis" 59889 "Borrowed"
		{ 2061, jps.buff(59889,player) , jps_TANK , "Emergency_Soins Rapides_Borrowed_"..jps_TANK },
		-- "Penance" 47540
		{ 47540, true , jps_TANK , "Emergency_Penance_"..jps_TANK },
		-- "Soins rapides" 2061 -- "Focalisation intérieure" 89485
		{ 2061, jps.buffId(89485) , jps_TANK , "Emergency_Soins Rapides_Foca_"..jps_TANK },
		-- "Prière de guérison" 33076
		{ 33076, not jps.buff(33076,jps_TANK) , jps_TANK , "Emergency_Mending_"..jps_TANK },
		-- "Cascade" 121135
		{ 121135, (UnitIsUnit(jps_TANK,player)~=1) and countInRaid > 2 , jps_TANK , "Emergency_Cascade_"..jps_TANK },
		-- "Soins rapides" 2061
		{ 2061, (health_pct_TANK < 0.35) , jps_TANK , "Emergency_Soins Rapides_35%_"..jps_TANK },
		-- "Soins supérieurs" 2060 
		{ 2060, (health_pct_TANK > 0.35) , jps_TANK , "Emergency_Soins Sup_"..jps_TANK },
		-- "Soins de lien"
		{ 32546 , unitFor_Binding(jps_TANK) , jps_TANK , "Emergency_Lien_MultiUnit_" },
		-- jps.MagicDispel
		{ 527, jps.MagicDispel(jps_TANK) , jps_TANK, "Emergency_dispelMagic_"..jps_TANK }, 
		-- "Don des naaru"
		{ 59544, select(2,GetSpellBookItemInfo(NaaruGift))~=nil , jps_TANK , "Emergency_Naaru_"..jps_TANK },
		-- "Renew"
		{ 139, not jps.buff(139,jps_TANK) , jps_TANK , "Emergency_Renew_"..jps_TANK },
		-- "Flammes sacrées" 14914
		{ 14914, jps.canDPS(rangedTarget) , rangedTarget , "|cFFFF0000Emergency_DPS_Flammes_"..rangedTarget },
	}
return table
end

-- SS se cumule avec DA(Divine Aegis) Bouclier protecteur si soins critiques
-- sous SS Les soins critiques de Focalisation ne donnent plus DA pour Soins Rapides, Sup, POH. Seul Penance sous SS peut donner DA
-- SS Max Absorb = 60% UnitHealthMax(player)
-- SS is affected by Archangel
-- SS Scales with  Grace
local function parse_shell() -- return table -- spell & buff player Spirit Shell 109964 -- buff target Spirit Shell 114908
	local table=
	{
	--TANK not Buff Spirit Shell 114908
		-- "Soins rapides" 2061 "From Darkness, Comes Light" 109186 gives buff -- "Vague de Lumière" 114255 "Surge of Light"
		{ 2061, jps.buff(114255) , jps_TANK, "Carapace_Soins Rapides_Waves_"..jps_TANK },
		-- POH
		{ 596, (jps.LastCast~=PrayerofHealing) and jps.canHeal(Shell_Target) , Shell_Target , "Carapace_POH_Target_" },
		-- "Soins rapides" -- 4P PvP mana cost flash heal 50% with SpiritShell
		{ 2061, isInBG and (not jps.buffId(114908,jps_TANK)) and (FriendTable[jps_TANK] ~= nil) , jps_TANK , "Carapace_NoBuff_Soins Rapides_"..jps_TANK },
		-- "Soins supérieurs" 2060
		{ 2060, isInPvE and (not jps.buffId(114908,jps_TANK)) and (FriendTable[jps_TANK] ~= nil) , jps_TANK , "Carapace_NoBuff_Soins Sup_"..jps_TANK },		
	--TANK Buff Spirit Shell 114908
		-- "Soins" 2050
		{ 2050, jps.buffId(114908,jps_TANK) and (UnitGetTotalAbsorbs(jps_TANK) > 40000) , jps_TANK , "Carapace_Buff_Soins_"..jps_TANK },
		-- "Soins supérieurs" 2060
		{ 2060, isInPvE and jps.buffId(114908,jps_TANK) and (UnitGetTotalAbsorbs(jps_TANK) < average_flashheal) , jps_TANK , "Carapace_Buff_Soins Sup_"..jps_TANK },
		-- "Soins Rapides" 2061 -- 4P PvP mana cost flash heal 50%
		{ 2061, isInBG and jps.buffId(114908,jps_TANK) and (UnitGetTotalAbsorbs(jps_TANK) < average_flashheal) , jps_TANK , "Carapace_Buff_Soins Rapides_"..jps_TANK },
		-- "Soins" 2050
		{ 2050, jps.buffId(114908,jps_TANK) , jps_TANK , "Carapace_Buff_SoinsAbs_"..jps_TANK },
	}
return table
end

local function parse_shield() -- return table
	local table=
	{
		{ 17, timerShield == 0 and not jps.debuff(6788,jps_TANK) and not jps.buff(17,jps_TANK) , jps_TANK , "Shield_Timer_"..jps_TANK },
		{ 17, unitFor_Shield , FriendUnit , "Shield_MultiUnit_" },
	}
	return table
end

local function parse_mending() -- return table
	local table=
	{
		{ 33076, (health_deficiency_TANK > average_flashheal) and (UnitGetTotalAbsorbs(jps_TANK) == 0) and not jps.buff(33076,jps_TANK) , jps_TANK , "Mending_Health_"..jps_TANK },
		{ 33076, unitFor_Mending , FriendUnit , "Mending_MultiUnit_" },
	}
return table
end

local function parse_POH() -- return table -- AT LEAST 3 FRIENDUNIT IN THE SAME GROUP WITH HEALTH_PCT < 0.75
	local table=
	{
		{ 121135,(UnitIsUnit(jps_TANK,player)~=1) , jps_TANK , "Cascade_POH_"..jps_TANK },
		-- CancelUnitBuff(player,SpiritShell)
		{ {"macro","/cancelaura "..SpiritShell,"player"}, jps.buffId(109964) , player , "POH_Macro_CancelAura_Carapace_" }, 
		{ "nested", (jps.LastCast==PrayerofHealing) , parse_mending() },
		{ 17, (jps.LastCast==PrayerofHealing) and not jps.buff(59889,player) and not jps.debuff(6788,jps_TANK) and not jps.buff(17,jps_TANK), jps_TANK , "Shield_POH_"..jps_TANK },	-- "Sursis" 59889 "Borrowed"
		{ 17, (jps.LastCast==PrayerofHealing) and not jps.buff(59889,player)  and not jps.buff(17,player) and not jps.debuff(6788,player) , player , "Shield_POH_"..player }, -- si le jps_TANK est debuff Ame affaiblie et pas jps.buff(59889,player)
		{ "nested", (jps.LastCast==PrayerofHealing) and (health_pct_TANK < 0.35) , parse_emergency_TANK() },
		{ 596, IsInRaid() and jps.canHeal(POH_Target), POH_Target , "POH_Raid_" }, -- Raid
		{ 596, IsInGroup() and not IsInRaid() and jps.canHeal(jps_TANK), jps_TANK , "POH_Party_"..jps_TANK }, -- Party
		{ 596, IsInGroup() and not IsInRaid() , player , "POH_Party_"..player }, -- Party 
	}
return table
end

local function parse_flasheal() -- return table
local table=
{
	{ 2061, jps.buffId(89485,player) and (health_deficiency_TANK > average_flashheal) , jps_TANK , "Soins Rapides_Foca_"..jps_TANK }, -- "Focalisation intérieure" 89485
	{ 2061, jps.buff(59889,player) and (health_deficiency_TANK > average_flashheal) , jps_TANK , "Soins Rapides_Borrowed_"..jps_TANK }, -- "Sursis" 59889 "Borrowed"
	{ 2061, (health_deficiency_TANK > average_flashheal) , jps_TANK , "Soins Rapides_"..jps_TANK },
}
return table
end

local function parse_greatheal() -- return table
local table=
{
	{ 2060, jps.buffId(89485,player) and (health_deficiency_TANK > average_flashheal) , jps_TANK, "Soins Sup_Foca_"..jps_TANK  },
	{ 2060, jps.buff(59889,player) and (health_deficiency_TANK > average_flashheal) , jps_TANK, "Soins Sup_Borrowed_"..jps_TANK  },
	{ 2060, (health_deficiency_TANK > average_flashheal) , jps_TANK, "Soins Sup_"..jps_TANK  },
}
return table
end

----------------------------------------------------------
-- TRINKETS -- OPENING -- CANCELAURA -- SPELLSTOPCASTING
----------------------------------------------------------

-- Avoid interrupt Channeling
if UnitChannelInfo("player")~= nil then return nil
--	SpellStopCasting() with "Soins" 2050 if Health < 0.75
elseif jps.IsCastingSpell(2050,"player") and jps.CastTimeLeft(player) > 0.5 and (health_pct_TANK < 0.75) and (manapool > 0.20) then 
	SpellStopCasting()
	DEFAULT_CHAT_FRAME:AddMessage("STOPCASTING HEAL",0, 0.5, 0.8)
-- Avoid Overhealing -- Grâce 77613
elseif jps.IsCasting("player") and (health_pct_TANK > 0.95) and (not jps.buffId(109964)) and (jps.buffStacks(Grace,jps_TANK) == 3) and (jps.LastTarget == jps_TANK) then 
	SpellStopCasting()
	DEFAULT_CHAT_FRAME:AddMessage("STOPCASTING OVERHEAL",0, 0.5, 0.8)
end

local manaspellTable = {
	{ 527, jps.MagicDispel , {player,jps_TANK} , "|cFFFF0000Mana_dispelMagic_MultiUnit_" },
	{ "nested", jps.buffId(109964) and (health_pct_TANK > 0.75) , parse_shell() },
	{ 2061, jps.buff(114255) and (health_pct_TANK < 0.95) , jps_TANK, "Mana_Soins Rapides_Waves_"..jps_TANK },
	{ 47540, (health_pct_TANK < 0.95) , jps_TANK, "Mana_Penance_"..jps_TANK },
	{ 17, (timerShield == 0) and not jps.debuff(6788,jps_TANK) and not jps.buff(17,jps_TANK) , jps_TANK, "Mana_Shield_"..jps_TANK },
	{ 33076, not jps.buffTracker(33076) and (FriendTable[jps_TANK] ~= nil) , jps_TANK, "Mana_Mending_"..jps_TANK },
	{ 2050, (FriendTable[jps_TANK] ~= nil) and (jps.buffStacks(Grace,jps_TANK) < 3) , jps_TANK, "Mana_Soins_"..jps_TANK },
	{ 14914, jps.canDPS(rangedTarget) , rangedTarget, "Mana_Fire_"..rangedTarget },
	{ 2050, (health_deficiency_TANK > average_flashheal) , jps_TANK , "Mana_Soins_"..jps_TANK },
	{ 109964, (FriendTable[jps_TANK] ~= nil) and (health_pct_TANK > 0.95) , jps_TANK , "|cff0070ddCarapace_"..jps_TANK },	
	{ 585, (health_deficiency_TANK < average_flashheal) and jps.canDPS(rangedTarget) , rangedTarget, "Mana_Chatiment_"..rangedTarget },
}

------------------------
-- SPELL TABLE ---------
------------------------

-- CancelUnitBuff(player,SpiritShell)
		--{ {"macro","/cancelaura "..SpiritShell,"player"}, (health_pct_TANK < 0.55) and jps.buffId(109964) , player , "Macro_CancelAura_Carapace" }, 
-- SpellStopCasting()
		--{ {"macro","/stopcasting"},  spellstop == tostring(select(1,GetSpellInfo(2050))) and jps.CastTimeLeft(player) > 0.5 and (health_pct_TANK < 0.75) , player , "Macro_StopCasting" },

local spellTable =
{
-- TRINKETS -- jps.useTrinket(0) est "Trinket0Slot" est slotId  13 -- "jps.useTrinket(1) est "Trinket1Slot" est slotId  14
	--{ jps.useTrinket(0), jps.UseCDs , player },
	--{ jps.useTrinket(1), jps.UseCDs , player },
	{ jps.useTrinket(1), isInBG and jps.UseCDs and stunMe , player },
-- "Passage dans le Vide" -- "Void Shift" 108968
	{ 108968, (FriendTable[player] == nil) and (health_pct_TANK < 0.40) and (UnitIsUnit(jps_TANK,player)~=1) and (playerhealth_pct > 0.80) , jps_TANK , "Void Shift_"..jps_TANK  },
-- "Pierre de soins" 5512
	{ {"macro","/use item:5512"}, select(1,IsUsableItem(5512))==1 and jps.itemCooldown(5512)==0 and (playerhealth_pct < 0.50) , player },
-- "Prière du désespoir" 19236
	{ 19236, select(2,GetSpellBookItemInfo(Desesperate))~=nil and jps.cooldown(19236)==0 and (playerhealth_pct < 0.50) , player },
-- "Psychic Scream" "Cri psychique" 8122 -- FARMING OR PVP -- NOT PVE -- debuff same ID 8122
	{ 8122, isInBG and jps.canDPS(rangedTarget) and canFear and not unitLoseControl(rangedTarget) , rangedTarget },
-- "Psyfiend" 108921 Démon psychique
	{ 108921, (FriendTable[player] ~= nil) and jps.canDPS(rangedTarget) and isInBG and canFear and not unitLoseControl(rangedTarget) , player },
-- "Void Tendrils" 108920 -- debuff "Void Tendril's Grasp" 114404
	{ 108920, jps.canDPS(rangedTarget) and isInBG and canFear and not unitLoseControl(rangedTarget) , rangedTarget },
-- "Torve-esprit" 123040 -- "Ombrefiel" 34433 "Shadowfiend"
	{ 34433, (manapool < 0.75) and canCastShadowfiend , rangedTarget },
	{ 123040, (manapool < 0.75) and canCastShadowfiend , rangedTarget },

-- "Soins rapides" 2061 "From Darkness, Comes Light" 109186 gives buff -- "Vague de Lumière" 114255 "Surge of Light"
	{ 2061, jps.buff(114255) and (jps.buffDuration(114255) < 4) , jps_TANK, "Soins Rapides_Waves_"..jps_TANK },
-- "Soins rapides" 2061 -- "Focalisation intérieure" 89485 -- "Egide Divine" 47515
	{ 2061, jps.buffId(89485) and (health_deficiency_TANK > average_flashheal) , jps_TANK , "Soins Rapides_Foca_Health_"..jps_TANK },
	{ 2061, jps.buffId(89485) and not jps.buff(DivineAegis,jps_TANK) , jps_TANK , "Soins Rapides_Foca_Egide_"..jps_TANK },
	unitFor_Flash,
	
-- Inner Focus 89485 "Focalisation intérieure" --  96267 Immune to Silence, Interrupt and Dispel effects 5 seconds remaining
	{ 89485, isInPvE and UnitAffectingCombat(player)==1 and (jps.cooldown(89485) == 0) , player , "Foca_" },
-- AGGRO PLAYER
	{ 586, isInPvE and UnitThreatSituation(player)==3 , player },
	{ "nested", isInBG and (TimeToDiePlayer < 5) , parse_player_aggro() },
	{ "nested", isInBG and (player_Aggro + player_IsInterrupt > 0) and (FriendTable[player] ~= nil) , parse_player_aggro() },
	
-- "Infusion de puissance" 10060 
	{ 10060, (health_pct_TANK < 0.75) and (jps.cooldown(10060) == 0) and (manapool > 0.20) , player , "Puissance_" },
-- ARCHANGE "Archange" 81700 -- "Evangélisme" 81661 buffStacks == 5
	{ 81700, (health_pct_TANK < 0.75) and (jps.buffStacks(81661) == 5) and (manapool > 0.20) , player, "ARCHANGE_" },
-- EMERGENCY TARGET
	{ "nested", (health_pct_TANK < 0.55) and (groupToHeal == false) , parse_emergency_TANK() },
	{ "nested", (health_pct_TANK < 0.55) and (groupToHeal == true) , parse_POH() },

-- DISPEL
	{ "nested", true , parse_dispel() },	
-- DAMAGE -- "Carapace spirituelle" spell & buff player 109964
	{ "nested", jps.FaceTarget and (health_pct_TANK > 0.55) and (timerShield > 0) and unitLoseControl(rangedTarget)  , parse_dmg() },
	{ "nested", jps.FaceTarget and (health_pct_TANK > 0.75) and (timerShield > 0) and not jps.buffId(109964) , parse_dmg() },
	{ "nested", jps.FaceTarget and (health_pct_TANK > 0.55) and (timerShield > 0) and UnitHealth(rangedTarget)/UnitHealthMax(rangedTarget) < 0.20 , parse_dmg() },
	{ "nested", jps.FaceTarget and (health_pct_TANK > 0.95) and (timerShield > 0) , parse_dmg() }, -- jps.buff(81700) "Archange" 81700
-- "Flammes sacrées" 14914  -- "Evangélisme" 81661 -- It is important to note that the instant cast Holy Fire from Glyph of Holy Fire does consume Borrowed Time
	{ 14914, jps.canDPS(rangedTarget) and not jps.buff(81661,player) , rangedTarget ,"|cFFFF0000DPS_Flammes_"..rangedTarget },
	{ 14914, jps.canDPS(rangedTarget) and jps.buff(81661,player) and (jps.buffDuration(81661) < 8) , rangedTarget ,"|cFFFF0000DPS_Flammes_"..rangedTarget },
	{ 14914, jps.canDPS , EnemyUnit , "|cFFFF0000DPS_Flammes_MultiUnit_" },
-- "Mot de pouvoir : Réconfort" -- "Power Word: Solace" 129250 -- REGEN MANA
	--{ 129250, jps.canDPS(rangedTarget) and not jps.buff(81661,player) , rangedTarget, "|cFFFF0000DPS_Solace_"..rangedTarget },
	--{ 129250, jps.canDPS(rangedTarget) and jps.buff(81661,player) and (jps.buffDuration(81661) < 8) , rangedTarget ,"|cFFFF0000DPS_Solace_"..rangedTarget },
	--{ 129250, jps.canDPS ,  EnemyUnit, "|cFFFF0000DPS_Solace_MultiUnit_" },
	
-- "Power Word: Shield" 17 -- Ame affaiblie 6788 Extaxe (Rapture) regen mana 150% esprit toutes les 12 sec
	{ "nested", true , parse_shield() },
-- CARAPACE	-- "Carapace spirituelle" spell & buff player 109964 buff target 114908
	{ "nested", jps.buffId(109964) and (health_pct_TANK > 0.75) , parse_shell() },
	{ 109964, unitFor_SpiritShell , {player,jps_TANK}, "CARAPACE_" },

-- "Prière de soins" 596
	{ "nested", (groupToHeal == true) , parse_POH() },
-- "Prière de guérison" 33076
	{ "nested", true , parse_mending() },
-- "Soins" 2050 -- Grâce 77613 -- jps.buffStacks(Grace,jps_TANK)
	{ 2050, (FriendTable[jps_TANK] ~= nil) and (health_pct_TANK > 0.75) and (jps.buffStacks(Grace,jps_TANK) < 3) , jps_TANK , "Soins_Grace_"..jps_TANK },
	{ 2050, (health_pct_TANK > 0.75) and (health_deficiency_TANK > average_flashheal) , jps_TANK , "Soins_"..jps_TANK },
-- "Pénitence" 47540
	{ 47540, (health_deficiency_TANK > average_flashheal) , jps_TANK , "Penance_"..jps_TANK},
-- "Cascade" 121135 "Escalade"
	{ 121135, (health_pct_TANK < 0.75) and (UnitIsUnit(jps_TANK,player)~=1) and countInRaid > 2 , jps_TANK , "Cascade_"..jps_TANK },
-- "Don des naaru" 59544
	{ 59544, (select(2,GetSpellBookItemInfo(NaaruGift))~=nil) and (health_deficiency_TANK > average_flashheal) , jps_TANK , "Naaru_"..jps_TANK },
-- "Rénovation" 139
	{ 139, not jps.buff(139,jps_TANK) and (health_deficiency_TANK > average_flashheal) , jps_TANK , "Renew_"..jps_TANK },
	{ 139, not jps.buff(139,jps_TANK) and jps.debuff(6788,jps_TANK) and (jps.cooldown(33076) > 0) , jps_TANK , "Renew_"..jps_TANK }, -- debuff Ame affaiblie and Mending on CD
-- "Soins de lien" 32546 -- Glyph of Binding Heal 
	{ 32546 , unitFor_Binding , FriendUnit , "Lien_MultiUnit_" },
-- "Soins rapides" 2061 -- "Soins supérieurs" 2060
	{ "nested", true , parse_greatheal() },
-- "Feu intérieur" 588
	{ 588, not jps.buff(588,player) and not jps.buff(73413,player), player }, -- "Volonté intérieure" 73413
-- "Gardien de peur" 6346 -- FARMING OR PVP -- NOT PVE
	{ 6346, isInBG and (not jps.buff(6346,player)) , player },
}

local spellTable_moving =
{
-- TRINKETS -- jps.useTrinket(0) est "Trinket0Slot" est slotId  13 -- "jps.useTrinket(1) est "Trinket1Slot" est slotId  14
	{ jps.useTrinket(1), isInBG and jps.UseCDs and stunMe , player },
-- "Passage dans le Vide" -- "Void Shift" 108968
	{ 108968, (FriendTable[player] == nil) and (health_pct_TANK < 0.40) and (UnitIsUnit(jps_TANK,player)~=1) and (playerhealth_pct > 0.80) , jps_TANK , "Moving_Void Shift_"..jps_TANK  },
-- "Pierre de soins" 5512
	{ {"macro","/use item:5512"}, select(1,IsUsableItem(5512))==1 and jps.itemCooldown(5512)==0 and (playerhealth_pct < 0.50) , player },
-- "Prière du désespoir" 19236
	{ 19236, select(2,GetSpellBookItemInfo(Desesperate))~=nil and jps.cooldown(19236)==0 and (playerhealth_pct < 0.50) , player },
-- "Psychic Scream" "Cri psychique" 8122 -- FARMING OR PVP -- NOT PVE -- debuff same ID 8122
	{ 8122, isInBG and jps.canDPS(rangedTarget) and canFear and not unitLoseControl(rangedTarget) , rangedTarget },
-- "Psyfiend" 108921 Démon psychique
	{ 108921, (FriendTable[player] ~= nil) and jps.canDPS(rangedTarget) and isInBG and canFear and not unitLoseControl(rangedTarget) , player },
-- "Void Tendrils" 108920 -- debuff "Void Tendril's Grasp" 114404
	{ 108920, jps.canDPS(rangedTarget) and isInBG and canFear and not unitLoseControl(rangedTarget) , rangedTarget },
-- "Torve-esprit" 123040 -- "Ombrefiel" 34433 "Shadowfiend"
	{ 34433, (manapool < 0.75) and canCastShadowfiend , rangedTarget },
	{ 123040, (manapool < 0.75) and canCastShadowfiend , rangedTarget },

-- AGGRO PLAYER
	{ 586, isInPvE and UnitThreatSituation(player)==3 , player },
	{ 17, isInBG and not jps.debuff(6788,player) and not jps.buff(17,player) , player },
	{ "nested", isInBG and (TimeToDiePlayer < 5) , parse_player_aggro() },
	{ "nested", isInBG and (player_Aggro + player_IsInterrupt > 0) and (FriendTable[player] ~= nil) , parse_player_aggro() },

-- EMERGENCY PLAYER
	{ 33206, (playerhealth_pct < 0.35) and (UnitAffectingCombat(player)==1) , player} , -- "Suppression de la douleur"
	{ 17, (playerhealth_deficiency > average_flashheal) and not jps.buff(17,player) and not jps.debuff(6788,player) , player}, -- Shield
	{ 2061, (playerhealth_deficiency > average_flashheal) and jps.buff(114255) , player }, -- "Soins rapides" 2061 "From Darkness, Comes Light" 109186 gives buff -- "Vague de Lumière" 114255 "Surge of Light"
	{ 47540, (playerhealth_deficiency > average_flashheal) , player} , -- "Pénitence" 47540
	{ 33076, (playerhealth_deficiency > average_flashheal) and not jps.buff(33076,player) , player}, -- "Prière de guérison" 33076
	{ 59544, (playerhealth_deficiency > average_flashheal) and (select(2,GetSpellBookItemInfo(NaaruGift))~=nil) , player }, 	-- "Don des naaru" 59544
	{ 139, (playerhealth_deficiency > average_flashheal) and not jps.buff(139,player) , player} , -- "Rénovation" 139

-- EMERGENCY TARGET
	-- "Suppression de la douleur" 33206
	{ 33206, (health_pct_TANK < 0.35) and (UnitAffectingCombat(player)==1) , jps_TANK },
	-- "Soins rapides" 2061 "From Darkness, Comes Light" 109186 gives buff -- "Vague de Lumière" 114255 "Surge of Light"
	{ 2061, (health_deficiency_TANK > average_flashheal) and jps.buff(114255) , jps_TANK },
	-- "Pénitence" 47540 avec talent possible caster en moving
	{ 47540, (health_deficiency_TANK > average_flashheal) , jps_TANK },
	-- "Escalade" 121135 "Cascade"
	{ 121135, (health_deficiency_TANK > average_flashheal) and (UnitIsUnit(jps_TANK,player)~=1) and countInRaid > 2 , jps_TANK  },
	-- "Power Word: Shield" 17 -- Ame affaiblie 6788)
	{ "nested", true , parse_shield() },		
	-- "Prière de guérison" 33076
	{ "nested", true , parse_mending() },
	-- "Don des naaru" 59544
	{ 59544, (select(2,GetSpellBookItemInfo(NaaruGift))~=nil) and (health_deficiency_TANK > average_flashheal) , jps_TANK },
	-- "Rénovation" 139
	{ 139, not jps.buff(139,jps_TANK) and (health_deficiency_TANK > average_flashheal) , jps_TANK },

-- DISPEL
	{ "nested", true , parse_dispel() },
-- DAMAGE 
-- "Flammes sacrées" 14914  -- "Evangélisme" 81661 -- It is important to note that the instant cast Holy Fire from Glyph of Holy Fire does consume Borrowed Time
	{ 14914, jps.canDPS(rangedTarget) , rangedTarget , "|cFFFF0000DPS_Flammes_"..rangedTarget },
	{ 14914, jps.canDPS , EnemyUnit , "|cFFFF0000DPS_Flammes_MultiUnit_" },
-- "Mot de pouvoir : Réconfort" -- "Power Word: Solace" 129250 -- REGEN MANA
	--{ 129250, jps.canDPS(rangedTarget) and not jps.buff(81661,player) , rangedTarget, "|cFFFF0000DPS_Solace_"..rangedTarget },
	--{ 129250, jps.canDPS(rangedTarget) and jps.buff(81661,player) and (jps.buffDuration(81661) < 8) , rangedTarget ,"|cFFFF0000DPS_Solace_"..rangedTarget },
-- "Pénitence" 47540 
	{ 47540, jps.FaceTarget and jps.canDPS(rangedTarget) , rangedTarget,"|cFFFF0000DPS_Penance_"..rangedTarget },
-- "Mot de l'ombre : Mort" 32379 -- FARMING OR PVP -- NOT PVE
	{ 32379, jps.FaceTarget and isInBG and jps.IsCastingPoly(rangedTarget) and unitFor_ShadowWordDeath(rangedTarget) , rangedTarget , "|cFFFF0000castDeath_Polymorph_"..rangedTarget },
	{ 32379, jps.FaceTarget and isInBG and jps.canDPS(rangedTarget) and (UnitHealth(rangedTarget)/UnitHealthMax(rangedTarget) < 0.20) , rangedTarget, "|cFFFF0000castDeath_"..rangedTarget },
	{ 32379, unitFor_ShadowWordDeath, EnemyUnit , "|cFFFF0000castDeath_MultiUnit_" },
-- "Mot de l'ombre: Douleur" 589 -- FARMING OR PVP -- NOT PVE
	{ 589, jps.FaceTarget and isInBG and jps.canDPS(rangedTarget) and jps.myDebuffDuration(589,rangedTarget) == 0 , rangedTarget , "|cFFFF0000DPS_Douleur_"..rangedTarget },

-- "Feu intérieur" 588 -- "Volonté intérieure" 73413
	{ 588, not jps.buff(588,player) and not jps.buff(73413,player) , player }, 
-- "Gardien de peur" 6346 -- FARMING OR PVP -- NOT PVE
	{ 6346, isInBG and (not jps.buff(6346,player)) , player }, -- "Gardien de peur" 6346
}

	if jps.Moving then
		spell, target = parseSpellTable(spellTable_moving)
	elseif (health_pct_TANK > 0.75) and not jps.FaceTarget then
		spell, target = parseSpellTable(manaspellTable)
	else
		spell, target = parseSpellTable(spellTable)
	end
	return spell,target

end, "Disc Priest PvE", true, false)



-- "Leap of Faith" -- "Saut de foi" 
-- "Mass Dispel"  -- Dissipation de masse 32375
-- "Psyfiend" -- "Démon psychique" 108921
-- "Evangélisme" 81661
-- "Archange" 81700
-- "Sursis" 59889 "Borrowed"
-- "Egide divine" 47753 "Divine Aegis"
-- "Spirit Shell" -- Carapace spirituelle -- Pendant les prochaines 15 s, vos Soins, Soins rapides, Soins supérieurs, et Prière de soins ne soignent plus mais créent des boucliers d’absorption qui durent 15 s
-- "Holy Fire" -- Flammes sacrées
-- "Archangel" -- Archange -- Consomme votre Evangelisme, ce qui augmente les soins que vous prodiguez de 5% par charge d'Evangelisme consommée pendant 18 s.
-- "Evangelism" -- Evangélisme -- dégâts directs avec Flammes sacrées ou Fouet mental, vous bénéficiez d'Evangélisme. Cumulable jusqu'à 5 fois. Dure 20 s
-- "Atonement" -- Expiation -- dmg avec Châtiment, Flammes sacrées ou Pénitence, vous rendez instantanément à un membre du groupe ou du raid proche qui a peu de points de vie et qui se trouve à moins de 15 mètres de la cible ennemie un montant de points de vie égal à 100% des dégâts infligés.
-- "Borrowed Time" -- Sursis -- Votre prochain sort bénéficie d'un bonus de 15% à la hâte des sorts quand vous lancez Mot de pouvoir : Bouclier. Dure 6 s.
-- "Divine Hymn" -- Hymne divin
-- "Dispel Magic" -- Purifier
-- "Inner Fire" -- Feu intérieur
-- "Serendipity" -- Heureux hasard -- vous soignez avec Soins de lien ou Soins rapides, le temps d'incantation de votre prochain sort Soins supérieurs ou Prière de soins est réduit de 20% et son coût en mana de 10%.
-- "Power Word: Fortitude" -- Mot de pouvoir : Robustesse
-- "Fear Ward" -- Gardien de peur
-- "Chakra: Serenity" -- Chakra : Sérénité
-- "Chakra" -- Chakra
-- "Heal" -- Soins
-- "Flash Heal" -- Soins rapides
-- "Binding Heal" -- Soins de lien
-- "Greater Heal" -- Soins supérieurs
-- "Renew" -- Rénovation
-- "Circle of Healing" -- Cercle de soins
-- "Prayer of Healing" -- Prière de soins
-- "Prayer of Mending" -- Prière de guérison
-- "Guardian Spirit" -- Esprit gardien
-- "Cure Disease" -- Purifier
-- "Desperate Prayer" -- Prière du désespoir
-- "Surge of light" -- Vague de Lumière
-- "Holy Word: Serenity" -- Mot sacré : Sérénité SpellID 88684
-- "Power Word: Shield" -- Mot de pouvoir : Bouclier 
-- "Ame affaiblie" -- Weakened Soul

local priestLight = {}

priestLight.arcaneTorrent = 28730;
priestLight.bloodFury = 33702;
priestLight.bloodlust = 2825;	
priestLight.borrowedTime = 59889;
priestLight.cascade = 121135;
priestLight.divineStar = 110744;
priestLight.flashHeal = 2061;
priestLight.grace = 77613;
priestLight.greaterHeal = 2060;
priestLight.halo = 120517;
priestLight.archangel = 81700;
priestLight.evangelism = 81662;
priestLight.hymnOfHope = 64901;
priestLight.innerFocus = 89485;
priestLight.jadeSerpentPotion = 105702;
priestLight.manaPotion = 76098;
priestLight.mindbender = 123040;
priestLight.powerInfusion = 10060;
priestLight.powerWordShield = 17;
priestLight.powerWordSolace = 129250;
priestLight.rapture = 47536;
priestLight.renew = 139; 
priestLight.shadowWordDeath = 32379;
priestLight.smite = 585;
priestLight.surgeOfLight = 114255;
priestLight.twistOfFate = 109142; 
priestLight.magicDispel = 527;
priestLight.spiritShell = 114908;
priestLight.spiritShellBuild = 109964;
priestLight.prayerOfHealing = 596;
priestLight.prayerOfMending = 33076;
priestLight.divineAegis = 47753;
priestLight.bindingHeal = 32546;
priestLight.naaruGift = 59544;
priestLight.desperatePrayer = 19236;
priestLight.innerWill = 73413;
priestLight.innerFire = 588;
priestLight.penance = 47540;
priestLight.shadowfiend = 34433;
priestLight.voidShift = 108968;
priestLight.painsup = 33206;
priestLight.holyFire = 14914;
priestLight.heal = 2050;
priestLight.weakenedSoul = 6788;
priestLight.arcaneTorrent = 28730;
priestLight.disc = {}
priestLight.disc.interruptTable = {{priestLight.flashHeal, 0.75, false}, {priestLight.greaterHeal, 0.93,false },{ priestLight.heal, 0.98,false }, {priestLight.prayerOfHealing,0.90,true}}
 
priestConfig = mConfig:createConfig("Priest Disc Config","PriestRotationsDisc","Default",{"/priest","/disc","/rotation"})
priestConfig:addSlider("rotationPowerNormalSingle", "Power of your normal single Target Healing in % ", 0, 100, 100, 1)
priestConfig:addSlider("rotationPowerNormalAOE", "Power of your normal AOE Target Healing in % ", 0, 100, 100, 1)
priestConfig:addSlider("rotationPowerEmergency", "Power of your normal Important units Healing in % ", 0, 100, 100, 1)
priestConfig:addSlider("mindbenderManaPercent", "% of mana for activating Mindbender", 0, 100, 70, 1)
priestConfig:addSlider("shadowfiendManaPercent", "% of mana for activating shadowfiend", 0, 100, 60, 1)
priestConfig:addSlider("arcaneTorrent", "% of mana for activating arcane Torrent", 0, 100, 90, 1)
priestConfig:addSlider("manaPotionManaPercent", "% of mana for using mana potion", 0, 100, 40, 1)
priestConfig:addSlider("trinketManaPercent", "% of mana for using mana/spirit trinket", 0, 100, 80, 1)
priestConfig:addSlider("timeBetweenShields", "seconds you want to wait before you shield another unit", 1, 30, 12, 1)
priestConfig:addSlider("timeBetweenSmite", "seconds you want to wait between smites (if you have 5 stacks evangelism)", 1, 10, 1.5, 0.5)


-- allows us to adjust the whole heal output with one slider! for finding better healing % values etc.
function priestLight.getPercentNormal(value) 
	return value * (100 * (priestConfig:getPercent("rotationPowerNormalSingle")) )
end
function priestLight.getPercentAOE(value) 
	return value * (100 * (priestConfig:getPercent("rotationPowerNormalAOE")) )
end
function priestLight.getPercentImportant(value) 
	return value * (100 * (priestConfig:getPercent("rotationPowerEmergency")) )
end

function priestLight.shouldInterruptCasting(spellsToCheck, avgHP,unitsBelow70, lowestImportantHP )
 	local healTargetHP = jps.hp(jps.LastTarget)
 	local spellCasting, _, _, _, _, endTime, _ = UnitCastingInfo("player")
 	if spellCasting == nil then return false end
 
	for key, healSpellTable  in pairs(spellsToCheck) do
 		local breakpoint = healSpellTable[2]
		local spellName = tostring(select(1,GetSpellInfo(healSpellTable[1]))) 
		local aoe = healSpellTable[3]
		if spellName:lower() == spellCasting:lower() then
			if aoe == false then
				if healTargetHP > breakpoint then
					print("interrupt "..spellName.." , unit "..jps.LastTarget.. " has enough hp!");
					SpellStopCasting()
				end
			else
				if unitsBelow70 <= 2 and not jps.buff(114908) then --114908 = spritshell
					print("interrupt "..spellName.." , raid has enough hp!");
					SpellStopCasting()
				end
			end
		end
	end
end

jps.registerRotation("PRIEST","DISCIPLINE",function()
	
	priestLight.disc.unitsBelow70 = 0
	priestLight.disc.unitsBelow50 = 0
	priestLight.disc.unitsBelow30 = 0
	priestLight.disc.sumHP = 0
	priestLight.disc.avgHP = 1
	priestLight.disc.units = 0
	
	for unit,index in pairs(jps.RaidStatus) do
		if jps.canHeal(unit) then
			local thisHP = jps.hp(unit)
			priestLight.disc.units = priestLight.disc.units+1
			priestLight.disc.avgHP = priestLight.disc.sumHP+thisHP

			if thisHP < 0.3 then priestLight.disc.unitsBelow30 = priestLight.disc.unitsBelow30 + 1 end
			if thisHP < 0.5 then priestLight.disc.unitsBelow50 = priestLight.disc.unitsBelow50 + 1 end
			if thisHP < 0.7 then priestLight.disc.unitsBelow70 = priestLight.disc.unitsBelow70 + 1 end
		end
	end
	if priestLight.disc.unitsBelow70 >= 3 and jps.CastTimeLeft("player") < 0.1 then	
		priestLight.disc.pohTarget = jps.FindSubGroupTarget(0.7)
	else 
		priestLight.disc.pohTarget = nil
	end

	if priestLight.disc.units >= 1 then
		priestLight.disc.avgHP = priestLight.disc.sumHP / priestLight.disc.units
	end
	
	priestLight.disc.lowestUnit = jps.LowestInRaidStatus()
	priestLight.disc.lowestUnitHP = jps.hp(priestLight.disc.lowestUnit)
	
	priestLight.disc.tanks = jps.findTanksInRaid()
	priestLight.disc.importantUnits = jps.findTanksInRaid() -- units which need "more" heal"
	priestLight.disc.shouldHeal = false
	priestLight.disc.lowestImportantUnit = nil
	priestLight.disc.lowestImportantUnitHP = 1
	
	if jps.canHeal("target") then table.insert(priestLight.disc.importantUnits,"target") end
	if jps.canHeal("focus") then table.insert(priestLight.disc.importantUnits,"focus") end
	if jps.canHeal("player") then table.insert(priestLight.disc.importantUnits,"player") end

	for _, unitName in ipairs(priestLight.disc.importantUnits) do
		local thisHP = jps.hp(unitName)

		if jps.canHeal(unitName) and thisHP <= priestLight.disc.lowestImportantUnitHP then
			priestLight.disc.lowestImportantUnitHP = thisHP
			priestLight.disc.lowestImportantUnit = unitName
		end
	end
	
	priestLight.shouldInterruptCasting(priestLight.disc.interruptTable,priestLight.disc.avgHP,  priestLight.disc.unitsBelow70, priestLight.disc.lowestImportantUnitHP)
	
	if priestLight.disc.lowestImportantUnitHP < 1 or priestLight.disc.lowestUnitHP <1 then
		priestLight.disc.shouldHeal = true
	end 

	local dispelTable = {priestLight.magicDispel}
	function priestLight.disc.dispel()
		local cleanseTarget = nil
		if jps.DispelMagicTarget() then
			cleanseTarget = jps.DispelMagicTarget()
		elseif jps.DispelPoisonTarget() then
			cleanseTarget = jps.DispelPoisonTarget()
		end
		dispelTable[2] = cleanseTarget ~= nil and jps.Interrupts
		dispelTable[3] = cleanseTarget
		return dispelTable
	end
	
	priestLight.disc.rangedTarget = nil
	priestLight.disc.aggroTank = nil
	if jps.canDPS("target") then
		priestLight.disc.rangedTarget = "target"
		priestLight.disc.aggroTank = jps.findMeAggroTank("target")
	elseif jps.canDPS("focustarget") then
		priestLight.disc.rangedTarget = "focustarget"
		priestLight.disc.aggroTank = jps.findMeAggroTank("focustarget")
	elseif jps.canDPS("targettarget") then
		priestLight.disc.rangedTarget = "targettarget"
		priestLight.disc.aggroTank = jps.findMeAggroTank("targettarget")
	elseif jps.canDPS("mouseover") then
		priestLight.disc.rangedTarget = "mouseover"
		priestLight.disc.aggroTank = jps.findMeAggroTank("mouseover")
	elseif jps.canDPS("boss1") then
		priestLight.disc.rangedTarget = "boss1"
		priestLight.disc.aggroTank = jps.findMeAggroTank("boss1")
	elseif jps.canDPS("boss2") then
		priestLight.disc.rangedTarget = "boss2"
		priestLight.disc.aggroTank = jps.findMeAggroTank("boss2")
	elseif jps.canDPS("boss3") then
		priestLight.disc.rangedTarget = "boss3"
		priestLight.disc.aggroTank = jps.findMeAggroTank("boss3")
	elseif jps.canDPS("boss4") then
		priestLight.disc.rangedTarget = "boss3"
		priestLight.disc.aggroTank = jps.findMeAggroTank("boss3")
	end

	local spellTableTest = {
		-- buffs
		{priestLight.innerFire, not jps.buff(priestLight.innerWill) and not jps.buff(priestLight.innerFire), 'player'},
		
		-- cooldowns
		{"nested", priestLight.disc.shouldHeal == true, 
			{
				{priestLight.innerFocus, jps.UseCDs and priestLight.disc.lowestUnitHP < 0.7},
				{priestLight.archangel, jps.buffStacks(priestLight.evangelism) == 5 and jps.UseCDs},
				{ jps.getDPSRacial(),jps.UseCDs},
				-- Requires engineerins
				{ jps.useSynapseSprings(),jps.useSynapseSprings() ~= "" and jps.UseCDs},
				-- Requires herbalism
				{ "Lifeblood", jps.UseCDs},
			}
		},
	
		-- mana
		{priestLight.mindbender, jps.mana() <= priestConfig:getPercent("mindbenderManaPercent") and jps.UseCDs and priestLight.disc.rangedTarget ~= nil, priestLight.disc.rangedTarget},
		{priestLight.shadowfiend, jps.mana() <= priestConfig:getPercent("shadowfiendManaPercent") and jps.UseCDs and priestLight.disc.rangedTarget ~= nil, priestLight.disc.rangedTarget},
		{priestLight.arcaneTorrent, jps.mana() <= priestConfig:getPercent("arcaneTorrent") and jps.UseCDs },
		{jps.useTrinket(0), jps.mana() <= priestConfig:getPercent("trinketManaPercent") and jps.UseCDs and jps.isManaRegTrinket(0)},
		{jps.useTrinket(1), jps.mana() <= priestConfig:getPercent("trinketManaPercent") and jps.UseCDs and jps.isManaRegTrinket(1)},
		{jps.useBagItem(priestLight.manaPotion), jps.mana() <= priestConfig:getPercent("manaPotionManaPercent") and jps.UseCDs},
	
		-- dispel
		priestLight.disc.dispel,
	
		-- moving
		{'nested' , jps.Moving, 
			{
				{priestLight.powerWordShield, not jps.debuff(priestLight.weakenedSoul) and jps.mana() > 0.8, "player"},
				{priestLight.powerWordShield, not jps.debuff(priestLight.weakenedSoul,priestLight.disc.lowestUnit) and jps.castEverySeconds(priestLight.powerWordShield,priestConfig:get("timeBetweenShields")) and priestLight.disc.lowestUnitHP < 0.97, priestLight.disc.lowestUnit},
				{priestLight.powerWordShield, not jps.debuff(priestLight.weakenedSoul,priestLight.disc.lowestUnit) and jps.buff(priestLight.rapture) and priestLight.disc.lowestUnitHP < 0.97, priestLight.disc.lowestUnit},
				{priestLight.renew, not jps.buff(priestLight.renew,priestLight.disc.lowestUnit) and priestLight.disc.lowestUnitHP < 0.8, priestLight.disc.lowestUnit },
				{priestLight.penance, jps.glyphInfo() and priestLight.disc.lowestUnitHP < 0.7, priestLight.disc.lowestUnit },
				{priestLight.cascade, priestLight.disc.lowestUnitHP < 0.6, priestLight.disc.lowestUnit },
			},
	
		},
	
		-- spirit shell stacking
		{'nested' , jps.buff(priestLight.spiritShellBuild),
			{
				{priestLight.cascade, "onCD", priestLight.disc.lowestUnit},
				{priestLight.divineStar, "onCD", priestLight.disc.lowestUnit},
				{priestLight.prayerOfMending, "onCD" , priestLight.disc.lowestUnit },
				{priestLight.prayerOfHealing, "onCD", priestLight.disc.lowestUnit},
			}
		},
		
		-- PW:S
		{priestLight.powerWordShield, not jps.debuff(priestLight.weakenedSoul, priestLight.disc.lowestUnit) and jps.castEverySeconds(priestLight.powerWordShield,priestConfig:get("timeBetweenShields")) and priestLight.disc.lowestUnitHP < 0.97, priestLight.disc.lowestUnit},
		{priestLight.powerWordShield, not jps.debuff(priestLight.weakenedSoul, priestLight.disc.lowestUnit) and jps.buff(priestLight.rapture) and priestLight.disc.lowestUnitHP < 0.95, priestLight.disc.lowestUnit},
		{"nested", priestLight.disc.aggroTank ~= nil,
			{
				{priestLight.powerWordShield, not jps.debuff(priestLight.weakenedSoul, priestLight.disc.aggroTank), priestLight.disc.aggroTank},
			}
		},

		-- important units emergency
		{'nested' , priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.99), 
	
			{
				{priestLight.voidShift, priestLight.disc.lowestImportantUnit ~= jpsName and priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.3) and UnitHealth("player") > 300000 and jps.UseCDs, priestLight.disc.lowestImportantUnit },
				{priestLight.painsup, jps.canHeal("target") and jps.hp("target") < priestLight.getPercentImportant(0.4) and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.UseCDs, "target" },
				{priestLight.painsup, priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.4) and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.UseCDs, priestLight.disc.lowestImportantUnit },
				{priestLight.desperatePrayer, jps.hp() > priestLight.getPercentImportant(0.45) and priestLight.disc.lowestImportantUnitHP < 0.5 and jps.UseCDs, priestLight.disc.lowestImportantUnit},
				{priestLight.flashHeal, priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.4), priestLight.disc.lowestImportantUnit },
				{priestLight.greaterHeal, priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.65), priestLight.disc.lowestImportantUnit },
				{priestLight.bindingHeal, priestLight.disc.lowestImportantUnit ~= jpsName and priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.8) and jps.hp("player") < priestLight.getPercentImportant(0.7), priestLight.disc.lowestImportantUnit },
				{priestLight.penance, priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.95), priestLight.disc.lowestImportantUnit },
				{priestLight.prayerOfMending, priestLight.disc.lowestImportantUnitHP < priestLight.getPercentImportant(0.95) , priestLight.disc.lowestImportantUnit },
			},
		},
	
		-- multitarget target
		{'nested' , jps.MultiTarget or (priestLight.disc.unitsBelow70 >= 3 and priestLight.disc.avgHP < priestLight.getPercentAOE(0.9)),
			{
				-- from high heal to low filler heals
				{priestLight.cascade, priestLight.disc.lowestUnitHP < priestLight.getPercentAOE(0.7), priestLight.disc.lowestUnit},
				{priestLight.divineStar, priestLight.disc.lowestUnitHP < priestLight.getPercentAOE(0.7), priestLight.disc.lowestUnit},
				{priestLight.prayerOfMending, priestLight.disc.lowestImportantUnitHP < priestLight.getPercentAOE(0.7) , priestLight.disc.lowestUnit },
				{priestLight.prayerOfHealing, priestLight.disc.pohTarget ~= nil, priestLight.disc.pohTarget},
			},
	
		},

	 	-- single target & dps
		{'nested' , not jps.MultiTarget, 
			{
				{priestLight.desperatePrayer, jps.hp() > 0.45 and priestLight.disc.lowestUnitHP < priestLight.getPercentNormal(0.5) and jps.UseCDs, priestLight.disc.lowestUnit},
				{priestLight.flashHeal, priestLight.disc.lowestUnitHP < priestLight.getPercentNormal(0.4), priestLight.disc.lowestUnit },
				{priestLight.bindingHeal, priestLight.disc.lowestImportantUnit ~= jpsName and priestLight.disc.lowestUnitHP < priestLight.getPercentNormal(0.7) and jps.hp("player") < priestLight.getPercentNormal(0.7), priestLight.disc.lowestUnit },
				{priestLight.prayerOfMending, priestLight.disc.lowestUnitHP < priestLight.getPercentNormal(0.95) , priestLight.disc.lowestUnit },
				{priestLight.greaterHeal, priestLight.disc.lowestUnitHP < priestLight.getPercentNormal(0.50), priestLight.disc.lowestUnit },
				{priestLight.penance, priestLight.disc.lowestUnitHP < priestLight.getPercentNormal(0.9), priestLight.disc.lowestUnit },
				{priestLight.holyFire, priestLight.disc.rangedTarget ~= nil , priestLight.disc.rangedTarget},
				{priestLight.penance, priestLight.disc.rangedTarget ~= nil , priestLight.disc.rangedTarget},
				{priestLight.smite, priestLight.disc.rangedTarget ~= nil and jps.buffStacks(priestLight.evangelism) <5 , priestLight.disc.rangedTarget},
				{priestLight.smite, priestLight.disc.rangedTarget ~= nil and jps.castEverySeconds(priestLight.smite,priestConfig:get("timeBetweenSmite")), priestLight.disc.rangedTarget},
				{priestLight.heal, priestLight.disc.lowestUnitHP < priestLight.getPercentNormal(0.85), priestLight.disc.lowestUnit },
			},
	
		},
	}
	
	local spell = nil
	local target = nil
	spell,target = parseSpellTable(spellTableTest)
	--[[if IsControlKeyDown() then
		print("|cff0070ddspell:","|cffffffff",spell,"|cff0070ddtarget","|cffffffff",target)
		print("|cff0070ddlowest important:","|cffffffff",priestLight.disc.lowestImportantUnit,"|cff0070dd lowest normal","|cffffffff",priestLight.disc.lowestUnit)
	end]]--
	return spell,target
end, "Disc Priest PVE light 5.4", true ,false)
