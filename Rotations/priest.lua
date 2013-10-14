local L = MyLocalizationTable
priest = {}
local function toSpellName(id) name = GetSpellInfo(id); return name end
priest.Spell = {}
priest.Spell["average_flashheal"] = math.max(90000 , getaverage_heal(L["Flash Heal"]))
priest.Spell["SpiritShell"] = tostring(select(1,GetSpellInfo(114908))) -- buff target Spirit Shell 114908
priest.Spell["PrayerofHealing"] = tostring(select(1,GetSpellInfo(596))) -- "Prière de soins" 596
priest.Spell["NaaruGift"] = tostring(select(1,GetSpellInfo(59544))) -- NaaruGift 59544
priest.Spell["Desesperate"] = tostring(select(1,GetSpellInfo(19236))) -- "Prière du désespoir" 19236
priest.Spell["BindingHeal"] = tostring(select(1,GetSpellInfo(32546))) -- "Soins de lien" 32546
priest.Spell["Grace"] = tostring(select(1,GetSpellInfo(77613))) -- Grâce 77613 -- jps.buffStacks(Grace,jps_TANK)
priest.Spell["DivineAegis"] =  tostring(select(1,GetSpellInfo(47753))) -- Egide Divine 47515 - 47753


priest.RaidStatus = {}

function priest.updateRaidStatus(lowHealthDef,auraID,tank)
	if lowHealthDef == nil then lowHealthDef = 0.75 end
	local countInRange = 0
	local countInRaid = 0
	local groupToHeal = jps.FindSubGroup()
	local groupToAura = 1
	if tank == nil then groupToAura = groupToHeal
	else groupToAura = jps.UnitSubGroupInRaid(tank) end
	local tt_count = 0
	local tt = nil
	local lowestUnit = jpsName
	local lowestHP = 1
	local auratt = nil
	local auratt_count = 0

	for unit,unitTable in pairs(jps.RaidStatus) do
		local hpInc = UnitGetIncomingHeals(unit)
		if not hpInc then hpInc = 0 end
		local hpAbs = UnitGetTotalAbsorbs(unit)
		if not hpAbs then hpAbs = 0 end
        local thisHP = UnitHealth(unit) + hpInc + hpAbs
        local thisHPct = thisHP / UnitHealthMax(unit)
        
		if (unitTable["inrange"] == true) and unitTable["hpct"] < 1 then
			countInRange = countInRange + 1
		end
		if (unitTable["inrange"] == true) and unitTable["hpct"] < lowHealthDef then
			countInRaid = countInRaid + 1
		end
		if (unitTable["inrange"] == true) and (unitTable["hpct"] < lowHealthDef) and (unitTable["subgroup"] == groupToHeal)  then
			tt_count = tt_count + 1
			tt = unit
		end
		if (unitTable["inrange"] == true) and thisHPct < lowestHP then
         	lowestHP = thisHPct
         	lowestUnit = unit
        end
        local mybuff = jps.buffId(auraID,unit) -- spellID
        if (unitTable["inrange"] == true) and (unitTable["subgroup"] == groupToAura) and not mybuff then
			auratt = unit
			auratt_count = auratt_count + 1
		end
        
	end

priest.RaidStatus.countInRange = countInRange
priest.RaidStatus.countInRaid = countInRaid
if auratt_count > 2 then priest.RaidStatus.ShellTarget = auratt else priest.RaidStatus.ShellTarget = nil end
if tt_count > 2 then priest.RaidStatus.POHtarget = tt  else priest.RaidStatus.POHtarget = nil end
priest.RaidStatus.groupToHeal = (IsInGroup() and (IsInRaid() == false) and (countInRaid > 2)) or (IsInRaid() and type(priest.RaidStatus.POHtarget) == "string")
priest.RaidStatus.LowestFriend = lowestUnit

return priest.RaidStatus
end

