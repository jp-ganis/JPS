-- JPS Helper Functions
--jpganis


-- Lookup Tables
-- Credit (and thanks!) to BenPhelps
jps.Dispells = {
	["Magic"] = {
		"Static Disruption", -- Akil'zon
		"Consuming Darkness", -- Argaloth
		"Emberstrike", -- Erunak Stonespeaker
		"Binding Shadows", -- Erudax
		"Divine Reckoning", -- Temple Guardian Anhuur
		"Static Cling", -- Asaad, noobs shouldn't get hit by this, but get real....
		"Pain and Suffering", -- Baron Ashbury
		"Cursed Veil" -- Baron Silverlaine
		-- "Wither", -- Ammunae
	},
	
	["Poison"] = {
		"Viscous Poison", -- Lockmaw
	},
	
	["Disease"] = {
		"Plague of Ages", -- High Prophet Barim
	},
	
	["Curse"] = {
		"Curse of Blood", -- High Priestess Azil
		"Cursed Bullets", -- Lord Godfrey
	},
	
	["Enrage"] = { -- hunters pretty much
		"Enrage", -- Generic Enrage, used all over the place
	}	
}

-- Functions
function jps.Cast(spell)
	if not jps.Target then jps.Target = "target" end
	if not jps.Casting then jps.LastCast = spell end
	CastSpellByName(spell,jps.Target)	
	jps.Target = nil
	if jps.IconSpell ~= spell then
		jps.set_jps_icon( spell )
		if jps.Debug then write(spell, jps.Target) end
	end
end

function jps.canDispell( unit, ... )
	for _, dtype in pairs(...) do
		if jps.Dispells[dtype] ~= nil then
			for _, spell in pairs(jps.Dispells[dtype]) do
				if ud( unit, spell ) then return true end
			end
		end
	end
	return false
end

function jps.cooldown(spell)
	local start,duration,_ = GetSpellCooldown(spell)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.petCooldown(index)
	local start,duration,_ = GetPetActionCooldown(index)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.buff( spell, unit )
	if unit == nil then unit = "player" end
	if UnitBuff(unit, spell) then return true end
	return false
end

function jps.debuff( spell, unit )
	if unit == nil then unit = "target" end
	if UnitDebuff(unit, spell) then return true end
	return false
end

function jps.buffDuration( spell, unit)
	if unit == nil then unit = "player" end
	local _,_,_,_,_,_,expire,caster,_,_,_ = UnitBuff(unit,spell)
	if caster ~= "player" then return 0 end
	if expire == nil then return 0 end
	duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmyBuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,expire,_,_,_,_ = UnitBuff(unit,spell)
	if expire == nil then return 0 end
	duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spell)
	if caster~="player" then return 0 end
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmyDebuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,duration,_,caster,_,_ = UnitDebuff(unit,spell)
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffStacks( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,count, _,_,_,caster, _,_ = UnitDebuff(unit,spell)
	if caster ~= "player" then return 0 end
	if count == nil then count = 0 end
	return count
end

function jps.buffStacks( spell, unit )
	if unit == nil then unit = "player" end
	local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spell)
	if count == nil then count = 0 end
	return count
end

function jps.shouldPvPKick(unit)
	if unit == nil then unit = "target" end
	local target_spell, _, _, _, _, endTime, _, _, unInterruptable = UnitCastingInfo(unit)
  	local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
	if target_spell == "Release Aberrations" then return false end
	if target_spell and not unInterruptable then
		endTime = endTime - GetTime()*1000
		if jps.PVPInterrupt == true then
			if endTime < 500+jps.Lag then
				return true
			end 
		else 
			return true
		end
	elseif chanelling and not notInterruptible then
		return true
	end
	return false
end

function jps.shouldKick(unit)
	if unit == nil then unit = "target" end
	local target_spell, _, _, _, _, endTime, _, _, unInterruptable = UnitCastingInfo(unit)
	local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
	if target_spell == "Release Aberrations" then return false end
	if target_spell and not unInterruptable then
		return true
	end
	if chanelling and not notInterruptible then
		return true
	end 
	return false
