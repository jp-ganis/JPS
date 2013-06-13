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

local rotationButtonPositionY = -90; -- NEW
local rotationButtonPositionX = 20; -- NEW
local jpsRotationFrame = nil; -- NEW
local rotationCount = 0

function jps_createConfigFrame()
	jpsConfigFrame = CreateFrame("Frame", "jpsConfigFrame", UIParent)

	-- More Juked <3
	-- local w = 256
	-- local h = 128
	jpsConfigFrame.name = "JPS Options Panel"
	local title = jpsConfigFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 20, -10) 
	title:SetText("JPS")
	local subtitle = jpsConfigFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", jpsConfigFrame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("Configuration options for JPS")

	-- <3 to Juked
	-- Create checkboxes
	local buttonPositionY = -60;
	local buttonPositionX = 40;

	local t = {1,2,3,4,5,6,7,8,9}
	for var,value in pairs(jpsDB[jpsRealm][jpsName]) do
		if type(jpsDB[jpsRealm][jpsName][var]) == "boolean" then
			if var == "Enabled" then t[1] = var
			elseif var == "FaceTarget" then t[2] = var
			elseif var == "MoveToTarget" then t[3] = var
			elseif var == "UseCDs" then t[4] = var
			elseif var == "MultiTarget" then t[5] = var
			elseif var == "Interrupts" then t[6] = var
			elseif var == "Defensive" then t[7] = var
			elseif var == "PvP" then t[8] = var
			elseif var == "ExtraButtons" then t[9] = var
			else table.insert(t,var)
			end
		end
	end

	for i,v in ipairs (t) do
		local JPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JPS_Button_"..v, jpsConfigFrame, "OptionsCheckButtonTemplate");
		JPS_IconOptions_CheckButton:SetPoint("TOPLEFT",buttonPositionX,buttonPositionY);
		getglobal(JPS_IconOptions_CheckButton:GetName().."Text"):SetText(v);

		local function JPS_IconOptions_CheckButton_OnClick()
			if v == "PvP" then jps.togglePvP()
			else jps[v] = not jps[v] end
			jps_SAVE_PROFILE()
			jps_LOAD_PROFILE()
		end  

		local function JPS_IconOptions_CheckButton_OnShow()
			jps_SAVE_PROFILE()
			JPS_IconOptions_CheckButton:SetChecked(jpsDB[jpsRealm][jpsName][v]);
		end  

		JPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
		JPS_IconOptions_CheckButton:SetScript("OnClick", JPS_IconOptions_CheckButton_OnClick);
		JPS_IconOptions_CheckButton:SetScript("OnShow", JPS_IconOptions_CheckButton_OnShow);
		if i == 9 then buttonPositionY = buttonPositionY - 30 end
		buttonPositionY = buttonPositionY - 30;
	end

	-- HIDE AT LOAD
	InterfaceOptions_AddCategory(jpsConfigFrame)
	jps.Configged = true
	jpsConfigFrame:Hide()
	
	-- DROPDOWN ROTATION
	jps.resetTimeToDieFrame()
	jps.resetRotationDropdownFrame()
	jps.addRotationDropdownFrame()
	jps.addSettingsFrame()
	
end


---------------------------------
-- DROPDOWN ROTATIONS
---------------------------------

