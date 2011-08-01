function paladin_protadin(self)
	-- Complete re-write for 4.2 by GoCarGo.
        local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
        local targetHealthPercent = UnitHealth("target")/UnitHealthMax("target") * 100
        local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100
        local hPower = UnitPower("player","9")
        local spell = nil

	-- Interrupt, works equally well with "focus" instead of "target"
	if jps.Interrupts and jps.should_kick("target") and cd("Rebuke") == 0 and myManaPercent >= 35 then
		return "Rebuke"
	end

        --Check for Righteous Fury and Seal
        if not ub("player","Righteous Fury") then
                return "Righteous Fury"
        end
        
        if not ub("player","Seal of Truth") then
                return "Seal of Truth"
        end

	-- Check we're in melee range, if not pull with AS.
	if IsSpellInRange("Crusader Strike","target") ~=1 then
		return "Avenger's Shield"
	end

	-- Defense
	if cd("Holy Shield") == 0 and myHealthPercent < 75 then 
		return "Holy Shield"
        elseif cd("Divine Protection") == 0 and myHealthPercent < 52 then
		return "Divine Protection"
	elseif cd("Guardian of Ancient Kings") == 0 and myHealthPercent < 47 then
		return "Guardian of Ancient Kings"
	elseif cd("Ardent Defender") == 0 and myHealthPercent < 33 then
		return "Ardent Defender"
        elseif cd("Lay on Hands") == 0 and myHealthPercent < 23 then
		return "Lay on Hands"
	end

	-- Offense, Single-Target
	if not jps.MultiTarget then
		if cd("Avenging Wrath") == 0 and UnitHealthMax("target") > 100000 and not ub("player","Avenging Wrath") then
			spell = "Avenging Wrath"
                elseif cd("Shield of the Righteous") == 0 and hPower == 3 then
			spell = "Shield of the Righteous"
		elseif cd("Crusader Strike") == 0 then
			spell = "Crusader Strike"
		elseif cd("Avenger's Shield") == 0 then
			spell = "Avenger's Shield"
		elseif cd("Hammer of Wrath") == 0 and targetHealthPercent < 20 then
			spell = "Hammer of Wrath"
		elseif cd("Judgement") == 0 then
			spell = "Judgement"
		end

	-- Multi-Target
	else
		if cd("Inquisition") == 0 and hPower == 3 and not ub("player","Inquisition") then
			spell = "Inquisition"
		elseif cd("Hammer of the Righteous") == 0 then
			spell = "Hammer of the Righteous"
		elseif cd("Avenger's Shield") == 0 then
			spell = "Avenger's Shield"
                elseif cd("Consecration") == 0 and myManaPercent > 35 then
			spell = "Consecration"
                elseif cd("Holy Wrath") == 0 then
			spell = "Holy Wrath"
		elseif cd("Hammer of Wrath") == 0 and targetHealthPercent < 20 then
			spell = "Hammer of Wrath"
		elseif cd("Judgement") == 0 then
			spell = "Judgement"
                end
	end

	-- Return
	return spell

end