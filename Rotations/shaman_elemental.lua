function shaman_elemental(self)
   local spell = nil
   local mana = UnitMana("player")/UnitManaMax("player")
   local speed = GetUnitSpeed("player")   
   local lsCount = jps.get_buff_stacks("player","lightning shield")
   local fsDuration = jps.buff_duration("target","flame shock")
   
   if lsCount < 2 then
      spell = "lightning shield"
   elseif lsCount == 9 and fsDuration > 6 cd("earth shock") == 0 then
      spell = "earth shock"
   elseif mana < 0.6 and cd("thunderstorm") == 0 then
      spell = "thunderstorm"   
   elseif fsDuration < 2 and cd("flame shock") == 0 then
      spell = "flame shock"
   elseif speed > 0 then
      spell = "ghost wolf"
   elseif cd("lava burst") == 0 and cd("elemental mastery") == 0 and UnitHealth("target") > 500000 then
      spell = "elemental mastery"      
   elseif cd("lava burst") == 0 then
      spell = "lava burst"
   elseif cd("chain lightning") == 0 then
      spell = "chain lightning"
   else
      spell = "lightning bolt"
	end
	return spell
end
