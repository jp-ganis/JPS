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
--combatFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
--combatFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
--combatFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
--combatFrame:RegisterEvent("UNIT_SPELLCAST_START")
--combatFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
--combatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
--combatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
--combatFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
--combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatFrame:RegisterEvent("UI_ERROR_MESSAGE")
combatFrame:RegisterEvent("UNIT_HEALTH")
combatFrame:RegisterEvent("BAG_UPDATE")

function combatEventHandler(self, event, ...)
    if event == "PLAYER_LOGIN" then
        jps.Class = UnitClass("player")
				jps.detectSpec()
    elseif event == "PLAYER_REGEN_DISABLED" then
        jps.Combat = true
        if jps.Enabled then combat() end
    elseif event == "PLAYER_REGEN_ENABLED" then
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
		
		if jpsEnabled == nil then jps.toggleEnabled(true)   else jps.toggleEnabled(jpsEnabled) end
		if jpsUseCDs == nil then jps.toggleCDs(true)        else jps.toggleCDs(jpsUseCDs) end
		if jpsMultiTarget == nil then jps.toggleMulti(false) else jps.toggleMulti(jpsMultiTarget) end
		if jpsToggles == nil then jps.toggleToggles(true)   else jps.toggleToggles(jpsToggles) end
		
		if jpsPetHeal == nil then jpsPetHeal,jps.PetHeal = false,false
		elseif jpsPetHeal == true then jps.PetHeal = true
		else jps.PetHeal = false end
		
	elseif event == "PLAYER_LOGOUT" then
		jpsIconSize = jps.IconSize
		jpsEnabled = jps.Enabled
		jpsMultiTarget = jps.MultiTarget
		jpsPetHeal = jps.PetHeal
		jpsUseCDs = jps.UseCDs
	end
end

function jps.detectSpec()
	jps.Spec = jps.Specs[jps.Class][GetPrimaryTalentTree()]
	if jps.Spec then print (":::: JPS Online for your",jps.Spec,jps.Class,"::::") end
	if not jps.Enabled then jpsIcon:Hide() end
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
        print("Murglesnout & Grey Deletion now",jps.Fishing)
    elseif msg == "debug" then
        jps.Debug = not jps.Debug
        print("Debug mode set to",jps.Debug)
    elseif msg == "peth" then
        jps.PetHeal = not jps.PetHeal
        print("Pet heal set to",jps.PetHeal)
    elseif msg == "multi" or msg == "multitarget" then
        jps.toggleMulti()
        print("MultiTarget mode set to",jps.MultiTarget)
    elseif msg == "cds" then
		jps.toggleCDs()
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
    elseif msg == "opening" then
        jps.Opening = not jps.Opening
        print("Opening flag is now set to",jps.Opening)
	elseif msg == "size" then
		jps.IconSize = tonumber(rest)
		jpsIcon:SetWidth(jps.IconSize)
		jpsIcon:SetHeight(jps.IconSize)
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
        print("jps.MacroSpam:",jps.MacroSpam)
        print("jps.Fishing:",jps.Fishing)
				print("Use /jps help for help.")
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

-- Create the frame that does all the work, pew pew..
JPSFrame = CreateFrame("Frame", "JPSFrame")
JPSFrame:SetScript("OnUpdate", function(self, elapsed)
	if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
	JPS_OnUpdate(self, elapsed)
end)

-- Create the dragable Icon frame, anchor point for everything else
jpsIcon = CreateFrame("Button", "jpsIcon", UIParent)
jpsIcon:SetMovable(true)
jpsIcon:EnableMouse(true)
jpsIcon:RegisterForClicks("LeftButtonUp", "RightButtonUp")
jpsIcon:RegisterForDrag("LeftButton")
jpsIcon:SetScript("OnDragStart", jpsIcon.StartMoving)
jpsIcon:SetScript("OnDragStop", jpsIcon.StopMovingOrSizing)
jpsIcon:SetPoint("CENTER")


jpsIcon.texture = jpsIcon:CreateTexture("ARTWORK") -- create the spell icon texture
jpsIcon.texture:SetPoint('TOPRIGHT', jpsIcon, -2, -2) -- inset it by 3px or pt or w/e the game uses
jpsIcon.texture:SetPoint('BOTTOMLEFT', jpsIcon, 2, 2)
jpsIcon.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93) -- cut off the blizzard border
jpsIcon.texture:SetTexture("Interface\\AddOns\\JPS\\media\\jps.tga") -- set the default texture

-- barrowed this, along with the texture from nMainbar
jpsIcon.border = jpsIcon:CreateTexture(nil, "OVERLAY") -- create the border texture
jpsIcon.border:SetParent(jpsIcon) -- link it with the icon frame so it drags around with it
jpsIcon.border:SetPoint('TOPRIGHT', jpsIcon, 1, 1) -- outset the points a bit so it goes around the spell icon
jpsIcon.border:SetPoint('BOTTOMLEFT', jpsIcon, -1, -1)
jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga") -- set the texture
jpsIcon.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND") -- create the icon frame
jpsIcon.shadow:SetParent(jpsIcon) -- link it with the icon frame so it drags around with it
jpsIcon.shadow:SetPoint('TOPRIGHT', jpsIcon.border, 4.5, 4.5) -- outset the points a bit so it goes around the border
jpsIcon.shadow:SetPoint('BOTTOMLEFT', jpsIcon.border, -4.5, -4.5) -- outset the points a bit so it goes around the border
jpsIcon.shadow:SetTexture("Interface\\AddOns\\JPS\\media\\shadow.tga")  -- set the texture
jpsIcon.shadow:SetVertexColor(0, 0, 0, 0.85)  -- color the texture black and set the alpha so its a bit more trans

