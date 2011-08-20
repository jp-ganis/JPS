function rogue_sub(self)
   local cp = GetComboPoints("player")
   local spell = nil

   if jps.Interrupts and jps.should_kick("target") and cd("kick") == 0 then
      spell = "kick"
   elseif ub("player","stealth") and cd("shadowstep") == 0 then
      spell = "shadowstep"
   elseif ub("player","stealth") then
      spell = "garrote"
   elseif ub("player","shadow dance") and cd("shadowstep") == 0 then
      spell = "shadowstep"
   elseif ub("player","shadow dance") then
      spell = "ambush"
   elseif not ub("player","stealth") and cd("shadow dance") == 0 and jps.UseCDs then
      spell = "shadow dance"
   elseif not ub("player","stealth") and cd("vanish") == 0 and jps.UseCDs then
      spell = "vanish"
   elseif not ub("player","slice and dice") and cp >= 3 then
      spell = "slice and dice"
   elseif not ub("player","recuperate") and cp >= 3 then
      spell = "recuperate"
   elseif not ud("target","hemorrhage") then
      spell = "hemorrhage"
   elseif cp >= 4 then
      spell = "eviscerate"
   else
      spell = "backstab"
   end

   return spell
end
