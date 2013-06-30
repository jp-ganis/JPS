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
-- GetSpellInfo -- name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellId or spellName)
-- IsHarmfulSpell(spellname) -- IsHelpfulSpell(spellname)) returns 1 or nil -- USELESS SOMES SPELLS RETURNS NIL AS OUBLI, SPIRIT SHELL
-- IsSpellInRange(spellID, spellType, unit) -- spellType String, "spell" or "pet"
-- IsSpellInRange(spellName, unit) -- returns 0 if out of range, 1 if in range, or nil if the unit is invalid.
function jps_IsSpellInRange(spell,unit)
	if spell == nil then return false end
	if unit == nil then unit = "target" end 
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end

    local inRange = IsSpellInRange(spellname, unit)
 
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
-- Collecting the Spell GLOBAL SpellID, not to be confused with the SpellID
-- Matching the Spell Name and the GLOBAL SpellID will give us the Spellbook index of the Spell 
-- With the Spellbook index, we can then proceed to do a proper IsSpellInRange with the index.
function jps_SpellHasRange(spell)
	if spell == nil then return false end
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end

    local hasRange = SpellHasRange(spellname)

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
	if jps.PvP then 
		local iceblock = tostring(select(1,GetSpellInfo(45438))) -- "Bloc de glace" 45438 "Ice Block"
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

function jps.canCast(spell,unit)
	if unit == nil then unit = "target" end
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if jps.PlayerIsBlacklisted(unit) then return false end -- ADDITION jps.PlayerIsBlacklisted(unit) in CANCAST
	if not jps.UnitExists(unit) then return false end
	if spellname == nil then  return false end
	spellname = string.lower(spellname)

	--if jps.Debug then jps_canCast_debug(spell,unit) end

	if(getSpellStatus(spellname ) == 0) then return false end -- NEW
	
	local usable, nomana = IsUsableSpell(spellname) -- usable, nomana = IsUsableSpell("spellName" or spellID)
	if not usable then return false end
	if nomana then return false end
	if (jps.cooldown(spellname)~=0) then return false end
	if jps.SpellHasRange(spell) and not jps.IsSpellInRange(spell,unit) then return false end
	if jps[spell] ~= nil and jps[spell] == false then return false end
	return true
end

----------------------
-- CAST
----------------------

function jps.spell_need_select(spell)
	local spellname = nil
	if type(spell) == "string" then spellname = string.lower(spell) end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	-- "Death and Decay" 43265 -- DK
	-- "Mass Dispel" 32375 -- Priest
	-- "Power Word: Barrier" 62618 -- Priest
	-- "Flamestrike" 2120 -- Mage
	-- "Rain of Fire" 104233 -- Mage
	-- "Dizzying Haze" 118022 -- Brewmaster
	-- "Light's Hammer" 114158 -- Paladin
	-- "Healing Rain" 73921 -- Shaman
	-- "wild mushroom" 88747 -- Druid
	-- "Explosive Trap" 13813 - Hunter
	-- "Ice Trap" 13809 - Hunter
	-- "Snake Trap" 34600 - Hunter
	-- "Freezing Trap" 1499 - Hunter
	-- "Summon Jade Serpent Statue" - 115313 Monk
	-- "Healing Sphere" - 115460 Monk
	-- "demoralizing banner" - 114203 warrior
	-- "mocking banner" - 114192 warrior 
	-- "heroic leap" - 6544 warrior
	-- "Freeze" - 33395 Frost Mage
	-- "Rune Of Power" 116011- Mage
	-- "Rain of Fire" 5740 -- Warlock
	-- "Lightwell" 724 - Priest
	-- "Holy Word: Sanctuary" 88685 - Priest

	local tableSelect = {88685,724,32375,43265,62618,2120,104233,118022,114158,73921,88747, 13813, 13809, 34600, 1499, 115313, 115460, 114203, 114192, 6544, 33395, 116011, 5740}
	for i,j in ipairs (tableSelect) do
		if spellname == string.lower(tostring(select(1,GetSpellInfo(j)))) then return true end 
	end
return false
end

function jps.Cast(spell)  -- "number" "string"
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if jps.Target==nil then jps.Target = "target" end
	if not jps.Casting then jps.LastCast = spellname end
	
	if jps.spell_need_select(spellname) then jps.groundClick() end
	CastSpellByName(spellname,jps.Target) -- CastSpellByID(spellID [, "target"])
	
	if (jps.IconSpell ~= spellname) or (jps.Target ~= jps.LastCast) then
		jps.set_jps_icon(spellname)
		if jps.Debug then write(spellname,"|cff1eff00",jps.Target,"|cffffffff",jps.Message) end
	end
	
	jps.LastTarget = jps.Target
	jps.LastTargetGUID = UnitGUID(jps.Target)
	jps.Target = nil
	jps.Message = nil
	jps.ThisCast = nil
end

