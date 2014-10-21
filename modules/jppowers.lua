--[[[
@module Functions: Unit health & powers
@description
Functions which handle unit health, unit powers
]]--

local L = MyLocalizationTable


------------------------------
-- HEALTH Functions
------------------------------
--[[[
@function jps.hp
@description 
get unit's hp left as percentage( decimal format: 0.80, 0.50...)
[br][i]Usage:[/i][br]
[code]
jps.hp("target")

[/code]
@param unit: UnitID

@returns float
]]--
function jps.hp(unit,message)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	if message == "abs" then
		return UnitHealthMax(unit) - UnitHealth(unit)
	else
		return UnitHealth(unit) / UnitHealthMax(unit)
	end
end

--[[[
@function jps.hpTotal
@description 
get unit's hp as integer
[br][i]Usage:[/i][br]
[code]
jps.hpTotal("target")

[/code]
@param unit: UnitID

@returns int: current hp as value
]]--
function jps.hpTotal(unit)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	return UnitHealth(unit)
end


function jps.hpInc(unit,message)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	local hpInc = UnitGetIncomingHeals(unit)
	if not hpInc then hpInc = 0 end
	if message == "abs" then
		return UnitHealthMax(unit) - (UnitHealth(unit) + hpInc)
	else
		return (UnitHealth(unit) + hpInc)/UnitHealthMax(unit)
	end
end

function jps.hpAbs(unit,message)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	local hpInc = UnitGetIncomingHeals(unit)
	if not hpInc then hpInc = 0 end
	local hpAbs = UnitGetTotalAbsorbs(unit)
	if not hpAbs then hpAbs = 0 end
	if message == "abs" then
		return UnitHealthMax(unit) - (UnitHealth(unit) + hpInc + hpAbs)
	else
		return (UnitHealth(unit) + hpInc + hpAbs)/UnitHealthMax(unit)
	end
end
--[[[
@function jps.rage
@description 
returns players rage
[br][i]Usage:[/i][br]
[code]
jps.rage()

[/code]

@returns int: current rage
]]--
function jps.rage()
	return UnitPower("player",1)
end
--[[[
@function jps.energy
@description 
returns players energy
[br][i]Usage:[/i][br]
[code]
jps.energy()

[/code]

@returns int: current energy
]]--
function jps.energy()
	return UnitPower("player",3)
end
--[[[
@function jps.focus
@description 
returns players focus
[br][i]Usage:[/i][br]
[code]
jps.focus()

[/code]

@returns int: current focus
]]--
function jps.focus()
	return UnitPower("player",2)
end
--[[[
@function jps.runicPower
@description 
returns players runic Power
[br][i]Usage:[/i][br]
[code]
jps.runicPower()

[/code]

@returns int: current runic power
]]--
function jps.runicPower()
	return UnitPower("player",6)
end
--[[[
@function jps.soulShards
@description 
returns players soulShards
[br][i]Usage:[/i][br]
[code]
jps.soulShards()

[/code]

@returns int: current soul shards
]]--
function jps.soulShards()
	return UnitPower("player",7)
end
--[[[
@function jps.eclipsePower
@description 
returns players eclipser Power
[br][i]Usage:[/i][br]
[code]
jps.eclipsePower()

[/code]

@returns int: current eclipse Power
]]--
function jps.eclipsePower()
	return UnitPower("player",8)
end
--[[[
@function jps.chi
@description 
returns players chi
[br][i]Usage:[/i][br]
[code]
jps.chi()

[/code]

@returns int: current chi
]]--
function jps.chi()
	return UnitPower("player", 12)
end
--[[[
@function jps.holyPower
@description 
returns players holy power
[br][i]Usage:[/i][br]
[code]
jps.holy Power()

[/code]

@returns int: current holy Power
]]--
function jps.holyPower()
	return UnitPower("player",9)
end
--[[[
@function jps.shadowOrbs
@description 
returns players shadow orbs
[br][i]Usage:[/i][br]
[code]
jps.rage()

[/code]

@returns int: current shadow orbs
]]--
function jps.shadowOrbs()
	return UnitPower("player",13)
end
--[[[
@function jps.burningEmbers
@description 
returns players burning emvers
[br][i]Usage:[/i][br]
[code]
jps.burningEmbers()

[/code]

@returns int: current burning embers
]]--
function jps.burningEmbers()
	return UnitPower("player",14)
end
--[[[
@function jps.emberShards
@description 
returns players emberShards
[br][i]Usage:[/i][br]
[code]
jps.emberShards()

[/code]

@returns int: current ember shards
]]--
function jps.emberShards()
	return UnitPower("player",14, true)
end
--[[[
@function jps.demonicFury
@description 
returns players demonic fury
[br][i]Usage:[/i][br]
[code]
jps.demonicFury()

[/code]

@returns int: current demonic fury
]]--
function jps.demonicFury()
	return UnitPower("player",15)
end
--[[[
@function jps.mana
@description 
returns unit''s mana as percentage (float) or as a value(int)
[br][i]Usage:[/i][br]
[code]
jps.mana("unit")[br]
jps.mana("unit","abs") -- for current mana value

[/code]

@returns float: current mana percentage
@returns int: current mana value
]]--
function jps.mana(unit,message)
	if unit == nil then unit = "player" end
	if message == "abs" or message == "absolute" then
		return UnitMana(unit)
	else
		return UnitMana(unit)/UnitManaMax(unit)
	end
end