-- function jps.addRotationDropdown()

	-- DropDownRotation = CreateFrame("FRAME", "JPS Rotation", jpsConfigFrame, "UIDropDownMenuTemplate")
	-- DropDownRotation:ClearAllPoints()
	-- DropDownRotation:SetPoint("CENTER",150,120)
	-- local title = DropDownRotation:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	-- title:SetPoint("TOPLEFT", 20, 20) 
	-- title:SetText("JPS ROTATIONS")

	-- local function Rotation_OnClick(self)
	   -- UIDropDownMenu_SetSelectedID(DropDownRotation, self:GetID())
	   -- jps.Count = self:GetID() -- HERE we get the jps.Count in the DropDownRotation
	   -- jps.Tooltip = "Click Macro /jps pew\nFor the Rotation Tooltip"
	-- end

	-- local function DropDown_Initialize(self, level)
		-- local menuList = {
		   -- jps.ToggleRotationName[1], -- will be {"No Rotations"} or spellTable[1]["ToolTip"]
		   -- jps.ToggleRotationName[2],
		   -- jps.ToggleRotationName[3],
		   -- jps.ToggleRotationName[4],
		   -- jps.ToggleRotationName[5],
		-- }
		-- local info = UIDropDownMenu_CreateInfo()
		-- for k,v in pairs(menuList) do
		  -- info = UIDropDownMenu_CreateInfo()
		  -- info.text = v
		  -- info.value = v
		  -- info.func = Rotation_OnClick
		  -- UIDropDownMenu_AddButton(info, level)
		-- end
	-- end
	
	-- UIDropDownMenu_Initialize(DropDownRotation, DropDown_Initialize)
	-- UIDropDownMenu_SetWidth(DropDownRotation, 164)
	-- UIDropDownMenu_SetSelectedID(DropDownRotation, 1)
	-- UIDropDownMenu_JustifyText(DropDownRotation, "LEFT")

-- end

---------------------------
-- Settings Frame
---------------------------s
--[[
A Frame for Settings that you only could change in the code:
- deleting greys
- dispel on / off
- facing direction
- use potions, use flasks
- use trinekt 1 / 2
- dismount when entering combat 
- hide JPS ui due to screenshots !
- button for reset DB / UI position

what I need here:
- one function where I can add a checkbox with titel + description , it should also care about saving current state in jpsDB and handle onClick
- one function for reading settings e.g. jps.getConfigVal(str) and one for writing jps.setConfigVal()


some of there we could change through jps.UseCDs , but this is to generally because the cooldowns are to different (we don't have to care about a 45 sec cooldown while fighting trash, but it would be useless to use a potion there :) 
]]--

function jps.addSettingsFrame()
	jpsSettingsFrame = CreateFrame("Frame", "jpsSettingsFrame", jpsConfigFrame)
	jpsSettingsFrame.parent  = jpsConfigFrame.name
	jpsSettingsFrame.name = "JPS Settings Panel"
	local title = jpsSettingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 20, -10) 
	title:SetText("JPS SETTINGS PANEL")
	local settingsInfo = jpsSettingsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	settingsInfo:SetHeight(32)
	settingsInfo:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	settingsInfo:SetPoint("RIGHT", jpsSettingsFrame, -32, 0)
	settingsInfo:SetNonSpaceWrap(true)
	settingsInfo:SetJustifyH("LEFT")
	settingsInfo:SetJustifyV("TOP")
	settingsInfo:SetText("Work in Progress!")

	
	InterfaceOptions_AddCategory(jpsSettingsFrame)
	jpsSettingsFrame:Hide()
	
end

---------------------------
-- DROPDOWN SPELLS
---------------------------

