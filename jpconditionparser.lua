local parser = {}
parser.testMode = false
function fnConditionsMatched(spell,conditions)
    -- nil
    if spell == nil then
        return false
    -- nil
    elseif conditions == nil then
        return true
    elseif type(conditions) == "boolean" then
        return conditions
    else
        return conditions()
    end
end

parser.compiledTables = {}

-- Pick a spell from a priority table.
function parseStaticSpellTable( hydraTable )
    if jps.firstInitializingLoop == true then return nil,"target" end
    if not parser.compiledTables[tostring(hydraTable)] then 
        jps.compileSpellTable(hydraTable)
        parser.compiledTables[tostring(hydraTable)] = true
    end
    local spell = nil
    local conditions = nil
    local target = nil
    local message = nil

    for _, spellTable in pairs(hydraTable) do
        if type(spellTable) == "function" then
            local fnTable = spellTable()
            spell = fnTable[1] 
            conditions = fnTable[2]
            target = fnTable[3]
        else
            spell = spellTable[1] 
            conditions = spellTable[2]
            target = spellTable[3]
        end
        
        if not target then target = "target" end

        -- NESTED TABLE
        if spell == "nested" and conditions() then
        
            local newTable = spellTable[3]
            spell,target = parseStaticSpellTable( newTable )

        -- MACRO -- BE SURE THAT CONDITION TAKES CARE OF CANCAST -- TRUE or FALSE -- NOT NIL
        elseif type(spell) == "table" and spell[1] == "macro" and conditions() then
            local macroText = spell[2]
            local macroTarget = spell[3]
            if type(macroTarget)=="function" then macroTarget = macroTarget() end
            -- Workaround for TargetUnit is still PROTECTED despite goblin active
            local changeTargets = jps.UnitExists(macroTarget) 
            if changeTargets then jps.Macro("/target "..macroTarget) end
             
            if conditions() and type(macroText) == "string" then
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
            if conditions() and type(macroText) == "table" then
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
        end

        -- If not already assigned, assign target now.
        if not target and type(spellTable[3]) == "string" then
            target = spellTable[3]
        elseif not target and type(spellTable[3]) == "function" then
            target = spellTable[3]()
        end

        -- Return spell if conditions are true and spell is castable.
        if type(spell) ~= "table" and fnConditionsMatched(spell,conditions) and jps.canCast(spell,target) then
            -- if jps.Debug then print("|cffff8000Spell","|cffffffff",tostring(select(1,GetSpellInfo(spell)))) end 
            return spell,target 
        end
    end
    return nil
end



--[[
    FUNCTIONS USED IN SPELL TABLE
  ]]

local function FN(fn,...)
    local params = {...}
    local params_exec = {}
    return function()
  for i,v in ipairs(params) do
    if type(v) == "function" then 
        params_exec[i] = v()
    else
        params_exec[i] = v
    end
  end
        return fn()(unpack(params_exec))
    end
end


local function AND(...)
    local functions = {...}
    return function()
        for _,fn in pairs(functions) do
            if not fn() then if not parser.testMode then return false end end
        end
        return true
    end
end

local function OR(...)
    local functions = {...}
    return function()
        for _,fn in pairs(functions) do
            if fn() then if not parser.testMode then return true end end
        end
        return false
    end
end

local function NOT(fn)
    return function()
        return not fn()
    end
end


local function LT(o1, o2)
    return function()
        return o1() < o2()
    end
end

local function LE(o1, o2)
    return function()
        return o1() <= o2()
    end
end

local function EQ(o1, o2)
    return function()
        return o1() == o2()
    end
end

local function NEQ(o1, o2)
    return function()
        return o1() ~= o2()
    end
end

local function GE(o1, o2)
    return function()
        return o1() >= o2()
    end
end

local function GT(o1, o2)
    return function()
        return o1() > o2()
    end
end

local function VALUE(val)
    return function()
        return val
    end
end

