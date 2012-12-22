function monk_brewmaster(self)
   
	-- Usage info:
	-- Shift to use "Dizzying Haze" at mouse position - AoE threat builder - "Hurl a keg of your finest brew"
	-- Left control and mouseover target to use "Chi Wave" - can be used on friendlies and enemies (disabled for now)

	local chi = UnitPower("player","12") -- 12 is chi
	local energy = UnitPower("player","3") -- 3 is energy
	local targetHealth = UnitHealth("target")
	local stance = GetShapeshiftForm()
	local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")

	local possibleSpells = {

		-- Stance check
		{ nil, stance ~= 2 },

		-- Dizzying Haze when holding down shift.
		{ "Dizzying Haze", 
			IsShiftKeyDown() ~= nil 
			and GetCurrentKeyBoardFocus() == nil },

		-- Defensive cooldowns 
		{ "Fortifying Brew", 
      jps.UseCDs 
      and jps.hp() < .3 
      and not defensiveCDActive },

    { "Diffuse Magic", 
      jps.UseCDs 
      and jps.hp() < .5 
      and not defensiveCDActive },

    { "Dampen Harm", 
      jps.UseCDs 
      and jps.hp() < .6 
      and not defensiveCDActive },

    { "Chi Wave",
      jps.UseCDs 
      and jps.hp() < .6 
      and chi >= 2 },


		-- Insta-kill single target when available
    { "Touch of Death", 
      jps.UseCDs 
      and jps.buff("Death Note") 
      and chi > 2 
      and not jps.MultiTarget },

    -- On-Use Trinket 1
    { jps.useTrinket(1), 
      jps.UseCDs },

    -- On-Use Trinket 2
    { jps.useTrinket(2), 
      jps.UseCDs },

    -- Purifying Brew to clear stagger when it's moderate or heavy.
		{ "Purifying Brew",
			jps.debuff("Heavy Stagger") 
			or jps.debuff("Moderate Stagger") },
		
		-- Elusive Brew with 10 or more stacks.
		{ "Elusive Brew", 
			jps.buffStacks("Elusive Brew") >= 10 },

		-- Guard when Power Guard buff is available.
		{ "Guard", 
			jps.buff("Power Guard") 
			and jps.hp() < 0.85
			and not defensiveCDActive },

		-- Blackout Kick if we don't have shuffle or if it's about to drop.
		{ "Blackout Kick", 
			not jps.buff("Shuffle")
			or jps.buffDuration("shuffle") < 3 },

		-- Keg Smash to build some chi and threat.
		{ "Keg Smash", 
			chi < 3 },

		-- Interrupt
    { "Spear Hand Strike", 
      jps.Interrupts 
      and jps.shouldKick() },

		-- Breath of Fire is our strongest AoE
		{ "Breath of Fire", 
			jps.MultiTarget },

		-- Expel Harm for building some chi and healing if we're not full health.
		{ "Expel Harm", 
			jps.hp() < 0.90 
			and energy >= 40 
			and chi < 4 },

		-- Chi Wave for multi-target threat and heal.
		{ "Chi Wave", 
			jps.MultiTarget 
			and chi >= 2 },

		-- Rushing Jade Wind for multi-target threat.
		{ "Rushing Jade Wind", 
			jps.MultiTarget 
			and chi >= 2 },

		-- Spinning Crane Kick for multi-target threat.
		{ "Spinning Crane Kick", 
			jps.MultiTarget 
			and energy >= 40 },

		-- Tiger Palm to keep the Tiger Power buff up. No chi cost due to Brewmaster specialization at level 34.
		{ "Tiger Palm", 
			not jps.buff("Tiger Power")
			or jps.buffDuration("Tiger Power") <= 1.5 },

		-- Chi Brew if we have the talent.
		{ "Chi Brew", 
			chi == 0 },

		-- Jab is our basic chi builder.
		{ "Jab", 
			energy >= 40 
			and chi < 4 },

		-- Tiger Palm to keep the Tiger Power buff up. No chi cost due to Brewmaster specialization at level 34.
		{ "Tiger Palm", true },
		
	}

	local spell = parseSpellTable(possibleSpells)

	-- If it's Dizzying Haze we need to set a target.
	if spell == "Dizzying Haze" then jps.groundClick() end

	return spell
end
