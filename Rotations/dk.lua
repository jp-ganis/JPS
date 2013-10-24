	dk = {}
	dk.spells = {}
	dk.spells["frost fever"] = 55078
	dk.spells["blood plague"] = 55095

	function dk.canCastPlagueLeech(timeLeft)  
		if not jps.mydebuff("Frost Fever") or not jps.mydebuff("Blood Plague") then return false end
		if jps.myDebuffDuration("Frost Fever") <= timeLeft then
			return true
		end
		if jps.myDebuffDuration("Blood Plague") <= timeLeft then
			return true
		end
		return false
	end
	
	function dk.updateRunes() 
		dk.dr1 = select(3,GetRuneCooldown(1))
		dk.dr2 = select(3,GetRuneCooldown(2))
		dk.ur1 = select(3,GetRuneCooldown(3))
		dk.ur2 = select(3,GetRuneCooldown(4))
		dk.fr1 = select(3,GetRuneCooldown(5))
		dk.fr2 = select(3,GetRuneCooldown(6))
		dk.oneDr = dk.dr1 or dk.dr2
		dk.twoDr = dk.dr1 and dk.dr2
		dk.oneFr = dk.fr1 or dk.fr2
		dk.twoFr = dk.fr1 and dk.fr2
		dk.oneUr = dk.ur1 or dk.ur2
		dk.twoUr = dk.ur1 and dk.ur2
	end
	
	function dk.hasGhoul()
		if jps.Spec == "Unholy" then
			if UnitExists("pet") == nil then return false end
		else
			if select(1,GetTotemInfo(1)) == false then return false end
		end
		return true
	end
	
	function dk.rune(name)
		dk.updateRunes()
		if dk[name] ~= nil then
			return dk[name]
		end
		print(" there is no rune with the name: "..name)
		return 0
	end
	
	function dk.totalAttackPower()
		local base, pos, neg = UnitAttackPower("player")
		return base + pos + neg
	end

	function dk.shouldRefreshDot(dotName, unit)
		if not unit then unit = "target" end
		local ap = dk.totalAttackPower()
		local crit = GetCritChance()
		local dmgBuff = dk.getDamageBuff()
		local mastery = GetMastery()
		local dotID = nil
		if type(dotName) == "number" then
			dotID = dotName
		else
			dotID = dk.spells[dotName]
		end
		local shouldRefresh = false
		if dk.currentDotStats[dotID] then
			if ap > dk.currentDotStats[dotID].ap then  shouldRefresh = true end
			if crit > dk.currentDotStats[dotID].crit then  shouldRefresh = true end
			if dmgBuff > dk.currentDotStats[dotID].dmgBuff then  shouldRefresh = true end
			if mastery > dk.currentDotStats[dotID].mastery then
				if jps.Spec == "Unholy" and dotID == 55095 then  shouldRefresh = true end
				if jps.Spec == "Frost" and dotID == 55078 then  shouldRefresh = true end
			end
		end
		if shouldRefresh == true then 
			dk.currentDotStats[dotID].isStrong = true
		end
		return shouldRefresh
	end
	
	function dk.shouldExtendDot(dotName, unit)
		if not unit then unit = "target" end
		if not jps.buff(dotName, unit) then return false end -- we can't extend dots which are not available
		if type(dotName) == "number" then
			local spellId = dotName
		else
			local spellId = dk.spells[dotName] or nil
		end
		if not dk.shouldRefreshDot(spellID, unit) and dk.currentDotStats[spellID].isStrong then return true end -- extend current "strong" dot's
		return false
	end

	dk.dmgIncreaseBuffs = {
		{138002, 0.4}, --+40% jin rokh fluidity
		{140741, 1,0.1, "HARMFUL"},-- +100% +10% per stack - ji kun nitrument
		{57934, 0.15}, -- +15% - tricks
		{118977, 0.6},-- +60% - fearless
	}
	function dk.getDamageBuff()
		-- credits to kirk' dotTracker
    	local damageBuff = 1
		for i, buff in ipairs(dk.dmgIncreaseBuffs) do
			local filter = buff[4] or nil
	        hasBuff,_,_,stacks = UnitAura("player", buff[1], nil, filter)
	        if hasBuff then
	            damageBuff = damageBuff + buff[2] + (buff[2] * stacks)
	        end
	    end
	    return damageBuff
	end

	dk.currentDotStats = {}
	function dk.logDotDmg(...)
		local eventtype = select(2, ...)
		local srcName = select(5 , ...)
		local dotDmg = select(15, ...)
		local spellID = select(12, ...)
		local spellName = select(13, ...)
		
		if  not eventtype or srcName ~= "Sudos" then return end
		if spellID ~= dk.spells["frost fever"] and spellID ~= dk.spells["blood plague"] then return end
		if eventtype == "SPELL_AURA_APPLIED" then
			if not dk.currentDotStats[spellID] then dk.currentDotStats[spellID] = {} end
			dk.currentDotStats[spellID].ap = dk.totalAttackPower()
			dk.currentDotStats[spellID].mastery = GetMastery()
			dk.currentDotStats[spellID].crit = GetCritChance() -- since 5.2 also in the dot snapshot
			dk.currentDotStats[spellID].dmgBuff = dk.getDamageBuff()
			dk.currentDotStats[spellID].isStrong = false

		end
		if eventtype == "SPELL_AURA_REMOVED" then
			if dk.currentDotStats[spellID] then
				dk.currentDotStats[spellID].ap = 0
				dk.currentDotStats[spellID].mastery = 0
				dk.currentDotStats[spellID].crit = 0
				dk.currentDotStats[spellID].dmgBuff = 0
				dk.currentDotStats[spellID].isStrong = false
			end
		end
	end
	jps.registerEvent("COMBAT_LOG_EVENT_UNFILTERED", dk.logDotDmg)

	
	function addUIButton(name, posX, posY, onClick, icon)
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
	function removeUIButton(name)
		if name ~= nil then
			name:Hide()
		end
	end
	
