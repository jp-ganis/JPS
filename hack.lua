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

function fh.NearbyUnit()

	local Total = GetTotalObjects(TYPE_PLAYER)
	local PlayerGuid = UnitGUID("player")
	local PlayerObject = GetObjectFromGUID(PlayerGuid)
	local i = 1
	while i <= Total do
	   local ThisObject = GetObjectListEntry(i);
	   local ThisObject_name = ThisObject:GetName()
	   local ThisObject_guid = ThisObject:GetGUID()
	   local ThisObject_hpct = ThisObject:GetHealth () / ThisObject:GetMaxHealth ()
	   local ThisObject_target = ThisObject:GetTarget() -- Returns the object's target Only available for units and players

	   if (ThisObject:GetDistance() < 40) and ThisObject:InLineOfSight() and ThisObject:Exists() then -- and (ThisObject_hpct > 0)
		  if not PlayerObject:CanAttack(ThisObject) then
			 fh.FriendUnit[ThisObject_name] = {["hpct"]= ThisObject_hpct}
			 --print("Name: ", ThisObject:GetName(),"type: ", ThisObject:GetType(),"Reaction: ", ThisObject:GetReaction(PlayerObject))
			 -- ThisObject:GetReaction (PlayerObject) == 5
		  end
		  if PlayerObject:CanAttack(ThisObject) then
		  	fh.EnemyUnit[ThisObject_guid ] = {["hpct"]= ThisObject_hpct}
		  	--write("Name: ", ThisObject:GetName(),"type: ", ThisObject:GetType(),"Reaction: ", ThisObject:GetReaction(PlayerObject))
			-- ThisObject:GetReaction (PlayerObject) == 2
		  end
	   else
			jps.removeTableKey(fh.FriendUnit,ThisObject_name)
			jps.removeTableKey(fh.EnemyUnit,ThisObject_guid)
	   end
		  i = i + 1;
	end
end

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

function fh.SortRaidStatus()
	local PlayerGuid = UnitGUID("player")
	local PlayerObject = GetObjectFromGUID(PlayerGuid)
	local NearbyPlayers = PlayerObject:GetNearbyPlayers (40)
	local NearbyEnemies = PlayerObject:GetNearbyEnemies (40)
	
	for _,ThisObject in ipairs(NearbyPlayers) do
		local ThisObject_name = ThisObject:GetName()
		local ThisObject_guid = ThisObject:GetGUID()
		local ThisObject_hpct = ThisObject:GetHealth () / ThisObject:GetMaxHealth ()
		local ThisObject_target = ThisObject:GetTarget() -- Returns the object's target Only available for units and players
		local ThisObject_raid = jps.UnitInRaid(ThisObject_name)

		if not fh.RaidStatus[ThisObject_name] then fh.RaidStatus[ThisObject_name] = {} end
		fh.RaidStatus[ThisObject_name] = {		["unit"] = ThisObject_raid ,
												["guid"] = ThisObject_guid ,
												["hpct"] = ThisObject_hpct ,
												["target"] = ThisObject_target 
											}
	end

	for _,ThisObject in ipairs(NearbyEnemies) do
		local ThisObject_name = ThisObject:GetName()
		local ThisObject_guid = ThisObject:GetGUID()
		local ThisObject_hpct = ThisObject:GetHealth () / ThisObject:GetMaxHealth ()
		local ThisObject_target = ThisObject:GetTarget() -- Returns the object's target Only available for units and players
		
		if not fh.RaidTarget[ThisObject_name] then fh.RaidTarget[ThisObject_name] = {} end
		fh.RaidTarget[ThisObject_name] = {		["guid"] = ThisObject_guid ,
												["hpct"] = ThisObject_hpct ,
												["target"] = ThisObject_target ,
											}
	end
end

-----------------------
-- FUNCTION DISTANCE 
-----------------------

function GatherRoute (counter)

	local x = counter
	local y = counter
	local z = counter
	local x1 = x+counter
	local y1 = y+counter
	local z1 = z+counter

	local pX = Route_Angoisse[x][1] -- j[1]
	local pY = Route_Angoisse[y][2] -- j[2]
	local pZ = Route_Angoisse[z][3] -- j[3]
	-- GetDistanceBetweenPoints (X1, Y1, Z1, X2, Y2, Z2 ) Returns the distance between the 2 points.
	local pX1 = Route_Angoisse[x1][1] -- j[1]
	local pY1 = Route_Angoisse[y1][2] -- j[2]
	local pZ1 = Route_Angoisse[z1][3] -- j[3]
	
	local PlayerGuid = UnitGUID("player")
	local PlayerObject = GetObjectFromGUID(PlayerGuid)
	local PlayerLocationX,PlayerLocationY,PlayerLocationZ  = PlayerObject:GetLocation ()
	local distance = GetDistanceBetweenPoints(pX, pY, pZ,PlayerLocationX,PlayerLocationY,PlayerLocationZ)
	local distance1 = GetDistanceBetweenPoints(pX1, pY1, pZ1,PlayerLocationX,PlayerLocationY,PlayerLocationZ) 
	print("|cff1eff00player",PlayerLocationX,PlayerLocationY,PlayerLocationZ)

	if distance1 > distance then 
		MoveTo(pX1, pY1, pZ1)
	else
		MoveTo (pX, pY, pZ)
	end
end

local counter = 1

function myRoute_OnUpdate(self,elapsed)
	if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	if (self.TimeSinceLastUpdate > 1) then
		counter = counter + 1
		local wp = jps_tableLen(Route_Angoisse)
		if counter == wp then counter = 1 end
		if not jps.Combat then
			myRoute (counter)
			self.TimeSinceLastUpdate = 0		
		end	
	end
end

--local routeFrame = CreateFrame("FRAME", nil)
--routeFrame:SetScript("OnUpdate", myRoute_OnUpdate)