function paladin_ret(self)
	-- Rewrite for 4.2 by Gocargo.
	local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
	local targetHealthPercent = UnitHealth("target")/UnitHealthMax("target") * 100
	local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100
	local hPower = UnitPower("player","9")
	local race = UnitRace("player")
	local inqDuration = jps.buffDuration("Inquisition")
	local spell = nil
   
	-- Interrupt, works equally well with "focus" instead of "target"
	if jps.Interrupts and jps.shouldKick("target") and cd("Rebuke") == 0 and myManaPercent >= 25 then
		return "Rebuke"
	end

        -- Blood Elf Arcane Torrent
        if jps.Interrupts and jps.shouldKick("target") and cd("Arcane Torrent") == 0 and race == "Blood Elf" then
		return "Arcane Torrent"
	end
 
     	-- Check for Seal and Mana levels
        if not ub("player","Seal of Truth") then
                return "Seal of Truth"
        end

        if myManaPercent < 35 and cd("Divine Plea") == 0 then
                spell = "Divine Plea"
        end

        -- About to Die ?
   	if myHealthPercent < 20 and hPower == 3 then 
		spell = "Word of Glory"
        end

	-- Inquisition logic (Cannot get timers working right, commented out for now)
	if not ub("player", "Inquisition") and ub("player", "Divine Purpose") then 
		spell = "Inquisition"
	elseif ub("player", "Divine Purpose") and inqDuration < 2 then 
		spell = "Inquisition"	
	elseif not ub("player", "Inquisition") and hPower == 3 then 
		spell = "Inquisition" 
		      
	-- Zealotry logic for CD usage
	elseif jps.UseCDs and ub("player", "Divine Purpose") and cd("Zealotry") == 0 then 
		spell = "Zealotry"
	elseif jps.UseCDs and hPower == 3 and cd("Zealotry") == 0 then 
		spell = "Zealotry"
        elseif jps.UseCDs and cd("Avenging Wrath") == 0 then
                spell = "Avenging Wrath"
        
	-- Crusader Strike / Divine Storm based on MultiTarget
	elseif cd("Crusader Strike") == 0 and not jps.MultiTarget then 
		spell = "Crusader Strike"
        elseif cd("Divine Storm") == 0 and jps.MultiTarget then 
		spell = "Divine Storm"

	-- Hammer during execute mode or Avenging wrath
	elseif targetHealthPercent < 20 and cd("Hammer of Wrath") == 0 then 
		spell = "Hammer of Wrath"
	elseif ub("player", "Avenging Wrath") and cd("Hammer of Wrath") == 0 then 
		spell = "Hammer of Wrath"

	--EXORCISM LOGIC--
   	elseif ub("player", "The Art of War") and cd("Exorcism")==0 then 
		spell = "Exorcism"

        --TEMPLAR'S VERDICT LOGIC--
	elseif ub("player", "Divine Purpose") then 
		spell = "Templar's Verdict"
	elseif hPower == 3 then 
		spell = "Templar's Verdict"

	--JUDGEMENT LOGIC--
  	elseif cd("Judgement") == 0 then 
		spell = "Judgement"

   	--HOLY WRATH--
	elseif cd("Holy Wrath") == 0 then 
		spell = "Holy Wrath"

   	--TIME TO GO OOM--
	elseif cd("Consecration") == 0 and jps.MultiTarget then 
		spell = "Consecration"

	end
        return spell

end
