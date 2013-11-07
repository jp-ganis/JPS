--[[
TO-DO:
- check behavior on respec
- add maybe default slashcommand
- add getPercent function
- add helper functions for key modifiers
- idea: for larger rotations add subviews/tabs 
]]--



mConfigAllConfigs = {}


local mConfigVersion = 1
local DISPLAYED_OPTIONS = 8
local OPTIONS_HEIGHT = 40
local OPTIONS_WIDTH = 400
MCONFIG_VERSION = mConfigVersion
mConfig = {}

local _nextElementId = 1
local function nextElementId()
    local name = "MCONFIG_ELEMENT_" .. _nextElementId
    _nextElementId = _nextElementId + 1
    return name
end

local function addTooltip(frame, title, text)
    if text and title then
        frame:SetScript("OnEnter",  function (self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetText(title)
            GameTooltip:AddLine(text, 1, 1, 1)
            GameTooltip:Show()
        end)

        frame:SetScript("OnLeave",  function (self)
            GameTooltip:Hide()
        end)
    end
end

local testMode = false
function mConfig:testMode()
    if not testMode then
        testMConfig()
        testMode = true
    end
end

function mConfig:addButton(text,tooltip,fn)
    local button = CreateFrame("Button", nil, jps.rotationConfig.frames.scrollFrame)
    button:SetNormalFontObject("GameFontNormal")
    button:SetSize(OPTIONS_WIDTH, OPTIONS_HEIGHT)
    button:SetText(text)
    addTooltip(button, text, tooltip)
    if fn then
        button:SetScript("OnClick", function() fn(jps.rotationConfig.values) end)
    end
    
    table.insert(jps.rotationConfig.frames.options, button)
    
    mConfig:update()
end
function mConfig:addText(text, tooltip)

    local optionFrame = CreateFrame("Frame", nil, jps.rotationConfig.frames.scrollFrame)
    optionFrame:SetSize(OPTIONS_WIDTH, OPTIONS_HEIGHT)
    addTooltip(optionFrame, text, tooltip)

    local optionText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionText:SetPoint("LEFT",optionFrame,20,-6)
    optionText:SetWidth(OPTIONS_WIDTH-40)
    optionText:SetHeight(OPTIONS_HEIGHT)
    optionText:SetText(text)
    optionText:SetJustifyH("CENTER")
    optionText:SetJustifyV("CENTER")
    
    table.insert(jps.rotationConfig.frames.options, optionFrame)
end

function mConfig:addCheckBox(key, text, tooltip, defaultValue)
    if not defaultValue then defaultValue = false end
    if not jps.rotationConfig.values[key] then jps.rotationConfig.values[key] = defaultValue end

    local optionFrame = CreateFrame("Frame", nil, jps.rotationConfig.frames.scrollFrame)
    optionFrame:SetSize(OPTIONS_WIDTH, OPTIONS_HEIGHT)
    addTooltip(optionFrame, text, tooltip)

    local checkbutton = CreateFrame("CheckButton", nil, optionFrame, "ChatConfigSmallCheckButtonTemplate")
    checkbutton:SetHitRectInsets(4,4,4,4);
    checkbutton:SetPoint("RIGHT",optionFrame,-30,-5)
    --checkbutton.tooltip = tooltip
    checkbutton:SetChecked(defaultValue)
    checkbutton:SetScript("OnClick", function()
        jps.rotationConfig.values[key] = checkbutton:GetChecked(defaultValue) == 1
    end)
   -- checkbutton:SetWidth(30)
    optionFrame:Show()

    local optionText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionText:SetPoint("LEFT",optionFrame,20,-6)
    optionText:SetWidth(OPTIONS_WIDTH-80)
    optionText:SetHeight(OPTIONS_HEIGHT)
    optionText:SetText(text)
    optionText:SetJustifyH("LEFT")
    
    jps.rotationConfig.defaults[key] = defaultValue
    table.insert(jps.rotationConfig.frames.options, optionFrame)
    jps.rotationConfig.setters[key] = function(v) checkbutton:SetChecked(v) end
    jps.rotationConfig.update(self)
end

function mConfig:addTextBox(key, text, tooltip, defaultValue)
    if not defaultValue then defaultValue = "" end
    if not jps.rotationConfig.values[key] then jps.rotationConfig.values[key] = defaultValue end

    local optionFrame = CreateFrame("Frame", nil, jps.rotationConfig.frames.scrollFrame)
    optionFrame:SetSize(OPTIONS_WIDTH, OPTIONS_HEIGHT)
    addTooltip(optionFrame, text, tooltip)
    optionFrame:Show()
    
    local textbox = CreateFrame("EditBox",nextElementId() , optionFrame, "InputBoxTemplate" );
    textbox:SetWidth(120)
    textbox:SetHeight(40)
    textbox:SetPoint("RIGHT",optionFrame,-20,-8)
    textbox:SetText(defaultValue)
    textbox:SetAutoFocus(false) 
    textbox:SetScript("OnTextChanged", function()
        jps.rotationConfig.values[key] = textbox:GetText() 
    end)
    getglobal(textbox:GetName().."Middle"):ClearAllPoints()
    getglobal(textbox:GetName().."Middle"):SetPoint("LEFT",getglobal(textbox:GetName().."Left"), "RIGHT", 0, 0)
    getglobal(textbox:GetName().."Middle"):SetPoint("RIGHT",getglobal(textbox:GetName().."Right"), "LEFT", 0, 0)
    textbox:ClearAllPoints()
    textbox:SetPoint("RIGHT",optionFrame,-20,-8)
    --textbox:SetPoint("LEFT",

    local optionText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionText:SetPoint("LEFT",optionFrame,20,-6)
    optionText:SetWidth(OPTIONS_WIDTH-180)
    optionText:SetHeight(OPTIONS_HEIGHT)
    optionText:SetText(text)
    optionText:SetJustifyH("LEFT")
    
    jps.rotationConfig.defaults[key] = defaultValue
    jps.rotationConfig.setters[key] = function(v) textbox:SetText(v) end
    table.insert(jps.rotationConfig.frames.options, optionFrame)
    mConfig:update()
end

function mConfig:addNumericBox(key, text, tooltip, defaultValue)
    if not defaultValue then defaultValue = 0 end
    if not jps.rotationConfig.values[key] then jps.rotationConfig.values[key] = defaultValue end

    local optionFrame = CreateFrame("Frame", nil, jps.rotationConfig.frames.scrollFrame)
    optionFrame:SetSize(OPTIONS_WIDTH, OPTIONS_HEIGHT)
    addTooltip(optionFrame, text, tooltip)
    optionFrame:Show()

    local textbox = CreateFrame("EditBox", nextElementId(), optionFrame, "InputBoxTemplate" );
    textbox:SetWidth(60)
    textbox:SetHeight(40)
    textbox:SetText(defaultValue)
    textbox:SetAutoFocus(false) 
    textbox:SetScript("OnTextChanged", function()
        jps.rotationConfig.values[key] = textbox:GetNumber()
    end)
    getglobal(textbox:GetName().."Middle"):ClearAllPoints()
    getglobal(textbox:GetName().."Middle"):SetPoint("LEFT",getglobal(textbox:GetName().."Left"), "RIGHT", 0, 0)
    getglobal(textbox:GetName().."Middle"):SetPoint("RIGHT",getglobal(textbox:GetName().."Right"), "LEFT", 0, 0)
    textbox:ClearAllPoints()
    textbox:SetPoint("RIGHT",optionFrame,-20,-8)
    
    

    local optionText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionText:SetPoint("LEFT",optionFrame,20,-6)
    optionText:SetWidth(OPTIONS_WIDTH-120)
    optionText:SetHeight(OPTIONS_HEIGHT)
    optionText:SetText(text)
    optionText:SetJustifyH("LEFT")
    
    jps.rotationConfig.defaults[key] = defaultValue
    jps.rotationConfig.setters[key] = function(v) textbox:SetText(v) end
    table.insert(jps.rotationConfig.frames.options, optionFrame)

    mConfig:update()
end

function mConfig:addSlider(key, text, tooltip, minValue, maxValue, defaultValue,stepSize)
    if not defaultValue then defaultValue = minValue end
    if not stepSize then stepSize = 1 end
    if not jps.rotationConfig.values[key] then jps.rotationConfig.values[key] = defaultValue end
    local optionFrame = CreateFrame("Frame", nil, jps.rotationConfig.frames.scrollFrame)
    optionFrame:SetSize(OPTIONS_WIDTH, OPTIONS_HEIGHT)
    addTooltip(optionFrame, text, tooltip)
    optionFrame:Show()


    local optionText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionText:SetPoint("LEFT",optionFrame,20,-6)
    optionText:SetWidth(OPTIONS_WIDTH-180)
    optionText:SetHeight(OPTIONS_HEIGHT)
    optionText:SetText(text .. "|r |cffffffff (" .. (math.floor(jps.rotationConfig.values[key]*10)/10) .. ")|r")
    optionText:SetJustifyH("LEFT")

    local slider = CreateFrame("Slider", nextElementId(), optionFrame, "OptionsSliderTemplate")
    slider:SetScale(1)
    slider:SetMinMaxValues(minValue,maxValue)
    slider.minValue, slider.maxValue = slider:GetMinMaxValues()
    slider:SetValue(jps.rotationConfig.values[key])
    slider:SetValueStep(stepSize)
    slider:SetWidth(120)
    --slider:SetHeight(20)
    slider:EnableMouse(true)
    slider:SetPoint("RIGHT",optionFrame,-20,-8)
    getglobal(slider:GetName() .. 'Low'):SetText(lowText)
    getglobal(slider:GetName() .. 'High'):SetText(HighText)
    getglobal(slider:GetName() .. 'Text'):SetText(title)
    slider:SetScript("OnValueChanged", function()
        jps.rotationConfig.values[key] = slider:GetValue() 
        optionText:SetText(text .. "|r |cffffffff (" .. (math.floor(jps.rotationConfig.values[key]*10)/10) .. ")|r")
    end)
    
    jps.rotationConfig.defaults[key] = defaultValue
    jps.rotationConfig.setters[key] = function(v) slider:SetValue(v) end
    table.insert(jps.rotationConfig.frames.options, optionFrame)
    
    mConfig:update()
end


function mConfig:addDropDown(key, text, tooltip, values, defaultValue)
    if not defaultValue then defaultValue = 1 end
    if not jps.rotationConfig.values[key] then jps.rotationConfig.values[key] = defaultValue end

    local optionFrame = CreateFrame("Frame", nil, jps.rotationConfig.frames.scrollFrame)
    optionFrame:SetSize(OPTIONS_WIDTH, OPTIONS_HEIGHT)
    addTooltip(optionFrame, text, tooltip)
    optionFrame:Show()


    local optionText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionText:SetPoint("LEFT",optionFrame,20,-6)
    optionText:SetWidth(OPTIONS_WIDTH-180)
    optionText:SetHeight(OPTIONS_HEIGHT)
    optionText:SetText(text)
    optionText:SetJustifyH("LEFT")

    local dropdown = CreateFrame("Frame", nextElementId(), optionFrame, "UIDropDownMenuTemplate")
    local InitializeDropdown = function()
        local info = UIDropDownMenu_CreateInfo()
        local configValues = jps.rotationConfig.values
        for k,v in pairs(values) do
                info.text = v;
                info.value = k;
                info.func  = function(self)
                    UIDropDownMenu_SetSelectedValue(dropdown, jps.rotationConfig.value)
                    configValues[key] = jps.rotationConfig.value
                    UIDropDownMenu_SetText(dropdown, v)
                end
                info.checked = nil
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info, 1);
        end
    end

    dropdown:SetPoint("RIGHT",optionFrame, 0,-8)
    UIDropDownMenu_SetWidth(dropdown, 110);
    UIDropDownMenu_JustifyText(dropdown, "LEFT");
    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)
    jps.rotationConfig.defaults[key] = defaultValue
    jps.rotationConfig.setters[key] = function(v) 
        UIDropDownMenu_SetSelectedValue(dropdown, v)
        for k,text in pairs(values) do
            if k == v then UIDropDownMenu_SetText(dropdown, text) end
        end
    end
    jps.rotationConfig.setters[key](defaultValue)
    table.insert(jps.rotationConfig.frames.options, optionFrame)
    
    mConfig:update()
