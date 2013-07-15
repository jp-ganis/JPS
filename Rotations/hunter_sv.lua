jps.registerRotation("HUNTER","SURVIVAL", function()
-- by tropic
jps.Tooltip = "::Survival Hunter (PvE)::\n- Shift-key: \"Explosive Trap\"\n- Alt-key: \"Freezing Trap\"\n- Control-key: \"Snake Trap\"\n- Shift+Control-key: \"Ice Trap\"\nMisdirect to Pet when soloing or misdirect to \"focus\" in party/raid.\nUse CDs: Blows all cooldowns: trinkets, eng. gloves, \n  talents, pots (if boss) etc. (manually use \"Readiness\") \nAuto use \"Healthstone\" at 50% hp, \"Mend Pet\" at 90% hp.\nInterrupt spell cast with \"Silencing Shot\".\nCheck file for talents and glyphs..."
--------------
--- TALENTS --
--------------
-- http://www.wowhead.com/talent#hTE

---------------
---- GLYPHS ---
---------------
-- Major: (1) Glyph of Deterrence (2) Glyph of Misdirection (3) Glyph of Animal Bond
-- Minor: (1) Glyph of Revive Pet (2) Glyph of Aspect of the Cheetah (3) Glyph of Aspect of the Pack

---------------
---- INFO -----
---------------
-- will auto misdirect to pet if soloing
-- misdirect to "focus" e.g. in party/raid
-- mend pet when hp is less than 90%
-- interrupt spellcasting with Silencing Shot
-- use CDs incl. Lifeblood (herbalism)
-- hot-keys for traps

---------------
---- SETUP ----
---------------
local spell = nil
local focus = UnitMana("player")

---------------------
--- TRAP HOT-KEYS ---
---------------------
-- Reset keys to zero
local shiftKEY_binary = 0
local altKEY_binary = 0
local controlKEY_binary = 0

-- Register key downs
if IsShiftKeyDown() ~= nil    	and GetCurrentKeyBoardFocus() == nil then shiftKEY_binary = 1 	end
if IsAltKeyDown() ~= nil 	and GetCurrentKeyBoardFocus() == nil then altKEY_binary = 2 	end
if IsControlKeyDown() ~= nil 	and GetCurrentKeyBoardFocus() == nil then controlKEY_binary = 4 end

-- Binary calculation
trapKEY_combo = shiftKEY_binary + altKEY_binary + controlKEY_binary
-- print("Trap key combo pressed: ",trapKEY_combo) -- FOR TESTING PURPOSE

-- Binary key combinations
-- 1 = Shift
-- 2 = Alt
-- 3 = Shift + Alt
-- 4 = Control
-- 5 = Shift + Control
-- 6 = Alt + Control
-- 7 = Shift + Alt + Control
if trapKEY_combo == 1 then ExplosiveTrap_KEY 	= true 	else ExplosiveTrap_KEY 	= false end -- Launch Explosiv trap
if trapKEY_combo == 2 then FreezingTrap_KEY 	= true  else FreezingTrap_KEY 	= false end -- Launch Freezing trap (ice block trap)
if trapKEY_combo == 4 then SnakeTrap_KEY 	= true  else SnakeTrap_KEY 	= false end -- Launch Snake trap
if trapKEY_combo == 5 then IceTrap_KEY 		= true  else IceTrap_KEY 	= false end -- Launch Ice trap (ice on ground)
if trapKEY_combo == 6 then allInOneTraps_KEY 	= true 	else allInOneTraps_KEY 	= false end -- Launch all traps after each other

--------------------
-- Auto use setup --
--------------------
-- Pots
local autoUseVirminsBite = true -- Increases your Agility by 4000 for 25 sec. (1 Min Cooldown)

---------------------------------------------------------
-- Pet target check - force pet to attack playertarget --
---------------------------------------------------------
-- IMPORTANT!! pet must be set to "Passive" on the pet actionbar, this is done automatically below
local petTargetID = UnitGUID("pettarget") 		-- get unique ID on pettarget
local playerTargetID = UnitGUID("target") 		-- get unique ID on playertarget
local petShouldAttackMyTarget = false 			-- default to false
if playerTargetID ~= nil				-- 1) check if player has target,
and playerTargetID ~= petTargetID			-- 2) check petarget is equal to playertarget,
and UnitCanAttack("player", "target") ~= nil then	-- 3) check that player can attack current target
petShouldAttackMyTarget = true				-- set variable to true = pet should attack playertarget
end

-------------------------------------------------------
-- Pet passive mode check - force pet to PassiveMode --
-------------------------------------------------------
-- Check pet is passive, returns 1/nil
local _, _, _, _, petIsPassive, _, _ = GetPetActionInfo(10) -- Slot 10 is PassiveMode on the pet actionbar

