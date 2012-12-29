function mage_fire(self)
--pcmd
	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end

	local castingSpell, _, _, _, _, endTime = UnitCastingInfo("player")

	local possibleSpells = {

		-- Ice Block when you're about to die.
		{ "Ice Block",
			jps.hp() < .3
			and not jps.buff("Ice Block")
			and not jps.debuff("Hypothermia") },

		{ { "macro", "/cancelaura Ice Block" }, 
			jps.hp() > .8
			and jps.buff("Ice Block") },

		-- Refresh your Ice block. (talent based)
		{ "Cold Snap",
			jps.cooldown("Ice Block") > 0
			and jps.cooldown("Cold Snap") == 0
			and not jps.buff("Presence of Mind") },
		
		-- Ice Barrier when you're taking a decent amount of damage. (talent based)
		{ "Ice Barrier",
			jps.hp() < .7
			and not jps.buff("Ice Barrier")
			and not jps.buff("Presence of Mind") },

		-- Interrupts.
		{ "Counterspell", 
			jps.Interrupts 
      and jps.shouldKick()
      and not jps.buff("Presence of Mind") },

		-- Molten Armor if you forgot to buff it.
		{ "Molten Armor", 
			not jps.buff("Molten Armor")
			and not jps.buff("Presence of Mind") },

		-- Arcane Brilliance if you forgot to buff it.
		{ "Arcane Brilliance", 
			not jps.buff("Arcane Brilliance")
			and not jps.buff("Presence of Mind"), "player" },
		
		-- Removed AoE spells since they are very situational.
		-- { "Dragon's Breath", CheckInteractDistance("target", 3) == 1 }, 
		-- { "Flamestrike", jps.MultiTarget },
		
		-- Evocation whenever you're missing the damage buff.
		-- ** Important ** This assumes you have the Invocation talent. Comment this line our if you don't.
		{ "Evocation",
			not jps.buff("Invoker's Energy")
			and jps.cooldown("Evocation") == 0
			and not jps.buff("Presence of Mind") },

		-- Combustion is now based only off ignite. It would be nice if we could judge the size of the ignite though.
		{ "Combustion", 
			jps.UseCDs
			and jps.debuffDuration("Ignite") > 0 },
		
		-- Mirror Image is a minor DPS increase.
		{ "Mirror Image", 
			jps.UseCDs },

		-- PoM for insta-pyro. (talent based)
		{ "Presence of Mind",
			not jps.buff("Pyroblast!") },

		-- Engineers may have synapse springs on their gloves (slot 10).
    { jps.useSlot(10), 
      jps.UseCDs
      and not castingSpell == "Evocation"
      and ( jps.buff("Heating Up")
      	or jps.buff("Pyroblast!")
      	or jps.buff("Presence of Mind")
      ) },

		-- On-use Trinkets when we have a damage buff.
    { jps.useSlot(13), 
      jps.UseCDs
      and not castingSpell == "Evocation"
      and ( jps.buff("Heating Up")
      	or jps.buff("Pyroblast!")
      	or jps.buff("Presence of Mind")
      ) },
    { jps.useSlot(14), 
      jps.UseCDs
      and not castingSpell == "Evocation"
      and ( jps.buff("Heating Up")
      	or jps.buff("Pyroblast!")
      	or jps.buff("Presence of Mind")
      ) },

    -- Lifeblood on cooldown. (profession based)
    { "Lifeblood",
      jps.UseCDs
      and not castingSpell == "Evocation" },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
      jps.UseCDs
      and not castingSpell == "Evocation" },

		-- Pyroblast whenever we proc Pyroblast! or if we're using Presence of Mind.
		{ "Pyroblast", 
			jps.buff("Pyroblast!")
			or jps.buff("Presence of Mind") },

		-- Living Bomb. (talent based)
		{ "Living Bomb", 
			jps.debuffDuration("Living Bomb") < 1 },

		-- Frost Bomb. (talent based)
		{ "Frost Bomb", 
			jps.debuffDuration("Frost Bomb") == 0 },

		-- Nether Tempest. (talent based)
		{ "Nether Tempest", 
			jps.debuffDuration("Nether Tempest") < 1 },

		-- Inferno Blast whenever we proc Heating Up.
		{ "Inferno Blast", 
			jps.buff("Heating Up") },

		-- Scorch if we're moving.
		{ "Scorch", 
			jps.Moving },

		-- Fireball if we're standing still.
		{ "Fireball" },
		
	}
   local spell,target = parseSpellTable(possibleSpells)
   if spell == "Flamestrike" then
       jps.Cast( spell )
       jps.groundClick()
   end

   jps.Target = target
   return spell
end
