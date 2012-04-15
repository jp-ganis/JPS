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
jps.Version = "1.2.0"
jps.Revision = "r348"
jps.RaidStatus = {}
jps.UpdateInterval = 0.05
jps.Combat = false
jps.Class = nil
jps.Spec = nil
jps.Race = nil
jps.Rotation = nil
jps.PVPInterrupt = false
jps.Interrupts = true
jps.Debug = false
jps.PLuaFlag = false
jps.MoveToTarget = false
jps.FaceTarget = false
-- Utility
jps.Target = nil
jps.LastTarget = nil
jps.Casting = false
jps.LastCast = nil
jps.ThisCast = nil
jps.NextCast = nil
jps.Error = nil
jps.Lag = 0
jps.Moving = nil
jps.IconSpell = nil
jps.Timers = {}
jps.DPSRacial = nil
jps.DefRacial = nil
jps.Lifeblood = nil
jps.EngiGloves = nil
-- Class Specific
jps.Opening = true
jps.Healing = false
-- Misc.
jps.MacroSpam = false
jps.Fishing = false
jps.Macro = "jpsMacro"
jps.HealerBlacklist = {}
jps.BlacklistTimer = 2
jps.BlankCheck = false
healtable = {}

-- Config.
jps.Configged = false
jps_variablesLoaded = false
jpsName = UnitName("player")
jpsRealm = GetCVar("realmName")

-- Slash Cmd
SLASH_jps1 = '/jps'

-- Function Shorthands
cd = GetSpellCooldown
ub = UnitBuff
ud = UnitDebuff

combatFrame = CreateFrame("FRAME", nil)
combatFrame:RegisterEvent("PLAYER_LOGIN")
combatFrame:RegisterEvent("VARIABLES_LOADED")
combatFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
combatFrame:RegisterEvent("PLAYER_ALIVE")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:RegisterEvent("UI_ERROR_MESSAGE")
combatFrame:RegisterEvent("INSPECT_READY")
combatFrame:RegisterEvent("UNIT_HEALTH")
combatFrame:RegisterEvent("BAG_UPDATE")
combatFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
combatFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatFrame:RegisterEvent("PLAYER_CONTROL_GAINED") -- Fires after the PLAYER_CONTROL_LOST event, when control has been restored to the player
combatFrame:RegisterEvent("PLAYER_CONTROL_LOST") -- Fires whenever the player is unable to control the character
combatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

function write(...)
	if jps.BlankCheck then return end
	DEFAULT_CHAT_FRAME:AddMessage("|cffff8000JPS: " .. strjoin(" ", tostringall(...)));
end

