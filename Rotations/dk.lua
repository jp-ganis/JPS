	dk = {}

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
		if UnitExists("pet") == nil then return false end
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

	-- Bloodshield Toggle
	ToggleBS = nil
	jps.bloodshieldAbsorb = 0;
	jps.hasBloodshield = false;
	bsDataAdded = false;
	jps.bloodshieldActive = false
	-- Watch CombatLog for Bloodshild Aura changes
	function handleDeathknightBloodschield(...)
		if jps.Spec == "Blood" and jps.bloodshieldActive then
			local  timestamp, eventtype, hideCaster, 
				srcGUID, srcName, srcFlags, srcRaidFlags, 
				destGUID, destName, destFlags, destRaidFlags, 
				param9, param10, param11, param12, param13, param14, 
				param15, param16, param17, param18, param19, param20
			timestamp, eventtype, hideCaster, 
			srcGUID, srcName, srcFlags, srcRaidFlags,
			destGUID, destName, destFlags, destRaidFlags,
			param9, param10, param11, param12, param13, param14, 
			param15, param16, param17, param18, param19, param20 = ...
			
			if  not eventtype or not destName then return end
			if param10 then spellName = param10 end
			if param13 then spellAbsorb = param13 end
			local spellName, spellAbsorb = "", 0
			if param9 ~= nil then
				if param9 == 77535 then
					if eventtype == "SPELL_AURA_APPLIED" and destName == "Sudos" and param10 then
						if spellAbsorb and spellAbsorb ~= "" then
							jps.hasBloodshield = true;
							jps.bloodshieldAbsorb = spellAbsorb;
							if jps.Debug then print("Blood Shield applied.  Value = "..spellAbsorb) end
						end
					end
					
					if eventtype == "SPELL_AURA_REFRESH" and destName == "Sudos" then
						jps.bloodshieldAbsorb = spellAbsorb;
						if jps.Debug then print("Blood Shield refresh.  New value = "..spellAbsorb) end
						if(jps.hp("player","abs") == spellAbsorb and jps.Debug ) then
							print("got Full Shield, no need to DS until we got dmg / shield duration <= 2");
						end
					end
					if eventtype == "SPELL_AURA_REMOVED" and destName == "Sudos" and param10 then
						jps.hasBloodshield = false;
						jps.bloodshieldAbsorb = 0;
						write("Blood Shield removed!")
					end
				end
			end
		end
	end
		
	function removeBloodDeathknightButtons()
		if ToggleBS ~= nil then
			ToggleBS:Hide()
		end
	end
	function addBloodDeathknightButtons()
		ToggleBS:RegisterForClicks("LeftButtonUp")
		ToggleBS:SetPoint("TOPLEFT", jpsIcon, 0, 42)
		ToggleBS:SetHeight(36)
		ToggleBS:SetWidth(36)
		ToggleBS.texture = ToggleBS:CreateTexture()
		ToggleBS.texture:SetPoint('TOPRIGHT', ToggleBS, -3, -3)
		ToggleBS.texture:SetPoint('BOTTOMLEFT', ToggleBS, 3, 3)
		ToggleBS.texture:SetTexture(jps.GUIicon_bs)
		ToggleBS.texture:SetTexCoord(0.07, 0.92, 0.07, 0.93)
		ToggleBS.border = ToggleBS:CreateTexture(nil, "OVERLAY")
		ToggleBS.border:SetParent(ToggleBS)
		ToggleBS.border:SetPoint('TOPRIGHT', ToggleBS, 1, 1)
		ToggleBS.border:SetPoint('BOTTOMLEFT', ToggleBS, -1, -1)
		ToggleBS.border:SetTexture(jps.GUIborder)
		ToggleBS.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
		ToggleBS.shadow:SetParent(ToggleBS)
		ToggleBS.shadow:SetPoint('TOPRIGHT', ToggleBS.border, 4.5, 4.5) 
		ToggleBS.shadow:SetPoint('BOTTOMLEFT', ToggleBS.border, -4.5, -4.5) 
		ToggleBS.shadow:SetTexture(jps.GUIshadow)
		ToggleBS.shadow:SetVertexColor(0, 0, 0, 0.85)  
		ToggleBS:SetScript("OnClick", function(self, button)
			jps.gui_ToggleBS()
		end)
		ToggleBS:Show()
	end
	function jps.gui_ToggleBS( value )
		if value ~= nil then
			jps.bloodshieldActive = value
			if value == true then
				ToggleBS.border:SetTexture(jps.GUIborder_active)
			else
				ToggleBS.border:SetTexture(jps.GUIborder)
			end
			return
		end
		if jps.bloodshieldActive then
			ToggleBS.border:SetTexture(jps.GUIborder)
			write ("Bloodshield Disabled.")
		else
			ToggleBS.border:SetTexture(jps.GUIborder_active)
			write ("Bloodshield Enabled.")
		end
		jps.bloodshieldActive = not jps.bloodshieldActive
		return
	end
	
	
	--	After jps.bloodshieldActive is set to true (button) blood DK starts to build up a bloodshild until your max hp
	--	auto refresh it when buff duration < 3 sec
	--	GCD and Runes are not wasted until our bloodshild is maxed
	--	deff CDs
	dk.spellsWithGCD = {"Death and Decay","Blood Boil","Scourge Strike", "Army of the Dead", "Soul Reaper", "Heart Strike","Rune Strike"}
	function dk.bloodshieldMe(spell) 
		local frostFeverDuration = jps.myDebuffDuration("Frost Fever")
		local bloodPlagueDuration = jps.myDebuffDuration("Blood Plague")
		local cooldownDS = jps.cooldown("Death Strike")
		local bloodChargeStacks = jps.buffStacks("Blood Charge")
		local shouldBloodTap = false
		if bloodChargeStacks < 5 and jps.IsSpellKnown("Blood Tap") then
			shouldBloodTap = true
		end 
		if not jps.bloodshieldActive then return spell end -- run normal rotation
	
		local foundBadSpell = false
		local stopLoop = false
		local useRuneStrike = false
		if spell ~= nil then
			for k,v in pairs(dk.spellsWithGCD) do -- check if we dont waste runes and GCD's
				if v == spell and stopLoop == false then
					if spell == "Rune Strike" and jps.buffDuration("Blood Shield") > 4 and shouldBloodTap then
						foundBadSpell = false
						stopLoop = true
					else
						foundBadSpell = true
					end
				end
			end
		end
		if jps.bloodshieldAbsorb == 0 and cooldownDS == 0 and jps.canCast("Death Strike","target") then return "Death Strike" end --build BS, no more checks needed
		if jps.runicPower() > 40 and jps.buffDuration("Blood Shield") > 4 and cooldownDS < 4 and jps.canCast("Rune Strike", "target") then
			return "Rune Strike"
		end
		if foundBadSpell == false then -- run filtered rotation
			return spell
		end
		if jps.hp("player","abs") == jps.bloodshieldAbsorb and jps.buffDuration("Blood Shield") >= 4  then return spell end -- run normal rotation if shield is maxed
		if cooldownDS > 2 and  bloodChargeStacks >= 5 then jps.Cast("Blood Tap") end -- try to get runes
		if cooldownDS > 2 and jps.IsSpellKnown("Plague Leech") and (frostFeverDuration > 1 and bloodPlagueDuration > 1)  then jps.Cast("Plague Leech") end -- try to get runes
		if (jps.buffDuration("Blood Shield") <= 4 or jps.hp("player","abs") > jps.bloodshieldAbsorb ) and jps.canCast("Death Strike","target") then return "Death Strike" end -- build BS
		return nil
	end
	
	jps.registerEvent("INSPECT_READY", function()
		if jps.Spec == "Blood" then
			if not bsDataAdded then
				bsDataAdded = true	
				jps.GUIicon_bs = "Interface\\Icons\\Spell_deathknight_deathstrike"
				if ToggleBS == nil then 
					ToggleBS = CreateFrame("Button", "ToggleBS", jpsIcon)
				end
				addBloodDeathknightButtons()
			end
		end
	end)
	jps.registerEvent("COMBAT_LOG_EVENT_UNFILTERED",  handleDeathknightBloodschield)
	
	jps.registerEvent("ACTIVE_TALENT_GROUP_CHANGED", function(...) 
		if jps.Spec ~= "Blood" then
			removeBloodDeathknightButtons()
		else
			if not bsDataAdded then
				bsDataAdded = true
				jps.GUIicon_bs = "Interface\\Icons\\Spell_deathknight_deathstrike"
				if ToggleBS == nil then 
					ToggleBS = CreateFrame("Button", "ToggleBS", jpsIcon)
				end
				addBloodDeathknightButtons()
			end
			ToggleBS:Show()
		end
	end)