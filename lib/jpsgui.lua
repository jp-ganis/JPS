-- Huge thanks to BenPhelps for these SO sexy buttons.
jps.GUInormal = "Interface\\AddOns\\JPS\\media\\jps.tga"
jps.GUIpvp = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp"
jps.GUInoplua = "Interface\\Icons\\Spell_Totem_WardOfDraining"
jps.GUIshadow = "Interface\\AddOns\\JPS\\media\\shadow.tga"
jps.GUIborder = "Interface\\AddOns\\JPS\\media\\border.tga"
jps.GUIborder_active = "Interface\\AddOns\\JPS\\media\\border_on.tga"
jps.GUIborder_combat = "Interface\\AddOns\\JPS\\media\\border_combat.tga"
jps.GUIicon_cd = "Interface\\Icons\\Spell_Holy_BorrowedTime"
jps.GUIicon_multi = "Interface\\Icons\\achievement_arena_5v5_3"
jps.GUIicon_int = "Interface\\Icons\\INV_Shield_05"
jps.IconSize = 36
jps.ButtonGrowthDir = "right"

BINDING_HEADER_JPS = "JPS Toggles"
BINDING_NAME_JPSTOGGLE = "Enabled/Disable"
BINDING_NAME_JPSTOGGLEMULTI = "Multi Target"
BINDING_NAME_JPSTOGGLECD = "CD Usage"


-- Create the frame that does all the work, pew pew...
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
jpsIcon.texture:SetPoint('TOPRIGHT', jpsIcon, -2, -2) -- inset it by 2px or pt or w/e the game uses
jpsIcon.texture:SetPoint('BOTTOMLEFT', jpsIcon, 2, 2)
jpsIcon.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93) -- cut off the blizzard border
jpsIcon.texture:SetTexture(jps.GUInormal) -- set the default texture

-- barrowed this, along with the texture from nMainbar
jpsIcon.border = jpsIcon:CreateTexture(nil, "OVERLAY") -- create the border texture
jpsIcon.border:SetParent(jpsIcon) -- link it with the icon frame so it drags around with it
jpsIcon.border:SetPoint('TOPRIGHT', jpsIcon, 1, 1) -- outset the points a bit so it goes around the spell icon
jpsIcon.border:SetPoint('BOTTOMLEFT', jpsIcon, -1, -1)
jpsIcon.border:SetTexture(jps.GUIborder) -- set the texture
jpsIcon.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND") -- create the icon frame
jpsIcon.shadow:SetParent(jpsIcon) -- link it with the icon frame so it drags around with it
jpsIcon.shadow:SetPoint('TOPRIGHT', jpsIcon.border, 4.5, 4.5) -- outset the points a bit so it goes around the border
jpsIcon.shadow:SetPoint('BOTTOMLEFT', jpsIcon.border, -4.5, -4.5) -- outset the points a bit so it goes around the border
jpsIcon.shadow:SetTexture(jps.GUIshadow)  -- set the texture
jpsIcon.shadow:SetVertexColor(0, 0, 0, 0.85)  -- color the texture black and set the alpha so its a bit more trans

jpsIcon:SetScript("OnClick", function(self, button)
	if button == "LeftButton" then
		jps.gui_toggleEnabled()
	elseif button == "RightButton" then
		if IsShiftKeyDown() then
			jps.gui_setToggleDir()
		else
			jps.gui_toggleToggles()
		end
	end
end)

ToggleCDs = CreateFrame("Button", "ToggleCDs", jpsIcon)
ToggleCDs:RegisterForClicks("LeftButtonUp")
ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 40, 0)
ToggleCDs:SetHeight(36)
ToggleCDs:SetWidth(36)
ToggleCDs.texture = ToggleCDs:CreateTexture()
ToggleCDs.texture:SetPoint('TOPRIGHT', ToggleCDs, -3, -3)
ToggleCDs.texture:SetPoint('BOTTOMLEFT', ToggleCDs, 3, 3)
ToggleCDs.texture:SetTexture(jps.GUIicon_cd)
ToggleCDs.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
ToggleCDs.border = ToggleCDs:CreateTexture(nil, "OVERLAY")
ToggleCDs.border:SetParent(ToggleCDs)
ToggleCDs.border:SetPoint('TOPRIGHT', ToggleCDs, 1, 1)
ToggleCDs.border:SetPoint('BOTTOMLEFT', ToggleCDs, -1, -1)
ToggleCDs.border:SetTexture(jps.GUIborder)

