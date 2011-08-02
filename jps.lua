-- Universal
jps = {}
jps.Version = "0.9.2"
jps.RaidStatus = {}
jps.UpdateInterval = 0.2
jps.Enabled = true
jps.Combat = false
jps.Class = nil
jps.Spec = nil
jps.Interrupts = true
jps.PVPInterrupt = false
jps.UseCDs = true
jps.MultiTarget = false
jps.Debug = false
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
jps.Havoc = false
jps.Opening = false
jps.Panther = false
jps.PetHeal = true
-- Misc.
jps.MacroSpam = false
jps.Fishing = false
jps.Lifeblood = true
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
combatFrame:RegisterEvent("PLAYER_ALIVE")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
combatFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
combatFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
combatFrame:RegisterEvent("UNIT_SPELLCAST_START")
combatFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
combatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
combatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
combatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatFrame:RegisterEvent("UI_ERROR_MESSAGE")
combatFrame:RegisterEvent("UNIT_HEALTH")
combatFrame:RegisterEvent("BAG_UPDATE")

function combatEventHandler(self, event, ...)
    if event == "PLAYER_ALIVE" or event == "PLAYER_LOGIN" then
        jps.Class = UnitClass("player")
        jps.Spec = jps.Specs[jps.Class][GetPrimaryTalentTree()]
        if jps.Spec then print (":::: JPS Online for your",jps.Spec,jps.Class,"::::") end
        if not jps.Enabled then IconFrame:Hide() end
    elseif event == "PLAYER_REGEN_DISABLED" then
        jps.Combat = true
        if jps.Enabled then combat() end
    elseif event == "PLAYER_REGEN_ENABLED" then
        jps.Combat = false
        jps.Opening = true
        jps.RaidStatus = {}
        collectgarbage("collect")
    -- Casting - Credit (and thanks!) to walkistalki for the channeling and pet stuff.
    elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_SENT" then
        if ... == "player" then
            jps.Casting = true
        end
  elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and (UnitChannelInfo("player") == nil)) or event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if ... == "player" then
            jps.Casting = false
        end
  elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" or (event == "UNIT_SPELLCAST_CHANNEL_UPDATE" and (UnitChannelInfo("player")==nil))then
        if ... == "player" then
            jps.Casting = false
        end
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
    end
end

combatFrame:SetScript("OnEvent", combatEventHandler)

function SlashCmdList.jps(msg, editbox)
    if msg == "toggle" or msg == "t" then
        if jps.Enabled == false then msg = "e"
        else msg = "d" end
    end
    if msg== "disable" or msg == "d" then
        jps.Enabled = false
        IconFrame:Hide()
        print "JPS Disabled."
    elseif msg== "enable" or msg == "e" then
        jps.Enabled = true
        jps.NextCast = nil
        IconFrame:Show()
        print "JPS Enabled."
    elseif msg == "panther" then
        jps.Panther = not jps.Panther
        print("T11 4pc use set to",jps.Panther)
    elseif msg == "fishing" then
        jps.Fishing = not jps.Fishing
        print("Murglesnout & Grey Deletion now",jps.Fishing)
    elseif msg == "debug" then
        jps.Debug = not jps.Debug
        print("Debug mode set to",jps.Debug)
    elseif msg == "peth" then
        jps.PetHeal = not jps.PetHeal
        print("Pet heal set to",jps.PetHeal)
    elseif msg == "multi" or msg == "multitarget" then
        jps.MultiTarget = not jps.MultiTarget
        print("MultiTarget mode set to",jps.MultiTarget)
    elseif msg == "lifeblood" or msg == "lb" then
        jps.Lifeblood = not jps.Lifeblood
        print("Lifeblood set to",jps.MultiTarget)
    elseif msg == "cds" then
        jps.UseCDs = not jps.UseCDs
        print("Cooldown use set to",jps.UseCDs)
    elseif msg == "int" or msg == "interrupts" then
        jps.Interrupts = not jps.Interrupts
        print("Interrupt use set to",jps.Interrupts)
    elseif msg == "pint" then
        jps.PVPInterrupt = not jps.PVPInterrupt
        print("PVP Interrupt use set to",jps.PVPInterrupt)
    elseif msg == "spam" or msg == "macrospam" or msg == "macro" then
        jps.MacroSpam = not jps.MacroSpam
        print("MacroSpam flag is now set to",jps.MacroSpam)
    elseif msg == "havoc" then
        jps.Havoc = not jps.Havoc
        print("Bane of Havoc flag is now set to",jps.Havoc)
    elseif msg == "opening" then
        jps.Opening = not jps.Opening
        print("Opening flag is now set to",jps.Opening)
    elseif msg == "help" then
        print("Slash Commands:")
        print("/jps - Show enabled status.")
        print("/jps enable/disable - Enable/Disable the addon.")
        print("/jps spam - Toggle spamming of a given macro.")
        if jps.Spec == "Feral" then
            print("/jps panther - Toggle Feral T11 4pc.")
        end
        print("/jps cds - Toggle use of cooldowns.")
        print("/jps pew - Spammable macro to do your best moves, if for some reason you don't want it fully automated")
        print("/jps interrupts - Toggle interrupting")
        print("/jps help - Show this help text.")
    elseif msg == "pew" then
        combat()
    else
        if jps.Enabled then
            print("JPS v"..jps.Version.." Enabled - Ready and Waiting.")
        else 
            print "JPS Disabled - Waiting on Standby."
        end
        print("jps.UseCDs:",jps.UseCDs)
        print("jps.Opening:",jps.Opening)
        print("jps.Interrupts:",jps.Interrupts)
        if jps.Spec == "Feral" then
            print("jps.Panther:",jps.Panther)
        end
        print("jps.MacroSpam:",jps.MacroSpam)
        print("jps.Fishing:",jps.Fishing)
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
        print("Sorry! JPS does not yet have a rotation for your",jps.Spec,jps.Class.."...yet.")
        jps.Enabled = false
        return
    end

    -- Lag
    _,_,jps.Lag = GetNetStats()
    jps.Lag = jps.Lag/100
    
    -- Movement
    jps.Moving = GetUnitSpeed("player") > 0
    
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
