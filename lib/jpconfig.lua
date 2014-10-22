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
---------------------------
-- HELPER FUNCTIONS
---------------------------

function jps.redColor(str)
	return "|cFFFF0000"..str.."|r"
end


local rotationButtonPositionY = -90; -- NEW
local rotationButtonPositionX = 20; -- NEW
local jpsRotationFrame = nil; -- NEW
local rotationCount = 0

local rotationCountSetting = 0
local settingsButtonPositionY = -90;
local settingsButtonPositionX = 20;

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
	jps.addRotationDropdownFrame()
	jps.addSettingsFrame()
	jps.addcustomRotationFrame()
	jps.addUIFrame()
	
end


function jps.addSlider(sliderName, parentObj, xPos, yPos, defaultVal, stepSize, minVal, maxVal, lowText,HighText,title, onChangeFunc)
	local sliderObj = CreateFrame("Slider",sliderName,parentObj,"OptionsSliderTemplate") --frameType, frameName, frameParent, frameTemplate 

	sliderObj:SetScale(1)
	sliderObj:SetMinMaxValues(minVal,maxVal)
	sliderObj.minValue, sliderObj.maxValue = sliderObj:GetMinMaxValues()
	sliderObj:SetValue(defaultVal)
	sliderObj:SetValueStep(stepSize)
	sliderObj:EnableMouse(true)
	sliderObj:SetPoint("TOPLEFT", parentObj, xPos, yPos)
	getglobal(sliderObj:GetName() .. 'Low'):SetText(lowText)
	getglobal(sliderObj:GetName() .. 'High'):SetText(HighText)
	getglobal(sliderObj:GetName() .. 'Text'):SetText(title)
	sliderObj:SetScript("OnValueChanged", onChangeFunc)
	sliderObj:Show()
	return sliderObj
end

---------------------------
-- UI Settings Frame
---------------------------
function jps.addUIFrame()
	jpsUIFrame = CreateFrame("Frame", "jpsUIFrame", jpsConfigFrame)
	jpsUIFrame.parent  = jpsConfigFrame.name
	jpsUIFrame.name = "JPS UI Panel"
	local title = jpsUIFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 20, -10) 
	title:SetText("JPS CUSTOM ROTATION PANEL")
	jpsUIFrameInfo = jpsUIFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	jpsUIFrameInfo:SetHeight(46)
	jpsUIFrameInfo:SetWidth(570)
	jpsUIFrameInfo:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	jpsUIFrameInfo:SetPoint("RIGHT", jpsUIFrame, -32, 0)
	jpsUIFrameInfo:SetNonSpaceWrap(true)
	jpsUIFrameInfo:SetJustifyH("LEFT")
	jpsUIFrameInfo:SetJustifyV("TOP")
	jpsUIFrameInfo:SetText('Adjust the look of the JPS UI')
	
	
	iconSizeSlider = jps.addSlider("iconSizeSlider",jpsUIFrame,30,-90, jps.getConfigVal("jpsIconSize") , 0.1, 0.5,1.5,"0.5","1.5","Main UI Scale", function(self, value)
		jpsIcon:SetScale(value)
		jps.setConfigVal("jpsIconSize",value)
	end)
	
	rotationDropdownSizeSlider = jps.addSlider("rotationDropdownSizeSlider",jpsUIFrame,30,-155, jps.getConfigVal("rotationDropdownSizeSlider") , 0.1, 0.5,1.5,"0.5","1.5","Rotation Dropdown Scale", function(self, value)
		rotationDropdownHolder:SetScale(value)
		jps.setConfigVal("rotationDropdownSizeSlider",value)
	end)
	
	timetodieSizeSlider = jps.addSlider("timetodieSizeSlider",jpsUIFrame,30,-215, jps.getConfigVal("timetodieSizeSlider") , 0.1, 0.5,1.5,"0.5","1.5","TimeToDie UI Scale", function(self, value)
		JPSEXTInfoFrame:SetScale(value)
		jps.setConfigVal("timetodieSizeSlider",value)
	end)
	
	
	InterfaceOptions_AddCategory(jpsUIFrame)

end

