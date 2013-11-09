--[[[
@rotation BM Hunter PVE 5.3
@class HUNTER
@spec BEASTMASTERY
@author tropic
@description
Features:[br]
[*] auto misdirect to pet if soloing[br]
[*] misdirect to "focus" e.g. in party/raid[br]
[*] mend pet when hp is less than 90%[br]
[*] interrupt spellcasting with Silencing Shot[br]
[*] use CDs incl. Lifeblood (herbalism)[br]
[*] hot-keys for traps[br]
]]--


jps.registerRotation("HUNTER","BEASTMASTERY", function()

	local spell = nil
	local target = nil
	local sps_duration = jps.debuffDuration("serpent sting")
	local focus = UnitMana("player")
	local pet_focus = UnitMana("pet")
	local pet_frenzy = jps.buffStacks("Frenzy Effect","pet")
	local pet_attacking = IsPetAttackActive()

	---------------
	---- INFO -----
	---------------
	-- will auto misdirect to pet if soloing
	-- misdirect to "focus" e.g. in party/raid
	-- mend pet when hp is less than 90%
	-- interrupt spellcasting with Silencing Shot
	-- use CDs incl. Lifeblood (herbalism)
	-- hot-keys for traps

	---------------------
	--- TRAP HOT-KEYS ---
	---------------------
	-- Reset keys to zero
	local shiftKEY_binary = 0
	local altKEY_binary = 0
	local controlKEY_binary = 0

	-- Register key downs
	if IsShiftKeyDown() ~= nil 		and GetCurrentKeyBoardFocus() == nil then shiftKEY_binary = 1 	end
	if IsAltKeyDown() ~= nil 		and GetCurrentKeyBoardFocus() == nil then altKEY_binary = 2 	end
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
	if trapKEY_combo == 4 then SnakeTrap_KEY 		= true  else SnakeTrap_KEY 		= false end -- Launch Snake trap
	if trapKEY_combo == 5 then IceTrap_KEY 			= true  else IceTrap_KEY 		= false end -- Launch Ice trap (ice on ground)
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
	if playerTargetID ~= nil and playerTargetID ~= petTargetID and UnitCanAttack("player", "target") ~= nil then -- 1) check if player has target, 2) check petarget is equal to playertarget, 3) check that player can attack current target
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
		-- Preparation (flasks)
		{ jps.useBagItem("Alchemist's Flask") , not jps.buff("Enhanced Agility") and not jps.buff("Flask of Spring Blossoms") and jps.UseCDs},
		-- Revive pet
		{ "Heart of the Phoenix",			UnitIsDead("pet") ~= nil and HasPetUI() ~= nil }, -- Instant revive pet (only some pets, Ferocity)
		{ "Revive Pet",						((UnitIsDead("pet") ~= nil and HasPetUI() ~= nil) or HasPetUI() == nil) and not jps.Moving },
		-- Heal pet
		{ "Mend Pet", 						jps.hp("pet") < 0.90 and not jps.buff("Mend Pet","pet") },
		-- Set pet to passive (IMPORTANT!)
		{ {"macro","/script PetPassiveMode()"},		petIsPassive == nil }, -- Set pet to passive
		-- Misc
		{ {"macro","/petattack"}, 			petShouldAttackMyTarget },
		{ "Aspect of the Hawk", not jps.buff("Aspect of the Hawk") and not jps.buff("Aspect of the Iron Hawk") },

		-- Misdirect to pet if no "focus" -- for farming, best with Glyph of Misdirection
		{ "Misdirection", 					not jps.buff("Misdirection") and UnitExists("focus") == nil and not IsInGroup() and UnitExists("pet") ~= nil, "pet" }, -- IsInGroup() returns true/false. Works for any party/raid
		{ "Misdirection", 					not jps.buff("Misdirection") and UnitExists("focus") ~= nil, "focus" },
		-- Healthstone
		{ jps.useBagItem("Healthstone") , 	jps.hp("player") < 0.50 }, -- restores 20% of total health
		--
		{ "Silencing Shot", 				jps.shouldKick() and jps.CastTimeLeft("target") < 1.4 }, -- Tier 2 talent
		-- Trinkets and Engineering Gloves
		-- On-use Trinkets.
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and jps.UseCDs },
		-- Requires herbalism
		{ "Lifeblood",			jps.UseCDs },
		-- Use pot
		{ jps.useBagItem("Virmen's Bite"), 	autoUseVirminsBite and jps.UseCDs and (jps.buff("Rapid Fire") or jps.bloodlusting()) },
		-- CDs
		{ "Lifeblood", 						jps.UseCDs }, -- Herbalism
		-- Traps
		{ "Trap Launcher", 					not jps.buff("Trap Launcher") },
		{ "Explosive Trap",					(ExplosiveTrap_KEY 	or allInOneTraps_KEY) and jps.buff("Trap Launcher") },
		{ "Ice Trap",						(IceTrap_KEY 		or allInOneTraps_KEY) and jps.buff("Trap Launcher") },
		{ "Snake Trap",						(SnakeTrap_KEY 		or allInOneTraps_KEY) and jps.buff("Trap Launcher") },
		{ "Freezing Trap",					FreezingTrap_KEY 	and jps.buff("Trap Launcher") },
		-- AoE
		{ "Multi-Shot", 					jps.MultiTarget },
		-- Rotation
		{ "focus fire", 					jps.buffStacks("Frenzy") == 5 and not jps.buff("The Beast Within")},
		{ "serpent sting", 					not jps.myDebuff("serpent sting") },
		{ "fervor", 						focus < 65 and not jps.buff("fervor") },
		{ "stampede", 						jps.UseCDs },
		{ "Rapid Fire", 					jps.UseCDs and not jps.buff("Rapid Fire") },
		{ "bestial wrath", 					focus > 60 and not jps.buff("The Beast Within") and jps.cooldown("Kill Command") == 0 },
		{ "a murder of crows", 				jps.UseCDs and not jps.myDebuff("a murder of crows") },
		{ "kill shot", 						},
		{ "kill command", 					},
		{ "glaive toss", 					},
		{ "lynx rush", 						},
		{ "dire beast", 					focus <= 90 },
		{ "barrage", 						},
		{ "powershot", 						},
		{ "blink strike", 					},
		{ "arcane shot", 					jps.buff("thrill of the hunt") },
		{ "focus fire", 					jps.buffStacks("Frenzy") == 5 and not jps.buff("The Beast Within")},
		{ "cobra shot", 					not jps.buff("The Beast Within") and sps_duration  < 6 },
		{ "arcane shot", 					focus >= 61 or jps.buff("The Beast Within") },
		{ "cobra shot", 					not jps.buff("The Beast Within") },
	}

	jps.petIsDead = false

	spell,target = parseSpellTable(spellTable)
	return spell,target

