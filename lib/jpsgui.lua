-- Huge thanks to BenPhelps for these SO sexy buttons.
jps.GUInormal = "Interface\\AddOns\\JPS\\Media\\basquiat.tga"
jps.GUIpvp = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp"
jps.GUInoplua = "Interface\\Icons\\Spell_Totem_WardOfDraining"
jps.GUIshadow = "Interface\\AddOns\\JPS\\Media\\shadow.tga"
jps.GUIborder = "Interface\\AddOns\\JPS\\Media\\border.tga"
jps.GUIborder_active = "Interface\\AddOns\\JPS\\Media\\border_on.tga"
jps.GUIborder_combat = "Interface\\AddOns\\JPS\\Media\\border_combat.tga"
jps.GUIicon_cd = "Interface\\Icons\\Spell_Holy_BorrowedTime"
jps.GUIicon_multi = "Interface\\Icons\\achievement_arena_5v5_3"
jps.GUIicon_int = "Interface\\Icons\\INV_Shield_05"
jps.GUIicon_def = "Interface\\Icons\\Spell_Misc_EmotionHappy"
jps.GUIicon_rot = "Interface\\Icons\\Spell_Shadow_Shadowfiend"
jps.IconSize = 36
jps.ButtonGrowthDir = "right"

BINDING_HEADER_JPS = "JPS Toggles"
BINDING_NAME_JPSTOGGLE = "Enabled/Disable"
BINDING_NAME_JPSTOGGLEMULTI = "Multi Target"
BINDING_NAME_JPSTOGGLECD = "CD Usage"
BINDING_NAME_JPSTOGGLEINT = "Int Usage"
-- Create the frame that does all the work

JPSFrame = CreateFrame("Frame", "JPSFrame")
JPSFrame:SetScript("OnUpdate", function(self, elapsed)
	if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
    if (self.TimeSinceLastUpdate > jps.UpdateInterval) then
      	if jps.Combat and jps.Enabled then
         	jps_Combat() 
         	self.TimeSinceLastUpdate = 0
      	end
   	end
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
		if IsControlKeyDown() then
			InterfaceOptionsFrame_OpenToCategory(jpsConfigFrame)
		elseif IsShiftKeyDown() then
			jps.gui_setToggleDir()
		else
			jps.gui_toggleToggles()
		end
	end
end)

------------------ TOOLTIP ---------------------------
jpsIcon:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	local text = ""
	if jps.Enabled then text = "JPS ENABLE" else text = "JPS DISABLE" end
	GameTooltip:SetText(text.." for your|cffa335ee "..jps.Class.." "..jps.Spec)
	GameTooltip:AddLine("jps.Rotation["..jps.Count.."]" , 1, 1, 1)
	GameTooltip:AddLine("|cffff8000"..jps.Tooltip , 1, 1, 1)
	GameTooltip:Show()
end)
jpsIcon:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

------------------------------------------------------
--------------- ToggleCDs ----------------------------
------------------------------------------------------

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

------------------ TOOLTIP ---------------------------
ToggleCDs:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText("jps.UseCDs")
	GameTooltip:Show()
end)
ToggleCDs:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

------------------------------------------------------
--------------- ToggleMulti --------------------------
------------------------------------------------------

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

------------------ TOOLTIP ---------------------------
ToggleMulti:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText("jps.MultiTarget")
	GameTooltip:Show()
end)
ToggleMulti:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

------------------------------------------------------
--------------- ToggleInt ----------------------------
------------------------------------------------------

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

------------------ TOOLTIP ---------------------------
ToggleInt:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText("jps.Interrupts")
	GameTooltip:Show()
end)
ToggleInt:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

------------------------------------------------------
--------------- ToggleDef ----------------------------
------------------------------------------------------

ToggleDef = CreateFrame("Button", "ToggleDef", jpsIcon)
ToggleDef:RegisterForClicks("LeftButtonUp")
ToggleDef:SetPoint("TOPRIGHT", jpsIcon, 40, 0)
ToggleDef:SetHeight(36)
ToggleDef:SetWidth(36)
ToggleDef.texture = ToggleDef:CreateTexture()
ToggleDef.texture:SetPoint('TOPRIGHT', ToggleDef, -3, -3)
ToggleDef.texture:SetPoint('BOTTOMLEFT', ToggleDef, 3, 3)
ToggleDef.texture:SetTexture(jps.GUIicon_def)
ToggleDef.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
ToggleDef.border = ToggleDef:CreateTexture(nil, "OVERLAY")
ToggleDef.border:SetParent(ToggleDef)
ToggleDef.border:SetPoint('TOPRIGHT', ToggleDef, 1, 1)
ToggleDef.border:SetPoint('BOTTOMLEFT', ToggleDef, -1, -1)
ToggleDef.border:SetTexture(jps.GUIborder_active)

