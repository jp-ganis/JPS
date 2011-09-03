-- JPS, PLua DPS Addon by jpganis
-- Huge thanks to everyone who's helped out on this, <3
-- Universal
jps = {}
jps.Version = "1.0.0"
jps.Revision = "r231"
jps.RaidStatus = {}
jps.UpdateInterval = 0.1
jps.Combat = false
jps.Class = nil
jps.Spec = nil
jps.Interrupts = true
jps.PVPInterrupt = false
jps.PvP = false
jps.Debug = false
jps.Defensive = false
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
-- Class Specific
jps.Opening = true
-- Misc.
jps.MacroSpam = false
jps.Fishing = false
jps.Macro = "jpsMacro"
jps.HealerBlacklist = {}
jps.BlacklistTimer = 2

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
combatFrame:RegisterEvent("UI_ERROR_MESSAGE")
combatFrame:RegisterEvent("INSPECT_READY")
combatFrame:RegisterEvent("UNIT_HEALTH")
combatFrame:RegisterEvent("BAG_UPDATE")
combatFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")


function write(...)
	DEFAULT_CHAT_FRAME:AddMessage("|cffff8000JPS: " .. strjoin(" ", tostringall(...)));
end

function combatEventHandler(self, event, ...)
	if event == "PLAYER_LOGIN" then
		NotifyInspect("player")
		
	elseif event == "INSPECT_READY" then
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
		if jpsEnabled == nil then jps.toggleEnabled(true)	else jps.toggleEnabled(jpsEnabled) end
		if jpsUseCDs == nil then jps.toggleCDs(true)		else jps.toggleCDs(jpsUseCDs) end
		if jpsMultiTarget == nil then jps.toggleMulti(false) else jps.toggleMulti(jpsMultiTarget) end
		if jpsToggles == nil then jps.toggleToggles(true)	else jps.toggleToggles(jpsToggles) end
		if jpsToggleDir == nil then jps.setToggleDir("right") else jps.setToggleDir(jpsToggleDir) end
		if jpsIconSize == nil then jps.resize(36) else jps.resize(jpsIconSize) end
		-- Racials
		local race = UnitRace("player")
		if race == "troll" then
			jps.DPSRacial = "berserking"
		elseif race == "orc" then
			jps.DPSRacial = "blood fury"
		elseif GetSpellBookItemInfo("lifeblood") ~= nil then
			jps.DPSRacial = "lifeblood"
		elseif race == "dwarf" then
			jps.defRacial = "stoneform"
		end
		
		
	-- On Logout
	elseif event == "PLAYER_LOGOUT" then
		jpsIconSize = jps.IconSize
		jpsEnabled = jps.Enabled
		jpsMultiTarget = jps.MultiTarget
		jpsUseCDs = jps.UseCDs
		jpsToggleDir = jps.ToggleDir

    -- Combat Event Handler
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local eventtable =  {... }

       --- Required For Healing Classes
       -- Update out of sight players before selecting a spell -- used for healing classes
       jps.UpdateHealerBlacklist()
        if eventtable[2] == "SPELL_CAST_FAILED" and eventtable[5]== GetUnitName("player") and eventtable[15]== "Target not in line of sight" then
          jps.BlacklistPlayer(jps.LastTarget)
        end
    end
end

function jps.detectSpec()
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
		jps.toggleEnabled(true)
	elseif msg == "respec" then
		jps.detectSpec()
	elseif msg == "fishing" then
		jps.Fishing = not jps.Fishing
		write("Murglesnout & Grey Deletion now", tostring(jps.Fishing))
	elseif msg == "debug" then
		jps.Debug = not jps.Debug
		write("Debug mode set to",tostring(jps.Debug))
	elseif msg == "multi" or msg == "multitarget" or msg == "aoe" then
		jps.toggleMulti()
	elseif msg == "cds" then
		jps.toggleCDs()
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
		jps.PvP = not jps.PvP
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
		if jps.Enabled then
			write("Enabled - Ready and Waiting.")
		else 
			write("Disabled - Waiting on Standby.")
		end
		write("Use /jps help for help.")
	end
end

function JPS_OnUpdate(self,elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	if (self.TimeSinceLastUpdate > jps.UpdateInterval) then

		if jps.MacroSpam and not jps.Casting then
			RunMacro(jps.Macro)

		elseif jps.Combat and jps.Enabled then
			if not IsMounted() then combat() end
			self.TimeSinceLastUpdate = 0

		end
	end
end

function combat(self) 
	-- Rotations
	if jps.Rotations == nil then
        jps.Rotations = { 
            ["Druid"]        = { ["Feral Combat"]  = druid_feral,
                                 ["Balance"]       = druid_balance,
                                 ["Restoration"]   = druid_resto },
            
            ["Death Knight"] = { ["Unholy"]        = dk_unholy,
                                 ["Blood"]         = dk_blood,
                                 ["Frost"]         = dk_frost  },
                
            ["Shaman"]       = { ["Enhancement"]   = shaman_enhancement,
                                 ["Elemental"]     = shaman_elemental,
								 ["Restoration"]   = shaman_resto_pvp },
            
            ["Paladin"]      = { ["Protection"]    = paladin_protadin,
                                 ["Retribution"]   = paladin_ret,
								 ["Holy"]		   = paladin_holy },
            
            ["Warlock"]      = { ["Affliction"]    = warlock_affl,
                                 ["Destruction"]   = warlock_destro,
                                 ["Demonology"]    = warlock_demo },
            
            ["Hunter"]       = { ["Beast Mastery"] = hunter_bm,
                                 ["Marksmanship"]  = hunter_mm,
                                 ["Survival"]      = hunter_sv },
                        
            ["Mage"]         = { ["Fire"]          = mage_fire,
                                 ["Arcane"]        = mage_arcane,
                                 ["Frost"]         = mage_frost },
                                
            ["Rogue"]        = { ["Assassination"] = rogue_assass,
								 ["Subtlety"] = rogue_sub },
            
            ["Warrior"]      = { ["Fury"]          = warrior_fury,
                                 ["Protection"]    = warrior_prot,
                                 ["Arms"]          = warrior_arms },
                                
            ["Priest"]       = { ["Shadow"]        = priest_shadow,
                                 ["Holy"]          = priest_holy,
								 ["Discipline"]	   = priest_disc },
        }
	end
	
	-- Loading check.
	if not jps.Class then return end

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



	-- Get spell from rotation
	jps.ThisCast = jps.Rotations[jps.Class][jps.Spec]()
	
	-- Check spell usability
	if jps.ThisCast and not jps.Casting and cd(jps.ThisCast) == 0 then
		if jps.NextCast ~= nil and jps.NextCast ~= jps.ThisCast then
			jps.Cast(jps.NextCast)
			jps.NextCast = nil
        else
           jps.Cast(jps.ThisCast)
		end
   	end
	
	-- Hide Error
	StaticPopup1:Hide()
	
	-- Return spellcast.
	return jps.ThisCast
end
