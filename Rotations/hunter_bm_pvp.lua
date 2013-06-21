function hunter_bm_pvp()
-- valve
	local player = jpsName
	local pet = "pet"
	local sps_duration = jps.debuffDuration("serpent sting")
	local focus = UnitMana("player")
	local pet_focus = UnitMana("pet")
	local pet_frenzy = jps.buffStacks("Frenzy Effect","pet")
	local pet_attacking = IsPetAttackActive()
	local stunMe =  jps.StunEvents()
	local hasControl = HasFullControl()

	local pethealth_pct = jps.hp("pet")
	local playerhealth_pct = jps.hp(player)
	local targethealth_pct = jps.hp("target")

	local playerRace = UnitRace("player")
	local targetClass = UnitClass("target")
	local targetSpec = GetSpecialization("target")

	local isSpellHarmful = IsHarmfulSpell("target")

	local EnemyUnit = {}
	for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end

	local rangedTarget = "target"
	if jps.canDPS("target") then
	rangedTarget = "target"
	elseif jps.canDPS("focustarget") then
	rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
	rangedTarget = "targettarget"
	elseif jps.canDPS(EnemyUnit[1]) then
	rangedTarget = EnemyUnit[1]
	end
	
	-- Concussive Shot Targets
	local function shouldCShot()
			if targetClass == "death knight" or targetClass == "hunter" or targetClass == "rogue" or targetClass == "warrior" then return true end
				if targetSpec == "enhancement" or targetSpec == "retribution" then return true end
				if jps.buff("bear form","target") or jps.buff("cat form","target") then return true end
		return false
		end
	
	-- Should Spirit Mend
		local playerhealth_pct = jps.hp(player)
		local focushealth_pct = jps.hp("focus")
		local mousehealth_pct = jps.hp("mouseover")
		local spiritMendTarget = nil
	local function shouldSpiritMend()
			if focushealth_pct < 0.30 and UnitIsFriend("player","focus") then spiritMendTarget = "focus" return true end
			if playerhealth_pct < 0.30 then spiritMendTarget = player return true end
			if mousehealth_pct < 0.30 and UnitIsFriend("player","mouseover") then spiritMendTarget = "mouseover" return true end
			return false
		end
	
	------------------------
	-- SPELL TABLE ---------
	------------------------
	local spellTable = 
	{
	
	-- Should Spirit Mend  
		{ "spirit mend", jps.IsSpellInRange("spirit mend",spiritMendTarget) and shouldSpiritMend() , spiritMendTarget },
	
	-- Remove Snares, Roots, Loss of Control, etc.
		{ "disengage", CheckInteractDistance("target",3)==1 , rangedTarget },
		-- { {"macro","/cast [@player] Master's Call"}, rooted or snared , player },
		{ "will of the forsaken", hasControl == nil and playerRace == "undead" , player },
		-- { jps.useTrinket(1), stunMe and playerRace ~= "human" , player },
		{ "every man for himself", stunMe and playerRace == "human" , player },
	
	-- Kicks etc.
		{ "war stomp", jps.shouldKick() and CheckInteractDistance("target",3)==1 and playerRace == "tauren" },
		{ "arcane torrent", jps.shouldKick() and CheckInteractDistance("target",3)==1 and playerRace == "blood elf" },
		{ "concussive shot", shouldCShot() , rangedTarget },
		{ "intimidation", jps.shouldKick() , rangedTarget },
		{ "scatter shot", jps.shouldKick() , rangedTarget },
		{ "silencing shot", jps.shouldKick() , rangedTarget },
		{ "wyvern sting", jps.shouldKick() , rangedTarget },
		{ "scare beast", jps.buff("bear form","target") or jps.buff("cat form","target") or UnitCreatureType("target") == "beast" , rangedTarget },
	
	-- Heals etc.
		{ "gift of the naaru", playerhealth_pct <= 0.90 and playerRace == "draenei" , player },
		{ "stone form", playerhealth_pct <= 0.50 and playerRace == "dwarf" , player },
		{ "deterrence", playerhealth_pct <= 0.21 , player },
		{ "exhilaration", playerhealth_pct <= 0.70 , player },
		{ "exhilaration", pethealth_pct <= 0.20 , player },
		{ "feign death", playerhealth_pct <= 0.10 , player },
		{ "mend pet", pethealth_pct < 0.30 and CheckInteractDistance("target",3)==0 , player },
		{ "revive pet", HasPetSpells() == nil , player },
	
	-- Cooldowns
		{ "readiness", jps.cooldown("deterrence") > 0 or jps.cooldown("disengage") > 0 , player },
		{ "crouching tiger, hidden chimera", jps.cooldown("deterrence") > 0 or jps.cooldown("disengage") > 0 , player },
	
	-- Debuffs
		{ "hunter's mark", not jps.debuff("hunter's mark") , rangedTarget },
		{ "widow venom", not jps.debuff("widow venom") , rangedTarget },
		{ "binding shot", true , rangedTarget },
		{ "tranquilizing shot", jps.buff("enrage",rangedTarget) , rangedTarget },
	
	-- Buffs
		{ jps.DPSRacial, jps.UseCDs },
		-- { jps.useTrinket(1), },
		{ "trueshot aura", not jps.buff("trueshot aura") , player },
		{ "aspect of the iron hawk", not jps.Moving and not jps.buff("aspect of the iron hawk"), player },
		{ "aspect of the hawk", not jps.Moving and not jps.buff("aspect of the hawk") , player },
		{ "aspect of the fox", jps.Moving and not jps.buff("aspect of the fox") , player },
		{ "fervor", focus < 65 and not jps.buff("fervor") , player },
		{ "bestial wrath", focus > 60 and not jps.buff("the beast within") , player },
		{ "focus fire", pet_frenzy==5 , player },
		{ "rapid fire", not jps.buff("rapid fire") and not jps.buff("the beast within") and not jps.bloodlusting() , player },
	
	-- Traps
		-- { "explosive trap",
		-- { "freezing trap",
		-- { "ice trap",
		-- { "snake trap",
	
	-- Pet Attacks
		-- Finishers
		{ "stampede", IsShiftKeyDown() ~= nil , rangedTarget },
		{ "beast cleave", IsShiftKeyDown() ~= nil , rangedTarget },
	
	-- Base Attacks
		{ "lynx rush", true , rangedTarget },
		{ "dire beast", true , rangedTarget},
		{ "blink strike", true , rangedTarget },
		{ "kill command", true , rangedTarget },
	
	-- AoE
		{ "multi-shot", jps.MultiTarget , rangedTarget },
		{ "powershot", true , rangedTarget },
		{ "barrage", true , rangedTarget },
	
	-- Attacks
	-- Finishers
		{ "kill shot", targethealth_pct <= 0.20 , rangedTarget },
		{ "a murder of crows", targethealth_pct <= 0.20 , rangedTarget },
	
	-- Base Attacks
		{ "steady shot", jps.Moving , rangedTarget },
		{ "serpent sting", not jps.debuff("serpent sting") , rangedTarget },
		{ "glaive toss", true , rangedTarget },
		{ "arcane shot", jps.buff("thrill of the hunt") , player },
		{ "cobra shot", focus <= 45 , rangedTarget },
		{ "arcane shot", focus >= 46 , rangedTarget },
	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end

-- Put DPS trinket in top trinket slot and if not human, put PvP trinket in bottom slot.