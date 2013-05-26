function warlock_demo(self)

if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local mana = UnitMana("player")/UnitManaMax("player")
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
   
   { {"macro","/cast Dark Soul: Knowledge"}, jps.cooldown("Dark Soul: Knowledge") == 0 and jps.UseCDs and jps.Opening },
   { {"macro","/cast Dark Soul: Knowledge"}, jps.cooldown("Dark Soul: Knowledge") == 0 and jps.UseCDs and dpower > 780 },
   { "hand of gul'dan" },
   { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
   { jps.DPSRacial, jps.UseCDs },
   
   { "corruption", cpn_duration == 0 },
   
   { "imp swarm", jps.UseCDs },
   { {"macro","/cast felstorm"}, jps.cooldown("felstorm") == 0 },
   { {"macro","/cast Grimoire: Felguard"}, jps.cooldown("Grimoire: Felguard") == 0 and not jps.buff("metamorphosis") and jps.UseCDs },
   
   ----- meta pull -----
   { "metamorphosis", jps.Opening },
   
   ---meta cycle ----
   { "metamorphosis", dpower > 800 },
   
   { {"macro","/cast doom"}, jps.buff("metamorphosis") and jps.buffDuration("doom") <= 30 },
   { {"macro","/cast touch of chaos"}, jps.buff("metamorphosis") },
   
   
   -- forme humaine --
   
   { "soul fire", jps.buff("molten core") and jps.buffDuration("molten core") > 2 and not jps.buff("metamorphosis") },
   { "soul fire", jps.hp("target") <= 0.25 and not jps.buff("metamorphosis") },
   { "shadow bolt", not jps.buff("metamorphosis") },
   
   
   }
   
   if jps.buff("metamorphosis") then jps.Opening = false end
   
     local spell = parseSpellTable( spellTable )
      return spell
end