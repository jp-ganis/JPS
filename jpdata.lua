-- Lookup Tables
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
	jps.Target = "target"
	if jps.IconSpell ~= spell then
		jps.set_jps_icon(spell)
		if jps.Debug then print(spell, jps.Target) end
	end
end

function jps.can_cast(spell, unit)
	if UnitExists(unit) and UnitIsVisible(unit) and UnitIsFriend("player",unit) then
		if IsSpellInRange(spell, unit) then return 1 end
	end
	return 0
end

function jps.can_dispell( unit, ... )
	for _, dtype in pairs(...) do
		if jps.Dispells[dtype] ~= nil then
			for _, spell in pairs(jps.Dispells[dtype]) do
				if ud( unit, spell ) then return 1 end
			end
		end
	end
	return 0
end

function jps.get_cooldown(spell)
	local start,duration,_ = GetSpellCooldown(spell)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.get_pet_cooldown(index)
	local start,duration,_ = GetPetActionCooldown(index)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.buff( spell, unit )
	if unit == nil then unit = "player" end
	local buff,_,_,_,_,_,_,_,_,_,_ = UnitBuff(unit, spell)
	if buff ~= nil then return 1 end
	return 0
end

function jps.buff_duration(unit,spell)
	local _,_,_,_,_,_,expire,caster,_,_,_ = UnitBuff(unit,spell)
	if caster ~= "player" then return 0 end
	if expire == nil then return 0 end
	duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmybuff_duration(unit,spell)
	local _,_,_,_,_,_,expire,_,_,_,_ = UnitBuff(unit,spell)
	if expire == nil then return 0 end
	duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuff_duration(unit,spell)
	local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spell)
	if caster~="player" then return 0 end
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmydebuff_duration(unit,spell)
	local _,_,_,_,_,_,duration,_,caster,_,_ = UnitDebuff(unit,spell)
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.get_debuff_stacks(unit,spell)	
	local _, _, _, count, _, _, _, _, _ = UnitDebuff(unit,spell)
	if count == nil then count = 0 end
	return count
end

function jps.get_buff_stacks(unit,spell)	
	local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spell)
	if count == nil then count = 0 end
	return count
end

function jps.should_pvpkick(unit)
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

function jps.should_kick(unit)
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

function jps.create_timer( name, duration )
	jps.Timers[name] = duration+GetTime()
end

function jps.check_timer( name )
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

-- walkistalki healing functions
jps.HealValues = {}

function jps.update_healtable(...)
	local temparglist = {...}
	if temparglist[5] == GetUnitName("player") and (temparglist[2] == "SPELL_HEAL" or temparglist[2] == "SPELL_PERIODIC_HEAL") and temparglist[15] == 0 then
		if jps.HealValues[temparglist[11]] == nil then
			jps.HealValues[temparglist[11]] = {["healtotal"] = temparglist[13],["healcount"] = 1, ["averageheal"] = temparglist[13]}
		else
			jps.HealValues[temparglist[11]]["healtotal"]   = jps.HealValues[temparglist[11]]["healtotal"] + temparglist[13]
			jps.HealValues[temparglist[11]]["healcount"]   = jps.HealValues[temparglist[11]]["healcount"] + 1
			jps.HealValues[temparglist[11]]["averageheal"] = jps.HealValues[temparglist[11]]["healtotal"] / jps.HealValues[temparglist[11]]["healcount"]
		end
	end
end

function jps.reset_healtable(self)
	for k,v in pairs(healtable) do
		jps.HealValues[k]["healtotal"]= jps.HealValues[k]["averageheal"]
		jps.HealValues[k]["healcount"]= 1
	end
end

function jps.getaverage_heal(spellname)
	if jps.HealValues[spellname] ~= nil then
		return jps.HealValues[spellname]["averageheal"]
	else
		return 0
	end
end

function jps.UpdateOutOfSightPlayers(self)
   if #jps.OutOfSightPlayers > 0 then
	  for i = #jps.OutOfSightPlayers, 1, -1 do
		 if GetTime() - jps.OutOfSightPlayers[i][2] > 2 then
			table.remove(jps.OutOfSightPlayers,i)
		 end
	  end
   end
end

function jps.PlayerIsExcluded(playerName)
	for i = 1, #jps.OutOfSightPlayers do
		if jps.OutOfSightPlayers[i][1] ==	 playerName then
			return true
		end
	end
	return false
end

function jps.ExcludePlayer(playername)
	if playername == nil then
		playername = "nil"
	end
	local playerexclude = {}
	table.insert(playerexclude, playername)
	table.insert(playerexclude, GetTime())
	table.insert(jps.OutOfSightPlayers,playerexclude)
end
