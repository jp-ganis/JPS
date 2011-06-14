function warrior_fury(self)
   local spell = nil
   local playerHealth = UnitHealth("player")/UnitHealthMax("player")
   local targetHealth = UnitHealth("target")/UnitHealthMax("target")
   local nSang = UnitBuff("player","Bloodsurge")
   local nEnrage = UnitBuff("player","Enrager")
   local nRage = UnitBuff("player","Berserker Rage")
   local nVict = UnitBuff("player","Victorious")
   local nPower = UnitPower("Player",1) -- Rage est PowerType 1

	 if not (IsSpellInRange("bloodthirst","target") == 1) then return nil end

   if cd("Battle Shout")==0 and not ub("player","Battle Shout") and not ub("player","Roar of Courage") and not ub("player","Horn of Winter") and not ub("player","Strength of earth totem") then
      spell = "Battle Shout"
   elseif cd("Battle Shout")==0 and nPower<10 then
      spell = "Battle Shout"
   elseif cd("Berserker Rage")==0 and not ub("player","Berserker Rage") then
      spell = "Berserker Rage"
   elseif cd("Pummel")==0 and IsSpellInRange("Pummel","target")==1 and jps.ShouldKick("target") then
      spell = "Pummel"
   elseif nVict~=nil then 
      spell = "Victory Rush"
   elseif cd("Enraged Regeneration")==0 and playerHealth<0.50 and nEnrage then
      spell = "Enraged Regeneration"
   elseif cd("Execute")==0 and targetHealth<0.2 then 
      spell = "Execute"
   elseif cd("Colossus Smash")==0 then 
      spell = "Colossus Smash"
   elseif cd("Death Wish")==0 and nPower>50 then 
      spell = "Death Wish"
   elseif cd("Heroic Throw")==0 then 
      spell = "Heroic Throw"
   elseif cd("Heroic Strike")==0 and nPower>50 then
      spell = "Heroic Strike"
   elseif cd("Cleave")==0 then 
      spell = "Cleave"
   elseif cd("Lifeblood")==0 then 
      spell = "Lifeblood"
   elseif cd("Slam")==0 and nSang~=nil then
      spell = "Slam"
   elseif cd("Raging Blow")==0 and (nEnrage~=nil or nRage~=nil) then
      spell = "Raging Blow"
   elseif cd("Bloodthirst")==0 then 
      spell = "Bloodthirst"
   end
   return spell
end
