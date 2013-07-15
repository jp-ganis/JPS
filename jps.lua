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
local L = MyLocalizationTable
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
jps.detectSpecDisabled = false

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
jps.HealerBlacklist = {}
jps.Timers = {}
Healtable = {}
jps.EnemyTable =  {}
jps.RaidTimeToDie = {}
jps.RaidTimeToLive = {}
jps.initializedRotation = false
jps.firstInitializingLoop = true
jps.settings = {}
jps.settingsQueue = {}
jps.combatStart = 0
jps.RaidMode = false

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

-- Latency
jps.CastBar = {}
jps.CastBar.latency = 0
jps.CastBar.nextSpell = ""
jps.CastBar.nextTarget = ""
jps.CastBar.currentSpell = ""
jps.CastBar.currentTarget = ""
jps.CastBar.currentMessage = ""

-- Slash Cmd
SLASH_jps1 = '/jps'


function write(...)
   DEFAULT_CHAT_FRAME:AddMessage("|cffff8000JPS: " .. strjoin(" ", tostringall(...))); -- color orange
end
function macrowrite(...)
   DEFAULT_CHAT_FRAME:AddMessage("|cffff8000MACRO: " .. strjoin(" ", tostringall(...))); -- color orange
end

function updateTimeToDie(elapsed, unit)
	if not unit then
			updateTimeToDie(elapsed, "target")
			updateTimeToDie(elapsed, "focus")
			updateTimeToDie(elapsed, "mouseover")
			for id = 1, 4 do
				updateTimeToDie(elapsed, "boss" .. id)
			end
			if jps.isHealer then
				for id = 1, 4 do
					updateTimeToDie(elapsed, "party" .. id)
					updateTimeToDie(elapsed, "partypet" .. id)
				end
				for id = 1, 5 do
					updateTimeToDie(elapsed, "arena" .. id)
					updateTimeToDie(elapsed, "arenapet" .. id)
				end
				for id = 1, 40 do
					updateTimeToDie(elapsed, "raid" .. id)
					updateTimeToDie(elapsed, "raidpet" .. id)
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
--[[JPSEVENT
combatFrame:SetScript("OnEvent", jps_combatEventHandler)
]]
------------------------
-- DETECT CLASS SPEC
------------------------

function jps.detectSpec()
	if jps.detectSpecDisabled then return false end
	
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
				jps.detectSpecDisabled = true
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
	elseif msg == "raid"  or msg == "raidmode" then
		jps.RaidMode = not jps.RaidMode
		if jps.RaidMode then
			write("Raid Mode is now enabled")
		else
			write("Raid Mode is now disabled")
		end
		
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
   if not jps.activeRotation() then
	  write("JPS does not have a rotation for your",jps.Spec,jps.Class)
	  jps.Enabled = false
	  return 
   end
   
   if (IsMounted() == 1 and jps.getConfigVal("dismount in combat") == 0) or UnitIsDeadOrGhost("player")==1 or jps.buff(L["Drink"],"player") then return end
	-- LagWorld
	jps.Lag = select(4,GetNetStats())/1000 -- amount of lag in milliseconds local down, up, lagHome, lagWorld = GetNetStats()
	-- Casting
	-- if UnitCastingInfo("player")~= nil or UnitChannelInfo("player")~= nil then jps.Casting = true else jps.Casting = false end
	local latency = jps.CastBar.latency
	if jps.ChannelTimeLeft() > 0 then
		jps.Casting = true
	elseif (jps.CastTimeLeft() - latency) > 0 then 
		jps.Casting = true
	else
		jps.Casting = false
	end
   -- Check spell usability 
   if string.len(jps.customRotationFunc) > 10 then
	   jps.ThisCast,jps.Target = jps.customRotation() 
   else
	   jps.ThisCast,jps.Target =  jps.activeRotation().getSpell()
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
   
   -- Return spellcast.
   return jps.ThisCast,jps.Target
end