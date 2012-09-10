function shaman_resto(self)
	local spell = nil
   local lsStacks = jps.buffStacks("lightning shield")
   local focus = "focus"
   local me = "player"
   local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()
   local engineering ="/use 10"
   local r = RunMacroText
	local tank = nil
	
	

   -- Totems
   local _, fireName, _, _, _ = GetTotemInfo(1)
   local _, earthName, _, _, _ = GetTotemInfo(2)
   local _, waterName, _, _, _ = GetTotemInfo(3)
   local _, airName, _, _, _ = GetTotemInfo(4)

   local haveFireTotem = fireName ~= ""
   local haveEarthTotem = earthName ~= ""
   local haveWaterTotem = waterName ~= ""
   local haveAirTotem = airName ~= ""

	
	
	tank = jps.findMeATank()
	--assumes that focus is the tank
	
	
	-- Check if we should Purify
    local cleanseTarget = nil
    cleanseTarget = jps.FindMeADispelTarget({"Curse"},{"Magic"})
    

	-- lowest friendly
	local defaultTarget = jps.lowestInRaidStatus()
	local defaultHP = jps.hpInc(defaultTarget)
	

	-- Priority Table
	local spellTable = {
			{ "fire elemental totem",   jps.UseCDs },
			{ "spiritwalker's grace", jps.Moving and defaultHP < 0.75 },
			
			{ "water shield", not jps.buff("water shield"), me  },
			{ "Earthliving Weapon",         not mh, me},
			
			{ "earth shield",			tank ~= me and not jps.buff("earth shield",tank), tank },
			
			
			-- Heals
			{ "riptide",				defaultHP < 0.95 and not jps.buff("RipTide"), defaultTarget },
			{ "greater healing wave",		defaultHP < 0.4, defaultTarget },
			{ "healing wave",				defaultHP < 0.8, defaultTarget },
			
			{ "Purify spirit",			cleanseTarget~=nil, cleanseTarget },
			
			

	}

	return parseSpellTable( spellTable )
end
