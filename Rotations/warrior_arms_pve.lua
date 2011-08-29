function warrior_arms_pve(self)
	local spell = nil
	
	if not ud("target","rend") then
		spell = "rend"
	elseif cd("colossus smash") == 0 then
		spell = "colossus smash"
	elseif cd("mortal strike") == 0 then
		spell = "mortal strike"
	elseif cd("overpower") == 0 then
		spell = "overpower"
	elseif UnitPower("player") > 70 then
		spell = "heroic strike"
	else
		spell = "slam"
	end

	return spell
end
