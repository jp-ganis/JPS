function hunter_sv(self)
	
	local focus = UnitPower("player")
	local sting_duration = jps.debuffDuration("target","Serpent Sting")
	
	if UnitThreatSituation("player") == 3 and cd("Feign Death") == 0 and jps.checkTimer("feign") == 0 then
   		jps.createTimer("feign", "2")
   		spell = "Feign Death"

   	elseif jps.checkTimer("feign") > 0 then
   		spell = nil

   	elseif ub("player", "Feign Death") and jps.checkTimer("feign") == 0 then
   		CancelUnitBuff("player", "Feign Death")
   		spell = nil
	
	elseif GetNumPartyMembers() == 0 and jps.Opening and not UnitIsDead("pet") then
		jps.Target = "pet"
		spell = "Misdirection"
		jps.Opening = false
	
	elseif jps.Opening and UnitExists("focus") == 1 and cd("Misdirection") == 0 then
		jps.Target = "focus"
		spell = "Misdirection"
		jps.Opening = false
		
	elseif not ud("target","Hunter's Mark") and not jps.MultiTarget then
		spell = "Hunter's Mark"
	
	elseif GetUnitSpeed("player") == 0 and not ub("player", "Aspect of the Hawk") then
		spell = "Aspect of the Hawk"
		
	elseif IsShiftKeyDown() and jps.MultiTarget and not ub("player", "Trap Launcher") and cd("Explosive Trap") then
		spell = "Trap Launcher"
		
	elseif IsShiftKeyDown() and jps.MultiTarget and ub("player", "Trap Launcher") and cd("Explosive Trap") then
		CameraOrSelectOrMoveStart()
		CameraOrSelectOrMoveStop()
		spell = "Explosive Trap"
		
	elseif jps.MultiTarget and focus > 40 then
		spell = "Multi-Shot"
		
	elseif sting_duration < 2 and focus > 25 then
		spell = "Serpent Sting"
	
	elseif ub("player", "Lock and Load") then
		spell = "Explosive Shot"
		
	elseif cd("Explosive Shot") == 0 and focus > 44 then
		spell = "Explosive Shot"
		
	elseif cd("Black Arrow") == 0  and focus > 35 then
		spell = "Black Arrow"
		
	elseif UnitHealth("target")/UnitHealthMax("target") <= 0.2 and cd("Kill Shot") == 0 then
		spell = "Kill Shot"
		
	elseif focus > 85 then
	  	spell = "Arcane Shot"
	
	elseif jps.UseCDs and cd("Rapid Fire") == 0 and not ub("player","Rapid Fire") then
		spell = "Rapid Fire"
		
	elseif GetUnitSpeed("player") > 0 and not ub("player", "Aspect of the Fox") then
		spell = "Aspect of the Fox"
	
	else
		spell = "Cobra Shot"
		
	end
	
	return spell
end
