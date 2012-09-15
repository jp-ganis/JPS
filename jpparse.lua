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
	if jps.Debug then return jpd( spell, unit ) end
	
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
	--if not IsSpellKnown(spellID) then return false end  --still buggy in wow api (IsPlayerSpell doesnt worked)

    if(getSpellStatus(spell) == 0) then return false end
	
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,unit)==0 then return false end
	if jps[spell] ~= nil and jps[spell] == false then return false end --JPTODO - spell.lower

	return true
end

-- spell Config Methods
function setSpellStatus(spell, status)
    spell:lower()
    jps.spellConfig[spell] = status
end

function getSpellStatus(spell)
    spell:lower()
    local spellConfig = jps.spellConfig[spell]
    if(spellConfig == nil) then
       setSpellStatus(spell, 1)
       addSpellCheckboxToFrame(spell)
       return 1
    else
       return jps.spellConfig[spell]
    end
end

function jps.addRotations(rotationTable)
    if(type(rotationTable) ~= "table") then return false end
    for key, spellTable in pairs(rotationTable) do
        spellTable["rotation"] = nil
        table.insert(jps.rotations, spellTable)    
    end
    return true
end

function jps.getRotations() 
    return jps.rotations
end

function jps.initRotations() 
    if( not jps.rotationsInitialized ) then
       local rotations = jps.Rotation(self,"init")
       if(rotations) then
           if(jps.addRotations(rotations)) then
              jps.rotationsInitialized = true
              jps.addRotationDropdown()
           end
       end
    end
end

function jps.setActiveRotation(pos)
    jps["useRotation"] = tonumber(pos)
 end

function jps.getActiveRotation()
    local rotationID = jps["useRotation"]
    local rotationTable = jps.rotations[rotationID]
    if(rotationTable) then
        rotationTable.key = rotationID
        return rotationTable
    else 
        return nil
    end
end

function jps.getActiveRotationKey() 
    return jps["useRotation"]
end
-- canCast debug mode
function jpd( spell, unit )
	if unit == nil then unit = "target" end
	write("|cffa335ee"..spell.." @ "..unit)
	local _, spellID = GetSpellBookItemInfo(spell)
	local usable, nomana = IsUsableSpell(spell)

	if not UnitExists(unit) then
		write("Failed UnitExists test")
		return false end
	if UnitIsDead(unit) then
		write("Failed UnitIsDead test")
		return false end
	if UnitIsDeadOrGhost(unit) then
		write("Failed UnitIsDeadOrGhost test")
		return false end
    if jps.spellConfig[spell] == 0 then
         write("spell is not actived")
         return false end
	if not usable then
		write("Failed IsUsableSpell test")
		return false end
	if jps.cooldown(spell) ~= 0 then
		write("Failed Cooldown test")
		return false end
	if nomana  then
		write("Failed Mana test")
		return false end
	if not UnitIsVisible(unit)  then
		write("Failed Visible test")
		return false end
	--[[if not IsSpellKnown(spellID)  then
		write("Failed IsSpellKnown test")
		return false end
		still buggy in wow API , IsPlayerSpell doesnt worked
    ]]--
	if SpellHasRange(spell)==1 and IsSpellInRange(spell,unit)==0 then
		write("Failed Range test")
		return false end
	if jps[spell] ~= nil and jps[spell] == false then
		write("Failed JPS Lookup test")
		return false end
	write("Passed all tests")
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
	if not spell then
		return false
	
	-- nil
	elseif conditions == nil then
		return true

	-- onCD
	elseif conditions == "onCD" then
		return true

	-- refresh
	elseif conditions == "refresh" then
		if IsHarmfulSpell(spell) then return not jps.debuff( spell )
		else return not jps.buff( spell ) end

	-- otherwise
	else
		return conditions
	end
end
	

-- Pick a spell from a priority table.
function parseSpellTable( dataTable )
	local spell,conditions,target,hydraTable = nil
	
	if(dataTable[jps.getActiveRotationKey()]["rotation"] ~= nil and jps.rotationsInitialized) then -- we have more than one rotation, pick the active
        hydraTable = dataTable[jps.getActiveRotationKey()]["rotation"]
    else 
        hydraTable = dataTable
	end
	for _, spellTable in pairs(hydraTable) do
		spell = spellTable[1]
		conditions = spellTable[2]
		target = nil

		-- Nested table
		if spell == "nested" and conditions then
			local newTable = spellTable[3]
			spell,target = parseSpellTable( newTable )

		-- Macro
		elseif type(spell) == "table" and spell[1] == "macro" then
			local macroText = spell[2]
			local macroSpell = spell[3]
			local macroTarget = spell[4]
			-- if macroTarget then TargetUnit(macroTarget) end -- TargetUnit is PROTECTED despite goblin active
			if (macroSpell and ImReallySureICanCastThisShit( macroSpell,macroTarget )) then
				conditions = conditionsMatched(  macroSpell, conditions )
			elseif conditions == nil then 
				conditions = true
			end
			if conditions then RunMacroText(macroText) return end

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
