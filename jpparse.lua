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

function parseSpellTable( hydraTable )
	for _, table in pairs(hydraTable) do
		local spell = table[1]
		local conditions = table[2]
		local stopCasting = table[4]
		if type(table[3]) == "string" then jps.Target = table[3]
		else jps.Target = nil end

		-- Special Cases
		-- Nested table
		if spell == "nested" and conditions then
			spell =	parseSpellTable(table[3])

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
				if stopCasting then SpellStopCasting() end
				return spell
			end
		end
	end

	return nil
end
