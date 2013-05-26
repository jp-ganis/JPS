function warrior_fury(self)
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local spell = nil
   local nRage = jps.buff("Enrage") 
   local targetHealth = jps.hp(target)*100
   local nPower = UnitPower("Player",1) -- Rage est PowerType 1

   local spellTable = 
   {
      { "Recklessness" ,         jps.UseCDs and (jps.debuffDuration("Colossus Smash") >= 5 or jps.cooldown("Colossus Smash") <= 4 ) and targetHealth < 20 },
      { "Bloodbath",   	 jps.UseCDs and jps.buff("Recklessness") },   
      { "Berserker Rage" ,       jps.UseCDs and (not nRage or (jps.buffStacks("Raging Blow") == 2 and targetHealth > 20 )) },
      { "Deadly Calm" ,         jps.UseCDs and nPower >= 40 },
      { "Heroic Strike" ,       (((jps.debuff("Colossus Smash") and nPower >= 40) or (jps.buff("Deadly Calm") and nPower >= 30)) and targetHealth >= 20 ) or nPower >=110 },
      { "Bloodthirst" ,         not (targetHealth < 20 and jps.debuff("colossus smash") and nPower >= 30 ) }, 
      { "Wild Strike" ,          jps.buff("Bloodsurge") and targetHealth >= 20 and jps.cooldown("Bloodthirst") <= 1 },
      { nil,                     not (targetHealth < 20 and jps.debuff("colossus smash") and rage >= 30) and jps.cd("bloodthirst") <= 1 },
      { "Colossus Smash" },
      { "Execute" },
      { "Raging Blow" ,          jps.buff("Raging Blow!") },
      { "Wild Strike" ,          jps.buff("Bloodsurge") and targetHealth >= 20 },
      { "Shockwave" },
      { "Dragon Roar" },
      { "Heroic Throw"  },
      { "Commanding Shout" ,          nPower <= 70 and not jps.debuff("Colossus Smash") },
      { "Wild Strike" ,         jps.debuff("Colossus Smash") and targetHealth >= 20 },   
      { "Impending Victory" ,      targetHealth >= 20  },
      { "Wild Strike" ,         jps.cooldown("Colossus Smash") >= 1 and nPower >= 60 and targetHealth >= 20  },
      { "Commanding Shout" ,          nPower <= 70  },   
   }

   local spell,target = parseSpellTable(spellTable)
   return spell
end