-----------------
-- Spell Table --
-----------------

	local spellTable =  {
		["ToolTip"] = "SV Hunter PVE 5.3",
		-- Preparation (flasks)
		{ jps.useBagItem("Alchemist's Flask") , not jps.buff("Enhanced Agility") and not jps.buff("Flask of Spring Blossoms") and jps.UseCDs},
		-- Revive pet
		{ "Heart of the Phoenix",		UnitIsDead("pet") ~= nil and HasPetUI() ~= nil }, -- Instant revive pet (only some pets, Ferocity)
		{ "Revive Pet",				((UnitIsDead("pet") ~= nil and HasPetUI() ~= nil) or HasPetUI() == nil) and not jps.Moving }, 
		-- Heal pet
		{ "Mend Pet", 				jps.hp("pet") < 0.90 and not jps.buff("Mend Pet","pet") },
		-- Set pet to passive (IMPORTANT!)
		{ {"macro","/script PetPassiveMode()"},	petIsPassive == nil }, -- Set pet to passive
		-- Misc
		{ {"macro","/petattack"}, 		petShouldAttackMyTarget },
		{ "Aspect of the Hawk", 		not jps.buff("Aspect of the Hawk") and not jps.buff("Aspect of the Iron Hawk") }, -- Tier 3 talent
		-- Misdirect to pet if no "focus" -- for farming, best with Glyph of Misdirection
		{ "Misdirection", 			not jps.buff("Misdirection") and UnitExists("focus") == nil and not IsInGroup() and UnitExists("pet") ~= nil, "pet" }, -- IsInGroup() returns true/false. Works for any party/raid
		{ "Misdirection", 			not jps.buff("Misdirection") and UnitExists("focus") ~= nil, "focus" },
		-- Healthstone
		{ jps.useBagItem("Healthstone") , 	jps.hp("player") < 0.50 }, -- restores 20% of total health
		-- 
		{ "Silencing Shot", 			jps.shouldKick() and jps.CastTimeLeft("target") < 1.4 }, -- Tier 2 talent
		-- Trinkets and Engineering Gloves
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		-- Requires herbalism
		{ "Lifeblood",			jps.UseCDs },	
		-- Use pot
		{ jps.useBagItem("Virmen's Bite"), 	autoUseVirminsBite and jps.UseCDs and (jps.buff("Rapid Fire") or jps.bloodlusting()) }, 	
--		{ "Readiness", 				jps.UseCDs }, -- Resets all cooldowns except Stampede. Use to chain DPS cooldowns.
		{ "A Murder of Crows", 			jps.UseCDs and not jps.mydebuff("A Murder of Crows")}, -- Tier 5 talent
		{ "Dire Beast", 			"onCD" }, -- Tier 4 talents
--		{ "Rabid", 				jps.UseCDs }, -- Pet ability
		{ "Rapid Fire", 			jps.UseCDs and not jps.buff("Rapid Fire") and not jps.bloodlusting() },
		{ "Stampede", 				jps.UseCDs },
		-- Traps
		{ "Trap Launcher", 			not jps.buff("Trap Launcher") },
		{ "Explosive Trap",			(ExplosiveTrap_KEY 	or allInOneTraps_KEY) and jps.buff("Trap Launcher") }, 
		{ "Ice Trap",				(IceTrap_KEY 		or allInOneTraps_KEY) and jps.buff("Trap Launcher") }, 	
		{ "Snake Trap",				(SnakeTrap_KEY 		or allInOneTraps_KEY) and jps.buff("Trap Launcher") }, 	
		{ "Freezing Trap",			FreezingTrap_KEY 	and jps.buff("Trap Launcher") }, 	
		-- Rotation
		{ "explosive shot", 			jps.buff("lock and load") and jps.debuffDuration("explosive shot") < 1.0 },
		{ "Glaive Toss", 			"onCD"}, -- Tier 6 talent
		-- AoE
		{ "Multi-Shot", 			jps.MultiTarget },
		{ "cobra shot", 			jps.MultiTarget },
		-- Single target
		{ "kill shot", 				"onCD" }, -- Target below 20%
		{ "serpent sting", 			jps.myDebuffDuration("serpent sting") < .3 },
		{ "explosive shot", 			jps.myDebuffDuration("explosive shot") < .3 },
		{ "black arrow", 			not jps.mydebuff("black arrow") and not jps.MultiTarget },
		{ "cobra shot", 			jps.myDebuffDuration("serpent sting") < 6 },
		{ "arcane shot", 			focus >= 70 and not jps.buff("lock and load") and not jps.MultiTarget },
		{ "cobra shot", 			"onCD"},
	}

	jps.petIsDead = false

	spell,target = parseSpellTable(spellTable)
	return spell,target
	
end, "Default")