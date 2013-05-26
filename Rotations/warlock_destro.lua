function warlock_destro(self)
   --latitude
   local burning = UnitPower("player",14);   
   local spell = nil;   
   local imo_duration = jps.debuffDuration("immolate");

local spellTable =

{
   
   
   { "curse of the elements", not jps.debuff("curse of the elements") },
   { {"macro","/use 13"},      jps.itemCooldown("77114") == 0 and jps.UseCDs },
   { {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and jps.UseCDs },
   { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
   { jps.DPSRacial, jps.UseCDs },
   { "shadowburn", jps.hp("target") <= 0.20 and burning > 0  },
   { "chaos bolt", lcChaosBolting },
   { "immolate", imo_duration < 2 and jps.LastCast ~= "immolate" },
   { "conflagrate", "onCD" },
   { "incinerate" },
}   
        if burning <= 1 then lcChaosBolting = false end
         if burning > 2 then lcChaosBolting = true end
        local spell = parseSpellTable( spellTable )
      return spell
end