end



function mConfig:update()
    local numItems = #(jps.rotationConfig.frames.options)
    FauxScrollFrame_Update(jps.rotationConfig.frames.scrollFrame, numItems, DISPLAYED_OPTIONS, OPTIONS_HEIGHT)
    local offset = FauxScrollFrame_GetOffset(jps.rotationConfig.frames.scrollFrame) + 1
    for key,value in pairs(jps.rotationConfig.values) do
        if jps.rotationConfig.setters[key] then 
            jps.rotationConfig.setters[key](value) 
        end
    end
    for line = 1, numItems do
        local option = jps.rotationConfig.frames.options[line]
        if line < offset then
            option:Hide()
        elseif line == offset then
            option:SetPoint("TOP", jps.rotationConfig.frames.scrollFrame,0,-5)
            option:Show()
        elseif line >= offset + DISPLAYED_OPTIONS then
            option:Hide()
        else
            option:SetPoint("TOP", jps.rotationConfig.frames.options[line - 1], "BOTTOM")
            option:Show()
        end
    end

end

function mconfig_SAVE_VARIABLES()
    for _,c in pairs(mConfigAllConfigs) do
        if jpsDB.mconfigData[c.addOn] then
            jpsDB.mconfigData[c.addOn][c.key] = jps.rotationConfig.values[c.key]
        end
    end	
