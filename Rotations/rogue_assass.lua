function rogue_assass(self)
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuff_duration("target","rupture")
	local snd_duration = jps.buff_duration("player","slice and dice")
	local execute_phase = UnitHealth("target")/UnitHealthMax("target") <= 0.35

	local spell = nil

	if ub("player","stealth") or ub("player","vanish") then
		spell = "garrote"
	elseif not ub("player","overkill") and cd("vanish") == 0 and jps.UseCDs then
		spell = "vanish"
	elseif cd("vendetta") == 0 and jps.UseCDs then
		spell = "vendetta"
	elseif not ub("player","slice and dice") and cp > 0 then
		spell = "slice and dice"
	elseif snd_duration < 2 and cp > 0 then 
		spell = "envenom"
	elseif cp >= 4 and rupture_duration < 2 then
		spell = "rupture"
	elseif execute_phase and cp < 5 then
		spell = "backstab"
	elseif execute_phase and cp == 5 then
		spell = "envenom"
	elseif cp >= 4 then
		spell = "envenom"
	else
		spell = "mutilate"
	end

	if spell = "envenom" and cp == 5 and cd("cold blood") == 0 and jps.UseCDs then
		jps.Cast("cold blood")
	end

	return spell
end
