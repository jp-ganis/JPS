function hunter_bm(self)
   -- hsershen
   local spell = nil
   local sps_duration = jps.debuffDuration("serpent sting")
   local focus = UnitMana("player")
   local pet_focus = UnitMana("pet")
   local pet_frenzy = jps.buffStacks("Frenzy Effect","pet")
   local pet_attacking = IsPetAttackActive()

   local spellTable = 
   {
      { {"macro","/petattack"}, not IsPetAttackActive() },
      { jps.DPSRacial, jps.UseCDs },
      { "cobra shot", focus < 20 },
      { "bestial wrath", focus > 60 },
      { "serpent sting", not jps.debuff("serpent sting") },
      { "kill shot" },
      { "rapid fire", not jps.buff("bloodlust") and not jps.buff("the beast within") and not jps.buff("heroism") and not jps.buff("time warp") },
      { "kill command", },
      { "dire beast", },
      { "lynx rush", },
      { "focus fire", pet_frenzy==5 and not jps.buff("the beast within")},
      { "arcane shot", focus >= 59 or jps.buff("the beast within") },
      { "cobra shot", focus < 20 },
   }

   return parseSpellTable(spellTable)
end
