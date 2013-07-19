--[[[
@module Events
@description 
JPS Event Handling. If you need to react to specific events or want to execute a function this module might help you.
Instead of creating your own frame and event-handler you can just hook into the JPS main frame and register functions
here.[br]
[br]
This module also contains profiling support for the events. If enabled you will get the memory consumption from all events summarized 
- [i]Attention:[/i] This has a serious impact on FPS!
]]--
-- Logger
local LOG=jps.Logger(jps.LogLevel.ERROR)
-- JPS Frame
local jpsFrame = CreateFrame("Frame", "JPSFrame")
-- Update Table
local updateTable = {}
-- Event Table for all events
local eventTable = {}
-- Event Table for COMBAT_LOG_EVENT_UNFILTERED Sub-Types
local combatLogEventTable = {}

-- Localization
local L = MyLocalizationTable

--------------------------
-- (UN)REGISTER FUNCTIONS 
--------------------------

--[[[
@function jps.registerOnUpdate
@description 
Register OnUpdate Function[br]
Adds the given function to the update table if it wasn't already registered.[br]
[br][i]Usage:[/i][br]
[code]
jps.registerOnUpdate(function()[br]
print("Update")[br]
end)[br]
[/code]
@param fn function to be executed on update
]]--
function jps.registerOnUpdate(fn)
	if not updateTable[fn] then
		updateTable[fn] = fn
		return true
	end
end

--[[[
@function jps.unregisterOnUpdate
@description 
Unregister OnUpdate Function[br]
Removes the given event function from the update table if it was registered earlier. Has no effect if the function wasn't registered.[br]
[br][i]Usage:[/i][br]
[code]
function myOnUpdate() ... end[br]
...[br]
jps.registerOnUpdate(myOnUpdate)[br]
...[br]
jps.unregisterOnUpdate(myOnUpdate)[br]
[/code]
@param fn function to unregister
]]--
function jps.unregisterOnUpdate(fn)
	if updateTable[fn] then
		updateTable[fn] = nil
		return true
	end
end

--[[[
@function jps.registerEvent
@description 
Adds the given event function to the event table if it wasn't already registered.[br]
[br][i]Usage:[/i][br]
[code]
jps.registerEvent("LOOT_OPENED", function()[br]
print("You opened Loot!")[br]
end)[br]
[/code]
@param event event name
@param fn function to be executed on update
]]-
function jps.registerEvent(event, fn)
	if not eventTable[event] then
		eventTable[event] = {}
		jpsFrame:RegisterEvent(event)
	end
	if not eventTable[event][fn] then
		eventTable[event][fn] = fn
		return true
	end
end

--[[[
@function jps.unregisterEvent
@description 
Removes the given event function from the event table if it was registered earlier. Has no effect if the function wasn't registered.[br]
[br][i]Usage:[/i][br]
[code]
function myLootOpened() ... end[br]
...[br]
jps.registerEvent("LOOT_OPENED", myLootOpened)[br]
...[br]
jps.unregisterEvent("LOOT_OPENED", myLootOpened)[br]
[/code]
@param event event name
@param fn function to unregister
]]--
function jps.unregisterEvent(event, fn)
	if eventTable[event] and eventTable[event][fn] then
		eventTable[event][fn] = nil
		local count = 0
		for k in pairs(eventTable[event]) do count = count + 1 end
		if count == 0 then
			jpsFrame:UnregisterEvent(event)
		end
		return true
	end
end

--[[[
@function jps.registerCombatLogEventUnfiltered
@description 
Register event subtype for COMBAT_LOG_EVENT_UNFILTERED - Adds the given event function to the COMBAT_LOG_EVENT_UNFILTERED table if it wasn't already registered.[br]
[br][i]Usage:[/i][br]
[code]
jps.registerCombatLogEventUnfiltered("SWING_DAMAGE", function()[br]
print("Swing Damage - yay!")[br]
end)[br]
[/code]
@param event name of the combat sub-event
@param fn function which should be executed on event
]]--
function jps.registerCombatLogEventUnfiltered(event, fn)
	if not combatLogEventTable[event] then
		combatLogEventTable[event] = {}
		jpsFrame:RegisterEvent(event)
	end
	if not combatLogEventTable[event][fn] then
		combatLogEventTable[event][fn] = fn
		return true
	end
end


--[[[
@function jps.unregisterCombatLogEventUnfiltered
@description 
Removes the given event function from the COMBAT_LOG_EVENT_UNFILTERED table if it was registered earlier. Has no effect if the function wasn't registered.[br]
[br][i]Usage:[/i][br]
[code]
function mySwingDamage() ... end[br]
...[br]
jps.registerCombatLogEventUnfiltered("SWING_DAMAGE", mySwingDamage)[br]
...[br]
jps.unregisterCombatLogEventUnfiltered("SWING_DAMAGE", mySwingDamage)[br]
[/code]
@param event event name
@param fn function to unregister
]]--
function jps.unregisterCombatLogEventUnfiltered(event, fn)
	 if combatLogEventTable[event] and combatLogEventTable[event][fn] then
		combatLogEventTable[event][fn] = nil
		local count = 0
		for k in pairs(combatLogEventTable[event]) do count = count + 1 end
		if count == 0 then
			jpsFrame:UnregisterEvent(event)
		end
		return true
	 end
end

--------------------------
-- PROFILING FUNCTIONS 
--------------------------
local enableProfiling = false
local enableUnfilteredProfiling = false
local memoryUsageTable = {}
local memoryStartTable = {}
local memoryUsageInterval = 0
local function startProfileMemory(key)
	if not memoryStartTable[key] then UpdateAddOnMemoryUsage(); memoryStartTable[key] = GetAddOnMemoryUsage("JPS") end 
end

local function endProfileMemory(key)
	if not memoryStartTable[key] then return end
	if not memoryUsageTable[key] then memoryUsageTable[key] = 0 end
	UpdateAddOnMemoryUsage()
	memoryUsageTable[key] = GetAddOnMemoryUsage("JPS") - memoryStartTable[key]
end

local reportInterval = 15
local maxProfileDuration = 60
local lastReportUpdate = 0
local totalProfileDuration = 0
function jps.reportMemoryUsage(elapsed)
	lastReportUpdate = lastReportUpdate + elapsed
	totalProfileDuration = totalProfileDuration + elapsed
	if lastReportUpdate > reportInterval then
		lastReportUpdate = 0
		print("Memory Usage Report:")
		for key,usage in pairs(memoryUsageTable) do
			print(" * " .. key .. ": " .. usage .. " KB in " .. reportInterval .. " seconds" )
		end
	    UpdateAddOnMemoryUsage()
		print(" *** TOTAL: " .. (GetAddOnMemoryUsage("JPS")-memoryUsageInterval) .. " KB in " .. reportInterval .. " seconds" )
		memoryUsageInterval = GetAddOnMemoryUsage("JPS")
		memoryStartTable = {}
		memoryUsageTable = {}
	end
	if totalProfileDuration >= maxProfileDuration then
		enableProfiling = false
		enableUnfilteredProfiling = false
	end
end

--[[[
@function jps.enableProfiling
@description 
Enables profiling for one minute. Every 15 seconds you will get the memory consumption from all events summarized 
- [i]Attention:[/i] This has a serious impact on FPS!
@param unfiltered [code]True[/code] if COMBAT_LOG_UNFILTERED events should be split up ([i]BIG PERFORMANCE DECREASE[/i]) - defaults to [code]False[/code]
]]--
function jps.enableProfiling(unfiltered)
	totalProfileDuration = 0
	lastReportUpdate = 0
	enableProfiling = true
	enableUnfilteredProfiling = unfiltered
	UpdateAddOnMemoryUsage()
	memoryUsageInterval = GetAddOnMemoryUsage("JPS")
end

--------------------------
-- EVENT LOOP FUNCTIONS 
--------------------------

-- Update Handler
jpsFrame:SetScript("OnUpdate", function(self, elapsed)
	if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	if (self.TimeSinceLastUpdate > jps.UpdateInterval) then
		for _,fn in pairs(updateTable) do
			local status, error = pcall(fn)
			if not status then
				 LOG.error("Error %s on OnUpdate function %s", error, fn)
			end
		end
		self.TimeSinceLastUpdate = 0
	end
	if enableProfiling then jps.reportMemoryUsage(elapsed) end
end)

--- Event Handler
jpsFrame:SetScript("OnEvent", function(self, event, ...)
	if eventTable[event] then
		if enableProfiling then startProfileMemory(event) end
		for _,fn in pairs(eventTable[event]) do
			local status, error = pcall(fn, ...)
			if not status then
				LOG.error("Error on event %s, function %s", error, fn)
			end
		end
		if enableProfiling then endProfileMemory(event) end
	end
	-- Execute this code everytime?
	if (jps.checkTimer("FacingBug") > 0) and (jps.checkTimer("Facing") == 0) then
		SaveView(2)
		TurnLeftStop()
		TurnRightStop()
		CameraOrSelectOrMoveStop()
	end
end)

--- COMBAT_LOG_EVENT_UNFILTERED Handler
jps.registerEvent("COMBAT_LOG_EVENT_UNFILTERED", function(timeStamp, event, ...)
	if jps.Enabled and UnitAffectingCombat("player") == 1 and combatLogEventTable[event] then
		LOG.debug("CombatLogEventUntfiltered: %s", event)
		if enableUnfilteredProfiling and enableProfiling then startProfileMemory("COMBAT_LOG_EVENT_UNFILTERED::"..event) end
		for _,fn in pairs(combatLogEventTable[event]) do
			local status, error = pcall(fn, timeStamp, event, ...)
			if not status then
				LOG.error("Error on COMBAT_LOG_EVENT_UNFILTERED sub-event %s, function %s", error, fn)
			end
		end
		if enableUnfilteredProfiling and enableProfiling then endProfileMemory("COMBAT_LOG_EVENT_UNFILTERED::"..event) end
	end
end)

--------------------------
-- UPDATE FUNCTIONS
--------------------------

-- Garbage Collection
local function collectGarbage()
	if jps.getConfigVal("collect garbage ingame(could cause a fps drop)") == 1 then
		if GetAddOnMemoryUsage("JPS") > 5000 then collectgarbage("collect") end
	end
end
jps.registerOnUpdate(collectGarbage)
-- TimeToDie Update
jps.registerOnUpdate(updateTimeToDie)
-- Combat
jps.registerOnUpdate(function()
	if jps.Combat and jps.Enabled then
		jps_Combat() 
	end
end)

--------------------------
-- EVENT FUNCTIONS
--------------------------
-- PLAYER_LOGIN
jps.registerEvent("PLAYER_LOGIN", function()
	NotifyInspect("player")
end)

-- PLAYER_ENTERING_WORLD
jps.registerEvent("PLAYER_ENTERING_WORLD", function()
	jps.detectSpec()
	reset_healtable()
	jps.SortRaidStatus()

end)

-- INSPECT_READY
jps.registerEvent("INSPECT_READY", function()
	if not jps.Spec then 
		jps.detectSpec() 
	end
	if jps_variablesLoaded and not jps.Configged then 
		jps_createConfigFrame()
		jps.runFunctionQueue("gui_loaded")
	end
end)

-- VARIABLES_LOADED
jps.registerEvent("VARIABLES_LOADED", jps_VARIABLES_LOADED)

-- Enter Combat
jps.registerEvent("PLAYER_REGEN_DISABLED", function()
	jps.Combat = true
	jps.gui_toggleCombat(true)
	jps.SortRaidStatus()
	if jps.getConfigVal("timetodie frame visible") == 1 then
		JPSEXTInfoFrame:Show()
	end
	jps.combatStart = GetTime()
end)

-- Leave Combat
local function leaveCombat()
	TurnLeftStop()
	TurnRightStop()
	CameraOrSelectOrMoveStop()
	jps.Opening = true
	jps.Combat = false
	jps.gui_toggleCombat(false)
	jps.EnemyTable = {}
	jps.clearTimeToLive()
	jps.SortRaidStatus() -- wipe jps.RaidTarget and jps.RaidStatus
	if jps.getConfigVal("timetodie frame visible") == 1 then
		JPSEXTInfoFrame:Hide()
		end
	jps.combatStart = 0
end
jps.registerEvent("PLAYER_REGEN_ENABLED", leaveCombat)
jps.registerEvent("PLAYER_REGEN_ENABLED", collectGarbage)
jps.registerEvent("PLAYER_UNGHOST", leaveCombat)
jps.registerEvent("PLAYER_UNGHOST", collectGarbage)

-- Group/Raid Update
jps.registerEvent("GROUP_ROSTER_UPDATE", jps.SortRaidStatus)
jps.registerEvent("RAID_ROSTER_UPDATE", jps.SortRaidStatus)

-- Dual Spec Respec
jps.registerEvent("ACTIVE_TALENT_GROUP_CHANGED", jps.detectSpec)

-- Save on Logout
jps.registerEvent("PLAYER_LEAVING_WORLD", jps_SAVE_PROFILE)

-- Hide Static Popup - thx here to Phelps & ProbablyEngine
local function hideStaticPopup(addon, eventBlocked)
	jps.PLuaFlag = true
	if addon == "JPS" then
		StaticPopup1:Hide()
		LOG.debug("Addon Action Blocked: %s", eventBlocked)
	end
end
jps.registerEvent("ADDON_ACTION_FORBIDDEN", hideStaticPopup)
jps.registerEvent("ADDON_ACTION_BLOCKED", hideStaticPopup)

-- LOOT_OPENED
jps.registerEvent("LOOT_OPENED", function()
	if (IsFishingLoot()) then
		jps.Fishing = true
	end
end)

-- LOOT_CLOSED
jps.registerEvent("LOOT_CLOSED", function()
	local deleteFish = false
	if jps.Fishing then
		deleteFish = true
		jps.Fishing = false
	end
	local deleteCarp = jps.getConfigVal("Delete Fish: Golden Carp")
	local deleteMurgle = jps.getConfigVal("Delete Fish: Murglesnout")
	for bag = 0,4,1 do
		for slot = 1, GetContainerNumSlots(bag), 1 do
			local name = GetContainerItemLink(bag,slot)
			local itemId = GetContainerItemID(bag, slot) 
			if name then
				local copper = select(11,GetItemInfo(itemId)) or 0;
				if string.find(name,"ff9d9d9d") and copper < 500 and jps.getConfigVal("Delete Grey loot worth less than 5 silver") == 1 then -- delete grey stuff worth less then 5 silver
					write("Deleting "..name.." reason: to low price")
					PickupContainerItem(bag,slot)
					DeleteCursorItem()
				elseif deleteFish and ((string.find(name,L["Murglesnout"]) and deleteMurgle ) or (deleteCarp == 1 and string.find(name,L["Golden Carp"]))) then 
					PickupContainerItem(bag,slot)
					write("Deleting "..name)
					DeleteCursorItem()
				end					
			end 
		 end 
	end
end)

-- UI_ERROR_MESSAGE
jps.registerEvent("UI_ERROR_MESSAGE", function(event_error)
	-- "UI_ERROR_MESSAGE" returns ONLY one arg1
	-- http://www.wowwiki.com/WoW_Constants/Errors
	-- http://www.wowwiki.com/WoW_Constants/Spells
	if (jps.checkTimer("FacingBug") > 0) and (jps.checkTimer("Facing") == 0) then
		SaveView(2)
		TurnLeftStop()
		TurnRightStop()
		CameraOrSelectOrMoveStop()
	elseif jps.Enabled then -- and jps.Combat
		if (event_error == SPELL_FAILED_NOT_BEHIND) then -- "You must be behind your target."
			LOG.debug("SPELL_FAILED_NOT_BEHIND - %s", event_error)
			jps.isNotBehind = true
			jps.isBehind = false
		elseif jps.FaceTarget and ((event_error == SPELL_FAILED_UNIT_NOT_INFRONT) or (event_error == ERR_BADATTACKFACING)) then
			LOG.debug("ERR_BADATTACKFACING - %s", event_error)			
			jps.createTimer("Facing",0.6)
			jps.createTimer("FacingBug",1.2)
			SetView(2)
			if jps.getConfigVal("FaceTarget rotate direction. checked = left, unchecked = right") == 1 
			then
				TurnLeftStart()
			else
				TurnRightStart()
			end
			
			CameraOrSelectOrMoveStart()
			
		elseif (event_error == SPELL_FAILED_LINE_OF_SIGHT) or (event_error == SPELL_FAILED_VISION_OBSCURED) then
			LOG.debug("SPELL_FAILED - %s", event_error)
			jps.BlacklistPlayer(jps.LastTarget)
		end
	end
end)

-- "UNIT_SPELLCAST_SENT"
jps.registerEvent("UNIT_SPELLCAST_SENT", function(...)
		local unitID = select(1,...)
		local spellname = select(2,...)

		jps.CastBar.latencySpell = spellname
		if unitID == "player" and spellname then jps.CastBar.sentTime = GetTime() end
end)

-- "UNIT_SPELLCAST_START"
jps.registerEvent("UNIT_SPELLCAST_START", function(...)
		local unitID = select(1,...)
		local spellname = select(2,...)

		if unitID == "player" and (spellname == jps.CastBar.latencySpell) then 
			jps.CastBar.startTime = GetTime() 
		else
			jps.CastBar.startTime = nil
			jps.CastBar.latency = 0
		end

		if jps.CastBar.startTime then
			jps.CastBar.latency = jps.CastBar.startTime - jps.CastBar.sentTime
			jps.CastBar.latencySpell = nil
		else
			jps.CastBar.latency = 0
		end
end)

-- "UNIT_SPELLCAST_INTERRUPTED" -- "UNIT_SPELLCAST_STOP"
local function latencySpell ()
		jps.CastBar.startTime = nil
		jps.CastBar.latency = 0
end
jps.registerEvent("UNIT_SPELLCAST_INTERRUPTED", latencySpell)
jps.registerEvent("UNIT_SPELLCAST_STOP", latencySpell)

-- LOOT_OPENED
jps.registerEvent("LOOT_OPENED", function()
	if (IsFishingLoot()) then
		jps.Fishing = true
	end
end)

-- UNIT_SPELLCAST_SUCCEEDED
jps.registerEvent("UNIT_SPELLCAST_SUCCEEDED", function(...)
	--if jps.Debug then print("UNIT_SPELLCAST_SUCCEEDED") end
	if not jps.CurrentCast then jps.CurrentCast = {} end
	if ... == "player" then
		jps.CurrentCast[1], jps.CurrentCast[2], _ , _, jps.CurrentCast[5], _ = ...
	end
	
	if jps.FaceTarget and (jps.CurrentCast[1]=="player") and jps.CurrentCast[5] then
		SaveView(2)
		if jps.getConfigVal("FaceTarget rotate direction. checked = left, unchecked = right") == 1 then
			TurnLeftStop()
		else
			TurnRightStop()
		end
		CameraOrSelectOrMoveStop()
	end
	jps.isNotBehind = false
	jps.isBehind = true
end)

-- RAIDSTATUS UPDATE
-- UNIT_HEALTH events are sent for raid and party members regardless of their distance from the character of the host. 
-- This makes UNIT_HEALTH extremely valuable to monitor PARTY AND RAID MEMBERS.
-- arg1 the UnitID of the unit whose health is affected player, pet, target, mouseover, party1..4, partypet1..4, raid1..40
-- "UNIT_HEALTH_FREQUENT" Same event as UNIT_HEALTH, but not throttled as aggressively by the client
-- "UNIT_HEALTH_PREDICTION" arg1 unitId receiving the incoming heal
jps.registerEvent("UNIT_HEALTH_FREQUENT", function(unit)
	if jps.Enabled then
		local unittarget = unit.."target"
		
		if jps.isHealer then jps.UpdateRaidStatus(unit) end
		
		if jps.canDPS(unittarget) then -- Working only with raidindex.."target" and not with unitname.."target"
			local unittarget_hpct = jps.hp(unittarget)
			local unittarget_guid = UnitGUID(unittarget)
			
			local countTargets = 0
			if jps.RaidTarget[unittarget_guid] ~= nil then
				countTargets = jps.RaidTarget[unittarget_guid]["count"]
			end
			
			if jps.RaidTarget[unittarget_guid] == nil then
				jps.RaidTarget[unittarget_guid] = {}
			end
			
			jps.RaidTarget[unittarget_guid]["unit"] = unittarget
			jps.RaidTarget[unittarget_guid]["hpct"] = unittarget_hpct
			jps.RaidTarget[unittarget_guid]["count"] = countTargets + 1
			
		else
			jps.removeTableKey(jps.RaidTarget,unittarget_guid)
			jps.removeTableKey(jps.EnemyTable,unittarget_guid)
		end
	end
end)

-- PLAYER_LEVEL_UP - if jps was disabled because of toon level < 10
jps.registerEvent("PLAYER_LEVEL_UP", function(level)
	if level == "10" then
		jps.Level = level
		jps.detectSpec()
		jps.Enabled = true
		jps.detectSpecDisabled = false
	end
end)

--------------------------
-- COMBAT_LOG_EVENT_UNFILTERED FUNCTIONS
--------------------------
-- eventtable[4] == sourceGUID
-- eventtable[5] == sourceName
-- eventtable[6] == sourceFlags
-- eventtable[8] == destGUID
-- eventtable[9] == destName
-- eventtable[10] == destFlags
-- eventtable[15] == amount if suffix is _DAMAGE or _HEAL

-- TIMER SHIELD FOR DISC PRIEST
jps.registerCombatLogEventUnfiltered("", function(...)
	if select(5,...) == GetUnitName("player") and select(12,...) == 17 then
		jps.createTimer("Shield", 12 )
	end
end)

-- HEALTABLE -- CONTAINS THE AVERAGE VALUE OF HEALING SPELLS
local function updateHealTable(...)
	if select(5,...) == GetUnitName("player") then
		update_healtable(...)
	end
end
jps.registerCombatLogEventUnfiltered("SPELL_HEAL", updateHealTable)
jps.registerCombatLogEventUnfiltered("SPELL_PERIODIC_HEAL", updateHealTable)

-- AGGRO PLAYER replace event == "UNIT_COMBAT"
local function aggroTimer(...)
	if select(9,...) == GetUnitName("player") then
		jps.createTimer("Player_Aggro", 4 )
	end
end
jps.registerCombatLogEventUnfiltered("SWING_DAMAGE", aggroTimer)
jps.registerCombatLogEventUnfiltered("SPELL_DAMAGE", aggroTimer)

-- REMOVE DIED UNIT OR OUT OF RANGE UNIT OF TABLES
jps.registerCombatLogEventUnfiltered("UNIT_DIED", function(...)
	if select(8,...) ~= nil then
		local mobGuid = select(8,...) -- eventtable[8] == destGUID 
		jps.removeTableKey(jps.RaidTimeToDie,mobGuid)
		jps.removeTableKey(jps.RaidTarget,mobGuid)
		jps.removeTableKey(jps.EnemyTable,mobGuid)
	end
end)

-- TABLE ENEMIES IN COMBAT
jps.registerEvent("COMBAT_LOG_EVENT_UNFILTERED", function(...)
	local sourceGUID = select(4,...)
	local sourceName = select(5,...)
	local sourceFlags = select(6,...)
	local destName = select(9,...)
	local destFlags = select(10,...)
	if sourceFlags and (bit.band(sourceFlags,COMBATLOG_OBJECT_REACTION_HOSTILE) > 0) 
	and (bit.band(sourceFlags,COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0)
	and destFlags and (bit.band(destFlags,COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0)
	and jps.canHeal(destName) and (sourceGUID ~= nil) then
		local enemyFriend = jps.stringSplit(destName,"-") -- eventtable[9] == destName -- "Bob" or "Bob-Garona" to "Bob"
		if jps.EnemyTable[sourceGUID] == nil then
			jps.EnemyTable[sourceGUID] = {}
		end
		jps.EnemyTable[sourceGUID]["friend"] = enemyFriend -- TABLE OF ENEMY GUID TARGETING FRIEND NAME
	end
	local action = select(2, ...)
	local periodic = select(15, ...)
	local swing = select(12, ...)	
	local GUID = select(8, ...)
	
	local dmgTTD = 0
	if (action == "SPELL_DAMAGE" or action == "SPELL_PERIODIC_DAMAGE") and periodic ~= nil then
		if periodic > 0 then 
			dmgTTD = periodic
		end
	elseif (action == "SWING_DAMAGE") and swing ~= nil then
		if swing > 0 then 
			dmgTTD = swing
		end
	end
	if InCombatLockdown()==1 then -- InCombatLockdown() returns 1 if in combat or nil otherwise
		local unitGuid = GUID -- thisEvent[8] == destGUID
		jps.Combat = true
		jps.gui_toggleCombat(true)
		if jps.RaidTimeToDie[unitGuid] == nil then jps.RaidTimeToDie[unitGuid] = {} end
		local dataset = jps.RaidTimeToDie[unitGuid]
		local data = table.getn(dataset)
		if data > jps.timeToLiveMaxSamples then table.remove(dataset, jps.timeToLiveMaxSamples) end
		table.insert(dataset, 1, {GetTime(), dmgTTD})
		jps.RaidTimeToDie[unitGuid] = dataset
		--jps.RaidTimeToDie[unitGuid] = { [1] = {GetTime(), thisEvent[15] },[2] = {GetTime(), thisEvent[15] },[3] = {GetTime(), thisEvent[15] } }
	end
end)

