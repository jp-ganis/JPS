function monk_mistweaver(self)

  -- Healer
	local me = "player"
  local chi = UnitPower(me, 12)

	-- Tank is focus.
	local tank = jps.findMeATank()
  local tankHP = jps.hpInc(tank)
  
	-- Default to healing lowest partymember
	local defaultTarget = jps.lowestInRaidStatus()

	-- Check that the tank isn't going critical, and that I'm not about to die
  if jps.canHeal(tank) and tankHP <= .5 then defaultTarget = tank end
	if jps.hpInc(me) < .3 then defaultTarget = me end

	-- Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)
    
	
	local possibleSpells = {
    
		{ "Healing Sphere", 
			IsShiftKeyDown() ~= nil 
			and GetCurrentKeyBoardFocus() == nil },
    
    -- Make sure your statue is up at all times.
		{ "Summon Jade Serpent Statue",
      not jsp.buff("Eminence") },

		-- Fortifying Brew if you get low.
		{ "Fortifying Brew", 
      jps.UseCDs 
      and jps.hp() < .4
      and not defensiveCDActive },

    -- Diffuse Magic if you get low. (talent based)
    { "Diffuse Magic", 
      jps.UseCDs 
      and jps.hp() < .5 
      and not defensiveCDActive },

    -- Dampen Harm if you get low. (talent based)
    { "Dampen Harm", 
      jps.UseCDs 
      and jps.hp() < .6 
      and not defensiveCDActive },

    -- Healthstone if you get low.
    { "Healthstone",
      jps.hp() < .5
      and GetItemCount("Healthstone", 0, 1) > 0 },
    
    -- Thunder Focus Tea on CD
    { "Thunder Focus Tea",
       jps.UseCDs
       and tankHP < .6 },
    
    -- Life Cocoon on the tank if he's low.
		{ "Life Cocoon",
      tankHP < .4, tank },
      
		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), 
      jps.UseCDs
      and defaultHP < .7 },
        
		-- On-Use Trinkets.
    { jps.useTrinket(1), 
      jps.UseCDs
      and defaultHP < .7 },
    { jps.useTrinket(2), 
      jps.UseCDs
      and defaultHP < .7 },

		-- Lifeblood (requires herbalism)
		{ "Lifeblood",
			jps.UseCDs
			and defaultHP < .7 },
    
    -- Renewing Mist when someone other than tank is taking mild damage.
		{ "Renewing Mist",
      defaultHP < .8
      and not defaultTarget == tank, defaultTarget },
    
    -- Uplift when someone other than tank is taking heavy damage.
		{ "Uplift",
      defaultHP < .6
      and chi >= 2
      and not defaultTarget == tank, defaultTarget },
    
    -- Surging Mist for heavy damage.
		{ "Surging Mist",
      defaultHP < .5
      and (
        jps.buffStacks("Vital Mists") == 5
        or not jps.Moving ), defaultTarget },
    
    -- Enveloping Mist for moderate damage.
		{ "Enveloping Mist",
      not jps.Moving
      and defaultHP < .7, defaultTarget },
    
    -- Soothing Mist for mild damage.
		{ "Soothing Mist",
      not jps.Moving
      and defaultHP < .8, defaultTarget },
        
    -- Maintain Tiger Power
    { "Tiger Palm",
      not jps.buff("Tiger Power")
      and IsSpellInRange("Tiger Palm", "target") },
    
    -- Maintain Serpent's Zeal
    { "Blackout Kick",
      not jps.buff("Serpent's Zeal")
      and IsSpellInRange("Blackout Kick", "target") },
    
    -- Spinning Crane Kick to cap our chi when MultiTarget is toggled.
    { "Spinning Crane Kick",
      jps.MultiTarget
      and chi < 4 },
    
    -- Jab to cap our chi.
    { "Jab",
      chi < 4
      and IsSpellInRange("Jab", "target") },
      
	}

	local spell, target = parseSpellTable(possibleSpells)
  jps.Target = target
  if spell == "Summon Jade Serpent Statue" or spell == "Healing Sphere" then jps.groundClick() end
	return spell

end
