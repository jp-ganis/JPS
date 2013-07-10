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
		if enabled then
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

--[[

pending delete - never used! 



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

]]--