---------------------------
-- Custom Rotation Frame
---------------------------
function jps.addcustomRotationFrame()
	jpsCustomRotationFrame = CreateFrame("Frame", "jpsCustomRotationFrame", jpsConfigFrame)
	jpsCustomRotationFrame.parent  = jpsConfigFrame.name
	jpsCustomRotationFrame.name = "JPS Custom Rotation Panel"
	local title = jpsCustomRotationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 20, -10) 
	title:SetText("JPS CUSTOM ROTATION PANEL")
	local customRotationInfo = jpsCustomRotationFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	customRotationInfo:SetHeight(46)
	customRotationInfo:SetWidth(570)
	customRotationInfo:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	customRotationInfo:SetPoint("RIGHT", jpsCustomRotationFrame, -32, 0)
	customRotationInfo:SetNonSpaceWrap(true)
	customRotationInfo:SetJustifyH("LEFT")
	customRotationInfo:SetJustifyV("TOP")
	customRotationInfo:SetText('Here you can test your rotations or change them without reloading the WoW Interface.\nEach Rotation posted here doesn\'t require the Wrapper like. "function dk_frost() ... end",\nbut you need to write the content that is used inside a normal rotation function. Like "return parseSpellTable(spellTable)" etc.')


	local jpsCustomRotation = CreateFrame('Frame', 'nChatCopy', jpsCustomRotationFrame)
	jpsCustomRotation:SetWidth(500)
	jpsCustomRotation:SetHeight(400)
	jpsCustomRotation:SetPoint('CENTER')
	jpsCustomRotation:SetFrameStrata('DIALOG')
	jpsCustomRotation:SetBackdrop({
		bgFile = [[Interface\Buttons\WHITE8x8]],
		insets = {left = 3, right = 3, top = 4, bottom = 3
	}})
	jpsCustomRotation:SetBackdropColor(0, 0, 0, 0.7)
	
	
	jpsCustomRotationBox = CreateFrame('EditBox', 'nChatCopyBox', jpsCustomRotation)
	jpsCustomRotationBox:SetMultiLine(true)
	jpsCustomRotationBox:SetAutoFocus(true)
	jpsCustomRotationBox:EnableMouse(true)
	jpsCustomRotationBox:SetMaxLetters(99999)
	jpsCustomRotationBox:SetFont('Fonts\\ARIALN.ttf', 13, 'THINOUTLINE')
	jpsCustomRotationBox:SetWidth(590)
	jpsCustomRotationBox:SetHeight(590)

	local Scroll = CreateFrame('ScrollFrame', 'nChatCopyScroll', jpsCustomRotation, 'UIPanelScrollFrameTemplate')
	Scroll:SetPoint('TOPLEFT', jpsCustomRotation, 'TOPLEFT', 8, -30)
	Scroll:SetPoint('BOTTOMRIGHT', jpsCustomRotation, 'BOTTOMRIGHT', -30, 8)
	Scroll:SetScrollChild(jpsCustomRotationBox)	

	
	local jpsOpenHelpFrameButton = CreateFrame('Button', 'jpsOpenHelpFrameButton', jpsCustomRotationFrame , 'UIPanelButtonTemplate')
	jpsOpenHelpFrameButton:SetText("show help")
	jpsOpenHelpFrameButton:SetPoint("BOTTOM",jpsCustomRotationFrame,"BOTTOM", 0, 20)
	jpsOpenHelpFrameButton:SetScript("OnClick", function()  helpFrame:Show();Scroll:Hide() end)
	jpsOpenHelpFrameButton:SetSize(145,25)
	
	
	local jpsCustomRotationRemove = CreateFrame('Button', 'resetRotation', jpsCustomRotationFrame , 'UIPanelButtonTemplate')
	jpsCustomRotationRemove:SetText("Reset Rotation")
	jpsCustomRotationRemove:SetPoint("BOTTOM",jpsOpenHelpFrameButton,"BOTTOM", 150, 0)
	jpsCustomRotationRemove:SetScript("OnClick", function()jps.customRotationFunc = ""; jpsCustomRotationBox:SetText("") end)
	jpsCustomRotationRemove:SetSize(145,25)

	
	local jpsCustomRotationButton = CreateFrame('Button', 'submitRotation', jpsCustomRotationFrame , 'UIPanelButtonTemplate')
	jpsCustomRotationButton:SetText("Activate This Rotation")
	jpsCustomRotationButton:SetPoint("BOTTOM",jpsOpenHelpFrameButton,"BOTTOM", -150, 0)
	jpsCustomRotationButton:SetScript("OnClick", function()
		if string.len(jpsCustomRotationBox:GetText()) > 10 then 
			jps.customRotationFunc = jpsCustomRotationBox:GetText();
			assert(loadstring('function jps.customRotation() '.. jps.customRotationFunc..' end'))() 
		end
	end)
	jpsCustomRotationButton:SetSize(145,25)


	local helpFrame = CreateFrame('Frame', 'helpFrame', jpsCustomRotationFrame)
	helpFrame:SetSize(550,450)
	helpFrame:SetPoint("CENTER", jpsCustomRotationFrame)
	helpFrame:SetFrameStrata('DIALOG')
	helpFrame:SetBackdrop({
		bgFile = [[Interface\Buttons\WHITE8x8]],
		edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
		insets = {left = 3, right = 3, top = 4, bottom = 3
	}})
	helpFrame:SetBackdropColor(0, 0, 0, 1)
	helpFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
	
	local customRotationHelp = helpFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	customRotationHelp:SetFont('Fonts\\ARIALN.ttf', 13, 'THINOUTLINE')
	customRotationHelp:SetHeight(550)
	customRotationHelp:SetWidth(430)
	customRotationHelp:SetPoint("TOPLEFT", helpFrame, "TOPLEFT", 20 ,-40)
	customRotationHelp:SetNonSpaceWrap(true)
	customRotationHelp:SetJustifyH("LEFT")
	customRotationHelp:SetJustifyV("TOP")
	
	local helpText = jps.redColor("Required")..'\n- a spellTable e.g. "local spellTable = {}"\n- the function call local spell,target = parseSpellTable(spellTable)\n- your rotation should return a spell and a target, e.g. "return spell, target"\n\n'..jps.redColor("Example Rotation")..'\nlocal spell = nil\;\nlocal target = nil\;\nlocal spellTable = {\n     { "Frost Presence",        not jps.buff("Frost Presence") },\n     { "frost strike",        "onCD"},\n     { "obliterate",        "onCD"},\n };\n\nspell,target = parseSpellTable(spellTable)\;\nreturn spell,target\n\n'..jps.redColor("Functions / Know How")..'\nvalid targets are: "player","target","focus","mouseover","pet","raidN" (N = 1-40), "partyN" (N=1-4) and many more\n\n- jps.buff("buffName", "target") -- returns true or false whether a buff is applied, buffName is required\n- jps.debuff("debuffName", "target") -- returns true or false whether a debuff is applied, buffName is required\n- jps.buffDuration("buffName","target") -- returns the duration of a buff in seconds\n- jps.debuffDuration("debuffName","target") -- returns the duration of a debuff in seconds\n- jps.UseCDs -- Usage of CDs enabled or disabled\n- jps.MultiTarget -- Multitarget enabled or disabled\n- jps.hp("target") -- return decimal hp of a target ( 1 = 100% health, 0.5 = 50% health )'
	
	customRotationHelp:SetText(helpText)	

	local jpsCustomRotationRemove = CreateFrame('Button', 'closeHelp', helpFrame , 'UIPanelButtonTemplate')
	jpsCustomRotationRemove:SetText("close")
	jpsCustomRotationRemove:SetPoint("TOP",helpFrame,"TOP", 0, -10)
	jpsCustomRotationRemove:SetScript("OnClick", function()helpFrame:Hide();Scroll:Show() end)
	jpsCustomRotationRemove:SetSize(75,25)	
	jpsCustomRotationRemove:Show()

	InterfaceOptions_AddCategory(jpsCustomRotationFrame)
	jpsCustomRotation:Show()
	Scroll:Show()
	jpsCustomRotationBox:Show()
	jpsCustomRotationButton:Show()
	jpsCustomRotationRemove:Show()
	helpFrame:Hide()
	
