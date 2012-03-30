-- contains the average value of non critical healing spells

healtable = {}

-- Updates the healtable
function update_healtable(...)
        local temparglist = {}
        if temparglist[5] == GetUnitName("player") and (temparglist[2] == "SPELL_HEAL" or temparglist[2] == "SPELL_PERIODIC_HEAL") and temparglist[15] == 0 then
          if healtable[temparglist[11]]== nil then
            healtable[temparglist[11]]= {["healtotal"]= temparglist[13],["healcount"]= 1,["averageheal"]= temparglist[13]}
          else
            healtable[temparglist[11]]["healtotal"]= healtable[temparglist[11]]["healtotal"]+temparglist[13];
            healtable[temparglist[11]]["healcount"]= healtable[temparglist[11]]["healcount"]+1;
            healtable[temparglist[11]]["averageheal"]= healtable[temparglist[11]]["healtotal"]/healtable[temparglist[11]]["healcount"];
          end

-- print(temparglist[11],"  ",healtable[temparglist[11]]["healtotal"],"  ",healtable[temparglist[11]]["healcount"],"  ",healtable[temparglist[11]]["averageheal"])
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
		if jps.canHeal(unit) then
			local thisHP = jps.hpInc(unit)
			-- Number of people below x%
			if thisHP < 0.3 then unitsBelow30 = unitsBelow30 + 1 end
			if thisHP < 0.5 then unitsBelow50 = unitsBelow50 + 1 end
			if thisHP < 0.7 then unitsBelow70 = unitsBelow70 + 1 end
		end
	end

------------------------
-- SPELL TABLE ---------
------------------------

local spellTable =
{
    { "Inner Fire", not ub("player", "Inner Fire") , "player" },
    { "Power Word: Fortitude", not ub("player", "Power Word: Fortitude") , "player" },
    { "Chakra", not ub("player","Chakra") and not ub("player","Chakra: Serenity"), "player" },
    { "nested", ub("player","Chakra") and not ub("player","Chakra: Serenity") , "player" },
        {
            { "Heal", health_deficiency < getaverage_heal("Flash Heal"), Priest_Target },
            { "Flash Heal", health_deficiency > getaverage_heal("Flash Heal"), Priest_Target },
            { "Heal", "onCD", "player" },
        },
    { "Guardian Spirit", health_pct < 0.25 , Priest_Target }, --SpellStopCasting()
    { "Desperate Prayer", UnitHealth("player")/UnitHealthMax("player") < 0.40 , "player" }, -- SpellStopCasting()
    { "Fade", UnitThreatSituation("player")==3, "player" },
    { "Renew", not ub(Priest_Target,"renew") and health_deficiency > (getaverage_heal("Renew") + getaverage_heal("Heal")), Priest_Target },
    { "Prayer of Mending", not ub(Priest_Target,"Prayer of Mending"), Priest_Target },
    { "Flash Heal", ub("player", "surge of light") and health_deficiency > getaverage_heal("Flash Heal"), Priest_Target },
    { "Holy Word: Serenity", health_deficiency > (getaverage_heal("Renew") + getaverage_heal("Heal")), Priest_Target },
    { "Flash Heal", health_pct < 0.50 and stackSerendip < 2, Priest_Target },
    { "Greater Heal", health_pct < 0.70 and health_deficiency > (getaverage_heal("Greater Heal") + getaverage_heal("Renew")), Priest_Target },
    { "Binding Heal", UnitIsUnit(Priest_Target, "player")~=1 and health_deficiency > (getaverage_heal("Binding Heal") + getaverage_heal("Renew")) and playerhealth_deficiency > (getaverage_heal("Binding Heal") + getaverage_heal("Renew")), Priest_Target },
    { "Circle of Healing", unitsBelow70  > 3, Priest_Target },
    { "Circle of Healing", unitsBelow70  > 3, "player" },
    { "Prayer of Healing", unitsBelow50  > 3, "player" },
    { "Prayer of Healing", unitsBelow50  > 3, Priest_Target },
    { "Heal", health_deficiency > (getaverage_heal("Heal") + getaverage_heal("Renew")), Priest_Target }
}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
end
