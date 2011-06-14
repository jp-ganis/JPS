function mage_arcane(self)
	-- Credit (and thanks!) to trixo
   local mana = UnitMana("player")/UnitManaMax("player")
   local spell = nil
   local abCount = jps.get_debuff_stacks("player","arcane blast")
   local ab_duration = jps.debuff_duration("player","arcane blast")   
   local magearmor = jps.buff_duration("player","mage armor")
   local arcaneb = jps.buff_duration("player","arcane brilliance")

   if cd("lifeblood") == 0 then
      spell = "lifeblood"
   elseif magearmor < 60 then
      spell = "mage armor"
   elseif arcaneb < 60 then
      spell = "arcane brilliance"         
   elseif ab_duration < 2 and GetUnitSpeed("player") > 0 then
      spell = "arcane blast"   
   elseif ub("player","arcane missile!") and mana < 0.5 then
      spell = "arcane missiles"
   elseif abCount == 4 and mana < 0.8 then
      spell = "arcane missiles"
   else
      spell = "arcane blast"
   end
   return spell
end   
