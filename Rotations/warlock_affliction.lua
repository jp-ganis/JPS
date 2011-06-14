function warlock_affliction(self)
	local mana = UnitMana("player")/UnitManaMax("player")
	local shards = UnitPower("player",7)
	local spell = nil

	local bod_duration = jps.debuff_duration("target","bane of doom")
	local cpn_duration = jps.debuff_duration("target","corruption")
	local ua_duration = jps.debuff_duration("target","unstable affliction")

	-- focus dotting
	local focus_dotting, focus_corruption, focus_ua, focus_bane
	if UnitExists("focus") then
		focus_dotting = true
		focus_corruption = jps.debuff_duration("focus","corruption")
		focus_ua = jps.debuff_duration("focus","unstable affliction")
		focus_bane = jps.debuff_duration("focus","bane of agony")
	end

	if not ud("target","curse of the elements") then
		spell = "curse of the elements"
	-- Opening
	elseif jps.Opening and not jps.Casting then
		if not ud("target","shadow and flame") and jps.LastCast ~= "shadow bolt" then
			spell = "shadow bolt"
		elseif cd("haunt") == 0 then
			spell = "haunt"
		elseif cd("demon soul") == 0 then
			spell = "demon soul"
		elseif not ud("target","bane of doom") then
			spell = "bane of doom"
		elseif not ud("target","corruption") then
			spell = "corruption"
		elseif not ud("target","unstable affliction") and jps.LastCast ~= "unstable affliction" then
			spell = "unstable affliction"
		else
			spell = "drain life"
			jps.Opening = false
		end
	elseif not jps.Casting then
	-- Standard
		if cd("haunt") == 0 and not jps.Moving then
			spell = "haunt"
		elseif cd("demon soul") == 0 then
			spell = "demon soul"
		elseif bod_duration < 15 then
			spell = "bane of doom"
		elseif not ud("target","shadow and flame") and jps.LastCast ~= "shadow bolt" then
			spell = "shadow bolt"
		elseif ub("player","shadow trance") then
			spell = "shadow bolt"
		elseif cpn_duration < 1.5 then
			spell = "corruption"
		elseif jps.Moving then
			spell = "fel flame"
		elseif ua_duration < 1.5 and jps.LastCast ~= "unstable affliction" then
			spell = "unstable affliction"
		elseif UnitHealth("target")/UnitHealthMax("target") < 0.25 then
			spell = "drain soul"
		elseif focus_dotting and focus_corruption < 1.5 then
			spell = "corruption"
			jps.Target = "focus"
		elseif focus_dotting and focus_bane < 1.5 then
			spell = "bane of agony"
			jps.Target = "focus"
		elseif focus_dotting and focus_ua < 1.5 then
			spell = "unstable affliction"
			jps.Target = "focus"
		elseif cd("Shadowflame") == 0 and IsShiftKeyDown() then
			spell = "shadowflame"
		elseif mana < 0.5 then
			spell = "life tap"
		else
			spell = "drain life"
		end
	end
	return spell
end   
