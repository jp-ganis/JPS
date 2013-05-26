function shaman_resto(self)
  
  -- Healer
	local me = "player"

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
	if jps.hpInc(me) < .4 then
    healTarget = me
  end

	-- Get the health of our heal target.
	local healTargetHP = jps.hpInc(healTarget)
  
  -- Check for a dispel target.
  local dispelTarget = jps.FindMeADispelTarget({"Magic"}, {"Curse"})
  
  -- Weapon enchants
  local mh, _, _, oh, _, _, _, _, _ = GetWeaponEnchantInfo()
  
  -- Totems
  local _, fireTotem, _, _, _ = GetTotemInfo(1)
  local _, earthTotem, _, _, _ = GetTotemInfo(2)
  local _, waterName, _, _, _ = GetTotemInfo(3)
  local _, airTotem, _, _, _ = GetTotemInfo(4)

  local fireTotemActive = fireTotem ~= ""
  local earthTotemActive = earthTotem ~= ""
  local waterTotemActive = waterName ~= ""
  local airTotemActive = airTotem ~= ""
	
  -- Fear
  local feared = jps.debuff("Fear") or jps.debuff("Intimidating Shout") or jps.debuff("Howl of Terror") or jps.debuff("Psychic Scream")
  
  -- Priority Table
  local possibleSpells = {
    
    -- Healing Rain when holding shift.
    { "Healing Rain",
      IsShiftKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil },
      
    -- Water Shield at all times.
    { "Water Shield",
      not jps.buff("Water Shield")
      and not jps.buff("Earth Shield") },
    
    -- Earthliving Weapon at all times.
    { "Earthliving Weapon", not mh },
			
    -- Earth Shield the tank.
    { "Earth Shield",
      not jps.buff("Earth Shield", tank), tank },
		
    -- Tremor Totem if we're feared.
    { "Tremor Totem", feared },
        
    -- Purify Spirit if we have a dispel target.
    { "Purify Spirit",
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
    
    -- Ancestral Swiftness for a instant big heal. (talent based)
    { "Ancestral Swiftness",
      jps.UseCDs
      and healTargetHP < .4 },
    
    -- Greater Healing Wave is our big heal.
    { "Greater Healing Wave",
      healTargetHP < .45
      or jps.buff("Ancestral Swiftness"), healTarget },
    
    -- Spirit Link Totem when we're in trouble.
    { "Spirit Link Totem",
      jps.UseCDs
      and healTargetHP < .4
      and not airTotemActive },
        
    -- Healing Tide Totem for a big heal.
    { "Healing Tide Totem",
      jps.UseCDs
      and healTargetHP < .5
      and not waterTotemActive },
    
    -- Healing Stream Totem for a decent hot.
    { "Healing Stream Totem",
      healTargetHP < .7
      and not waterTotemActive },
    
    -- Earth Elemental Totem during BL.
    { "Earth Elemental Totem",
      jps.UseCDs
      and jps.bloodlusting()
      and not earthTotemActive },
    
    -- Stormlash Totem during BL.
    { "Stormlash Totem",
       jps.UseCDs
       and jps.bloodlusting() },
             
    -- Spiritwalker's Grace if we're moving and need to heal.
    { "Spiritwalker's Grace",
      jps.UseCDs
      and jps.Moving 
      and healTargetHP < .75 },
		
    -- Chain Heal the tank when more than just the tank has taken damage.
    { "Chain Heal",
      jps.MultiTarget
      and healTargetHP < .75
      and tank < .9
      and healTarget ~= tank, tank },
    
    -- Riptide a lot.
    { "Riptide",
      healTargetHP < .9
      and not jps.buff("Riptide", healTarget), healTarget },
    
    -- Fire Elemental Totem
    { "Fire Elemental Totem",
      jps.UseCDs },
        
    -- Magma Totem when we need AoE
    { "Magma Totem",
      jps.MultiTarget 
      and fireTotem ~= "Magma Totem" 
      and fireTotem ~= "Fire Elemental Totem" },
    
    -- Searing Totem as our default fire totem.
    { "Searing Totem", not fireTotemActive },
    
    -- Healing wave is our light heal.
    { "Healing Wave",
      healTargetHP < .87, healTarget },
    
    -- Lightning Bolt for mana as filler.
    { "Lightning Bolt",
       jps.mana() < .98 },
		
  }
	
	local spell, target = parseSpellTable(possibleSpells)
  jps.Target = target
  
  if spell == "Healing Rain" then
    jps.groundClick()
  end
  
  -- Debug
  if IsAltKeyDown() ~= nil and spell then
    print( string.format("Healing: %s, Health: %s, Spell: %s", healTarget, healTargetHP, spell) )
  end
  
  return spell	
end
