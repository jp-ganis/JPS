-- JPS Priority List Stuff
--jpganis
function ImReallySureICanCastThisShit(spell,unit)
	if unit == nil then unit = "target" end
	local _, spellID = GetSpellBookItemInfo(spell)
	
	if not UnitIsVisible(unit) then return false end
	if not IsSpellKnown(spellID) then return false end
	if jps.getCooldown(spell) ~= 0	then return false end
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,unit)==0 then return false end
	
	return true
end

function parseSpellTable(hydra_table)
	for index, table in pairs(hydra_table) do
		spell = table[1]
		conditions = table[2]

		-- Special Cases
		-- Just refresh debuff/buff when it drops off.
		if conditions == "refresh" then
			if IsHarmfulSpell(spell) then
				conditions = not jps.debuff(spell)
			else
				conditions = not jps.buff(spell)
			end
		-- Refresh on target.
		elseif conditions == "refreshTarget" then
			if not jps.buff(spell,"target") then
				conditions = not jps.buff(spell,"target")
			end
		-- onCD, instead of just "true"
		elseif conditions == "onCD" then
			conditions = true
		end

		-- Return
		if conditions and ImReallySureICanCastThisShit(spell) then
			return spell
		end
	end

	return nil
end