end

function mConfig:Show()
    jps.rotationConfig.frames.configFrame:Show()
end

function mConfig:Hide()
    jps.rotationConfig.frames.configFrame:Hide()
end

function mConfig:Toggle()
    if jps.rotationConfig.frames.configFrame:IsShown() then
        jps.rotationConfig.frames.configFrame:Hide()
    else
        jps.rotationConfig.frames.configFrame:Show()
    end
end

function mConfig:get(key)
    return jps.rotationConfig.values[key]
end

function mConfig:set(key, value)
    jps.rotationConfig.values[key] = value
    return mConfig:update()
end

function mConfig:defaultValues()
    for k,v in pairs(jps.rotationConfig.defaults) do
        jps.rotationConfig.values[k] = v
    end
    return mConfig:update()
end

function mConfig:getPercent(key)
	return jps.rotationConfig.values[key]/100
end

function mConfig:createConfig(titleText,addOn,key,slashCommands)
    if not key then key = "Default" end
    if not jpsDB.mconfigData then
		jpsDB.mconfigData = {}
	end
    if not jpsDB.mconfigData[addOn] then jpsDB.mconfigData[addOn] = {} end
    if not jpsDB.mconfigData[addOn][key] then jpsDB.mconfigData[addOn][key] = {} end
    local data = {
        frames={options={}},
        addOn=addOn,
        key=key,
        values=jpsDB.mconfigData[addOn][key],
        defaults={},
        setters={},
    }
    table.insert(mConfigAllConfigs, data)
    data.frames.configFrame = CreateFrame("Frame", nil,UIParent)
    data.frames.configFrame:SetPoint("CENTER",UIParent)
    data.frames.configFrame:EnableMouse(true)
    data.frames.configFrame:SetMovable(true)
    data.frames.configFrame:SetWidth(OPTIONS_WIDTH + 100)
    data.frames.configFrame:SetHeight((DISPLAYED_OPTIONS+2) * OPTIONS_HEIGHT + 20)
    data.frames.configFrame:RegisterForDrag("LeftButton")
    data.frames.configFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    data.frames.configFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    data.frames.configFrame:SetClampedToScreen(true)
    data.frames.configFrame:SetBackdrop({
        --   bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    data.frames.configFrame:Hide()
    
    local title = CreateFrame("Frame", nil, data.frames.configFrame)
    title:SetPoint("TOP", data.frames.configFrame)
    title:SetWidth(OPTIONS_WIDTH)
    title:SetHeight(OPTIONS_HEIGHT)
    local text = title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetWidth(OPTIONS_WIDTH)
    text:SetHeight(OPTIONS_HEIGHT)
    text:SetPoint("LEFT",title)
    text:SetText(titleText)
    title:Show()
  
    data.frames.scrollFrame = CreateFrame("ScrollFrame", "mConfigScrollFrame"..nextElementId(), data.frames.configFrame, "FauxScrollFrameTemplate")
    data.frames.scrollFrame:SetPoint("CENTER",data.frames.configFrame)
    data.frames.scrollFrame:SetWidth(OPTIONS_WIDTH)
    data.frames.scrollFrame:SetHeight(DISPLAYED_OPTIONS * OPTIONS_HEIGHT + 20)
    data.frames.scrollFrame:Show()
    data.frames.scrollFrame:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        -- bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    data.frames.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, OPTIONS_HEIGHT, function() mConfig:update() end)
    end)
    
    --data.frames.scrollFrame:SetScript("OnUpdate", function() data:update() end)

    local button = CreateFrame("Button", nil, data.frames.configFrame)
    button:SetPoint("BOTTOM", data.frames.configFrame, "BOTTOM", 0, 10)
    button:SetWidth(100)
    button:SetHeight(25)
    button:SetText("Close")
    button:SetNormalFontObject("GameFontNormal")
    button:SetScript("OnClick", function(self) data.frames.configFrame:Hide() end)
    -- Button Textures
    local ntex = button:CreateTexture()
    ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
    ntex:SetTexCoord(0, 0.625, 0, 0.6875)
    ntex:SetAllPoints() 
    button:SetNormalTexture(ntex)
    local htex = button:CreateTexture()
    htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
    htex:SetTexCoord(0, 0.625, 0, 0.6875)
    htex:SetAllPoints()
    button:SetHighlightTexture(htex)
    local ptex = button:CreateTexture()
    ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
    ptex:SetTexCoord(0, 0.625, 0, 0.6875)
    ptex:SetAllPoints()
    button:SetPushedTexture(ptex)
    
    if slashCommands then
        local slashId = "MCONFIG_"..addOn.."_"..key
        if type(slashCommands) == "table" then
            local pos = 1
            for _,slashCommand in pairs(slashCommands) do
                _G["SLASH_"..slashId..pos] = slashCommand
                pos = pos + 1
            end
        else
            _G["SLASH_"..slashId.."1"] = slashCommands
        end
        SlashCmdList[slashId] = function(msg,editbox)
            if data.frames.configFrame:IsShown() then
                data.frames.configFrame:Hide()
            else
                data.frames.configFrame:Show()
                data.frames.scrollFrame:Show()
            end
        end
    end
    jps.rotationConfig = data
    	
	if not jpsDB.mconfigData then
		jpsDB.mconfigData = {}
	end
    for _,c in pairs(mConfigAllConfigs) do
        if jpsDB.mconfigData[c.addOn] then
            jps.rotationConfig.values[c.key] = jpsDB.mconfigData[c.addOn][c.key]
            mConfig:update()
        end
    end

end

