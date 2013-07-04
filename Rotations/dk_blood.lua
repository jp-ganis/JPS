-- function for checking diseases on target for plague leech, because we need fresh dot time left
function canCastPlagueLeech(timeLeft)  
	if not jps.mydebuff("Frost Fever") or not jps.mydebuff("Blood Plague") then return false end
	if jps.myDebuffDuration("Frost Fever") <= timeLeft then
		return true
	end
	if jps.myDebuffDuration("Blood Plague") <= timeLeft then
		return true
	end
	return false
end
--[[
-- DK Bloodshield Toggle 
bloodshieldAbsorb = 0;
hasBloodshield = false;
bloodshieldMeActive = false;

-- Watch CombatLog for Bloodshild Aura changes
function handleDeathknightBloodschield(elapsed, ...)	 
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
	
	local spellName, spellAbsorb = "", 0

	if eventtype == "SPELL_AURA_APPLIED" and destName == "Sudos" and param10 then
		if param10 then spellName = param10 end
		if param13 then spellAbsorb = param13 end
	
		if param9 == 77535 then
				if spellAbsorb and spellAbsorb ~= "" then
					jps.hasBloodshield = true;
					jps.bloodshieldAbsorb = spellAbsorb;
					if jps.Debug then print("Blood Shield applied.  Value = "..spellAbsorb) end
				end
		end
	end
	
	if eventtype == "SPELL_AURA_REFRESH" and destName == "Sudos" then
		if param10 then spellName = param10 end
		if param13 then spellAbsorb = param13 end
	
		if param9 then
			if param9 == 77535 then
				jps.bloodshieldAbsorb = spellAbsorb;
				if jps.Debug then print("Blood Shield refresh.  New value = "..spellAbsorb) end
				if(jps.hp("player","abs") == spellAbsorb and jps.Debug ) then
					print("got Full Shield, no need to DS until we got dmg / shield duration <= 2");
				end
			end
		end
	end
	
	if eventtype == "SPELL_AURA_REMOVED" and destName == "Sudos" and param10 then
		if param10 then spellName = param10 end
		if param13 then spellAbsorb = param13 end
	
		if param9 == 77535 then
			jps.hasBloodshield = false;
			jps.bloodshieldAbsorb = 0;
			print("Blood Shield removed.  Remaining = "..spellAbsorb)
		end
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

if jps.Spec == "Blood" then
	jps.GUIicon_bs = "Interface\\Icons\\Spell_deathknight_deathstrike"
	if ToggleBS == nil then 
		ToggleBS = CreateFrame("Button", "ToggleBS", jpsIcon)
		addBloodDeathknightButtons()
	end
	jps.registerCombatLogEventUnfiltered("SPELL_AURA_APPLIED", handleDeathknightBloodschield)
	jps.registerCombatLogEventUnfiltered("SPELL_AURA_REFRESH", handleDeathknightBloodschield)
	jps.registerCombatLogEventUnfiltered("SPELL_AURA_REMOVED", handleDeathknightBloodschield)
else
	if ToggleBS ~= nil then
		ToggleBS:hide()
		ToggleBS:SetParent(nil)
		ToggleBS:ClearAllPoints()
		ToggleBS.OnEvent = function() end
	end
	jps.unregisterCombatLogEventUnfiltered("SPELL_AURA_APPLIED", handleDeathknightBloodschield)
	jps.unregisterCombatLogEventUnfiltered("SPELL_AURA_REFRESH", handleDeathknightBloodschield)
	jps.unregisterCombatLogEventUnfiltered("SPELL_AURA_REMOVED", handleDeathknightBloodschield)
end


--	After jps.bloodshieldActive is set to true (button) blood DK starts to build up a bloodshild until your max hp
--	auto refresh it when buff duration < 3 sec
--	GCD and Runes are not wasted until our bloodshild is maxed
--	deff CDs

function bloodshieldMe(spell) 
    local frostFeverDuration = jps.myDebuffDuration("Frost Fever")
    local bloodPlagueDuration = jps.myDebuffDuration("Blood Plague")
    local cooldownDS = jps.cooldown("Death Strike")
    local spellsWithGCD = {"Death and Decay", "Army of the Dead", "Soul Reaper", "Heart Strike","Rune Strike"}
    local bloodChargeStacks = jps.buffStacks("Blood Charge")
    
    if not jps.bloodshieldActive then return spell end -- run normal rotation

    foundBadSpell = false
    for k,v in pairs(spellsWithGCD) do -- check if we dont waste runes and GCD's
        if v == spell then
        	foundBadSpell = true;
        end
    end
    if jps.runicPower >= 30 and cooldownDS > 1.5 and bloodChargeStacks < 5 then   -- use Rune Strike, when our DS CD > GCD & we need blood charge stacks
        spell = "Rune Strike"
        foundBadSpell = false
    end
    if foundBadSpell == false then -- run filtered rotation
    	return spell
    end

    if jps.bloodshieldAbsorb == 0 and cooldownDS == 0 and ImReallySureICanCastThisShit("Death Strike") then return "Death Strike" end --build BS, no more checks needed
    if jps.hp("player","abs") == jps.bloodshieldAbsorb and jps.buffDuration("Blood Shield") > 3 then return spell end -- run normal rotation
    local usable, nomana = IsUsableSpell("Plague Leech")
    if cooldownDS > 2 and  bloodChargeStacks >= 5 then jps.Cast("Blood Tap") end -- try to get runes
    if cooldownDS > 2 and (frostFeverDuration > 0 and bloodPlagueDuration > 0)  then jps.Cast("Plague Leech") end -- try to get runes
    if (jps.buffDuration("Blood Shield") <= 3 or jps.hp("player","abs") > jps.bloodshieldAbsorb ) and ImReallySureICanCastThisShit("Death Strike") then return "Death Strike" end -- build BS
    return nil
end
]]--

