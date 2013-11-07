--/click ActionButton1
-- SetCVar("autointeract", "1") -- Enable Click-to-Move -- RunMacroText("/console AutoInteract 1")
-- SetCVar("autointeract", "0") -- Disable Click-to-Move -- RunMacroText("/console AutoInteract 0")

-- reaction = UnitReaction("unit", "unit")
-- 1 - Hated
-- 2 - Hostile
-- 3 - Unfriendly
-- 4 - Neutral
-- 5 - Friendly
-- 6 - Honored
-- 7 - Revered
-- 8 - Exalted

-- TYPE_OBJECT
-- TYPE_ITEM
-- TYPE_CONTAINER
-- TYPE_UNIT
-- TYPE_PLAYER
-- TYPE_GAMEOBJECT
-- TYPE_DYNAMICOBJECT
-- TYPE_CORPSE

-- Object:GetMaxHealth ()
-- Object:GetHealth ()
-- Object:GetName () Returns the object's name. Only available for game objects, units, and players.
-- Object:GetGUID () Returns the object's GUID.
-- Object:CastSpellByName (Name)
-- Casts a spell at the object. If the spell is an area spell, it will be cast at the object's location. Only available for units and players.
-- Object:GetTarget () Returns the object's target Only available for units and players.
-- Object:Target () Targets the object. Only available for units and players.
-- Object:GetGUID () Returns the object's GUID.

-----------------------
-- FUNCTION RAIDSTATUS
-----------------------


-----------------------
-- FUNCTION TEST 
-----------------------
fh = {}
fh.FriendUnit = {}
fh.EnemyUnit = {}
fh.RaidStatus = {}
fh.RaidTarget = {}

function fh.groundClick(spell,unit)
	if unit == nil then unit = "player" end
	local UnitGuid = UnitGUID(unit)
	local knownTypes = {[0]="player", [1]="world object", [3]="NPC", [4]="pet", [5]="vehicle"}

	if FireHack and UnitGuid ~= nil then
		local knownType = tonumber(UnitGuid:sub(5,5), 16) % 8
		if (knownTypes[knownType] ~= nil) then
			local UnitObject = GetObjectFromGUID(UnitGuid)
			UnitObject:CastSpellByName(spell)
		end
	end
end