end	,"BM Hunter PVE 5.3",true,false)


--[[[
@rotation BM Hunter PVE 5.3
@class HUNTER
@spec BEASTMASTERY
@author tropic
@description
Features:[br]
[*] auto misdirect to pet if soloing, misdirect to "focus" e.g. in party/raid[br]
[*] Auto use "Healthstone" at 50% hp
[*] mend pet when hp is less than 90%[br]
[*] interrupt spellcasting with Counter Shot[br]
[*] Use CDs: Blows all cooldowns: trinkets, eng. gloves pots (if boss) etc.
[br]
[br]
Trap Keys:[br]
[*][code]SHIFT:[/code] Explosive Trap[br]
[*][code]ALT:[/code] Freezing Trap[br]
[*][code]CONTROL:[/code] Snake Trap[br]
[*][code]SHIFT-CONTROL:[/code] Ice Trap[br]
]]--


jps.registerStaticTable("HUNTER", "BEASTMASTERY", {
    -- Revive pet
    { hunter.spells.heartOfThePhoenix, 'UnitIsDead("pet") ~= nil and HasPetUI() ~= nil' }, -- Instant revive pet (only some pets, Ferocity)
    { hunter.spells.revivePet, '((UnitIsDead("pet") ~= nil and HasPetUI() ~= nil) or HasPetUI() == nil) and not jps.Moving' },

    -- Heal pet
    { hunter.spells.mendPet, 'jps.hp("pet") < 0.90 and not jps.buff(hunter.spells.mendPet, "pet")' },

    -- Set pet to passive (IMPORTANT!)
    { {"macro", "/script PetPassiveMode()"},    'hunter.petIsPassive() == nil' },
    { {"macro", "/petattack"}, 'hunter.petShouldAttackMyTarget()' },

    -- Aspects
    { hunter.spells.aspectOfTheHawk, 'not jps.buff(hunter.spells.aspectOfTheHawk) and not jps.buff(hunter.spells.aspectOfTheIronHawk)' },

    -- Misdirection
    { hunter.spells.misdirection, 'not jps.buff(hunter.spells.misdirection) and UnitExists("focus") == nil and not IsInGroup() and UnitExists("pet") ~= nil', 'pet' }, -- IsInGroup() returns true/false. Works for any party/raid
    { hunter.spells.misdirection, 'not jps.buff(hunter.spells.misdirection) and UnitExists("focus") ~= nil', 'focus' },

    -- Interrupt
    { hunter.spells.counterShot, 'jps.shouldKick() and jps.CastTimeLeft("target") < 1.4' },

    -- Healthstone
    { jps.useBagItem(5512), 'jps.hp("player") < 0.50' },

    -- Trinkets and stuff
    { jps.useTrinket(0), 'jps.UseCDs' },
    { jps.useTrinket(1), 'jps.UseCDs' },
    { jps.useSynapseSprings() , 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
    { jps.DPSRacial, 'jps.UseCDs' },
    { hunter.spells.lifeblood, 'jps.UseCDs' },

    -- Traps
    { hunter.spells.trapLauncher, 'not jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.explosiveTrap, '(hunter.trapKey() == 1 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.freezingTrap, '(hunter.trapKey() == 2 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.snakeTrap, '(hunter.trapKey() == 4 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.iceTrap, '(hunter.trapKey() == 5 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },

    -- Rotation
    { hunter.spells.multiShot, 'jps.MultiTarget' },
    { hunter.spells.focusFire, 'jps.buffStacks(hunter.buffs.frenzy) == 5 and not jps.buff(hunter.buffs.theBeastWithin)' },
    { hunter.spells.serpentSting, 'jps.myDebuff(hunter.spells.serpentSting, "target")' },
    { hunter.spells.fervor, 'jps.focus() < 65 and not jps.buff(hunter.spells.fervor)' },
    { hunter.spells.stampede, 'jps.UseCDs' },
    { hunter.spells.rapidFire, 'jps.UseCDs and not jps.buff(hunter.spells.rapidFire) and not jps.bloodlusting()' },
    { hunter.spells.bestialWrath, 'jps.focus() > 60 and not jps.buff(hunter.buffs.theBeastWithin) and jps.cooldown(hunter.spells.killCommand) == 0' },
    { hunter.spells.aMurderOfCrows, 'jps.UseCDs and not jps.myDebuff(hunter.spells.aMurderOfCrows)' },
    { hunter.spells.killShot },
    { hunter.spells.killCommand },
    { hunter.spells.glaiveToss },
    { hunter.spells.lynxRush },
    { hunter.spells.direBeast, 'jps.focus() <= 90' },
    { hunter.spells.barrage },
    { hunter.spells.powershot },
    { hunter.spells.blinkStrikes },
    { hunter.spells.arcaneShot, 'jps.buff(hunter.buffs.thrillOfTheHunt)' },
    { hunter.spells.cobraShot, 'not jps.buff(hunter.buffs.theBeastWithin) and jps.myDebuffDuration(hunter.spells.serpentSting) < 6' },
    { hunter.spells.arcaneShot, 'jps.focus() >= 61 or jps.buff(hunter.buffs.theBeastWithin)' },
    { hunter.spells.cobraShot, 'not jps.buff(hunter.buffs.theBeastWithin)' },
}, "BM Hunter PVE 5.4", true, false)

