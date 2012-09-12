function paladin_ret(self)
   --Razza13
   local hPower = UnitPower("player","9")

   local spellTable =
   {      
      { "inquisition", jps.buffDuration("inquisition") < 5 and (hPower > 2 or jps.buff("divine purpose")) },
      { "templar's verdict", hPower > 2 },
      { "hammer of wrath", jps.buff("avenging wrath") or jps.hp("target") <= 0.20 },
      { "exorcism", jps.buff("the art of war") },
      { "exorcism" },
      { "crusader strike" },
      { "judgment" },
   }
   

   return parseSpellTable(spellTable)
end