ToggleCDs.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
ToggleCDs.shadow:SetParent(ToggleCDs)
ToggleCDs.shadow:SetPoint('TOPRIGHT', ToggleCDs.border, 4.5, 4.5) 
ToggleCDs.shadow:SetPoint('BOTTOMLEFT', ToggleCDs.border, -4.5, -4.5) 
ToggleCDs.shadow:SetTexture(jps.GUIshadow)
ToggleCDs.shadow:SetVertexColor(0, 0, 0, 0.85)  


ToggleCDs:SetScript("OnClick", function(self, button)
	jps.gui_toggleCDs()
end)


ToggleMulti = CreateFrame("Button", "ToggleMulti", jpsIcon)
ToggleMulti:RegisterForClicks("LeftButtonUp")
ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 80, 0)
ToggleMulti:SetHeight(36)
ToggleMulti:SetWidth(36)
ToggleMulti.texture = ToggleMulti:CreateTexture()
ToggleMulti.texture:SetPoint('TOPRIGHT', ToggleMulti, -3, -3)
ToggleMulti.texture:SetPoint('BOTTOMLEFT', ToggleMulti, 3, 3)
ToggleMulti.texture:SetTexture(jps.GUIicon_multi)
ToggleMulti.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
ToggleMulti.border = ToggleMulti:CreateTexture(nil, "OVERLAY") -- create the
ToggleMulti.border:SetParent(ToggleMulti) -- link it with the icon frame so 
ToggleMulti.border:SetPoint('TOPRIGHT', ToggleMulti, 1, 1) -- outset the poi
ToggleMulti.border:SetPoint('BOTTOMLEFT', ToggleMulti, -1, -1)
ToggleMulti.border:SetTexture(jps.GUIborder)

ToggleMulti.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
ToggleMulti.shadow:SetParent(ToggleMulti)
ToggleMulti.shadow:SetPoint('TOPRIGHT', ToggleMulti.border, 4.5, 4.5) 
ToggleMulti.shadow:SetPoint('BOTTOMLEFT', ToggleMulti.border, -4.5, -4.5) 
ToggleMulti.shadow:SetTexture(jps.GUIshadow)
ToggleMulti.shadow:SetVertexColor(0, 0, 0, 0.85)

ToggleMulti:SetScript("OnClick", function(self, button)
	jps.gui_toggleMulti()
end)

ToggleInt = CreateFrame("Button", "ToggleInt", jpsIcon)
ToggleInt:RegisterForClicks("LeftButtonUp")
ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 120, 0)
ToggleInt:SetHeight(36)
ToggleInt:SetWidth(36)
ToggleInt.texture = ToggleInt:CreateTexture()
ToggleInt.texture:SetPoint('TOPRIGHT', ToggleInt, -3, -3)
ToggleInt.texture:SetPoint('BOTTOMLEFT', ToggleInt, 3, 3)
ToggleInt.texture:SetTexture(jps.GUIicon_int)
ToggleInt.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
ToggleInt.border = ToggleInt:CreateTexture(nil, "OVERLAY") -- create the
ToggleInt.border:SetParent(ToggleInt) -- link it with the icon frame so 
ToggleInt.border:SetPoint('TOPRIGHT', ToggleInt, 1, 1) -- outset the poi
ToggleInt.border:SetPoint('BOTTOMLEFT', ToggleInt, -1, -1)
ToggleInt.border:SetTexture(jps.GUIborder)

