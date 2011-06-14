-- Lookup Tables
-- Specs
jps.Specs = {
	["Death Knight"] = {[1] = "Blood", [2] = "Frost", [3] = "Unholy"},
	["Druid"] = {[1] = "Balance", [2] = "Feral", [3] = "Restoration"},
	["Warlock"] = {[1] = "Affliction", [2] = "Demonology", [3] = "Destruction"},
	["Priest"] = {[1] = "Discipline", [2] = "Holy", [3] = "Shadow"},
	["Warrior"] = {[1] = "Arms", [2] = "Fury", [3] = "Protection"},
	["Paladin"] = {[1] = "Holy", [2] = "Protection", [3] = "Retribution"},
	["Shaman"] = {[1] = "Elemental", [2] = "Enhancement", [3] = "Restoration"},
	["Rogue"] = {[1] = "Assassination", [2] = "Combat", [3] = "Subtlety"},
	["Hunter"] = {[1] = "Beast Mastery", [2] = "Marksmanship", [3] = "Survival"},
	["Mage"] = {[1] = "Arcane", [2] = "Fire", [3] = "Frost"},
}

-- Functions
function jps.Cast(spell)
	if not jps.Target then jps.Target = "target" end
	if not jps.Casting then jps.LastCast = spell end
	CastSpellByName(spell,jps.Target)	
	jps.Target = "target"
	if jps.IconSpell ~= spell then
		jps.set_jps_icon(spell)
		if jps.Debug then	print(spell, jps.Target) end
	end
end


function jps.get_cooldown(spell)
	local start,duration,_ = GetSpellCooldown(spell)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.buff_duration(unit,spell)
	local _,_,_,_,_,_,duration,_,_,_,_ = UnitBuff(unit,spell)
	if duration == nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuff_duration(unit,spell)
	local _,_,_,_,_,_,duration,_,_,_,_ = UnitDebuff(unit,spell)
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.set_jps_icon(spell)
	local _, _, icon, _, _, _, _, _, _ = GetSpellInfo(spell)
	IconFrame:SetBackdrop( {
		bgFile = icon,
		edgeFile = "Interface\DialogFrame\UI-DialogBox-Border", tile = true, tileSize = 41, edgeSize = 13,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	jps.IconSpell = spell
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

function jps.should_kick(unit)
	local target_spell, _, _, _, _, endTime, _, _, unInterruptable = UnitCastingInfo(unit)
  local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)

  if target_spell and not unInterruptable then
    endTime = endTime - GetTime()*1000
    if endTime < 500+jps.Lag then
      return true
    end 
  elseif chanelling and not notInterruptible then
    return true
  end 

	return false
end

-- walkistalki healing functions
jps.HealValues = {}

function jps.update_healtable(...)
	local temparglist = {...}
	if temparglist[5] == GetUnitName("player") and (temparglist[2] == "SPELL_HEAL" or temparglist[2] == "SPELL_PERIODIC_HEAL") and temparglist[15] == 0 then
		if jps.HealValues[temparglist[11]]== nil then
			jps.HealValues[temparglist[11]]= {["healtotal"]= temparglist[13],["healcount"]= 1,["averageheal"]= temparglist[13]}
		else
			jps.HealValues[temparglist[11]]["healtotal"]= jps.HealValues[temparglist[11]]["healtotal"]+temparglist[13]
			jps.HealValues[temparglist[11]]["healcount"]= jps.HealValues[temparglist[11]]["healcount"]+1
			jps.HealValues[temparglist[11]]["averageheal"]= jps.HealValues[temparglist[11]]["healtotal"]/jps.HealValues[temparglist[11]]["healcount"]
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
      if jps.OutOfSightPlayers[i][1] ==  playerName then
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
