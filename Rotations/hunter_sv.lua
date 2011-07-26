function hunter_sv(self)
   -- Survival Hunter - stolen a bunch from MM hunter!
	 -- Ty to Chiffon/Scribe :)
   ------------------------------------------
   local focus = UnitPower("player")
	 local sting_duration = jps.debuff_duration("target","serpent sting")

	-- Interupting, Borrowed directly from feral cat
	if jps.Interrupts and jps.should_kick("target") and cd("Silencing Shot") == 0 then
		print("Silencing Target")
		return "Silencing Shot"
	end

   if jps.PetHeal and not ub("pet","Mend Pet") and UnitHealth("pet")/UnitHealthMax("pet") <= 0.9 then
      spell = "Mend Pet"
   elseif GetUnitSpeed("player") == 0 and not ub("player", "Aspect of the Hawk") then
      spell = "Aspect of the Hawk"
   elseif jps.MultiTarget and focus > 40 then
      spell = "Multi-Shot"
	 elseif sting_duration < 2 then
	 		spell = "Serpent Sting"
	 elseif cd("explosive shot") == 0 and not ud("target","explosive shot") then
	 		spell = "explosive shot"
	 elseif cd("black arrow") == 0 then
	 		spell = "black arrow"
   elseif UnitHealth("target")/UnitHealthMax("target") <= 0.2 and cd("Kill Shot") == 0 then
      spell = "Kill Shot"
	 elseif focus > 85 then
	 		spell = "Arcane Shot"
   elseif jps.UseCDs and cd("Rapid Fire") == 0 and not ub("player","rapid fire") then
      spell = "Rapid Fire"
   elseif jps.UseCDs and jps.Lifeblood and cd("Lifeblood") == 0 and not ub("player","Lifeblood") then
	  spell = "Lifeblood"
   elseif GetUnitSpeed("player") > 0 and not ub("player", "Aspect of the Fox") then
      spell = "Aspect of the Fox"
   else
      spell = "Cobra Shot" 
   end

   return spell
end
