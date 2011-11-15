function shaman_elemental(self)
	-- jpganis basics, thorshammer for all the good stuff :D
   local spell = nil
   local lsStacks = jps.buffStacks("lightning shield")
   local mana = UnitMana("player")/UnitManaMax("player")
   local focus = "focus"
   local me = "player"
   local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()
   local engineering ="/use 10"
   local r = RunMacroText
   
   -- Totems
   local _, fireName, _, _, _ = GetTotemInfo(1)
   local _, earthName, _, _, _ = GetTotemInfo(2)
   local _, waterName, _, _, _ = GetTotemInfo(3)
   local _, airName, _, _, _ = GetTotemInfo(4)

   local haveFireTotem = fireName ~= ""
   local haveEarthTotem = earthName ~= ""
   local haveWaterTotem = waterName ~= ""
   local haveAirTotem = airName ~= ""
   
   
   -- Miscellaneous
   local feared = jps.debuff("fear","player") or jps.debuff("intimidating shout","player") or jps.debuff("howl of terror","player") or jps.debuff("psychic scream","player")
   
   local spellTable =
   {
      -- Set Me Up.
      { "lightning shield", not jps.buff("lightning shield")  },
      { "Flametongue Weapon",         not mh},
      
      -- Totems.
      { "call of the elements",   not haveWaterTotem and not haveFireTotem and not haveEarthTotem and not haveAirTotem },
      { "healing stream totem",   not haveWaterTotem },
      { "searing totem",      not haveFireTotem },
      { "wrath of air totem",      not haveAirTotem },
      { "stoneskin totem",      not haveEarthTotem },
      { "fire elemental totem",   jps.UseCDs },
      
      -- Hex.
      {"hex", not jps.debuff("hex","focus"), "focus"},
      
      -- Break fear.
      { "tremor totem", feared },
      
      -- Kick.
      { "wind shear",   jps.shouldKick() },
            
      -- Dwarf Racial for Bleeds.
      { jps.defRacial, jps.hp() < 0.6 or (jps.defRacial == "stoneform" and jps.debuff("rip","player")) },
      
      -- Basic Priority Spells
      { "elemental mastery",   "onCD" },
      { "flame shock", jps.debuffDuration("flame shock") < 2 },
      { r(engineering), "onCD" },
      { "lava burst",   "onCD" },
      { "earth shock", lsStacks == 9 },
      { "earth shock", lsStacks > 7 and jps.debuffDuration("flame shock") > 5 },
      { "spiritwalker's grace", jps.Moving },
      { "chain lightning", jps.MultiTarget },
      { "thunderstorm", mana < .6 and jps.UseCDs },
      { "lightning bolt", "onCD" },
   }

   return parseSpellTable( spellTable )
end
