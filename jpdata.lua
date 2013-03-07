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
-- JPS Helper Functions
-- jpganis

-------------------------------------
-- Lookup TABLES
-- Credit (and thanks!) to BenPhelps
-------------------------------------

-- In order to avoid double casting spells that you sometimes will use but that have no cooldown,
-- we need to maintain an ignore list. For example, when a monk rolls, we shouldn't queue up another roll
-- and take them over the side of a cliff. Or if a mage initiates combat with Living Bomb, etc.
jps.UserInitiatedSpellsToIgnore = {
	"Auto Attack",
	-- Monks Skills
	"Storm, Earth and Fire", -- Stops JPS from despawning your copy as soon as it is created.
  	"Purifying Brew", -- Having more than 1 chi, this can prevent using it twice in a row.
  	"Tigereye Brew",
  	"Detox", -- When casting Detox without any dispellable debuffs, the cooldown resets.
  	"Provoke", -- It can prevent you wasting your taunt in some rare situations.
  	"Disable", -- Gives you a better control on this skill using JPS.
  	"Legacy of the Emperor",
  	"Legacy of the White Tiger",
	"Roll",
	"Chi Torpedo",
	"Flying Serpent Kick",
	"Expel Harm", -- Brewmasters below 35% health have no cooldown on this skill due Desperate Measures.
	"Breath of Fire", -- If you have 4 chi or more, this can kick twice.
	-- Mage Skills
	"Blink",
	"Living Bomb",
	"Nether Tempest",
  	"Ice Lance",
  	"Arcane Brilliance",
  	"Spellsteal",
  	"Remove Curse",
  	-- Druid Skills
  	"Rejuvenation",
  	"Cat Form",
 	"Bear Form",
 	"Treant Form",
  	"Travel Form",
  	"Aquatic Form",
  	"Thrash",
	"Ravage",
 	"Mark of the Wild",
	"Faerie Fire",
  	"Moonfire",
  	"Lifebloom",
  	-- Priest Skills
  	"Power Word: Fortitude",
  	"Shadow Word: Pain",
  	"Mind Flay",
  	"Mind Spike",
  	"Unstable Affliction",
  	"Corruption",
  	"Shadow Bolt",
}

function jps.shouldSpellBeIgnored(spell)
	local result = false
	for _, v in pairs(jps.UserInitiatedSpellsToIgnore) do
	  if spell == v then
	  	-- write("Ignoring", spell, "for next cast.")
	  	result = true
	    break
	  end
	end
	return result
end

jps.Dispells = {
	["Magic"] = {
		"Static Disruption", -- Akil'zon
		"Consuming Darkness", -- Argaloth
		"Emberstrike", -- Erunak Stonespeaker
		"Binding Shadows", -- Erudax
		"Divine Reckoning", -- Temple Guardian Anhuur
		"Static Cling", -- Asaad
		"Pain and Suffering", -- Baron Ashbury
		"Cursed Veil", -- Baron Silverlaine
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
	},
	["Deathwing"] 	= {
		"Plasma incendiaire", -- Boss Debuff 
		"Searing Plasma",
	},
	["Yor'sahj"] 	= {
		"Corruption profonde", -- Boss Debuff 
		"Deep Corruption",
	},
}

jps_DispellOffensive_Eng = {
		"Innervate", -- Druide
		"Power Word: Shield", -- Pretre
		"Ghost Wolf", -- Shaman
		"Power Word: Fortitude", -- Pretre
		"Rejuvenation", -- Druide
		"Regrowth", -- Druide
		"Mark of the Wild", -- Druide
		"Heroism", -- Shaman
		"Bloodlust", -- Shaman
		"Arcane Brilliance", -- Mage
		"Ice Barrier", -- Mage
		"Mage Armor", -- Mage
		"Avenging Wrath", -- Paladin
		"Divine Plea", -- Paladin
}

jps_StunDebuff = {
		"Cyclone", 
		"Cheap Shot", 
		"Kidney Shot", 
		"Bash", 
		"Concussion Blow", 
		"Blind", 
		"Pounce", 
		"Maim", 
		"Fear", 
		"Hammer of Justice", 
		"Hex",
		"Sap", 
		"Psychic Scream",
}

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

function jps.FindMeADispelTarget(dispeltypes)
     for unit, _ in pairs(jps.RaidStatus) do
		if jps.canDispell( unit, dispeltypes ) then return unit end
	end
end

function jps.isStun()
	for i, j in ipairs(jps_StunDebuff) do
		if UnitDebuff("player",j) then return true end
	end
	return false
end

--------------------------
-- Dispell Functions LOOP
--------------------------

function jps.MagicDispell(unit) 
	if not unit then unit = "player" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
	if jps.canHeal(unit) then 
		while auraName do
			if debuffType=="Magic" then 
			return true end
			i = i + 1
			auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
		end
	end
	return false
