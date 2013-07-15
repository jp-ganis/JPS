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

local function addRotationToTable(rotations,rotation)
    for k,v in pairs(rotations) do
        if v.tooltip == rotation.tooltip then
            rotations[k] = rotation
            return
        end
    end
    table.insert(rotations, rotation)
end

function jps.registerRotation(class,specId,fn,tooltip,config,pve,pvp)
    local key = toKey(class, specId)
    if pve==nil then pve = true end
    if pvp==nil then pvp = true end
    if config== nil then config = {} end
    if pvp and not pvpRotations[key] then pvpRotations[key] = {} end
    if pve and not pveRotations[key] then pveRotations[key] = {} end
    local rotation = {tooltip = tooltip, rotation = fn, config = config}
    if pvp then addRotationToTable(pvpRotations[key], rotation) end
    if pve then addRotationToTable(pveRotations[key], rotation) end
    jps.initializedRotation = false
    jps.activeRotation()
end

function jps.unregisterRotation(class,specId,tooltip,pve,pvp)
    local key = toKey(class, specId)
    if pve==nil then pve = true end
    if pvp==nil then pvp = true end
    if pve and pveRotations[key] then for k,v in pairs(pveRotations[key]) do
        if v.tooltip == tooltip then
            table.remove(pveRotations[key], k)
            break
        end
    end end
    if pvp and pvpRotations[key] then for k,v in pairs(pvpRotations[key]) do
        if v.tooltip == tooltip then
            table.remove(pvpRotations[key], k)
            break
        end
    end end
end

function jps.registerTable(class,spec,spellTable,tooltip,config,pve,pvp)
    jps.registerRotation(class,spec,function() return parseSpellTable(spellTable) end,tooltip,config,pve,pvp)
end

function jps.registerStaticTable(class,spec,spellTable,tooltip,config,pve,pvp)
    jps.registerRotation(class,spec,function() return parseStaticSpellTable(spellTable) end,tooltip,config,pve,pvp)
end

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