ToggleDef.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
ToggleDef.shadow:SetParent(ToggleDef)
ToggleDef.shadow:SetPoint('TOPRIGHT', ToggleDef.border, 4.5, 4.5) 
ToggleDef.shadow:SetPoint('BOTTOMLEFT', ToggleDef.border, -4.5, -4.5) 
ToggleDef.shadow:SetTexture(jps.GUIshadow)
ToggleDef.shadow:SetVertexColor(0, 0, 0, 0.85)

ToggleDef:SetScript("OnClick", function(self, button)
	jps.gui_toggleDef()
end)

------------------ TOOLTIP ---------------------------
ToggleDef:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:SetText("jps.Defensive")
	GameTooltip:Show()
end)
ToggleDef:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

------------------------------------------------------
--------------- ToggleRot ----------------------------
------------------------------------------------------

ToggleRot = CreateFrame("Button", "ToggleRot", jpsIcon)
ToggleRot:RegisterForClicks("LeftButtonUp","RightButtonUp")
ToggleRot:SetPoint("TOPRIGHT", jpsIcon, 40, 0)
ToggleRot:SetHeight(36)
ToggleRot:SetWidth(36)
ToggleRot.texture = ToggleRot:CreateTexture()
ToggleRot.texture:SetPoint('TOPRIGHT', ToggleRot, -3, -3)
ToggleRot.texture:SetPoint('BOTTOMLEFT', ToggleRot, 3, 3)
ToggleRot.texture:SetTexture(jps.GUIicon_rot)
ToggleRot.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
ToggleRot.border = ToggleRot:CreateTexture(nil, "OVERLAY")
ToggleRot.border:SetParent(ToggleRot)
ToggleRot.border:SetPoint('TOPRIGHT', ToggleRot, 1, 1)
ToggleRot.border:SetPoint('BOTTOMLEFT', ToggleRot, -1, -1)
ToggleRot.border:SetTexture(jps.GUIborder_active)

ToggleRot.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
ToggleRot.shadow:SetParent(ToggleRot)
ToggleRot.shadow:SetPoint('TOPRIGHT', ToggleRot.border, 4.5, 4.5) 
ToggleRot.shadow:SetPoint('BOTTOMLEFT', ToggleRot.border, -4.5, -4.5) 
ToggleRot.shadow:SetTexture(jps.GUIshadow)
ToggleRot.shadow:SetVertexColor(0, 0, 0, 0.85)

-- FUNCTION TO TOGGLE A FRAME
--local countToggle = 0
--ToggleRot:SetScript("OnClick",function(self, button)
--	if countToggle > 1 then countToggle = 0 end
--	countToggle = countToggle + 1 
--	if countToggle == 1 then
--		DropDownMenuRotation:Show()
--	else
--		DropDownMenuRotation:Hide()
--	end
--end)

ToggleRot:SetScript("OnClick", function(self, button)
	jps.gui_toggleRot()
end)

------------------ TOOLTIP ---------------------------
ToggleRot:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	local text = ""
	if jps.FaceTarget then text = "ENABLE" else text = "DISABLE" end
	GameTooltip:SetText("jps.FaceTarget")
	GameTooltip:AddLine( text , 1, 1, 1)
	GameTooltip:Show()
end)
ToggleRot:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

------------------------------------------------------
--------------- Functions ----------------------------
------------------------------------------------------

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
		ToggleDef:SetWidth(jps.IconSize)
		ToggleDef:SetHeight(jps.IconSize)
		ToggleRot:SetWidth(jps.IconSize)
		ToggleRot:SetHeight(jps.IconSize)
		jps.gui_setToggleDir(jps.ButtonGrowthDir)
	end
end

