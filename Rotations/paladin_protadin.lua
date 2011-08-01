function paladin_protadin(self)
	-- Credit (and thanks!) go to scottland3.
   local rfury = UnitAura("player","Righteous Fury")
   local myHealth = UnitHealth("player")/UnitHealthMax("player")
   local myMana = UnitMana("player")/UnitManaMax("player")
   local power = UnitPower("player","9")
   local spell = nil

	--meant to mimic tanking rotation as closely as possible

   if myMana < .75 and cd("Divine Plea")==0 then 
      spell = "Divine Plea"
   elseif UnitIsEnemy("player", "target") and jps.should_kick("target") and cd("Rebuke") == 0 and IsSpellInRange("Rebuke", "target") == 1 then
      SpellStopCasting() spell = "Rebuke"
   elseif power>=3 then -- spend HP in the correct way, threshold for WoG is 70%, feel free to change
		if myHealth <= .7 and cd("Word of Glory")==0 then
			spell = "Word of Glory"
		elseif jps.MultiTarget then
			spell = "Inquisition"
		else
      		spell = "Shield of the Righteous"
		end
   elseif jps.buff_duration("Player", "Grand Crusader") > 0 then --easiest way to grab the GC proc, may create some clashes in rotation
      spell = "Avenger's Shield"
   elseif cd("Hammer of the Righteous")==0 then --keep CS/Hammer on CD, generating HP
		if jps.MultiTarget then
			spell = "Hammer of the Righteous"
		else
			spell = "Crusader Strike"
		end
   elseif cd("Judgement")==0 then --return mana asap
      spell = "Judgement"
   elseif cd("Avenger's Shield")==0 then 
      spell = "Avenger's Shield"
   elseif cd("Holy Wrath")==0 then
      spell = "Holy Wrath"
   elseif cd("Hammer of Wrath")==0 then
      spell = "Hammer of Wrath"
   elseif myMana > .9 and cd("Consecration")==0 then --low priority and mana heavy, only use at 90% of mana
      spell = "Consecration"
   end
   
   return spell

end
function paladin_protadin(self)
	-- Credit (and thanks!) go to scottland3.
   local rfury = UnitAura("player","Righteous Fury")
   local myHealth = UnitHealth("player")/UnitHealthMax("player")
   local myMana = UnitMana("player")/UnitManaMax("player")
   local power = UnitPower("player","9")
   local spell = nil


   if myMana < .75 and cd("Divine Plea")==0 then 
      spell = "Divine Plea"
   elseif UnitIsEnemy("player", "target") and jps.should_kick("target") and cd("Rebuke") == 0 and IsSpellInRange("Rebuke", "target") == 1 then
      SpellStopCasting() spell = "Rebuke"
   elseif power>=3 and cd("Shield of the Righteous")==0 then
      spell = "Shield of the Righteous"
   elseif cd("Hammer of the Righteous")==0 then
      spell = "Hammer of the Righteous"
   elseif myMana > .5 and cd("Consecration")==0 then
      spell = "Consecration"
   elseif cd("Holy Wrath")==0 then
      spell = "Holy Wrath"
   elseif cd("Avenger's Shield")==0 then 
      spell = "Avenger's Shield"
   elseif cd("Judgement")==0 then 
      spell = "Judgement"
   elseif cd("Hammer of Wrath")==0 then
      spell = "Hammer of Wrath"
   elseif cd("crusader's strike") == 0 then
      spell = "crusader strike"
   end
   
   return spell

end
