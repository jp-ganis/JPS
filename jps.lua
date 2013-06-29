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

-- Huge thanks to everyone who's helped out on this, <3
-- Universal

jps = {}
jps.Version = "1.3.0"
jps.Revision = "r546"
jps.NextSpell = {}
jps.Rotation = nil
jps.UpdateInterval = 0.05
jps.Enabled = false
jps.Combat = false
jps.Debug = false
jps.PLuaFlag = false
jps.MoveToTarget = false
jps.FaceTarget = true

jps.Fishing = false
jps.MultiTarget = false
jps.Interrupts = false
jps.UseCDs = false
jps.PvP = false
jps.Defensive = false

-- Utility
jps.Class = nil
jps.Spec = nil
jps.Race = nil
jps.Level = 1
jps.IconSpell = nil
jps.Message = nil
jps.LastTarget = nil
jps.LastTargetGUID = nil
jps.Target = nil
jps.Casting = false
jps.LastCast = nil
jps.ThisCast = nil
jps.NextCast = nil
jps.Error = nil
jps.Lag = nil
jps.Moving = nil
jps.MovingTarget = nil
jps.HarmSpell = nil
jps.IconSpell = nil
jps.CurrentCast = {}
jps.SpellBookTable = {}

-- Class
jps.isNotBehind = false
jps.isBehind = true
jps.isHealer = false
jps.DPSRacial = nil
jps.DefRacial = nil
jps.Lifeblood = nil
jps.EngiGloves = nil
jps.isTank = false

-- Raccourcis
cast = CastSpellByName

-- Misc
jps.raid = {}
jps.Opening = true
jps.RakeBuffed = false
jps.RipBuffed = false
jps.BlacklistTimer = 2
jps.RaidStatus = {}
jps.RaidTarget = {}
jps.RaidRoster = {}
jps.HealerBlacklist = {}
jps.Timers = {}
Healtable = {}
jps.EnemyTable =  {}
jps.RaidTimeToDie = {}
jps.RaidTimeToLive = {}
jps.initializedRotation = false
jps.firstInitializingLoop = true
jps.settings = {}
jps.combatStart = 0

-- Config.
jps.Configged = false
jps_variablesLoaded = false
jpsName = select(1,UnitName("player"))
jpsRealm = GetCVar("realmName")
jps.ExtraButtons = true
jps.ResetDB = false
jps.Count = 1
jps.Tooltip = "Click Macro /jps pew\nFor the Rotation Tooltip"
jps.ToggleRotationName = {"No Rotations"}
jps.MultiRotation = false
rotationDropdownHolder = nil
jps.customRotationFunc = ""
jps.timeToDieAlgorithm= "LeastSquared"  --  WeightedLeastSquares , LeastSquared , InitialMidpoints

-- IN COMBAT
local start_time = 0
local end_time = 0
local total_time = 0

-- Slash Cmd
SLASH_jps1 = '/jps'

local combatFrame = CreateFrame("FRAME", nil)
combatFrame:RegisterEvent("PLAYER_LOGIN")
combatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
combatFrame:RegisterEvent("INSPECT_READY")
combatFrame:RegisterEvent("VARIABLES_LOADED")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:RegisterEvent("PLAYER_UNGHOST")
combatFrame:RegisterEvent("PLAYER_ALIVE")
combatFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
combatFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
combatFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
combatFrame:RegisterEvent("LOOT_OPENED")
combatFrame:RegisterEvent("LOOT_CLOSED")
combatFrame:RegisterEvent("UI_ERROR_MESSAGE")
combatFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
combatFrame:RegisterEvent("UNIT_HEALTH_FREQUENT")
combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
if UnitLevel("player") < 10 then
	combatFrame:RegisterEvent("PLAYER_LEVEL_UP")
end

--combatFrame:RegisterEvent("PLAYER_CONTROL_GAINED") -- Fires after the PLAYER_CONTROL_LOST event, when control has been restored to the player
--combatFrame:RegisterEvent("PLAYER_CONTROL_LOST") -- Fires whenever the player is unable to control the character
combatFrame:RegisterEvent("RAID_ROSTER_UPDATE")
combatFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

