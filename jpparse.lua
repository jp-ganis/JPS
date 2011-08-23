-- JPS Priority List Stuff
--jpganis
function ImReallySureICanCastThisShit(spell)
	local target = jps.Target
	if target == nil then target = "target" end
	local _, spellID = GetSpellBookItemInfo(spell)
	
	if not IsSpellKnown(spellID) then return false end
	if jps.getCooldown(spell) ~= 0	then return false end
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,target)==0 then return false end
	
	return true
end

function parseSpellTable(hydra_table)
	for index, table in pairs(hydra_table) do
		spell = table[1]
		conditions = table[2]

		if conditions and ImReallySureICanCastThisShit(spell) then
			return spell
		end
	end

	return nil
end
