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

--------------------------
-- LOCALIZATION
--------------------------

local L = MyLocalizationTable

--------------------------
-- Functions CAST
--------------------------

function jps_IsSpellInRange(spell,unit)
	if spell == nil then return false end
	if unit == nil then unit = "target" end 
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end

    -- Using WoW's standard API first, because Tricks of the Trade is bugged when passing it's spell index 
    -- So only going further down the function the spell's that returns nil 
    -- I this returns nil is if the unit is not a valid target for the spell (or you have no target selected)
    local inRange = IsSpellInRange(spellname, unit)

    -- Collecting the Spell GLOBAL SpellID, not to be confused with the SpellID
    -- Matching the Spell Name and the GLOBAL SpellID will give us the Spellbook index of the Spell 
    -- With the Spellbook index, we can then proceed to do a proper IsSpellInRange with the index. 
    if inRange == nil then 
        local myIndex = nil 
        local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
        local booktype = "spell"
        for index = offset+1, numSpells+offset do 
            -- Get the Global Spell ID from the Player's spellbook 
            local spellID = select(2, GetSpellBookItemInfo(index, booktype))
            if spellID and spellname == GetSpellBookItemName(index, booktype) then 
                myIndex = index
                break -- Breaking out of the for/do loop, because we have a match 
            end 
        end 

        -- If the Spell wasn't found, we're checking if we have a Pet Spellbook 
        -- If a Pet Spellbook is found, do the same as above and try to get an Index on the Spell 
        local numPetSpells = HasPetSpells()
        if myIndex == 0 and numPetSpells then 
            booktype = "pet"
            for index = 1, numPetSpells do 
                -- Get the Global Spell ID from the Pet's spellbook 
                local spellID = select(2, GetSpellBookItemInfo(index, booktype))
                if spellID and spellname == GetSpellBookItemName(index, booktype) then 
                    myIndex = index
                    break -- Breaking out of the for/do loop, because we have a match 
                end 
            end 
        end 

        if myIndex then 
            inRange = IsSpellInRange(myIndex, booktype, unit)
        end 
        return inRange
    end 
    return inRange
end 

-- GetSpellInfo -- name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellId or spellName)
-- SpellHasRange(index, "bookType") or SpellHasRange("name") -- hasRange returns 1 if the spell has an effective range. Otherwise nil.
function jps_SpellHasRange(spell)
	if spell == nil then return false end
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end

    local hasRange = SpellHasRange(spellname)

    -- Collecting the Spell GLOBAL SpellID, not to be confused with the SpellID
    -- Matching the Spell Name and the GLOBAL SpellID will give us the Spellbook index of the Spell 
    -- With the Spellbook index, we can then proceed to do a proper IsSpellInRange with the index. 
    if hasRange == nil then 
        local myIndex = nil 
        local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
        local booktype = "spell"
        for index = offset+1, numSpells+offset do 
            -- Get the Global Spell ID from the Player's spellbook 
            local spellID = select(2, GetSpellBookItemInfo(index, booktype))
            if spellID and spellname == GetSpellBookItemName(index, booktype) then 
                myIndex = index
                break -- Breaking out of the for/do loop, because we have a match 
            end 
        end 

        if myIndex then 
            hasRange= SpellHasRange(myIndex, booktype)
        end 
        return hasRange
    end 
    return hasRange
end 

function jps.IsSpellInRange(spell,unit)
	if spell == nil then return false end
	--if jps_IsSpellInRange(spell,unit)~=1 then return false end
	if jps_IsSpellInRange(spell,unit)==0 then return false end
	return true
end

function jps.SpellHasRange(spell)
	if spell == nil then return false end
	if jps_SpellHasRange(spell)~=1 then return false end 
	return true
end

function jps.UnitExists(unit)
	if unit == nil then return false end
	if UnitExists(unit)~=1 then return false end
	if UnitIsVisible(unit)~=1 then return false end
	if UnitIsDeadOrGhost(unit)==1 then return false end
	return true
end

-- UnitInRange(unit) -- returns FALSE if out of range or if the unit is invalid. TRUE if in range
-- information is ONLY AVAILABLE FOR MEMBERS OF THE PLAYER'S GROUP 
-- when not in a party/raid, the new version of UnitInRange returns FALSE for "player" and "pet". The old function returned true.
-- jps.IsSpellKnown(spell) can be use below lvl 90
function jps.canHeal(unit)
	if not jps.UnitExists(unit) then return false end
	if GetUnitName("player") == GetUnitName(unit) then return true end
	if UnitCanAssist("player",unit)~=1 then return false end -- UnitCanAssist(unitToAssist, unitToBeAssisted) return 1 if the unitToAssist can assist the unitToBeAssisted, nil otherwise
	if UnitIsFriend("player",unit)~=1 then return false end -- UnitIsFriend("unit","otherunit") return 1 if otherunit is friendly to unit, nil otherwise. 
	-- PNJ returns 1 with UnitIsFriend -- PNJ returns 1 or nil (Vendors) with UnitCanAssist
	if UnitInVehicle(unit)==1 then return false end  -- inVehicle - 1 if the unit is in a vehicle, otherwise nil
	if jps.PlayerIsBlacklisted(unit) then return false end
	if not select(1,UnitInRange(unit)) then return false end -- return FALSE when not in a party/raid reason why to be true for player GetUnitName("player") == GetUnitName(unit)
	return true
