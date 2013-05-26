-- tropic (original by jpganis)
-- Ty to SIMCRAFT for this rotation
function dk_unholy(self)
	-- INFO --
	-- Shift-key to cast Death and Decay
	-- Ctrl-key to heal ghoul pet with death coil
	-- Alt-key + mouseover to combat ress another player (Raise Ally) - You can mouseover the 
	--   player corpse or player frame in the party/raid frame
	-- Set "focus" for dark simulacrum (duplicate spell) (this is optional, default is current target)
	-- Automatically raise ghoul if dead

  if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
  
	local runicPower = UnitPower("player")

	local frostFeverDuration = jps.debuffDuration("Frost Fever")
	local bloodPlagueDuration = jps.debuffDuration("Blood Plague")

	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local ur1 = select(3,GetRuneCooldown(3))
	local ur2 = select(3,GetRuneCooldown(4))
	local fr1 = select(3,GetRuneCooldown(5))
	local fr2 = select(3,GetRuneCooldown(6))
	local one_dr = dr1 or dr2
	local two_dr = dr1 and dr2
	local one_fr = fr1 or fr2
	local two_fr = fr1 and fr2
	local one_ur = ur1 or ur2
	local two_ur = ur1 and ur2

	local possibleSpells = {
    
		{ "Death and Decay",
  	  IsShiftKeyDown() ~= nil
      and GetCurrentKeyBoardFocus() == nil },
    
		{ "Unholy Frenzy" },
    
		{ "Outbreak",
      frostFeverDuration < 3
      or bloodPlagueDuration < 3 },
    
		{ "Soul Reaper",
      jps.hp("target") <= .35 },
    
		-- Kick
		{ "Mind Freeze",
      jps.shouldKick()
      and jps.LastCast ~= "Strangulate"
      and jps.LastCast ~= "Asphyxiate" },
    
    -- Kick
		{ "Strangulate",
      jps.shouldKick() 
      and jps.LastCast ~= "Mind Freeze"
      and jps.LastCast ~= "Asphyxiate" },
      
    -- Kick
		{ "Asphyxiate",
      jps.shouldKick() 
      and jps.LastCast ~= "Mind Freeze"
      and jps.LastCast ~= "Strangulate" },
        
    -- On-Use Trinket 1.
    { jps.useSlot(13), 
      jps.UseCDs },

    -- On-Use Trinket 2.
    { jps.useSlot(14), 
      jps.UseCDs },

    -- Engineers may have synapse springs on their gloves (slot 10).
    { jps.useSlot(10), 
      jps.UseCDs },

    -- Herbalists have Lifeblood.
    { "Lifeblood",
      jps.UseCDs },
        
		{ "Unholy Blight",
      frostFeverDuration < 3 
      or bloodPlagueDuration < 3 },
    
		{ "Icy Touch",
      frostFeverDuration <= 0 },
    
		{ "Plague Strike",
      bloodPlagueDuration <= 0 },
    
		{ "Plague Leech",
      jps.cd("Outbreak") < 1 },
    
		{ "Summon Gargoyle" },
    
		{ "Dark Transformation" },
    
		{ "Empower Rune Weapon" },
    
		{ "Scourge Strike",
      two_ur 
      and runicPower < 90 },
    
		{ "Festering Strike",
      two_dr 
      and two_fr 
      and runicPower < 90 },
    
		{ "Death Coil",
      runicPower > 90
      or jps.buff("sudden doom") },
    
		{ "Blood Tap" },
    
		{ "Scourge Strike" },
    
		{ "Festering Strike" },
    
		{ "Death Coil",
      jps.cd("Summon Gargoyle") > 8 },
    
		{ "Horn of Winter" },
    
		{ "Empower Rune Weapon" },
    
	}

	local spell = parseSpellTable(possibleSpells)
	
	if spell == "Death and Decay" then
    jps.groundClick() 
  end
	
	return spell

end