end

function jps.mana(unit,message)
	if unit == nil then unit = "player" end
	if message == "abs" or message == "absolute" then
		return UnitMana(unit)
	else
		return UnitMana(unit)/UnitManaMax(unit)
	end
end

function jps.hp(unit,message)
	if unit == nil then unit = "player" end
	if message == "abs" or message == "absolute" then
		return UnitHealth(unit)
	else
		return UnitHealth(unit)/UnitHealthMax(unit)
	end
end

function jps.hpInc(unit,message)
	if unit == nil then unit = "player" end
	local hpInc = UnitGetIncomingHeals(unit)
	if not hpInc then hpInc = 0 end
	if message == "abs" or message == "absolute" then
		return UnitHealth(unit) + hpInc
	else
		return UnitHealth(unit)/UnitHealthMax(unit) + hpInc/UnitHealthMax(unit)
	end
end

function jps.targetHP(message)
	if message == "abs" or message == "absolute" then
		return UnitHealth("target")
	else
		return UnitHealth("target")/UnitHealthMax("target")
	end
end

function jps.lowestInRaidStatus()
	local lowestHP = 1
	local lowestUnit = nil
	for name, details in pairs(jps.RaidStatus) do
		if details["hp"] < lowestHP then
			lowestHP = details["hp"]
			lowestUnit = name
		end
	end

	return lowestUnit
end


-- Racial/Profession CDs Check
function jps.checkProfsAndRacials()
	-- Draenei, Dwarf, Worgen, Human, Gnome, Night Elf
	-- Tauren, Goblin, Orc, Troll, Forsaken, Blood Elf
	local usables = {}
	local moves =
	{
		"lifeblood",
		"berserking",
		"blood fury",
		--"engiGloves",
		--"gift of the naaru",
		--"stoneform",
		--"arcane torrent",
		--"will of the forsaken",
	}

	for _, move in pairs(moves) do
		if GetSpellBookItemInfo(move) then
			table.insert(usables,move)
		end
	end

	return usables

end

-- Lowest HP in RaidStatus
function jps.lowestFriendly()
	local lowestUnit = nil
	local lowestHP = UnitHealthMax("player")*100

	for unit, unitTable in pairs(jps.RaidStatus) do
		local thisHP = jps.RaidStatus[unit]["hp"]
		if thisHP < lowestHP then
			if not UnitIsDeadOrGhost(unit) and UnitIsVisible(unit) and UnitInRange(unit) then
				lowestHP = thisHP
				lowestUnit = unit
			end
		end
	end

	return lowestUnit
end


-- Find potential tank
function jps.couldBeTank( unit )
	if UnitGroupRolesAssigned(unit) == "TANK" then return true
	elseif jps.buff( "righteous fury",unit ) then return true
	elseif jps.buff( "blood presence",unit ) then return true
	elseif jps.buff( "bear form",unit ) then return true
	end
end

function jps.findMeATank()
	if UnitExists("focus") then return "focus" end

	for unit, _ in pairs(jps.RaidStatus) do
		if jps.couldBeTank( unit ) then return unit end
	end

	return "player"
end

--[[local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellInfo(a)
	return unpack(a)
end]]--

-- Ty to CDO for this code.
hooksecurefunc("UseAction", function(...)
	if jps.Enabled and select(3, ...) ~= nil then
		local stype, id = GetActionInfo( select(1, ...) )
		if stype == "spell" then
			local name,_,_,_,_,_,_,_,_ = GetSpellInfo(id)
			if jps.NextCast ~= name then 
				jps.NextCast = name
				if jps.Combat then write("Set",name,"for next cast.") end
			end
		end
	end
end)

-- BenPhelps' Timer Functions
function jps.createTimer( name, duration )
	jps.Timers[name] = duration+GetTime()
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
