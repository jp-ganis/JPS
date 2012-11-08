function warrior_arms(self)
--Gocargo

   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local spell = nil
   local targetHealth = UnitHealth("target")/UnitHealthMax("target")
   local nRage = jps.buff("Berserker Rage","player")
   local nPower = UnitPower("Player",1) -- Rage est PowerType 1

   local spellTable = 
   {
      { "Recklessness" ,         jps.UseCDs and (jps.debuffDuration("Colossus Smash") >= 5 or jps.cooldown("Colossus Smash") <= 4 ) and targetHealth < 20 , "target" },   
      { "Berserker Rage" ,       jps.UseCDs and not nRage, "player" },
      { "Deadly Calm" ,         jps.UseCDs and nPower >= 40, "player" },
      { "Lifeblood" ,          jps.UseCDs , "player" },
      { "Heroic Strike" ,       (((jps.buff("taste for blood") and jps.buffDuration("taste for blood") <= 2) or (jps.buffStacks("taste for blood") == 5) or (jps.buff("Taste for Blood") and jps.debuffDuration("Colossus Smash") <= 2 and jps.cooldown("Colossus Smash") > 0) or jps.buff("Deadly Calm") or nPower >= 110)) and targetHealth >= 20 and jps.debuff("Colossus Smash") , "target" },
      { "Mortal Strike" ,       "onCD" , "target" },
      { "Colossus Smash" ,       jps.debuffDuration("Colossus Smash") <= 1.5 , "target" },
      { "Execute" ,            "onCD" , "target" },
      { "Overpower" ,          jps.buff("Overpower") , "target"},
      { "Dragon Roar" ,          "onCD" , "target" },
      { "Slam" ,                (nPower >= 70 or jps.debuff("Colossus Smash")) and targetHealth >= 20 , "target" },
      { "Heroic Throw" ,         "onCD" , "target" },
      { "Battle Shout" ,          nPower <= 70 and not jps.debuff("Colossus Smash") , "player" },
      { "Slam" ,                targetHealth >= 20 , "target" },
      { "Impending Victory" ,      targetHealth >= 20 , "target" },
      { "Battle Shout" ,          nPower <= 70  , "player" },   

      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end