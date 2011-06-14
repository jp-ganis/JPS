function druid_balance(self)
	local power = UnitPower("player",SPELL_POWER_ECLIPSE)
	local eclipse = GetEclipseDirection()
	if eclipse == "none" then eclipse = "sun" end
	local spell = nil

	local is_duration = jps.debuff_duration("target","insect swarm")
	local mf_duration = jps.debuff_duration("target","moonfire")
	local sf_duration = jps.debuff_duration("target","sunfire")

	local focus_dotting, focus_is, focus_mf, focus_sf
	focus_dotting = false
	if UnitExists("focus") then
		focus_dotting = true
		focus_is = jps.debuff_duration("focus","insect swarm")
		focus_mf = jps.debuff_duration("focus","moonfire")
		focus_sf = jps.debuff_duration("focus","sunfire")
	end

	if cd("Force of Nature") == 0 and jps.UseCDs and ub("player","eclipse (solar)") then
		jps.Cast("force of nature")
		CameraOrSelectOrMoveStart()
		CameraOrSelectOrMoveStop()
		PetAttack("target")
		spell = "force of nature"
	elseif jps.buff_duration("player","shooting stars") < 2 and ub("player","shooting stars") then
		spell = "starsurge"
	elseif UnitMana("player")/UnitManaMax("player") < 0.5 and cd("innervate") == 0 then
		spell = "innervate"
		jps.Target = "player"
	elseif power <= -87 and (jps.LastCast == "wrath" or jps.LastCast == "starsurge") and not ub("player","eclipse (lunar)") then
		if cd("starsurge") == 0 then spell = "starsurge"
		else spell = "starfire" end
	elseif cd("starfall") == 0 then
		spell = "starfall"
	elseif power >= 80 and (jps.LastCast == "starfire" or jps.LastCast == "starsurge") and not ub("player","eclipse (solar)") then
		if cd("starsurge") == 0 then spell = "starsurge"
		else spell = "wrath" end
	elseif power <= -87 and not ub("player","eclipse (lunar)") then
		spell = "wrath"
	elseif power >= 80 and not ub("player","eclipse (solar)") then
		spell = "starfire"
	elseif is_duration < 1.5 then
		spell = "insect swarm"
	elseif sf_duration < 1.5 and mf_duration < 1.5 then
		spell = "moonfire"
	elseif focus_dotting and focus_is < 1.5 then
		spell = "insect swarm"
		jps.Target = "focus"
	elseif focus_dotting and focus_mf < 1.5 and focus_sf < 1.5 then
		spell = "moonfire"
		jps.Target = "focus"
	elseif ub("player","shooting stars") then
		spell = "starsurge"
	elseif jps.Moving then
		spell = "moonfire"
	elseif cd("starsurge") == 0 and not ub("player","shooting stars") then
		spell = "starsurge"
	elseif eclipse == "moon" then
		spell = "wrath"
	elseif eclipse == "sun" then
		spell = "starfire"
	end

	return spell
end
