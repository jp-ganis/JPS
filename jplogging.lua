--[[
LOGGING

Usage in your code:
    local log=jps.Logger(jps.LogLevel.DEBUG)
    log.debug("debug message")
    log.debug("this is a number: %s", 2)
]]--


jps.LogLevel={ DEBUG=1, INFO=2, WARN=3, ERROR=4, NONE=5 }

local function logPrint(logLevel,msgLevel)
    return function (msg,...)
        if msgLevel >= logLevel then
            local prefix = string.format("%s:%s - ", debug.getinfo(1, "S").short_src, debug.getinfo(2, "l").currentline)
            --TODO: Check if DEFAULT_CHAT_FRAME:AddMessage() has any significant advantages
            print(prefix .. string.format(msg, ...) )
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
    return newLogger
end
