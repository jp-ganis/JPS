function shaman_enhancement(self)
	-- Credit (and thanks!) to scottland3.
   local spell = nil
   local mana = UnitMana("player")/UnitManaMax("player")
   local maelstrom_count = jps.get_buff_stacks("player","maelstrom weapon")
   
   if jps.Interrupts("target") and cd("Wind Shear") == 0 and jps.should_kick("target") then 
      SpellStopCasting()
			spell = "Wind Shear"
   elseif cd("Shamanistic Rage") == 0 and mana < 0.2 then 
      spell = "Shamanistic Rage"
   elseif GetTotemTimeLeft("1") < 2 then
      spell = "searing totem"
   elseif cd("lava lash") == 0 then
      spell = "lava lash"
   elseif ub("player","unleash flame") and cd("flame shock") == 0 then
      spell = "flame shock"
   elseif maelstrom_count == 5 then 
      spell = "lightning bolt"
   elseif cd("unleash elements") == 0 then
      spell = "unleash elements"
   elseif cd("stormstrike") == 0 then
      spell = "stormstrike"
   elseif cd("earth shock") == 0 then
      spell = "earth shock"
   elseif cd("feral spirit") == 0 then
      spell = "feral spirit"
   end
   return spell
end
