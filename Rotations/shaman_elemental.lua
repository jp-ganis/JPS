function shaman_elemental(self)
   -- Updated for MoP
   -- Tier 1: Astral Shift
   -- Tier 2: Windwalk Totem
   -- Tier 3: Call of the Elements
   -- Tier 4: Echo of the Elements
   -- Tier 5: Healing Tide Totem
   -- Major Glyphs: Flame Shock (required), Spiritwalker's Grace (recommended),
   --    Telluric Currents (recommended)
   -- Minor Glyphs: Thunderstorm (required)

   local spell = nil
   local lsStacks = jps.buffStacks("lightning shield")
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

   local spellTable = {
      { "lightning shield",
         not jps.buff("lightning shield") },

      { "Flametongue Weapon",
         not mh},

      { "searing totem",
         not haveFireTotem },
      
      { "fire elemental totem",
         not haveFireTotem and jps.UseCDs },

      { "wind shear",
         jps.shouldKick() },

      { "unleash elements",
         jps.debuffDuration("flame shock") < 2 },
      
      { "flame shock",
         jps.buff("unleash flame") },

      { "lava burst" },

      { "earth shock",
         lsStacks > 5 and jps.debuffDuration("flame shock") > 5 },
      
      { "spiritwalker's grace",
         jps.Moving },
      
      { "chain lightning",
         jps.MultiTarget },
      
      { "thunderstorm",
         jps.mana() < .6 and jps.UseCDs },
      
      { "lightning bolt" },
   }

   return parseSpellTable( spellTable )
end