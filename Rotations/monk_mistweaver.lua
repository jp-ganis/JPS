function monk_mistweaver(self)

  -- Healer
	local me = "player"
  local chi = UnitPower(me, 12)

	-- Tank is focus.
	local tank = jps.findMeATank()
  local tankHP = jps.hpInc(tank)
  
	-- Set the heal target to the lowest partymember.
	local healTarget = jps.lowestInRaidStatus()

	-- If the tank really needs healing, make him the heal target.
  if jps.canHeal(tank) and tankHP <= .5 then
    healTarget = tank
  end
  
  -- If I really need healing, make me the heal target.
	if jps.hpInc() < .4 then
    healTarget = me
  end

	-- Get the health of our heal target.
	local healTargetHP = jps.hpInc(healTarget)
  
  -- Check for an active defensive CD.
  local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")
  
  local channeling = UnitChannelInfo("player")
  local soothing = false
  if channeling then
    soothing = channeling:find("Soothing Mist")
  end
  
  -- Check if we should detox
  local dispelTarget = jps.FindMeADispelTarget({"Magic"}, {"Poison"}, {"Disease"})
  
	local possibleSpells = {
    
		{ "Summon Jade Serpent Statue", 
			IsShiftKeyDown() ~= nil 
			and GetCurrentKeyBoardFocus() == nil },
    
		{ "Healing Sphere", 
			IsControlKeyDown() ~= nil 
			and GetCurrentKeyBoardFocus() == nil },
    
		-- { "Healing Sphere", 
		--	IsShiftKeyDown() ~= nil 
		--	and GetCurrentKeyBoardFocus() == nil },
    
    -- TODO: Figure out a way to detect Jade Serpent
    -- Make sure your statue is up at all times.
		-- { "Summon Jade Serpent Statue",
    --  not jps.buff("Eminence") },

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
    
    -- Insta-kill single target when available
    { "Touch of Death", 
      jps.UseCDs
      and jps.buff("Death Note") },
    
    -- Thunder Focus Tea on CD
    { "Thunder Focus Tea",
       jps.UseCDs
       and tankHP < .6 },
    
    -- Life Cocoon on the tank if he's low.
		{ "Life Cocoon",
      tankHP < .5, tank },
    
    -- Detox if needed.
    { "Detox",
      dispelTarget ~= nil, dispelTarget },
    
    -- Water Spirit if you get low on mana.
    { "Water Spirit",
      jps.mana() < .6
      and GetItemCount("Water Spirit", 0, 1) > 0 },
        
		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), 
      jps.UseCDs
      and healTargetHP < .7 },
        
		-- On-Use Trinkets.
    { jps.useTrinket(1), 
      jps.UseCDs
      and healTargetHP < .7 },
    { jps.useTrinket(2), 
      jps.UseCDs
      and healTargetHP < .7 },

		-- Lifeblood (requires herbalism)
		{ "Lifeblood",
      jps.UseCDs
			and healTargetHP < .7 },
    
    -- Invoke Xuen CD. (talent based)
    { "Invoke Xuen, the White Tiger", 
      jps.UseCDs
      and healTargetHP < .55 },
    
    -- Mana Tea when we have 2 stacks.
		{ "Mana Tea",
      jps.mana() < .9
      and jps.buffStacks("Mana Tea") >= 2
      and not soothing },
        
    -- Uplift when someone other than tank is taking heavy damage.
		{ "Uplift",
      healTargetHP < .75
      and jps.buff("Renewing Mist", healTarget)
      and not soothing, healTarget },
    
    -- Expel Harm for Chi when we've taken damage.
		{ "Expel Harm",
      jps.hp() < .85
      and chi < 4
      and not soothing },
    
    -- Renewing Mist when someone is taking mild damage.
		{ "Renewing Mist",
      healTargetHP < .9
      and not jps.buff("Renewing Mist", healTarget)
      and not soothing, healTarget },
    
    -- Soothing Mist for mild damage.
		{ "Soothing Mist",
      not soothing
      and not jps.Moving
      and healTargetHP < .85, healTarget },
    
    -- Surging Mist for heavy damage.
		{ "Surging Mist",
      healTargetHP < .55
      and (
        soothing
        or jps.buffStacks("Vital Mists") == 5 ), healTarget },
    
    -- Enveloping Mist for moderate damage.
		{ "Enveloping Mist",
      healTargetHP < .75
      and soothing, healTarget },
    
    -- Maintain Tiger Power
    { "Tiger Palm",
      not jps.buff("Tiger Power")
      and IsSpellInRange("Tiger Palm", "target")
      and not soothing },
    
    -- Maintain Serpent's Zeal
    { "Blackout Kick",
      ( not jps.buff("Serpent's Zeal")
        or jps.buffStacks("Serpent's Zeal") < 2
        or jps.buffDuration("Serpent's Zeal") < 5 )
      and IsSpellInRange("Blackout Kick", "target")
      and not soothing },
    
    -- Chi Wave when we're in melee range.
		{ "Chi Wave",
      healTargetHP < .85
      and IsSpellInRange("Jab", "target")
      and not soothing },
    
    -- Spinning Crane Kick to cap our chi when MultiTarget is toggled.
    { "Spinning Crane Kick",
      jps.MultiTarget
      and jps.mana() > .9
      and chi < 4
      and IsSpellInRange("Jab", "target")
      and not soothing },
    
    -- Jab to cap our chi.
    { "Jab",
      jps.mana() > .9
      and chi < 4
      and IsSpellInRange("Jab", "target")
      and not soothing },
    
    -- Tiger Palm as a chi dump.
    { "Tiger Palm",
      jps.mana() > .9
      and chi > 2
      and IsSpellInRange("Tiger Palm", "target")
      and not soothing },
      
	}

	local spell, target = parseSpellTable(possibleSpells)
  jps.Target = target
  
  if spell == "Summon Jade Serpent Statue" or spell == "Healing Sphere" then
    jps.groundClick()
  end
  
  -- Debug
  if IsAltKeyDown() ~= nil and spell then
    print( string.format("Healing: %s, Health: %s, Spell: %s", healTarget, healTargetHP, spell) )
  end
  
	return spell

end
