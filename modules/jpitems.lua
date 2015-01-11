--[[
	 JPS - WoW Protected Lua DPS AddOn
	Copyright (C) 2011 Jp Ganis

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--

--------------------------
-- LOCALIZATION
--------------------------
local L = MyLocalizationTable

function jps.glovesCooldown()
	local start, duration, enabled = GetInventoryItemCooldown("player", 10)
	if enabled==0 then return 999 end
	local cd = start+duration-GetTime() -- jps.Lag
	if cd < 0 then return 0 end
	return cd
end

local useBagItemMacros = {}
function jps.useBagItem(itemName)
	if type(itemName) == "number" then
		itemName, _ = GetItemInfo(itemName) -- get localized name when ID is passed
	end
	local count = GetItemCount(itemName, false, false)
	if count == 0 then return nil end -- we doesn't have this item in our bag
	for bag = 0,4 do
		for slot = 1,GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag,slot)
			if item and item:find(itemName) then -- item place found
				itemId = GetContainerItemID(bag, slot) -- get itemID for retrieving item Cooldown
				local start, dur, isNotBlocked = GetItemCooldown(itemId) -- maybe we should use GetContainerItemCooldown() will test it
				local cdDone = Ternary((start + dur ) > GetTime(), false, true)
				local hasNoCD = Ternary(dur == 0, true, false)
				if (cdDone or hasNoCD) and isNotBlocked == 1 then -- cd is done and item is not blocked (like potions infight even if CD is finished)
					if not useBagItemMacros[itemName] then useBagItemMacros[itemName] = { "macro", "/use "..itemName } end
					return useBagItemMacros[itemName]
				end
			end
		end
	end
	return nil
end 

--------------------------
-- TRINKET
--------------------------
-- isUsable, notEnoughMana = IsUsableItem(itemID) or IsUsableItem("itemName")
-- isUsable - 1 if the item is usable; otherwise nil (1nil)
-- notEnoughMana - 1 if the player lacks the resources (e.g. mana, energy, runes) to use the item; otherwise nil (1nil)
CreateFrame("GameTooltip", "ScanningTooltip", nil, "GameTooltipTemplate") -- Tooltip name cannot be nil
ScanningTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" )
ScanningTooltip:ClearLines()

function parseTrinketText(trinket,str)
	local id = 13 + trinket
	if trinket > 1 then return false end
	ScanningTooltip:SetInventoryItem("player", id)
	-- hasItem, hasCooldown, repairCost = Tooltip:SetInventoryItem("unit", invSlot {, nameOnly})

	local found = false
	for i=1,select("#",ScanningTooltip:GetRegions()) do 
		local region=select(i,ScanningTooltip:GetRegions())
		if region and region:GetObjectType()=="FontString" and region:GetText() then
			local text = region:GetText()
			--if text ~=nil then print(text) end
			if type(str) == "table" then 
				local matchesRequired = table.getn(str)
				local matchesFound = 0
				for key, val in pairs(str) do 
					if string.find(text:lower(), val:lower()) then 
						matchesFound = matchesFound +1 
					end
				end
				if matchesFound == matchesRequired then found = true end
			else 
				if string.find(text, str) then 
					found = true 
				end
			end
		end 
	end
	return found
end

function jps.trinketUse(trinket)
	return parseTrinketText(trinket, L["Use"])
end

jps.validTrinketStringsMana = {
	{L["Use"], "Spirit"},
	{L["Use"], "Mana"},
}
function jps.isManaRegTrinket(trinket)
	for k,valTable in pairs(jps.validTrinketStringsMana) do 
		if parseTrinketText(trinket, valTable) == true then
			return true
		end
	end
	return false
end

function jps.trinketIncreasesHealth(trinket)
	return parseTrinketText(trinket, {L["Use"], "health"})
end

function jps.trinketAbsorbDmg(trinket)
	return parseTrinketText(trinket, {L["Use"], "absorb"})
end

jps.itemStringTablePVPTrinket = {L["Use"], "Removes all movement impairing"}
function jps.isPVPInsignia(trinket)
	return parseTrinketText(trinket, jps.itemStringTablePVPTrinket)
end

--[[
function jps.isDPSHPSTrinket(trinket)
	local validStrings = {
		{L["Use"], "Increases", "spell power"},
		{L["Use"], "Increases", "strength"},
		{L["Use"], "Increases", "agility"},
		{L["Use"], "Increases", "intellect"},
		{L["Use"], "charges your weapon"},
		{L["Use"], "Increases", "haste"},
		{L["Use"], "Increases", "critical strike"},
		{L["Use"], "Increases", "mastery"},
	}
	for k,valTable in pairs(validStrings) do 
		if parseTrinketText(trinket, valTable) == true then
			return true
		end
	end
	return false
end
]]--


function jps.itemCooldown(item) -- start, duration, enable = GetItemCooldown(itemID) or GetItemCooldown("itemName")
	if item == nil then return 999 end
	local start,duration,isNotBlocked = GetItemCooldown(item) -- GetItemCooldown(ItemID)
	local cd = start+duration-GetTime() -- jps.Lag
	if isNotBlocked == 0 then return 999 end -- 1 if the item is ready or on cooldown, 0 if the item is used, but the cooldown didn't start yet 
	if cd < 0 then return 0 end
	return cd
end

local useSlotMacros = {}
function jps.useSlot(num)
	-- get the Trinket ID
	local trinketId = GetInventoryItemID("player", num)
	if not trinketId then return "" end

	-- Check if it's on cooldown
	local trinketCd = jps.itemCooldown(trinketId)
	if trinketCd > 0 then return "" end

	 -- Check if it's usable
	local trinketUsable = GetItemSpell(trinketId)
	if not trinketUsable then return "" end

	-- Abort Disenchant (or any Spell Targeting) if active
	if SpellIsTargeting() then
		SpellStopTargeting()
	end

	-- Use it
	if not useSlotMacros[num] then useSlotMacros[num] = { "macro", "/use "..num } end
	return useSlotMacros[num]
end

function jps.useEquipSlot(num)
	-- get the Trinket ID
	local trinketId = GetInventoryItemID("player", num)
	if not trinketId then return false end

	-- Check if it's on cooldown
	local trinketCd = jps.itemCooldown(trinketId)
	if trinketCd > 0 then return false end

	 -- Check if it's usable
	local trinketUsable = GetItemSpell(trinketId)
	if not trinketUsable then return false end

	-- Abort Disenchant (or any Spell Targeting) if active
	if SpellIsTargeting() then
		SpellStopTargeting()
	end

	-- Use it
	return true
end

-- For trinket's. Pass 0 or 1 for the number.
function jps.useTrinket(trinketNum)
	-- The index actually starts at 0
	local slotName = "Trinket"..(trinketNum).."Slot" -- "Trinket0Slot" "Trinket1Slot"
	
	-- Get the slot ID
	local slotId = select(1,GetInventorySlotInfo(slotName)) -- "Trinket0Slot" est 13 "Trinket1Slot" est 14

	return jps.useSlot(slotId)
end

function jps.useTrinketBool(trinketNum)
   -- The index actually starts at 0
   local slotName = "Trinket"..(trinketNum).."Slot" -- "Trinket0Slot" "Trinket1Slot"
   
   -- Get the slot ID
   local slotId = select(1,GetInventorySlotInfo(slotName)) -- "Trinket0Slot" est 13 "Trinket1Slot" est 14
   -- get the Trinket ID
   local trinketId = GetInventoryItemID("player", slotId)
   if not trinketId then return false end
   -- Check if it's on cooldown
   local trinketCd = jps.itemCooldown(trinketId)
   if trinketCd > 0 then return false end
   -- Check if it's usable
   local trinketUsable = GetItemSpell(trinketId)
   if not trinketUsable then return false end

   return true
end