ToggleInt.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
ToggleInt.shadow:SetParent(ToggleInt)
ToggleInt.shadow:SetPoint('TOPRIGHT', ToggleInt.border, 4.5, 4.5) 
ToggleInt.shadow:SetPoint('BOTTOMLEFT', ToggleInt.border, -4.5, -4.5) 
ToggleInt.shadow:SetTexture(jps.GUIshadow)
ToggleInt.shadow:SetVertexColor(0, 0, 0, 0.85)

ToggleInt:SetScript("OnClick", function(self, button)
	jps.gui_toggleInt()
end)

function jps.resize( size )
	size = tonumber(size)
	if size ~= nil then
		jps.IconSize = size
		jpsIcon:SetWidth(jps.IconSize)
		jpsIcon:SetHeight(jps.IconSize)
		ToggleCDs:SetWidth(jps.IconSize)
		ToggleCDs:SetHeight(jps.IconSize)
		ToggleMulti:SetWidth(jps.IconSize)
		ToggleMulti:SetHeight(jps.IconSize)
		ToggleInt:SetWidth(jps.IconSize)
		ToggleInt:SetHeight(jps.IconSize)
		jps.gui_setToggleDir(jps.ButtonGrowthDir)
	end
end

function jps.gui_setToggleDir( dir )
	local paddingA = jps.IconSize + 4
	local paddingB = jps.IconSize * 2 + 8
	local paddingC = jps.IconSize * 3 + 12
	local ButtonGrowthDir
	if dir ~= nil then
		if dir == "right" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, paddingB, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, paddingA, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, paddingC, 0)
			ButtonGrowthDir = "right"
		elseif dir == "left" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, -paddingB, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, -paddingA, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, -paddingC, 0)
			ButtonGrowthDir = "left"
		elseif dir == "up" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, paddingB)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, paddingA)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, paddingC)
			ButtonGrowthDir = "up"
		elseif dir == "down" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingB)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingA)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingC)
			ButtonGrowthDir = "down"
		end
	else 
		dir = jps.ButtonGrowthDir
		if dir == "right" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, paddingB, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, paddingA, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, paddingC, 0)
			ButtonGrowthDir = "down"
		elseif dir == "left" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, -paddingB, 0)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, -paddingA, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, -paddingC, 0)
			ButtonGrowthDir = "up"
		elseif dir == "up" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, paddingB)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, paddingA)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, paddingC)
			ButtonGrowthDir = "right"
		elseif dir == "down" then
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingB)
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingA)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingC)
			ButtonGrowthDir = "left"
		end
	end
	jps.ButtonGrowthDir = ButtonGrowthDir
end

function jps.gui_toggleEnabled( value )
	ToggleMulti:Show()
	ToggleCDs:Show()
	ToggleInt:Show()
	jpsIcon:Show()
	if value ~= nil then
		jps.Enabled = value
		if value == true then
			jpsIcon.border:SetTexture(jps.GUIborder_active)
		else
			jpsIcon.border:SetTexture(jps.GUIborder)
		end
		return
	end
	if jps.Enabled then
		jpsIcon.border:SetTexture(jps.GUIborder)
		write("Disabled.")
	else
		jpsIcon.border:SetTexture(jps.GUIborder_active)
		write("Enabled.")
	end
	jps.Enabled = not jps.Enabled
	return
end

function jps.gui_toggleMulti( value )
	if value ~= nil then
		jps.MultiTarget = value
		if value == true then
			ToggleMulti.border:SetTexture(jps.GUIborder_active)
		else
			ToggleMulti.border:SetTexture(jps.GUIborder)
		end
		return
	end
	if jps.MultiTarget then
		ToggleMulti.border:SetTexture(jps.GUIborder)
		write("Multi-Target Disabled.")
	else
		ToggleMulti.border:SetTexture(jps.GUIborder_active)
		write("Multi-Target Enabled.")
	end
	jps.MultiTarget = not jps.MultiTarget
	return
end

