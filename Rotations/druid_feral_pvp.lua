--[[[
@rotation Default PvP
@class DRUID
@spec FERAL
@talents U!20.120!YXQr
@author SwollNMember
@description 
Thanks to jpganis for the original version and attack conditionals.[br]
User Notes:[br]
[*] Put DPS trinket in top trinket slot and PvP loss of control trinket in bottom slot.[br]
[*] Hold down shift key to force multitarget attacks.[br]
[*] Force of Nature is cast when targeting the ground anywhere in the world frame.[br]
[*] Primary attack conditionals consolidated into functions to provide clarity and reduce clutter.[br]
[*] Auto-shifts out of roots and returns to cat, bear or aquatic form.[br]
[*] Casts shred when behind target, otherwise casts mangle.[br]
[*] When King of the Jungle is active subs ravage for shred and mangle.[br]
[*] [code]CTRL-SHIFT[/code]: Cast Rain of Fire @ Mouse - ignoring the current RoF duration[br]
[*] [code]CTRL[/code]: If target is dead or ghost cast Soulstone, else cast Havoc @ Mouse[br]
[*] [code]ALT[/code]: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)[br]
[*] [code]jps.Interrupts[/code]: Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)[br]
[*] [code]jps.Defensive[/code]: Create Healthstone if necessary, cast mortal coil and use ember tap[br]
[*] [code]jps.UseCDs[/code]: Use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated![br]
]]--


