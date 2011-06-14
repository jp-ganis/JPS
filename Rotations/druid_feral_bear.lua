function druid_feral_bear(self)
	local rage = UnitMana("player")
	local lacCount = jps.get_debuff_stacks("target","lacerate")
	local lac_duration = jps.debuff_duration("target","lacerate")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100
	local spell = nil

	-- Interrupt, works equally well with "focus" instead of "target"
	if jps.Interrupts and jps.should_kick("target") and cd("skull bash") == 0 and rage >= 15 then
		return "skull bash(bear form)"
	end

	-- Check we're in melee range/bear form.
	if not ub("player","bear form") or IsSpellInRange("maul","target") ~= 1 then
		return nil
	end

	-- No GCD
	if cd("maul") == 0 and rage > 40 then
		return "maul"
	end

	-- Defence
	if cd("Barkskin") == 0 and hp < 75 then 
		return "Barkskin"
	elseif cd("Survival Instincts") == 0 and hp < 50 then
		return "Survival Instincts"
	elseif cd("Frenzied Regeneration") == 0 and hp < 30 then
		return "Frenzied Regeneration"
	end

	-- Offence, Single-Target
	if not jps.MultiTarget then
		if cd("mangle") == 0 and (rage >= 20 or ub("player","berserk")) then
			spell = "mangle(bear form)"
		elseif not ud("target","Faerie Fire") then
			spell = "faerie fire (feral)"
		elseif lacCount < 3 or lacDuration < 1 then
			spell = "lacerate"
		elseif lacCount == 3 and false then
			spell = "pulverize"
		elseif cd("thrash") == 0 then
			spell = "thrash"
		elseif cd("Faerie Fire (Feral)") == 0 then
			spell = "Faerie Fire (Feral)"
		elseif not ud("target","demoralizing roar") then
			spell = "Demoralizing Roar"
		end

	-- Multi-Target
	else
		if ub("player","berserk") then
			spell = "mangle(bear form)"
		elseif cd("swipe(bear form)") == 0 then
			spell = "swipe(bear form)"
		elseif cd("thrash") == 0 then
			spell = "thrash"
		elseif lacCount < 3 or lacDuration < 1 then
			spell = "lacerate"
		elseif lacCount == 3 and false then
			spell = "pulverize"
		elseif cd("Faerie Fire (Feral)") == 0 then
			spell = "Faerie Fire (Feral)"
		elseif not ud("target","demoralizing roar") then
			spell = "Demoralizing Roar"
		end
	end

	-- Return
	return spell

end
