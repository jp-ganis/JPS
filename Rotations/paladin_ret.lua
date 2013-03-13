function paladin_ret(self)

  local holyPower = UnitPower("player", "9")

  local spellTable = {  
    
    -- Might
    { "Blessing of Might", 
      not jps.buff("Blessing of Might") },
    
    -- Oh shit button
    { "Lay on Hands", 
      jps.UseCDs
      and jps.hp() < .2 },
    
    -- Bubble
    { "Divine Shield", 
      jps.UseCDs
      and jps.hp() < .2 },
    
    -- Big Heal
    { "Flash of Light", 
      jps.hp() < .75
      and jps.buff("The Art of War") },
    
    -- Heal
    { "Sacred Shield", 
      jps.hp() < .7
      and not jps.buff("Sacred Shield") },
    
    -- Guardian of Ancient Kings
    { "Guardian of Ancient Kings", 
      jps.UseCDs },
    
    -- Avenging Wrath
    { "Avenging Wrath", 
      jps.UseCDs
      and jps.hp() < .8 },
    
    -- Holy Avenger
    { "Holy Avenger", 
      jps.UseCDs
      and jps.hp() < .7 },
            
    -- Heal
    { "Word of Glory", 
      jps.hp() < .7 },
    
    -- Interrupts
    { "Rebuke", 
      jps.Interrupts 
      and jps.shouldKick() },
    
    -- Trinket CDs.
    { jps.useSlot(13), 
      jps.UseCDs },
    { jps.useSlot(14), 
      jps.UseCDs },
    
    -- Synapse Springs CD. (engineering gloves)
    { jps.useSlot(10), 
      jps.UseCDs },
    
    -- Lifeblood CD. (herbalists)
    { "Lifeblood",
      jps.UseCDs },
    
    -- DPS Racial CD.
    { jps.DPSRacial, 
      jps.UseCDs },
    
    { "Inquisition", 
      jps.buffDuration("Inquisition") < 5 
      and (
        holyPower > 2 
        or jps.buff("Divine Purpose")
      ) },
    
    { "Templar's Verdict", 
      holyPower == 5 },
    
    -- Execute
    { "Hammer of Wrath", 
      jps.buff("Avenging Wrath") 
      or jps.hp("target") <= .2 },

    -- Exorcism proc
    { "Exorcism", 
      jps.buff("The Art of War") },
      
    { "Judgment" },
    
    { "Crusader Strike" },
    
    { "Exorcism" },
  }
   

   return parseSpellTable(spellTable)
end
