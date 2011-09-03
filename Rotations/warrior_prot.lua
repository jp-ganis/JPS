function warrior_prot(self)

local spell = nil
local playerHealth = UnitHealth("player")/UnitHealthMax("player")
local targetHealth = UnitHealth("target")/UnitHealthMax("target")
local nEnrage = UnitBuff("player","Enrage")
local nRage = UnitBuff("player","Berserker Rage")
local nPower = UnitPower("Player",1) -- Rage est PowerType 1
local stackSunder = jps.debuffStacks("Sunder Armor")
local stackThunder = jps.buffStacks("Thunderstruck")
   
if UnitCanAttack("player","target") then
	if cd("Battle Shout")==0 and not ub("player","Battle Shout") and IsUsableSpell("Battle Shout") then
      	spell="Battle Shout"
	elseif cd("Berserker Rage")==0 and not ub("player","Berserker Rage") and IsUsableSpell("Berserker Rage") then
      	spell="Berserker Rage"
	elseif UnitHealth('player')<30000 and cd("Shield Wall")==0 then
      	spell="Shield Wall"
	elseif UnitHealth('player')<30000 and cd("Last Stand")==0 then
      	spell="Last Stand"
	elseif playerHealth<0.60 and cd("Enraged Regeneration") and IsUsableSpell("Enraged Regeneration") and nEnrage then
      	spell="Enraged Regeneration"
	elseif playerHealth<0.60 and cd("Shield Block")== 0 and IsUsableSpell("Shield Block") then
      	spell="Shield Block"
   	elseif IsMouseButtonDown(3) and cd("Charge")==0 and IsSpellInRange("Charge", "target")==1 and IsUsableSpell("Charge") then 
      	spell="Charge"
    elseif cd("Heroic Throw")==0 and IsUsableSpell("Heroic Throw") then 
      	spell="Heroic Throw"
	-- Taunt sometimes must be set manually
	--elseif UnitThreatSituation("player")==2 and cd("Taunt")==0 and IsUsableSpell("Taunt") then
	--	spell= "Taunt"
   	elseif cd("Pummel")== 0 and IsSpellInRange("Pummel","target")==1 and IsUsableSpell("Pummel") and jps.shouldKick("target") then 
      	spell="Pummel"
	elseif (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("Spell Reflection")==0 and  IsUsableSpell("Spell Reflection") then
		spell= "Spell Reflection"
   	elseif ub("player","Victorious") and IsUsableSpell("Victory Rush") then 
      	spell="Victory Rush"
	elseif not ud("target","Sunder Armor") and cd("Devastate")== 0 and IsSpellInRange("Devastate","target")==1 and IsUsableSpell("Devastate") then
		spell="Devastate"
   	elseif cd("Shield Slam")== 0 and IsSpellInRange("Shield Slam", "target")==1 and IsUsableSpell("Shield Slam") then 
      	spell="Shield Slam"
   	elseif stackSunder<3 and cd("Devastate")== 0 and IsSpellInRange("Devastate","target")==1 and IsUsableSpell("Devastate") then
      	spell="Devastate"
   	elseif ub("player","Sword and Board") and cd("Devastate")== 0 and IsSpellInRange("Devastate","target")==1 and IsUsableSpell("Devastate") then
      	spell="Devastate"
   	elseif cd("Revenge")== 0 and IsSpellInRange("Revenge", "target")==1 and IsUsableSpell("Revenge") then
      	spell="Revenge"
	elseif IsMouseButtonDown(2) and cd("Shockwave")== 0 and stackThunder>1 and IsUsableSpell("Shockwave") then 
      	spell="Shockwave"
	elseif IsMouseButtonDown(2) and cd("Thunder Clap")== 0 and IsUsableSpell("Thunder Clap") then 
      	spell="Thunder Clap"
   	elseif cd("Lifeblood")==0 and IsUsableSpell("Lifeblood") then 
      	spell="Lifeblood"
   	elseif cd("Heroic Strike")==0 and ub("player","Incite") and IsSpellInRange("Heroic Strike", "target")==1 and IsUsableSpell("Heroic Strike") then
      	spell="Heroic Strike"
   	elseif cd("Heroic Strike")==0 and nPower>70 and IsSpellInRange("Heroic Strike", "target")==1 and IsUsableSpell("Heroic Strike") then
     	spell="Heroic Strike"
   	elseif cd("Concussion Blow")== 0 and IsSpellInRange("Concussion Blow","target")==1 and IsUsableSpell("Concussion Blow") then 
      	spell="Concussion Blow"
   	elseif cd("Devastate")==0 and IsSpellInRange("Devastate","target")==1 and IsUsableSpell("Devastate") then
      	spell="Devastate"
   	elseif cd("Rend") and not UnitDebuff("target","Rend") and IsSpellInRange("Rend","target")==1 and IsUsableSpell("Rend") then 
      	spell="Rend"
   	end
else return end
	return spell
end

--[[
Renvoi de sort - Spell Reflection
Ivresse de la victoire - Victory Rush
Victorieux - Victorious
Provocation - Taunt
Fracasser armure - Sunder Armor
Emulation - Incite
Fracasser armure - Sunder Armor
Mur protecteur - Shield Wall
Dernier rempart - Last Stand
Charge - Charge
Lancer héroïque - Heroic Throw
Dévaster - Devastate
Heurt de bouclier - Shield Slam
Epée et bouclier - Sword and Board
Volée de coups - Pummel
Maîtrise du blocage	 - Shield Block
Frappe héroïque - Heroic Strike
Sang-de-vie - Lifeblood
Régénération enragée - Enraged Regeneration
Coup traumatisant - Concussion Blow
Pourfendre - Rend
Onde de choc - Shockwave
Foudroyé - Thunderstruck
Coup de tonnerre - Thunder Clap
Revanche - Revenge
]]
