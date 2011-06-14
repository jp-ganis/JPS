function hunter_bm(self)
   -- by Scribe
   local spell = nil
   local sps_duration = jps.debuff_duration("target","serpent sting")
   local focus = UnitMana("player")
   local pet_focus = UnitMana("pet")
   local pet_frenzy = jps.get_buff_stacks("pet","Frenzy Effect")
   local pet_attacking = IsPetAttackActive()


    -- Normal rotation
   if UnitHealth("target")/UnitHealthMax("target") <= 0.2 and cd("Kill Shot") == 0 then
      spell = "Kill Shot"
   elseif UnitHealth("target")/UnitHealthMax("target") > 0.2 and not ud("target", "Hunter's Mark") then 
      spell = "Hunter's Mark"
   elseif not ud("target", "Serpent Sting") then 
      spell = "Serpent Sting"
   elseif focus > 37 and cd("Kill Command") == 0 and pet_attacking == true then
      -- most dps from here
      spell = "Kill Command"
   elseif focus > 50 and cd("Kill Command") > 2 and cd("Bestial Wrath") > 15 then
      -- Blow any additional focus on arcane shot
      spell = "Arcane Shot"
   elseif cd("Kill Command") > 2 then
      -- make up some more focus
      spell = "Cobra Shot"
   elseif IsSpellInRange("Arcane Shot","target") == 0 then
      spell = "disengage"
   end
   
   -- cooldowns
   if focus < 30 and cd("Rapid Fire") == 0 and cd("Bestial Wrath") > 20 then
      spell = "Rapid Fire"
   elseif focus > 70 and cd("Bestial Wrath") == 0 then
      spell = "Bestial Wrath"
   elseif pet_focus < 60 and focus < 60 and cd("Fervor") == 0 then
      spell = "Fervor"
   elseif pet_frenzy == 5 and not ud("player", "Focus Fire") then
      spell = "Focus Fire"   
   end
   
   -- Beast wrath special
      -- reduced focus cost means we dont want to do any cast times just blast away with arcane and kill command
   if ud("player", "Bestial Wrath") then
      if focus > 18 and cd("Kill Command") == 0 and pet_attacking == true then
         spell = "Kill Command"
      elseif cd("Kill Command") > 2 then
         spell = "Arcane Shot"
      end
   end


   return spell
end
