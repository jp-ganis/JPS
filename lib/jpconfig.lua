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

local rotationButtonPositionY = -90
local rotationButtonPositionX = 40
local jpsRotationFrame = nil
	
function jps_createConfigFrame()
	jpsConfigFrame = CreateFrame("Frame", "jpsConfigFrame", UIParent)
	local w = 256
	local h = 128

	-- More Juked <3
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
	
	local t = {1,2,3,4,5,6,7,8}
	for var,value in pairs(jpsDB[jpsRealm][jpsName]) do
		if type(jpsDB[jpsRealm][jpsName][var]) == "boolean" then
			if var == "Enabled" then t[1] = var
			elseif var == "FaceTarget" then t[2] = var
			elseif var == "MoveToTarget" then t[3] = var
			elseif var == "Interrupts" then t[4] = var
			elseif var == "PvP" then t[5] = var
			elseif var == "UseCDs" then t[6] = var
			elseif var == "MultiTarget" then t[7] = var
			elseif var == "ExtraButtons" then t[8] = var
			else table.insert(t,var)
			end
		end
	end
	local rotationConfigExist = false

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
		if i == 6 then buttonPositionY = buttonPositionY - 30 end
		buttonPositionY = buttonPositionY - 30;
	end
	
	-- Hide at load
	InterfaceOptions_AddCategory(jpsConfigFrame)
	jps.Configged = true
	jpsConfigFrame:Hide()	
	
	
	jpsRotationFrame = CreateFrame("Frame", "jpsRotationFrame", jpsConfigFrame)
	jpsRotationFrame.parent  = jpsConfigFrame.name
	jpsRotationFrame.name = "JPS Rotation Panel"
	local title = jpsRotationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 20, -10) 
	title:SetText("JPS Rotation")
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
	desc:SetPoint("TOPLEFT", rotationInfo, "BOTTOMLEFT", 0, 0)
	desc:SetPoint("RIGHT", jpsRotationFrame, -32, 0)
	desc:SetNonSpaceWrap(true)
	desc:SetJustifyH("LEFT")
	desc:SetJustifyV("TOP")
	desc:SetText("Uncheck spells when you dont want to use them.")
		
		
	for spellKey,spellVal in pairs (jpsDB[jpsRealm][jpsName].spellConfig) do
		local rotationJPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JPS_Button_"..spellKey, jpsRotationFrame, "OptionsCheckButtonTemplate");
		rotationJPS_IconOptions_CheckButton:SetPoint("TOPLEFT",rotationButtonPositionX,rotationButtonPositionY);
		getglobal(rotationJPS_IconOptions_CheckButton:GetName().."Text"):SetText(spellKey);

		local function rotationJPS_IconOptions_CheckButton_OnClick()
            local spellStatus = nil
            if(rotationJPS_IconOptions_CheckButton:GetChecked() == nil) then 
                status = 0 
            else 
                status = 1 
            end
            setSpellStatus(spellKey, status)
		end  
		
		local function rotationJPS_IconOptions_CheckButton_OnShow()
			rotationJPS_IconOptions_CheckButton:SetChecked(getSpellStatus(spellKey));
		end  

		
		
		rotationJPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
		rotationJPS_IconOptions_CheckButton:SetScript("OnClick", rotationJPS_IconOptions_CheckButton_OnClick);
		rotationJPS_IconOptions_CheckButton:SetScript("OnShow", rotationJPS_IconOptions_CheckButton_OnShow);
		if i == 6 then rotationButtonPositionY = rotationButtonPositionY - 30 end
		rotationButtonPositionY = rotationButtonPositionY - 30;
	end


	InterfaceOptions_AddCategory(jpsRotationFrame)
	jpsRotationFrame:Hide()
end

function addSpellCheckboxToFrame(spellName)
    local rotationJPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JPS_Button_"..spellName, jpsRotationFrame, "OptionsCheckButtonTemplate");
    rotationJPS_IconOptions_CheckButton:SetPoint("TOPLEFT",rotationButtonPositionX,rotationButtonPositionY);
    getglobal(rotationJPS_IconOptions_CheckButton:GetName().."Text"):SetText(spellName);
    
    local function rotationJPS_IconOptions_CheckButton_OnClick()
        local spellStatus = nil
        if(rotationJPS_IconOptions_CheckButton:GetChecked() == nil) then 
            status = 0 
        else 
            status = 1 
        end
        setSpellStatus(spellName, status)
    end  
    
    local function rotationJPS_IconOptions_CheckButton_OnShow()
        rotationJPS_IconOptions_CheckButton:SetChecked(getSpellStatus(spellName);
    end  
    
    rotationJPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
    rotationJPS_IconOptions_CheckButton:SetScript("OnClick", rotationJPS_IconOptions_CheckButton_OnClick);
    rotationJPS_IconOptions_CheckButton:SetScript("OnShow", rotationJPS_IconOptions_CheckButton_OnShow);
    
    if i == 6 then rotationButtonPositionY = rotationButtonPositionY - 30 end
    rotationButtonPositionY = rotationButtonPositionY - 30;
end