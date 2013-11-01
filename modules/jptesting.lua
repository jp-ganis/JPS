--[[
|cffe5cc80 = beige (artifact)
|cffff8000 = orange (legendary)
|cffa335ee = purple (epic)
|cff0070dd = blue (rare)
|cff1eff00 = green (uncommon)
|cffffffff = white (normal)
|cff9d9d9d = gray (crappy)
|cFFFFff00 = yellow
|cFFFF0000 = red
]]

-----------------------
-- FUNCTION TEST 
-----------------------



-- adds / removes a btn to the jps icon
function newButtonToJPSFrame(name, posX, posY, onClick, icon)
	GUIicon_btn = icon
	btn = CreateFrame("Button", name, jpsIcon)
	btn:RegisterForClicks("LeftButtonUp")
	btn:SetPoint("TOPLEFT", jpsIcon, posX, posY)
	btn:SetHeight(36)
	btn:SetWidth(36)
	btn.texture = btn:CreateTexture()
	btn.texture:SetPoint('TOPRIGHT', btn, -3, -3)
	btn.texture:SetPoint('BOTTOMLEFT', btn, 3, 3)
	btn.texture:SetTexture(GUIicon_btn)
	btn.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
	btn.border = ToggleBS:CreateTexture(nil, "OVERLAY")
	btn.border:SetParent(ToggleBS)
	btn.border:SetPoint('TOPRIGHT', btn, 1, 1)
	btn.border:SetPoint('BOTTOMLEFT', btn, -1, -1)
	btn.border:SetTexture(jps.GUIborder)
	btn.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
	btn.shadow:SetParent(ToggleBS)
	btn.shadow:SetPoint('TOPRIGHT', btn.border, 4.5, 4.5) 
	btn.shadow:SetPoint('BOTTOMLEFT', btn.border, -4.5, -4.5) 
	btn.shadow:SetTexture(jps.GUIshadow)
	btn.shadow:SetVertexColor(0, 0, 0, 0.85)  
	btn:SetScript("OnClick", onClick)
	btn:Show()
	return btn
end
function removeJPSButton(name)
	if name ~= nil then
		name:Hide()
	end
enda