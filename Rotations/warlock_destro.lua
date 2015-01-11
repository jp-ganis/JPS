
	
function unitNotGarroshMCed(unit)
	if UnitExists(unit) then
		if UnitDebuff(unit,GetSpellInfo(145832))
		or UnitDebuff(unit,GetSpellInfo(145171))
		or UnitDebuff(unit,GetSpellInfo(145065))
		or UnitDebuff(unit,GetSpellInfo(145071))
		then return false else return true end
	end
	return true
end

function isShadowBurnUnit(unit)
	if jps.hp(unit) > 0.2 then return false end
	if jps.burningEmbers()  == 0 then return false end
	if jps.buffStacks(wl.spells.havoc) > 0 then return true end
	unitHP = jps.hpTotal(unit)
	members = GetNumGroupMembers() or 1
	if unitHP > (members*0.8)*70000 then return false end
	return true
end

function isHavocUnit(unit) 
	if not UnitExists(unit) then  return false end
	if UnitIsUnit("target",unit) then return false end
	return true
end
wl.extraButtons = {}

function addUIButton(name, posX, posY, icon)
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
	btn.border = btn:CreateTexture(nil, "OVERLAY")
	btn.border:SetParent(btn)
	btn.border:SetPoint('TOPRIGHT', btn, 1, 1)
	btn.border:SetPoint('BOTTOMLEFT', btn, -1, -1)
	btn.border:SetTexture(jps.GUIborder)
	btn.shadow = jpsIcon:CreateTexture(nil, "BACKGROUND")
	btn.shadow:SetParent(btn)
	btn.shadow:SetPoint('TOPRIGHT', btn.border, 4.5, 4.5)
	btn.shadow:SetPoint('BOTTOMLEFT', btn.border, -4.5, -4.5)
	btn.shadow:SetTexture(jps.GUIshadow)
	btn.shadow:SetVertexColor(0, 0, 0, 0.85)
	wl.extraButtons[name] = false
	btn:SetScript("OnClick", function( self , value)
		if wl.extraButtons[name] == true then
			self.border:SetTexture(jps.GUIborder)
			wl.extraButtons[name] = false;
		else
			wl.extraButtons[name] = true;
			self.border:SetTexture(jps.GUIborder_active)
		end
end)
	btn:Show()
	return btn
end
function removeUIButton(name)
	if name ~= nil then
		name:Hide()
	end
end
function wl.btn(name) return wl.extraButtons[name] or false end


