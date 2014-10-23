--[[[
@module Functions: spellbook functions
@description
Functions which handle talents & glyphs
]]--

local L = MyLocalizationTable

------------------------------
-- GLYPHS
------------------------------

-- numTalents = GetNumTalents(inspect)
-- numTalents If true, returns information for the inspected unit. otherwise, returns information for the player character.
-- name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq, previewRank, meetsPreviewPrereq = GetTalentInfo(tabIndex, talentIndex, inspect, pet, talentGroup)

-- isKnown = IsSpellKnown(spellID [, isPet])
-- isKnown - True if the player (or pet) knows the given spell. false otherwise
--[[[
@function jps.talentInfo
@description 
check's if a player has skilled a talent or not
[br][i]Usage:[/i][br]
[code]
jps.talentInfo("Shadowfury")

[/code]
@param string: talent name or spellID

@returns boolean
]]--
--JPTODO: check jps.talentInfo functionality
function jps.talentInfo(talent)
	local talentname = nil
	if type(talent) == "string" then talentname = talent end
	if type(talent) == "number" then talentname = tostring(select(1,GetSpellInfo(talent))) end

	local asg = GetActiveSpecGroup();
	local rows = 7
	local cols = 3

	for r = 1, rows do
		for c = 1, cols do
			local talentID, name, iconTexture, selected, available = GetTalentInfo(r,c,asg)
			if name:lower() == talentname:lower() and selected == true then return true end
		end
	end
	return false
end

-- numGlyphs = GetNumGlyphs() numGlyphs the number of glyphs THAT THE CHARACTER CAN LEARN
-- name, glyphType, isKnown, icon, glyphId, glyphLink, spec = GetGlyphInfo(index)
-- enabled, glyphType, glyphTooltipIndex, glyphSpellID, icon = GetGlyphSocketInfo(socketID[[, talentGroup], isInspect, inspectUnit])
--[[[
@function jps.glyphInfo
@description 
checks if a player has skilled a glyph or not
[br][i]Usage:[/i][br]
[code]
jps.glyphInfo(4)

[/code]
@param int: glyphID 

@returns boolean
]]--
--JPTODO: check jps.glyphInfo functionality
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