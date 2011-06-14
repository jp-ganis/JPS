function hunter_mm(self)
	-- Credit (and thanks!) to scottland3.
   local spell = nil
   local sps_duration = jps.debuff_duration("target","serpent sting")
   local iss_duration = jps.buff_duration("player","improved steady shot")
   local raf_duration = jps.buff_duration("player","rapid fire")

   if UnitHealth("target")/UnitHealthMax("target") <= 0.2 and cd("Kill Shot") == 0 then
      spell = "Kill Shot"
   elseif ub("player", "Fire!") then 
      spell = "Aimed Shot"
   elseif UnitHealth("target")/UnitHealthMax("target") > 0.2 and not ud("target", "Hunter's Mark") then 
      spell = "Hunter's Mark"
   elseif raf_duration < 1.8 and ub("player","rapid fire") and cd("readiness") == 0 then
      spell = "readiness"
   elseif IsSpellInRange("Arcane Shot","target") == 0 then
      spell = "disengage"
   elseif sps_duration < 1.8 then 
      spell = "Serpent Sting"
   elseif cd("Chimera Shot") == 0 and sps_duration < 3 then 
      spell = "Chimera Shot"
   elseif cd("Chimera Shot") == 0 and sps_duration > 12 then
      spell = "Chimera Shot"
   elseif cd("rapid fire") == 0 and UnitHealth("target") > 100000 then
      spell = "rapid fire"
   elseif iss_duration < 3 then
      spell = "steady shot"
   elseif UnitPower("player") > 85 then 
      spell = "arcane shot" 
   elseif UnitPower("player") >= 80 and ub("player","rapid fire") then 
      spell = "aimed shot"
   else 
      spell = "Steady Shot" 
   end

	return spell
end
