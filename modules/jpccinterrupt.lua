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

--------------------------------------
-- Loss of Control check (e.g. PvP) --
--------------------------------------
-- API changes http://www.wowinterface.com/forums/showthread.php?t=45176
-- local LossOfControlType, _, LossOfControlText, _, LossOfControlStartTime, LossOfControlTimeRemaining, duration, _, _, _ = C_LossOfControl.GetEventInfo(1)
-- LossOfControlType : --STUN_MECHANIC --STUN --PACIFYSILENCE --SILENCE --FEAR --CHARM --PACIFY --CONFUSE --POSSESS --SCHOOL_INTERRUPT --DISARM --ROOT

jps.stunTypeTable = {"STUN_MECHANIC", "STUN", "PACIFYSILENCE", "SILENCE", "FEAR", "CHARM", "PACIFY", "CONFUSE", "ROOT"}
function jps.StunEvents() -- ONLY FOR PLAYER
	local numEvents = C_LossOfControl.GetNumEvents()
	local locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType = C_LossOfControl.GetEventInfo(numEvents)
	if (numEvents > 0) and (timeRemaining ~= nil) then
		if 	locType == SCHOOL_INTERRUPT then
			--print("SPELL_FAILED_INTERRUPTED",locType)
			jps.createTimer("Spell_Interrupt", 2 )
		end
		for i,j in ipairs(jps.stunTypeTable) do
			if locType == j and timeRemaining > 1 then
			--print("locType: ",locType,"timeRemaining: ",timeRemaining)
			return true end
		end
	end
	return false
end

-- Check if unit loosed control
-- unit = http://www.wowwiki.com/UnitId
-- type of spell = "CC" , "Snare" , "Root" , "Silence" , "Immune", "ImmuneSpell", "Disarm"
function jps.LoseControl(unit,message)
	local targetControlled = false
	local timeControlled = 0
	if not jps.UnitExists(unit) then return targetControlled, timeControlled end
	if message == nil then message = "CC" end 

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

function jps.shouldKick(unit)
	if not jps.canDPS(unit) then return false end
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