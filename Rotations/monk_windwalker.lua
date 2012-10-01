function monk_windwalker(self)

   local energy = UnitMana("player")
   local cp = UnitPower("Player", 12)
   local tpDuration = jps.buffDuration("Tiger Power")
   local tpclearcasting = jps.buff("Combo Breaker: Tiger Palm")
   local bkclearcasting = jps.buff("Combo Breaker: Blackout Kick")

   local spellTable =
   {
      { nil,                IsSpellInRange("jab","target") == 0 },
      { "Energizing Brew",        jps.UseCDs and energy <= 35 },
      { "Tigereye Brew",        jps.UseCDs and jps.buffStacks("Tigereye Brew") == 10 },
      { jps.DPSRacial,          jps.UseCDs },
      { "spear hand strike",     jps.shouldKick() and jps.Interrupts },
      { "Touch of Death",        jps.UseCDs and jps.buff("Death Note") },
      { "Tiger Palm",           tpclearcasting },
      { "Tiger Palm",           cp > 0 and jps.buffStacks("Tiger Power") < 3 },
      { "Blackout Kick",        bkclearcasting },
      { "jab",                   jps.cooldown("Fists of Fury") == 0 and cp < 3 },
      { "Fists of Fury",        cp > 2 and not jps.Moving and IsSpellInRange("jab","target") },
      { "Tiger Palm",           tpDuration <= 5 and cp > 0 },
      { "Rising Sun Kick",        cp > 1 },
      { "Blackout Kick",        cp > 1 },
      { "Expel Harm",           cp < 3 and jps.hp() < 0.7 },
      { "jab",                   cp < 3 and energy > 40 },
   }

   return parseSpellTable(spellTable)
end