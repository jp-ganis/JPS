-- Talents:
-- Tier 1: Scorch or Presence of Mind (Prefer Scorch)
-- Tier 2: Ice Barrier (Optional)
-- Tier 3: Ice Ward (Optional) 
-- Tier 4: Cauterize (Optional) 
-- Tier 5: Living Bomb (Optional)
-- Tier 6: Rune of Power or Incanter's Ward (Do NOT take Invocation with this rotation)

-- Glyphs:
-- Major: Fire Blast (required), Mana Gem (recommended), Evocation (recommended)
-- Minor: Mirror Image (recommended), Momentum (recommended), and whatever you like.
function mage_arcane(self)

	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end

	local castingSpell, _, _, _, _, endTime = UnitCastingInfo("player")
  
  local evocating = (castingSpell == "Evocation")
  local atActive = jps.buff("Altered Time")
  local pomActive = jps.buff("Presence of Mind")
  local apActive = jps.buff("Arcane Power")
  local arcaneCharges = jps.debuffStacks("Arcane Charge", "player") -- Note: Arcane Charge is considered a debuff.
  local amStacks = jps.buffStacks("Arcane Missiles!")
  
	local possibleSpells = {

		-- Mage Armor if you forgot to buff it.
		{ "Mage Armor", 
			not jps.buff("Mage Armor")
      and not atActive },

		-- Arcane Brilliance if you forgot to buff it.
		{ "Arcane Brilliance", 
			not jps.buff("Arcane Brilliance")
      and not atActive },
      
		-- Flamestrike (targeted) when holding down shift.
		{ "Flamestrike", 
		  IsShiftKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil
      and not jps.Moving },
    
		-- Rune of Power (targeted) when holding down alt. (talent based)
		{ "Rune of Power", 
			IsAltKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil
      and not jps.Moving },
    
		-- Ice Block when you're about to die.
		{ "Ice Block",
			jps.hp() < .3
			and not jps.buff("Ice Block")
			and not jps.debuff("Hypothermia") },

    -- Cancel Ice Block once we've been healed up enough.
		{ { "macro", "/cancelaura Ice Block" }, 
			jps.hp() > .8
			and jps.buff("Ice Block") },

    -- Healthstone if you get low.
    { "Healthstone",
      jps.hp() < .5
      and GetItemCount("Healthstone", 0, 1) > 0 },
        
		-- Refresh your Ice block. (talent based)
		{ "Cold Snap",
			jps.cooldown("Ice Block") > 0
			and jps.cooldown("Cold Snap") == 0 },
		
		-- Incanter's Ward when you're taking some damage. (talent based)
		{ "Incanter's Ward",
			jps.hp() < .9
      and jps.mana() < .94
      and arcaneCharges >= 4
      and not atActive },
    
		-- Ice Barrier when you're taking some damage. (talent based)
		{ "Ice Barrier",
			jps.hp() < .85
      and not atActive },

    -- Use a mana gem to keep your mana topped up. Brilliant is talent based.
    { "Brilliant Mana Gem",
      jps.mana() < .87
      and not atActive
      and GetItemCount("Brilliant Mana Gem", 0, 1) > 0 },
    
    -- Use a mana gem to keep your mana topped up.
    { "Mana Gem",
      jps.mana() < .87
      and not atActive
      and GetItemCount("Mana Gem", 0, 1) > 0 },
    
		-- Interrupts.
		{ "Counterspell", 
			jps.Interrupts 
      and jps.shouldKick() },
    
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
      and jps.hp("target") > .2
      and not evocating },

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
    
    -- ****
    -- Cooldown stacking starts.
    
		-- Arcane Power when we have 6 charges and 2 stacks.
		{ "Arcane Power",
			jps.UseCDs
      and not atActive
      and arcaneCharges == 6
      and amStacks == 2 },

		-- Engineers may have synapse springs on their gloves (slot 10).
    { jps.useSlot(10), 
      apActive
      and not ( evocating 
        or atActive ) },

		-- On-use Trinkets when we have a damage buff.
    { jps.useSlot(13), 
      apActive
      and not ( evocating 
        or atActive ) },
    { jps.useSlot(14), 
      apActive
      and not ( evocating 
        or atActive ) },

    -- Lifeblood on cooldown. (profession based)
    { "Lifeblood",
      apActive
      and not ( evocating 
        or atActive ) },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
      jps.UseCDs
      and not evocating },

		-- PoM for insta-something. (talent based)
		{ "Presence of Mind",
			apActive
      and not atActive },
    
    -- Arcane Power when arcane power is active and we still have our charges and stacks.
    { "Alter Time",
      apActive
      and arcaneCharges == 6
      and amStacks == 2 },
    
    -- Cooldown stacking ends.
    -- ****
    
    -- Arcane Missile once we have 2 stacks, or if we have the altered time buff (no point in saving stacks).
    { "Arcane Missiles",
      not jps.Moving
      and ( atActive 
        or amStacks == 2 ) },
    
    -- Arcane Barrage once we have full arcane charges and no missile stacks. This won't happen very often.
    { "Arcane Barrage",
      atActive
      and amStacks == 0
      and arcaneCharges == 6 },
    
    -- Spread Living Bomb with Fireblast (talent and glyph based).
    { "Fire Blast", 
      jps.MultiTarget 
      and jps.debuff("Living Bomb") },
        
    -- Ice Ward for a big nova on the tank if we're multi target. (talent based)
    { { "macro", "/cast [help][@targettarget,help] Ice Ward" },
      jps.MultiTarget
      and jps.cooldown("Ice Ward") == 0 },
    
		-- Scorch if we're moving or drop below 90% mana. (talent based)
		{ "Scorch", 
			jps.Moving
      or jps.mana() < .9 },

		-- Arcane Blast as our default.
		{ "Arcane Blast",
      not jps.Moving },
		
	}
  
	local spell, target = parseSpellTable(possibleSpells)
	jps.Target = target
	
  if spell == "Flamestrike" or spell == "Rune of Power" then
    jps.groundClick()
  end
  
	return spell
  
end
