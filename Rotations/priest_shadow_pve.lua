
jps.registerRotation("PRIEST","SHADOW",function()

	local spell = nil
	local target = nil
	local player = jpsName
	local playerhealth_deficiency =  UnitHealthMax(player) - UnitHealth(player)
	local playerhealth_pct = jps.hp(player)
	local giftnaaru = tostring(select(1,GetSpellInfo(59544))) -- giftnaaru 59544
	local desesperate = tostring(select(1,GetSpellInfo(19236))) -- "Prière du désespoir" 19236
	local mindblast = tostring(select(1,GetSpellInfo(8092))) -- "Mind Blast" 8092
	
	local jps_Target = jps.LowestInRaidStatus()
	local health_deficiency = UnitHealthMax(jps_Target) - UnitHealth(jps_Target)
	local health_pct = jps.hp(jps_Target)
	
----------------------
-- TARGET ENEMY
----------------------
	
	local ArenaUnit = {"arena1","arena2","arena3"}

	local FriendUnit = {}
	for name,index in pairs(jps.RaidStatus) do 
	if (index["inrange"] == true) then table.insert(FriendUnit,name) end
	end

	local EnemyUnit = {}
	for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end
	local lowestEnemy = jps.LowestInRaidTarget()

	local rangedTarget = "target"
	if jps.canDPS("target") then
	rangedTarget = "target"
	elseif jps.canDPS("focustarget") then
	rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
	rangedTarget = "targettarget"
	elseif jps.canDPS(lowestEnemy) then
	rangedTarget = lowestEnemy
	end

	local isboss = UnitLevel(rangedTarget) == -1 or UnitClassification(rangedTarget) == "elite"
	local canCastShadowfiend = jps.canDPS(rangedTarget) and (jps.TimeToDie(rangedTarget) > 12 ) or isboss or (UnitHealth(rangedTarget) > 200000)

---------------------
-- FIREHACK
---------------------

	if jps.FaceTarget and jps.canDPS(rangedTarget) then jps.Macro("/target "..rangedTarget) end
	
---------------------
-- TIMER
---------------------

	local player_Aggro =  jps.checkTimer("Player_Aggro")
	local player_IsInterrupt = jps.checkTimer("Spell_Interrupt")
	local stunMe = jps.StunEvents() --- return true/false ONLY FOR PLAYER
	local enemycount,targetcount = jps.RaidEnemyCount() 

	local swpDuration = jps.myDebuffDuration(589)
	local plagueDuration = jps.myDebuffDuration(2944)
	local vtDuration = jps.myDebuffDuration(34914)
	local sorbs = UnitPower("player",13)
	local vamptouch = tostring(select(1,GetSpellInfo(34914)))
	local swPain = tostring(select(1,GetSpellInfo(589)))
	
	local isAlone = (GetNumGroupMembers() == 0)  and UnitAffectingCombat(player)==1
	local isInBG = ((GetNumGroupMembers() > 0) and (UnitIsPVP(player) == 1) and UnitAffectingCombat(player)==1) or isAlone
	local isInPvE = (GetNumGroupMembers() > 0) and (UnitIsPVP(player) ~= 1) and UnitAffectingCombat(player)==1
	local targetControlled, timeControlled = jps.LoseControlTable(rangedTarget,{"CC", "Snare", "Root", "Silence", "Disarm"})
	local lastcast = jps.CurrentCast[2] -- jps.CurrentCast[2]) -- arg2 Spell name de event == "UNIT_SPELLCAST_SUCCEEDED"

----------------------------------------------------------
-- TRINKETS -- OPENING -- CANCELAURA -- SPELLSTOPCASTING
----------------------------------------------------------

if jps.buff(47585,"player") then return end -- "Dispersion" 47585
	
