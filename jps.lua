-- JPS, PLua DPS Addon by jpganis
-- Huge thanks to everyone who's helped out on this, <3
-- Universal
jps = {}
jps.Version = "1.1.0"
jps.Revision = "r251"
jps.RaidStatus = {}
jps.UpdateInterval = 0.1
jps.Combat = false
jps.Class = nil
jps.Spec = nil
jps.Race = nil
jps.Rotation = nil
jps.Interrupts = true
jps.Debug = false
-- Utility
jps.Target = nil
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
-- Misc.
jps.MacroSpam = false
jps.Fishing = false
jps.Macro = "jpsMacro"
jps.HealerBlacklist = {}
-- Config.
jps_variablesLoaded = false
jpsName = UnitName("player")
jpsRealm = GetCVar("realmName")
jps_saveVars = {
	{ "Enabled", true },
	{ "Interrupts", true },
	{ "UseCDs", false },
	{ "PvP", false },
	{ "MultiTarget", false },
	{ "ExtraButtons", true },
	{ "ButtonGrowthDir", "right" },
	{ "IconSize", 36 },
}

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


function write(...)
	DEFAULT_CHAT_FRAME:AddMessage("|cffff8000JPS: " .. strjoin(" ", tostringall(...)));
end

function combatEventHandler(self, event, ...)
	if event == "PLAYER_LOGIN" then
		NotifyInspect("player")

	elseif event == "INSPECT_READY" then
		jps.detectSpec()
		jps.setClassCooldowns()
		if jps_variablesLoaded then
			jps_createConfigFrame() end
	
	elseif event == "VARIABLES_LOADED" then
		jps_VARIABLES_LOADED()
		if jps.Spec then
			jps_createConfigFrame() end
	
	elseif event == "ADDON_ACTION_FORBIDDEN" then
		write("JPS' actions have been forbidden - either you haven't got Protected LUA enabled, or you're doing something really, really terrible.")
		jps.Enabled = false
		
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
		if jps.Error == "You must be behind your target." and jps.ThisCast == "shred" then
			jps.Cast("mangle(cat form)")
		elseif jps.Error == "You must be behind your target." and (jps.ThisCast == "backstab" or jps.ThisCast == "garrote") then
			jps.Cast("mutilate")
		end

	-- RaidStatus Update
	elseif event == "UNIT_HEALTH" and jps.Enabled then
		local unit = ...
        if UnitIsFriend("player",unit) then
			local delta = 0
			local hp = jps.hpInc(unit)

			if jps.RaidStatus[unit] then
				delta = jps.RaidStatus[unit]["hp"] - hp end
			jps.RaidStatus[unit] = { ["hp"] = hp, ["hpabs"] = UnitHealth(unit), ["hpmax"] = UnitHealthMax(unit), ["delta"] = delta }
		end 

	-- Dual Spec Respec
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		jps.detectSpec()

	-- On Logout
	elseif event == "PLAYER_LEAVING_WORLD" then
		jps_SAVE_PROFILE()

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
		jps.Interrupts = not jps.Interrupts
		write("Interrupt use set to",tostring(jps.Interrupts))
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

function combat(self) 
	-- Check for the Rotation
	if not jps.Rotation then
		write("Sorry! The rotation file for your",jps.Spec,jps.Class.." seems to be corrupted. Please send Jp (iLulz) a bug report, and make sure you have \"Display LUA Errors\" enabled, you'll find this option by going to the WoW Interface Menu (by pressing Escape) and going to Help -> Display LUA Errors. Thank you!")
		jps.Enabled = false
		return
	end

	-- Lag
	_,_,jps.Lag = GetNetStats()
	jps.Lag = jps.Lag/100
	
	-- Movement
	jps.Moving = GetUnitSpeed("player") > 0

	-- Casting
	if UnitCastingInfo("player") then jps.Casting = true
	elseif UnitChannelInfo("player") then jps.Casting = true
	else jps.Casting = false
	end
	
	-- Get spell from rotation
	jps.ThisCast = jps.Rotation()
	
	-- Check spell usability
	if jps.ThisCast and not jps.Casting and cd(jps.ThisCast) == 0 then
		if jps.NextCast ~= nil and jps.NextCast ~= jps.ThisCast then
			jps.Cast(jps.NextCast)
			jps.NextCast = nil
        else
            if jps.Debug then print(jps.ThisCast," on ", jps.Target) end
			jps.Cast(jps.ThisCast)
		end
   	end
	
	-- Hide Error
	StaticPopup1:Hide()
	
	-- Return spellcast.
	return jps.ThisCast
end
