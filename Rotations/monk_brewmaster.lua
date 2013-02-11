function monk_brewmaster(self)
   
	-- Usage info:
	-- Shift to use "Dizzying Haze" at mouse position - AoE threat builder - "Hurl a keg of your finest brew"
	-- Left control and mouseover target to use "Chi Wave" - can be used on friendlies and enemies (disabled for now)

  if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
  
	local chi = UnitPower("player", "12") -- 12 is chi
	local energy = UnitPower("player", "3") -- 3 is energy
	local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")

	local possibleSpells = {

		-- Dizzying Haze when holding down shift.
		-- { "Dizzying Haze", 
		--   IsShiftKeyDown() ~= nil 
		--   and GetCurrentKeyBoardFocus() == nil },

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
        
		-- Insta-kill single target when available.
    { "Touch of Death", 
      jps.UseCDs 
      and jps.buff("Death Note") 
      and chi > 2 
      and not jps.MultiTarget },

    -- Purifying Brew to clear stagger when it's moderate or heavy.
		{ "Purifying Brew",
			jps.debuff("Moderate Stagger") 
			or jps.debuff("Heavy Stagger") },
		
		-- Elusive Brew with 10 or more stacks.
		{ "Elusive Brew", 
			jps.buffStacks("Elusive Brew") >= 10 },

    -- Chi Brew if we have no chi (talent based).
    { "Chi Brew", 
      chi == 0 },

    -- Rushing Jade Wind applies shuffle with a heal and multi-target damage. 
    --  Use it instead of Blackout kick when it's available. (talent based)
    { "Rushing Jade Wind", 
      jps.MultiTarget
      or jps.hp() < .85
      or ( not jps.buff("Shuffle")
        or jps.buffDuration("Shuffle") < 3 ) },

    -- Blackout Kick if shuffle is missing or about to drop.
    { "Blackout Kick", 
      ( not jps.buff("Shuffle")
        or jps.buffDuration("Shuffle") < 3 )
      and chi >= 2 },

		-- Guard when Power Guard buff is available, we're taking some damage.
		{ "Guard", 
			jps.buff("Power Guard") 
			and jps.hp() < .9 },

    -- On-Use Trinket 1.
    { jps.useSlot(13), 
      jps.UseCDs },

    -- On-Use Trinket 2.
    { jps.useSlot(14), 
      jps.UseCDs },

    -- Engineers may have synapse springs on their gloves (slot 10).
    { jps.useSlot(10), 
      chi > 3
      and energy >= 50 },

    -- Herbalists have Lifeblood.
    { "Lifeblood",
      jps.UseCDs },

		-- Keg Smash to build some chi and keep the weakened blows debuff up.
		{ "Keg Smash", 
			chi < 3
      or not jps.debuff("Weakened Blows") },

		-- Interrupt.
    { "Spear Hand Strike", 
      jps.Interrupts 
      and jps.shouldKick() },
    { "Paralysis", 
      jps.Interrupts 
      and jps.shouldKick() },

    -- Invoke Xuen on cooldown for single-target. (talent based)
    { "Invoke Xuen, the White Tiger", 
      jps.UseCDs },
        
		-- Breath of Fire is the strongest AoE.
		{ "Breath of Fire", 
			jps.MultiTarget },

		-- Expel Harm for building some chi and healing if not at full health.
		{ "Expel Harm",
			jps.hp() < .85
			and energy >= 40
			and chi < 4 },

    -- Tiger Palm to keep the Tiger Power buff up. No chi cost due to Brewmaster specialization at level 34.
    { "Tiger Palm", 
      not jps.MultiTarget
      and not jps.buff("Tiger Power")
      or jps.buffDuration("Tiger Power") <= 1.5 },

    -- Zen Sphere for threat and heal (talent based).
    { "Zen Sphere",
      jps.hp() < .85 },
    
		-- Chi Wave for threat and heal (talent based).
		{ "Chi Wave",
      jps.hp() < .85 },
    
		-- Chi Wave for threat and heal (talent based).
		{ "Chi Burst",
      jps.hp() < .85 },

		-- Spinning Crane Kick for multi-target threat.
		{ "Spinning Crane Kick", 
			jps.MultiTarget },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
      jps.UseCDs },

		-- Jab is our basic chi builder.
		{ "Jab", 
			chi < 4 },

    -- Blackout Kick as a chi dump.
    { "Blackout Kick", 
      chi >= 4 },
        
		-- Tiger Palm filler.
		{ "Tiger Palm" },
		
	}

	local spell = parseSpellTable(possibleSpells)

	-- If it's Dizzying Haze we need to set a target.
	if spell == "Dizzying Haze" then jps.groundClick() end

	return spell
end
