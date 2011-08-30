-- JPS Priority List Stuff
--jpganis
function ImReallySureICanCastThisShit( spell, unit )
	if unit == nil then unit = "target" end
	local _, spellID = GetSpellBookItemInfo(spell)
	local usable, nomana = IsUsableSpell(spell)

	if nomana then return false end
	if not usable then return false end
	if not UnitIsVisible(unit) then return false end
	if not IsSpellKnown(spellID) then return false end
	if jps.cooldown(spell) ~= 0	then return false end
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,unit)==0 then return false end
	
	return true
end

function parseSpellTable( hydra_table )
	for _, table in pairs(hydra_table) do
		local spell = table[1]
		local conditions = table[2]
		if type(table[3]) == "string" then jps.Target = table[3]
		else jps.Target = nil end

		-- Special Cases
		-- Nested table
		if spell == "nested" and conditions then
			local nestedSpell =	parseSpellTable(table[3])
			if nestedSpell then spell = nestedSpell
			else spell = nil end
		-- Just refresh debuff/buff when it drops off.
		elseif conditions == "refresh" then
			if IsHarmfulSpell(spell) then
				conditions = not jps.debuff( spell,jps.Target )
			else
				conditions = not jps.buff( spell,jps.Target )
			end
		-- onCD, instead of just "true"
		elseif conditions == "onCD" then
			conditions = true
		end

		-- Otherwise:
		-- Return spell if conditions are true.
		if conditions and spell then
			if ImReallySureICanCastThisShit( spell,jps.Target ) then
				return spell
			end
		end
	end

	return nil
end