end

-- INVALID IF THE NAMED PLAYER IS NOT A PART OF YOUR PARTY OR RAID -- NEED .."TARGET"
-- JPS.CANDPS IS WORKING ONLY FOR PARTYn..TARGET AND RAIDn..TARGET NOT FOR UNITNAME..TARGET
function jps.canDPS(unit) 
	if not jps.UnitExists(unit) then return false end
	if jps.PvP then  -- do no dmg on players with paladin divine shild or ice block active !!! 
		local iceblock = tostring(select(1,GetSpellInfo(45438))) --  45438 "Ice Block"
		local divineshield = tostring(select(1,GetSpellInfo(642))) -- 642 "Divine Shield"
		if jps.buff(divineshield,unit) then return false end
		if jps.buff(iceblock,unit) then return false end
	end
	if (GetUnitName(unit) == L["Training Dummy"]) or (GetUnitName(unit) == L["Raider's Training Dummy"]) then return true end	
	if UnitCanAttack("player", unit)~=1 then return false end-- UnitCanAttack(attacker, attacked) return 1 if the attacker can attack the attacked, nil otherwise.
	if UnitIsEnemy("player",unit)~=1 then return false end -- WARNING a unit is hostile to you or not Returns either 1 ot nil -- Raider's Training returns nil with UnitIsEnemy
	if jps.PlayerIsBlacklisted(unit) then return false end -- WARNING Blacklist is updated only when UNITH HEALTH occurs 
	if not jps.IsSpellInRange(jps.HarmSpell,unit) then return false end
	return true
end

function jpd( spell, unit )
	if unit == nil then unit = "target" end
	write("|cffa335ee"..spell.." @ "..unit)
	local _, spellID = GetSpellBookItemInfo(spell)
	local usable, nomana = IsUsableSpell(spell)

	if jps.UnitExists(unit) == 0 then 
		write("Unit Exists test failed");
		return false end
	end
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
	if jps.SpellHasRange(spell)==1 and jps.IsSpellInRange(spell,unit)==0 then
		write("Failed Range test")
		return false end
	if jps[spell] ~= nil and jps[spell] == false then
		write("Failed JPS Lookup test")
		return false end
	write("Passed all tests")
	return true
end


function jps.canCast(spell,unit)
	if unit == nil then unit = "target" end
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if jps.PlayerIsBlacklisted(unit) then return false end -- ADDITION jps.PlayerIsBlacklisted(unit) in CANCAST
	if not jps.UnitExists(unit) then return false end
	if spellname == nil then  return false end
	spellname = string.lower(spellname)

	if(getSpellStatus(spellname ) == 0) then return false end -- NEW
	
	local usable, nomana = IsUsableSpell(spellname) -- usable, nomana = IsUsableSpell("spellName" or spellID)
	if not usable then return false end
	if nomana then return false end
	if (jps.cooldown(spellname)~=0) then return false end
	if jps.SpellHasRange(spell) and not jps.IsSpellInRange(spell,unit) then return false end
	if jps[spell] ~= nil and jps[spell] == false then return false end
	if jps.Debug then jpd(spell, unit) end
	return true
end
-- local isKnown = IsPlayerSpell(spellID) true if the player can cast this spell, false otherwise.
-- if not isKnown then then return false end

function jps.spellNeedSelect(spell)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	-- "Death and Decay" 43265 -- DK
	-- "Mass Dispel" 32375 -- Priest
	-- "Flamestrike" 2120 -- Mage
	-- "Rain of Fire" 104233 -- Mage
	-- "Dizzying Haze" 118022 -- Brewmaster
	-- "Light's Hammer" 114158 -- Paladin
	-- "Healing Rain" 73921 -- Shaman
	-- "wild mushroom" 88747 -- Druid
	local tableSelect = {32375,43265,2120,104233,118022,114158,73921,88747}  
	for i,j in ipairs (tableSelect) do
		if spellname == tostring(select(1,GetSpellInfo(j))) then return true end 
	end
	
return false
end

function jps.Cast(spell)  -- "number" "string"
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if jps.Target==nil then jps.Target = "target" end
	if not jps.Casting then jps.LastCast = spellname end
	
	CastSpellByName(spellname,jps.Target) -- CastSpellByID(spellID [, "target"])
	
	if jps.spellNeedSelect(spellname) then
		jps.groundClick()
	end

	if jps.IconSpell ~= spellname then
		jps.set_jps_icon(spellname)
		if jps.Debug then write(spellname,"|cff1eff00",jps.Target,"|cffffffff",jps.Message) end
	end
	
	jps.LastTarget = jps.Target
	jps.Target = nil
	jps.Message = nil
	jps.ThisCast = nil
