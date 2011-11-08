function mage_frost(self)
	local spell = nil

	if jps.cd("flame orb") == 0 then
		spell = "flame orb"
	elseif jps.cd("deep freeze") == 0 and ub("player","fingers of frost") then
		spell = "deep freeze"
	elseif ub("player","fingers of frost") and ub("player","brain freeze") then
		spell = "frostfire bolt"
	elseif jps.petCooldown("5") == 0 then
		CastPetAction("5")
		CameraOrSelectOrMoveStart()
		CameraOrSelectOrMoveStop()
	else
		spell = "frostbolt"
	end

	return parseSpellTable(spelltable)
	
	--return spell
end
