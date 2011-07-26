function mage_frost(self)
	local spell = nil

	if cd("frostfire orb") == 0 then
		spell = "frostfire orb"
	elseif cd("deep freeze") == 0 and ub("player","fingers of frost") then
		spell = "deep freeze"
	elseif ub("player","fingers of frost") and ub("player","brain freeze") then
		spell = "frostfire bolt"
	elseif jps.get_pet_cooldown("freeze") == 0 then
		CastPetAction("freeze")
		CameraOrSelectOrMoveStart()
		CameraOrSelectOrMoveStop()
	else
		spell = "frostbolt"
	end
	
	return spell
end