end

function jps.DiseaseDispell(unit) 
	if not unit then unit = "player" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
	if jps.canHeal(unit) then 
		while auraName do
			if debuffType=="Disease" then 
			return true end
			i = i + 1
			auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
		end
	end
	return false
end

function jps.DispelMagicTarget()
	for unit,_ in pairs(jps.RaidStatus) do	 
		if jps.MagicDispell(unit) then return unit end
	end
end 

function jps.DispelDiseaseTarget()
	for unit,_ in pairs(jps.RaidStatus) do	 
		if jps.DiseaseDispell(unit) then return unit end
	end
end 

function jps.canDispellOffensive(unit)
if not unit then return false end
local i = 1
local auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitBuff(unit, i)
	if UnitExists(unit)==1 and UnitIsEnemy("player",unit)==1 and UnitCanAttack("player", unit)==1 then
		while auraName do
			for k, j in ipairs(jps_DispellOffensive_Eng) do
			   if auraName==j and debuffType=="Magic" then
			   return true end
			end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitBuff(unit, i)
		end
	end
	return false
end

--------------------------
-- Functions
--------------------------

function jps.Cast(spell)
	if not jps.Target then
    jps.Target = "target"
  end
  
	if not jps.Casting then
    jps.LastCast = spell
  end
	
  if(getSpellStatus(spell) == 0) then return false end
	if(jps.cooldownNoLag(spell) ~= 0) then return false end
	
	CastSpellByName(spell,jps.Target)
	jps.LastTarget = jps.Target
	if jps.IconSpell ~= spell then
		jps.set_jps_icon( spell )
		if jps.Debug then write(spell, jps.Target) end
	end
	jps.Target = nil
end

function jps.cooldown(spell)
	local start,duration,_ = GetSpellCooldown(spell)
	if start == nil then return 0 end
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.cooldownNoLag(spell)
	local start,duration,_ = GetSpellCooldown(spell)
	if start == nil then return 0 end
	local cd = start+duration-GetTime()
	if cd < 0 then return 0 end
	return cd
end

-- Shorthand
jps.cd = jps.cooldown

function jps.itemCooldown(item)
	local start,duration,_ = GetItemCooldown(item)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.glovesCooldown()
	local start, duration, enabled = GetInventoryItemCooldown("player", 10)
	if enabled==0 then return 9001 end
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

--------------------------
-- BUFF DEBUFF
--------------------------

function jps_findBuffDebuff()
	for i=1,40 do 
		local ID = select(11,UnitBuff("player",i))
		local Name= select(1,UnitBuff("player",i))
		if ID then print("|cff1eff00Buff",i.."="..ID,"="..Name) end 
	end

	for i=1,40 do 
		local ID = select(11,UnitDebuff("target",i))
		local Name= select(1,UnitDebuff("target",i))
		if ID then print("|cFFFF0000Debuff",i.."="..ID,"="..Name) end 
	end
end

function jps.buffID( spellID, unit )
	if unit == nil then unit = "player" end
	local i = 1 
	while( i <= 40 ) do
		local ID = select(11, UnitBuff(unit, i) )
		if ID == spellID then return true end
	i = i + 1
	end
	return false
end

function jps.debuffID( spellID, unit )
	if unit == nil then unit = "target" end
	local i = 1 
	while( i <= 40 ) do
		local ID = select(11, UnitDebuff(unit, i) )
		if ID == spellID then return true end
	i = i + 1
	end
	return false
end

function jps.myDebuffID( spellID, unit )
	if unit == nil then unit = "target" end
	local i = 1 
	while( i <= 40 ) do
		local ID = select(11, UnitDebuff(unit, i) )
		local caster = select(8, UnitDebuff(unit, i) )
		if ID == spellID and caster == "player" then return true end
	i = i + 1
	end
	return false
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

function jps.myDebuff( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,expire,caster,_,_,_ = UnitDebuff(unit,spell)
	if caster~="player" then return false end
	return jps.debuff( spell, unit )
end

function jps.buffDuration( spell, unit )
	if unit == nil then unit = "player" end
	local expire = select(7,UnitBuff(unit,spell))
	local caster = select(8,UnitBuff(unit,spell))
	if caster ~= "player" then return 0 end
	if expire == nil then return 0 end
	local duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmyBuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,expire,_,_,_,_ = UnitBuff(unit,spell)
	if expire == nil then return 0 end
	local duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local expire = select(7,UnitDebuff(unit,spell))
	local caster = select(8,UnitDebuff(unit,spell))
	if caster~="player" then return 0 end
	if expire==nil then return 0 end
	local duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmyDebuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,expire,caster,_,_ = UnitDebuff(unit,spell)
	if expire==nil then return 0 end
	local duration = expire-GetTime()-jps.Lag
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

function jps.buffStacksID( spellID, unit )
	if unit == nil then unit = "player" end
	local i = 1 
	while( i <= 40 ) do
		local ID = select(11, UnitBuff(unit, i) )
		local count = select(4, UnitBuff(unit, i) )
		if ID == spellID then 
			if count == nil then count = 0 end
			return count
		end
	i = i + 1
	end
	return 0
end

function jps.buffStacks( spell, unit )
	if unit == nil then unit = "player" end
	local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spell)
	if count == nil then count = 0 end
	return count