function jps.addRotationDropdownFrame()

	jpsRotationFrame = CreateFrame("Frame", "jpsRotationFrame", jpsConfigFrame)
	jpsRotationFrame.parent  = jpsConfigFrame.name
	jpsRotationFrame.name = "JPS Rotation Panel"
	local title = jpsRotationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 20, -10) 
	title:SetText("JPS SPELLS ROTATION")
	local rotationInfo = jpsRotationFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	rotationInfo:SetHeight(32)
	rotationInfo:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	rotationInfo:SetPoint("RIGHT", jpsRotationFrame, -32, 0)
	rotationInfo:SetNonSpaceWrap(true)
	rotationInfo:SetJustifyH("LEFT")
	rotationInfo:SetJustifyV("TOP")
	rotationInfo:SetText("Rotation Config for your "..jps.Spec.." "..jps.Class)
	
	local desc = jpsRotationFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	desc:SetHeight(32)
	desc:SetPoint("TOPLEFT", rotationInfo, "BOTTOMLEFT", 0, 16)
	desc:SetPoint("RIGHT", jpsRotationFrame, -32, 0)
	desc:SetNonSpaceWrap(true)
	desc:SetJustifyH("LEFT")
	desc:SetJustifyV("TOP")
	desc:SetText("Uncheck spells when you dont want to use them. Do a /jps db to reset the spells")

	for spellKey,spellVal in pairs (jpsDB[jpsRealm][jpsName].spellConfig) do
		rotationCount = rotationCount + 1
		if rotationCount == 16 then 
			rotationButtonPositionX = 220
			rotationButtonPositionY = - 90
		elseif rotationCount == 31 then
			rotationButtonPositionX = 420
			rotationButtonPositionY = - 90
		end

		local rotationJPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JPS_Button_"..spellKey, jpsRotationFrame, "OptionsCheckButtonTemplate");
		rotationJPS_IconOptions_CheckButton:SetPoint("TOPLEFT",rotationButtonPositionX,rotationButtonPositionY);
		getglobal(rotationJPS_IconOptions_CheckButton:GetName().."Text"):SetText(spellKey);

		local function rotationJPS_IconOptions_CheckButton_OnClick()
            local spellStatus = nil
            if(rotationJPS_IconOptions_CheckButton:GetChecked() == nil) then 
                spellStatus = 0 
            else 
                spellStatus = 1 
            end
            setSpellStatus(spellKey, spellStatus)
		end  
		
		local function rotationJPS_IconOptions_CheckButton_OnShow()
			rotationJPS_IconOptions_CheckButton:SetChecked(getSpellStatus(spellKey));
		end  

		rotationJPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
		rotationJPS_IconOptions_CheckButton:SetScript("OnClick", rotationJPS_IconOptions_CheckButton_OnClick);
		rotationJPS_IconOptions_CheckButton:SetScript("OnShow", rotationJPS_IconOptions_CheckButton_OnShow);
		
		rotationButtonPositionY = rotationButtonPositionY - 30;
	end
	
	InterfaceOptions_AddCategory(jpsRotationFrame)
	jpsRotationFrame:Hide()
end

---------------------------
-- RESET DROPDOWN SPELLS
---------------------------

function jps.resetRotationDropdownFrame()
	initDropDown_CheckButton = CreateFrame("CheckButton","", jpsConfigFrame, "OptionsCheckButtonTemplate");
	initDropDown_CheckButton:SetPoint("TOPLEFT",20,-370)
	initDropDown_CheckButton:RegisterForClicks("AnyUp")
	
	local title = initDropDown_CheckButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	title:SetPoint("TOPLEFT", 30, -5) 
	title:SetText("|cffffffffDROPDOWN ROTATION FRAME")
	
	local function DropDown_Check_OnClick(self)
		local checkbutton = initDropDown_CheckButton:GetChecked()
		if checkbutton == 1 then
			rotationDropdownHolder:Show()
		else
			rotationDropdownHolder:Hide()
		end
	end
	
	-- local function DropDown_Check_OnShow(self)
		-- initDropDown_CheckButton:SetChecked(checkbutton)
	-- end
	
	--initDropDown_CheckButton:SetScript("OnShow", DropDown_Check_OnShow);
	initDropDown_CheckButton:SetScript("OnClick", DropDown_Check_OnClick);

end

function jps.resetTimeToDieFrame()
	TimeToDie_CheckButton = CreateFrame("CheckButton","", jpsConfigFrame, "OptionsCheckButtonTemplate");
	TimeToDie_CheckButton:SetPoint("TOPLEFT",20, -400)
	TimeToDie_CheckButton:RegisterForClicks("AnyUp")
	
	local title = TimeToDie_CheckButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	title:SetPoint("TOPLEFT", 30, -5) 
	title:SetText("|cffffffffTIMETODIE FRAME")
	
	local function DropDown_Check_OnClick(self)
		local timecheckbutton = TimeToDie_CheckButton:GetChecked()
		if timecheckbutton == 1 then
			JPSEXTInfoFrame:Show()
		else
			JPSEXTInfoFrame:Hide()
		end
	end
	
	-- local function DropDown_Check_OnShow(self)
		-- initDropDown_CheckButton:SetChecked(checkbutton)
	-- end
	
	--initDropDown_CheckButton:SetScript("OnShow", DropDown_Check_OnShow);
	TimeToDie_CheckButton:SetScript("OnClick", DropDown_Check_OnClick);

end

---------------------------
-- ADD SPELLS DROPDOWN
---------------------------