--------------------------
-- LOCALIZATION
--------------------------

local L = MyLocalizationTable

function write(...)
   DEFAULT_CHAT_FRAME:AddMessage("|cffff8000JPS: " .. strjoin(" ", tostringall(...))); -- color orange
end
function macrowrite(...)
   DEFAULT_CHAT_FRAME:AddMessage("|cffff8000MACRO: " .. strjoin(" ", tostringall(...))); -- color orange
end

--------------------------
-- EVENTS HANDLER
--------------------------

	function jps_combatEventHandler(self, event, ...)

	if event == "PLAYER_LOGIN" then
		NotifyInspect("player")
	  
	elseif event == "PLAYER_ENTERING_WORLD" then -- 2er fire > reloadui
		if jps.Debug then print("PLAYER_ENTERING_WORLD") end
		jps.detectSpec()
		reset_healtable()
		jps.SortRaidStatus()
		jps.UpdateRaidStatus()	

	elseif event == "INSPECT_READY" then -- 3er fire > reloadui
		if jps.Debug then  print("INSPECT_READY") end
		if not jps.Spec then 
			jps.detectSpec() 
		end
		if jps_variablesLoaded and not jps.Configged then jps_createConfigFrame() end

	elseif event == "VARIABLES_LOADED" then -- 1er fire > reloadui
		if jps.Debug then print("VARIABLES_LOADED") end
		jps_VARIABLES_LOADED()

	elseif event == "PLAYER_REGEN_DISABLED" then
		if jps.Debug then print("PLAYER_REGEN_DISABLED") end
		jps.Combat = true
		jps.gui_toggleCombat(true)
		jps.SortRaidStatus()
		jps.UpdateRaidStatus()
		start_time = GetTime()
		if jps.getConfigVal("timetodie frame visible") == 1 then
			JPSEXTInfoFrame:Show()
		end
		jps.combatStart = GetTime()
	  
	elseif (event == "PLAYER_REGEN_ENABLED") or (event == "PLAYER_UNGHOST") then -- or (event == "PLAYER_ALIVE")
		if jps.Debug then print("PLAYER_REGEN_ENABLED") end
		TurnLeftStop()
		TurnRightStop()
		CameraOrSelectOrMoveStop()
		jps.Opening = true
		jps.Combat = false
		jps.gui_toggleCombat(false)
		jps.RaidStatus = {}
		jps.RaidTarget = {}
		jps.EnemyTable = {}
		jps.clearTimeToLive()
		if jps.getConfigVal("timetodie frame visible") == 1 then
			JPSEXTInfoFrame:Hide()
		end
		jps.combatStart = 0
		collectgarbage("collect")
		
-- Raid Update		
	elseif (event == "GROUP_ROSTER_UPDATE") or (event == "RAID_ROSTER_UPDATE") then
		if jps.Debug then  print("ROSTER_UPDATE") end
		jps.SortRaidStatus()
		
-- Dual Spec Respec
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then -- only fire when spec change no other event before
		--print("ACTIVE_TALENT")
		jps.detectSpec()
	  
-- On Logout
	elseif event == "PLAYER_LEAVING_WORLD" then
		jps_SAVE_PROFILE()
	  
-- "ADDON_ACTION_FORBIDDEN"
	elseif event == "ADDON_ACTION_FORBIDDEN" then
		jps.PLuaFlag = true
	  
