function hunter_mm(self)
	-- Marksmanship Hunter by Chiffon with additions by Scribe
	--jpganis
	--SIMCRAFT
	------------------------------------------
	local up = UnitPower
	local r = RunMacroText;
	local spell = nil
	local focus = UnitPower("player")

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
	elseif UnitIsDead("pet") then
		spell = "Revive Pet"
	
	--SIMCRAFT
	else
		local spellTable = 
		{
			{ "aspect of the hawk", not jps.buff("aspect of the hawk") and not jps.Moving },
			{ "aspect of the fox", not jps.buff("aspect of the fox") and jps.Moving },
			{ jps.DPSRacial, jps.UseCDs },
			{ "multi-shot", jps.MultiTarget },
			{ "serpent sting", not jps.debuff("serpent sting") and jps.hp("target") <= 0.9 },
			{ "chimera shot", jps.hp("target") <= 0.9 },
			{ "rapid fire", not jps.buff("bloodlust") and not jps.buff("heroism") and not jps.buff("time warp") },
			{ "readiness", jps.cd("rapid fire") > 0 and not jps.buff("rapid fire") },
			{ "kill shot", "onCD" },
			{ "aimed shot", jps.buffStacks("ready, set, aim...")==5 },
			{ "aimed shot", jps.cd("chimera shot") > 5 or focus >= 80 or jps.buff("rapid fire") },
			{ "aimed shot", jps.hp("target") >= 0.9 or jps.buff("bloodlust") },
			{ "aimed shot", jps.buff("heroism") or jps.buff("time warp") },
			{ "steady shot", "onCD" },
		}
		return parseSpellTable(spellTable)
	end
	
	return spell
end
