function druid_resto(self)
	local my_mana = UnitMana("player")/UnitManaMax("player")
	local my_hp = UnitHealth("player")/UnitHealthMax("player")
	local tank, tank_hp, tank_focus, tank_bloom_count,tank_bloom_duration
	if UnitExists("focus") then
		tank = "focus"
		tank_hp = UnitHealth(tank)/UnitHealthMax(tank)
		tank_focus = true
		tank_bloom_count = jps.get_buff_stacks(tank,"lifebloom")
		tank_bloom_duration = jps.buff_duration(tank,"lifebloom")
	end
	local spell = nil

	if ub("player","nature's swiftness") then tank_focus = false end

	if my_mana < 0.5 and cd("innervate") == 0 then
		spell = "innervate"
		jps.Target = "player"
	elseif my_hp < 0.7 and cd("barkskin") == 0 then
		spell = "barkskin"
	-- tank healing
	elseif tank_focus and tank_bloom_count < 3 then
		spell = "lifebloom"
		jps.Target = tank
	elseif tank_focus and tank_bloom_count == 3 and tank_bloom_duration < 3 and tank_hp > 60 then
		spell = "lifebloom"
		jps.Target = tank
	elseif IsShiftKeyDown() and cd("wild growth") == 0 then
		spell = "wild growth"
	else
		-- Check for critical (sub-40) raid-members.
		spell = nil
		for unit,hp_table in pairs(jps.RaidStatus) do
			if spell ~= nil then break end
			jps.Target = unit
			local pct = hp_table["hp"]/hp_table["hpmax"]*100
			if (IsSpellInRange("lifebloom",unit) or unit=="player") and pct < 40 then
				if cd("Nature's Swiftness") == 0 then
					spell = "Nature's Swiftness"
				elseif ub("player","nature's swiftness") then
					spell = "Healing Touch"
				elseif (ub(unit,"rejuvenation") or ub(unit,"regrowth")) and cd("swiftmend") == 0 then
					spell = "swiftmend"
				elseif not ub(unit, "regrowth") and jps.LastCast ~= "regrowth" then
					spell = "regrowth"
				else
					spell = "healing touch"
				end
				print(UnitName(unit).." critical - casting "..spell..".")
				return spell
			end
		end
		-- Non-critical updates, this may take some time...
		spell = nil
		for unit,hp_table in pairs(jps.RaidStatus) do
			local pct = hp_table["hp"]/hp_table["hpmax"]*100
			if IsSpellInRange("lifebloom",unit) or unit=="player" then
				if spell ~= nil then break end
				jps.Target = unit
				if pct < 80 and (ub(unit,"rejuvenation") or ub(unit,"regrowth")) and cd("swiftmend") == 0 then
					spell = "swiftmend"
				-- Dispels
				elseif ud(unit,"static disruption") then
					spell = "remove corruption"
				elseif ud(unit,"Consuming Darkness") then
					spell = "remove corruption"
				-- HoTs
				elseif pct < 65 and not ub(unit, "regrowth") and jps.LastCast ~= "regrowth" then
					spell = "regrowth"
				elseif pct < 95 and not ub(unit,"rejuvenation") then
					spell = "rejuvenation"
				-- Heals
				elseif pct < 55 then
					spell = "healing touch"
				elseif pct < 75 then
					spell = "nourish"
				end
			end
		end
	end
	
	return spell
end
