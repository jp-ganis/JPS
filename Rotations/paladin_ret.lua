function paladin_ret(self)
--latitude
   local hPower = UnitPower("player","9")

   local spellTable =
   {

---- Mono -----
      
      
      { "inquisition", jps.buffDuration("inquisition") < 5 },
      { "avenging wrath", jps.UseCDs },
      { "templar's verdict", hPower == 5 },
      { "hammer of wrath", jps.buff("avenging wrath") or jps.hp("target") <= 0.20 },
      { "exorcism" },
      { "exorcism", jps.buff("the art of war") },
      { "crusader strike", hPower < 3 },
      { "judgment" },
      { "templar's verdict", hPower == 3 },
      
      
   }
   

   return parseSpellTable(spellTable)
end