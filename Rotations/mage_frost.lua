function mage_frost(self)

	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
  
	local castingSpell, _, _, _, _, endTime = UnitCastingInfo("player")
  
  local evocating = (castingSpell == "Evocation")
  local atActive = jps.buff("Altered Time")
  local pomActive = jps.buff("Presence of Mind")
  local fofActive = jps.buff("Fingers of Frost")
  local bfActive = jps.buff("Brain Freeze")
  local ivActive = jps.buff("Icy Veins")
  
  local targetType = UnitClassification("target")
  local onBoss = (targetType == 'worldboss')
  
	local possibleSpells = {

		-- Flamestrike when holding down shift.
		{ "Flamestrike", 
		  IsShiftKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil },
    
		-- Freeze when holding down control.
		{ "Freeze", 
			IsControlKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil },
    
		-- Rune of Power when holding down alt. (talent based)
		{ "Rune of Power", 
			IsAltKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil },
      
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
			not jps.buff("Molten Armor") },

		-- Arcane Brilliance if you forgot to buff it.
		{ "Arcane Brilliance", 
			not jps.buff("Arcane Brilliance"), "player" },
    
		-- Rune of Power whenever it runs out if we're not moving. (talent based)
    -- This is going to drop it whever the mouse currently is, 
    -- so either keep your mouse over your mage, or remove this rule.
		{ "Rune of Power", 
			not jps.buff("Rune of Power")
      and not jps.Moving },
        
		-- Evocation whenever you're missing the damage buff.
		-- ** Important ** This assumes you have the Invocation talent. Comment this line our if you don't.
    -- If you have the talent Rune of Power and find yourself casting it over and over again, it's because
    -- it replaces Evocation and the following command will keep casting it because you don't have Invoker's Energy,
    -- real pain to track down...
		-- { "Evocation",
    --  jps.UseCDs
    --  and not jps.Moving
		--	and not jps.buff("Invoker's Energy")
		--	and jps.cooldown("Evocation") == 0
		--	and not pomActive },
    
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
      and ( ( fofActive and bfActive ) or ivActive ) },
    
    -- Instant Frostfire Bolt when we have Brain Freeze buff.
		{ "Frostfire Bolt", 
      bfActive or pomActive },
    
    -- Ice Lance when we have Fingers of Frost buff.
		{ "Ice Lance", 
      fofActive },
    
    -- Spread Living Bomb with Fireblast (talent and glyph based).
    { "Fire Blast", 
      jps.MultiTarget 
      and jps.debuff("Living Bomb") },
    
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
    
    -- Ice Ward for a big nova on the tank if we're multi target. (talent based)
    { "Ice Ward",
      jps.MultiTarget,
      jps.findMeATank() },
    
    -- Scorch if we are moving. (talent based)
		{ "Scorch", jps.Moving },
    
    -- Ice Lance if we are moving and don't have scorch.
		{ "Ice Lance", jps.Moving },
    
    -- Frostbolt filler.
		{ "Frostbolt" },
	}
  
	local spell, target = parseSpellTable(possibleSpells)
	jps.Target = target
  
  if spell == "Flamestrike" or spell == "Rune of Power" or spell == "Freeze" then
    jps.groundClick()
  end
  
	return spell
  
end
