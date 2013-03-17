-- Shift-key to cast Death and Decay
function dk_frost(self)
	
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
    
		-- Death and Decay when shift is down.
		{ "Death and Decay",
      IsShiftKeyDown() ~= nil 
      and GetCurrentKeyBoardFocus() == nil },
    
    -- Army of the Dead when control is down.
    { "Army of the Dead",
      IsLeftControlKeyDown() ~= nil 
      and GetCurrentKeyBoardFocus() == nil },
    
    -- Empower Rune Weapon
    { "Empower Rune Weapon",
      jps.UseCDs
      and runicPower <= 25
      and not two_dr
      and not two_fr
      and not two_ur },
    
    -- Pillar of Frost
    { "Pillar of Frost",
      jps.UseCDs },
    
    -- Raise Dead when Pillar of Frost is active.
    { "Raise Dead",
      jps.UseCDs
      and jps.buff("Pillar of Frost") },
        
    -- Outbreak to keep diseases up.
		{ "Outbreak",
      frostFeverDuration < 3
      or bloodPlagueDuration < 3 },
    
    -- Soul Reaper when the target is below 35% health.
    { "Soul Reaper",
      jps.hp("target") < .35 },
    
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
    
    -- Raise Dead
		{ "Raise Dead",
      jps.UseCDs 
      and UnitExists("pet") == nil },
        
    -- Unholy Blight to keep diseases up. (talent based)
		{ "Unholy Blight",
      frostFeverDuration < 3 
      or bloodPlagueDuration < 3 },
        
    -- On-Use Trinket 1.
    { jps.useSlot(13), 
      jps.UseCDs },

    -- On-Use Trinket 2.
    { jps.useSlot(14), 
      jps.UseCDs },

		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), 
      jps.UseCDs },
    

    -- Herbalists have Lifeblood.
    { "Lifeblood",
      jps.UseCDs },
        
    -- Howling Blast to keep frost fever up or when you have a Rime proc.
		{ "Howling Blast",
      frostFeverDuration <= 0
      or jps.buff("Rime") },
    
    -- Plague Strike to keep blood plague up.
		{ "Plague Strike",
      bloodPlagueDuration <= 0 },
    
    -- Death Siphon when we need a bit of healing. (talent based)
		{ "Death Siphon",
      jps.hp() < .8 },
        
    -- Death strike when we need a bit of healing.
		{ "Death Strike",
      jps.hp() < .7 },
        
    -- Dual wield specific. Disabling for now.
    -- Frost Strike when we have a Killing Machine proc.
		-- { "Frost Strike",
    --    jps.buff("Killing Machine") },
    
    -- Obliterate when you have a Killing Machine proc or you won't cap runic power.
		{ "Obliterate",
      jps.buff("Killing Machine")
      or runicPower < 60 },
    
    -- Frost Strike filler when available.
		{ "Frost Strike" },

    -- Howling Blast filler when available.
		{ "Howling Blast" },
    
    -- Horn of Winter filler when available.
		{ "Horn of Winter" },
    
	}

	local spell = parseSpellTable(possibleSpells)
	
	if spell == "Death and Decay" then
    jps.groundClick() 
  end
	
	return spell

end
