function warlock_affliction(self)
  
	--simcrafted
	-- local shards = UnitPower("player", 7)

	local baneDuration = jps.debuffDuration("Bane of Doom")
	local corrDuration = jps.debuffDuration("Corruption")
	local uaDuration = jps.debuffDuration("Unstable Affliction")

	-- focus dotting
	local focusDotting, focusCorr, focusUA, focusBane
  
	if UnitExists("focus") then
		focusDotting = true
		focusCorr = jps.debuffDuration("Corruption", "focus")
		focusUA = jps.debuffDuration("Unstable Affliction", "focus")
		focusBane = jps.debuffDuration("Bane of Agony", "focus")
	end

	local corrTick = 2
	local uaTick = 2	
	local uaCastTime = 1.5

	local possibleSpells = {
    
		{ "Demon Soul" },
    
		{ "Corruption", 
      corrDuration < corrTick },
    
		{ "Unstable Affliction", 
      uaDuration < (uaTick + uaCastTime) 
      and jps.LastCast ~= "Unstable Affliction" },
      
		{ "Bane of Doom", 
      baneDuration == 0 },
    
		{ "Haunt" },
    
		{ "Summon Doomguard" },
    
		{ "Drain Soul", 
      jps.hp("target") <= .25 },
    
		{ "Shadowflame", 
      IsShiftKeyDown() },
    
		{ "Life Tap", 
      jps.mana() <= .35 },
      
		{ "Soulburn", 
      not jps.buff("Demon Soul: Felhunter") },
      
		{ "Soulfire", 
      jps.buff("Soulburn") },
    
		{ "Shadow Bolt" },
    
		{ "Life Tap", 
      jps.Moving 
      and jps.mana() < .8 
      and jps.mana() < jps.hp("Target") },
      
		{ "Fel Flame", 
      jps.Moving },
    
		{ "Life Tap", 
      jps.mana() <= .6 },
    
	}

	return parseSpellTable(possibleSpells)
end