function jps.gui_toggleCDs( value )
	if value ~= nil then
		jps.UseCDs = value
		if value == true then
			ToggleCDs.border:SetTexture(jps.GUIborder_active)
		else
			ToggleCDs.border:SetTexture(jps.GUIborder)
		end
		return
	end
	if jps.UseCDs then
		ToggleCDs.border:SetTexture(jps.GUIborder)
		write ("Cooldown Usage Disabled.")
	else
		ToggleCDs.border:SetTexture(jps.GUIborder_active)
		write ("Cooldown Usage Enabled.")
	end
	jps.UseCDs = not jps.UseCDs
	return
end

function jps.gui_toggleInt( value )
	if value ~= nil then
		jps.Interrupts = value
		if value == true then
			ToggleInt.border:SetTexture(jps.GUIborder_active)
		else
			ToggleInt.border:SetTexture(jps.GUIborder)
		end
		return
	end
	if jps.Interrupts then
		ToggleInt.border:SetTexture(jps.GUIborder)
		write("Interrupts Disabled.")
	else
		ToggleInt.border:SetTexture(jps.GUIborder_active)
		write("Interrupts Enabled.")
	end
	jps.Interrupts = not jps.Interrupts
	return
end

function jps.gui_toggleCombat( status )
	if status == true then
		if not jps.Enabled then
			jpsIcon.border:SetTexture(jps.GUIborder)
		else
			jpsIcon.border:SetTexture(jps.GUIborder_combat)
		end
	else
		if jps.Enabled then
			jpsIcon.border:SetTexture(jps.GUIborder_active)
		else
			jpsIcon.border:SetTexture(jps.GUIborder)
		end
	end
end

function jps.set_jps_icon( spell )
	local icon = GetSpellTexture(spell)
	jpsIcon.texture:SetTexture(icon)
	jps.IconSpell = spell
end

function jps.gui_toggleToggles( value )
	if value ~= nil then
		jps.ExtraButtons = value
		if value == true then
			ToggleMulti:Show()
			ToggleCDs:Show()
			ToggleInt:Show()
		else
			ToggleMulti:Hide()
			ToggleCDs:Hide()
			ToggleInt:Hide()
		end

	else
		jps.ExtraButtons = not jps.ExtraButtons

		if jps.ExtraButtons then
			ToggleMulti:Show()
			ToggleCDs:Show()
			ToggleInt:Show()
		else
			ToggleMulti:Hide()
			ToggleCDs:Hide()
			ToggleInt:Hide()
		end
	end
end



function jps.addRotationDropdown()
    local items = jps.getRotations()
    
    if (count(items) == 1) then return false end

    CreateFrame("Button", "chooseRotationDropdown", jpsIcon, "UIDropDownMenuTemplate")
    chooseRotationDropdown:ClearAllPoints()
    chooseRotationDropdown:SetPoint("LEFT", -18, -40)
    chooseRotationDropdown:Show()
    
    local function OnClick(self, arg1, arg2, checked)
       UIDropDownMenu_SetSelectedID(chooseRotationDropdown, arg1)
       jps.useRotation = arg1
       write("changed Rotation to", arg2)
    end
     
    local function initialize(self, level)
       local info = UIDropDownMenu_CreateInfo()
       for k,v in pairs(items) do
          
          info = UIDropDownMenu_CreateInfo()
          info.text = v["name"]
          info.value = k
          info.arg1 = k
          info.arg2 = v["name"] 
          info.func = OnClick
          UIDropDownMenu_AddButton(info, level)
       end
    end
     
     
    UIDropDownMenu_Initialize(chooseRotationDropdown, initialize)
    UIDropDownMenu_SetWidth(chooseRotationDropdown, 100);
    UIDropDownMenu_SetButtonWidth(chooseRotationDropdown, 124)
    UIDropDownMenu_SetSelectedID(chooseRotationDropdown, 1)
    UIDropDownMenu_JustifyText(chooseRotationDropdown, "LEFT")
    jps.rotationsInitialized = true

end