-- FISHES
	elseif event == "LOOT_OPENED"  then
		if (IsFishingLoot()) then
			jps.Fishing = true
		end
	elseif  event == "LOOT_CLOSED" then
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
					if string.find(name,"ff9d9d9d") and copper < 500  and jps.getConfigVal("Delete Grey loot worth less than 5 silver") == 1 then -- delete grey stuff worth less then 5 silver
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
			
      
-- UI ERROR
	elseif (jps.checkTimer("FacingBug") > 0) and (jps.checkTimer("Facing") == 0) then
		SaveView(2)
		TurnLeftStop()
		TurnRightStop()
		CameraOrSelectOrMoveStop()

	elseif event == "UI_ERROR_MESSAGE" and jps.Enabled then -- and jps.Combat
	-- "UI_ERROR_MESSAGE" returns ONLY one arg1
	-- http://www.wowwiki.com/WoW_Constants/Errors
	-- http://www.wowwiki.com/WoW_Constants/Spells

		local event_error = ...
		if (event_error == SPELL_FAILED_NOT_BEHIND) then -- "You must be behind your target."
			if jps.Debug then  print("SPELL_FAILED_NOT_BEHIND",event_error) end
			jps.isNotBehind = true
   			jps.isBehind = false
   			
		elseif jps.FaceTarget and ((event_error == SPELL_FAILED_UNIT_NOT_INFRONT) or (event_error == ERR_BADATTACKFACING)) then
			-- if event_error == L["Target needs to be in front of you."] or event_error == L["You are facing the wrong way!"] then
			if jps.Debug then  print("ERR_BADATTACKFACING",event_error)	end
			
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
			-- if (event_error == L["Target not in line of sight"]) or (event_error == L["Your vision of the target is obscured"]) then
			if jps.Debug then print("SPELL_FAILED_LINE_OF_SIGHT",event_error) end
			jps.BlacklistPlayer(jps.LastTarget)
		end
		
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and jps.Enabled then -- and jps.Combat
		--if jps.Debug then print("UNIT_SPELLCAST_SUCCEEDED") end
		jps.CurrentCast = {...}
		
		-- "Druid" -- 5221 -- "Shred" -- "Ambush" 8676
		if jps.CurrentCast[2] == tostring(select(1,GetSpellInfo(5221))) then 
			jps.isNotBehind = false
			jps.isBehind = true
		elseif jps.CurrentCast[2] == tostring(select(1,GetSpellInfo(8676))) then
			jps.isNotBehind = false
			jps.isBehind = true
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
	end

-- RAIDSTATUS UPDATE
-- UNIT_HEALTH events are sent for raid and party members regardless of their distance from the character of the host. 
-- This makes UNIT_HEALTH extremely valuable to monitor PARTY AND RAID MEMBERS.
-- arg1 the UnitID of the unit whose health is affected player, pet, target, mouseover, party1..4, partypet1..4, raid1..40
-- "UNIT_HEALTH_FREQUENT" Same event as UNIT_HEALTH, but not throttled as aggressively by the client
-- "UNIT_HEALTH_PREDICTION" arg1 unitId receiving the incoming heal

	if event == "UNIT_HEALTH_FREQUENT" and jps.Enabled then
		local unit = ...
		local unitname = select(1,UnitName(unit))
		local unittarget = unit.."target"
		local unit_guid = UnitGUID(unit)
		local unit_health = jps.hp(unit) 
		
		local calculate = true -- first time event fires
		if event_dataset == nil then event_dataset = {} end
		table.insert( event_dataset,1, GetTime() )
		local raid_data = jps_tableLen(event_dataset)

		if raid_data == 1 or raid_data == 0 then calculate = true
		else
			if (event_dataset[1] - event_dataset[raid_data]) < jps.UpdateInterval then
				calculate = false
			else
				calculate = true
				table.wipe(event_dataset)
			end
			 
		end 

		if calculate and jps.isHealer then
			jps.UpdateRaidStatus()	
		end

		if calculate and jps.canDPS(unittarget) then -- Working only with raidindex.."target" and not with unitname.."target"
			local hpct_enemy = jps.hp(unittarget)
			local unittarget_guid = UnitGUID(unittarget)
			
			local countTargets = 0
			if jps.RaidTarget[unittarget_guid] ~= nil then
				countTargets = jps.RaidTarget[unittarget_guid]["count"]
			end
	
			jps.RaidTarget[unittarget_guid] = { 
				["unit"] = unittarget,
				["hpct"] = hpct_enemy,
				["count"] = countTargets + 1
			}
			
		else
			jps_removeKey(jps.RaidTarget,unittarget_guid)
			jps_removeKey(jps.EnemyTable,unittarget_guid)
		end

		if jps.RaidTimeToLive[unit_guid] == nil then jps.RaidTimeToLive[unit_guid] = {} end
		local raid_dataset = jps.RaidTimeToLive[unit_guid]
		local raid_data = table.getn(raid_dataset)
		if raid_data > jps.timeToLiveMaxSamples then table.remove(raid_dataset, jps.timeToLiveMaxSamples) end
		table.insert(raid_dataset, 1, {GetTime(), unit_health})
		jps.RaidTimeToLive[unit_guid] = raid_dataset

		-- PLAYER_LEVEL_UP - if jps was disabled because of toon level < 10
		elseif event == "PLAYER_LEVEL_UP" then
			local eventtable =  {...}
			if eventtable[1] == "10" then
				jps.Level = eventtable[1]
				jps.detectSpec()
				jps.Enabled = true
			end
				