end


	
---------------------------
-- Settings Frame
---------------------------

function jps.addSettingsFrame()
	
	-- Custom Event Handlers which are called after a Setting checkbox is clicked
	-- key = name of checkbox, value = function to call
	jps.onClickSettingEvents = {
		["timetodie frame visible"] = jps.TimeToDieToggle,
		["rotation dropdown visible"] = jps.DropdownRotationTogle,
		["show jps window"] = jps.mainIconToggle,
	}
	
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

	for settingsKey,settingsVal in pairs (jps.settings) do
		jps.notifySettingChanged(settingsKey, jps.getConfigVal(settingsKey))

		rotationCountSetting = rotationCountSetting + 1
		if rotationCountSetting == 16 then 
			settingsButtonPositionX = 220
			settingsButtonPositionY = - 90
		elseif rotationCountSetting == 31 then
			settingsButtonPositionX = 420
			settingsButtonPositionY = - 90
		end

		local settingsJPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JPS_Button_Settings_"..settingsKey, jpsSettingsFrame, "OptionsCheckButtonTemplate");
		settingsJPS_IconOptions_CheckButton:SetPoint("TOPLEFT",settingsButtonPositionX,settingsButtonPositionY);
		getglobal(settingsJPS_IconOptions_CheckButton:GetName().."Text"):SetText(settingsKey);

		local function settingsJPS_IconOptions_CheckButton_OnClick()
            local settingsStatus = nil
            if(settingsJPS_IconOptions_CheckButton:GetChecked() == false) then 
                settingsStatus = 0 
            else 
                settingsStatus = 1 
            end
            jps.notifySettingChanged(settingsKey, settingsStatus)
            jps.setConfigVal(settingsKey, settingsStatus)
		end  
		
		local function settingsJPS_IconOptions_CheckButton_OnShow()
			settingsJPS_IconOptions_CheckButton:SetChecked(jps.getConfigVal(settingsKey));
		end  

		settingsJPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
		settingsJPS_IconOptions_CheckButton:SetScript("OnClick", settingsJPS_IconOptions_CheckButton_OnClick);
		settingsJPS_IconOptions_CheckButton:SetScript("OnShow", settingsJPS_IconOptions_CheckButton_OnShow);
		
		settingsButtonPositionY = settingsButtonPositionY - 30;
	end
	
	InterfaceOptions_AddCategory(jpsSettingsFrame)
	
	for key, settingOptions in pairs(jps.settingsQueue) do
		if settingOptions["settingType"] == checkbox then
			jps.addSettingsCheckbox(key)
			jps.settingsQueue[key] = nil
		end
	end
	
	jpsSettingsFrame:Hide()
	
