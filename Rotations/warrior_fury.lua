function warrior_fury(self)
	
	local spell = nil
	local playerHealth = UnitHealth("player")/UnitHealthMax("player")
	local targetHealth = UnitHealth("target")/UnitHealthMax("target")
	local nSang = UnitBuff("player","Bloodsurge")
	local nEnrage = UnitBuff("player","Enrage")
	local nRage = UnitBuff("player","Berserker Rage")
	local nPower = UnitPower("Player",1) -- Rage est PowerType 1
	local nEmul = UnitBuff("player","Incite")
	local nTrance = UnitBuff("player","Battle Trance")
	local nExec= UnitBuff("player","Executioner")
	local stackExec = jps.get_buff_stacks("player","Executioner")

-- Rugissement de courage - augmentant leur Force et leur Agilité de 549
-- Totem de force de la terre - augmente de 549 la Force et l'Agilité
-- Cor de l'hiver - augmente de 549 le total de Force et d'Agilité

if UnitCanAttack("player","target") then

	if cd("Battle Shout")==0 and IsUsableSpell("Battle Shout") and not ub("player","Battle Shout") and not ub("player","Roar of Courage") and not ub("player","Horn of Winter") and not ub("player","Strength of earth totem") then
      	spell= "Battle Shout"
    elseif nPower < 10 and cd("Battle Shout")==0 and IsUsableSpell("Battle Shout") then
		spell= "Battle Shout"
	elseif cd("Commanding Shout")==0 and IsUsableSpell("Commanding Shout") and playerHealth < 0.25 then
		spell= "Commanding Shout"
	elseif cd("Berserker Rage")==0 and not ub("player","Berserker Rage") and IsUsableSpell("Berserker Rage") then
		spell= "Berserker Rage"
	elseif IsMouseButtonDown(3) and cd("Intercept")==0 and IsSpellInRange("Intercept","target")==1 and IsUsableSpell("Intercept") then
		spell= "Intercept"
	elseif cd("Enraged Regeneration")==0 and playerHealth<0.60 and IsUsableSpell("Enraged Regeneration") and nEnrage then
		spell= "Enraged Regeneration"
	elseif cd("Pummel")==0 and IsSpellInRange("Pummel","target")==1 and IsUsableSpell("Pummel") and jps.should_kick("target") then
		spell= "Pummel"
	elseif ub("player","Victorious") and IsUsableSpell("Victory Rush") then 
		spell= "Victory Rush"
	elseif (UnitHealth("target") > 400000) and cd("Lifeblood")==0 and IsUsableSpell("Lifeblood") and UnitBuff("player","Flurry") then 
		spell= "Lifeblood"

	-- IsMouseButtonDown([button]) 1 or LeftButton - 2 or RightButton - 3 or MiddleButton or clickable scroll control
	elseif IsMouseButtonDown(2) and cd("Inner Rage")==0 and IsUsableSpell("Inner Rage") then 
		spell= "Inner Rage"
	elseif IsMouseButtonDown(2) and nPower>30 and cd("Cleave")==0 and IsUsableSpell("Cleave") then 
		spell= "Cleave"
	elseif IsMouseButtonDown(3) and nPower>25 and cd("Whirlwind")==0 and IsUsableSpell("Whirlwind") then 
		spell= "Whirlwind"
		
	elseif cd("Death wish")==0 and nPower>50 and IsUsableSpell("Death wish") then 
		spell= "Death wish"
	elseif cd("Colossus Smash")==0 and IsUsableSpell("Colossus Smash") then 
		spell= "Colossus Smash"
		
	elseif targetHealth<0.20 and cd("Execute")==0 and IsUsableSpell("Execute") then 
		if stackExec==nil or stackExec<5 then
			spell= "Execute"
		elseif cd("Bloodthirst")~=0 and (nEnrage~=nil or nRage~=nil) and cd("Raging Blow")==0 and IsUsableSpell("Raging Blow") then
			spell= "Raging Blow"
		elseif cd("Bloodthirst")~=0 and nSang~=nil and cd("Slam")==0 and IsUsableSpell("Slam") then
			spell= "Slam"
		elseif cd("Bloodthirst")==0 and IsUsableSpell("Bloodthirst") then 
			spell= "Bloodthirst"
		else
			spell= "Execute"
		end
		
	elseif ud("target","Colossus Smash") and UnitBuff("player","Death wish") and cd("Bloodthirst")==0 and IsUsableSpell("Bloodthirst") then
		spell= "Bloodthirst" 
	elseif ud("target","Colossus Smash") and UnitBuff("player","Death wish") and (nEnrage~=nil or nRage~=nil) and cd("Raging Blow")==0 and IsUsableSpell("Raging Blow") then
		spell= "Raging Blow"
	elseif ud("target","Colossus Smash") and UnitBuff("player","Death wish") and nSang~=nil and cd("Slam")==0 and IsUsableSpell("Slam") then
		spell= "Slam"
	elseif ud("target","Colossus Smash") and UnitBuff("player","Death wish") and cd("Heroic Strike")==0 and nEmul~=nil and nPower>50 and IsUsableSpell("Heroic Strike") then
		spell= "Heroic Strike"
	elseif ud("target","Colossus Smash") and cd("Bloodthirst")==0 and IsUsableSpell("Bloodthirst") then
		spell= "Bloodthirst"
	elseif ud("target","Colossus Smash") and cd("Bloodthirst")~=0 and (nEnrage~=nil or nRage~=nil) and cd("Raging Blow")==0 and IsUsableSpell("Raging Blow") then 
		spell= "Raging Blow"
	elseif ud("target","Colossus Smash") and cd("Bloodthirst")~=0 and nSang~=nil and cd("Slam")==0 and IsUsableSpell("Slam") then
		spell= "Slam"

	elseif cd("Heroic Strike")==0 and nTrance~=nil and IsUsableSpell("Heroic Strike") then
		spell= "Heroic Strike"
	elseif cd("Heroic Strike")==0 and targetHealth>0.20 and nPower>70 and IsUsableSpell("Heroic Strike") then
		spell= "Heroic Strike"
	elseif cd("Heroic Strike")==0 and nEmul~=nil and nPower>50 and IsUsableSpell("Heroic Strike") then
		spell= "Heroic Strike"

	elseif cd("Bloodthirst")~=0 and (nEnrage~=nil or nRage~=nil) and cd("Raging Blow")==0 and IsUsableSpell("Raging Blow") then
		spell= "Raging Blow"
	elseif cd("Bloodthirst")~=0 and nSang~=nil and cd("Slam")==0 and IsUsableSpell("Slam") then
		spell= "Slam"
	elseif cd("Bloodthirst")==0 and IsUsableSpell("Bloodthirst") then 
		spell= "Bloodthirst"
	elseif UnitThreatSituation("player")==0 and cd("Heroic Throw")==0 and IsUsableSpell("Heroic Throw") then 
		spell= "Heroic Throw"
	elseif (UnitHealth("target") > 500000) and (jps.get_debuff_stacks("target","Sunder Armor") < 3) and cd("Sunder Armor")==0 and IsUsableSpell("Sunder Armor") then
		spell= "Sunder Armor"
	end
else return end
	return spell
end


--http://manaflask.com/Ronnie/blog/5964/


