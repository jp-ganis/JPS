function hunter_mm(self)
	-- Marksmanship Hunter by Chiffon with additions by Scribe
	------------------------------------------
	local up = UnitPower
	local r = RunMacroText;
	local spell = nil
	local raf_ready,raf_timeleft,_ = GetSpellCooldown("Rapid Fire");
	local chim_ready,chim_timeleft,_ = GetSpellCooldown("Chimera Shot");

	-- Interupting, Borrowed directly from feral cat
	if jps.Interrupts and jps.shouldKick("target") and cd("Silencing Shot") == 0 then
		print("Silencing Target")
		return "Silencing Shot"

	-- Misdirecting to pet if not in a party
	elseif GetNumPartyMembers() == 0 and jps.Opening and not UnitIsDead("pet") then
		jps.Target = "pet"
		spell = "Misdirection"
		jps.Opening = false	
		
	-- Misdirecting to focus if set
	elseif jps.Opening and UnitExists("focus") and cd("Misdirection") then
		print("Misdirecting to",GetUnitName("focus", showServerName)..".")
		jps.Target = "focus"
		spell = "Misdirection"
		jps.Opening = false
		
	-- Main rotation (Shift to launch trap in Multi Mob situations)
	elseif UnitThreatSituation("player") == 3 and cd("Feign Death") == 0 and jps.checkTimer("feign") and GetNumPartyMembers() > 0 then
		print("Aggro! Feign Death cast.")
		jps.createTimer("feign", "2")
		spell = "Feign Death"
	elseif jps.checkTimer("feign") > 0 then
		spell = nil
	elseif ub("player", "Feign Death") and jps.checkTimer("feign") == 0 then
		CancelUnitBuff("player", "Feign Death")
		spell = nil
	elseif not ub("pet","Mend Pet") and UnitHealth("pet")/UnitHealthMax("pet") <= 0.5 and UnitHealth("pet") then
		spell = "Mend Pet"
	elseif GetUnitSpeed("player") == 0 and not ub("player", "Aspect of the Hawk") then
		spell = "Aspect of the Hawk"
	elseif IsShiftKeyDown() and jps.MultiTarget and not ub("player", "Trap Launcher") and cd("Explosive Trap") then
		spell = "Trap Launcher"
	elseif IsShiftKeyDown() and jps.MultiTarget and ub("player", "Trap Launcher") and cd("Explosive Trap") then
		CameraOrSelectOrMoveStart()
		CameraOrSelectOrMoveStop()
		spell = "Explosive Trap"
	elseif jps.MultiTarget and up("player") > 40 then
		spell = "Multi-Shot"
	elseif UnitHealth("target")/UnitHealthMax("target") <= 0.2 and cd("Kill Shot") == 0 then
		spell = "Kill Shot"
	elseif not jps.MultiTarget and not UnitDebuff("target", "Serpent Sting",nil,"PLAYER") and up("player") > 25 and UnitHealth("target") > 50000 then 
		spell = "Serpent Sting"
	elseif cd("Chimera Shot") == 0 and up("player") >= 44 then
		spell = "Chimera Shot"
	elseif jps.UseCDs and cd("Rapid Fire") == 0 and not ub("player","rapid fire") then
		spell = "Rapid Fire"
	elseif jps.UseCDs and cd("Lifeblood") == 0 and not ub("player","Lifeblood") then
		spell = "Lifeblood"
	elseif jps.UseCDs and cd("Rapid Fire") > 0 and jps.cooldown("Rapid Fire") >= 120 and not ub("player","rapid fire") and cd("readiness") == 0 then
		spell = "Readiness"
	elseif GetUnitSpeed("player") == 0 and UnitHealth("target")/UnitHealthMax("target") > 0.9 and up("player") > 55 and jps.cooldown("Chimera Shot") > 4 then
		spell = "Aimed Shot"
	elseif up("player") > 66 then
		if ub("player","rapid fire") then
			spell = "Aimed Shot"
		else 
			spell = "Arcane Shot"
		end
	elseif ub("player", "Fire!") then 
		spell = "Aimed Shot"
	elseif GetUnitSpeed("player") > 0 and not ub("player", "Aspect of the Fox") then
		spell = "Aspect of the Fox"
	else
		spell = "Steady Shot" 
	end
	
	return spell
end
