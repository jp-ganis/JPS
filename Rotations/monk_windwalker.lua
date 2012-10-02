    function monk_windwalker(self)
      --rer09

          local energy = UnitMana("player")
          local chi = UnitPower("Player", 12)
          local tpDuration = jps.buffDuration("Tiger Power")
          local tpclearcasting = jps.buff("Combo Breaker: Tiger Palm")
          local bkclearcasting = jps.buff("Combo Breaker: Blackout Kick")

          local spellTable =
          {
      -- Chi Builders
      { "jab",                         chi < 3 and energy > 40 and (jps.cooldown("Expel Harm") > 0 or jps.hp() > .94) and not jps.MultiTarget and not tpclearcasting and not bkclearcasting },
             { "Expel Harm",                 chi < 3 and jps.hp() < 0.94 and jps.cooldown("Expel Harm") == 0 and energy > 40 },      

      -- On-Use Trinkets
      {jps.useTrinket(1),           jps.UseCds },
          {jps.useTrinket(2),           jps.UseCds },
      
      -- Chi Finishers
             { "Rising Sun Kick",              chi > 1 and jps.cooldown("Rising Sun Kick") == 0 and not jps.buff("Death Note") },
             { "Tiger Palm",                 chi > 0 and jps.buffStacks("Tiger Power") < 3 and not jps.buff("Death Note") },
             { "Tiger Palm",                 tpDuration <= 5 and chi > 0 },
             { "Fists of Fury",              chi > 2 and not jps.Moving and IsSpellInRange("jab","target") and jps.cooldown("Fists of Fury") == 0 },
             { "Blackout Kick",              chi > 1  and not jps.buff("Death Note") },

      -- Combo Breakers
             { "Tiger Palm",                 tpclearcasting },
             { "Blackout Kick",              bkclearcasting },

      -- Defensive Abilities
      { "Fortifying Brew",         jps.UseCDs and jps.hp() < .5 },
      { {"macro","/cast Chi Wave"},       jps.UseCDs and jps.hp() < .6 },
      { {"macro","/cast Touch of Karma"},   jps.UseCDs and jps.hp() < .7 and jps.cooldown("Touch of Karma") },

      -- Cooldowns
             { "Tigereye Brew",              jps.UseCDs and jps.buffStacks("Tigereye Brew") == 10 },
            { "Touch of Death",              jps.UseCDs and jps.buff("Death Note") and chi > 2 },
             { "Energizing Brew",              jps.UseCDs and energy <= 70 },

      -- Interrupts
      { "Spear Hand Strike",         jps.Interrupts and jps.shouldKick() },
      { "Leg Sweep",            jps.Interrupts and jps.shouldKick() and jps.cooldown("Spear Hand Strike") > 0 },

      -- AoE (4+ targets)
      { "Spinning Crane Kick",      jps.MultiTarget and energy > 40 and chi < 3 },


        }

          return parseSpellTable(spellTable)
       end