function jps.isRecast(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if unit==nil then unit = "target" end
	
	return jps.LastCast==spellname and UnitGUID(unit)==jps.LastTargetGUID
end
----------------------
-- DEBUG MODE
----------------------`

function jps_canHeal_debug(unit)
	if not jps.UnitExists(unit) then write("not Unit") return false end
	if GetUnitName("player") == GetUnitName(unit) then write("Player") return true end
	if UnitExists(unit)~=1 then write("not Exists") return false end
	if UnitIsVisible(unit)~=1 then write("not Visible") return false end
	if UnitIsDeadOrGhost(unit)==1 then write("Dead") return false end
	if UnitCanAssist("player",unit)~=1 then write("not Friend") return false end
	if UnitInVehicle(unit)==1 then write("in Vehicle") return false end
	if jps.PlayerIsBlacklisted(unit) then write("Blacklist") return false end
	if not select(1,UnitInRange(unit)) then write("not inRange") return false end
	write("Passed all tests canHeal".."|cffa335ee"..unit)
	return true
end

function jps_canCast_debug(spell,unit) -- NEED A SPELLNAME
	if spell == nil then write("spell is nil") return false end
	if not jps.UnitExists(unit) then write("unit is not a valid target or nil") return false end
	
	write("|cffa335ee"..spell.." @ "..unit)

	local usable, nomana = IsUsableSpell(spell) -- IsUsableSpell("spellName" or spellID)
	if not usable then write(spell.." = Failed IsUsableSpell test") return false end
	if nomana  then write(spell.." = Failed Mana test") return false end
	if jps.cooldown(spell)~=0 then write("Failed Cooldown test") return false end
	if jps_SpellHasRange(spell)~=1 then write(spell.." = Failed SpellHasRange test") return false end

	if jps_IsSpellInRange(spell,unit)~=1 then write(spell.." = Failed SpellinRange test") return false end
	write("Passed all tests canCast ".."|cffa335ee"..spell)
	return true
end

-------------------------
-- SPELL CONFIG METHODS
-------------------------
-- isKnown = IsSpellKnown(spellID [, isPet])
-- isKnown - True if the player (or pet) knows the given spell. false otherwise

function setSpellStatus(spell, status)
	spell = string.lower(spell)
    jps.spellConfig[jps.Spec][spell] = status
end

function getSpellStatus(spell)

    spell = spell:lower() --spell = string.lower(spell)
    local spellConfig = jps.spellConfig[jps.Spec][spell]
    if(spellConfig == nil) then
       setSpellStatus(spell, 1)
       jps.addSpellCheckboxToFrame(spell)
       return 1
    else
       return jps.spellConfig[jps.Spec][spell]
    end
end

-------------------------
-- PARSE
-------------------------

--[[ -- MultiTable
function jps.IsCastingPoly( unit )
	if ... then return false end
	return true
end
parseMultiUnitTable( { "shadow word: death", jps.IsCastingPoly, {"arena1","arena2","arena3"} } )

the code is equivalent to:

parseSpellTable(
   {
      { "shadow word: death", jps.IsCastingPoly("arena1") , "arena1" },
      { "shadow word: death", jps.IsCastingPoly("arena2") , "arena2" },
      { "shadow word: death", jps.IsCastingPoly("arena3") , "arena3" },
   }
)
--]]

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
		-- WARNING THE TABLE NEED A VALID MASSAGE TO CONCATENATE IN PARSEMULTIUNITTABLE
		table.insert( unitTable, 4, message..unit )  
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
    if jps.firstInitializingLoop == true then return nil,"target" end
	local spell = nil
	local conditions = nil
	local target = nil
	local message = nil

	for _, spellTable in pairs(hydraTable) do
		spell = spellTable[1] 
		conditions = spellTable[2]
		target = spellTable[3]
		if not target then target = "target" end
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
 			local changeTargets = jps.UnitExists(macroTarget)
			if changeTargets then jps.Macro("/target "..macroTarget) end
 			
			if conditions and type(macroText) == "string" then
				local macroSpell = macroText
				if string.find(macroText,"%s") == nil then -- {"macro","/startattack"}
					macroSpell = macroText
				else 
					macroSpell = select(3,string.find(macroText,"%s(.*)")) -- {"macro","/cast Sanguinaire"}
				end
				jps.Macro(macroText)
				if jps.Debug then macrowrite(macroSpell,"|cff1eff00",macroTarget,"|cffffffff",jps.Message) end
			end
		
			-- CASTSEQUENCE WORKS ONLY FOR {INSTANT CAST, SPELL}
			-- better than "#showtooltip\n/cast Frappe du colosse\n/cast Sanguinaire"
			-- because I can check the spell with jps.canCast
			-- {"macro",{109964,2060},player}
			if conditions and type(macroText) == "table" then
				for _,sequence in ipairs (macroText) do
					local spellname = tostring(select(1,GetSpellInfo(sequence)))
					if jps.canCast(spellname,macroTarget) then
						local macroText = "/cast "..spellname
						jps.Macro(macroText)
						if jps.Debug then macrowrite(spellname,"|cff1eff00",macroTarget,"|cffffffff",jps.Message) end
					end
				end
			end
			if changeTargets and jps.isHealer then jps.Macro("/targetlasttarget") end
			
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
			-- if jps.Debug then print("|cffff8000Spell","|cffffffff",tostring(select(1,GetSpellInfo(spell)))) end 
			return spell,target 
		end
	end
	return nil
end

-------------------------
-- MULTIPLE ROTATIONS
-------------------------

function jps.RotationActive(spellTable)
	local countRotations = 0

	for i,j in ipairs (spellTable) do
		if spellTable[i]["ToolTip"] ~= nil then
			jps.MultiRotation = true
			countRotations = countRotations+1 
			jps.ToggleRotationName[i] = spellTable[i]["ToolTip"]
		end
	end

	if jps.initializedRotation == false then
		if countRotations > 1 and jps.getConfigVal("Rotation Dropdown Visible") == 1 then 
			rotationDropdownHolder:Show()
			UIDropDownMenu_SetText(DropDownRotationGUI, jps.ToggleRotationName[1])
		else  
			rotationDropdownHolder:Hide() 
		end
		jps.firstInitializingLoop = true
	end

	jps.initializedRotation = true

	if jps.MultiRotation then
		jps.Tooltip = spellTable[jps.Count]["ToolTip"]
		return spellTable[jps.Count]
	else
		return spellTable
	end
end