function warrior_arms(self)

  if UnitCanAttack("player", "target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end

  local rage = UnitPower("Player", 1)

  local possibleSpells =  {
    
    { "Recklessness" ,
      jps.UseCDs 
      and ( jps.debuffDuration("Colossus Smash") >= 5 
        or jps.cooldown("Colossus Smash") <= 4 ) 
      and jps.hp("target") < .2 },
      
    { "Berserker Rage" ,
      jps.UseCDs 
      and not jps.buff("Berserker Rage") },
      
    { "Deadly Calm" ,
      jps.UseCDs 
      and rage >= 40 },
      
    { "Lifeblood" ,
      jps.UseCDs },
      
    { "Heroic Strike" ,
      jps.hp("target") >= .2
      and jps.debuff("Colossus Smash")
      and ( ( (
            jps.buff("taste for blood") 
            and jps.buffDuration("taste for blood") <= 2 )
          or jps.buffStacks("taste for blood") == 5
          or (
            jps.buff("Taste for Blood") 
            and jps.debuffDuration("Colossus Smash") <= 2 
            and jps.cooldown("Colossus Smash") > 0 ) 
          or jps.buff("Deadly Calm") 
          or rage >= 110 ) ) },
      
    { "Mortal Strike" },
      
    { "Colossus Smash",
      jps.debuffDuration("Colossus Smash") <= 1.5 },
      
    { "Execute" },
    
    { "Overpower",
      jps.buff("Overpower") },
      
    { "Dragon Roar" },
    
    { "Slam", 
      (rage >= 70 
        or jps.debuff("Colossus Smash"))
      and jps.hp("target") >= .2 },
    
    { "Heroic Throw" },
    
    { "Battle Shout",
      rage <= 70 
      and not jps.debuff("Colossus Smash"), "player" },
      
    { "Slam",
      jps.hp("target") >= .2 },
      
    { "Impending Victory", 
      jps.hp("target") >= .2 },
      
    { "Battle Shout", 
      rage <= 70 },   

    { {"macro","/startattack"} },
  }

  return parseSpellTable(possibleSpells)
end
