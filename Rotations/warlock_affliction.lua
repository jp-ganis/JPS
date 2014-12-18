function getDotStatus(unit)
	local castCorruption = jps.myDebuffDuration("corruption" ,unit) <= 3
	local castAgony = jps.myDebuffDuration("agony", unit) <= 4
	local castUnstableAffliction = jps.myDebuffDuration("Unstable Affliction", unit) <= 3
	return (castCorruption or castAgony or castUnstableAffliction), (castCorruption and castAgony and castUnstableAffliction)
end

-- checks if the given unit (or all dottableUnits) are possible targets for soulburn/soulswap
local function isSoulburnSoulSwapTarget(unit)
	local shards = UnitPower("player", 7)
	local attackFocus = false
	local attackMouseOver = false
	local burnPhase = jps.hp("target") <= 0.20;
   
   -- If focus exists and is not the same as target, consider attacking focus too
	if not UnitExists(unit) or UnitIsFriend("player", unit) or  jps.dotTracker.isTrivial("target") then
		return false
	end

	local oneDotMissing, allDotsMissing = getDotStatus(unit)
	local castSoulburn = false

	if allDotsMissing == true then
		-- since soulburn mouseover is a bit risky, only do it at 4 shards
		if unit == "mouseover" then
			if shards > 3 then
			castSoulburn = true
			end
		-- every other target can be recasted with at least 2 shards left
		elseif unit ~= "mouseover" and shards >= 1 then
			castSoulburn = true
		end
	end

	-- Don't cast soulburn is last cast was soulswap!
	return castSoulburn and not jps.isRecast(wl.spells.soulSwap, unit)
end


function wl.soulburnSoulSwapTable()
	local soulburnTable = {wl.spells.soulburn,false}
	local soulSwapTable = {wl.spells.soulSwap, false}
	--local cancelSoulburnTable = {{"macro","/cancelaura "..wl.spells.soulburn}, true}
	local function setTable(tbl,condition,target) tbl[2] = condition; tbl[3] = target; return tbl end

	return function()
		for i, dottableUnit in ipairs(wl.dottableUnits) do
			if isSoulburnSoulSwapTarget(dottableUnit) then
				if jps.buffDuration(wl.spells.soulburn) == 0 then
					-- If we are not soulburned, cast soulburn
					return setTable(soulburnTable,true,unit)
				else
					-- If we are alredy soulburned, cast soulswap
					return setTable(soulSwapTable,true,unit)
				end
			end
		end
		return setTable(soulburnTable,false,"target")
	end
end


-- aborts channeling spells, if necessary
local function cancelChannelingIfNecessary()

	if UnitChannelInfo("player") == wl.spells.drainSoul and not jps.dotTracker.isTrivial("target") then
	local stopChanneling = false
		if UnitClassification("target") == "worldboss" or UnitClassification("target") == "elite" then
			local oneDotMissing, allDotsMissing = getDotStatus("target")
			if oneDotMissing then stopChanneling = true end
		end
	end
	if IsAltKeyDown() or IsControlKeyDown() then stopChanneling  = true end 
	if stopChanneling then
		SpellStopCasting()
		jps.NextSpell = nil
	end
end


-- checks whether a unit has seed of curruption or soulburned seed of corruption
function wl.socDuration(unit,soulburned)
	local hasSoC, hasSoulburnSoC = false
	local durationSoC, durationSoulburnSoC = 0
	for i=1,40 do
		local _, _, _, _, _, _, expirationTime, caster, _, _, spellId = UnitDebuff(unit, i)
		local duration = 0
		if expirationTime~=nil then
			duration = expirationTime-GetTime()
			if duration < 0 then duration = 0 end
		end
		if not soulburned and spellId==27243 and caster=="player" then -- Default SoC
			return duration
		elseif soulburned and spellId==114790 and caster=="player" then -- Soulburn SoC
			return duration
		end
	end
	return 0
end

function wl.canSoulSwap()
	if not UnitExists("mouseover") then return false end
	if jps.myDebuff(wl.spells.corruption) and jps.myDebuff(wl.spells.agony) and  jps.myDebuff(wl.spells.unstableAffliction) and not jps.buff("soul swap") and jps.soulShards() >= 1 and IsShiftKeyDown() == true and IsAltKeyDown() == true and jps.canDPS("mouseover") and not UnitIsUnit("target","mouseover") then
		return true
	end
	return false
