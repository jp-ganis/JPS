local pveRotations = {}
local pvpRotations = {}

local function toKey(class,specId)
    local classId = class
    if type(class) == "string" then
        class = string.upper(class)
        if class == "WARRIOR" then
            classId = 1
        elseif class == "PALADIN" then
            classId = 2
        elseif class == "HUNTER" then
            classId = 3
        elseif class == "ROGUE" then
            classId = 4
        elseif class == "PRIEST" then
            classId = 5
        elseif class == "DEATHKNIGHT" then
            classId = 6
        elseif class == "SHAMAN" then
            classId = 7
        elseif class == "MAGE" then
            classId = 8
        elseif class == "WARLOCK" then
            classId = 9
        elseif class == "MONK" then
            classId = 10
        elseif class == "DRUID" then
            classId = 11
        else
            return 0
        end
    end
    if type(classId) ~= "number" or type(specId) ~= "number" then return 0 end
    if classId < 1 or classId > 11 then return 0 end
    if classId < 11 and specId > 3 then return 0 end
    if classId == 11 and specId > 4 then return 0 end
    return classId * 10 + specId
end

local function getCurrentKey()
    _,_,classId = UnitClass("player")
    specId = GetSpecialization()
    return classId * 10 + specId
end

function jps.registerRotation(class,specId,fn,tooltip,config,pve,pvp)
    local key = toKey(class, specId)
    if pve==nil then pve = true end
    if pvp==nil then pvp = true end
    if config== nil then config = {} end
    if pvp and not pvpRotations[key] then pvpRotations[key] = {} end
    if pve and not pveRotations[key] then pveRotations[key] = {} end
    local rotation = {tooltip = tooltip, rotation = fn, config = config}
    if pvp then table.insert(pvpRotations[key], rotation) end
    if pve then table.insert(pveRotations[key], rotation) end
end

function jps.registerStaticTable(class,spec,spellTable,tooltip,config,pve,pvp)
    jps.registerRotation(class,spec,function() return parseStaticSpellTable(spellTable) end,tooltip,config,pve,pvp)
end
--[[
function jps.activeRotation()
        if jps.PvP then return jps.getActiveRotation(pvpRotation) else return jps.activeRotation(pveRotation) end
end]]

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
        if countRotations > 1 and jps.getConfigVal("Rotation Dropdown Visible") == 1 then 
            rotationDropdownHolder:Show()
            UIDropDownMenu_SetText(DropDownRotationGUI, jps.ToggleRotationName[1])
        else  
            rotationDropdownHolder:Hide() 
        end
        jps.firstInitializingLoop = true
    end

    jps.initializedRotation = true

    if not rotationTable[getCurrentKey()][jps.Count] then return nil end
    jps.Tooltip = rotationTable[getCurrentKey()][jps.Count].tooltip
    return rotationTable[getCurrentKey()][jps.Count].rotation()
end