-- jps.RaidTarget[unittarget_guid] = { ["unit"] = unittarget, ["hpct"] = hpct_enemy, ["count"] = countTargets + 1 }
-- jps.EnemyTable[enemyGuid] = { ["friend"] = enemyFriend } -- TABLE OF ENEMY GUID TARGETING FRIEND NAME
function priest.updateRaidTarget(friendName)
	for unit,index in pairs(jps.EnemyTable) do
		if UnitIsUnit(friendName,index.friend) == 1 then return true end
	end
	return false
end

-- Enemy Tracking
function priest.rangedTarget()
	local rangedTarget = "target"
	local lowestEnemy = jps.LowestInRaidTarget()
	if jps.canDPS("target") then
		rangedTarget =  "target"
	elseif jps.canDPS("focustarget") then
		rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
		rangedTarget = "targettarget"
	elseif jps.canDPS(lowestEnemy) then
		rangedTarget = lowestEnemy
	end
	return rangedTarget
end

-- Target Heal
function priest.jpsTank()
	local jps_TANK = jps.findMeATank() -- IF NOT "FOCUS" RETURN PLAYER AS DEFAULT
	local Tanktable = { ["focus"] = 100, ["player"] = 100, ["target"] = 100, ["targetarget"] = 100, ["mouseover"] = 100 }
	if isInBG and playerhealth_pct < 0.40 then
		jps_TANK = player
	elseif jps.Defensive then -- WARNING FOCUS RETURN FALSE IF NOT IN GROUP OR RAID BECAUSE OF UNITINRANGE(UNIT)
		Tanktable["player"] = jps.roundValue(jps.hp("player"),3)
		if jps.canHeal("focus") then Tanktable["focus"] = jps.roundValue(jps.hp("focus"),3) else Tanktable["focus"] = 100 end
		if jps.canHeal("target") then Tanktable["target"] = jps.roundValue(jps.hp("target"),3) else Tanktable["target"] = 100 end
		if jps.canHeal("targettarget") then Tanktable["targettarget"] = jps.roundValue(jps.hp("targettarget"),3) else Tanktable["targettarget"] = 100 end
		if jps.canHeal("mouseover") then Tanktable["mouseover"] = jps.roundValue(jps.hp("mouseover"),3) else Tanktable["mouseover"] = 100 end
		local lowestHP = 1
		for unit,hpct in pairs(Tanktable) do
			local thisHP = hpct
			if thisHP <= lowestHP then 
				lowestHP = thisHP
				jps_TANK = select(1,UnitName(unit))
			end
		end
	else
		jps_TANK = jps.LowestFriendlyStatus() -- jps.LowestInRaidStatus()
	end
	return jps_TANK
end

-- FIND THE TARGET IN SUBGROUP TO HEAL WITH BUFF SPIRIT SHELL IN RAID
function jps.FindSubGroupAura(aura) -- auraID to get correct spellID
	local groupToHeal = jps.FindSubGroup()
	local tt = nil
	local tt_count = 0

	for unit,unitTable in pairs(jps.RaidStatus) do
		local mybuff = jps.buffId(aura,unit)
		if (unitTable["inrange"] == true) and (unitTable["subgroup"] == groupToHeal) and not mybuff then
			tt = unit
			tt_count = tt_count + 1
		end
	end
	if tt_count > 2 then return tt end
	return nil
end

-- FIND THE TARGET IN SUBGROUP TO HEAL WITH BUFF SPIRIT SHELL IN RAID
function priest.FindSubGroupAura(aura,tank) -- auraID to get correct spellID
	local tt = nil
	local tt_count = 0
	local groupToHeal = 1
	if tank == nil then groupToHeal = jps.FindSubGroup()
	else groupToHeal = jps.UnitSubGroupInRaid(tank) end 

	for unit,unitTable in pairs(jps.RaidStatus) do
		local mybuff = jps.buffId(aura,unit) -- spellID
		if (unitTable["inrange"] == true) and (unitTable["subgroup"] == groupToHeal) and not mybuff then
			tt = unit
			tt_count = tt_count + 1
		end
	end
	if tt_count > 2 then return tt end
	return nil
end

