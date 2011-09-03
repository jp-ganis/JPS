-- JPS Priority List Stuff
--jpganis

-- canCast
function ImReallySureICanCastThisShit( spell, unit )
	if unit == nil then unit = "target" end
	local _, spellID = GetSpellBookItemInfo(spell)
	local usable, nomana = IsUsableSpell(spell)

	if nomana then return false end
	if not usable then return false end
	if UnitIsDead(unit) then return false end
	if UnitIsDeadOrGhost(unit) then return false end
	if not UnitIsVisible(unit) then return false end
	if jps.cooldown(spell) ~= 0	then return false end
	if not IsSpellKnown(spellID) then return false end
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,unit)==0 then return false end
	
	return true
end

-- multiUnitTable
function parseMultiUnitTable( spellTable )
	local spell = spellTable[1]
	local unitFunction = spellTable[2]
	local targets = spellTable[3]
	local stopCasting = spellTable[4]
	local target = nil
	local sirenTable = {}

	for _, unit in pairs(targets) do
		local unitTable = {}
		table.insert( unitTable, 1, spell )
		table.insert( unitTable, 2, unitFunction(unit) )
		table.insert( unitTable, 3, unit )
		table.insert( unitTable, 4, stopCasting )

		table.insert( sirenTable, unitTable )
	end

	return parseSpellTable( sirenTable )
end

-- conditionsMatched
function conditionsMatched( spell, conditions )
	-- nil
	if not spell or not conditions then
		return false

	-- refresh
	elseif conditions == "refresh" then
		if IsHarmfulSpell(spell) then return not jps.debuff( spell )
		else return not jps.buff( spell ) end

	-- onCD
	elseif conditions == "onCD" then
		return true

	-- otherwise
	else
		return conditions

	end
end
	

-- Pick a spell from a priority table.
function parseSpellTable( hydraTable )
	for _, spellTable in pairs(hydraTable) do
		local spell = spellTable[1]
		local conditions = spellTable[2]
        local stopCasting = spellTable[4]
		local target = nil

		-- Nested table
		if spell == "nested" and conditions then
			local newTable = spellTable[3]
			spell,target = parseSpellTable( newTable )

		-- MultiTarget List
		elseif type(conditions) == "function" then
			spell,target = parseMultiUnitTable( spellTable )
		end

		-- If not already assigned, assign target now.
		if not target then
			target = spellTable[3] end

		-- Return spell if conditions are true and spell is castable.
		if conditionsMatched( spell, conditions ) and ImReallySureICanCastThisShit( spell,target ) then

			if stopCasting then SpellStopCasting() end
			jps.Target = target
			return spell,target

		end
	end

	return nil
end
