function hunter_bm_pve()
	jps.Tooltip = ":: BM Hunter (PvE) 5.2 ::"
	---------------
	local spell = spell,target
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
	
	local spellTable =  {}
	spellTable[1] = {
		["ToolTip"] = "BM Hunter PVE 5.3",

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
		{ "Aspect of the Hawk", 			not jps.buff("Aspect of the Hawk") and not jps.buff("Aspect of the Iron Hawk") }, -- Tier 3 talent
		-- Misdirect to pet if no "focus" -- for farming, best with Glyph of Misdirection
		{ "Misdirection", 					not jps.buff("Misdirection") and UnitExists("focus") == nil and not IsInGroup() and UnitExists("pet") ~= nil, "pet" }, -- IsInGroup() returns true/false. Works for any party/raid
		{ "Misdirection", 					not jps.buff("Misdirection") and UnitExists("focus") ~= nil, "focus" },
		-- Healthstone
		{ jps.useBagItem("Healthstone") , 	jps.hp("player") < 0.50 }, -- restores 20% of total health
		-- 
		{ "Silencing Shot", 				jps.shouldKick() and jps.castTimeLeft("target") < 1.4 }, -- Tier 2 talent
		-- Trinkets and Engineering Gloves
		-- On-use Trinkets.
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
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
		{ "serpent sting", 					not jps.mydebuff("serpent sting") },
		{ "fervor", 						focus < 65 and not jps.buff("fervor") },
		{ "bestial wrath", 					focus > 60 and not jps.buff("The Beast Within") },
		{ "Rapid Fire", 					jps.UseCDs and not jps.buff("Rapid Fire") and not jps.buff("the beast within") and not jps.buff("Heroism") and not jps.buff("Time Warp") and not jps.buff("Ancient Hysteria") and not jps.buff("Bloodlust") },
		{ "stampede", 						jps.UseCDs },
		{ "kill shot", 						},
		{ "kill command", 					},
		{ "a murder of crows", 				jps.UseCDs and not jps.mydebuff("a murder of crows") },
		{ "glaive toss", 					},
		{ "lynx rush", 						},
		{ "dire beast", 					focus <= 90 },
		{ "barrage", 						},
		{ "powershot", 						},
		{ "blink strike", 					},
		{ "arcane shot", 					jps.buff("thrill of the hunt") },
		{ "focus fire", 					jps.buffStacks("Frenzy") == 5 and not jps.buff("the beast within")},
		{ "cobra shot", 					sps_duration  < 6 },
		{ "arcane shot", 					focus >= 61 or jps.buff("the beast within") },
		{ "cobra shot", 					},
	}

	jps.petIsDead = false

	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)
	return spell,target

end