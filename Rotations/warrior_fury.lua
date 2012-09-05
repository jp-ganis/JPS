function warrior_fury(self)
--Gocargo
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local spell = nil
   local targetHealth = UnitHealth("target")/UnitHealthMax("target")
   local nRage = jps.buff("Berserker Rage","player")
   local nPower = UnitPower("Player",1) -- Rage est PowerType 1

   local spellTable = 
   {
      { "Recklessness" ,         jps.UseCDs and (jps.debuffDuration("Colossus Smash") >= 5 or jps.cooldown("Colossus Smash") <= 4 ) and targetHealth < 20 , "target" },   
      { "Berserker Rage" ,       jps.UseCDs and (not nRage or (jps.buffStacks("Raging Blow") == 2 and targetHealth > 20 )), "player" },
      { "Deadly Calm" ,         jps.UseCDs and nPower >= 40, "player" },
      { "Lifeblood" ,          "onCD", "player" },
      { "Heroic Strike" ,       (((jps.buff("player", "Colossus Smash") and nPower >= 40) or (jps.buff("Deadly Calm") and nPower >= 30)) and targetHealth >= 20 ) or nPower >=110 , "target" },
      { "Bloodthirst" ,          targetHealth > 20 and not jps.debuff("Colossus Smash") and nPower < 30 , "target" },
      { "Wild Strike" ,          jps.buff("Bloodsurge") and targetHealth >= 20 and jps.cooldown("Bloodthirst") <= 1 , "target" },
      { "Colossus Smash" ,       "onCD" , "target" },
      { "Execute" ,            "onCD" , "target" },
      { "Raging Blow" ,          jps.buff("Raging Blow") , "target" },
      { "Wild Strike" ,          jps.buff("Bloodsurge") and targetHealth >= 20 , "target" },
      { "Dragon Roar" ,          "onCD" , "target" },
      { "Heroic Throw" ,         "onCD" , "target" },
      { "Battle Shout" ,          nPower <= 70 and not jps.debuff("Colossus Smash") , "player" },
      { "Wild Strike" ,         jps.debuff("Colossus Smash") and targetHealth >= 20 , "target" },   
      { "Impending Victory" ,      targetHealth >= 20 , "target" },
      { "Wild Strike" ,         jps.cooldown("Colossus Smash") >= 1 and nPower >= 60 and targetHealth >= 20 , "target" },
      { "Battle Shout" ,          nPower <= 70  , "player" },   

      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end