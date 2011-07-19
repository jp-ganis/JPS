function hunter_bm(self)
	-- by Scribe (v1.32b)
	local spell = nil
	local sps_duration = jps.debuff_duration("target","serpent sting")
	local focus = UnitMana("player")
	local pet_focus = UnitMana("pet")
	local pet_frenzy = jps.get_buff_stacks("pet","Frenzy Effect")
	local pet_attacking = IsPetAttackActive()
	local target_health_percent = UnitHealth("target")/UnitHealthMax("target") * 100
	local pet_health_percent = UnitHealth("pet")/UnitHealthMax("pet") * 100
	
	-- this is here to stop blowing wrath on nearly dead mobs with low health
	if UnitHealthMax("target") > 1000000 or target_health_percent > 25 then 
		local green_light_wrath = true
	end

    -- Normal rotation
	if jps.PetHeal and not ub("pet","Mend Pet") and target_health_percent <= 90 then
	      spell = "Mend Pet"
	elseif target_health_percent <= 20 and cd("Kill Shot") == 0 then
		spell = "Kill Shot"
	elseif target_health_percent > 30 and not ud("target", "Hunter's Mark") then 
		spell = "Hunter's Mark"
	elseif not UnitDebuff("target", "Serpent Sting",nil,"PLAYER") then 
		spell = "Serpent Sting"
	elseif focus > 36 and cd("Kill Command") == 0 and pet_attacking == true then
		-- most dps from here
		spell = "Kill Command"
	elseif focus > 59 and jps.get_cooldown("Kill Command") > 2 and jps.get_cooldown("Bestial Wrath") > 8 then
		-- Blow any additional focus on arcane shot
		spell = "Arcane Shot"
	elseif IsSpellInRange("Arcane Shot","target") == 0 then
		spell = "disengage"
	elseif jps.get_cooldown("Kill Command") > 0.5 then
		-- make up some more focus
		spell = "Cobra Shot"
	end
	
	-- cooldowns
	if focus < 30 and cd("Rapid Fire") == 0 and jps.get_cooldown("Bestial Wrath") > 20 and jps.UseCDs then
		spell = "Rapid Fire"
	elseif focus > 60 and cd("Bestial Wrath") == 0 then
		spell = "Bestial Wrath"
	elseif pet_focus < 60 and focus < 60 and cd("Fervor") == 0 and jps.UseCDs then
		spell = "Fervor"
	elseif pet_frenzy == 5 and not ub("player", "Focus Fire") then
		spell = "Focus Fire"	
	end
	
	-- Beast wrath special
	-- reduced focus cost means we dont want to do any cast times just blast away with arcane and kill command
	if ub("player", "The Beast Within") then

		if jps.get_cooldown("Kill Command") < 0.1 then
			spell = "Kill Command"
		else
			spell = "Arcane Shot"
		end
	end
	
	-- Control key for AOE spam
	if IsControlKeyDown() then
		spell = "Multi-Shot"
	end

	return spell
end
