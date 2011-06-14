function paladin_ret(self)
	-- Credit (and thanks!) to Gocargo.
	local hpower = UnitPower("player",SPELL_POWER_HOLY_POWER)
	local zea_cd = jps.get_cooldown("zealotry")
	local inq_duration = jps.buff_duration("player","inquisition")
	local execute_phase = UnitHealth("target")/UnitHealthMax("target") <= 0.20
	local spell = nil
   
	--ACTION GOES DOWN HERE--

	--INTERRUPT LOGIC--
   	if UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("Rebuke") == 0 and IsSpellInRange("Rebuke", "target") == 1 then 
		SpellStopCasting() spell = "Rebuke"
	elseif UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("Rebuke") == 0 and IsSpellInRange("Rebuke", "target") == 1 then 
		SpellStopCasting() spell = "Arcane Torrent"

	--HEAL ME BRO--
   	elseif UnitHealth("player")/UnitHealthMax("player") < 0.15 and hpower == 3 then 
		spell = "Word of Glory"

	-- INQUISITION LOGIC--
	elseif not ub("player", "Inquisition") and ub("player", "Divine Purpose") then 
		spell = "Inquisition"
	elseif ub("player", "Divine Purpose") and inq_duration < 2 then 
		spell = "Inquisition"	
	elseif not ub("player", "Inquisition") and hpower > 2 then 
		spell = "Inquisition" 
	elseif hpower > 0 and inq_duration < 2 then 
		spell = "Inquisition"  	
	
	--ZEALOTRY LOGIC--
	elseif ub("player", "Divine Purpose") and cd("Zealotry") == 0 then 
		spell = "Zealotry"
	elseif hpower == 3 and cd("Zealotry") == 0 then 
		spell = "Zealotry"

	--CS LOGIC--
	elseif cd("crusader strike") == 0 then 
		spell = "crusader strike"

	--TEMPLAR'S VERDICT LOGIC--
	elseif ub("player", "Divine Purpose") then 
		spell = "Templar's Verdict"
	elseif hpower == 3 then 
		spell = "Templar's Verdict"
   	
	--HAMMER LOGIC--
	elseif execute_phase and cd("Hammer of Wrath") == 0 then 
		spell = "Hammer of Wrath"
	elseif ub("player", "Avenging Wrath") and cd("Hammer of Wrath") == 0 then 
		spell = "hammer of wrath"

	--EXORCISM LOGIC--
   	elseif ub("player", "the art of war") and cd("Exorcism")==0 then 
		spell = "exorcism"

	--JUDGEMENT LOGIC--
  	elseif cd("Judgement") == 0 then 
		spell = "Judgement"

   	--HOLY WRATH--
	elseif cd("Holy wrath") == 0 then 
		spell = "Holy Wrath"

   	--TIME TO GO OOM--
	elseif cd("Consecration") == 0 then 
		spell = "Consecration"

	end

 return spell
end
