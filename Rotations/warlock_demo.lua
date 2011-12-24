--huge thanks to latitude!
--as good as simcraft :)
function warlock_demo(self)
   local mana = UnitMana("player")/UnitManaMax("player")
   local shards = UnitPower("player",7)

   local bod_duration = jps.debuffDuration("bane of doom")
   local cpn_duration = jps.debuffDuration("corruption")
   local imo_duration = jps.debuffDuration("immolate")

   local spellTable =
   {
      { "demon soul" },
	  { {"macro","/use 10"}, jps.glovesCooldown() == 0 },
      { "metamorphosis" },
      { "shadowflame"},
      { "immolate", imo_duration < 2 and jps.LastCast ~= "immolate"},
      { "hand of gul'dan", jps.cd("hand of gul'dan") == 0 },
      { "corruption", cpn_duration < 3 },
      { "bane of doom", bod_duration == 0 },
      { "fel flame", jps.Moving },
      { "incinerate", jps.buff("molten core")},
      { "soul fire", jps.buff("decimation")},
      { "incinerate" },
   }
   
   
   return parseSpellTable(spellTable)
end