end

function jps.getConfigVal(key, default)
	local setting = jps.settings[string.lower(key)]
	local def = default or 1
	if setting == nil then
		jps.setConfigVal(key, def)
		if not jps.Configged then
			if jps.settingsQueue[key] == nil then
				jps.settingsQueue[key] = {settingType="checkbox" }
			end
		else
			jps.addSettingsCheckbox(key)
		end
		return def
	else 
		return setting
	end
end

function jps.setConfigVal(key,status)
	jps.settings[string.lower(key)] = status
end

function jps.notifySettingChanged(key, status) 
	if jps.onClickSettingEvents[string.lower(key)] ~= nil then
		jps.onClickSettingEvents[string.lower(key)](key, status)
	end
end

function jps.addSettingsCheckbox(settingName)
	rotationCountSetting = rotationCountSetting + 1
	if rotationCountSetting == 16 then 
		settingsButtonPositionX = 220
		settingsButtonPositionY = - 90
	elseif rotationCountSetting == 31 then
		settingsButtonPositionX = 420
		settingsButtonPositionY = - 90
	end

    local settingsJPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JPS_Button_Settings_"..settingName, jpsSettingsFrame, "OptionsCheckButtonTemplate");
    settingsJPS_IconOptions_CheckButton:SetPoint("TOPLEFT",settingsButtonPositionX,settingsButtonPositionY);
    getglobal(settingsJPS_IconOptions_CheckButton:GetName().."Text"):SetText(settingName);
    
    local function settingsJPS_IconOptions_CheckButton_OnClick()
        local settingStatus = nil
        if(settingsJPS_IconOptions_CheckButton:GetChecked() == false) then 
            settingStatus = 0 
        else 
            settingStatus = 1 
        end
        jps.notifySettingChanged(settingName, settingsStatus)
        jps.setConfigVal(settingName, settingsStatus)
    end  
    
    local function settingsJPS_IconOptions_CheckButton_OnShow()
        settingsJPS_IconOptions_CheckButton:SetChecked(jps.getConfigVal(settingName));
    end  
    
    settingsJPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
    settingsJPS_IconOptions_CheckButton:SetScript("OnClick", settingsJPS_IconOptions_CheckButton_OnClick);
    settingsJPS_IconOptions_CheckButton:SetScript("OnShow", settingsJPS_IconOptions_CheckButton_OnShow);

    settingsButtonPositionY = settingsButtonPositionY - 30;
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
	if jps.Spec then
		rotationInfo:SetText("Rotation Config for your "..jps.Spec.." "..jps.Class)
	end
	
	local desc = jpsRotationFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	desc:SetHeight(32)
	desc:SetPoint("TOPLEFT", rotationInfo, "BOTTOMLEFT", 0, 16)
	desc:SetPoint("RIGHT", jpsRotationFrame, -32, 0)
	desc:SetNonSpaceWrap(true)
	desc:SetJustifyH("LEFT")
	desc:SetJustifyV("TOP")
	desc:SetText("Uncheck spells when you dont want to use them. Do a /jps db to reset the spells")
	if jps.spellConfig[jps.Spec] then
		for spellKey,spellVal in pairs (jps.spellConfig[jps.Spec]) do
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
	            if(rotationJPS_IconOptions_CheckButton:GetChecked() == false) then 
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
	end
	
	InterfaceOptions_AddCategory(jpsRotationFrame)
	jpsRotationFrame:Hide()
