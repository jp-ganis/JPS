function paladin_ret()
   if jps.PvP then
      return paladin_ret_pvp()
   else
      return paladin_ret_pve()
   end
end