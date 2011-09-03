-- Please work.
jpsConfigFrame = CreateFrame("Frame", "jpsConfigButton", UIParent)
local w = 256
local h = 128

-- Size/Pos
jpsConfigFrame:SetWidth(256)
jpsConfigFrame:SetHeight(128)
jpsConfigFrame:SetPoint("CENTER",0,0)

-- Set the texture
local t = jpsConfigFrame:CreateTexture(nil,"BACKGROUND")
t:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
t:SetAllPoints(jpsConfigFrame)
jpsConfigFrame.texture = t

-- Set them movable
jpsConfigFrame:SetMovable(true)
jpsConfigFrame:EnableMouse(true)
jpsConfigFrame:RegisterForDrag("LeftButton")
jpsConfigFrame:SetScript("OnDragStart", jpsConfigFrame.StartMoving)
jpsConfigFrame:SetScript("OnDragStop", jpsConfigFrame.StopMovingOrSizing)

-- Create a close button
local closeButton = CreateFrame("Button",nil,jpsConfigFrame)
closeButton:SetPoint("BOTTOMRIGHT",w-10,h-10)
closeButton:SetText("Done")

-- More JPS <3
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

-- <3 to JPS
-- Create a checkbox
local cmdfuncs = {}
cmdfuncs["pvp"] = function () jps.PvP = not jps.PvP end
local buttonPositionY = -60;
local buttonPositionX = 40;

local t = {"pvp"}
local bar_cmd_table={cmdfuncs["pvp"]}
local t2 = {"toggle pvp"}

for i,v in ipairs (t) do
    local JPS_IconOptions_CheckButton = CreateFrame("CheckButton", "JUKED_Button_"..v, jpsConfigFrame, "OptionsCheckButtonTemplate");
    JPS_IconOptions_CheckButton:SetPoint("TOPLEFT",buttonPositionX,buttonPositionY);
    getglobal(JPS_IconOptions_CheckButton:GetName().."Text"):SetText(t2[i]);

    local function JPS_IconOptions_CheckButton_OnClick()
            bar_cmd_table[i](1,"gui")
    end  

    local function JPS_IconOptions_CheckButton_OnShow()
        JPS_IconOptions_CheckButton:SetChecked(JPSDB[CharIndex][v]);
    end  

    JPS_IconOptions_CheckButton:RegisterForClicks("AnyUp");
    JPS_IconOptions_CheckButton:SetScript("OnClick", JPS_IconOptions_CheckButton_OnClick);
    JPS_IconOptions_CheckButton:SetScript("OnShow", JPS_IconOptions_CheckButton_OnShow);
    buttonPositionY = buttonPositionY - 30;
end

-- Hide at load
InterfaceOptions_AddCategory(jpsConfigFrame)
jpsConfigFrame:Hide()