function combatEventHandler(self, event, ...)
	if jps.Enabled == false then return end

	if event == "PLAYER_LOGIN" then
		NotifyInspect("player")
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		jps.SortRaidStatus()
		reset_healtable()

	elseif event == "INSPECT_READY" then
		if not jps.Spec then 
			jps.detectSpec()
			jps.setClassCooldowns()
		end
		if jps_variablesLoaded and not jps.Configged then
			jps_createConfigFrame() end
	
	elseif event == "VARIABLES_LOADED" then
		jps_VARIABLES_LOADED()
		if jps.Spec then
			jps_createConfigFrame() end
	
	elseif event == "ADDON_ACTION_FORBIDDEN" then
		jps.PLuaFlag = true
		
	elseif event == "PLAYER_REGEN_DISABLED" then
		jps.Combat = true
		jps.gui_toggleCombat(true)
		if jps.Enabled then combat() end

	elseif event == "PLAYER_REGEN_ENABLED" then
		jps.gui_toggleCombat(false)
		jps.Combat = false
		jps.Opening = true
		jps.RaidStatus = {}
		collectgarbage("collect")
		
	elseif event == "PLAYER_CONTROL_LOST" then
    		jps.Combat = false
    		jps.gui_toggleCombat(false)

	elseif event == "PLAYER_CONTROL_GAINED" then
    		jps.Combat = true
    		jps.gui_toggleCombat(true)

	-- Fishes
	elseif event == "BAG_UPDATE" and jps.Fishing then
		for bag = 0,4,1 do
		  for slot = 1, GetContainerNumSlots(bag), 1 do
			local name = GetContainerItemLink(bag,slot)
			  if name and (string.find(name,"ff9d9d9d") or string.find(name,"Murglesnout")) then
				PickupContainerItem(bag,slot)
				DeleteCursorItem()
			  end 
			end 
		end 

	-- UI Error checking - for LoS and Shred-fails.
	elseif event == "UI_ERROR_MESSAGE" and jps.Enabled then
		jps.Error = ...
		if jps.Error == "You must be behind your target." and jps.Class == "Druid" then
			jps.Cast("mangle(cat form)")
		elseif jps.Error == "You must be behind your target." and (jps.ThisCast == "backstab" or jps.ThisCast == "garrote") then
			if jps.Spec == "Assassination" then jps.Cast("mutilate")
			elseif jps.Spec == "Subtlety" then jps.Cast("hemorrhage") end
		elseif (jps.FaceTarget or jps.MoveToTarget) and (jps.Error == "You are facing the wrong way!" or jps.Error == "Target needs to be in front of you.") then
			jps.faceTarget()
		elseif (jps.Error == "Out of range." or jps.Error == "You are too far away!") and jps.MoveToTarget then
			jps.moveToTarget()
		end

		jps.Error = nil
		
	-- RaidStatus Update
    elseif event == "UNIT_HEALTH" and jps.Enabled then
    	jps.UpdateHealerBlacklist()
    	if jps.Spec == "Restoration" or jps.Spec == "Holy" or jps.Spec == "Discipline" then jps.Healing = true end
 		
        local unit = ...
        if jps.canHeal(unit) and jps.Enabled and jps.Healing then combat() end -- and jps.Combat

	-- Dual Spec Respec
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		jps.detectSpec()

	-- On Logout
	elseif event == "PLAYER_LEAVING_WORLD" then
		jps_SAVE_PROFILE()

	-- Combat Event Handler
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local eventtable =  {...}
    	EventHandler_player(...)
        local eventtable =  {...}

       -- Update out of sight players before selecting a spell -- Required For Healing Classes
        if eventtable[2] == "SPELL_CAST_FAILED" and eventtable[5]== GetUnitName("player") and eventtable[15]== "Target not in line of sight" then
		jps.BlacklistPlayer(jps.LastTarget)
        end
    	-- HEALTABLE -- contains the average value of healing spells
        if eventtable[5] == GetUnitName("player") and (eventtable[2] == "SPELL_HEAL" or eventtable[2] == "SPELL_PERIODIC_HEAL") then
		update_healtable(...)
        end
    end
end

function jps.detectSpec()
	jps.Race = UnitRace("player")
	jps.Class = UnitClass("player")
	if jps.Class then
		local id = GetPrimaryTalentTree()
		if not id then write("JPS couldn't find your talent tree... One second please.") 
		else
			local _,name,_,_,_,_,_,_ = GetTalentTabInfo( id )
			if name then
				jps.Spec = name
				if jps.Spec then write("Online for your",jps.Spec,jps.Class) end
			end
		end
	end
	jps.Rotation = jps_getCombatFunction( jps.Class,jps.Spec )
	jps_VARIABLES_LOADED()
end

combatFrame:SetScript("OnEvent", combatEventHandler)