-- COMBAT_LOG_EVENT
-- eventtable[4] == sourceGUID
-- eventtable[5] == sourceName
-- eventtable[6] == sourceFlags
-- eventtable[8] == destGUID
-- eventtable[9] == destName
-- eventtable[10] == destFlags
-- eventtable[15] == amount if suffix is _DAMAGE or _HEAL

	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" and jps.Enabled and UnitAffectingCombat("player") == 1 then
		local eventtable =  {...}
		
		-- TIMER SHIELD FOR DISC PRIEST
		if eventtable[2] == "SPELL_CAST_SUCCESS" and eventtable[5] == GetUnitName("player") and eventtable[12] == 17 then
			jps.createTimer("Shield", 12 )
		end
		
		-- HEALTABLE -- CONTAINS THE AVERAGE VALUE OF HEALING SPELLS
		if eventtable[5] == GetUnitName("player") and (eventtable[2] == "SPELL_HEAL" or eventtable[2] == "SPELL_PERIODIC_HEAL") then
			update_healtable(...)
		end
	
		-- AGGRO PLAYER replace event == "UNIT_COMBAT"
		if eventtable[9] == GetUnitName("player") and (eventtable[2] == "SWING_DAMAGE" or eventtable[2] == "SPELL_DAMAGE") then
			jps.createTimer("Player_Aggro", 4 )
		end	

-- REMOVE DIED UNIT OR OUT OF RANGE UNIT OF TABLES
		if eventtable[2] == "UNIT_DIED" and (eventtable[8] ~= nil) then
			local mobName = jps_stringTarget(eventtable[9],"-") -- eventtable[9] == destName -- "Bob" or "Bob-Garona" to "Bob"
			local mobGuid = eventtable[8] -- eventtable[8] == destGUID 
			jps_removeKey(jps.RaidTimeToDie,mobGuid)
			jps_removeKey(jps.RaidTarget,mobGuid)
			jps_removeKey(jps.EnemyTable,mobGuid)

