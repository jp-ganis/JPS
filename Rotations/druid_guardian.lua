function druid_guardian(self)
  
  if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
  
  -- Rage
	local rage = UnitMana("player")

	local possibleSpells = {
    
		-- Mark of the Wild if we forgot to buff it.
		{ "Mark of the Wild", 
			not jps.buff("Mark of the Wild") },
        
		-- Bear Form
	  { "Bear Form", 
	  	not jps.buff("Bear Form") },
    
    -- Might of Ursoc
		{ "Might of Ursoc",
      jps.hp() < .4 },
    
    -- Survival Instincts
		{ "Survival Instincts",
      jps.hp() < .5 },
    
    -- Life Spirit if we get low.
    { "Life Spirit",
      jps.hp() < .5
      and GetItemCount("Life Spirit", 0, 1) > 0 },
    
    -- Healthstone if we get low.
    { "Healthstone",
      jps.hp() < .6
      and GetItemCount("Healthstone", 0, 1) > 0 },
            
    -- Barkskin
		{ "Barkskin",
      jps.hp() < .6 },
    
    -- Bail now if we aren't in melee range
		{ nil,
      IsSpellInRange("Mangle", "target") ~= 1 },
    
		-- Interrupts
		{ "Skull Bash", 
			jps.shouldKick() 
			and jps.Interrupts },

    -- Talent based stun.
		{ "Mighty Bash", 
			jps.shouldKick() 
			and jps.Interrupts },
		
		-- Healing Touch whenever we have Nature's Swiftness. (talent based)
		{ "Healing Touch", 
			jps.buff("Nature's Swiftness") },
		
		-- Nature's Swiftness
		{ "Nature's Swiftness",	
			jps.hp() < .8 },
    
    -- Renewal (talent based).
		{ "Renewal",
      jps.hp() < .3 },
        
		-- Frenzied Regeneration
		{ "Frenzied Regeneration",
      jps.hp() < .7
      and jps.buff("Savage Defense") },
    
    -- Savage Defense
		{ "Savage Defense",
      jps.hp() < .9 },
    
		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), 
      jps.UseCDs },
      
		-- On-Use Trinkets.
    { jps.useTrinket(1), 
      jps.UseCDs },
    { jps.useTrinket(2), 
      jps.UseCDs },

		-- DPS Racial.
		{ jps.DPSRacial, 
			jps.UseCDs },

		-- Lifeblood. (requires herbalism)
		{ "Lifeblood",
			jps.UseCDs },

		-- Treants (talent specific)
		{ "Force of Nature",
       jps.UseCDs },
    
 		-- Faerie Fire to keep Weakened Armor up.
 		{ "Faerie Fire",
       not jps.MultiTarget
       and not jps.debuff("Weakened Armor") },
    
		-- Berserk if thrash and weakened armor are already up.
		{ "Berserk",
      jps.UseCDs
      and jps.debuff("Thrash")
      and jps.debuff("Weakened Armor") },
    
    -- Mangle on cooldown.
    { "Mangle" },
    
    -- Thrash on cooldown.
		{ "Thrash" },
    
    -- Lacertate on cooldown for single-target.
		{ "Lacerate",
      not jps.MultiTarget },
    
    -- Maul when Tooth and Claw procs or as a rage dump.
    { "Maul", 
      not jps.MultiTarget
      and (
        jps.buff("Tooth and Claw")
        or rage > 80 ) },
    
    -- Enrage if we're low on rage.
		{ "Enrage",
      rage <= 20 },
    
    -- Swipe on cooldown.
    { "Swipe" },
	}

	return parseSpellTable(possibleSpells)
  
end
