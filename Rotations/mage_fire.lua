function mage_fire(self)

	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end

	local castingSpell, _, _, _, _, endTime = UnitCastingInfo("player")
  
  local evocating = (castingSpell == "Evocation")
  local atActive = jps.buff("Altered Time")
  local pomActive = jps.buff("Presence of Mind")
  local pyroActive = jps.buff("Pyroblast!")
  
  -- How big should ignite damage be before we combust.
  local combustAt = 12000
  local igniteAmount = jps.getIgniteAmount()
  
  -- if igniteAmount > combustAt then
  --   print("We have an ignite of: " .. igniteAmount .. ", so let's combust" )
  -- end
  
	local possibleSpells = {

		-- Flamestrike when holding down shift.
		{ "Flamestrike", 
		  IsShiftKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil
      and not jps.Moving },
    
		-- Rune of Power when holding down alt. (talent based)
		{ "Rune of Power", 
			IsAltKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil
      and not jps.Moving },
		
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
		
		-- Incanter's Ward when you're taking some damage. (talent based)
		{ "Incanter's Ward",
			jps.hp() < .9
      and not atActive },
    
		-- Ice Barrier when you're taking some damage. (talent based)
		{ "Ice Barrier",
			jps.hp() < .85 },

		-- Interrupts.
		{ "Counterspell", 
			jps.Interrupts 
      and jps.shouldKick() },

		-- Molten Armor if you forgot to buff it.
		{ "Molten Armor", 
			not jps.buff("Molten Armor")
      and not jps.Moving },

		-- Arcane Brilliance if you forgot to buff it.
		{ "Arcane Brilliance", 
			not jps.buff("Arcane Brilliance"), "player" },
        
		-- Evocation whenever you're missing the damage buff.
		-- ** Important ** This assumes you have the Invocation talent. Comment this line our if you don't.
    -- If you have the talent Rune of Power and find yourself casting it over and over again, it's because
    -- it replaces Evocation and the following command will keep casting it because you don't have Invoker's Energy,
    -- real pain to track down...
		--{ "Evocation",
    -- jps.UseCDs
    -- and not jps.Moving
		--	and not jps.buff("Invoker's Energy")
		--	and jps.cooldown("Evocation") == 0
		--	and not pomActive },

		-- Combustion is now based only off ignite damage.
		{ "Combustion", 
			jps.UseCDs
			and jps.debuffDuration("Ignite") > 0
      and igniteAmount > combustAt },
		
		-- Mirror Image is a minor DPS increase.
		{ "Mirror Image", 
			jps.UseCDs
      and jps.hp("target") > .2
      and not evocating },

		-- PoM for insta-pyro. (talent based)
		{ "Presence of Mind",
			not ( evocating or atActive ) },

		-- Engineers may have synapse springs on their gloves (slot 10).
    { jps.useSlot(10), 
      jps.UseCDs
      and not ( evocating or atActive )
      and ( pyroActive or pomActive ) },

		-- On-use Trinkets when we have a damage buff.
    { jps.useSlot(13), 
      jps.UseCDs
      and not ( evocating or atActive )
      and ( pyroActive or pomActive ) },
    { jps.useSlot(14), 
      jps.UseCDs
      and not ( evocating or atActive )
      and ( pyroActive or pomActive ) },

    -- Lifeblood on cooldown. (profession based)
    { "Lifeblood",
      jps.UseCDs
      and not ( evocating or atActive ) },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
      jps.UseCDs
      and not ( evocating or atActive ) },

    -- Alter Time whenver we have decent buffs.
    { "Alter Time",
      jps.UseCDs
      and not evocating
      and ( pyroActive or pomActive ) },
    
		-- Pyroblast whenever we proc Pyroblast! or if we're using Presence of Mind.
		{ "Pyroblast", 
			pyroActive
      or pomActive },

		-- Living Bomb. (talent based)
		{ "Living Bomb", 
			jps.debuffDuration("Living Bomb") < 1 },

		-- Frost Bomb. (talent based)
		{ "Frost Bomb", 
			jps.debuffDuration("Frost Bomb") == 0
      and not jps.Moving },

		-- Nether Tempest. (talent based)
		{ "Nether Tempest", 
			jps.debuffDuration("Nether Tempest") < 1 },

		-- Inferno Blast whenever we proc Heating Up.
		{ "Inferno Blast", 
			jps.buff("Heating Up") },

    -- Ice Ward for a big nova on the tank if we're multi target. (talent based)
    { "Ice Ward",
      jps.MultiTarget,
      jps.findMeATank() },
        
		-- Scorch if we're moving.
		{ "Scorch", 
			jps.Moving },

		-- Fireball if we're standing still.
		{ "Fireball" },
		
	}
  
	local spell, target = parseSpellTable(possibleSpells)
	jps.Target = target
	
  if spell == "Flamestrike" or spell == "Rune of Power" then
    jps.groundClick()
  end
  
	return spell
  
end
