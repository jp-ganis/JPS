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

--------------------------
-- LOCALIZATION
--------------------------

local L = MyLocalizationTable

--------------------------
-- Dispel Functions LOOP
--------------------------

function jps.canDispel( unit, ... )
	for _, dtype in pairs(...) do
		if jps_Dispels[dtype] ~= nil then
			for _, spell in pairs(jps_Dispels[dtype]) do
				if jps.debuff(spell,unit) then return true end
			end
		end
	end
	return false
end

function jps.FindMeDispelTarget(dispeltypes) -- jps.FindMeDispelTarget({"Magic"}, {"Poison"}, {"Disease"})
     for unit, _ in pairs(jps.RaidStatus) do
		if jps.canHeal(unit) and jps.canDispel( unit, dispeltypes ) then return unit end
	end
end

function jps.MagicDispel(unit,debuffunit) -- "Magic" -- "Disease" -- "Poison"
   	if not jps.canHeal(unit) then return false end
   	if debuffunit == nil then debuffunit = "Magic" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	while auraName do
		if debuffType==debuffunit then
		return true end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	end
	return false
end

function jps.DiseaseDispel(unit,debuffunit) -- "Magic" -- "Disease" -- "Poison"
   	if not jps.canHeal(unit) then return false end
   	if debuffunit == nil then debuffunit = "Disease" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	while auraName do
		if debuffType==debuffunit then 
		return true end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	end
	return false
end

function jps.PoisonDispel(unit,debuffunit) -- "Magic" -- "Disease" -- "Poison"
   	if not jps.canHeal(unit) then return false end
   	if debuffunit == nil then debuffunit = "Poison" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	while auraName do
		if debuffType==debuffunit then 
		return true end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	end
	return false
end

function jps.DispelMagicTarget()
	if jps.getConfigVal("Dispel Magic") == 0 then return false end
	for unit,_ in pairs(jps.RaidStatus) do	 
		if jps.canHeal(unit) and jps.MagicDispel(unit) then return unit end
	end
end 

function jps.DispelDiseaseTarget()
if jps.getConfigVal("Dispel Disease") == 0 then return false end
	for unit,_ in pairs(jps.RaidStatus) do	 
		if jps.canHeal(unit) and jps.DiseaseDispel(unit) then return unit end
	end
end 

function jps.DispelPoisonTarget()
if jps.getConfigVal("Dispel Poison") == 0 then return false end
	for unit,_ in pairs(jps.RaidStatus) do	 
		if jps.canHeal(unit) and jps.PoisonDispel(unit) then return unit end
	end
end 


--------------------------
-- Dispel Functions TABLE
--------------------------

-- Don't Dispel if unit is affected by some debuffs
function jps.NoDispelFriendly(unit)
	if not jps.canHeal(unit) then return false end
	local dontDispelDebuff = 
	{	
		30108,131736, 	-- "Unstable Affliction"
		33763,94447, 	-- "Lifebloom"
		34914,124465, 	-- "Vampiric Touch"
	} 							
	for _,debuff in pairs(dontDispelDebuff) do
		if jps.debuff(debuff,unit) then return true end -- Don't dispel if friend is affected by "Unstable Affliction" or "Vampiric Touch" or "Lifebloom"
	end
	return false
end

-- Dispel all debuff in the debuff table EXCEPT if unit is affected by some debuffs
function jps.DispelFriendly(unit)
   if not jps.canHeal(unit) then return false end
   if jps.NoDispelFriendly(unit) then return false end
   for _, debuff in pairs(jps_DebuffToDispel_Name) do
      if jps.debuff(debuff,unit) then
      return true end
   end
   return false
end

function jps.DispelFriendlyTarget()
	for unit,_ in pairs(jps.RaidStatus) do	 
		if jps.canHeal(unit) and jps.DispelFriendly(unit) then 
		return unit end
	end
end

------------------------------------
-- OFFENSIVE Dispel -- STUN DEBUFF
------------------------------------

-- arena1 to arena5 - A member of the opposing team in an Arena match
-- { 528, jps.DispelOffensive(unit) , {"arena1","arena2","arena3"} },  -- Dissipation de la magie 528
function jps.DispelOffensive(unit)
	if not jps.canDPS(unit) then return false end
	for _, buff in pairs(jps_BuffToDispel_Name) do
		if  jps.buff(buff,unit)  then -- and debuffType=="Magic"
		return true end
	end
	return false
end