--	SpellStopCasting() -- "Mind Flay" 15407 -- "Mind Blast" 8092 -- buff 81292 "Glyph of Mind Spike"
local canCastMindBlast = false
local spellstop = UnitChannelInfo(player) -- it's a channeling spell so jps.CastTimeLeft(player) can't work (work only for UnitCastingInfo -- insead use jps.ChanelTimeLeft(unit)
	-- "Mind Blast" 8092 Stack shadow orbs -- buff 81292 "Glyph of Mind Spike"
	if spellstop == tostring(select(1,GetSpellInfo(15407))) and (jps.cooldown(8092) == 0) and jps.buff(81292,player) then 
		canCastMindBlast = true
	-- "Divine Insight" proc "Mind Blast" 8092 -- "Divine Insight" Clairvoyance divine 109175
	elseif spellstop == tostring(select(1,GetSpellInfo(15407))) and (jps.cooldown(8092) == 0) and jps.buff(109175) then
		canCastMindBlast = true
	-- "Mind Blast" 8092
	elseif spellstop == tostring(select(1,GetSpellInfo(15407))) and (jps.cooldown(8092) == 0)  and (sorbs < 3) then 
		canCastMindBlast = true
	end

if canCastMindBlast and UnitChannelInfo("player")== nil then
	SpellStopCasting()
	spell = 8092
	target = rangedTarget
return end

------------------------
-- LOCAL FUNCTIONS -----
------------------------

local function ShadowWordDeath(unit)
	if jps.cooldown(32379) ~= 0 then return false end
	if (UnitHealth(unit)/UnitHealthMax(unit) > 0.20) then return false end
	return true
end

local function ShadowWordPain(unit)
	if jps.cooldown(589) ~= 0 then return false end
	if jps.mydebuff(589,unit) then return false end
	if (UnitHealth(unit)/UnitHealthMax(unit) > 0.20) then return false end -- pas gaspiller inutilement "Shadow Word: Pain"
	return true
end

local function LowHealthEnemy() -- return table
	local table=
	{
		-- "Cascade" Heal 121135 -- Shadow 127632
		{ 127632, (jps.cooldown(121135) == 0) and (enemycount > 1) , rangedTarget , "Cascade_"  },
		-- "Shadow Word: Death " 32379
		{ 32379, (UnitHealth(rangedTarget)/UnitHealthMax(rangedTarget) < 0.20) , rangedTarget , "Death" },
		-- "Devouring Plague" 2944	
		{ 2944, (sorbs > 0) , rangedTarget },
		-- "Mind Blast" 8092
		{ 8092, jps.cooldown(8092) == 0 and (jps.buffStacks(81292) == 2) , rangedTarget , "Blast" },
		-- "Mind Spike" 73510
		{ 73510, (jps.buffStacks(81292) < 2) , rangedTarget , "Spike" }, 
	}
return table
end

local function parse_multitarget()
local table = 
	{
	-- "Oubli" 586 PVE 
		{ 586, isInPvE and UnitThreatSituation(player)==3 , player },
	-- "Oubli" 586 PVP
		{ 586, (player_Aggro > 0) and (jps.useTrinket(1)== nil) , player },
	-- "Cascade" Heal 121135 -- Shadow 127632
		{ 127632, (jps.cooldown(121135) == 0) , rangedTarget , "Cascade_"  },
	-- "Mind Sear" 48045
		{ 48045, jps.cooldown(48045) == 0 , rangedTarget  },
	}
return table
end

local function unitFor_Leap(unit) -- {"CC", "Snare", "Root", "Silence", "Immune", "ImmuneSpell", "Disarm"}
	if (UnitIsUnit(unit,"player")==1) then return false end
	if jps.LoseControlTable(unit,{"CC", "Snare", "Root"}) then return true end
	return false
end

------------------------
-- SPELL TABLE ---------
------------------------

-- if jps.debuffDuration(114404,"target") > 18 and jps.UnitExists("target") then MoveBackwardStart() end
-- if jps.debuffDuration(114404,"target") < 18 and jps.debuff(114404,"target") and jps.UnitExists("target") then MoveBackwardStop() end

-------------------------------------------------------------
------------------------ TABLE SPELL ------------------------
-------------------------------------------------------------

local spellTable = {
-- "Shadowform" 15473 Stay in 
	{ 15473, not jps.buff(15473) , player },
-- TRINKETS -- jps.useTrinket(0) est "Trinket0Slot" est slotId  13 -- "jps.useTrinket(1) est "Trinket1Slot" est slotId  14  -- Do not use while Dispersion
	--{ jps.useTrinket(0), jps.UseCDs , player },
	--{ jps.useTrinket(1), jps.UseCDs , player },
-- "Pierre de soins" 5512
	{ {"macro","/use item:5512"}, UnitAffectingCombat(player)==1 and select(1,IsUsableItem(5512))==1 and jps.itemCooldown(5512)==0 and (playerhealth_pct < 0.50) , player , "UseItem" },

-- DAMAGE
-- "Mind Spike" "Mind Blast" in case low health
	{ "nested", UnitHealth(rangedTarget) < 90000 and vtDuration < 5 , LowHealthEnemy() },
-- "Mind Spike" 73510 proc -- "From Darkness, Comes Light" 109186 gives buff -- "Surge of Darkness" 87160
	{ 73510, jps.buff(87160) , rangedTarget }, -- buff 87160 "Surge of Darkness"
-- "Divine Insight" proc "Mind Blast" 8092
	{ 8092, jps.buff(109175) , rangedTarget }, -- "Divine Insight" Clairvoyance divine 109175
-- "Devouring Plague" 2944 plague when we have 3 orbs 	
	{ 2944, (sorbs == 3) , rangedTarget },
-- "Shadow Word: Death " "Mot de l'ombre : Mort" 32379
	{ 32379, ShadowWordDeath , EnemyUnit , "|cFFFF0000castDeath_EnemyUnit_" }, 	
	{ 32379, (UnitHealth(rangedTarget)/UnitHealthMax(rangedTarget) < 0.20) , rangedTarget, "|cFFFF0000castDeath_"..rangedTarget },

-- AGGRO
-- "Power Word: Shield" 17	
	{ 17, (player_Aggro > 0) and not jps.debuff(6788,player) and not jps.buff(17,player) , player }, -- Shield
-- "Oubli" 586 -- PVE 
	{ 586, isInPvE and UnitThreatSituation(player)==3 , player },
-- "Oubli" 586 -- PVP -- Fantasme 108942 -- vous dissipez tous les effets affectant le déplacement sur vous-même et votre vitesse de déplacement ne peut être réduite pendant 5 s
	{ 586, isInBG and IsSpellKnown(108942) and (player_Aggro > 0) and (jps.useTrinket(1)== nil) , player , "Oubli_Aggro" },
-- "Dispersion" 47585
	{ 47585, jps.cooldown(47585) == 0 and (player_Aggro > 0) and (playerhealth_pct < 0.40) , player , "Dispersion_Aggro" },
	{ 47585, jps.cooldown(47585) == 0 and (UnitPower (player,0)/UnitPowerMax (player,0) < 0.50) , player , "Dispersion_Mana" },
-- "Semblance spectrale" 112833 "Spectral Guise"
	{ 112833, jps.cooldown(112833) == 0 and (player_Aggro > 0) and (playerhealth_pct < 0.40) and (jps.cooldown(586) ~= 0) and (jps.cooldown(47585) ~= 0) , player ,"SPECTRAL GUISE" },

-- MULTITARGET
	{ "nested", jps.MultiTarget , parse_multitarget() },
	--{ "nested", (enemycount > 3) , parse_multitarget() },
	
-- "Mass Dispel" 32375 "Dissipation de masse"
	--{ 32375, jps.MagicDispel , FriendUnit , "|cFFFF0000Magic Dispel_"},
	
-- DAMAGE
-- "Vampiric Touch" 34914 Keep VT up with duration
	{ 34914, jps.mydebuff(34914,rangedTarget) and vtDuration < 2.5 and (lastcast ~= vamptouch or jps.LastCast ~= vamptouch) , rangedTarget },
-- "Shadow Word: Pain" 589 Keep SW:P up with duration
	{ 589, jps.mydebuff(589,rangedTarget) and swpDuration < 2.5 and (lastcast ~= swPain or jps.LastCast ~= swPain) , rangedTarget },
-- "Power Infusion" "Infusion de puissance" 10060
	{ 10060, UnitAffectingCombat(player)==1 and jps.cooldown(10060) == 0 and (UnitPower (player,0)/UnitPowerMax (player,0) > 0.20) , player },
-- "Mind Blast" 8092 Stack shadow orbs -- buff 81292 "Glyph of Mind Spike"
	{ 8092, jps.cooldown(8092) == 0 and jps.buff(81292,player) , rangedTarget },
-- "Mind Blast" 8092 Stack shadow orbs
	{ 8092, jps.cooldown(8092) == 0 , rangedTarget },
-- "Shadow Word: Pain" 589
	{ 589, not jps.mydebuff(589,rangedTarget) and (lastcast ~= swPain or jps.LastCast ~= swPain) , rangedTarget },
-- "Vampiric Touch" 34914 
	{ 34914, (not jps.mydebuff(34914,rangedTarget)) and (lastcast ~= vamptouch or jps.LastCast ~= vamptouch) , rangedTarget },
-- "Cascade" Heal 121135 -- Shadow 127632
	{ 127632, (jps.cooldown(121135) == 0) , rangedTarget , "Cascade_" },
-- "Divine Star" Heal 110744 -- Shadow 122121
	{ 122121, (jps.cooldown(122121) == 0) , rangedTarget , "Divine Star_" },
-- "Mindbender" "Torve-esprit" 123040 -- "Ombrefiel" 34433 "Shadowfiend"
	{ 34433, jps.cooldown(34433) == 0 and canCastShadowfiend , rangedTarget },
	{ 123040, jps.cooldown(123040) == 0 and canCastShadowfiend , rangedTarget },
	
-- DISPEL
-- "Purifier" 527 -- UNAVAILABLE IN SHADOW FORM 15473

-- HEAL
-- "Passage dans le Vide" -- "Void Shift" 108968
	{ 108968, UnitAffectingCombat(player)==1 and (health_pct < 0.40) and (player_Aggro == 0) and UnitIsUnit(jps_Target,player)~=1 and (playerhealth_pct > 0.80) , jps_Target , "Void Shift"..jps_Target },
-- "Vampiric Embrace" 15286
	{ 15286, health_pct < 0.60 , player },
-- "Prière du désespoir" 19236
	{ 19236, UnitAffectingCombat(player)==1 and select(2,GetSpellBookItemInfo(desesperate))~=nil and jps.cooldown(19236)==0 and (playerhealth_pct < 0.50) , player },
-- "Inner Fire" 588 Keep Inner Fire up 
	{ 588, not jps.buff(588,player) and not jps.buff(73413,player), player }, -- "Volonté intérieure" 73413
-- "Fear Ward" "Gardien de peur" 6346 -- FARMING OR PVP -- NOT PVE
	{ 6346, isInBG and not jps.buff(6346,player) , player },
-- "Prayer of Mending" "Prière de guérison" 33076 
	{ 33076, not jps.buff(33076,player) and (playerhealth_pct < 0.60) , player , "Mending_Health_"..player },
	{ 33076, not jps.buff(33076,jps_Target) and (health_pct < 0.60) , jps_Target , "Mending_Health_"..jps_Target },
-- "Renew" 139 Self heal when critical 
	{ 139, (playerhealth_pct < 0.75) and not jps.buff(139,player), player },
	{ 139, isInBG and (health_pct < 0.50) and not jps.buff(139,jps_Target), jps_Target },
-- "Don des naaru" 59544 -- YOU CAN'T DO IT YOU ARE IN SHAPESHIFT FORM
	--{ 59544, select(2,GetSpellBookItemInfo(giftnaaru))~=nil and (playerhealth_pct < 0.80) , player },
-- "Mind Flay" 15407
	{ 15407, jps.cooldown(15407) == 0 , rangedTarget },
}

-------------------------------------------------------------
------------------------ MOVING PVE -------------------------
-------------------------------------------------------------

local spellTable_moving = 
{
	["ToolTip"] = "Shadow Priest Moving",
-- "Shadowform" 15473 Stay in 
	{ 15473, not jps.buff(15473) , player },
-- TRINKETS -- jps.useTrinket(0) est "Trinket0Slot" est slotId  13 -- "jps.useTrinket(1) est "Trinket1Slot" est slotId  14  -- Do not use while Dispersion

-- "Pierre de soins" 5512
	{ {"macro","/use item:5512"}, UnitAffectingCombat(player)==1 and select(1,IsUsableItem(5512))==1 and jps.itemCooldown(5512)==0 and (playerhealth_pct < 0.50) , player , "UseItem" },

-- AGGRO
-- "Power Word: Shield" 17	
	{ 17, (player_Aggro > 0) and not jps.debuff(6788,player) and not jps.buff(17,player) , player }, -- Shield
-- "Oubli" 586 -- PVE 
	{ 586, isInPvE and UnitThreatSituation(player)==3 , player },
-- "Oubli" 586 -- PVP -- Fantasme 108942 -- vous dissipez tous les effets affectant le déplacement sur vous-même et votre vitesse de déplacement ne peut être réduite pendant 5 s
	{ 586, isInBG and IsSpellKnown(108942) and (player_Aggro > 0) and (jps.useTrinket(1)== nil) , player , "Oubli_Aggro" },
-- "Dispersion" 47585
	{ 47585, jps.cooldown(47585) == 0 and (player_Aggro > 0) and (playerhealth_pct < 0.40) , player , "Dispersion_Aggro" },
	{ 47585, jps.cooldown(47585) == 0 and (UnitPower (player,0)/UnitPowerMax (player,0) < 0.50) , player , "Dispersion_Mana" },
-- "Semblance spectrale" 112833 "Spectral Guise"
	{ 112833, jps.cooldown(112833) == 0 and (player_Aggro > 0) and (playerhealth_pct < 0.40) and (jps.cooldown(586) ~= 0) and (jps.cooldown(47585) ~= 0) , player ,"SPECTRAL GUISE" },

-- DAMAGE
-- "Shadow Word: Pain" 589 Keep SW:P up with duration
	{ 589, jps.mydebuff(589,rangedTarget) and swpDuration < 2.5 and (lastcast ~= swPain or jps.LastCast ~= swPain) , rangedTarget },
-- "Divine Insight" proc "Mind Blast" 8092
	{ 8092, jps.buff(109175) , rangedTarget }, -- "Divine Insight" Clairvoyance divine 109175
-- "Devouring Plague" 2944 plague when we have 3 orbs 	
	{ 2944, (sorbs > 0) , rangedTarget },
-- "Shadow Word: Death " "Mot de l'ombre : Mort" 32379
	{ 32379, isInBG and jps.IsCastingPoly(rangedTarget) , rangedTarget , "|cFFFF0000castDeath_Polymorph_"..rangedTarget },
	{ {"func", 32379 , jps.IsCastingPoly}, isInBG , EnemyUnit , "|cFFFF0000castDeath_Polymorph_Cond_Multi_" }, 
	{ 32379, ShadowWordDeath , EnemyUnit , "|cFFFF0000castDeath_EnemyUnit_" }, 	
	{ 32379, isInBG and (UnitHealth(rangedTarget)/UnitHealthMax(rangedTarget) < 0.20) , rangedTarget, "|cFFFF0000castDeath_"..rangedTarget },
-- "Shadow Word: Pain" 589 Keep up
	{ 589, (not jps.mydebuff(589,rangedTarget)) and (lastcast ~= swPain or jps.LastCast ~= swPain) , rangedTarget },
-- "Cascade" Heal 121135 -- Shadow 127632
	{ 127632, (jps.cooldown(121135) == 0) and (enemycount > 1) , rangedTarget , "Cascade_" },
-- "Divine Star" Heal 110744 -- Shadow 122121
	{ 122121, (jps.cooldown(122121) == 0) , rangedTarget , "Divine Star_" },
-- "Mindbender" "Torve-esprit" 123040 -- "Ombrefiel" 34433 "Shadowfiend"
	{ 34433, jps.cooldown(34433) == 0 and canCastShadowfiend , rangedTarget },
	{ 123040, jps.cooldown(123040) == 0 and canCastShadowfiend , rangedTarget },
	
-- DISPEL
-- "Purifier" 527 -- UNAVAILABLE IN SHADOW FORM 15473
	
-- HEAL
-- "Passage dans le Vide" -- "Void Shift" 108968
	{ 108968, UnitAffectingCombat(player)==1 and (health_pct < 0.40) and (player_Aggro == 0) and UnitIsUnit(jps_Target,player)~=1 and (playerhealth_pct > 0.80) , jps_Target , "Void Shift"..jps_Target },
-- "Vampiric Embrace" 15286
	{ 15286, health_pct < 0.60 , player },
-- "Prière du désespoir" 19236
	{ 19236, UnitAffectingCombat(player)==1 and select(2,GetSpellBookItemInfo(desesperate))~=nil and jps.cooldown(19236)==0 and (playerhealth_pct < 0.50) , player },
-- "Don des naaru" 59544 -- YOU CAN'T DO IT YOU ARE IN SHAPESHIFT FORM
	--{ 59544, select(2,GetSpellBookItemInfo(giftnaaru))~=nil and (playerhealth_pct < 0.80) , player },
-- "Inner Fire" 588 Keep Inner Fire up 
	{ 588, not jps.buff(588,player) and not jps.buff(73413,player), player }, -- "Volonté intérieure" 73413
-- "Fear Ward" "Gardien de peur" 6346 -- FARMING OR PVP -- NOT PVE
	{ 6346, isInBG and not jps.buff(6346,player) , player },
-- "Prayer of Mending" "Prière de guérison" 33076 
	{ 33076, not jps.buff(33076,player) and (playerhealth_pct < 0.60) , player , "Mending_Health_"..player },
	{ 33076, not jps.buff(33076,jps_Target) and (health_pct < 0.60) , jps_Target , "Mending_Health_"..jps_Target },
-- "Renew" 139 Self heal when critical 
	{ 139, (playerhealth_pct < 0.75) and not jps.buff(139,player), player },
-- "Don des naaru" 59544 -- YOU CAN'T DO IT YOU ARE IN SHAPESHIFT FORM
	--{ 59544, select(2,GetSpellBookItemInfo(giftnaaru))~=nil and (playerhealth_pct < 0.80) , player },

}
	--local spellTable_moving = jps.deepTableCopy(spellTable[1])
	if jps.Moving then
		jps.Tooltip = spellTable_moving["ToolTip"]
		spell, target = parseSpellTable(spellTable_moving)
	else
		spell,target = parseSpellTable(spellTable)
	end
	return spell,target
end, "Shadow Priest PvE", true, false)

-- Vampiric Embrace -- 3-minute cooldown with a 15-second duration. It causes all the single-target damage you deal to heal nearby allies for 50% of the damage
-- Void Shift  -- allows you to swap health percentages with your target raid or party member. It can be used to save raid members, by trading your life with theirs, or to save yourself in the same way
-- Dispersion  -- use Dispersion immediately after using Mind Blast and while none of your DoTs need to be refreshed. In this way, Dispersion will essentially take the place of  Mind Flay in your rotation, which is your weakest spell