end


local spellTable = {

	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),

	-- Def CD's
	{ wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{ jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	
	-- CD's
	{"soul swap", 'wl.canSoulSwap()',"target"},
	{"soul swap", 'jps.buff("soul swap") and jps.canDPS("mouseover")',"mouseover"},
	
	
	{ {"macro","/cast " .. wl.spells.darkSoulMisery}, 'jps.cooldown(wl.spells.darkSoulMisery) == 0 and jps.UseCDs and not jps.buff(wl.spells.darkSoulMisery) ' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{ wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.UseCDs' },	

	{"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
		-- Life Tap
		{wl.spells.lifeTap, 'jps.mana() < 0.4 and jps.mana() < jps.hp("player")' },

		-- Haunt
		{"nested", 'not jps.isRecast(wl.spells.haunt,"target") ', {
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.hp("target") <= 0.20 and jps.soulShards() >= 1' },
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.soulShards() == 4'},
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.soulShards() >= 2'}, 
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.buff(wl.spells.darkSoulMisery) and jps.soulShards() >= 1'},
		}},
		-- DoT's

		jps.dotTracker.castTableStatic("agony"),
		{"nested", 'not jps.Moving', {
			jps.dotTracker.castTableStatic("Unstable Affliction"),
		}},
		jps.dotTracker.castTableStatic("corruption"),
		-- Filler
		{wl.spells.drainSoul },
	}},
	{"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
	
		jps.dotTracker.castTableStatic("agony"),
		jps.dotTracker.castTableStatic("corruption"),

	}},
	{"nested", 'jps.MultiTarget', {
		-- Life Tap
		{wl.spells.lifeTap, 'jps.mana() < 0.4 and jps.mana() < jps.hp("player")' },
		{wl.spells.soulburn, 'jps.myDebuffDuration(wl.spells.corruption, "target") < 2 and wl.socDuration("target",true)<1'},
		{wl.spells.seedOfCorruption, 'jps.buffDuration(wl.spells.soulburn) > 0 and jps.myDebuffDuration(wl.spells.corruption,"target") < 3 and not wl.socDuration("target",true)<1 and not jps.isRecast(wl.spells.seedOfCorruption,"target")'},
		{wl.spells.seedOfCorruption, 'wl.socDuration("target") < 2 and not jps.isRecast(wl.spells.seedOfCorruption,"target")'},
		{wl.spells.seedOfCorruption, 'wl.socDuration("mouseover") < 2 and not jps.isRecast(wl.spells.seedOfCorruption,"mouseover")', "mouseover"},
		-- Haunt
		{"nested", 'not jps.isRecast(wl.spells.haunt,"target")', {
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.hp("target") <= 0.20 and jps.soulShards() >= 1' },
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.soulShards() == 4'},
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.soulShards() >= 2'},
			{wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.buff(wl.spells.darkSoulMisery) and jps.soulShards() >= 1'},
		}},
		{wl.spells.drainSoul },
	}},
}


--[[[
@rotation Affliction 6.0.2
@class warlock
@spec affliction
@author Kirk24788
@description
This is a Raid-Rotation, which will do fine on normal mobs, even while leveling but might not be optimal for PvP.
[br]
Modifiers:[br]
[*] [code]CTRL + ALT[/code]: Soulburn + Soul Swap for all dots on the current target[br]
[*] [code]ALT[/code]: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)[br]
[*] [code]jps.Interrupts[/code]: Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)[br]
[*] [code]jps.Defensive[/code]: Create Healthstone if necessary and cast mortal coil[br]
[*] [code]jps.UseCDs[/code]: Use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated![br]
]]--
jps.registerRotation("WARLOCK","AFFLICTION",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if jps.IsSpellKnown("Shadowfury") and jps.cooldown("Shadowfury") == 0 and IsAltKeyDown() == true and not GetCurrentKeyBoardFocus() and  IsShiftKeyDown() == false and  IsControlKeyDown() == false then
		jps.Cast("Shadowfury")
	end --spells out of spelltable are currently necessary when they come from talents :(
	
	
	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	cancelChannelingIfNecessary()

	return parseStaticSpellTable(spellTable)
end,"Affliction 6.0.2")