-- check if unit loosed control
-- unit = http://www.wowwiki.com/UnitId
-- message = type of spell =  "CC" , "Snare" , "Root" , "Silence" , "Immune", "ImmuneSpell", "Disarm" 
function jps.LoseControl(unit,message)
	if not jps.UnitExists(unit) then return false,0 end
	if message == nil then message = "CC" end 
	-- Check debuffs
	local targetControlled = false
	local timeControlled = 0
	for i = 1, 40 do
		local name, _, _, _, _, duration, expTime, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
		if not spellId then break end -- no more debuffs, terminate the loop
		local Priority = jps_SpellControl[spellId]
		if Priority then
			if Priority == message then
				targetControlled = true
				if expTime ~= nil then timeControlled = expTime - GetTime() end
			break end 
		end

	end
	return targetControlled, timeControlled
end

function jps.LoseControlTable(unit,table) -- {"CC", "Snare", "Root", "Silence", "Immune", "ImmuneSpell", "Disarm"}
	if not jps.UnitExists(unit) then return false,0 end
	if table == nil then table = {"CC", "Snare", "Root", "Silence", "Immune", "ImmuneSpell", "Disarm"} end
	-- Check debuffs
	local targetControlled = false
	local timeControlled = 0
	for i = 1, 40 do
		local name, _, _, _, _, duration, expTime, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
		if not spellId then break end -- no more debuffs, terminate the loop
		local Priority = jps_SpellControl[spellId]
		if Priority then
			for k,controltype in ipairs (table) do
				if Priority == controltype then -- "CC" , "Snare" , "Root" , "Silence" , "Immune", "ImmuneSpell", "Disarm"
					targetControlled = true
					if expTime ~= nil then timeControlled = expTime - GetTime() end
				break end
			end
		end
	end
return targetControlled, timeControlled
end

--------------------------------------
-- Loss of Control check (e.g. PvP) --
--------------------------------------
-- API changes http://www.wowinterface.com/forums/showthread.php?t=45176
-- local LossOfControlType, _, LossOfControlText, _, LossOfControlStartTime, LossOfControlTimeRemaining, duration, _, _, _ = C_LossOfControl.GetEventInfo(1)
-- LossOfControlType : --STUN_MECHANIC --STUN --PACIFYSILENCE  --SILENCE --FEAR  --CHARM --PACIFY --CONFUSE  --POSSESS --SCHOOL_INTERRUPT  --DISARM  --ROOT 

function jps.StunEvents() -- ONLY FOR PLAYER
	local locTypeTable = {"STUN_MECHANIC", "STUN", "PACIFYSILENCE", "SILENCE", "FEAR", "CHARM", "PACIFY", "CONFUSE", "ROOT"}
	local numEvents = C_LossOfControl.GetNumEvents()
	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(numEvents)
	if (numEvents > 0) and (timeRemaining ~= nil) then
		if 	locType == SCHOOL_INTERRUPT then
			--print("SPELL_FAILED_INTERRUPTED",locType)
			jps.createTimer("Spell_Interrupt", 2 )
		end
		for i,j in ipairs(locTypeTable) do
			if locType == j and timeRemaining > 1 then
			--print("locType: ",locType,"timeRemaining: ",timeRemaining)
			return true end
		end
	end
	return false
end

--------------------------
-- BUFF DEBUFF
--------------------------
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("unit", index or "name"[, "rank"[, "filter"]])
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff("unit", index or ["name", "rank"][, "filter"]) 
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("unit", index or ["name", "rank"][, "filter"])

function jps.buffId(spellId,unit)
	local spellname = nil
	if type(spellId) == "number" then spellname = tostring(select(1,GetSpellInfo(spellId))) end
	if unit == nil then unit = "player" end
	for i = 1, 40 do
		local auraName, _, _, count, _, duration, expirationTime, castBy, _, _, buffId = UnitBuff(unit, i)
		if spellId == buffId and auraName == spellname then return true end
		if not spellId then break end -- no more auras, terminate the loop 
	end
return false
end