local spellTable = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),

	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{jps.useBagItem(5512), 'jps.hp("player") < 0.99 and jps.debuff("weak ancient barrier")' }, --malk barrier
	{jps.useBagItem(5512), 'jps.hp("player") < 0.99 and jps.debuff("ancient barrier")' }, --malk barrier
	{jps.useBagItem(86569), 'not jps.buff("Flask of the Warm Sun") and not jps.buff("Visions of Insanity")'},
	{wl.spells.emberTap, 'jps.Defensive and jps.hp() <= 0.4 and jps.burningEmbers() > 0 ' },
	
	-- Soulstone
	wl.soulStone("target"),

	-- Rain of Fire

	{wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1.5 and not GetCurrentKeyBoardFocus() and jps.Moving'	},
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1.5 and not GetCurrentKeyBoardFocus() and jps.MultiTarget'	},
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus() and jps.Moving' },


	{wl.spells.fireAndBrimstone, 'jps.burningEmbers() > 0 and not jps.buff(wl.spells.fireAndBrimstone, "player") and jps.MultiTarget and not jps.isRecast(wl.spells.fireAndBrimstone, "target")' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.emberShards() < 5' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },

	-- On the move
	{wl.spells.shadowburn, 'jps.hp("target") <= 0.19 and jps.burningEmbers() > 0 and jps.Moving'  },

	-- CD's
	{"nested", 'jps.canDPS("target") and not jps.Moving', {
		{ {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and not jps.buff(wl.spells.darkSoulInstability) and jps.UseCDs' },
		{ jps.getDPSRacial(), 'jps.UseCDs' },
		{ wl.spells.lifeblood, 'jps.UseCDs' },
		{ {"macro","/use 13"}, 'jps.useEquipSlot(13) and jps.UseCDs'},
		{ {"macro","/use 14"}, 'jps.useEquipSlot(14) and jps.UseCDs'},
	}},
	


	{"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
		
		{wl.spells.havoc, 'isHavocUnit("mouseover") and not wl.btn("mouseoverGateway") and not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
		{wl.spells.havoc, 'isHavocUnit("focus") and not jps.Moving and jps.emberShards() >= 35  and jps.canDPS("focus") ', "focus"  },
		{wl.spells.havoc, 'isHavocUnit("focus") and not jps.Moving and jps.burningEmbers() > 0 and wl.hasProc(1) and jps.emberShards() >= 15 and jps.canDPS("focus") ', "focus"  },
								
		{wl.spells.shadowburn, 'isShadowBurnUnit("target")'  },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.burningEmbers() > 0 and jps.buffStacks(wl.spells.havoc)>=3'},
		{wl.spells.incinerate, 'jps.buff("backlash")'},
		{"nested", 'not jps.Moving', {
			jps.dotTracker.castTableStatic("immolate"),
		}},

		{wl.spells.conflagrate ,'GetSpellCharges(wl.spells.conflagrate) >= 2' },
		
		{wl.spells.chaosBolt, 'not jps.Moving and jps.buff(wl.spells.darkSoulInstability) and jps.emberShards() >= 19 and jps.hpTotal("target") > 40000' ,"target" },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.TimeToDie("target", 0.2) > 5.0 and jps.burningEmbers() >= 3 and jps.buffStacks(wl.spells.backdraft) < 3 and jps.hpTotal("target") > 40000' ,"target"},
		{wl.spells.chaosBolt, 'not jps.Moving and jps.emberShards() >= 35 and jps.hpTotal("target") > 40000' ,"target"},
		{wl.spells.chaosBolt, 'jps.talentInfo(wl.spells.charredRemains) and not jps.Moving and jps.emberShards() >= 3' ,"target"},
		{wl.spells.chaosBolt, 'not jps.Moving and wl.hasProc(1) and jps.emberShards() >= 10 and jps.buffStacks(wl.spells.backdraft) < 3 and jps.hpTotal("target") > 40000' ,"target"},
		{wl.spells.conflagrate },
		{wl.spells.incinerate },
	}},
	
	{"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.19 and jps.burningEmbers() > 0 '  },
		{wl.spells.conflagrate },
	}},
	
	{"nested", 'jps.MultiTarget', {
		{wl.spells.chaosBolt, 'jps.talentInfo(wl.spells.charredRemains) and jps.burningEmbers() >= 3'},
		--{wl.spells.shadowburn, 'jps.hp("target") <= 0.19 and jps.burningEmbers() > 0 and not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()'  },
		{wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player") and GetSpellCharges(wl.spells.conflagrate) >= 2 ' },
		{wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and jps.LastCast ~= wl.spells.immolate '},
		
		{wl.spells.incinerate },
	}},
}


--[[[
@rotation Destruction 5.4
@class warlock
@spec destruction
@talents Vb!112101!ZbS
@author Kirk24788
@description
This is a Raid-Rotation, which will do fine on normal mobs, even while leveling but might not be optimal for PvP.
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Cast Rain of Fire @ Mouse - [b]ONLY[/b] if RoF Duration is less than 1 seconds[br]
[*] [code]CTRL-SHIFT[/code]: Cast Rain of Fire @ Mouse - ignoring the current RoF duration[br]
[*] [code]ALT-SHIFT[/code]: Cast Shadowfury @ Mouse[br]
[*] [code]CTRL[/code]: If target is dead or ghost cast Soulstone, else cast Havoc @ Mouse[br]
[*] [code]ALT[/code]: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)[br]
[*] [code]jps.Interrupts[/code]: Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)[br]
[*] [code]jps.Defensive[/code]: Create Healthstone if necessary, cast mortal coil and use ember tap[br]
[*] [code]jps.UseCDs[/code]: Use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated![br]
]]--



jps.registerRotation("WARLOCK","DESTRUCTION",function()
	wl.deactivateBurningRushIfNotMoving(1)
	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 and not IsShiftKeyDown() then
		SpellStopCasting()
		jps.NextSpell = nil
	end
	
	if not jps.MultiTarget and jps.IsCasting("player") and (jps.IsCastingSpell("Incinerate","player") or jps.IsCastingSpell("Immolate","player")) and isShadowBurnUnit("target") then
		SpellStopCasting()
		if jps.canCast("Shadowburn","target") then
			jps.Target = "target"
			jps.Cast("Shadowburn")
		end
	end
	
	if not jps.MultiTarget and jps.hp("mouseover") <= 0.2 and jps.burningEmbers() > 0 and unitNotGarroshMCed("mouseover") then
		if jps.canDPS("mouseover") and isShadowBurnUnit("mouseover") then
			return "Shadowburn","mouseover"
		end
	end
	
	if jps.IsSpellKnown(wl.spells.cataclysm) and jps.cooldown(wl.spells.cataclysm) == 0 and IsShiftKeyDown() and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() then
		jps.Cast(wl.spells.cataclysm)
	end --spells out of spelltable are currently necessary when they come from talents :(
	
	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() and  IsShiftKeyDown() == false then
		jps.Cast("Shadowfury")
	end --spells out of spelltable are currently necessary when they come from talents :(


	return parseStaticSpellTable(spellTable)
end,"Destruction 5.3")

-- out of combat rotation
local spellTableOOC = {
	{"Dark Intent",'not jps.buff("Dark Intent")',"player"},
	{"Summon Voidwalker",'not jps.Moving and jps.talentInfo("Grimoire of Sacrifice") and not wl.hasPet() and not jps.buff("Grimoire of Sacrifice") and not jps.isRecast("Summon Voidwalker")',"player"},
	{"Grimoire of Sacrifice",'jps.talentInfo("Grimoire of Sacrifice") and wl.hasPet() and not jps.buff("Grimoire of Sacrifice")',"player"},
}




jps.registerRotation("WARLOCK","DESTRUCTION",function()
	wl.deactivateBurningRushIfNotMoving(1)
	spell,target = parseStaticSpellTable(spellTableOOC)

	return parseStaticSpellTable(spellTableOOC)
end,"Out of Combat",false,false,nil, true)

