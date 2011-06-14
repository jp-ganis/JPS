function druid_feral_cat(self)
	local energy = UnitMana("player")
	local cp = GetComboPoints("player")
	local tf_cd = jps.get_cooldown("tiger's fury")
	local rip_duration = jps.debuff_duration("target","rip")
	local rake_duration = jps.debuff_duration("target","rake")
	local sr_duration = jps.buff_duration("player","savage roar")
	local mangle_duration = jps.debuff_duration("target","mangle")
	local execute_phase = UnitHealth("target")/UnitHealthMax("target") <= 0.25
	local spell = nil
	local target_spell, _, _, _, _, endTime, _, _, interrupt = UnitCastingInfo("target")
	local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo("target")
	if jps.Interrupts and jps.should_kick("target") and cd("skull bash") == 0 and energy >= 25 then
			return "skull bash(cat form)"
	end

	if not ub("player","cat form") or IsSpellInRange("shred","target") ~= 1 then
		return nil
	end

	local pantherDuration = jps.buff_duration("player","strength of the panther")
	local pantherCount = jps.get_buff_stacks("player","strength of the panther")

	if jps.MultiTarget then
		if cd("tiger's fury") == 0 and energy <= 26 then
			spell = "tiger's fury"
		elseif cd("tiger's fury") == 0 and energy <= 35 and not ub("player","clearcasting") then
			spell = "tiger's fury"
		elseif cd("berserk") == 0 and tf_cd > 15 and jps.UseCDs then
			spell = "berserk"
		elseif jps.Panther and (pantherCount < 3 or panther_duration < 4) then
			spell = "mangle(cat form)"
		else
			spell = "swipe"
		end
	else
		if jps.Opening then
			if not ud("target","faerie fire") and cd("faerie fire (feral)") == 0 then
				spell = "faerie fire (feral)"
			elseif mangle_duration < 1 and not ud("target","trauma") then
				spell = "mangle(cat form)"
			elseif cp > 0 and sr_duration < 1 then
				spell = "savage roar"
			elseif energy >= 66 and cp < 5 then
				spell = "shred"
			elseif cd("tiger's fury") == 0 then
				spell = "tiger's fury"
			elseif tf_cd > 20 and energy >= 70 and cd("berserk") == 0 and jps.UseCDs then
				spell = "berserk"
			elseif not ud("target","rake") then
				spell = "rake"
			elseif ub("player","stampede") and cp < 5 then
				spell = "ravage"
			elseif cp > 4 then
				spell = "rip"
			elseif ud("target","rip") then
				jps.Opening = false
				print "Finished opening."
				spell = "shred"
			else
				spell = "shred"
			end
		-- END OF OPENER --
		else
			if cd("tiger's fury") == 0 and energy <= 26 then
				spell = "tiger's fury"
			elseif cd("tiger's fury") == 0 and energy <= 35 and not ub("player","clearcasting") then
				spell = "tiger's fury"
			elseif jps.Panther and (pantherCount < 3 or pantherDuration < 4) then
				spell = "mangle(cat form)"
			elseif ub("player","stampede") and (jps.buff_duration("player","stampede") <= 2 or ub("player","primal madness")) then
				spell = "ravage"
			elseif jps.debuff_duration("target","faerie fire") < 1 and cd("faerie fire (feral)") == 0 then
				spell = "faerie fire (feral)"
			elseif mangle_duration < 1 and not ud("target","trauma") and not ud("target","hemorrhage") then
				spell = "mangle(cat form)"
			elseif cd("berserk") == 0 and tf_cd > 15 and energy > 80 and jps.UseCDs then
				spell = "berserk"
			elseif execute_phase and (cp == 5 or rip_duration < 2) and ud("target","rip") then
				spell = "ferocious bite"
			elseif cp == 5 and rip_duration < 2 then
				spell = "rip"
			elseif ub("player","tiger's fury") and rake_duration < 8.5 then
				spell = "rake"
			elseif rake_duration < 3 then
				spell = "rake"
			elseif ub("player","clearcasting") then
				spell = "shred"
			--elseif cp > 4 and rip_duration >= 6 then
			--	spell = "ferocious bite"
			elseif cp > 4 and rip_duration < 12 and abs(sr_duration-rip_duration) <= 3 then
				spell = "savage roar"
			elseif cp > 0 and sr_duration < 2 and rip_duration >= 6 then
				spell = "savage roar"
			elseif ub("player","stampede") and cp < 5 then
				spell = "ravage"
			elseif ub("player","berserk") or energy > 80 or tf_cd < 2 then
				spell = "shred"
			end
		end
	end

	return spell
end
