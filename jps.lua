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
<<<<<<< HEAD

		--jpsEnabled
		if jpsEnabled == nil then jpsEnabled,jps.Enabled = true,true
		elseif jpsEnabled == true then jps.Enabled = true,true
		else jps.Enabled = false end

		--jpsUseCDs
		if jpsUseCDs == nil then jpsUseCDs,jps.UseCDs = true,true
		elseif jpsUseCDs == true then jps.UseCDs = true
		else jps.UseCDs = false end

		--jpsMultiTarget
		if jpsMultiTarget == nil then jpsMultiTarget,jps.MultiTarget  = false,false
		elseif jpsMultiTarget == true then jps.MultiTarget = true
		else jps.MultiTarget = false end
	
	-- On Logout
=======
		
		if jpsEnabled == nil then jps.toggleEnabled(true)   else jps.toggleEnabled(jpsEnabled) end
		if jpsUseCDs == nil then jps.toggleCDs(true)        else jps.toggleCDs(jpsUseCDs) end
		if jpsMultiTarget == nil then jps.toggleMulti(false) else jps.toggleMulti(jpsMultiTarget) end
		if jpsToggles == nil then jps.toggleToggles(true)   else jps.toggleToggles(jpsToggles) end
		if jpsToggleDir == nil then jps.setToggleDir("right") else jps.setToggleDir(jpsToggleDir) end
		
		if jpsPetHeal == nil then jpsPetHeal,jps.PetHeal = false,false
		elseif jpsPetHeal == true then jps.PetHeal = true
		else jps.PetHeal = false end
		
>>>>>>> 5883a7d3f383b80bf5251bddefe46cdac681934a
	elseif event == "PLAYER_LOGOUT" then
		jpsIconSize = jps.IconSize
		jpsEnabled = jps.Enabled
		jpsMultiTarget = jps.MultiTarget
<<<<<<< HEAD
=======
		jpsPetHeal = jps.PetHeal
		jpsUseCDs = jps.UseCDs
		jpsToggleDir = jps.ToggleDir
>>>>>>> 5883a7d3f383b80bf5251bddefe46cdac681934a
	end
end

function jps.detectSpec()
	jps.Spec = jps.Specs[jps.Class][GetPrimaryTalentTree()]
	if jps.Spec then write("Online for your",jps.Spec,jps.Class) end
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
        write("Murglesnout & Grey Deletion now",jps.Fishing)
    elseif msg == "debug" then
        jps.Debug = not jps.Debug
<<<<<<< HEAD
        print("Debug mode set to",jps.Debug)
=======
        write("Debug mode set to",jps.Debug)
    elseif msg == "peth" then
        jps.PetHeal = not jps.PetHeal
        write("Pet heal set to",jps.PetHeal)
>>>>>>> 5883a7d3f383b80bf5251bddefe46cdac681934a
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
		jps.IconSize = tonumber(rest)
		jpsIcon:SetWidth(jps.IconSize)
		jpsIcon:SetHeight(jps.IconSize)
    elseif msg == "help" then
<<<<<<< HEAD
        print("Slash Commands:")
        print("/jps - Show enabled status.")
        print("/jps enable/disable - Enable/Disable the addon.")
        print("/jps spam - Toggle spamming of a given macro.")
        print("/jps cds - Toggle use of cooldowns.")
        print("/jps pew - Spammable macro to do your best moves, if for some reason you don't want it fully automated")
        print("/jps interrupts - Toggle interrupting")
        print("/jps help - Show this help text.")
=======
        write("Slash Commands:")
        write("/jps - Show enabled status.")
        write("/jps enable/disable - Enable/Disable the addon.")
        write("/jps spam - Toggle spamming of a given macro.")
        if jps.Spec == "Feral" then
            write("/jps panther - Toggle Feral T11 4pc.")
        end
        write("/jps cds - Toggle use of cooldowns.")
        write("/jps pew - Spammable macro to do your best moves, if for some reason you don't want it fully automated")
        write("/jps interrupts - Toggle interrupting")
        write("/jps help - Show this help text.")
>>>>>>> 5883a7d3f383b80bf5251bddefe46cdac681934a
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
<<<<<<< HEAD
jpsIconBorder = IconFrame:CreateTexture(nil, "OVERLAY") -- create the border texture
jpsIconBorder:SetParent(IconFrame) -- link it with the icon frame so it drags around with it
jpsIconBorder:SetPoint('TOPRIGHT', IconFrame, 1, 1) -- outset the points a bit so it goes around the spell icon
jpsIconBorder:SetPoint('BOTTOMLEFT', IconFrame, -1, -1)
jpsIconBorder:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga") -- set the texture
jpsIconShadow = IconFrame:CreateTexture(nil, "BACKGROUND") -- create the icon frame
jpsIconShadow:SetParent(IconFrame) -- link it with the icon frame so it drags around with it
jpsIconShadow:SetPoint('TOPRIGHT', jpsIconBorder, 4.5, 4.5) -- outset the points a bit so it goes around the border
jpsIconShadow:SetPoint('BOTTOMLEFT', jpsIconBorder, -4.5, -4.5) -- outset the points a bit so it goes around the border
jpsIconShadow:SetTexture("Interface\\AddOns\\JPS\\media\\shadow.tga")  -- set the texture
jpsIconShadow:SetVertexColor(0, 0, 0, 0.85)  -- color the texture black and set the alpha so its a bit more trans
=======
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
		if IsShiftKeyDown() then
			jps.setToggleDir()
		else
			jps.toggleToggles()
		end
		
	end
end)

ToggleCDs = CreateFrame("Button", "ToggleCDs", jpsIcon)
ToggleCDs:RegisterForClicks("LeftButtonUp")
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

function jps.setToggleDir( dir )
	if dir ~= nil then
		if dir == "right" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 80, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 40, 0)
			jps.ToggleDir = "right"
		elseif dir == "left" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, -80, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, -40, 0)
			jps.ToggleDir = "left"
		elseif dir == "up" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, 80)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, 40)
			jps.ToggleDir = "up"
		elseif dir == "down" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, -80)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, -40)
			jps.ToggleDir = "down"
		end
	else 
		dir = jps.ToggleDir
		if dir == "right" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 80, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 40, 0)
			jps.ToggleDir = "down"
		elseif dir == "left" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, -80, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, -40, 0)
			jps.ToggleDir = "up"
		elseif dir == "up" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, 80)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, 40)
			jps.ToggleDir = "right"
		elseif dir == "down" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, -80)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, -40)
			jps.ToggleDir = "left"
		end
	end
	
end

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
		write (" Cooldown Usage Disabled.")
	else
		ToggleCDs.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		write (" Cooldown Usage Enabled.")
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
		write("Disabled.")
	else
		jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		write("Enabled.")
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
		write("Multi-Target Disabled.")
	else
		ToggleMulti.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		write("Multi-Target Enabled.")
	end
	jps.MultiTarget = not jps.MultiTarget
	return
end

function jps.toggleCombat( status )
	if status == true then
		jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_combat.tga")
	else
		if jps.Enabled then
			jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border_on.tga")
		else
			jpsIcon.border:SetTexture("Interface\\AddOns\\JPS\\media\\border.tga")
		end
	end
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

>>>>>>> 5883a7d3f383b80bf5251bddefe46cdac681934a
