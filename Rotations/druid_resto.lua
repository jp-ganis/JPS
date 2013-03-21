function druid_resto(self)
	-- INFO --
	-- jps.MultiTarget to Wild Regrowth
	-- Use Innervate and Tranquility manually

	local me = "player"

	-- Tank is focus.
	local tank = jps.findMeATank()
  local tankHP = jps.hpInc(tank)
  
  -- Check if we should cleanse
  local cleanseTarget = nil
  local hasSacredCleansingTalent = 0
  _,_,_,_,hasSacredCleansingTalent = 1 -- GetTalentInfo(1,14) JPTODO: find the resto talent
  if hasSacredCleansingTalent == 1 then
    cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Curse"},{"Magic"})
  else
    cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Curse"})
  end

	-- Default to healing lowest partymember
	local defaultTarget = jps.lowestInRaidStatus()

	-- Check that the tank isn't going critical, and that I'm not about to die
  if jps.canHeal(tank) and tankHP <= .5 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	-- Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)

  local defensiveCDActive = jps.buff("Ironbark", defaultTarget) or jps.buff("Nature's Vigil") or jps.buff("Incarnation: Tree of Life")
	
	local possibleSpells = {
    
		-- Do nothing if we're not in a healing form.
	  { nil, 
	  	jps.buff("Bear Form")
      or jps.buff("Aquatic Form")
      or jps.buff("Cat Form")
      or jps.buff("Travel Form")
      or jps.buff("Swift Flight Form") },
    
		-- Rebirth Ctrl-key + mouseover
		{ "Rebirth",
      IsControlKeyDown() ~= nil 
      and UnitIsDeadOrGhost("mouseover") ~= nil 
      and IsSpellInRange("Rebirth", "mouseover"), "mouseover" },

    -- Barkskin
		{ "Barkskin",
      jps.UseCDs
      and jps.hp() < .5 },
    
    -- Ironbark
    { "Ironbark",
      jps.UseCDs
      and defaultHP < .5
      and not defensiveCDActive, defaultTarget },
    
    -- Tree of Life (talent based).
		{ "Incarnation: Tree of Life",
      jps.UseCDs
      and defaultHP < .5
      and not defensiveCDActive },

    -- Nature's Vigil
    { "Nature's Vigil",
      jps.UseCDs
      and defaultHP < .5
      and not defensiveCDActive, defaultTarget },
    
    -- Healthstone if you get low.
    { "Healthstone",
      jps.hp() < .5
      and GetItemCount("Healthstone", 0, 1) > 0 },
    
    -- Innervate
		{ "Innervate",
      jps.UseCDs
      and jps.mana() < .75, me },
    
    -- Swiftmend on lowest target. This is a hefty heal and helps us keep harmony up. We want to use it a lot.
		{ "Swiftmend",
      defaultHP < .85
      and (
        jps.buff("Rejuvenation", defaultTarget)
        or jps.buff("Regrowth", defaultTarget)
      ), defaultTarget },
    
    -- Nature's Swiftness
		{ "Nature's Swiftness", 
      jps.UseCDs
      and defaultHP < .4 },
    
    -- Healing Touch when needed and we have Nature's Swiftness buff.
		{ "Healing Touch",
      defaultHP < .8
      and jps.buff("Nature's Swiftness"), defaultTarget },
        
    -- Regrowth when needed.
		{ "Regrowth",
      not jps.Moving
      and defaultHP < .45, defaultTarget },
    
    -- Regrowth during clearcasting procs.
		{ "Regrowth",
      not jps.Moving
      and defaultHP < .9
      and jps.buff("clearcasting"), defaultTarget },
    
    -- Regrowth if clearcasting is about to drop.
		{ "Regrowth",
      not jps.Moving
      and jps.buff("clearcasting")
      and jps.buffDuration("clearcasting") < 2.5, defaultTarget },
    
    -- Nourish if Harmony buff fell off.
		{ "Nourish",
      not jps.buff("Harmony")
      and not jps.Moving, tank },
    
		-- On-Use Trinkets.
    { jps.useTrinket(1), 
      jps.UseCDs
      and defaultHP < .7 },
    { jps.useTrinket(2), 
      jps.UseCDs
      and defaultHP < .7 },

		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), 
      jps.UseCDs
      and defaultHP < .7 },

		-- Lifeblood (requires herbalism)
		{ "Lifeblood",
			jps.UseCDs
			and defaultHP < .7 },
    
    -- Decurse
		{ "Remove Corruption",
      cleanseTarget ~= nil, cleanseTarget },
    
    -- Lifebloom stacks on tank.
		{ "Lifebloom",
      tankHP < 1
      and (
        jps.buffDuration("Lifebloom", tank) < 2
        or jps.buffStacks("Lifebloom", tank) < 3
      ), tank },
            
    -- Wild Growth on lowest target.
		{ "Wild Growth",
      defaultHP < .9
      and jps.MultiTarget, defaultTarget },
    
    -- Rejuvenation on lowest target.
		{ "Rejuvenation",
      defaultHP < .85
      and not jps.buff("Rejuvenation", defaultTarget), defaultTarget },
    
    -- Rejuvenation on tank.
		{ "Rejuvenation",
      tankHP < .9
      and (
        not jps.buff("Rejuvenation", tank)
        or jps.buffDuration("Rejuvenation", tank) < 1.5
      ), tank },
    
		-- DPS Racial
		{ jps.DPSRacial, 
			jps.UseCDs },
    
    -- Nourish as tank filler.
		{ "Nourish",
      tankHP < .85
      and not jps.Moving, tank },
	}

	local spell, target = parseSpellTable(possibleSpells)
	jps.Target = target
	return spell
	
end
