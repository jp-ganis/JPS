function warlock_demo(self)
--latitude
if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local mana = UnitMana("player")/UnitManaMax("player")
   local bod_duration = jps.debuffDuration("bane of doom")
   local cpn_duration = jps.debuffDuration("corruption")
   local cur_duration = jps.debuffDuration("curse of the elements")
   local meta_duration = jps.buffDuration("metamorphosis")
   local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
   local dpower = UnitPower("player",15)
   local spell = nil
   local spellTable =
    
    {
   
   
   { "curse of the elements", cur_duration == 0 },
   { "fel flame", currentSpeed > 0 },

   { {"macro","/cast Dark Soul: Knowledge"}, jps.cooldown("Dark Soul: Knowledge") == 0 and jps.UseCDs },
   { "hand of gul'dan" },
   { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
   { jps.DPSRacial, jps.UseCDs },
   
   { "corruption", cpn_duration == 0 },
   
   { "imp swarm", jps.UseCDs },
   { {"macro","/cast felstorm"}, jps.cooldown("felstorm") == 0 },
   { {"macro","/cast Grimoire: Felguard"}, jps.cooldown("Grimoire: Felguard") == 0 and not jps.buff("metamorphosis") and jps.UseCDs },
   
   ----- meta only for opening -----
   { "metamorphosis", jps.Opening },

   
   ---meta cycle ----
   { "metamorphosis", dpower > 800 },
   { "bane of doom", jps.buff("metamorphosis") and bod_duration < 1 },
   { "touch of chaos", jps.buff("metamorphosis") },
   
   
   -- forme humaine --
   
   { "soul fire", jps.buff("molten core") and jps.buffDuration("molten core") > 2},
   { "soul fire", jps.hp("target") <= 0.25 },
   { "shadow bolt" },
   
   
   }
   
   if jps.buff("metamorphosis") then jps.Opening = false end
   
     local spell = parseSpellTable( spellTable )
      return spell
end