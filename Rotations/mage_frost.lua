function mage_frost(self)

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
  
	local castingSpell, _, _, _, _, endTime = UnitCastingInfo("player")
  
  local evocating = (castingSpell == "Evocation")
  local atActive = jps.buff("Altered Time")
  local pomActive = jps.buff("Presence of Mind")
  local fofActive = jps.buff("Fingers of Frost")
  local bfActive = jps.buff("Brain Freeze")
  local ivActive = jps.buff("Icy Veins")
  
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
			and jps.cooldown("Cold Snap") == 0 },
		
		-- Ice Barrier when you're taking a decent amount of damage. (talent based)
		{ "Ice Barrier",
			jps.hp() < .7
			and not jps.buff("Ice Barrier") },

		-- Interrupts.
		{ "Counterspell", 
			jps.Interrupts 
      and jps.shouldKick() },

		-- Molten Armor if you forgot to buff it.
		{ "Molten Armor", 
			not jps.buff("Molten Armor")
			and not pomActive },

		-- Arcane Brilliance if you forgot to buff it.
		{ "Arcane Brilliance", 
			not jps.buff("Arcane Brilliance"), "player" },
    
		-- Evocation whenever you're missing the damage buff.
		-- ** Important ** This assumes you have the Invocation talent. Comment this line our if you don't.
		{ "Evocation",
      jps.UseCDs
			and not jps.buff("Invoker's Energy")
			and jps.cooldown("Evocation") == 0
			and not pomActive },
    
		-- Mirror Image is a minor DPS increase.
		{ "Mirror Image", 
			jps.UseCDs
      and not ( evocating or atActive ) },

		-- PoM for insta-frostbolt. (talent based)
		{ "Presence of Mind",
      jps.UseCDs
      and not ( evocating or atActive ) },
    
		-- Icy Veins for haste buff.
		{ "Icy Veins",
      jps.UseCDs
      and not ( evocating or atActive ) },

		-- Engineers may have synapse springs on their gloves (slot 10).
    { jps.useSlot(10), 
      jps.UseCDs
      and not ( evocating or atActive )
      and ( fofActive or pomActive or ivActive ) },

		-- On-use Trinkets when we have a damage buff.
    { jps.useSlot(13), 
      jps.UseCDs
      and not ( evocating or atActive )
      and ( fofActive or pomActive or ivActive ) },
    { jps.useSlot(14), 
      jps.UseCDs
      and not ( evocating or atActive )
      and ( fofActive	or pomActive or ivActive ) },

    -- Lifeblood on cooldown. (profession based)
    { "Lifeblood",
      jps.UseCDs
      and not ( evocating or atActive ) },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
      jps.UseCDs
      and not evocating },
		
    -- Alter Time whenver we have decent buffs.
    { "Alter Time",
      jps.UseCDs
      and not evocating
      and ( fofActive or bfActive or pomActive or ivActive ) },
    
    -- Instant Frostfire Bolt when we have Brain Freeze buff.
		{ "Frostfire Bolt", 
      bfActive or pomActive },
    
    -- Ice Lance when we have Fingers of Frost buff.
		{ "Ice Lance", 
      fofActive },
    
		-- Living Bomb. (talent based)
		{ "Living Bomb", 
			jps.debuffDuration("Living Bomb") < 1 },

		-- Frost Bomb. (talent based)
		{ "Frost Bomb", 
			jps.debuffDuration("Frost Bomb") == 0 },

		-- Nether Tempest. (talent based)
		{ "Nether Tempest", 
			jps.debuffDuration("Nether Tempest") < 1 },
    
		-- Frozen Orb
		{ "Frozen Orb", 
			jps.UseCDs },
        
    -- Frostbolt if we're not moving.
		{ "Frostbolt", not jps.Moving },
    
    -- Scorch if we are moving. (talent based)
		{ "Scorch", jps.Moving },
    
    -- Ice Lance if we are moving.
		{ "Ice Lance", jps.Moving },
    
	}
  
  return parseSpellTable(possibleSpells)
  
end