local function GLOBAL_IDENTIFIER(id)
    return function()
        return _G[id]
    end
end

local function ACCESSOR(base, key)
    return function()
        return base()[key]
    end
end

local function ERROR(condition,msg)
    return function()
        print("Your rotation has an error in: \n" .. tostring(condition) .. "\n---" ..tostring(msg))
        return false
    end
end




--[[
    PARSER:
    conditions    = <condition> | <condition> 'and' <conditions> | <condition> 'or' <conditions>
    condition     = 'not' <condition> | '(' <conditions> ')' | <comparison>
    comparison    = <value> <comparator> <value>
    comparator    = '<' | '<=' | '=' | '==' | '~=' | '>=' | '>'
    value         = <identifier> | STRING | NUMBER | BOOLEAN | 'nil'
    identifier    = IDEN | IDEN'.'<accessor> | IDEN '(' ')' | IDEN'('<parameterlist>')
    accessor      = IDEN | IDEN.<accessor>
    parameterlist = <value> | <value> ',' <parameterlist>
]]


function parser.pop(tokens)
    local t,v = unpack(tokens[1])
    table.remove(tokens, 1)
    return t,v
end

function parser.lookahead(tokens)
    if tokens[1] then
        local t,v = unpack(tokens[1])
        return t,v
    else 
        return nil
    end
end

function parser.lookaheadType(tokens)
    return parser.lookahead(tokens)
end

function parser.lookaheadData(tokens)
    return select(2,parser.lookahead(tokens))
end

-- conditions = <condition> | <condition> 'and' <conditions> | <condition> 'or' <conditions>
function parser.conditions(tokens, expectBracket) 
    local condition1 = parser.condition(tokens)
    
    if tokens[1] then
        local t, v = parser.pop(tokens)
        
        if t == "keyword" then
            if v == 'and' then
                local condition2 = parser.conditions(tokens)
                return AND(condition1, condition2)
            elseif v == 'or' then
                local condition2 = parser.conditions(tokens)
                return OR(condition1, condition2)
            else
                error("Unexpected " .. tostring(t) .. ":" .. tostring(v) .. " conditions must be combined using keywords 'and' or 'or'!")
            end
        elseif expectBracket then
            if t == ")" then
                return condition1
            else
                error("Unexpected " .. tostring(t) .. ":" .. tostring(v) .. " missing ')'!")
            end
        else
            error("Unexpected " .. tostring(t) .. ":" .. tostring(v) .. " conditions must be combined using keywords 'and' or 'or'!")
        end
    elseif expectBracket then
        error("Unexpected " .. tostring(t) .. ":" .. tostring(v) .. " missing ')'!")
    else
        return condition1
    end
end

-- condition = 'not' <condition> | '(' <conditions> ')' | <comparison>
function parser.condition(tokens)
    local t, v = parser.lookahead(tokens)
    if t == "keyword" and v == "not" then
        parser.pop(tokens)
        return NOT(parser.condition(tokens))
    elseif t == "(" then
        parser.pop(tokens)
        return parser.conditions(tokens, true)
    else
        return parser.comparison(tokens)
    end
end

-- comparison = <value> <comparator> <value>
-- comparator = '<' | '<=' | '=' | '==' | '~=' | '>=' | '>'
function parser.comparison(tokens)
    local value1 = parser.value(tokens)
    local t = parser.lookaheadType(tokens)
    if t == "<" then
        local t, v = parser.pop(tokens)
        local value2 = parser.value(tokens)
        return LT(value1, value2)
    elseif t == "<=" then
        local t, v = parser.pop(tokens)
        local value2 = parser.value(tokens)
        return LE(value1, value2)
    elseif t == "=" or t == "==" then
        local t, v = parser.pop(tokens)
        local value2 = parser.value(tokens)
        return EQ(value1, value2)
    elseif t == "~=" then
        local t, v = parser.pop(tokens)
        local value2 = parser.value(tokens)
        return NEQ(value1, value2)
    elseif t == ">=" then
        local t, v = parser.pop(tokens)
        local value2 = parser.value(tokens)
        return GE(value1, value2)
    elseif t == ">" then
        local t, v = parser.pop(tokens)
        local value2 = parser.value(tokens)
        return GT(value1, value2)
    else
        return value1
    end
