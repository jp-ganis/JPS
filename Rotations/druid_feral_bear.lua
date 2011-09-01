focusshouldbesaved = false
focusthreatduration = 0
targetshouldbetaunted = false
targetthreatduration = 0

function druid_feral_bear(self)
	local rage = UnitMana("player")
	local lacCount = jps.debuffStacks("target","lacerate")
	local lac_duration = jps.debuffDuration("target","lacerate")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100
	local spell = nil

	--Taunt if not attacking me and if my focus target pulls agro
	if UnitExists("focus") and UnitIsFriend("focus","player") then
		if UnitThreatSituation("focus") ~= nil and UnitThreatSituation("focus") == 3 then
			if focusthreatduration == 0 then
				focusthreatduration = GetTime()
			elseif GetTime()-focusthreatduration > 2 and not focusshouldbesaved then
				focusshouldbesaved = true
				print("focus will be saved")
			end
		elseif focusshouldbesaved or focusthreatduration > 0 then
			focusshouldbesaved = false
			focusthreatduration = 0
		end
	end
   
	if UnitExists("target") and UnitCanAttack("target","player") then
		if UnitThreatSituation("player","target") ~= nil and UnitThreatSituation("player","target") < 3 and not ub("targettarget","bear form") and not ub("targettarget","defensive stance") and not ub("targettarget","blood presence") and not ub("targettarget","righteous fury")  then
			if targetthreatduration == 0 then
				targetthreatduration = GetTime()
			elseif GetTime()-targetthreatduration > 0.5 and not targetshouldbetaunted then
				targetshouldbetaunted = true
				print("Taunting Target")
			end
		elseif targetshouldbetaunted or targetthreatduration > 0 then
			targetshouldbetaunted = false
			targetthreatduration = 0
		end
	end

	-- Interrupt, works equally well with "focus" instead of "target"
	if jps.Interrupts and jps.shouldKick("target") and cd("Skull Bash") == 0 and rage >= 15 then
		return "Skull Bash(Bear Form)"
	elseif jps.Interrupts and jps.shouldKick("target") and cd("Bash") == 0 and rage >= 10 then
		return "Bash"
	end

	-- Check we're in melee range/bear form.
	if not ub("player","bear form") or IsSpellInRange("maul","target") ~= 1 then
		return nil
	end

	-- No GCD
	if cd("maul") == 0 and rage > 40 then
		return "maul"
	end

	-- Defense
	if cd("Barkskin") == 0 and hp < 75 then 
		return "Barkskin"
	elseif cd("Survival Instincts") == 0 and hp < 40 then
		return "Survival Instincts"
	elseif cd("Frenzied Regeneration") == 0 and hp < 25 then
		return "Frenzied Regeneration"
	end

	-- Use CDs
	if cd("Berserk") == 0 and jps.UseCDs then
		return "Berserk"
	end

	-- Taunt the Targets if I should Taunt or save someone
	if targetshouldbetaunted and cd("Growl") == 0 then
		return "Growl"
	elseif focusshouldbesaved and cd("Challenging Roar") == 0 then
		return "Challenging Roar"
	end

	-- Offense, Single-Target
	if not jps.MultiTarget then
		if cd("mangle") == 0 and (rage >= 20 or ub("player","berserk")) then
			spell = "Mangle(Bear Form)"
		elseif not ud("target","Demoralizing Roar") then
			spell = "Demoralizing Roar"
		elseif cd("Thrash") == 0 then
			spell = "Thrash"
		elseif not ud("target","Faerie Fire") then
			spell = "Faerie Fire (Feral)"
		elseif lacCount == 3 then
			spell = "Pulverize"
		elseif lacCount < 3 or lacDuration < 1 then
			spell = "Lacerate"
		elseif cd("Faerie Fire (Feral)") == 0 then
			spell = "Faerie Fire (Feral)"
		end

	-- Multi-Target
	else
		if ub("player","berserk") then
			spell = "mangle(bear form)"
		elseif cd("swipe(bear form)") == 0 then
			spell = "swipe(bear form)"
		elseif cd("thrash") == 0 then
			spell = "thrash"
		elseif not ud("target","demoralizing roar") then
			spell = "Demoralizing Roar"
		elseif lacCount < 3 or lacDuration < 1 then
			spell = "lacerate"
		elseif lacCount == 3 then
			spell = "pulverize"
		elseif cd("Faerie Fire (Feral)") == 0 then
			spell = "Faerie Fire (Feral)"
		end
	end

	-- Return
	return spell

end