end

-- /run print(jps.getIgniteAmount())
function jps.getIgniteAmount()
  -- Ignite ID is hardcoded, not sure if there's an alternative.
  local igniteSpell = GetSpellInfo(12654)
    
	buffName, buffRank, buffTexture, buffApplications, school, duration, timeLeft, unitCaster, buffId, isStealable, shouldConsolidate, spellID, canApplyAura, _, igniteAmount = UnitDebuff("target", igniteSpell, nil, "PLAYER");

  return igniteAmount;
end

function jps.bloodlusting()
	return jps.buff("bloodlust") or jps.buff("heroism") or jps.buff("time warp") or jps.buff("ancient hysteria")
end

function jps.castTimeLeft(unit)
	if unit == nil then unit = "player" end
	local _,_,_,_,_,endTime,_,_,_ = UnitCastingInfo(unit)
	if endTime == nil then return 0 end
	return (endTime-GetTime()*1000)/1000
end

function jps.shouldKick(unit)
	if unit == nil then unit = "target" end
    local target_spell, _, _, _, _, endTime, _, _, unInterruptable = UnitCastingInfo(unit)
	local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
	if target_spell == "Release Aberrations" then return false end

	if target_spell and unInterruptable == false then
		return true
		--if not jps.PvP then return true 
		--else return endTime-GetTime()*1000 < 333+jps.Lag end

	elseif channelling and notInterruptible == false then
		return true

	end 
	return false
end

------------------------------
-- HEALTH Functions
------------------------------

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
		return (UnitHealth(unit) + hpInc)/UnitHealthMax(unit)
	end
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

function jps.targetTargetTank()
	if jps.buff("bear form","targettarget") then return true end
	if jps.buff("blood presence","targettarget") then return true end
	if jps.buff("righteous fury","targettarget") then return true end
	
	local _,_,_,_,_,_,_,caster,_,_ = UnitDebuff("target","Sunder Armor")
	if caster ~= nil then
		if UnitName("targettarget") == caster then return true end end
	
	return false
end

--PLua 
function jps.groundClick()
	RunMacroText("/console deselectOnClick 0")
	CameraOrSelectOrMoveStart()
	CameraOrSelectOrMoveStop()
	RunMacroText("/console deselectOnClick 1")
end

function jps.faceTarget()
	InteractUnit("target")
end

function jps.moveToTarget()
	InteractUnit("target")
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

function jps_CalcThreat(unit)
    local y
        if UnitExists(unit.."target") and UnitIsEnemy(unit, unit.."target") then 
            y = UnitThreatSituation(unit, unit.."target")
        elseif UnitExists("playertarget") and UnitIsEnemy("player", "playertarget") then 
            y = UnitThreatSituation(unit, "playertarget")
        else
            y = UnitThreatSituation(unit)
        end
        
        if not y then y=0 end
    return y
end

function jps.findMeAggroTank()
	for unit, _ in pairs(jps.RaidStatus) do
		if jps_CalcThreat(unit) == 3  then return unit end
	end
	return "player"
end
------------------------------
-- Timer Functions
------------------------------
function jps.resetTimer( name )
	jps.Timers[name] = nil
end

function jps.createTimer( name, duration )
	if duration == nil then duration = 60 end -- 1 min
	jps.Timers[name] = duration + GetTime()
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

-- For trinket's. Pass 1 or 2 for the number.
function jps.useTrinket(trinketNum)
  -- THe index actually starts at 0, so subtract one.
  local slotName = "Trinket"..(trinketNum - 1).."Slot"
  -- Get the slot number
	local slotNum = GetInventorySlotInfo(slotName)
  return jps.useSlot(slotNum)
end

-- Engineers will use synapse springs buff on their gloves
function jps.useSynapseSprings()
  -- Get the slot number
  local slotNum = GetInventorySlotInfo("HandsSlot")
  return jps.useSlot(slotNum)
end

function jps.useSlot(num)
  -- Get the item identifier
	local itemId = GetInventoryItemID("player", num)
	if not itemId then return nil end
	
  -- Check if it's on cool down
  if jps.itemCooldown(itemId) > 0 then return nil end

  -- Check if it's usable
	local isUsable = GetItemSpell(itemId)
	if not isUsable then return nil end

  -- Use it
  return { "macro", "/use "..num }
end
