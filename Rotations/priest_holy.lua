-- contains the average value of non critical healing spells
--Written by htordeux  and then updated by GoCarGo

healtable = {}

-- Updates the healtable
function update_healtable(...)
        local temparglist = {...}
        if temparglist[5] == GetUnitName("player") and (temparglist[2] == "SPELL_HEAL" or temparglist[2] == "SPELL_PERIODIC_HEAL") and temparglist[15] == 0 then
          if healtable[temparglist[11]]== nil then
            healtable[temparglist[11]]= {["healtotal"]= temparglist[13],["healcount"]= 1,["averageheal"]= temparglist[13]}
          else
            healtable[temparglist[11]]["healtotal"]= healtable[temparglist[11]]["healtotal"]+temparglist[13];
            healtable[temparglist[11]]["healcount"]= healtable[temparglist[11]]["healcount"]+1;
            healtable[temparglist[11]]["averageheal"]= healtable[temparglist[11]]["healtotal"]/healtable[temparglist[11]]["healcount"];
          end;

  --          print(temparglist[11],"  ",healtable[temparglist[11]]["healtotal"],"  ",healtable[temparglist[11]]["healcount"],"  ",healtable[temparglist[11]]["averageheal"])
        end
end

-- Resets the count of each healing spell to 1 makes sure that the average takes continuously into account changes in stats due to buffs etc

function reset_healtable(self)
  for k,v in pairs(healtable) do
    healtable[k]["healtotal"]= healtable[k]["averageheal"];
    healtable[k]["healcount"]= 1;
  end
end

-- displays the different health values - mainly for tweaking/debugging

function print_healtable(self)
  for k,v in pairs(healtable) do
    print(k,":  ", healtable[k]["healtotal"],"  ", healtable[k]["healcount"],"  ", healtable[k]["averageheal"]);
  end
end

-- returns the average heal value of given spell. Needs to be extended for other classes, but takes into account Echo of Light (1+ GetMastery()* 0.0125) and Divine Touch (increaser) for holy priests

function getaverage_heal(spellname)
  local multiplier = 1
  local increaser = 0
  if spellname == "Renew" then
    if GetRangedHaste() < 12.5 then
      multiplier = 4
      else multiplayer = 5;
    end
    increaser =  getaverage_heal("Divine Touch");
  end

  if healtable[spellname] ~= nil then
    return (healtable[spellname]["averageheal"]+increaser) * (1+ GetMastery()* 0.0125) * multiplier
  else
    return 0
  end
end

function priest_holy(self)

local priest_spell = nil
local playerhealth_deficiency = UnitHealthMax("player")-UnitHealth("player")
local playerhealth_pct = UnitHealth("player") / UnitHealthMax("player")

local Priest_Target = jps.lowestInRaidStatus() 
local health_deficiency = UnitHealthMax(Priest_Target) - UnitHealth(Priest_Target)
local health_pct = UnitHealth(Priest_Target) / UnitHealthMax(Priest_Target)

local stackSerendip = jps.buffStacks("Serendipity","player")

-- counts the number of party members having a significant health loss
	local unitsBelow70 = 0
	local unitsBelow50 = 0
	local unitsBelow30 = 0
	for unit, unitTable in pairs(jps.RaidStatus) do
		--Only check the relevant units
		if not UnitIsDeadOrGhost(unit) and UnitIsVisible(unit) and UnitInRange(unit) and not jps.PlayerIsBlacklisted(unit) then
			local thisHP = jps.hpInc(unit)
			-- Number of people below x%
			if thisHP < 0.3 then unitsBelow30 = unitsBelow30 + 1 end
			if thisHP < 0.5 then unitsBelow50 = unitsBelow50 + 1 end
			if thisHP < 0.7 then unitsBelow70 = unitsBelow70 + 1 end
		end
	end

-- Let's buff --
   if not ub("player", "Inner Fire") then
     priest_spell = "Inner Fire"
     jps.Target = "player" 

   elseif not ub("player", "Power Word: Fortitude") then
     priest_spell = "Power Word: Fortitude"
     jps.Target = "player" 
     