function jps.buff(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	if select(1,UnitBuff(unit,spellname)) then return true end
	return false
end

function jps.debuff(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if select(1,UnitDebuff(unit,spellname)) then return true end
	return false
end

function jps.mydebuff(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if select(1,UnitDebuff(unit,spellname)) and select(8,UnitDebuff(unit,spellname))=="player" then return true end
	return false
end

function jps.myBuffDuration(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_,_ = UnitBuff(unit,spellname)
	if caster ~= "player" then return 0 end
	if duration == nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.myDebuffDuration(spell,unit) 
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spellname)
	if caster~="player" then return 0 end
	if duration==nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.buffDuration(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_,_ = UnitBuff(unit,spellname)
	if duration == nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffDuration(spell,unit) 
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spellname)
	if duration==nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffStacks(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	local _,_,_,count, _,_,_,_,_,_ = UnitDebuff(unit,spellname)
	if count == nil then count = 0 end
	return count
end

function jps.buffStacks(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spellname)
	if count == nil then count = 0 end
	return count
end

function jps.buffTracker(buff)
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.canHeal(unit) and jps.myBuffDuration(buff,unit) > 0 then
		return true end
	end
	return false
end

--------------------------
-- CASTING SPELL
--------------------------

--name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
--name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("unit")

function jps.CastTimeLeft(unit)
	if unit == nil then unit = "player" end
	local _,_,_,_,_,endTime,_,_,_ = UnitCastingInfo(unit)
	if endTime == nil then return 0 end
	return (endTime - (GetTime() * 1000 ) )/1000
end

function jps.ChannelTimeLeft(unit)
	if unit == nil then unit = "player" end
	local _,_,_,_,_,endTime,_,_,_ = UnitChannelInfo(unit)
	if endTime == nil then return 0 end
	return (endTime - (GetTime() * 1000 ) )/1000
end

function jps.IsCasting(unit)
	if unit == nil then unit = "player" end
	local enemyspell = nil
	local enemycasting = false
	local name, _, _, _, startTime, endTime, _, _, interrupt = UnitCastingInfo(unit) -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
	if jps.CastTimeLeft(unit) > 0 then
		enemycasting = true
		enemyspell = name
	elseif (jps.CastTimeLeft(unit) > 0) or (jps.ChannelTimeLeft(unit) > 0) then
		enemycasting = true
	end
	return enemycasting,enemyspell
end

function jps.IsCastingSpell(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	local name, _, _, _, startTime, endTime, _, _, interrupt = UnitCastingInfo(unit) -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
	if spellname == name and jps.CastTimeLeft(unit) > 0 then return true end
	return false
end

function jps.IsCastingPoly(unit)
	if not jps.canDPS(unit) then return false end
	local istargeting = unit.."player"
	local delay = 0
	local Class, _ = UnitClass(unit) -- NOT USEFULL BECAUSE ONLY MAGE & SHAMAN CAST THESES SPELLS
	local tablePoly = 
	{  
		[51514]  = "Hex" ,
		[118]    = "Polymorph" ,
		[61305]  = "Polymorph: Black Cat" ,
		[28272]  = "Polymorph: Pig" ,
		[61721]  = "Polymorph: Rabbit" ,
		[61780]  = "Polymorph: Turkey" ,
		[28271]  = "Polymorph: Turtle" , 
	}

	local spell, _, _, _, startTime, endTime = UnitCastingInfo(unit)
	for spellID,spellname in pairs(tablePoly) do
		if spell == tostring(select(1,GetSpellInfo(spellID))) then
			delay = jps.CastTimeLeft(unit) - jps.Lag
		break end
	end

	if delay < 0 and UnitIsUnit(istargeting, "player")==1 then return true end
	return false
end

--------------------------
-- COOLDOWN
--------------------------

function jps.dispelActive() 
	if not jps.Interrupts then return false end
	return true
end

function jps.shouldKick(unit)
	if not jps.Interrupts then return false end
	if unit == nil then unit = "target" end
    local target_spell, _, _, _, _, _, _, _, unInterruptable = UnitCastingInfo(unit)
	local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
	if target_spell == L["Release Aberrations"] then return false end 

	if target_spell and (unInterruptable == false) then
		return true
	elseif channelling and (notInterruptible == false) then
		return true
	end 
	return false
end

function jps.shouldKickLag(unit)
	if not jps.Interrupts then return false end
	if unit == nil then unit = "target" end
    local target_spell, _, _, _, _, cast_endTime, _, _, unInterruptable = UnitCastingInfo(unit)
	local channelling, _, _, _, _, chanel_endTime, _, notInterruptible = UnitChannelInfo(unit)
	if target_spell == L["Release Aberrations"] then return false end 
	
	if cast_endTime == nil then cast_endTime = 0 end
	if chanel_endTime == nil then chanel_endTime = 0 end

	if target_spell and unInterruptable == false then
		if jps.CastTimeLeft(unit) < 1 then 
		return true end
	elseif channelling and notInterruptible == false then
		if jps.ChannelTimeLeft(unit) < 1 then
		return true end
	end 
	return false
end

function jps.cooldown(spell) -- start, duration, enable = GetSpellCooldown("name") or GetSpellCooldown(id)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if jps.Lag == nil then jps.Lag = 0 end
	local start,duration,_ = GetSpellCooldown(spellname)
	if start == nil then return 0 end
	local cd = start+duration-GetTime() -- jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.glovesCooldown()
	local start, duration, enabled = GetInventoryItemCooldown("player", 10)
	if enabled==0 then return 999 end
	local cd = start+duration-GetTime() -- jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.useBagItem(itemName)
	if type(itemName) == "number" then
		itemName, _  = GetItemInfo(itemName) -- get localized name when ID is passed
	end
	local count = GetItemCount(itemName, false, false)
	if count == 0 then return nil end -- we doesn't have this item in our bag
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag,slot)
			if item and item:find(itemName) then -- item place found
				itemId = GetContainerItemID(bag, slot)  -- get itemID for retrieving item Cooldown
				local start, dur, isNotBlocked = GetItemCooldown(itemId) -- maybe we should use GetContainerItemCooldown() will test it
				local cdDone = Ternary((start + dur ) > GetTime(), false, true)
				local hasNoCD = Ternary(dur == 0, true, false)
				if (cdDone or hasNoCD) and isNotBlocked == 1 then -- cd is done and item is not blocked (like potions infight even if CD is finished)
					return { "macro", "/use "..itemName }
				end
			end
		end
	end
	return nil
end 

-- returns seconds in combat or if out of combat 0
function jps.combatTime()
	return GetTime() - jps.combatStart
end

function jps.bloodlusting()
	return jps.buff("bloodlust") or jps.buff("heroism") or jps.buff("time warp") or jps.buff("ancient hysteria")
end

function jps.targetIsRaidBoss(target) 
	if target == nil then target = "target" end
	local dungeon = jps.raid.getInstanceInfo()
	if inArray(dungeon.difficulty, {"normal10","normal25","hereoic10","heroic25","lfr25", "normal40"}) then		
		if UnitLevel(target) == -1 and UnitPlayerControlled(target) == false then
			return true
		end
	end
	return false
end

function jps.playerInLFR()
	local dungeon = jps.raid.getInstanceInfo()
	if dungeon.difficulty == "lfr25" then return true end
	return false
end

function jps.raid.getInstanceInfo()
    local name, instanceType , difficultyID = GetInstanceInfo()
    local targetName = UnitName("target")
    local diffTable = {}
    diffTable[0] = "none"
    diffTable[1] = "normal5"
    diffTable[2] = "heroic5"
    diffTable[3] = "normal10"
    diffTable[4] = "normal25"
    diffTable[5] = "heroic10"
    diffTable[6] = "heroic25"
    diffTable[7] = "lfr25"
    diffTable[8] = "challenge"
    diffTable[9] = "normal40"
    diffTable[10] = "none"
    diffTable[11] = "normal3"
    diffTable[12] = "heroic3" 
    return {instance = name , enemy = targetName, difficulty = diffTable[difficultyID]}
end

--------------------------
-- TRINKET
--------------------------
-- isUsable, notEnoughMana = IsUsableItem(itemID) or IsUsableItem("itemName")
-- isUsable - 1 if the item is usable; otherwise nil (1nil)
-- notEnoughMana - 1 if the player lacks the resources (e.g. mana, energy, runes) to use the item; otherwise nil (1nil)

function Tooltip_Parse(trinket)
	local id = 13 + trinket
	CreateFrame("GameTooltip", "ScanningTooltip", nil, "GameTooltipTemplate") -- Tooltip name cannot be nil
	ScanningTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" )
	ScanningTooltip:ClearLines()
	ScanningTooltip:SetInventoryItem("player", id)
	-- hasItem, hasCooldown, repairCost = Tooltip:SetInventoryItem("unit", invSlot {, nameOnly})

	local found = 0
	for i=1,select("#",ScanningTooltip:GetRegions()) do 
		local region=select(i,ScanningTooltip:GetRegions())
		if region and region:GetObjectType()=="FontString" and region:GetText() then
			local text =  region:GetText()
			--if text ~=nil then print(text) end
			if string.find(text, L["Use"]) then 
            	found = 1 
			end
		end 
	end
return found
end

function jps.itemCooldown(item) -- start, duration, enable = GetItemCooldown(itemID) or GetItemCooldown("itemName")
	if item == nil then return 999 end
	local start,duration,_ = GetItemCooldown(item) -- GetItemCooldown(ItemID)
	local cd = start+duration-GetTime() -- jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.useSlot(num)
	-- get the Trinket ID
	local trinketId = GetInventoryItemID("player", num)
	if not trinketId then return nil end
	
	-- Check if it's on cooldown
	local trinketCd = jps.itemCooldown(trinketId)
	if trinketCd > 0 then return nil end
	
	 -- Check if it's usable
	local trinketUsable = GetItemSpell(trinketId)
	if not trinketUsable then return nil end
	
	-- Use it
	return { "macro", "/use "..num }
end

-- For trinket's. Pass 0 or 1 for the number.
function jps.useTrinket(trinketNum)
	-- The index actually starts at 0
	local slotName = "Trinket"..(trinketNum).."Slot" -- "Trinket0Slot" "Trinket1Slot"
	
	-- Get the slot ID
	local slotId  = select(1,GetInventorySlotInfo(slotName)) -- "Trinket0Slot" est 13 "Trinket1Slot" est 14

	return jps.useSlot(slotId)
end

-- Engineers will use synapse springs buff on their gloves
function jps.useSynapseSprings()
	-- Get the slot number
	local slotNum = GetInventorySlotInfo("HandsSlot")
	return jps.useSlot(slotNum)
end

------------------------------
-- HEALTH Functions
------------------------------

function jps.hp(unit,message)
	if unit == nil then unit = "player" end
	if message == "abs" then
		return UnitHealthMax(unit) - UnitHealth(unit)
	else
		return UnitHealth(unit) / UnitHealthMax(unit)
	end
end

function jps.hpInc(unit,message)
	if unit == nil then unit = "player" end
	local hpInc = UnitGetIncomingHeals(unit)
	if not hpInc then hpInc = 0 end
	if message == "abs" then
    	return UnitHealthMax(unit) - (UnitHealth(unit) + hpInc)
	else
    	return (UnitHealth(unit) + hpInc)/UnitHealthMax(unit)
    end
end

function jps.rage()
	return UnitPower("player",1)
end

function jps.energy()
	return UnitPower("player",3)
end

function jps.focus()
	return UnitPower("player",2)
end

function jps.runicPower()
	return UnitPower("player",6)
end

function jps.soulShards()
	return UnitPower("player",7)
end

function jps.eclipsePower()
	return UnitPower("player",8)
end

function jps.holyPower()
	return UnitPower("player",9)
end

function jps.shadowOrbs()
	return UnitPower("player",13)
end

function jps.burningEmbers()
	return UnitPower("player",14)
end

function jps.emberShards()
	return UnitPower("player",14, true)
end

function jps.demonicFury()
	return UnitPower("player",15)
end

function jps.mana(unit,message)
	if unit == nil then unit = "player" end
	if message == "abs" or message == "absolute" then
		return UnitMana(unit)
	else
		return UnitMana(unit)/UnitManaMax(unit)
	end
end

----------------------
-- Find TANK
----------------------

function jps.findMeAggroTank()
	local allTanks = jps.findTanksInRaid() 
	local highestThreat = 0
	local aggroTank = "player"
	for possibleTankUnit, _ in pairs(allTanks) do
		local unitThreat = UnitThreatSituation(possibleTankUnit)
		if unitThreat > highestThreat then 
			highestThreat = unitThreat
			aggroTank = possibleTankUnit
		end
	end
	if jps.Debug then write("found Aggro Tank: "..aggroTank) end
	return aggroTank
end

function jps.findMeATank()
	local allTanks = jps.findTanksInRaid() 
	if jps_tableLen(allTanks) == 0 then
		if jps.UnitExists("focus") then return "focus" end
	else
		return allTanks[1] 
	end
	return "player"
end

function jps.findTanksInRaid() 
	local myTanks = {}
	for unitName, _ in pairs(jps.RaidStatus) do
		local foundTank = false
		if UnitGroupRolesAssigned(unitName) == "TANK" then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("bear form",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("blood presence",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("righteous fury",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
	end
	return myTanks
end

function jps.targetTargetTank()
	if jps.buff("bear form","targettarget") then return true end
	if jps.buff("blood presence","targettarget") then return true end
	if jps.buff("righteous fury","targettarget") then return true end
	
	local _,_,_,_,_,_,_,caster,_,_ = UnitDebuff("target","Sunder Armor")
	if caster ~= nil then
		if UnitName("targettarget") == caster then return true end end
	return false
end

------------------------------
-- BenPhelps' Timer Functions
------------------------------

function jps.resetTimer( name )
	jps.Timers[name] = nil
end

function jps.createTimer( name, duration )
	if duration == nil then duration = 60 end -- 1 min
	jps.Timers[name] = duration + GetTime()
end

function jps.checkTimer( name )
	if jps.Timers[name] ~= nil then
		local now = GetTime()
		if jps.Timers[name] < now then
			jps.Timers[name] = nil
			return 0
		else
			return jps.Timers[name] - now
		end
	end
	return 0
end

------------------------------
-- function like C / PHP ternary operator val = (condition) ? true : false
------------------------------

function Ternary(condition, doIt, notDo)
	if condition then return doIt else return notDo end
end

function inArray(needle, haystack)
	if type(haystack) ~= "table" then return false end
	for key, value in pairs(haystack) do 
		local valType = type(value)
		if valType == "string" or valType == "number" or valType == "boolean" then
			if value == needle then 
				return true
			end
		end
	end
	return false
end

------------------------------
-- GLYPHS
------------------------------

-- numTalents = GetNumTalents(inspect)
-- numTalents If true, returns information for the inspected unit. otherwise, returns information for the player character.
-- name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq, previewRank, meetsPreviewPrereq = GetTalentInfo(tabIndex, talentIndex, inspect, pet, talentGroup)

-- isKnown = IsSpellKnown(spellID [, isPet])
-- isKnown - True if the player (or pet) knows the given spell. false otherwise

function jps.talentInfo(talent)
	local talentname = nil
	if type(talent) == "string" then talentname = talent end
	if type(talent) == "number" then talentname = tostring(select(1,GetSpellInfo(talent))) end
	local numTalents = GetNumTalents();
	for t = 1, numTalents do
		local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq, previewRank, meetsPreviewPrereq= GetTalentInfo(t);
		if name == talentname and ( rank ) then return true end
	end
	return false
end

-- numGlyphs = GetNumGlyphs() numGlyphs the number of glyphs THAT THE CHARACTER CAN LEARN
-- name, glyphType, isKnown, icon, glyphId, glyphLink, spec = GetGlyphInfo(index)
-- enabled, glyphType, glyphTooltipIndex, glyphSpellID, icon = GetGlyphSocketInfo(socketID[[, talentGroup], isInspect, inspectUnit])

function jps.glyphInfo(glyphID)
	for i = 1, NUM_GLYPH_SLOTS do
		local enabled, glyphType, glyphTooltipIndex, glyphSpellID, icon = GetGlyphSocketInfo(i)
		if ( enabled ) then
			local link = GetGlyphLink(i) -- Retrieves the Glyph's link ("" if no glyph in Socket)
			if ( link ~= "") and glyphSpellID == glyphID then return true end
		end
	end
	return false
end

------------------------------
-- SPELLBOOK
------------------------------

function jps_FindBuffDebuff(unit)
if unit == nil then unit = "player" end
	for i=1,40 do 
		local ID = select(11,UnitBuff(unit,i))
		local Name= select(1,UnitBuff(unit,i))
		if ID then print("|cff1eff00Buff",i.."="..ID,"="..Name) end 
	end

	for i=1,40 do 
		local ID = select(11,UnitDebuff(unit,i))
		local Name= select(1,UnitDebuff(unit,i))
		if ID then print("|cFFFF0000Debuff",i.."="..ID,"="..Name) end 
	end
end

-- name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellId or spellName)


--[[ skillType, spellId = GetSpellBookItemInfo(index, bookType)
index  - Number - The index into the spellbook
bookType  - String - Spell book type; either BOOKTYPE_PET ("pet") or BOOKTYPE_SPELL ("spell")
Returns
skillType - String - The type of the spell (known values: "SPELL", "PETACTION", "FUTURESPELL", "FLYOUT")
spellId - Number - Spell ID of the spellbook item.
If nothing is found or invalid parameters were supplied, nil is returned
]]

--[[ Name, Subtext = GetSpellBookItemName(index, "bookType") or GetSpellBookItemName("spellName")
slotIndex - Number - Spellbook item index. Valid values are 1 through total number of spells in the spellbook on all pages and all tabs, ignoring empty slots.
bookType - String - Either BOOKTYPE_SPELL ("spell") or BOOKTYPE_PET ("pet").
Returns 
Name - Name of the spell. (string)
Subtext - The text that's written below the skill name. (string)
]]

--[[ name, texture, offset, numEntries, isGuild, offspecID = GetSpellTabInfo(tabIndex)
tabIndex - Number - The index of the tab, ascending from 1.
Returns
name - String - The name of the spell line (General, Shadow, Fury, etc.)
texture - String - The texture path for the spell line's icon
offset - Number - Number of spell book entries before this tab (one less than index of the first spell book item in this tab)
numEntries - Number - The number of spell entries in this tab.
isGuild - Boolean - true for Guild Perks, false otherwise
offspecID - Number - 0 if the tab contains spells you can cast (general/specialization/trade skill/etc); or specialization ID of the specialization this tab is showing the spells of.
]]

-- "Fouet mental" 15407 is bugged - GetSpellBookItemName(44,"spell") return name "Fouet mental" - but GetSpellBookItemInfo(44, booktype) returns spellID 585 which is "Chatiment"

function jps_GetSpellBook()
	local AllSpellKnown = {}
	local _, _, offset, numSpells, _ = GetSpellTabInfo(2)
	local booktype = "spell"
			for index = offset+1, numSpells+offset do
			    -- Get the Global Spell ID from the Player's spellbook
			    -- local spellname,rank,icon,cost,isFunnel,powerType,castTime,minRange,maxRange = GetSpellInfo(spellID)
	            local name = select(1,GetSpellBookItemName(index, booktype))
	            local spellID = select(2,GetSpellBookItemInfo(index, booktype))
	 			local spellname = name:lower()
	            AllSpellKnown[spellname] = spellID
	        end
	return AllSpellKnown
end

function jps_FindSpellBookSlot()
    local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
    local booktype = "spell"
    for index = offset+1, numSpells+offset do
        -- Get the Global Spell ID from the Player's spellbook 
        local spellID = select(2,GetSpellBookItemInfo(index, booktype))
        local slotType = select(1,GetSpellBookItemInfo(index, booktype))
        local name = select(1,GetSpellBookItemName(index, booktype)) 
        local spellname = select(1,GetSpellInfo(name)) -- select(1,GetSpellInfo(spellID))
        --local spellname,rank,icon,cost,isFunnel,powerType,castTime,minRange,maxRange = GetSpellInfo(spellID)
        print("Index",index,"spellID",spellID,"name",name,"spellname",spellname)
    end
end

function jps_IsSpellKnown(spell)
	local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
	local booktype = "spell"
	local mySpell = nil
		local spellname = nil
		if type(spell) == "string" then spellname = spell end
		if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
			for index = offset+1, numSpells+offset do
	            -- Get the Global Spell ID from the Player's spellbook 
	            local spellID = select(2,GetSpellBookItemInfo(index, booktype))
	            local slotType = select(1,GetSpellBookItemInfo(index, booktype))
	            local name = select(1,GetSpellBookItemName(index, booktype))
	            if ((spellname:lower() == name:lower()) or (spellname == name)) and slotType ~= "FUTURESPELL" then
	                mySpell = spellname
	                break -- Breaking out of the for/do loop, because we have a match 
	            end 
	        end
	return mySpell
end


function jps.IsSpellKnown(spell)
	if jps_IsSpellKnown(spell) == nil then return false end
return true
end

------------------------------
-- GUID
------------------------------
-- GUID is a string containing the hexadecimal representation of the unit's GUID, 
-- e.g. "0xF130C3030000037F2", or nil if the unit does not exist
-- className, classId, raceName, raceId, gender, name, realm = GetPlayerInfoByGUID("guid")

function ParseGUID(unit)
local guid = UnitGUID(unit)
if guid then
	local first3 = tonumber("0x"..strsub(guid, 5,5))
	local known = tonumber(strsub(guid, 5,5))
	
	local unitType = bit.band(first3,0x7)
	local knownType = tonumber(guid:sub(5,5), 16) % 8
	
   if (unitType == 0x000) then
		local playerID = (strsub(guid,6))
		print("Player, ID #", playerID)
   elseif (unitType == 0x003) then
      local creatureID = tonumber("0x"..strsub(guid,7,10))
      local spawnCounter = tonumber("0x"..strsub(guid,11))
      print("NPC, ID #",creatureID,"spawn #",spawnCounter)
   elseif (unitType == 0x004) then
      local petID = tonumber("0x"..strsub(guid,7,10))
      local spawnCounter = tonumber("0x"..strsub(guid,11))
      print("Pet, ID #",petID,"spawn #",spawnCounter)
   elseif (unitType == 0x005) then
      local creatureID = tonumber("0x"..strsub(guid,7,10))
      local spawnCounter = tonumber("0x"..strsub(guid,11))
      print("Vehicle, ID #",creatureID,"spawn #",spawnCounter)
   end
end
   return guid
end

------------------------------
-- PLUA PROTECTED
------------------------------

function jps.groundClick()
	jps.Macro("/console deselectOnClick 0")
	CameraOrSelectOrMoveStart()
	CameraOrSelectOrMoveStop()
	jps.Macro("/console deselectOnClick 1")
end

function jps.faceTarget()
	InteractUnit("target")
end

function jps.moveToTarget()
	InteractUnit("target")
end

function jps.Macro(text) 
	RunMacroText(text)
end

----------------------------
-- FUNCTIONS SPECIALIZATION
----------------------------

-- specialisationID = GetArenaOpponentSpec(oppNumber) returns specialisationID - Specialization ID. Use GetSpecializationInfoByID() to get rest of data
-- oppNumber - Number 1-5. The numbering corresponds Arena units. (number)
-- id, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)
-- id = GetInspectSpecialization("unit")

jps_tableSpec =
{
  [250]="Blood", [251]="Frost", [252]="Unholy", [102]="Balance", [103]="Feral",
  [104]="Guardian", [105]="Restoration", [253]="Beast Mastery", [254]="Marksmanship",
  [255]="Survival", [62]="Arcane", [63]="Fire", [64]="Frost", [268]="Brewmaster",
  [270]="Mistweaver", [269]="Windwalker", [65]="Holy", [66]="Protection",
  [70]="Retribution", [256]="Discipline", [257]="Holy", [258]="Shadow",
  [259]="Assassination", [260]="Combat", [261]="Subtlety", [262]="Elemental",
  [263]="Enhancement", [264]="Restoration", [265]="Affliction", [266]="Demonology",
  [267]="Destruction", [71]="Arms", [72]="Fury", [73]="Protection",
  [0]="Unknown Spec"
}
-- id, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)
-- id Number - specialization ID.
-- name String - specialization name, e.g. "Balance".
-- role String - This specialization's intended role in a party, one of "DAMAGER", "TANK", "HEALER".
-- class String - The name of the class to which this specialization belongs.

function jps_EnemySpec_Arena(number)
    local numOpponents = GetNumArenaOpponentSpecs() -- Returns the number of enemy players which specialization data are available in an arena match
    if numOpponents == 0 then return 0 end
    
    local specID = GetArenaOpponentSpec(number)
    local enemySpec = select(2,GetSpecializationInfoByID(specID)) 
    local enemyRole = select(6,GetSpecializationInfoByID(specID)) -- "DAMAGER", "TANK", "HEALER"
    local enemyClass = select(7,GetSpecializationInfoByID(specID)) -- Class
    return enemyRole,enemySpec,enemyClass
end

function jps_EnemySpec_Arena_Healer() 
    local numOpponents = GetNumArenaOpponentSpecs() -- Returns the number of enemy players which specialization data are available in an arena match
    if numOpponents == 0 then return 0 end
    local arenaNumber = 0
    for num=1,numOpponents do
        local enemyRole,_,_ = jps_EnemySpec_Arena(num)
        if enemyRole == "HEALER" then
            arenaNumber = num 
            break 
        end
    end
    return "arena"..arenaNumber
end


-- enemyRole, enemySpec, and enemyClass haven't been set yet when the function returns their values. 
-- The INSPECT_READY event is fired at some point in the future after that point.
-- Also, you also really don't want to be creating a new frame/event handler for every call
 
local f = CreateFrame("Frame")
f:SetScript("OnEvent",function(self, event, ...)
	if self[event] then
		self[event](self, ...) -- Call the method with the same name as the event. (INSPECT_READY fires the f:INSPECT_READY(...) method)
	end
end)
 
f:RegisterEvent("INSPECT_READY")
 
function f:INSPECT_READY(guid) -- Wowpedia says it has a single GUID argument, WoW Programming says it doesn't. If it doesn't have this argument, get rid of the GUID check below.
	local unit = self.unit
	if unit and UnitGUID(unit) == guid then
		self.unit = nil
		local specID = GetInspectSpecialization(unit)
		local _, enemySpec, _, _, _, enemyRole, enemyClass = GetSpecializationInfoByID(specID) -- It's more efficient to call the function once and use dummy variables for the returns you don't need than to call it once for each return you want.
		print(specID, "-", UnitName(unit), "is", jps_tableSpec[specID], "-", enemyClass, "-", enemySpec, "-", enemyRole)
		self:InspectReadyCallback(unit, specID, enemySpec, enemyRole, enemyClass) -- You can rename this and reorganise the arguments to your liking, just make sure you change its definition below.
	end
end
 
function f:InspectReadyCallback(unit, specID, enemySpec, enemyRole, enemyClass) -- Called when INSPECT_READY fires for the unit we inspected
	-- Do some stuff with the information we received from the inspection
end
 
function jps_EnemySpec_BG(unit)
	if not UnitExists(unit) then unit = "player"
	else unit = "target" end
 
	if CheckInteractDistance(unit,1) then
		f.unit = unit
		NotifyInspect(unit)
	end
end  