function priest.unitFor_MassDispel_Friend() -- Mass Dispel on PLAYER
	local parse_MassDispell = { 32375, false , "player" , "MassDispel_Friend_" }
	if not FireHack then return parse_MassDispell end
	if jps.Moving then return parse_MassDispell end
	if jps.cooldown(32375) ~= 0 then return parse_MassDispell end
	if not jps.MagicDispel("player") and not jps.DiseaseDispel("player") then return parse_MassDispell end
	
	local debuffcount = 0
	local PlayerGuid = UnitGUID("player")
	local PlayerObject = GetObjectFromGUID(PlayerGuid)
	local NearbyPlayers = PlayerObject:GetNearbyPlayers (8)
	if jps.tableLength(NearbyPlayers) == 0 then return parse_MassDispell end
	
	for _,UnitObject in ipairs(NearbyPlayers) do
		local UnitObject_name = UnitObject:GetName()
		if jps.MagicDispel(UnitObject_name) then
			debuffcount = debuffcount + 1
		end
		if debuffcount > 2 then
			parse_MassDispell[2] = true
		break end
	end
	return parse_MassDispell
end

function priest.unitFor_MassDispel_Enemy() -- Mass Dispel on TARGET
	local parse_MassDispell = { 32375, false , "target" , "MassDispel_Enemy_" }
	if not FireHack then return parse_MassDispell end
	if jps.Moving then return parse_MassDispell end
	if jps.cooldown(32375) ~= 0 then return parse_MassDispell end
	
	local PlayerGuid = UnitGUID("player")
	local PlayerObject = GetObjectFromGUID(PlayerGuid)
	local NearbyEnemies = PlayerObject:GetNearbyEnemies (30)
	if jps.tableLength(NearbyEnemies) == 0 then return parse_MassDispell end
		
	local iceblock = tostring(select(1,GetSpellInfo(45438))) -- ice block mage
	local divineshield = tostring(select(1,GetSpellInfo(642))) -- divine shield paladin
	for _,UnitObject in ipairs(NearbyEnemies) do
		if UnitObject:GetAura (divineshield) then
			UnitObject:Target()
			parse_MassDispell[2] = true
		elseif UnitObject:GetAura (iceblock) then
			UnitObject:Target()
			parse_MassDispell[2] = true
		break end
	end
	return parse_MassDispell
end

function priest.unitFor_Fear_Enemy() -- Enemy is casting a CC spell
	local Fear_Table = {8122, false, nil, "FEAR_MultiUnit_" }
	if jps.cooldown(8122) ~= 0 then return Fear_Table end
	if not FireHack then return Fear_Table end
	local PlayerGuid = UnitGUID("player")
	local PlayerObject = GetObjectFromGUID(PlayerGuid)
	local NearbyEnemies = PlayerObject:GetNearbyEnemies (8)
	if jps.tableLength(NearbyEnemies) == 0 then return Fear_Table end
	
	for _,UnitObject in ipairs(NearbyEnemies) do
		local enemyGuid = UnitObject:GetGUID ()
		if jps.RaidTarget[enemyGuid] ~= nil then
			local enemyUnit = jps.RaidTarget[enemyGuid]["unit"]
			local iscasting = jps.IsCastingControl(enemyUnit)
			if iscasting then
				Fear_Table[2] = true
				Fear_Table[3] = enemyUnit
			break end
		end
	end
	return Fear_Table
end

function priest.unitFor_Fear_Event() -- Target is casting a CC spell
	local parse_CrowdControl = { 8122 , false , nil , "FEAR_Event_CC_" }
	if jps.cooldown(8122) ~= 0 then return parse_CrowdControl end
	if not FireHack then return parse_CrowdControl end
	
	if jps.CrowdControl == true then
		local UnitGuid = UnitGUID(jps.CrowdControlTarget)
		local UnitObject = GetObjectFromGUID(UnitGuid)
		if UnitObject:GetDistance() < 8 then
			parse_CrowdControl[2] = true
			parse_CrowdControl[3] = jps.CrowdControlTarget
		end
	end
	return parse_CrowdControl
end