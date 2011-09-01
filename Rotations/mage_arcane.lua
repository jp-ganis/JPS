function mage_arcane(self)
	-- By Trixo v2.1
	-- /jps cds enables Arcane power and Mirror image
        -- /jps multi enables flame orb
	local r = RunMacroText
	local spell = nil
	local hp = UnitHealth("player")/UnitHealthMax("player")
	local mana = UnitMana("player")/UnitManaMax("player")
	local magearmor = jps.buffDuration("player","mage armor")
	local arcaneb = jps.buffDuration("player","arcane brilliance")	
	local abCount = jps.debuffStacks("player","arcane blast")
	local abDuration = jps.debuffDuration("player","arcane blast")	
	local useManagem = "/use mana gem"
	local engineering = "/use 10"

	if UnitChannelInfo("player") then
		return nil
	end
		
	if cd("flame orb") == 0 and jps.Multitarget then
		spell = "flame orb"		
-- Enable next two lines if you're a Herbalist	
        -- elseif cd("lifeblood") == 0 and UnitHealthMax("target") > 1000000 and UnitHealth("target") > 500000 then
        	-- spell = "lifeblood"	
-- Enable next two lines if you're a Engineer
        -- elseif GetItemCooldown("65141") == 0 then
         	-- r(engineering)		
-- Enable next two lines if you're a troll(race)	
	-- elseif cd("berserking") == 0 and ub("player","arcane power") then
		-- spell = "berserking"			
	elseif cd("arcane power") == 0 and UnitHealthMax("target") > 1000000 and UnitHealth("target") > 500000 and jps.UseCDs then
		spell = "arcane power"
	elseif cd("mirror image") == 0 and UnitHealthMax("target") > 2000000 and UnitHealth("target") > 1000000 and jps.UseCDs then
		spell = "mirror image"			 		
	elseif magearmor < 60 then
		spell = "mage armor"
	elseif arcaneb < 60 then
		spell = "arcane brilliance"	
	elseif GetItemCount("Mana gem") == 1 and GetItemCooldown(36799) == 0 and mana < 0.7 then
		r(useManagem)	
	elseif hp < 1 and cd("mage ward") == 0 then
		spell = "mage ward"			
	elseif abDuration < 2 and ud("player","arcane blast") and not jps.Casting then
		spell = "arcane barrage" 					 	
	elseif cd("evocation") == 0 and mana < 0.3 and not jps.Moving then
		spell = "evocation"	
	elseif ub("player","arcane missile!") and mana < 0.5 then
		spell = "arcane missiles"
	elseif abCount == 4 and	 mana < 0.8 and ub("player","arcane missiles!") then
		spell = "arcane missiles"
	elseif jps.Moving and cd("arcane barrage") == 0 then
		spell = "arcane barrage"		
	else
		spell = "arcane blast"
	end
	return spell
end
