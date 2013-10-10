--[[[
@module Rotation Registry
@description 
Rotations are stored in a central registry - each class/spec combination can have multiple Rotations.
Most of the rotations are registered on load, but you can also (un)register Rotations during runtime.
You could even outsource your rotations to a separate addon if you want to.
]]--
local pveRotations = {}
local pvpRotations = {}
local activeRotation = 1

local classNames = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK", "DRUID" }

local specNames = {}
specNames[1] = {"ARMS","FURY","PROTECTION"}
specNames[2] = {"HOLY","PROTECTION","RETRIBUTION"}
specNames[3] = {"BEASTMASTERY","MARKSMANSHIP","SURVIVAL"}
specNames[4] = {"ASSASSINATION","COMBAT","SUBTLETY"}
specNames[5] = {"DISCIPLINE","HOLY","SHADOW"}
specNames[6] = {"BLOOD","FROST","UNHOLY"}
specNames[7] = {"ELEMENTAL","ENHANCEMENT","RESTORATION"}
specNames[8] = {"ARCANE","FIRE","FROST"}
specNames[9] = {"AFFLICTION","DEMONOLOGY","DESTRUCTION"}
specNames[10] = {"BREWMASTER","MISTWEAVER","WINDWALKER"}
specNames[11] = {"BALANCE","FERAL","GUARDIAN","RESTORATION"}

local function classToNumber(class)
    if type(class) == "string" then
        className = string.upper(class)
        for k, v in ipairs(classNames) do
            if v == className then return k end
        end
    elseif type(class) == "number" then
        if classNames[class] then return class end
    end
    return nil
end

local function specToNumber(classId, spec)
    if not specNames[classId] then return nil end
    if type(spec) == "string" then
        specName = string.upper(spec)
        for k, v in ipairs(specNames[classId]) do
            if v == specName then return k end
        end
    elseif type(spec) == "number" then
        if specNames[classId][class] then return class end
    end
    return nil
end

local function toKey(class,spec)
    local classId = classToNumber(class)
    if not classId then return 0 end
    local specId = specToNumber(classId, spec)
    if not specId then return 0 end
    if classId < 1 or classId > 11 then return 0 end
    if classId < 11 and specId > 3 then return 0 end
    if classId == 11 and specId > 4 then return 0 end
    return classId * 10 + specId
end

local function getCurrentKey()
    _,_,classId = UnitClass("player")
    specId = GetSpecialization() or 0
    return classId * 10 + specId
end

local function addRotationToTable(rotations,rotation)
    for k,v in pairs(rotations) do
        if v.tooltip == rotation.tooltip then
            rotations[k] = rotation
            return
        end
    end
    table.insert(rotations, rotation)
end

local function tableCount(rotationTable, key)
    if not rotationTable[key] then return 0 end
    return table.getn(rotationTable[key])
end

--[[[ Internal function: Allows the DropDown to change the active rotation ]]--
function jps.setActiveRotation(idx)
    local maxCount = 0
    if jps.PvP then
        maxCount = tableCount(pvpRotations, getCurrentKey())
    else
        maxCount = tableCount(pveRotations, getCurrentKey())
    end
    if idx < 1 or idx > maxCount then idx = 1 end
    activeRotation = idx
end

--[[[
@function jps.registerRotation
@description 
Registers the given Rotation. If you register more than one Rotation per Class/Spec you will get a Drop-Down Menu where you can
choose your Rotation.
@param class Uppercase english classname or <a href="http://www.wowpedia.org/ClassId">Class ID</a>
@param spec Uppercase english spec name (no abbreviations!) or spec id
@param fn Rotation function
@param tooltip Unique Name for this Rotation
@param pve [i]Optional:[/i] [code]True[/code] if this should be registered as PvE rotation else [code]False[/code] - defaults to  [code]True[/code]
@param pvp [i]Optional:[/i] [code]True[/code] if this should be registered as PvP rotation else [code]False[/code] - defaults to  [code]True[/code]
@param config [i]Optional:[/i] Key/Value Pair Table which contains Config which can be used in your rotation #see:jps.getRotationValue - defaults to [code]{}[/code]
]]--
function jps.registerRotation(class,spec,fn,tooltip,pve,pvp,config)
    local key = toKey(class, spec)
    if pve==nil then pve = true end
    if pvp==nil then pvp = true end
    if config== nil then config = {} end
    if pvp and not pvpRotations[key] then pvpRotations[key] = {} end
    if pve and not pveRotations[key] then pveRotations[key] = {} end
    local rotation = {tooltip = tooltip, getSpell = fn, config = config}
    if pvp then addRotationToTable(pvpRotations[key], rotation) end
    if pve then addRotationToTable(pveRotations[key], rotation) end
    jps.resetRotationTable()
end


--[[[ Internal function: Resets the active Rotation, e.g. if the drop down was changed ]]--
function jps.resetRotationTable()
    jps.initializedRotation = false
    jps.setActiveRotation(activeRotation)
    jps.activeRotation()
end

--[[[ Debug Function - prints all Rotations sorted by class and spec ]]--
function jps.printRotations()
    for ci,class in ipairs(classNames) do
        local msg = class .. ": "
        for si,spec in ipairs(specNames[ci]) do
            local key = toKey(class, spec)
            local pveCount = tableCount(pveRotations,key)
            local pvpCount = tableCount(pvpRotations,key)
            msg = msg .. spec .. "(PvE " .. pveCount .. " / PvP " .. pvpCount .. ") "
        end
        print(msg)
    end
end

--[[[
@function jps.unregisterRotation
@description 
Unregister the Rotation with the given tooltip. You can choose to only unregister the rotation for PvE or PvP.
@param class Uppercase english classname or <a href="http://www.wowpedia.org/ClassId">Class ID</a>
@param spec Uppercase english spec name (no abbreviations!) or spec id
@param tooltip Name of the Rotation to unregister
@param pve [i]Optional:[/i] [code]True[/code] if this should only be unregistered from the PvE rotations else [code]False[/code] - defaults to  [code]True[/code]
@param pvp [i]Optional:[/i] [code]True[/code] if this should only be unregistered from the PvP rotations else [code]False[/code] - defaults to  [code]True[/code]
]]--
function jps.unregisterRotation(class,specId,tooltip,pve,pvp)
    local key = toKey(class, specId)
    if pve==nil then pve = true end
    if pvp==nil then pvp = true end
    if pve and pveRotations[key] then 
    	for k,v in pairs(pveRotations[key]) do
        	if v.tooltip == tooltip then
            	table.remove(pveRotations[key], k)
            break end
    	end
    end
    if pvp and pvpRotations[key] then
    	for k,v in pairs(pvpRotations[key]) do
        	if v.tooltip == tooltip then
            	table.remove(pvpRotations[key], k)
            break end
    	end
    end
end

--[[[
@function jps.registerStaticTable
@description
Short-hand function for registering static spell tables which usually only have a function with [code]return parseStaticSpellTable(spellTable)[/code].
For mor info look at #see:jps.registerRotation.
@param class Uppercase english classname or <a href="http://www.wowpedia.org/ClassId">Class ID</a>
@param spec Uppercase english spec name (no abbreviations!) or spec id
@param spellTabel static spell table
@param tooltip Unique Name for this Rotation
@param pve [i]Optional:[/i] [code]True[/code] if this should be registered as PvE rotation else [code]False[/code] - defaults to  [code]True[/code]
@param pvp [i]Optional:[/i] [code]True[/code] if this should be registered as PvP rotation else [code]False[/code] - defaults to  [code]True[/code]
@param config [i]Optional:[/i] Key/Value Pair Table which contains Config which can be used in your rotation #see:jps.getRotationValue - defaults to [code]{}[/code]
]]--
function jps.registerStaticTable(class,spec,spellTable,tooltip,pve,pvp,config)
    jps.registerRotation(class,spec,function() return parseStaticSpellTable(spellTable) end,tooltip,pve,pvp,config)
end


--[[[ Internal function: Returns the active Rotation for use in the Combat Loop ]]--
function jps.activeRotation(rotationTable)
    if rotationTable == nil then
        if jps.PvP then return jps.activeRotation(pvpRotations) else return jps.activeRotation(pveRotations) end
    end

    if not rotationTable[getCurrentKey()] then return nil end
    local countRotations = 0

    for k,v in pairs(rotationTable[getCurrentKey()]) do
        countRotations = countRotations+1 
        jps.ToggleRotationName[k] = v.tooltip
    end
    
    if jps.initializedRotation == false then
        if countRotations > 1 and jps.getConfigVal("rotation dropdown visible") == 1 then
			jps.MultiRotation = true
			UIDropDownMenu_SetText(DropDownRotationGUI, jps.ToggleRotationName[activeRotation])
            rotationDropdownHolder:Show()
            jps.deleteFunctionFromQueue(hideDropdown,"gui_loaded")
        else  
            rotationDropdownHolder:Hide()
            jps.addTofunctionQueue(hideDropdown,"gui_loaded")
        end
        jps.firstInitializingLoop = true
    end

    jps.initializedRotation = true

    if not rotationTable[getCurrentKey()][activeRotation] then return nil end
    jps.Count = activeRotation
    jps.Tooltip = rotationTable[getCurrentKey()][activeRotation].tooltip
    return rotationTable[getCurrentKey()][activeRotation]
end

--[[[
@function jps.getRotationValue
@description
If you supplied your rotation with a config table, you can access it's values with this function.
@param key Key for the config table
@returns Config value for the given key
]]--
function jps.getRotationValue(key)
    if not rotationTable[getCurrentKey()][activeRotation] or rotationTable[getCurrentKey()][activeRotation].config then  return nil end
    return rotationTable[getCurrentKey()][activeRotation].config[key]
end