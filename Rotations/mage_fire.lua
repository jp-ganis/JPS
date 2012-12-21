function mage_fire(self)

	-- According to: http://www.icy-veins.com/fire-mage-wow-pve-dps-guide
	local alterTime = jps.buff("alter time")

	local possibleSpells = {

		-- Flamestrike when holding down shift.
		{ "Flamestrike", 
			IsShiftKeyDown() ~= nil 
			and GetCurrentKeyBoardFocus() == nil },

		-- "Oh shit!"" spells.
		{ "Ice Block",
			jps.hp() < .3
			and not jps.debuff("Hypothermia") },

		{ "Greater Invisibility",
			jps.hp() < .3 },

		-- Reset Ice Block if we have the Cold Snap talent.
		{ "Cold Snap",
			jps.cooldown("Ice Block") > 0 },


		-- Defensive spells

		-- Temporal Shield if we're taking damage
		{ "Temporal Shield",
			jps.hp() < .8 },
		
		-- Ice Barrier if we're taking damage
		{ "Ice Barrier",
			jps.hp() < .85
			and not jps.buff("Ice Barrier") },

		-- Interrupt
		{ "Counterspell",
			jps.Interrupts 
      and jps.shouldKick() },

    -- -- On-Use Trinket 1
    -- { jps.useTrinket(1), 
    --   jps.UseCDs },

    -- -- On-Use Trinket 2
    -- { jps.useTrinket(2), 
    --   jps.UseCDs },

    -- DPS Racial on cooldown.
		-- { jps.DPSRacial,
		-- 	jps.UseCDs 
		-- 	and jps["DPS Racial"] },

		-- Alter Time for a second pyroblast.
		{ "Alter Time",
			jps.UseCDs
			and ( jps.cooldown("Presence of Mind") == 0
				or jps.buff("Pyroblast!") ) },

		-- POM Pyro on cooldown.
		-- { { "macro", "/cast Presence of Mind /cast Pyroblast" }, 
		-- 	jps.UseCDs
		-- 	and jps.cooldown("Presence of Mind") == 0 },

		-- Incanter's Ward on cooldown - not sure about this yet.
		{ "Incanter's Ward", 
			"onCD" },

		-- Evocation - TODO


		-- Bombs

		-- Nether Tempest should always be on.
		{ "Nether Tempest",
			not jps.debuff("Nether Tempest") },

		-- Living Bomb should always be on.
		{ "Living Bomb",
			not jps.debuff("Living Bomb") },

		-- Frost Bomb should always be on.
		{ "Frost Bomb",
			not jps.debuff("Frost Bomb") },

		
		-- Combustion once we have ignite and Inferno Blast is on cooldown.
		{ "Combustion", 
			jps.debuffDuration("Ignite") > 0
			and jps.cooldown("Inferno Blast") > 1 },
		
		-- Mirror Image on cooldown.
		{ "Mirror Image",
			jps.UseCDs },


		-- Rotation

		-- Instant Pyroblast.
		{ "Pyroblast",
			jps.buff("Pyroblast!") },

		-- Inferno blast when we have Heating Up to proc an instant pyroblast.
		{ "Inferno Blast",
			jps.buff("Heating Up") },

		-- Scorch when we're moving.
		{ "Scorch",
			jps.Moving },

		-- Fireball when we're not moving.
		{ "Fireball",
			"onCD" },
		
		-- Make sure we always have Molten Armor up. (Sometimes I forget)
		{ "Molten Armor", 
			not jps.buff("Molten Armor") },
	}
  
  local spell = parseSpellTable(possibleSpells)

  -- print(spell)

  -- If it's Flamestrike we need to set a target.
	if spell == "Flamestrike" then jps.groundClick() end

	-- if spell == "Flamestrike" then
	-- 	jps.Cast( spell )
	-- 	jps.groundClick()
	-- end

   return spell
end
