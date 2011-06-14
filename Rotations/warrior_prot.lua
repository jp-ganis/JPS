function warrior_prot(self)

   local spell = nil
   local playerHealth = UnitHealth("player")/UnitHealthMax("player")
   local targetHealth = UnitHealth("target")/UnitHealthMax("target")
   local nSang = UnitBuff("player","Bloodsurge")
   local nEnrage = UnitBuff("player","Enrage")
   local nRage = UnitBuff("player","Berserker Rage")
   local nVict = UnitBuff("player","Victorious")
   local nPower = UnitPower("Player",1) -- Rage est PowerType 1
   local nEmul = UnitBuff("player","Incite");
   local nThunder,_,_,stackThunder = UnitBuff("player","Thunderstruck");
   local nSunder,_,_,stackSunder = UnitDebuff("target","Sunder Armor");

   if cd("Battle Shout")==0 and not ub("player","Battle Shout") and IsUsableSpell("Battle Shout") then
      spell="Battle Shout"
   elseif cd("Berserker Rage")==0 and not ub("player","Berserker Rage") and IsUsableSpell("Berserker Rage") then
      spell="Berserker Rage"
   elseif UnitHealth('player')<30000 and cd("Shield Wall")==0 then
      spell="Shield Wall"
   elseif UnitHealth('player')<30000 and cd("Last Stand")==0 then
      spell="Last Stand"
   elseif cd("Charge")==0 and IsSpellInRange("Charge", "target")==1 and IsUsableSpell("Charge") then 
      spell="Charge"
   elseif cd("Heroic Throw")==0 and IsUsableSpell("Heroic Throw") then 
      spell="Heroic Throw"
   elseif nVict~=nil and IsUsableSpell("Victory Rush") then 
      spell="Victory Rush"
   elseif nSunder==nil and cd("Devastate")== 0 and IsSpellInRange("Devastate","target")==1 and IsUsableSpell("Devastate") then
      spell="Devastate"
   elseif nSunder~=nil and stackSunder<3 and cd("Devastate")== 0 and IsSpellInRange("Devastate","target")==1 and IsUsableSpell("Devastate") then
      spell="Devastate"
   elseif cd("Shield Slam")== 0 and ub("player","Sword and Board") and IsSpellInRange("Shield Slam", "target")==1 and IsUsableSpell("Shield Slam") then 
      spell="Shield Slam"
   elseif cd("Pummel")== 0 and (UnitCastingInfo("target") or UnitChannelInfo("target")) and IsSpellInRange("Pummel","target")==1 and IsUsableSpell("Pummel") then 
      spell="Pummel"
   elseif cd("Shield Block")== 0 and IsUsableSpell("Shield Block") then
      spell="Shield Block"
   elseif cd("Enraged Regeneration") and playerHealth<0.60 and IsUsableSpell("Enraged Regeneration") and nEnrage then
      spell="Enraged Regeneration"
   elseif cd("Revenge")== 0 and IsSpellInRange("Revenge", "target")==1 and IsUsableSpell("Revenge") then
      spell="Revenge"
   elseif cd("Thunder Clap")== 0 and nThunder==nil and IsUsableSpell("Thunder Clap") then 
      spell="Thunder Clap"
   elseif cd("Shockwave")== 0 and nThunder~=nil and IsUsableSpell("Shockwave") then 
      spell="Shockwave"
   elseif cd("Heroic Strike")==0 and nEmul~=nil and IsSpellInRange("Heroic Strike", "target")==1 and IsUsableSpell("Heroic Strike") then
      spell="Heroic Strike"
      print("Heroic Strike - Incite");
   elseif cd("Heroic Strike")==0 and nPower>50 and IsSpellInRange("Heroic Strike", "target")==1 and IsUsableSpell("Heroic Strike") then
      spell="Heroic Strike"
   elseif cd("Lifeblood")==0 and IsUsableSpell("Lifeblood") then 
      spell="Lifeblood"
   elseif cd("Concussion Blow")== 0 and IsSpellInRange("Concussion Blow","target")==1 and IsUsableSpell("Concussion Blow") then 
      spell="Concussion Blow"
   elseif cd("Devastate")==0 and IsSpellInRange("Devastate","target")==1 and IsUsableSpell("Devastate") then
      spell="Devastate"
   elseif cd("Rend") and not UnitDebuff("target","Rend") and IsSpellInRange("Rend","target")==1 and IsUsableSpell("Rend") then 
      spell="Rend"
   end
   cast(spell)
   print(spell)

end
