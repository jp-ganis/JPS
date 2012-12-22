function monk_windwalker(self)
  -- Tested with so-so gear around a 470 ilvl.
  -- Approximately 50k single-target DPS with self buffs.
  -- Approximately 60k single-target DPS with raid buffs.
  -- Over 70k multi-target DPS. Can easily go over 100k if there's a lot of mobs and a decent tank.

  local energy = UnitMana("player")
  local chi = UnitPower("Player", 12)
  local tpDuration = jps.buffDuration("Tiger Power")
  local tpclearcasting = jps.buff("Combo Breaker: Tiger Palm")
  local bkclearcasting = jps.buff("Combo Breaker: Blackout Kick")
  local defensiveCDActive = jps.buff("Touch of Karma") or jps.buff("Fortifying Brew") or jps.buff("Dampen Harm") or jps.buff("Diffuse Magic")
  local tbStacks = jps.buffStacks("Tigereye Brew")

  -- Spells should be ordered by priority.
  local possibleSpells = {

    -- Defensive Cooldowns
    { "Fortifying Brew", 
      jps.UseCDs 
      and jps.hp() < .6 
      and not defensiveCDActive },

    { "Diffuse Magic", 
      jps.UseCDs 
      and jps.hp() < .6 
      and not defensiveCDActive },

    { "Dampen Harm", 
      jps.UseCDs 
      and jps.hp() < .6 
      and not defensiveCDActive },

    { { "macro","/cast Touch of Karma" }, 
      jps.UseCDs 
      and jps.hp() < .7
      and not defensiveCDActive },

    { { "macro", "/cast Chi Wave" }, 
      jps.UseCDs 
      and jps.hp() < .6 
      and chi >= 2 },
    

    -- Insta-kill single target when available
    { "Touch of Death", 
      jps.UseCDs 
      and jps.buff("Death Note") 
      and not jps.MultiTarget },


    -- Interrupt
    { "Spear Hand Strike", 
      jps.Interrupts 
      and jps.shouldKick() },


    -- On-Use Trinkets
    { jps.useTrinket(1), 
      jps.UseCDs },

    { jps.useTrinket(2), 
      jps.UseCDs },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
        jps.UseCDs },

    -- Chi Brew if we have no chi. (talent based)
    { "Chi Brew", 
      chi == 0 },

    -- Tigereye Brew when we have 10 stacks.
    { "Tigereye Brew", 
      jps.UseCDs 
      and tbStacks == 10 },
    

    -- Energizing Brew whenever we're under 70 energy so we don't waste it.
    { "Energizing Brew", 
      jps.UseCDs 
      and energy <= 70 },


    -- Rising Sun Kick on cooldown.
    { "Rising Sun Kick", 
      chi >= 2 },


    -- Invoke Xuen on cooldown for single-target. (talent based)
    { "Invoke Xuen, the White Tiger", 
      jps.UseCDs 
      and not jps.MultiTarget },


    -- Rushing Jade Wind on cooldown for multi-target. (talent based)
    { "Rushing Jade Wind", 
      jps.UseCDs 
      and not jps.MultiTarget },


    -- Tiger Palm single-target if the buff is close to falling off.
    { "Tiger Palm", 
      not jps.MultiTarget 
      and ( (tpclearcasting 
        and tpDuration <= 3) 
      or (chi >= 1 
        and tpDuration <= 1) ) },


    -- Blackout Kick as single-target chi dump or on clearcast.
    { "Blackout Kick", 
      (chi >= 2 
        or bkclearcasting) 
      and not jps.MultiTarget },


    -- Leg sweep on cooldown during multi-target to reduce tank damage. TODO: Check if our target is stunned already.
    { "Leg Sweep", 
      jps.MultiTarget },

    -- Chi Wave if we're not at full health. (talent based)
    { "Chi Wave", 
      and jps.hp() < .9
      and chi >= 2 },

    -- Chi Burst if we're not at full health. (talent based)
    { "Chi Burst", 
      jps.hp() < .9
      and chi >= 2 },

    -- Zen Sphere if we're not at full health. (talent based)
    { "Zen Sphere", 
      jps.hp() < .8
      and chi >= 2
      and not jps.buff("Zen Sphere") },

    -- Heal + chi builder if we're not at full health.
    { "Expel Harm", 
      chi < 3 
      and energy >= 40 
      and jps.hp() < 0.85 },

    -- Spinning Crane Kick when we're multi-target (4+ targets ideal).
    { "Spinning Crane Kick", 
      energy >= 40 
      and jps.MultiTarget },

    -- Default chi builder.
    { "jab", 
      chi < 3 
      and energy >= 40 
      and not jps.MultiTarget },


    -- Fist of fury is very situational. Only use it with low energy and if RSK will be on CD for it's duration.
    { "Fists of Fury", 
      chi > 2 
      and energy < 40 
      and jps.cooldown("Rising Sun Kick") > 3.5 
      and not jps.Moving 
      and IsSpellInRange("jab","target") },

  }

  return parseSpellTable(possibleSpells)
end