jpsIcon:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		jps.toggleEnabled()
	elseif button == "RightButton" then
		jps.toggleToggles()
	end
end)

ToggleCDs = CreateFrame("Button", "ToggleCDs", jpsIcon)
ToggleCDs:RegisterForClicks("LeftButtonUp")
ToggleCDs:SetPoint("CENTER")
ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 40, 0)
ToggleCDs:SetHeight(36)
ToggleCDs:SetWidth(36)
ToggleCDs.texture = ToggleCDs:CreateTexture()
ToggleCDs.texture:SetAllPoints()
ToggleCDs.texture:SetTexture("Interface\\Icons\\Spell_Holy_BorrowedTime")
ToggleCDs.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
ToggleCDs.border = ToggleCDs:CreateTexture(nil, "OVERLAY")
ToggleCDs.border:SetParent(ToggleCDs)
ToggleCDs.border:SetPoint('TOPRIGHT', ToggleCDs, 1, 1)
ToggleCDs.border:SetPoint('BOTTOMLEFT', ToggleCDs, -1, -1)
ToggleCDs.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")

ToggleCDs.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
ToggleCDs.shadow:SetParent(ToggleCDs)
ToggleCDs.shadow:SetPoint('TOPRIGHT', ToggleCDs.border, 4.5, 4.5) 
ToggleCDs.shadow:SetPoint('BOTTOMLEFT', ToggleCDs.border, -4.5, -4.5) 
ToggleCDs.shadow:SetTexture("Interface\\AddOns\\JPS\\media\\shadow.tga")
ToggleCDs.shadow:SetVertexColor(0, 0, 0, 0.85)  


ToggleCDs:SetScript("OnClick", function(self, button)

	jps.toggleCDs()
	
end)


ToggleMulti = CreateFrame("Button", "ToggleMulti", jpsIcon)
ToggleMulti:RegisterForClicks("LeftButtonUp")
ToggleMulti:SetPoint("CENTER")
ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 80, 0)
ToggleMulti:SetHeight(36)
ToggleMulti:SetWidth(36)
ToggleMulti.texture = ToggleMulti:CreateTexture()
ToggleMulti.texture:SetAllPoints()
ToggleMulti.texture:SetTexture("Interface\\Icons\\achievement_arena_5v5_3")
ToggleMulti.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
ToggleMulti.border = ToggleMulti:CreateTexture(nil, "OVERLAY") -- create the
ToggleMulti.border:SetParent(ToggleMulti) -- link it with the icon frame so 
ToggleMulti.border:SetPoint('TOPRIGHT', ToggleMulti, 1, 1) -- outset the poi
ToggleMulti.border:SetPoint('BOTTOMLEFT', ToggleMulti, -1, -1)
ToggleMulti.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")

ToggleMulti.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
ToggleMulti.shadow:SetParent(ToggleMulti)
ToggleMulti.shadow:SetPoint('TOPRIGHT', ToggleMulti.border, 4.5, 4.5) 
ToggleMulti.shadow:SetPoint('BOTTOMLEFT', ToggleMulti.border, -4.5, -4.5) 
ToggleMulti.shadow:SetTexture("Interface\\AddOns\\JPS\\media\\shadow.tga")
ToggleMulti.shadow:SetVertexColor(0, 0, 0, 0.85)

ToggleMulti:SetScript("OnClick", function(self, button)

	jps.toggleMulti()

end)

function jps.toggleCDs( value )
	if value ~= nil then
		jps.UseCDs = value
		if value == true then
			ToggleCDs.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		else
			ToggleCDs.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")
		end
		return
	end
	if jps.UseCDs then
		ToggleCDs.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")
		print "JPS: Cooldown Usage Disabled."
	else
		ToggleCDs.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		print "JPS: Cooldown Usage Enabled."
	end
	jps.UseCDs = not jps.UseCDs
	return
end

function jps.toggleEnabled( value )
	if value ~= nil then
		jps.Enabled = value
		if value == true then
			jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		else
			jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")
		end
		return
	end
	if jps.Enabled then
		jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")
		print "JPS: Disabled."
	else
		jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		print "JPS: Enabled."
	end
	jps.Enabled = not jps.Enabled
	return
end

function jps.toggleMulti( value )
	if value ~= nil then
		jps.MultiTarget = value
		if value == true then
			ToggleMulti.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		else
			ToggleMulti.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")
		end
		return
	end
	if jps.MultiTarget then
		ToggleMulti.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")
		print "JPS: Multi-Target Disabled."
	else
		ToggleMulti.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		print "JPS: Multi-Target Enabled."
	end
	jps.MultiTarget = not jps.MultiTarget
	return
end

function jps.toggleToggles( values )
	if value ~= nil then
		jps.Toggles = value
		if value == true then
			ToggleMulti:Show()
			ToggleCDs:Show()
		else
			ToggleMulti:Hide()
			ToggleCDs:Hide()
		end
		return
	end
	if jps.Toggles then
		ToggleMulti:Hide()
		ToggleCDs:Hide()
	else
		ToggleMulti:Show()
		ToggleCDs:Show()
	end
	jps.Toggles = not jps.Toggles
end

