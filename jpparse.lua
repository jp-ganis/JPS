--[[
	 JPS - WoW Protected Lua DPS AddOn
    Copyright (C) 2011 Jp Ganis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--
-- JPS Priority List Stuff
--jpganis

-- canCast
function ImReallySureICanCastThisShit( spell, unit )
	spell:lower()

	--debug mode
	if jps.Debug and IsControlKeyDown() then return jpd( spell, unit ) end
	
	--
	if unit == nil then unit = "target" end
	local _, spellID = GetSpellBookItemInfo(spell)
	local usable, nomana = IsUsableSpell(spell)

	if not UnitExists(unit) then return false end
	if UnitIsDead(unit) then return false end
	if UnitIsDeadOrGhost(unit) then return false end
	if not usable then return false end
	if jps.cooldown(spell) ~= 0	then return false end
	if nomana then return false end
	if not UnitIsVisible(unit) then return false end
	if not IsSpellKnown(spellID) then return false end
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,unit)==0 then return false end
	if jps[spell] ~= nil and jps[spell] == false then return false end --JPTODO - spell.lower
	
	return true
end

-- canCast debug mode
function jpd( spell, unit )
	if unit == nil then unit = "target" end
	write(spell.." @ "..unit)
	local _, spellID = GetSpellBookItemInfo(spell)
	local usable, nomana = IsUsableSpell(spell)

	write("Unit Exists")
	if not UnitExists(unit) then return false end
	write("Unit Not Dead")
	if UnitIsDead(unit) then return false end
	write("Unit not dead/ghost")
	if UnitIsDeadOrGhost(unit) then return false end
	write("IsUsableSpell()")
	if not usable then return false end
	write("Spell NOT on cd")
	if jps.cooldown(spell) ~= 0	then return false end
	write("Not oom")
	if nomana then return false end
	write("unit visible")
	if not UnitIsVisible(unit) then return false end
	write("spell known")
	if not IsSpellKnown(spellID) then return false end
	write("spell in range")
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,unit)==0 then return false end
	write("jps lookup")
	if jps[spell] ~= nil and jps[spell] == false then return false end
	
	return true
end

-- multiUnitTable
function parseMultiUnitTable( spellTable )
	local spell = spellTable[1]
	local unitFunction = spellTable[2]
	local targets = spellTable[3]
	local conditions = spellTable[4]
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
		local target = nil

		-- conditions default to oncd
		if conditions == nil then conditions = true end

		-- Nested table
		if spell == "nested" and conditions then
			local newTable = spellTable[3]
			spell,target = parseSpellTable( newTable )

		-- Macro
		elseif type(spell) == "table" and spell[1] == "macro" then
			local macroText = spell[2]
			local macroSpell = spell[3]
			local macroTarget = spell[4]
			if macroSpell and ImReallySureICanCastThisShit( macroSpell,macroTarget ) then conditions = conditions end
			if macroTarget then TargetUnit(macroTarget) end
			if conditions then RunMacroText(macroText) return
			else conditions = false end

		-- MultiTarget List
		elseif type(conditions) == "function" then
			spell,target = parseMultiUnitTable( spellTable )
		end

		-- If not already assigned, assign target now.
		if not target and type(spellTable[3]) == "string" then
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
