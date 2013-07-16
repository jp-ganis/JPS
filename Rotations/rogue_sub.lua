jps.registerRotation("ROGUE","SUBTLETY",function()
	
	----------
	--- Declarations
	----------
	
	local player = "player"
	local rangedTarget = "target"
	
	local cp = GetComboPoints("player")
	local energy = UnitPower("player")
	local snd_duration = jps.buffDuration(5171) 
	local rupt_duration = jps.myDebuffDuration(1943) -- "Rupture" 1943
	local snd_spell = tostring(select(1,GetSpellInfo(5171))) -- 5171 "Slice and Dice"
	
	----------
	--- Rotation
	----------
	local spellTable = 
	{
		-- Ambush
		{ 8676	 , jps.buff(1784,"player")	, rangedTarget },
		
		-- Interrupts
		{ "Kick",  jps.shouldKick() },
		{ "Blind", jps.shouldKick() },
		{ "Kick",  jps.shouldKick("focus"),"focus" },
		{ "Blind", jps.shouldKick("focus"),"focus" },
		
		-- Slice and Dice
		{ 5171	 , (snd_duration < 4) and (cp > 3)	, rangedTarget , "SND_SpellID" },
		{ 5171	 , (snd_duration < 4) or (snd_duration < 15 and jps.buffStacks("Bandit's Guile") == 11 and cp > 3) , rangedTarget , "SND_SpellID_Bandit"},
		{ {"macro","/cast "..snd_spell}, (snd_duration < 4) and (cp > 3) , rangedTarget , "SND_Macro" },
		
		-- Shadow Blades
		{ 121471	, jps.bloodlusting() and snd_duration >= jps.buffDuration(121471)	, player },
		
		-- Killing Spree
		{ 51690	 , (energy < 35 and snd_duration > 4 and not jps.buff(13750)) and jps.multitarget	, rangedTarget },
		
		-- Adrenaline Rush - at low energy or while shadowblades is active
		{ 13750	 , (energy < 35 or jps.buff(121471)) and jps.useCDs	, player },
		
		-- Rupture
		{ 1943	 , rupt_duration < 4 and cp == 5	and jps.debuff(84617), rangedTarget },
		
		-- Eviscerate
		{ 2098	 , cp == 5 and jps.debuff(84617)	, rangedTarget },
		
		-- Revealing Strike
		{ 84617	 , not jps.debuff(84617)	, rangedTarget },
		
		-- Sinister Strike
		{ 1752	 , cp < 5	, rangedTarget },
	
	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default")