function SlashCmdList.jps(cmd, editbox)
	local msg, rest = cmd:match("^(%S*)%s*(.-)$");
	if msg == "toggle" or msg == "t" then
		if jps.Enabled == false then msg = "e"
		else msg = "d" end end
	if msg == "config" then
		InterfaceOptionsFrame_OpenToCategory(jpsConfigFrame)
	elseif msg == "disable" or msg == "d" then
		jps.gui_toggleEnabled(false)
	elseif msg == "enable" or msg == "e" then
		jps.gui_toggleEnabled(true)
	elseif msg == "respec" then
		jps.detectSpec()
	elseif msg == "suppress" then
		write("Printing output now set to",not jps.BlankCheck)
		jps.BlankCheck = not jps.BlankCheck
	elseif msg == "hide" then
		jpsIcon:Hide()
	elseif msg == "show" then
		jpsIcon:Show()
	elseif msg == "fishing" then
		jps.Fishing = not jps.Fishing
		write("Murglesnout & Grey Deletion now", tostring(jps.Fishing))
	elseif msg == "debug" then
		jps.Debug = not jps.Debug
		write("Debug mode set to",tostring(jps.Debug))
	elseif msg == "multi" or msg == "multitarget" or msg == "aoe" then
		jps.gui_toggleMulti()
	elseif msg == "cds" then
		jps.gui_toggleCDs()
	elseif msg == "int" or msg == "interrupts" then
		jps.gui_toggleInt()
	elseif msg == "pint" then
		jps.PVPInterrupt = not jps.PVPInterrupt
		write("PVP Interrupt use set to",tostring(jps.PVPInterrupt))
	elseif msg == "spam" or msg == "macrospam" or msg == "macro" then
		jps.MacroSpam = not jps.MacroSpam
		write("MacroSpam flag is now set to",tostring(jps.MacroSpam))
	elseif msg == "pvp" then
		jps.togglePvP()
		write("PvP mode is now set to",tostring(jps.PvP))
	elseif msg == "version" or msg == "revision" or msg == "v" then
		write("You have JPS revision",tostring(jps.Revision))
	elseif msg == "opening" then
		jps.Opening = not jps.Opening
		write("Opening flag is now set to",tostring(jps.Opening))
	elseif msg == "size" then
		jps.resize( rest )
	elseif msg == "def" or msg == "defensive" then
		jps.Defensive = not jps.Defensive
		write("Defensive cooldown usage set to", tostring(jps.Defensive))
	elseif msg == "heal" then
		jps.Healing = not jps.Healing
		write("Healing set to", tostring(jps.Healing))
	elseif msg == "help" then
		write("Slash Commands:")
		write("/jps - Show enabled status.")
		write("/jps enable/disable - Enable/Disable the addon.")
		write("/jps spam - Toggle spamming of a given macro.")
		write("/jps cds - Toggle use of cooldowns.")
		write("/jps pew - Spammable macro to do your best moves, if for some reason you don't want it fully automated")
		write("/jps interrupts - Toggle interrupting")
		write("/jps help - Show this help text.")
	elseif msg == "pew" then
		combat()
	else
		InterfaceOptionsFrame_OpenToCategory(jpsConfigFrame)
	end
end

function JPS_OnUpdate(self,elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	if (self.TimeSinceLastUpdate > jps.UpdateInterval) then

		if jps.MacroSpam and not jps.Casting then
			RunMacro(jps.Macro)
			self.TimeSinceLastUpdate = 0

		elseif jps.Combat and jps.Enabled then
			if not IsMounted() then combat() end
			self.TimeSinceLastUpdate = 0

		end
	end
end

local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
	return unpack(spellcache[a])
end

-- get spell from UseAction
hooksecurefunc("UseAction", function(...)
if jps.Enabled and select(3, ...) ~= nil then
	local stype, id = GetActionInfo( select(1, ...) )
	if stype == "spell" then
		local name,_,_,_,_,_,_,_,_ = GetSpellInfo(id)
		if jps.NextCast ~= name then 
			jps.NextCast = name
			if jps.Combat then write("Set",name,"for next cast.") end
		end
	end
end
end)

function combat(self) 
	-- Check for the Rotation
	if not jps.Class then return end
	if not jps.Rotation then
		write("Sorry! The rotation file for your",jps.Spec,jps.Class.." seems to be corrupted. Please send Jp (iLulz) a bug report, and make sure you have \"Display LUA Errors\" enabled, you'll find this option by going to the WoW Interface Menu (by pressing Escape) and going to Help -> Display LUA Errors. Thank you!")
		jps.Enabled = false
		return
	end
	
	-- Table RaidStatus
	if jps.Healing then jps.SortRaidStatus() end

	-- Lag
	jps.Lag = select(4,GetNetStats())
	jps.Lag = jps.Lag/100
	
	-- Movement
	jps.Moving = GetUnitSpeed("player") > 0

	-- Casting
	if UnitCastingInfo("player") or UnitChannelInfo("player") then jps.Casting = true
	else jps.Casting = false
	end
	
	-- STOP spam Combat
	if IsMounted() or UnitIsDeadOrGhost("player")==1 or jps.buff("Boisson", "player") or jps.buff("Drink", "player") then return end
	
	-- Get spell from rotation
	jps.ThisCast = jps.Rotation()
	
	-- Check spell usability
	if jps.ThisCast and not jps.Casting and cd(jps.ThisCast) == 0 then
		if jps.NextCast ~= nil and jps.NextCast ~= jps.ThisCast then
			jps.Cast(jps.NextCast)
			jps.NextCast = nil
        	else
            		if jps.Debug then write("|cffa335ee",jps.ThisCast," on ",jps.Target) end
            		jps.Cast(jps.ThisCast)
		end
   	end
	
	-- Hide Error
	StaticPopup1:Hide()
	
	-- Return spellcast.
	return jps.ThisCast
end
