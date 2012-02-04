function warrior_fury(self)

	local spell = nil
	local playerHealth = UnitHealth("player")/UnitHealthMax("player")
	local targetHealth = UnitHealth("target")/UnitHealthMax("target")
	local nSang = UnitBuff("player","Bloodsurge")
	local nEnrage = UnitBuff("player","Enrage")
	local nRage = UnitBuff("player","Berserker Rage")
	local nPower = UnitPower("Player",1)
	local nEmul = UnitBuff("player","Incite")
	local nTrance = UnitBuff("player","Battle Trance")
	local nExec= UnitBuff("player","Executioner")
	local stackExec = jps.buffStacks("Executioner")

if UnitCanAttack("player","target") then

	if cd("Battle Shout")==0 and IsUsableSpell("Battle Shout") and not ub("player","Battle Shout") and not ub("player","Roar of Courage") and not ub("player","Horn of Winter") and not ub("player","Strength of earth totem") then
      	spell= "Battle Shout"
    elseif nPower < 10 and cd("Battle Shout")==0 and IsUsableSpell("Battle Shout") then
		spell= "Battle Shout"
	elseif cd("Berserker Rage")==0 and not ub("player","Berserker Rage") and IsUsableSpell("Berserker Rage") then
		spell= "Berserker Rage"

-- Oh shit I'm Dying!!!!
	elseif cd("Enraged Regeneration")==0 and playerHealth<0.40 and IsUsableSpell("Enraged Regeneration") and nEnrage then
		spell= "Enraged Regeneration"

-- Interrupt that Shitz
	elseif cd("Pummel")==0 and IsSpellInRange("Pummel","target")==1 and IsUsableSpell("Pummel") and jps.shouldKick("target") then
		spell= "Pummel"

-- IsMouseButtonDown([button]) 1 or LeftButton - 2 or RightButton - 3 or MiddleButton or clickable scroll control
	elseif IsMouseButtonDown(2) and cd("Inner Rage")==0 and IsUsableSpell("Inner Rage") then 
		spell= "Inner Rage"
	elseif IsMouseButtonDown(2) and nPower>30 and cd("Cleave")==0 and IsUsableSpell("Cleave") then 
		spell= "Cleave"
	elseif IsMouseButtonDown(2) and nPower>25 and cd("Whirlwind")==0 and IsUsableSpell("Whirlwind") then 
		spell= "Whirlwind"

-- DPS Procs
	elseif cd("Death Wish")==0 and nPower>9 and IsUsableSpell("Death Wish") then 
		spell= "Death Wish"
	elseif cd("Recklessness")==0 and IsUsableSpell("Recklessness") then 
		spell= "Recklessness"

-- Execute stack rotation priorities
	elseif targetHealth<0.20 and cd("Execute")==0 and IsUsableSpell("Execute") then 
		if stackExec==nil or stackExec<5 then
			spell= "Execute"
		end

--Freebie
	elseif ub("player","Victorious") and IsUsableSpell("Victory Rush") then 
		spell= "Victory Rush"

-- Rage Check
	elseif cd("Heroic Strike")==0 and nPower>90 and IsUsableSpell("Heroic Strike") then
		spell= "Heroic Strike"

-- Start of Main Fury Warrior Rotation
-- (TG > SMF for WoW Patch 4.3.2)
	elseif cd("Bloodthirst")==0 and nPower>19 and IsUsableSpell("Bloodthirst") then
		spell= "Bloodthirst"
	elseif cd("Bloodthirst")~=0 and cd("Colossus Smash")==0 and IsUsableSpell("Colossus Smash") then
		spell= "Colossus Smash"
	elseif cd("Bloodthirst")==0 and nPower>19 and IsUsableSpell("Bloodthirst") then
		spell= "Bloodthirst"
	elseif cd("Bloodthirst")~=0 and nPower>19 and IsUsableSpell("Raging Blow") then
		spell= "Raging Blow"
	elseif cd("Bloodthirst")==0 and nPower>19 and IsUsableSpell("Bloodthirst") then
		spell= "Bloodthirst"
	elseif cd("Slam")==0 and nSang~=nil and nPower>14 and IsUsableSpell("Slam") then
		spell= "Slam"

-- Sunder on a miniboss, or boss only
	elseif (UnitHealth("target") > 5000000) and (jps.debuffStacks("Sunder Armor") < 3) and cd("Sunder Armor")==0 and IsUsableSpell("Sunder Armor") then
		spell= "Sunder Armor"
	end

else return end
	return spell
end