end

-------------------------
-- SPELL CONFIG METHODS
-------------------------
-- isKnown = IsSpellKnown(spellID [, isPet])
-- isKnown - True if the player (or pet) knows the given spell. false otherwise

function setSpellStatus(spell, status)
	spell = string.lower(spell)
    jps.spellConfig[spell] = status
end

function getSpellStatus(spell)

    spell = spell:lower() --spell = string.lower(spell)
    local spellConfig = jps.spellConfig[spell]
    if(spellConfig == nil) then
       setSpellStatus(spell, 1)
       jps.addSpellCheckboxToFrame(spell)
       return 1
    else
       return jps.spellConfig[spell]
    end
end

-------------------------
-- PARSE
-------------------------

function parseMultiUnitTable( spellTable )
	local spell = spellTable[1]
	local unitFunction = spellTable[2]
	local targets = spellTable[3]
	local message = spellTable[4]
	local sirenTable = {}

	for _, unit in pairs(targets) do
		local unitTable = {}
		table.insert( unitTable, 1, spell )
		table.insert( unitTable, 2, unitFunction(unit) )
		table.insert( unitTable, 3, unit )
		table.insert( unitTable, 4, message..unit )  -- WARNING the table need a valid massage to concatenate in parseMultiUnitTable
		table.insert( sirenTable, unitTable )
	end

	return parseSpellTable(sirenTable)
end

function conditionsMatched(spell,conditions)
	-- nil
	if spell == nil then
		return false
	-- nil
	elseif conditions == nil then
		return true
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
	local spell = nil
	local conditions = nil
	local target = nil
	local message = nil

	for _, spellTable in pairs(hydraTable) do
		spell = spellTable[1] 
		conditions = spellTable[2]
		target = spellTable[3]
		message = spellTable[4]
		if jps.Message ~= message then jps.Message = message end

		-- NESTED TABLE
		if spell == "nested" and conditions then
			local newTable = spellTable[3]
			spell,target = parseSpellTable( newTable )

		-- MACRO -- BE SURE THAT CONDITION TAKES CARE OF CANCAST -- TRUE or FALSE -- NOT NIL
		elseif type(spell) == "table" and spell[1] == "macro" and conditions then
			local macroText = spell[2]
			local macroTarget = spell[3]
			-- Workaround for TargetUnit is still PROTECTED despite goblin active
 			if jps.UnitExists(macroTarget) then RunMacroText("/target "..macroTarget) end

			if conditions and type(macroText) == "string" then
				local macroSpell = macroText
				if string.find(macroText,"%s") == nil then -- {"macro","/startattack"}
					macroSpell = macroText
				else 
					macroSpell = select(3,string.find(macroText,"%s(.*)")) -- {"macro","/cast Sanguinaire"}
				end
				RunMacroText(macroText)
				if jps.Debug then macrowrite(macroSpell,"|cff1eff00",macroTarget,"|cffffffff",jps.Message) end
			end
			
			if conditions and type(macroText) == "table" then
				for _,sequence in ipairs (macroText) do
					local spellname = tostring(select(1,GetSpellInfo(sequence)))
					if jps.canCast(spellname,macroTarget) then
						local macroText = "/cast "..spellname
						RunMacroText(macroText)
						if jps.Debug then macrowrite(spellname,"|cff1eff00",macroTarget,"|cffffffff",jps.Message) end
					end
				end
			end
			
		-- MultiTarget List -- { { "func" , spell , function_unit }, function_conditions , table_unit , message }
		elseif type(spell) == "table" and spell[1] == "func" and conditions then
			local newTable = { spell[2] , spell[3] , target , message}
			spell,target = parseMultiUnitTable(newTable)
			
		-- MultiTarget List -- { spell , function_unit , table_unit }
		elseif type(conditions) == "function" and type(target) == "table" then
			spell,target = parseMultiUnitTable(spellTable)
		end

		-- If not already assigned, assign target now.
		if not target and type(spellTable[3]) == "string" then
			target = spellTable[3]
		end

		-- Return spell if conditions are true and spell is castable.
		if type(spell) ~= "table" and conditionsMatched(spell,conditions) and jps.canCast(spell,target) then
			-- jps.Target = target
			-- jps.ThisCast = spell
			return spell,target 
		end
	end
	return nil
end

-------------------------
-- MULTIPLE ROTATIONS
-------------------------

function jps.RotationActive(spellTable)
-- GET The Rotation Name in dropDown Menu
	for i,j in ipairs (spellTable) do
		if spellTable[i]["ToolTip"] ~= nil then
			jps.MultiRotation = true
			jps.ToggleRotationName[i] = spellTable[i]["ToolTip"]
		end
	end

	if jps.MultiRotation then
		jps.Tooltip = spellTable[jps.Count]["ToolTip"]
		return spellTable[jps.Count]
	else
		return spellTable
	end
end