end

---------------------------
-- HIDE/SHOW DROPDOWN SPELLS
---------------------------

function jps.DropdownRotationTogle(key, status)
	if status == 1 then
		rotationDropdownHolder:Show()
	else
		rotationDropdownHolder:Hide()
	end
end

function jps.TimeToDieToggle(key, status)
	if status == 1 and InCombatLockdown() == 1 then
		JPSEXTInfoFrame:Show()
	else
		JPSEXTInfoFrame:Hide()
	end
end

function jps.mainIconToggle(key, status) 
	if status == 1 then
		jpsIcon:Show()
	else
		jpsIcon:Hide()
	end
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
        if(rotationJPS_IconOptions_CheckButton:GetChecked() == false) then 
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

function jps.loadDefaultSettings() 
	
	local settingsTable = {}
	if not jps.settings[string.lower("rotation dropdown visible")] then settingsTable["rotation dropdown visible"] = 1; end
	if not jps.settings[string.lower("timetodie frame visible")] then settingsTable["timetodie frame visible"] = 1; end
	if not jps.settings[string.lower("facetarget rotate direction. checked = left, unchecked = right")] then settingsTable["facetarget rotate direction. checked = left, unchecked = right"] = 1; end
	if not jps.settings[string.lower("dismount in combat")] then settingsTable["dismount in combat"] = 0; end
	if not jps.settings[string.lower("quiet mode")] then settingsTable["quiet mode"] = 0; end

	for key,val in pairs(settingsTable) do 
		if jps.settings[string.lower(key)] == nil then
			jps.settings[string.lower(key)] = val
		end
	end
end


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
		jpsDB[jpsRealm][jpsName].RaidMode = false
		jpsDB[jpsRealm][jpsName].spellConfig = {} -- NEW
		if jps.Spec then
			jpsDB[jpsRealm][jpsName].spellConfig[jps.Spec] = {} -- NEW
		end
		jpsDB[jpsRealm][jpsName].settings = {} -- NEW
	else
		if ( not jpsDB[jpsRealm][jpsName].spellConfig) then -- NEW
			jpsDB[jpsRealm][jpsName].spellConfig = {} -- NEW
		end
		if ( not jpsDB[jpsRealm][jpsName].settings) then -- NEW
			jpsDB[jpsRealm][jpsName].settings = {} -- NEW
		end		
		
		if jps.Spec then
			if ( not jpsDB[jpsRealm][jpsName].spellConfig[jps.Spec]) then -- NEW
				jpsDB[jpsRealm][jpsName].spellConfig[jps.Spec] = {} -- NEW
			end	
		end
		if not jpsDB[jpsRealm][jpsName].RaidMode then		
			jpsDB[jpsRealm][jpsName].RaidMode = false
		end
	end

	jps_LOAD_PROFILE()
	jps_SAVE_PROFILE()
	jps.loadDefaultSettings()
	jps.runFunctionQueue("settingsLoaded")
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