jps.registerRotation("DRUID","FERAL", function()
	local spell = nil
	local target = nil

	local player = jpsName
	local energy = UnitMana(player)
	local comboPoints = GetComboPoints(player)
	local tigerFuryCD = jps.cooldown("tiger's fury")
	local ripDuration = jps.debuffDuration("rip")
	local rakeDuration = jps.debuffDuration("rake")
	local srDuration = jps.buffDuration("savage roar")
	local srRipSyncTimer = abs(ripDuration - srDuration)
	local executePhase = jps.hp("target") <= 0.25
	local gcdLocked = true -- they changed this :( jps.cooldown("shred") == 0 Deprecated?
	local energyPerSec = 10.59
	local clearcasting = jps.buff("clearcasting")
	local berserking = jps.buff("berserk")
	local tigerFury = jps.buff("tiger's fury")
	local pSwift = jps.buff("predatory swiftness")
	local lacerateStacks = jps.buffStacks(33745)
	local form = GetShapeshiftForm() -- 1=Bear, 2=Aquatic, 3=Cat
	local isSwimming = IsSwimming() or IsSubmerged()
	local isFalling = IsFalling()
	
	local stunMe = jps.StunEvents()
	local hasControl = HasFullControl()
	local player_Aggro = jps.checkTimer( "Player_Aggro" )

	local playerRace = UnitRace(player)
	local targetClass = UnitClass("target")
	local targetSpec = GetSpecialization("target")
	local enemycount,targetcount = jps.RaidEnemyCount()

	local isSpellHarmful = IsHarmfulSpell("target")
	local lastcast = jps.CurrentCast
	local castSilence = jps.shouldKick("target")

	local playerhealth_pct = jps.hp(player)
	local targethealth_pct = jps.hp("target")
	local focushealth_pct = jps.hp("focus")
	local mousehealth_pct = jps.hp("mouseover")

	local EnemyUnit = {}
		for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end

	local rangedTarget = "target"
		if jps.canDPS("target") then rangedTarget = "target"
		elseif jps.canDPS("focustarget") then rangedTarget = "focustarget"
		elseif jps.canDPS("targettarget") then rangedTarget = "targettarget"
		elseif jps.canDPS(EnemyUnit[1]) then rangedTarget = EnemyUnit[1]
	end
------------------------
-- LOCAL FUNCTIONS -----
------------------------

-- Hibernate Conditions
	local function shouldSleep()
		if UnitCreatureType(rangedTarget) == "beast" then return true end
		if jps.buff("bear form",rangedTarget) then return true end
		if jps.buff("cat form",rangedTarget) then return true end
		if jps.buff("aquatic form",rangedTarget) then return true end
		if jps.buff("travel form",rangedTarget) then return true end
		if jps.buff("ghost wolf",rangedTarget) then return true end
	return false
	end

-- Soothe Conditions
	local function shouldSoothe()
		if jps.buff("vengeance",rangedTarget) then return true end
		if jps.buff("the beast within",rangedTarget) then return true end
		if jps.buff("bestial wrath",rangedTarget) then return true end
		if jps.buff("bloodthirst",rangedTarget) then return true end
		if jps.buff("enraged",rangedTarget) then return true end
		if jps.buff("berserker rage",rangedTarger) then return true end
	return false
	end

-- Is Target Melee?
	local function isMelee()
		if targetClass == "death knight" or targetClass == "hunter" or targetClass == "rogue" or targetClass == "warrior" then return true end
		if targetSpec == "enhancement" or targetSpec == "retribution" or targetSpec == "windwalker" or targetSpec == "brewmaster" then return true end
		if jps.buff("bear form","target") or jps.buff("cat form","target") then return true end
	return false
	end

-- Shred Conditions
	local function shouldShred()
		if clearcasting then return true end
		if jps.buffDuration("predatory swiftness") > 1 and not (energy + (energyPerSec * (jps.buffDuration("predatory swiftness")-1)) < (4 - comboPoints)*20) then return true end
		if ((comboPoints < 5 and ripDuration < 3) or (comboPoints == 0 and srDuration < 2 )) then return true end
		if berserking or jps.buff("tiger's fury") then return true end
		if tigerFuryCD <= 3 then return true end
		if energy >= 100 - (energyPerSec*2) then return true end
	return false
	end

-- Mangle Conditions
	local function shouldMangle()
		if clearcasting then return true end
		if jps.buffDuration("predatory swiftness") > 1 and not (energy + (energyPerSec * (jps.buffDuration("predatory swiftness")-1)) < (4 - comboPoints)*20) then return true end
		if ((comboPoints < 5 and ripDuration < 3) or (comboPoints == 0 and srDuration < 2 )) then return true end
		if berserking or jps.buff("tiger's fury") then return true end
		if tigerFuryCD <= 3 then return true end
		if energy >= 100 - (energyPerSec*2) then return true end
	return false
	end

-- Rake Conditions
	local function shouldRake()
		if not jps.RakeBuffed then return true end
		if rakeDuration < 3 and (berserking or tigerFuryCD+0.8 >= rakeDuration) then return true end
		if not jps.mydebuff("rake") then return true end
	return false
	end

-- Savage Roar Conditions
	local function shouldRoar()
		if srDuration <= 1 then return true end
		if srDuration <= 3 and comboPoints > 0 then return true end
		if srDuration <= 6 and comboPoints >= 5 and ripDuration > 4 then return true end
		if srDuration <= 6 and comboPoints >= 5 then return true end
	return false
	end

-- Rip Conditions
	local function shouldRip()
		if jps.buff("cloak of shadows",target) then return true end
		if comboPoints >= 5 and executePhase and not jps.RipBuffed then return true end
		if comboPoints >= 5 and ripDuration < 2 then return true end
		if comboPoints >= 5 and ripDuration < 2 and (berserking or ripDuration < tigerFuryCD) then return true end
		if comboPoints >= 5 and not jps.debuff("rip") then return true end
	return false
	end

-- Ferocious Bite Conditions
	local function shouldBite(unit)
		if executePhase and comboPoints > 0 and ripDuration <= 2 and ripDuration > 0 then return true end
		if executePhase and comboPoints == 5 and ripDuration > 0 then return true end
		if comboPoints >= 5 and ripDuration > 4 then return true end
	return false
	end
		
-- Thrash Conditions
	local function shouldThrash()
		if clearcasting and jps.debuffDuration("thrash") < 3 then return true end
		if comboPoints >= 5 and jps.debuffDuration("thrash") < 6 and (tigerFury or berserking) then return true end
		if comboPoints >= 5 and jps.debuffDuration("thrash") < 6 and tigerFuryCD <= 3 then return true end
		if comboPoints >= 5 and jps.debuffDuration("thrash") < 6 and energy >= 100 - energyPerSec then return true end
	return false
	end

-- Faerie Swarm Conditions
	local function shouldFSwarm()
		if IsSpellInRange("faerie swarm",rangedTarget) == 1 and IsSpellInRange("rip",rangedTarget) == 0 then return true end
		if targetClass == "death knight" or targetClass == "hunter" or targetClass == "paladin" or targetClass == "warrior" then return true end
		if targetSpec == "enhancement" then return true end
		if jps.buff("bear form",rangedTarget) then return true end
		if jps.MovingTarget and not jps.LoseControl(rangedTarget,"Snare") then return true end
		if not jps.LoseControl(rangedTarget,"Root") and IsSpellInRange("rip",rangedTarget) == 0 then return true end
	return false
	end

-- Nature's Swiftness Conditions
	local function shouldNSwift()
		if not pSwift and comboPoints >= 5 and executePhase then return true end
		if not pSwift and comboPoints >= 5 and ripDuration < 3 and (berserking or ripDuration <= tigerFuryCD) and not executePhase then return true end
	return false
	end

-- Healing Touch Conditions
	local function shouldHTouch()
		if jps.buff("predatory swiftness") and comboPoints >= 4 then return true end
		if jps.buff("predatory swiftness") and not clearcasting and energy < 45 and comboPoints < 4 and jps.buffDuration("predatory swiftness") <= 1 then return true end
		if jps.buff("nature's swiftness") then return true end
	return false
	end

-- Multitarget Attack Table
	local function parse_multitarget()
	local table =
	{
		{ "savage roar", srDuration == 0 , player },
		{ "tiger's fury", energy <= 35 and not clearcasting and gcdLocked , player },
		{ "thrash", not jps.debuff("thrash") or jps.debuffDuration("thrash") < 2 , rangedTarget },
		{ "swipe", energy > 51 , rangedTarget },
	}
	return table
	end
------------------------
-- SPELL TABLE ---------
------------------------
local spellTable =
{
	{ SetView(1),			 },
	{ "cat form",						form ~= 3 and playerhealth_pct > 0.20 and isSwimming == nil , player },
	{ "cat form",						form ~= 3 and isFalling == 1 , player },
	{ "aquatic form",			  	form ~= 2 and isSwimming == 1 and playerhealth_pct > 0.20 , player },
	{ "wild charge",					IsSpellInRange("wild charge",rangedTarget) == 1 , rangedTarget }, -- or jps.IsSpellInRange("wild charge") "target" by default
	
	-- Remove Snares, Roots, Loss of Control, etc.
	{ "dash",							jps.LoseControl(player,"Root") or jps.LoseControl(player,"Snare") , player },
	{ "berserk",				 	jps.LoseControl(player,"Fear") , player },
	{ CancelShapeshiftForm(),		jps.LoseControl(player,"Root") , player },
	{ CancelShapeshiftForm(),  	 player_Aggro > 0 and jps.IsCastingSpell("hibernate",rangedTarget) and jps.CastTimeLeft(rangedTarget) < 1 , player },
	
	-- Kicks, Crowd Control, etc.
	{ "skull bash",			 	jps.shouldKick() , rangedTarget },
	{ "mighty bash",			 	jps.shouldKick() , rangedTarget },
	{ "maim",						 	jps.shouldKick() , rangedTarget },
	{ "pounce",					  	jps.shouldKick() , rangedTarget },
	{ "force of nature",		  	jps.shouldKick() , rangedTarget },
	{ "bash",					 	jps.shouldKick() , rangedTarget }, -- Only available after Force of Nature
	{ "hibernate",				 	jps.shouldKick() and shouldSleep() , rangedTarget },
	
	-- Racials
	{ "war stomp",			 		jps.shouldKick() and playerRace == "tauren" , rangedTarget },
	
	-- Survival, Heals, etc.
	{ "barkskin",			 		playerhealth_pct < 0.30 , player },
	{ "might of ursoc",			 playerhealth_pct < 0.30 , player },
	{ "bear form",				  	playerhealth_pct < 0.20 and isMelee() and playerhealth_pct < targethealth_pct , player },
	{ "survival instincts",	  	playerhealth_pct < 0.20 , player },
	{ "frenzied regeneration",  	playerhealth_pct < 0.20 , player },
	{ "nature's vigil",				jps.UseCDs and jps.buff("berserk") , player },
	{ "maim",					 	playerhealth_pct < 0.50 , player },
	{ "rejuvenation",			 	playerhealth_pct < 0.50 and jps.debuff("maim") , player },
	{ "healing touch",			 	shouldHTouch() , player },
	-- Debuffs
	{ "faerie swarm",			 	shouldFSwarm() and not jps.debuff("weakend armor") , rangedTarget },
	{ "faerie swarm",			  	targetClass == "rogue" or jps.buff("cat form",rangedTarget) and not jps.debuff("faerie fire",rangedTarget) , rangedTarget },
	{ "stampeding roar",		  	},
	{ "soothe",					  	shouldSoothe() , rangedTarget },		
	
	-- Buffs
	{ "mark of the wild",		 	not jps.buff("mark of the wild") , player },
	
	-- Engineers may have synapse springs on their gloves (slot 10). 
	{ jps.useSynapseSprings,  jps.useSynapseSprings ~= "" and jps.UseCDs },
	
	-- DPS Racial
	{ jps.DPSRacial,  jps.UseCDs },
	
	-- Lifeblood  (requires herbalism) 
	{ "Lifeblood", jps.UseCDs },
	
	{ "savage roar",			 	shouldRoar() , player },
	{ "tiger's fury",			  	jps.UseCDs and energy <= 35 and not clearcasting , player },
	{ "berserk",					 	jps.UseCDs and jps.buff("tiger's fury") , player },
	{ "berserk",					 	jps.UseCDs and not jps.buff("tiger's fury") and jps.cooldown("tiger's fury") > 15 , player },
	{ "incarnation",			 	jps.UseCDs and jps.buff("berserk") , player },
	{ "prowl",							jps.buff("incarnation: king of the jungle") , player }, -- Increase damage 20% from stealth 

	-- Multitarget 
	{ "nested",				 		(enemycount > 2) and targethealth_pct >= 0.25 and IsSpellInRange("skull bash",rangedTarget) == 0 , parse_multitarget() },
	{ "nested",					  	IsShiftKeyDown ~= nil , parse_multitarget() },
	
	-- Single Target 
	{ "maim",							executephase , rangedTarget },
	{ "ferocious bite",			 shouldBite() , rangedTarget },
	
	-- Base Attacks
	{ "lacerate",			 		targetClass == "rogue" and not jps.debuff("lacerate") , rangedTarget },
	{ "ravage",					  	jps.buff("incarnation: king of the jungle") , rangedTarget },		
	{ "shred",				 		jps.isBehind and shouldShred() and not jps.buff("incarnation: king of the jungle") , rangedTarget },
	{ "mangle",						jps.isNotBehind and shouldMangle() and not jps.buff("incarnation: king of the jungle") , rangedTarget },
	{ "rake",				 		shouldRake() , rangedTarget },
	{ "rip",							shouldRip() , rangedTarget },
	{ {"macro","/startattack"}, 	nil , rangedTarget },
	-- Output
	--{ {"macro","/run print('END')"},true},
}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end,"Default PvP",false,true)
