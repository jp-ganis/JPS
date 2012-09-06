--jpganis
-- Ty to rer09!
function priest_shadow(self)
   local swpDuration = jps.debuffDuration("shadow word: pain")
   local plagueDuration = jps.debuffDuration("devouring plague")
   local vtDuration = jps.debuffDuration("vampiric touch")
   local sorbs = UnitPower("player",13)
   

   local spellTable =
   {
      { "mind blast",                 jps.cooldown("mind blast") == 0 and sorbs < 3 },
      { "vampiric touch",              not jps.debuff("vampiric touch") or vtDuration < 4 and jps.LastCast ~= "vampiric touch" },
      { "shadow word: pain",      not jps.debuff("shadow word: pain") or swpDuration < 2 },
      { "mind spike",                 jps.buff("surge of darkness") },
      { "shadowfiend",              jps.cooldown("mindbender") == 0 },
      { "devouring plague",              sorbs > 2 },
      { "shadow word: death",      jps.hp("target") <= 0.25 },
      { {"macro","/cast mind flay"},   jps.cooldown("mind flay") == 0 },
   }

   return parseSpellTable( spellTable )
end