-- TABLE ENEMIES IN COMBAT
		elseif eventtable[6] and (bit.band(eventtable[6],COMBATLOG_OBJECT_REACTION_HOSTILE) > 0) 
		and (bit.band(eventtable[6],COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0)
		and eventtable[10] and (bit.band(eventtable[10],COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) == 0)
		and jps.canHeal(eventtable[9]) and (eventtable[4] ~= nil) then
			local enemyFriend = jps_stringTarget(eventtable[9],"-") -- eventtable[9] == destName -- "Bob" or "Bob-Garona" to "Bob"
			local enemyName = eventtable[5] -- eventtable[5] == sourceName
			local enemyGuid = eventtable[4] -- eventtable[4] == sourceGUID
			jps.EnemyTable[enemyGuid] = { ["friend"] = enemyFriend } -- TABLE OF ENEMY GUID TARGETING FRIEND NAME
-- TABLE DAMAGE
--[[		elseif (eventtable[8] ~= nil) and ((eventtable[2] == "SPELL_PERIODIC_DAMAGE") or (eventtable[2] == "SPELL_DAMAGE") or (eventtable[2] == "SWING_DAMAGE")) then
			local dmg_TTD = 0
			jps.Combat = true
			jps.gui_toggleCombat(true)
			-- end_time = GetTime()
			-- total_time = math.max(end_time - start_time, 1)
			if (eventtable[2] == "SPELL_DAMAGE" or eventtable[2] == "SPELL_PERIODIC_DAMAGE") and (eventtable[15] > 0) then
				dmg_TTD = eventtable[15]
			elseif (eventtable[2] == "SWING_DAMAGE") and (eventtable[12] > 0) then
				dmg_TTD = eventtable[12]
			end
			if InCombatLockdown()==1 then -- InCombatLockdown() returns 1 if in combat or nil otherwise
				local unitGuid = eventtable[8] -- eventtable[8] == destGUID
				if jps.RaidTimeToDie[unitGuid] == nil then jps.RaidTimeToDie[unitGuid] = {} end
				local dataset = jps.RaidTimeToDie[unitGuid]
				local data = table.getn(dataset)
				if data > jps.timeToLiveMaxSamples then table.remove(dataset, jps.timeToLiveMaxSamples) end
				table.insert(dataset, 1, {GetTime(), dmg_TTD})
				jps.RaidTimeToDie[unitGuid] = dataset
				--jps.RaidTimeToDie[unitGuid] = { [1] = {GetTime(), eventtable[15] },[2] = {GetTime(), eventtable[15] },[3] = {GetTime(), eventtable[15] } }
			end
]]
		end
	end
end

function updateTimeToDie(unit)
	if not unit then
			updateTimeToDie("target")
			updateTimeToDie("focus")
			updateTimeToDie("mouseover")
			for id = 1, 4 do
				updateTimeToDie("boss" .. id)
			end
			if jps.isHealer then
				for id = 1, 4 do
					updateTimeToDie("party" .. id)
					updateTimeToDie("partypet" .. id)
				end
				for id = 1, 5 do
					updateTimeToDie("arena" .. id)
					updateTimeToDie("arenapet" .. id)
				end
				for id = 1, 40 do
					updateTimeToDie("raid" .. id)
					updateTimeToDie("raidpet" .. id)
				end
			end
		return
	end
	if not UnitExists(unit) then return end

	local unitGuid = UnitGUID(unit)
	local health = UnitHealth(unit)

	if health == UnitHealthMax(unit) then
		jps.RaidTimeToDie[unitGuid] = nil
		return
	end

	local time = GetTime()

	jps.RaidTimeToDie[unitGuid] = jps.timeToDieFunctions[jps.timeToDieAlgorithm][0](jps.RaidTimeToDie[unitGuid],health,time)
end

jps.timeToDieFunctions = {}
jps.timeToDieFunctions["InitialMidpoints"] = { 
	[0] = function(dataset, health, time)
		if not dataset or not dataset.health0 then
			dataset = {}
			dataset.time0, dataset.health0 = time, health
			dataset.mhealth, dataset.mtime = time, health
		else
			dataset.mhealth = (dataset.mhealth + health) * .5
			dataset.mtime = (dataset.mtime + time) * .5
			if dataset.mhealth > dataset.health0 then
				return nil
			end
		end
		return dataset
	end,
	[1] = function(dataset, health, time)
		if not dataset or not dataset.health0 then
			return nil
		else
			return health * (dataset.time0 - dataset.mtime) / (dataset.mhealth - dataset.health0)
		end
	end 
}
jps.timeToDieFunctions["LeastSquared"] = { 
	[0] = function(dataset, health, time)	
		if not dataset or not dataset.n then
			dataset = {}
			dataset.n = 1
			dataset.time0, dataset.health0 = time, health
			dataset.mhealth = time * health
			dataset.mtime = time * time
		else
			dataset.n = dataset.n + 1
			dataset.time0 = dataset.time0 + time
			dataset.health0 = dataset.health0 + health
			dataset.mhealth = dataset.mhealth + time * health
			dataset.mtime = dataset.mtime + time * time
			local timeToDie = jps.timeToDieFunctions["LeastSquared"][1](dataset,health,time)
			if not timeToDie then
				return nil
			end
		end
		return dataset
	end,
	[1] = function(dataset, health, time)
		if not dataset or not dataset.n then
			return nil
		else
			local timeToDie = (dataset.health0 * dataset.mtime - dataset.mhealth * dataset.time0) / (dataset.health0 * dataset.time0 - dataset.mhealth * dataset.n) - time
			if timeToDie < 0 then
				return nil
			else
				return timeToDie
			end
		end
	end 
}
jps.timeToDieFunctions["WeightedLeastSquares"] = { 
	[0] = function(dataset, health, time)	
		if not dataset or not dataset.health0 then
			dataset = {}
			dataset.time0, dataset.health0 = time, health
			dataset.mhealth = time * health
			dataset.mtime = time * time
		else
			dataset.time0 = (dataset.time0 + time) * .5
			dataset.health0 = (dataset.health0 + health) * .5
			dataset.mhealth = (dataset.mhealth + time * health) * .5
			dataset.mtime = (dataset.mtime + time * time) * .5
			local timeToDie = jps.timeToDieFunctions["WeightedLeastSquares"][1](dataset,health,time)
			if not timeToDie then
				return nil
			end
		end
		return dataset
	end,
	[1] = function(dataset, health, time)
		if not dataset or not dataset.health0 then
			return nil
		else
		
			local timeToDie = (dataset.mtime * dataset.health0 - dataset.time0 * dataset.mhealth) / (dataset.time0 * dataset.health0 - dataset.mhealth) - time
			if timeToDie < 0 then
				return nil
			else
				return timeToDie
			end
		end
	end 
}

combatFrame:SetScript("OnEvent", jps_combatEventHandler)

------------------------
-- DETECT CLASS SPEC
------------------------

function jps.detectSpec()
	jps.Count = 1
	jps.Tooltip = "Click Macro /jps pew\nFor the Rotation Tooltip"
	jps.ToggleRotationName = {"No Rotations"}
	jps.MultiRotation = false
	jps.initializedRotation = false
	jps.firstInitializingLoop = true
	rotationDropdownHolder:Hide()

	jps.Race = UnitRace("player")
	jps.Class = UnitClass("player")
	jps.Level = Ternary(jps.Level > 1, jps.Level, UnitLevel("player"))
	if jps.Class then
		local id = GetSpecialization() -- remplace GetPrimaryTalentTree() patch 5.0.4
		if not id then 
			if jps.Level < 10 then 
				write("You need to be at least at level 10 and have a specialization choosen to use JPS, shutting down") 
				jps.Enabled = false
			else
				write("jps couldn't find your talent tree... One second please.") 
			end
		else
		-- local id, name, description, icon, background, role = GetSpecializationInfo(specIndex [, isInspect [, isPet]])
			local _,name,_,_,_,_ = GetSpecializationInfo(id) -- patch 5.0.4 remplace GetTalentTabInfo( id )
			if name then
				jps.Spec = name
				if jps.Spec then 
					write("Online for your",jps.Spec,jps.Class)
				end
			end
		end
	end
   if (GetLocale() == "frFR") then
	  jps.Rotation = jps_getCombatFunction_fr(jps.Class,jps.Spec)
   else
	  jps.Rotation = jps_getCombatFunction(jps.Class,jps.Spec)
   end
   if jps.Spec == L["Discipline"] or jps.Spec == L["Holy"] or jps.Spec == L["Restoration"] or jps.Spec == L["Mistweaver"] then jps.isHealer = true end
   if jps.Spec == L["Blood"] or jps.Spec == L["Protection"] or jps.Spec == L["Brewmaster"] or jps.Spec == L["Guardian"] then
	   jps.isTank = true
	   jps.gui_toggleDef(true) 
   end
   jps.HarmSpell = jps_GetHarmSpell()
   --write("jps.HarmSpell_","|cff1eff00",jps.HarmSpell)
   jps.setClassCooldowns()
   jps_VARIABLES_LOADED()
   if jps.initializedRotation == false then
	   jps_Combat()
	end
end

------------------------
-- SLASHCMDLIST
------------------------

function SlashCmdList.jps(cmd, editbox)
	local msg, rest = cmd:match("^(%S*)%s*(.-)$");
	if msg == "toggle" or msg == "t" then
		if jps.Enabled == false then msg = "e"
		else msg = "d" end
	end
	if msg == "config" then
	  InterfaceOptionsFrame_OpenToCategory(jpsConfigFrame)
	elseif msg == "show" then
	  jpsIcon:Show()
	  write("Icon set to show")
	elseif msg == "hide" then
	  jpsIcon:Hide()
	  write("Icon set to hide")
	elseif msg== "disable" or msg == "d" then
	  jps.Enabled = false
	  jps.gui_toggleEnabled(false)
	  print "jps Disabled."
	elseif msg== "enable" or msg == "e" then
	  jps.Enabled = true
	  jps.gui_toggleEnabled(true)
	  print "jps Enabled."
	elseif msg == "respec" then
	  jps.detectSpec()
	elseif msg == "multi" or msg == "aoe" then
	  jps.gui_toggleMulti()
	elseif msg == "cds" then
	  jps.gui_toggleCDs()
	elseif msg == "int" then
	  jps.gui_toggleInt()
	elseif msg == "pvp" then
	  jps.togglePvP()
	  write("PvP mode is now set to",tostring(jps.PvP))
	elseif msg == "def" then
   	  jps.gui_toggleDef()
	  write("Defensive set to",tostring(jps.Defensive))
	elseif msg == "heal" then
	  jps.isHealer = not jps.isHealer
	  write("Healing set to", tostring(jps.isHealer))
	elseif msg == "opening" then
		jps.Opening = not jps.Opening
		write("Opening flag set to",tostring(jps.Opening))
	elseif msg == "fishing" or msg == "fish" then
	  jps.Fishing = not jps.Fishing
	  write("Murglesnout & Grey Deletion now", tostring(jps.Fishing))
	elseif msg == "debug" then
	  jps.Debug = not jps.Debug
	  write("Debug mode set to",tostring(jps.Debug))
	elseif msg == "face" then
		jps.gui_toggleRot()
		write("jps.FaceTarget set to",tostring(jps.FaceTarget))
	elseif msg == "db" then
   		jps.ResetDB = not jps.ResetDB
   		jps_VARIABLES_LOADED()
   		write("jps.ResetDB set to",tostring(jps.ResetDB))
   		jps.Macro("/reload")
	elseif msg == "ver"  or msg == "version" or msg == "revision" or msg == "v" then
		write("You have JPS version: "..jps.Version..", revision: "..jps.Revision)
	elseif msg == "opening" then
		jps.Opening = not jps.Opening
		write("Opening flag is now set to",tostring(jps.Opening))
	elseif msg == "size" then
		jps.resize( rest )
	elseif msg == "reset" then
		jps.resetView()
	elseif msg == "help" then
		write("Slash Commands:")
		write("/jps - Show enabled status.")
		write("/jps enable/disable - Enable/Disable the addon.")
		write("/jps spam - Toggle spamming of a given macro.")
		write("/jps cds - Toggle use of cooldowns.")
		write("/jps pew - Spammable macro to do your best moves, if for some reason you don't want it fully automated")
		write("/jps interrupts - Toggle interrupting")
		write("/jps reset - reset position of jps icons and UI")
		write("/jps db - cleares your local jps DB")
		write("/jps help - Show this help text.")
	elseif msg == "pew" then
	  	jps_Combat()
	else
		if jps.Enabled then
			print("jps Enabled - Ready and Waiting.")
		else 
			print "jps Disabled - Waiting on Standby."
		end
	end
end

-- Create the frame that does all the work
JPSFrame = CreateFrame("Frame", "JPSFrame")
JPSFrame:SetScript("OnUpdate", function(self, elapsed)
	if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	if (self.TimeSinceLastUpdate > jps.UpdateInterval) then
		if GetAddOnMemoryUsage("JPS") > 1000 then collectgarbage("collect") end
		updateTimeToDie()
	  	if jps.Combat and jps.Enabled then
		 	jps_Combat() 
		 	self.TimeSinceLastUpdate = 0
		end
   	end
end)

local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
   return unpack(spellcache[a])
end

hooksecurefunc("UseAction", function(...)
if jps.Enabled and (select(3, ...) ~= nil) and (InCombatLockdown()==1) and jps.IsCasting("player") then
   local stype,id,_ = GetActionInfo( select(1, ...) )
   if stype == "spell" then
	  local name = select(1,GetSpellInfo(id))
	  if jps.NextSpell[#jps.NextSpell] ~= name then -- # valable que pour table ipairs table[1]
		 table.insert(jps.NextSpell, name)
		 if jps.Combat then write("Set",name,"for next cast.") end
	  end
   end
end
end)

------------------------
-- COMBAT
------------------------

function jps_Combat() 
   -- Check for the Rotation
   if not jps.Class then return end
   if not jps.Rotation then
	  write("JPS does not have a rotation for your",jps.Spec,jps.Class)
	  jps.Enabled = false
	  return 
   end
   
   -- STOP spam Combat -- or (jps.checkTimer( "PLAYER_CONTROL_LOST" ) > 0) IF RETURN END NEVER PVP TRINKET
   if (IsMounted() == 1 and jps.getConfigVal("dismount in combat") == 0) or UnitIsDeadOrGhost("player")==1 or jps.buff(L["Drink"],"player") then return end
   
   -- Check spell usability 
   if string.len(jps.customRotationFunc) > 10 then
	   jps.ThisCast,jps.Target = jps.customRotation() 
   else
	   jps.ThisCast,jps.Target = jps.Rotation() -- ALLOW SPELLSTOPCASTING() IN JPS.ROTATION() TABLE
   end
   if jps.firstInitializingLoop == true then
	   jps.firstInitializingLoop = false
	   return nil
	end
   -- RAID UPDATE
	jps.UpdateHealerBlacklist()
   
   -- Movement
   jps.Moving = GetUnitSpeed("player") > 0
   jps.MovingTarget = GetUnitSpeed("target") > 0
   
   -- LagWorld
   jps.Lag = select(4,GetNetStats()) -- amount of lag in milliseconds local down, up, lagHome, lagWorld = GetNetStats()
   jps.Lag = jps.Lag/100
   
   -- Casting
   if UnitCastingInfo("player")~= nil or UnitChannelInfo("player")~= nil then jps.Casting = true
   else jps.Casting = false
   end

   if not jps.Casting and jps.ThisCast ~= nil then
	  if #jps.NextSpell >= 1 then
		 if jps.NextSpell[1] then
			jps.Cast(jps.NextSpell[1])
			table.remove(jps.NextSpell, 1)
		 else
			jps.NextSpell[1] = nil
		 end
	  else
		 jps.Cast(jps.ThisCast)
	  end
   end
   
--   if jps.ThisCast ~= nil and not jps.Casting then
--	  if jps.NextCast ~= nil and jps.NextCast ~= jps.ThisCast then
--		 jps.Cast(jps.NextCast)
--		 jps.NextCast = nil
--	   else
--		  jps.Cast(jps.ThisCast)
--	  end
--   end
   
   -- Hide Error
   StaticPopup1:Hide()
   
   -- Return spellcast.
   return jps.ThisCast,jps.Target
end