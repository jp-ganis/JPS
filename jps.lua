-- Universal
jps = {}
jps.Version = "0.9.2"
jps.RaidStatus = {}
jps.UpdateInterval = 0.2
jps.Combat = false
jps.Class = nil
jps.Spec = nil
jps.Interrupts = true
jps.PVPInterrupt = false
jps.Debug = false
jps.Lag = 0
-- Utility
jps.Target = nil
jps.Casting = false
jps.LastCast = nil
jps.ThisCast = nil
jps.NextCast = nil
jps.Error = nil
jps.Lag = nil
jps.Moving = nil
jps.IconSpell = nil
-- Class Specific
jps.Opening = false
-- Misc.
jps.MacroSpam = false
jps.Fishing = false
jps.Macro = "jpsMacro"
jps.OutOfSightPlayers = {}

-- Slash Cmd
SLASH_jps1 = '/jps'

-- Function Shorthands
cd = GetSpellCooldown
ub = UnitBuff
ud = UnitDebuff

combatFrame = CreateFrame("FRAME", nil)
combatFrame:RegisterEvent("PLAYER_LOGIN")
combatFrame:RegisterEvent("ADDON_LOADED");
combatFrame:RegisterEvent("PLAYER_LOGOUT");
combatFrame:RegisterEvent("PLAYER_ALIVE")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
--combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatFrame:RegisterEvent("UI_ERROR_MESSAGE")
combatFrame:RegisterEvent("UNIT_HEALTH")
combatFrame:RegisterEvent("BAG_UPDATE")


function write(...)
	DEFAULT_CHAT_FRAME:AddMessage("|cffff8000JPS: " .. strjoin(" ", ...), 1, 1, 1);
end

function combatEventHandler(self, event, ...)
    if event == "PLAYER_LOGIN" then
        jps.Class = UnitClass("player")
				jps.detectSpec()
    elseif event == "PLAYER_REGEN_DISABLED" then
        jps.Combat = true
		jps.toggleCombat(true)
        if jps.Enabled then combat() end
    elseif event == "PLAYER_REGEN_ENABLED" then
		jps.toggleCombat(false)
        jps.Combat = false
        jps.Opening = true
        jps.RaidStatus = {}
        collectgarbage("collect")
    -- Fishes
    elseif event == "BAG_UPDATE" and jps.Fishing then
        RunMacro("MG")
        RunMacro("MGG")
    -- UI Error checking - for LoS and Shred-fails.
    elseif event == "UI_ERROR_MESSAGE" and jps.Enabled then
        jps.Error = ...
        if jps.Error == "You must be behind your target." and jps.ThisCast == "shred" then
            jps.Cast("mangle(cat form)")
        elseif jps.Error == "You must be behind your target." and (jps.ThisCast == "backstab" or jps.ThisCast == "garrote") then
            jps.cast("mutilate")
        end
    -- RaidStatus Update
    elseif event == "UNIT_HEALTH" and jps.Enabled then
        local unit = ...
        if UnitIsFriend("player",unit) then
            jps.RaidStatus[unit] = { ["hp"] = UnitHealth(unit), ["hpmax"] = UnitHealthMax(unit), ["freshness"] = 0 }
        end
	-- Dual Spec Respec
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		jps.detectSpec()
	
	-- ADDON_LOADED
	elseif event == "ADDON_LOADED" and ... == "JPS" then
		if jpsIconSize == nil then
			jpsIconSize = 36
			jps.IconSize = jpsIconSize
			jpsIcon:SetWidth(jps.IconSize)
			jpsIcon:SetHeight(jps.IconSize)
		else
			jps.IconSize = jpsIconSize 
			jpsIcon:SetWidth(jps.IconSize)
			jpsIcon:SetHeight(jps.IconSize)
		end
		-- jpsOptions
		if jpsEnabled == nil then jps.toggleEnabled(true)   else jps.toggleEnabled(jpsEnabled) end
		if jpsUseCDs == nil then jps.toggleCDs(true)        else jps.toggleCDs(jpsUseCDs) end
		if jpsMultiTarget == nil then jps.toggleMulti(false) else jps.toggleMulti(jpsMultiTarget) end
		if jpsToggles == nil then jps.toggleToggles(true)   else jps.toggleToggles(jpsToggles) end
		if jpsToggleDir == nil then jps.setToggleDir("right") else jps.setToggleDir(jpsToggleDir) end
		if jpsIconSize == nil then jps.resize(36) else jps.resize(jpsIconSize) end
		
		
	-- On Logout
	elseif event == "PLAYER_LOGOUT" then
		jpsIconSize = jps.IconSize
		jpsEnabled = jps.Enabled
		jpsMultiTarget = jps.MultiTarget
		jpsUseCDs = jps.UseCDs
		jpsToggleDir = jps.ToggleDir
	end
end

function jps.detectSpec()
	jps.Spec = jps.Specs[jps.Class][GetPrimaryTalentTree()]
	if jps.Spec then write("Online for your",jps.Spec,jps.Class) end