-- Chakra
	elseif cd("Chakra")==0 and not ub("player","Chakra") and not ub("player","Chakra: Serenity") then
		priest_spell = "Chakra"
	elseif ub("player","Chakra") and not ub("player","Chakra: Serenity") then
		if (health_deficiency < getaverage_heal("Flash Heal")) and IsSpellInRange("Heal",Priest_Target)==1 then
		priest_spell = "Heal"
		jps.Target = Priest_Target
		elseif (health_deficiency > getaverage_heal("Flash Heal")) and IsSpellInRange("Heal",Priest_Target)==1 then
		priest_spell = "Flash Heal"
		jps.Target = Priest_Target
		else
		priest_spell = "Heal"
		jps.Target = "player"
		end

   -- Guardian Spirit in case tank is very low on health, guardian spirit will never be cast on dps--
   elseif (health_pct < 0.25) and jps.canCast("Guardian Spirit", Priest_Target) and jps.UseCDs then
      SpellStopCasting()
      priest_spell = "Guardian Spirit"
      jps.Target = Priest_Target 

   -- Cast Desperate Prayer on self in case of trouble--
   elseif cd("Desperate Prayer")==0 and UnitHealth("player")/UnitHealthMax("player") < 0.40 then
      SpellStopCasting()
      priest_spell = "Desperate Prayer"
      jps.Target = "player" 
		
   -- cast fade in case you are being attacked
   elseif UnitThreatSituation("player")==3 and cd("Fade")==0 then
    	priest_spell = "Fade"
		jps.Target = "player"
		
   -- Renew is top priority on targets who have moderate damage
   elseif not ub(Priest_Target,"renew") and jps.canCast("Renew", Priest_Target) and health_deficiency > ((getaverage_heal("Renew")*1.4) + getaverage_heal("Heal")) then
     	priest_spell = "Renew"
		jps.Target = Priest_Target
		
	-- Prayer of mending on tank
	elseif not ub(Priest_Target,"Prayer of Mending") and jps.canCast("Prayer of Mending",Priest_Target)==1 then
		spell = "Prayer of Mending"
		jps.Target = Priest_Target
	
   -- Instant cast flashheal for 0 mana in case surge of light and target is missing enough health to avoid overhealing--
   elseif ub("player", "surge of light") and jps.canCast("Flash Heal", Priest_Target) and health_deficiency > getaverage_heal("Flash Heal") then
      priest_spell = "Flash Heal"
      jps.Target = Priest_Target
      
   -- Cast Holy Word: Serenity - CanCast does not work on this type of spell, so I take renew for IsSpellInRange
   elseif cd(88684)==0 and IsUsableSpell(88684) and IsSpellInRange("Renew",Priest_Target)==1 and health_deficiency > (getaverage_heal("Renew") + getaverage_heal("Heal")) then
      priest_spell = "Holy Word: Serenity"
      jps.Target = Priest_Target
      
   -- Circle of healing in case at least 4 party members require healing --
   elseif unitsBelow70  > 3 and cd("Circle of Healing")==0 and IsUsableSpell("Circle of Healing") then
      	if jps.canCast("Circle of Healing",Priest_Target) then
			spell = "Circle of Healing"
			jps.Target = Priest_Target
		else
			spell = "Circle of Healing"
			jps.Target = "player"
		end

   -- if at least 4 partymembers around you require at least 8k health, cast prayer of healing--
   elseif unitsBelow50  > 3 and cd("Prayer of Healing")==0 and IsUsableSpell("Prayer of Healing") then
		if jps.canCast("Prayer of Healing",Priest_Target) then
			spell = "Prayer of Healing"
			jps.Target = Priest_Target
		else
			spell = "Prayer of Healing"
			jps.Target = "player"
		end

   -- cast flashheal if very high health loss and serendipitystacks < 2  --
   elseif health_pct < 0.50 and stackSerendip < 2 and jps.canCast("Flash Heal", Priest_Target) then
     priest_spell = "Flash Heal"
     jps.Target = Priest_Target

   -- main healing spell when high damage  --
   elseif health_pct < 0.70 and jps.canCast("Greater Heal", Priest_Target)
   and health_deficiency > (getaverage_heal("Greater Heal") + getaverage_heal("Renew")) then
     priest_spell = "Greater Heal"
     jps.Target = Priest_Target

   elseif UnitIsUnit(Priest_Target, "player")~=1 and jps.canCast("Binding Heal", Priest_Target)
   and health_deficiency > (getaverage_heal("Binding Heal") + getaverage_heal("Renew")) and playerhealth_deficiency > (getaverage_heal("Binding Heal") + getaverage_heal("Renew")) then
      priest_spell = "Binding Heal"
      jps.Target = Priest_Target

   -- main heal spell --
   elseif cd("Heal")==0 and jps.canCast("Heal", Priest_Target) and health_deficiency > (getaverage_heal("Heal") + getaverage_heal("Renew")) then
     priest_spell = "Heal"
     jps.Target = Priest_Target
   end

  return priest_spell

end