end

-- value      = <identifier> | STRING | NUMBER | BOOLEAN | 'nil'
function parser.value(tokens)
    local t, v = parser.lookahead(tokens)
    if t == "number" or t == "string" then
        parser.pop(tokens)
        return VALUE(v)
    elseif t == "keyword" and v == "true" then
        parser.pop(tokens)
        return VALUE(true)
    elseif t == "keyword" and v == "false" then
        parser.pop(tokens)
        return VALUE(false)
    elseif t == "keyword" and v == "nil" then
        parser.pop(tokens)
        return VALUE(nil)
    end
    return parser.identifier(tokens)
end

-- identifier = IDEN | IDEN'.'<accessor> | IDEN '(' ')' | IDEN'('<parameterlist>')
function parser.identifier(tokens)
    local t, v = parser.pop(tokens)
    if t ~= "iden" then
        error("Invalid identifier '" .. tostring(v) .. "'!")
    end
    local symbol = GLOBAL_IDENTIFIER(v)
    if parser.lookaheadType(tokens) == "." then
        parser.pop(tokens)
        symbol = parser.accessor(tokens, symbol)
    end
    if parser.lookaheadType(tokens) == "(" then
        parser.pop(tokens)
        if parser.lookaheadType(tokens) == ")" then
            parser.pop(tokens)
            return FN(symbol)
        else
            local parameterList = parser.parameterlist(tokens)
            return FN(symbol, unpack(parameterList))
        end
    else
        return symbol
    end

end

-- accessor = IDEN | IDEN.<accessor>
function parser.accessor(tokens, base)
    local t, v = parser.pop(tokens)
    if t ~= "iden" then
        error("Invalid identifier '" .. tostring(v) .. "'!")
    end
    local symbol = ACCESSOR(base, v)
    if parser.lookaheadType(tokens) == "." then
        parser.pop(tokens)
        symbol = parser.accessor(tokens, symbol)
    end
    return symbol
end


-- parameterlist = <value> | <value> ',' <parameterlist>
function parser.parameterlist(tokens)
    if parser.lookaheadType(tokens) == ")" then
        parser.pop(tokens)
        return nil
    end
    local value = parser.value(tokens)
    local nextToken = parser.lookaheadType(tokens)
    if nextToken == "," then
        parser.pop(tokens)
        return {value, unpack(parser.parameterlist(tokens))}
    elseif nextToken == ")" then
        parser.pop(tokens)
        return {value}
    else
        error("Invalid Token " .. tostring(nextToken) .. " in parameter list!")
    end
end




function jps.conditionParser(str)
    if type(str) == "function" then return str end
    local tokens = {}
    local i = 0
    
    for t,v in jps.lexer.lua(str) do
        i = i+1
        tokens[i] = {t,v}
    end
    local retOK, fn  = pcall(parser.conditions, tokens)
    if not retOK then
        return ERROR(str,fn)
    end
    parser.testMode = true
    local retOK, err = pcall(fn)
    parser.testMode = false
    if not retOK then
        return ERROR(str,err)
    end
    return fn
end


function jps.compileSpellTable(unparsedTable)
    local spell = nil
    local conditions = nil
    local target = nil
    local message = nil
    
    for i, spellTable in pairs(unparsedTable) do
        if type(spellTable) == "table" then
            spell = spellTable[1] 
            conditions = spellTable[2]
            if conditions ~= nil and type(conditions)=="string" then
                spellTable[2] = jps.conditionParser(conditions)
            end
            if spell == "nested" then
                jps.compileSpellTable(spellTable[3])
            end
        end
    end
    return unparsedTable
end