end

combatFrame:SetScript("OnEvent", combatEventHandler)

function SlashCmdList.jps(cmd, editbox)
	local msg, rest = cmd:match("^(%S*)%s*(.-)$");
    if msg == "toggle" or msg == "t" then
        if jps.Enabled == false then msg = "e"
        else msg = "d" end
    end
    if msg == "disable" or msg == "d" then
		jps.toggleEnabled(false)
    elseif msg == "enable" or msg == "e" then
        jps.NextCast = nil
		jps.toggleEnabled(true)
	elseif msg == "respec" then
		jps.detectSpec()
    elseif msg == "fishing" then
        jps.Fishing = not jps.Fishing
        write("Murglesnout & Grey Deletion now",jps.Fishing)
    elseif msg == "debug" then
        jps.Debug = not jps.Debug
        write("Debug mode set to",jps.Debug)
    elseif msg == "multi" or msg == "multitarget" then
        jps.toggleMulti()
    elseif msg == "cds" then
		jps.toggleCDs()
    elseif msg == "int" or msg == "interrupts" then
        jps.Interrupts = not jps.Interrupts
        write("Interrupt use set to",jps.Interrupts)
    elseif msg == "pint" then
        jps.PVPInterrupt = not jps.PVPInterrupt
        write("PVP Interrupt use set to",jps.PVPInterrupt)
    elseif msg == "spam" or msg == "macrospam" or msg == "macro" then
        jps.MacroSpam = not jps.MacroSpam
        write("MacroSpam flag is now set to",jps.MacroSpam)
    elseif msg == "opening" then
        jps.Opening = not jps.Opening
        write("Opening flag is now set to",jps.Opening)
	elseif msg == "size" then
		jps.resize( rest )
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
        if jps.Enabled then
            write("JPS v"..jps.Version.." Enabled - Ready and Waiting.")
        else 
            write "JPS Disabled - Waiting on Standby."
        end
        write("jps.UseCDs:",jps.UseCDs)
        write("jps.Opening:",jps.Opening)
        write("jps.Interrupts:",jps.Interrupts)
        write("jps.MacroSpam:",jps.MacroSpam)
        write("jps.Fishing:",jps.Fishing)
		write("Use /jps help for help.")
    end
end

function JPS_OnUpdate(self,elapsed)
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
    if (self.TimeSinceLastUpdate > jps.UpdateInterval) then
        if jps.MacroSpam and not jps.Casting then
            RunMacro(jps.Macro)
        elseif jps.Combat and jps.Enabled then
            combat()
            self.TimeSinceLastUpdate = 0
        end
    end
end

function combat(self) 
    -- Rotations
	if jps.Rotations == nil then
    	jps.Rotations = { 
    	    ["Druid"]        = { ["Feral"]         = druid_feral,
    	                         ["Balance"]       = druid_balance,
    	                         ["Restoration"]   = druid_resto },
    	    
    	    ["Death Knight"] = { ["Blood"]         = dk_blood,
    	                         ["Frost"]         = dk_frost  },
    	        
    	    ["Shaman"]       = { ["Enhancement"]   = shaman_enhancement,
    	                         ["Elemental"]     = shaman_elemental },
    	    
    	    ["Paladin"]      = { ["Protection"]    = paladin_protadin,
    	                         ["Retribution"]   = paladin_ret },
    	    
    	    ["Warlock"]      = { ["Affliction"]    = warlock_affl,
    	                         ["Destruction"]   = warlock_destro,
    	                         ["Demonology"]    = warlock_demo },
    	    
    	    ["Hunter"]       = { ["Beast Mastery"] = hunter_bm,
    	                         ["Marksmanship"]  = hunter_mm,
    	                         ["Survival"]      = hunter_sv },
    	                
    	    ["Mage"]         = { ["Fire"]          = mage_fire,
    	                         ["Arcane"]        = mage_arcane,
    	                         ["Frost"]         = mage_frost },
    	                        
    	    ["Rogue"]        = { ["Assassination"] = rogue_assass },
    	    
    	    ["Warrior"]      = { ["Fury"]          = warrior_fury,
    	                         ["Protection"]    = warrior_prot,
    	                         ["Arms"]          = warrior_arms },
    	                        
    	    ["Priest"]       = { ["Shadow"]        = priest_shadow,
    	                         ["Holy"]          = priest_holy }
    	}
	end
    
    -- Check for the Rotation
    if not jps.Rotations[jps.Class] or not jps.Rotations[jps.Class][jps.Spec] then
        write("Sorry! JPS does not yet have a rotation for your",jps.Spec,jps.Class.."...yet.")
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
    
    -- Get spell from rotation.
    jps.ThisCast = jps.Rotations[jps.Class][jps.Spec]()
    
    -- Check spell usability.
    if jps.ThisCast then
        jps.Cast(jps.ThisCast)
    end
    
    -- Hide Error
    StaticPopup1:Hide()
    
    -- Return spellcast.
    return jps.ThisCast
end