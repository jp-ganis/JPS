--[[
LOGGING

Usage in your code:
    local log=jps.Logger(jps.LogLevel.DEBUG)
    log.debug("debug message")
    log.debug("this is a number: %s", 2)
    /script jps.Logger(jps.LogLevel.DEBUG).debug("test!")
]]--


jps.LogLevel={ DEBUG=1, INFO=2, WARN=3, ERROR=4, NONE=5 }
local function split(str, sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        str:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end
local function logPrint(logLevel,msgLevel)
    return function (msg,a,b,c,d,e,f,g,h)
        if msgLevel >= logLevel then
            local stackTrace = split(debugstack(2,1,0), ":")
            local file  = split(stackTrace[1], "\\")
            --local prefix = ""
            local prefix = string.format("%s:%s - ", file[#file], stackTrace[2])--string.format("%s:%s - ", debug.getinfo(1, "S").short_src, debug.getinfo(2, "l").currentline)
            --TODO: Check if DEFAULT_CHAT_FRAME:AddMessage() has any significant advantages
            print(prefix .. string.format(msg, tostring(a), tostring(b), tostring(c), tostring(d), tostring(e), tostring(f), tostring(g), tostring(h)) )
        end
    end
end

function jps.Logger(level)
    local newLogger = {}
    if not level or not tonumber(level) or (level < jps.LogLevel.DEBUG and level > jps.LogLevel.NONE) then
        newLogger["logLevel"] = jps.LogLevel.NONE
    else
        newLogger["logLevel"] = level
    end
    newLogger["debug"] = logPrint(newLogger.logLevel, jps.LogLevel.DEBUG)
    newLogger["info"] = logPrint(newLogger.logLevel, jps.LogLevel.INFO)
    newLogger["warn"] = logPrint(newLogger.logLevel, jps.LogLevel.WARN)
    newLogger["error"] = logPrint(newLogger.logLevel, jps.LogLevel.ERROR)
    newLogger["isDebugEnabled"] = newLogger.logLevel <= jps.LogLevel.DEBUG
    newLogger["isInfoEnabled"] = newLogger.logLevel <= jps.LogLevel.INFO
    newLogger["isWarnEnabled"] = newLogger.logLevel <= jps.LogLevel.WARN
    newLogger["isErrorEnabled"] = newLogger.logLevel <= jps.LogLevel.ERROR
    return newLogger
end