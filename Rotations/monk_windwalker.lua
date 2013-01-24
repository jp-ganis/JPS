function monk_windwalker(self)
  
  if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
  
  -- Using the rotation outlined here: http://www.noxxic.com/wow/pve/monk/windwalker/dps-rotation-and-cooldowns
  
  -- Tested with so-so gear around a 480 ilvl.
  -- Approximately 60k single-target DPS with self buffs.
  -- Approximately 80k single-target DPS with raid buffs.
  -- Over 70k multi-target DPS. Can easily go over 100k if there's a lot of mobs and a decent tank.
  
  local energy = UnitMana("player")
  local chi = UnitPower("Player", 12)
  local defensiveCDActive = jps.buff("Touch of Karma") or jps.buff("Zen Meditation") or jps.buff("Fortifying Brew") or jps.buff("Dampen Harm") or jps.buff("Diffuse Magic")
  local tigerPowerDuration = jps.buffDuration("Tiger Power")

  -- Need to use the Tigereye Brew buff ID because it shares it's name with the stacks.
  local tigereyeActive = jps.buffID(116740)
  
  -- Spells should be ordered by priority.
  local possibleSpells = {

    -- Defensive Cooldowns.
    -- { "Zen Meditation", 
    --   jps.hp() < .4 
    --   and not defensiveCDActive },
      
    { "Fortifying Brew", 
      jps.hp() < .6 
      and not defensiveCDActive },

    -- Defensive Cooldown. (talent specific)
    { "Diffuse Magic", 
      jps.hp() < .6 
      and not defensiveCDActive },

    -- Defensive Cooldown. (talent specific)
    { "Dampen Harm", 
      jps.hp() < .6 
      and not defensiveCDActive },

    -- Defensive Cooldown.
    { "Touch of Karma",
      jps.hp() < .7
      and not defensiveCDActive },
    
    -- Insta-kill single target when available
    { "Touch of Death", 
      jps.buff("Death Note") 
      and not jps.MultiTarget },

    -- Interrupts
    { "Spear Hand Strike", 
      jps.Interrupts 
      and jps.shouldKick() },
    { "Paralysis", 
      jps.Interrupts 
      and jps.shouldKick() },

    -- Tigereye Brew when we have 10 stacks.
    { "Tigereye Brew", 
      jps.UseCDs
      and jps.buffStacks("Tigereye Brew") == 10 },
        
    -- Synapse springs when we have Tigereye Brew. (engineers)
    { jps.useSlot(10), 
      tigereyeActive },
    
    -- Lifeblood when we have Tigereye Brew. (herbalists)
    { "Lifeblood",
      tigereyeActive },
    
    -- On-use Trinkets when we have Tigereye Brew.
    { jps.useSlot(13), 
      tigereyeActive },
    { jps.useSlot(14), 
      tigereyeActive },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
      jps.UseCDs },

    -- Chi Brew if we have no chi. (talent based)
    { "Chi Brew", 
      chi == 0 },
    
    -- Energizing Brew whenever we're under 70 energy so we don't waste it.
    { "Energizing Brew", 
      energy <= 70 },

    -- Rising Sun Kick on cooldown.
    { "Rising Sun Kick", 
      chi >= 2 },

    -- Invoke Xuen on cooldown for single-target. (talent based)
    { "Invoke Xuen, the White Tiger", 
      jps.UseCDs 
      and not jps.MultiTarget },

    -- Rushing Jade Wind on cooldown for multi-target. (talent based)
    { "Rushing Jade Wind", 
      jps.MultiTarget },

    -- Tiger Palm single-target if the buff is close to falling off.
    { "Tiger Palm", 
      not jps.MultiTarget 
      and tigerPowerDuration <= 1
      and chi >= 1 },

    -- Fist of fury is a very situational chi dump, and is mainly filler to regenerate energy while it channels.
    -- Only use it with low energy and if RSK will be on CD and Tiger Power will be up for it's duration.
    { "Fists of Fury", 
      chi >= 3 
      and energy <= 30 
      and jps.cooldown("Rising Sun Kick") > 3
      and tigerPowerDuration > 3.5
      and not jps.Moving 
      and IsSpellInRange("jab","target") },

    -- Blackout Kick single-target on clearcast.
    { "Blackout Kick",
      not jps.MultiTarget 
      and jps.buff("Combo Breaker: Blackout Kick") },

    -- Tiger Palm single-target on clearcast.
    { "Tiger Palm",
      not jps.MultiTarget 
      and jps.buff("Combo Breaker: Tiger Palm") },

    -- Blackout Kick as single-target chi dump.
    { "Blackout Kick", 
      not jps.MultiTarget
      and chi >= 3 },

    -- Leg sweep on cooldown during multi-target to reduce tank damage. TODO: Check if our target is stunned already.
    { "Leg Sweep", 
      jps.MultiTarget },

    -- Chi Wave if we're not at full health. (talent based)
    { "Chi Wave",
      jps.hp() < .8
      and chi >= 2 },

    -- Chi Burst if we're not at full health. (talent based)
    { "Chi Burst", 
      jps.hp() < .8
      and chi >= 2 },

    -- Zen Sphere if we're not at full health. (talent based)
    { "Zen Sphere", 
      jps.hp() < .8
      and chi >= 2
      and not jps.buff("Zen Sphere") },

    -- Expel Harm to build chi and heal if we're not at full health.
    { "Expel Harm", 
      chi < 3 
      and energy >= 40 
      and jps.hp() < .85 },

    -- Spinning Crane Kick when we're multi-target (4+ targets ideal).
    { "Spinning Crane Kick", 
      energy >= 40 
      and jps.MultiTarget },

    -- Default chi builder.
    { "Jab", 
      chi < 3 
      and energy >= 40 
      and not jps.MultiTarget },
  }

  return parseSpellTable(possibleSpells)
end
