function hunter_sv(self)
   --latitude
   local spell = nil
   local sps_duration = jps.debuffDuration("serpent sting")
   local focus = UnitMana("player")
   local pet_focus = UnitMana("pet")
   

   local spellTable = 
   {
      { {"macro","/petattack"}, not IsPetAttackActive() },
      
      { jps.DPSRacial, jps.UseCDs },
      { "serpent sting", sps_duration == 0 },
      { "black arrow", jps.cooldown("black arrow") == 0},
      { "explosive shot", jps.buff("lock and load") and jps.cooldown("explosive shot") == 0 },
      { "explosive shot", jps.debuffDuration("explosive shot") < .3 },
      { "rapid fire", jps.cooldown("rapid fire") == 0 },
      { "kill shot", jps.hp("target") <= 0.20 },
      { "arcane shot", focus >= 55 and not jps.buff("lock and load") },
      { {"macro","/cast cobra shot"}, jps.cooldown("cobra shot") == 0 },
      
   }

   return parseSpellTable(spellTable)
end