function dk_blood()
	-- Talents:
	-- Tier 1: Roiling Blood (for trash / add fights) or Plague Leech for Single Target
	-- Tier 2: Anti-Magic Zone
	-- Tier 3: Death's Advance
	-- Tier 4: Death Pact
	-- Tier 5: Runic Corruption
	-- Tier 6: Remorseless Winter
	-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell
	
	-- Usage info:
	-- Shift to DnD at mouse
	-- left alt for anti magic zone
	-- left ctrl for army of death
	-- shift + left alt for battle rezz at your focus or (if focus is not death , or no focus or focus target out of range) mouseover	

	-- Cooldowns: trinkets, raise dead, dancing rune weapon, synapse springs, lifeblood 

	-- focus on other tank in raids !
	
	local spell = nil
	local target = nil
	
	local rp = jps.runicPower();
	local ffDuration = jps.myDebuffDuration("frost fever")
	local bpDuration = jps.myDebuffDuration("blood plague")
	local bcStacks = jps.buffStacks("blood charge") --Blood Stacks
	local haveGhoul, _, _, _, _ = GetTotemInfo(1) --Information about Ghoul pet
	
	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local ur1 = select(3,GetRuneCooldown(3))
	local ur2 = select(3,GetRuneCooldown(4))
	local fr1 = select(3,GetRuneCooldown(5))
	local fr2 = select(3,GetRuneCooldown(6))
	local one_dr = dr1 or dr2
	local two_dr = dr1 and dr2
	local one_fr = fr1 or fr2
	local two_fr = fr1 and fr2
	local one_ur = ur1 or ur2
	local two_ur = ur1 and ur2

	local spellTable = {}
	
	spellTable[1] = {
		["ToolTip"] = "DK Blood Main",			
		
		-- Blood presence
		{ "Blood Presence",			 not jps.buff("Blood Presence") },
		
    	-- Battle Rezz
    	{ "Raise Ally",			UnitIsDeadOrGhost("focus") == 1 and UnitPlayerControlled("focus") == true and jps.UseCds and IsLeftAltKeyDown()  ~= nil and GetCurrentKeyBoardFocus() == nil  , "focus" },
    	{ "Raise Ally",			UnitIsDeadOrGhost("mouseover") == 1 and UnitPlayerControlled("mouseover") == true and jps.UseCds and IsLeftAltKeyDown()  ~= nil  and GetCurrentKeyBoardFocus() == nil , "mouseover" },

		-- Shift is pressed
		{ "Death and Decay",			IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and not IsLeftAltKeyDown() },
		{ "Anti-Magic Zone",			IsLeftAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and not IsShiftKeyDown() },
		
		-- Cntrol is pressed
		{ "Army of the Dead",			IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		-- Defensive cooldowns
		{ "Death Pact",			jps.hp() < .5 and haveGhoul },
		{ "Lichborne",			jps.UseCDs and jps.hp() < 0.5 and rp >= 40 and jps.IsSpellKnown("Lichborne") },
		{ "Death Coil",			 		jps.hp() < 0.5 and rp >= 40 and jps.buff("lichborne"), "player" }, 
		{ "Rune Tap",			jps.hp() < .8 },
		{ "Icebound Fortitude",			jps.UseCDs and jps.hp() < .3},
		{ "Vampiric Blood",			jps.UseCDs and jps.hp() < .4 },
		
		-- Interrupts
		{ "Mind Freeze",			jps.shouldKick() and jps.LastCast ~= "Strangulate" and jps.LastCast ~= "Asphyxiate" },
		{ "Strangulate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Asphyxiate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		
		-- Aggro cooldowns
		-- { "Dark Command",			 --	targetThreatStatus ~= 3 and not jps.targetTargetTank() },
		{ "Raise Dead",			jps.UseCDs and UnitExists("pet") == nil },
		{ "Dancing Rune Weapon",			jps.UseCDs },
		
		-- Requires engineering
		{ jps.useSynapseSprings(),		jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood",			jps.UseCDs },
		
		-- Racials
    	{ jps.DPSRacial, 		jps.UseCDs },
		
		-- Buff
		{ "Bone Shield",			not jps.buff("Bone Shield") },
				
		-- Diseases
		{ "Outbreak",			ffDuration <= 2 or bpDuration <= 2 },
		{ "Plague Strike",			not jps.mydebuff("Blood Plague") },
		{ "Icy Touch",			not jps.mydebuff("Frost Fever") },
		
		{ "Plague Leech",			canCastPlagueLeech(3)},
		
		{ "Soul Reaper",			jps.hp("target") <= .35 },

		-- Multi target
		{ "Blood Boil",			jps.MultiTarget or jps.buff("Crimson Scourge")},
		
		-- Rotation
		{ "Death Strike",			 	jps.hp() < .7 or jps.buffDuration("Blood Shield") < 3 },
		{ "Rune Strike",			rp >= 80 and not two_fr and not two_ur },
		{ "Death Strike" },

		-- Death Siphon when we need a bit of healing. (talent based)
		{ "Death Siphon",			jps.hp() < .6 }, -- moved here, because we heal often more with Death Strike than Death Siphon

		{ "Heart Strike",			jps.mydebuff("Blood Plague") and jps.mydebuff("Frost Fever") },
		
		{ "Rune Strike",			rp >= 40 and jps.hp() > 0.5 and not jps.buff("lichborne") }, -- stop casting Rune Strike if Lichborne is up
		
		{ "Horn of Winter" },
		
		{ "Empower Rune Weapon",			not two_dr and not two_fr and not two_ur },
	}
	
	spellTable[2] = {
		["ToolTip"] = "DK Diseases",			

		-- Kicks
		{ "mind freeze",			jps.shouldKick() },
		{ "mind freeze",			jps.shouldKick("focus"), "focus" },
		{ "Strangulate",			jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze",			"target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",			jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze",			"focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate",			 "focus" },

		-- Buffs
		{ "blood presence",			 not jps.buff("blood presence") },
		{ "horn of winter",			 "onCD" },
		{ "Outbreak",			 ffDuration < 2 or bpDuration < 2 },
		{ "Unholy Blight",			 ffDuration < 2 or bpDuration < 2 },
		
		-- Diseases
		{ "Plague Strike",			not jps.mydebuff("Blood Plague") },
		{ "Icy Touch",			not jps.mydebuff("Frost Fever") },
		
	}

	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)

	return spell,target
end