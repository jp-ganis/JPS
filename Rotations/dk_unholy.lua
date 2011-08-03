function dk_unholy(self)

	-- Version 0.1 by kyletxag.
	local ius = IsUsableSpell
	local spell = nil
	local power = UnitPower("player",6)
	local HP = UnitHealth("player")/UnitHealthMax("player")
	local FF_duration = jps.debuff_duration("target","Frost Fever")
	local BP_duration = jps.debuff_duration("target","Blood Plague")
	local SI_stacks = jps.get_buff_stacks("pet","Shadow Infusion")
	local DT_pet = ub("pet", "Dark Transformation")

	--Interrupts--
	if UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("mind freeze") == 0 and IsSpellInRange("mind freeze", "target") == 1 and power >= 20 then
	         SpellStopCasting() spell = "mind freeze"
	elseif UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("strangulate") == 0 and IsSpellInRange("strangulate", "target") == 1 then
	         SpellStopCasting() spell = "strangulate"

	--Cooldowns--
	elseif ius("Unholy Frenzy") and cd("Unholy Frenzy") == 0 and jps.UseCDs then
	     spell = "Unholy Frenzy"   
	elseif ius("Summon Gargoyle") and cd("Summon Gargoyle") == 0 and jps.UseCDs then 
	     spell = "Summon Gargoyle"

	--Buffs--
	  elseif not ub("player","Horn of Winter") and cd("Horn of Winter") == 0 then
	     spell = "Horn of Winter" 
	  elseif HP < 0.2 and ius("Icebound Fortitude") then
	     spell = "Icebound Fortitude"

	--Multitarget--
	  elseif UnitExists("target") and UnitCanAttack("player","target") and jps.MultiTarget then
	     if ius("Dark Transformation") then
	        spell = "Dark Transformation"
        elseif FF_duration < 2 and BP_duration < 2 and cd("Outbreak") == 0 then
            spell = "Outbreak"
        elseif BP_duration < 2 then
            spell = "Plague Strike"
        elseif FF_duration < 2 then
            spell = "Icy Touch"
	     elseif ius("Pestilence") then
	        spell = "Pestilence"
	     elseif cd("Death and Decay") == 0 then
	        spell = "Death and Decay"
	        CameraOrSelectOrMoveStart()
	        CameraOrSelectOrMoveStop()
	     elseif ius("Blood Boil") then
	        spell = "Blood Boil"
	     elseif ius("Scourge Strike") then
	        spell = "Scourge Strike"
	     elseif ius("Festering Strike") then
	        spell = "Festering Strike"
	     elseif power >= 40 and ius("Death Coil") then
	        spell = "Death Coil"
	     elseif cd("Horn of Winter") == 0 then
	            spell= "Horn of Winter"
	     end

	--Single Target--
	  elseif UnitExists("target") and UnitCanAttack("player","target") and (not jps.MultiTarget) then -- for boss later (and UnitLevel("target") < 87)
		if not IsPetAttackActive() then
			PetAttack()
		elseif ius("Dark Transformation") then
	        spell = "Dark Transformation"
		elseif cd("Summon Gargoyle") == 0 and ius("Summon Gargoyle") and DT_pet and power >= 60 and jps.UseCDs then
	        spell = "Summon Gargoyle"
        elseif FF_duration < 2 and BP_duration < 2 and cd("Outbreak") == 0 then
            spell = "Outbreak"
        elseif BP_duration < 2 then
            spell = "Plague Strike"
        elseif FF_duration < 2 then
            spell = "Icy Touch"
	    elseif cd("Death and Decay") == 0 and ius("Death and Decay") then
	        spell = "Death and Decay"
	        CameraOrSelectOrMoveStart()
	        CameraOrSelectOrMoveStop()
        elseif ius("Scourge Strike") and SI_stacks < 5 then
            spell = "Scourge Strike"
        elseif ius("Festering Strike") then
            spell = "Festering Strike"
        elseif power >= 40 and not DT_pet then
			spell= "Death Coil"
        elseif cd("Blood Tap") == 0 then 
            spell= "Blood Tap"
        elseif cd("Horn of Winter") == 0 then
            spell= "Horn of Winter"
		end
	  end
	return spell
	end