function jps.addSpellCheckboxToFrame(spellName)

	rotationCount = rotationCount + 1
	if rotationCount == 16 then 
		rotationButtonPositionX = 220
		rotationButtonPositionY = - 90
	elseif rotationCount == 31 then
		rotationButtonPositionX = 420
		rotationButtonPositionY = - 90
	end

    local rotationJPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JPS_Button_"..spellName, jpsRotationFrame, "OptionsCheckButtonTemplate");
    rotationJPS_IconOptions_CheckButton:SetPoint("TOPLEFT",rotationButtonPositionX,rotationButtonPositionY);
    getglobal(rotationJPS_IconOptions_CheckButton:GetName().."Text"):SetText(spellName);
    
    local function rotationJPS_IconOptions_CheckButton_OnClick()
        local spellStatus = nil
        if(rotationJPS_IconOptions_CheckButton:GetChecked() == nil) then 
            spellStatus = 0 
        else 
            spellStatus = 1 
        end
        setSpellStatus(spellName, spellStatus)
    end  
    
    local function rotationJPS_IconOptions_CheckButton_OnShow()
        rotationJPS_IconOptions_CheckButton:SetChecked(getSpellStatus(spellName));
    end  
    
    rotationJPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
    rotationJPS_IconOptions_CheckButton:SetScript("OnClick", rotationJPS_IconOptions_CheckButton_OnClick);
    rotationJPS_IconOptions_CheckButton:SetScript("OnShow", rotationJPS_IconOptions_CheckButton_OnShow);

    rotationButtonPositionY = rotationButtonPositionY - 30;
end

---------------------------
-- LOAD_PROFILE
---------------------------

function jps_VARIABLES_LOADED()
	if jps.ResetDB then 
		jpsDB = {}
		collectgarbage("collect")
	end
	if ( not jpsDB ) then
		jpsDB = {}
	end
	if ( not jpsDB[jpsRealm] ) then
		jpsDB[jpsRealm] = {}
	end
	if ( not jpsDB[jpsRealm][jpsName] ) then
		write("Initializing new character names")
		jpsDB[jpsRealm][jpsName] = {}
		jpsDB[jpsRealm][jpsName].Enabled = true
		jpsDB[jpsRealm][jpsName].FaceTarget = false
		jpsDB[jpsRealm][jpsName].MoveToTarget = false
		jpsDB[jpsRealm][jpsName].UseCDs = false
		jpsDB[jpsRealm][jpsName].MultiTarget = false
		jpsDB[jpsRealm][jpsName].Interrupts = false
		jpsDB[jpsRealm][jpsName].Defensive = false
		jpsDB[jpsRealm][jpsName].PvP = false
		jpsDB[jpsRealm][jpsName].ExtraButtons = false
		jpsDB[jpsRealm][jpsName].spellConfig = {} -- NEW
	else
		if ( not jpsDB[jpsRealm][jpsName].spellConfig) then -- NEW
		  jpsDB[jpsRealm][jpsName].spellConfig = {} -- NEW
		end
	end

	jps_LOAD_PROFILE()
	jps_variablesLoaded = true
end

---------------------------
-- LOAD_PROFILE
---------------------------
function jps_LOAD_PROFILE() 
	for saveVar,value in pairs( jpsDB[jpsRealm][jpsName] ) do
		jps[saveVar] = value
	end

	jps.gui_toggleEnabled( jps.Enabled )
	jps.gui_toggleCDs( jps.UseCDs )
	jps.gui_toggleMulti( jps.MultiTarget )
	jps.gui_toggleInt(jps.Interrupts)
	jps.gui_toggleDef(jps.Defensive)
	jps.gui_toggleRot(jps.FaceTarget)
	jps.gui_toggleToggles( jps.ExtraButtons )
	jps.gui_setToggleDir( "right" )
	jps.togglePvP( jps.PvP )
	jps.resize( 36 )
end

---------------------------
-- SAVE_PROFILE
---------------------------

function jps_SAVE_PROFILE()
	for varName, _ in pairs( jpsDB[jpsRealm][jpsName] ) do
		jpsDB[jpsRealm][jpsName][varName] = jps[varName]
	end
end