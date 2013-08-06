jps.registerRotation("PRIEST","HOLY",function()
	
	local spell = nil
	local target = nil
		
	local playerhealth_deficiency = UnitHealthMax("player")-UnitHealth("player")
	
	local Priest_Target = jps.LowestInRaidStatus() 
	local health_deficiency = UnitHealthMax(Priest_Target) - UnitHealth(Priest_Target)
	local health_pct = jps.hp(Priest_Target)
	
	local stackSerendip = jps.buffStacks("Serendipity","player")
	
	-- counts the number of party members having a significant health loss
		local unitsBelow70 = 0
		local unitsBelow50 = 0
		local unitsBelow30 = 0
		for unit,index in pairs(jps.RaidStatus) do
			--Only check the relevant units
			if (index["inrange"] == true) then
				local thisHP = jps.hp(unit)
				-- Number of people below x%
				if thisHP < 0.3 then unitsBelow30 = unitsBelow30 + 1 end
				if thisHP < 0.5 then unitsBelow50 = unitsBelow50 + 1 end
				if thisHP < 0.7 then unitsBelow70 = unitsBelow70 + 1 end
			end
		end
	
	------------------------
	-- SPELL TABLE ---------
	------------------------
	
	local function parse_Chakra() -- return table
		local table=
		{
			{
				{ "Heal", health_deficiency < getaverage_heal("Flash Heal"), Priest_Target },
				{ "Flash Heal", health_deficiency > getaverage_heal("Flash Heal"), Priest_Target },
				{ "Heal", "onCD", "player" },
			}
		}
		return table
	end
	
	local spellTable =
	{
		-- buffs
		{ "Inner Fire", not jps.buff("Inner Fire") , "player" },
		{ "Power Word: Fortitude", not jps.buff("Power Word: Fortitude") , "player" },
		-- chakra
		{ "Chakra", not jps.buff("Chakra") and not jps.buff("Chakra: Serenity"), "player" },
		{ "nested", jps.buff("Chakra") and not jps.buff("Chakra: Serenity") , parse_Chakra() },
		
		-- oh shit heals
		{ "Guardian Spirit", health_pct < 0.25 , Priest_Target }, --SpellStopCasting()
		{ "Desperate Prayer", UnitHealth("player")/UnitHealthMax("player") < 0.40 , "player" }, -- SpellStopCasting()
		
		-- heal aggro
		{ "Fade", UnitThreatSituation("player")==3, "player" },
		
		-- priorities
		{ "Renew", not jps.buff("renew",Priest_Target) and health_deficiency > (getaverage_heal("Renew") + getaverage_heal("Heal")), Priest_Target },
		{ "Prayer of Mending", not jps.buff("Prayer of Mending",Priest_Target), Priest_Target },
		{ "Flash Heal", jps.buff("surge of light") and health_deficiency > getaverage_heal("Flash Heal"), Priest_Target },
		{ "Holy Word: Serenity", health_deficiency > (getaverage_heal("Renew") + getaverage_heal("Heal")), Priest_Target },
		{ "Flash Heal", health_pct < 0.50 and stackSerendip < 2, Priest_Target },
		{ "Greater Heal", health_pct < 0.70 and health_deficiency > (getaverage_heal("Greater Heal") + getaverage_heal("Renew")), Priest_Target },
		{ "Binding Heal", UnitIsUnit(Priest_Target, "player")~=1 and health_deficiency > getaverage_heal("Flash Heal") and playerhealth_deficiency > getaverage_heal("Flash Heal"), Priest_Target },
		
		-- aoe heal
		{ "Circle of Healing", unitsBelow70  > 3, Priest_Target },
		{ "Circle of Healing", unitsBelow70  > 3, "player" },
		{ "Prayer of Healing", unitsBelow50  > 3, "player" },
		{ "Prayer of Healing", unitsBelow50  > 3, Priest_Target },
		
		-- filler
		{ "Heal", health_deficiency > (getaverage_heal("Heal") + getaverage_heal("Renew")), Priest_Target }
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default")