function jps.gui_setToggleDir( dir )
	local paddingA = jps.IconSize + 4
	local paddingB = jps.IconSize * 2 + 8
	local paddingC = jps.IconSize * 3 + 12
	local paddingD = jps.IconSize * 4 + 16
	local paddingE = jps.IconSize * 5 + 20
	local ButtonGrowthDir
	if dir ~= nil then
		if dir == "right" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, paddingA, 0)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, paddingB, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, paddingC, 0)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, paddingD, 0)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, paddingE, 0)
			ButtonGrowthDir = "right"
		elseif dir == "left" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, -paddingA, 0)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, -paddingB, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, -paddingC, 0)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, -paddingD, 0)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, -paddingE, 0)
			ButtonGrowthDir = "left"
		elseif dir == "up" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, paddingA)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, paddingB)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, paddingC)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, 0, paddingD)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, 0, paddingE)
			ButtonGrowthDir = "up"
		elseif dir == "down" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingA)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingB)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingC)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingD)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingE)
			ButtonGrowthDir = "down"
		end
	else 
		dir = jps.ButtonGrowthDir
		if dir == "right" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, paddingA, 0)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, paddingB, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, paddingC, 0)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, paddingD, 0)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, paddingE, 0)
			ButtonGrowthDir = "down"
		elseif dir == "left" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, -paddingA, 0)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, -paddingB, 0)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, -paddingC, 0)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, -paddingD, 0)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, -paddingE, 0)
			ButtonGrowthDir = "up"
		elseif dir == "up" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, paddingA)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, paddingB)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, paddingC)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, 0, paddingD)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, 0, paddingE)
			ButtonGrowthDir = "right"
		elseif dir == "down" then
			ToggleCDs:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingA)
			ToggleMulti:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingB)
			ToggleInt:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingC)
			ToggleDef:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingD)
			ToggleRot:SetPoint("TOPRIGHT", jpsIcon, 0, -paddingE)
			ButtonGrowthDir = "left"
		end
	end
	jps.ButtonGrowthDir = ButtonGrowthDir
end

function jps.gui_toggleEnabled( value )
	ToggleCDs:Show()
	ToggleMulti:Show()
	ToggleInt:Show()
	ToggleDef:Show()
	ToggleRot:Show()
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
		write ("Cooldown Disabled.")
	else
		ToggleCDs.border:SetTexture(jps.GUIborder_active)
		write ("Cooldown Enabled.")
	end
	jps.UseCDs = not jps.UseCDs
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
		write("MultiTarget Disabled.")
	else
		ToggleMulti.border:SetTexture(jps.GUIborder_active)
		write("MultiTarget Enabled.")
	end
	jps.MultiTarget = not jps.MultiTarget
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

function jps.gui_toggleDef( value )
	if value ~= nil then
		jps.Defensive = value
		if value == true then
			ToggleDef.border:SetTexture(jps.GUIborder_active)
		else
			ToggleDef.border:SetTexture(jps.GUIborder)
		end
		return
	end
	if jps.Defensive then
		ToggleDef.border:SetTexture(jps.GUIborder)
		write ("Defensive Disabled.")
	else
		ToggleDef.border:SetTexture(jps.GUIborder_active)
		write ("Defensive Enabled.")
	end
	jps.Defensive = not jps.Defensive
	return
end

function jps.gui_toggleRot( value )
	if value ~= nil then
		jps.FaceTarget = value
		if value == true then
			ToggleRot.border:SetTexture(jps.GUIborder_active)
		else
			ToggleRot.border:SetTexture(jps.GUIborder)
		end
		return
	end
	if jps.FaceTarget then
		ToggleRot.border:SetTexture(jps.GUIborder)
		write ("FaceTarget Disabled.")
	else
		ToggleRot.border:SetTexture(jps.GUIborder_active)
		write ("FaceTarget Enabled.")
	end
	jps.FaceTarget = not jps.FaceTarget
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

function jps.gui_toggleToggles( value )
	if value ~= nil then
		jps.ExtraButtons = value
		if value == true then
			ToggleMulti:Show()
			ToggleCDs:Show()
			ToggleInt:Show()
			ToggleDef:Show()
			ToggleRot:Show()
		else
			ToggleMulti:Hide()
			ToggleCDs:Hide()
			ToggleInt:Hide()
			ToggleDef:Hide()
			ToggleRot:Hide()
		end

	else
		jps.ExtraButtons = not jps.ExtraButtons

		if jps.ExtraButtons then
			ToggleMulti:Show()
			ToggleCDs:Show()
			ToggleInt:Show()
			ToggleDef:Show()
			ToggleRot:Show()
		else
			ToggleMulti:Hide()
			ToggleCDs:Hide()
			ToggleInt:Hide()
			ToggleDef:Hide()
			ToggleRot:Hide()
		end
	end
end

---------------------------
-- TOGGLE PVP
---------------------------

function jps.togglePvP( value )
	if value == nil then jps.PvP = not jps.PvP
	else jps.PvP = value end

	if jps.PvP then jpsIcon.texture:SetTexture(jps.GUIpvp)
	else jpsIcon.texture:SetTexture(jps.GUInormal) end
end

---------------------------
-- ICON
---------------------------

function jps.set_jps_icon( spell )
	local icon = GetSpellTexture(spell)
	jpsIcon.texture:SetTexture(icon)
	jps.IconSpell = spell
end
