function dk_frost()
	
	local spell = nil
	local target = nil	
	
	local runicPower = UnitPower("player")
	local frostFeverDuration = jps.debuffDuration("Frost Fever")
	local bloodPlagueDuration = jps.debuffDuration("Blood Plague")
	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local ur1 = select(3,GetRuneCooldown(3))
	local ur2 = select(3,GetRuneCooldown(4))
	local fr1 = select(3,GetRuneCooldown(5))
	local fr2 = select(3,GetRuneCooldown(6))
	local oneDr = dr1 or dr2
	local twoDr = dr1 and dr2
	local oneFr = fr1 or fr2
	local twoFr = fr1 and fr2
	local oneUr = ur1 or ur2
	local twoUr = ur1 and ur2
	local timeToDie = ternary(tonumber(_G.TimeToDie.dataobj.text) ~= nil, _G.TimeToDie.dataobj.text , 99999999);
	
	local enemyTargetingMe = jps.IstargetMe()

	local rangedTarget = "target"
	if jps.canDPS("target") then
		rangedTarget = "target"
	elseif jps.canDPS("focustarget") then
		rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
		rangedTarget = "targettarget"
	elseif jps.canDPS(enemyTargetingMe) then
		rangedTarget = enemyTargetingMe
	end

	jps.Macro("/target "..rangedTarget)
	
	
	------------------------
	-- SPELL TABLE ---------
	------------------------
	
	local spellTable = {}
	spellTable[1] =
	{	
		["ToolTip"] = "DK PVE Main",
		{ "Frost Presence", not jps.buff("Frost Presence") },
				
		{ "Horn of Winter", not jps.buff("Horn of Winter")  },
		{ "Death and Decay", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget },
					
		-- Self heal
		{ "Death Pact", jps.UseCDs and jps.hp() < .6 and UnitExists("pet") ~= nil },
		
		{ "Pillar of Frost", jps.UseCDs },
		{ jps.DPSRacial, jps.UseCDs },
		
		{ "Raise Dead", jps.UseCDs and UnitExists("pet") == nil },

		-- Rune Management
		{ "Plague Leech", frostFeverDuration > 0  and bloodPlagueDuration > 0 and frostFeverDuration < 1 and bloodPlagueDuration < 1}, 

		
		{ "Outbreak", frostFeverDuration < 1 or bloodPlagueDuration < 1 },
		
		{ "Soul Reaper", jps.hp("target") < .35 },

		-- Kick
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "Strangulate",		jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",		jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },
		
		-- Unholy Blight when our diseases are about to fall off. (talent based)
		{ "Unholy Blight", frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		
		-- On-use Trinkets.
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood", jps.UseCDs },
		
		-- Diseases
		{ "Howling Blast", frostFeverDuration <= 1 or (jps.buff("Freezing Fog") and runicPower < 88) },
		{ "Plague Strike", bloodPlagueDuration <= 1 },
		
		-- Self heals
		{ "Death Siphon", jps.hp() < .8 },
		{ "Death Strike", jps.hp() < .7 },
		
		-- Dual wield specific. Disabling for now.
		-- Frost Strike when we have a Killing Machine proc.
		-- { "Frost Strike",	jps.buff("Killing Machine") },
		{ "Obliterate", runicPower <= 76 or jps.buff("Killing Machine") or jps.bloodlusting(), rangedTarget},

		{ "Plague Leech", frostFeverDuration > 0  and bloodPlagueDuration > 0 and frostFeverDuration < 3 and bloodPlagueDuration < 3}, 
		
		{ "Outbreak", frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		
		-- Filler.
		{ "Horn of Winter", runicPower < 20 },
		
		{ "Frost Strike", runicPower >= 76 or jps.bloodlusting() or not oneFr, rangedTarget}, 
		
		{ "Frost Strike", (not jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1 ) or (jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1 ), rangedTarget},
		{ "Obliterate", "onCD", rangedTarget},
		{ "Empower Rune Weapon", jps.UseCDs and ((runicPower <= 25 and not twoDr and not twoFr and not twoUr) or (timeToDie < 60 and jps.buff("Potion of Mogu Power")) or jps.bloodlusting()) },
		{ "Frost Strike", "onCD" , rangedTarget},
		{ "Plague Leech","onCD",rangedTarget},
	}
	
	spellTable[2] =
	{
	
		["ToolTip"] = "DK PVP Main",

		{ "Horn of Winter", not jps.buff("Horn of Winter")  },
		{ "Death and Decay", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget },
					
		-- Self heal
		{ "Death Pact", jps.UseCDs and jps.hp() < .6 and UnitExists("pet") ~= nil },
		
		-- Rune Management
		{ "Plague Leech", (frostFeverDuration > 0  and bloodPlagueDuration > 0) and (not twodr or not twofr or not twour) and (frostFeverDuration < 3 and bloodPlagueDuration < 3) }, 
		
		{ "Pillar of Frost", jps.UseCDs },
		{ jps.DPSRacial, jps.UseCDs },
		
		{ "Raise Dead", jps.UseCDs and UnitExists("pet") == nil },
		
		-- If our diseases are about to fall off.
		{ "Outbreak", frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		
		{ "Soul Reaper", jps.hp("target") < .35 },
		
		-- Kick
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "Strangulate",		jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",		jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },
		
		-- Unholy Blight when our diseases are about to fall off. (talent based)
		{ "Unholy Blight", frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		
		-- On-use Trinkets.
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood", jps.UseCDs },
		
		-- Diseases
		{ "Necrotic Strike", not jps.debuff("Necrotic Strike",target)},
		{ "Howling Blast", frostFeverDuration <= 1 or (jps.buff("Freezing Fog") and runicPower < 88) },
		{ "Plague Strike", bloodPlagueDuration <= 1 },
		
		-- Self heals
		{ "Death Siphon", jps.hp() < .8 },
		{ "Death Strike", jps.hp() < .7 },
		
		-- Dual wield specific. Disabling for now.
		-- Frost Strike when we have a Killing Machine proc.
		-- { "Frost Strike",	jps.buff("Killing Machine") },
		{ "Obliterate", runicPower <= 76 or jps.buff("Killing Machine") or jps.bloodlusting()},
		-- Filler.
		{ "Horn of Winter", runicPower < 20 },
		
		{ "Frost Strike", runicPower >= 76 or jps.bloodlusting() or not oneFr}, 
		
		{ "Frost Strike", (not jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1 ) or (jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1 ) },
		{ "Obliterate"},
		{ "Frost Strike"},
		{ "Plague Leech"},
		{ "Empower Rune Weapon", jps.UseCDs and ((runicPower <= 25 and not twoDr and not twoFr and not twoUr) or (timeToDie < 60 and jps.buff("Potion of Mogu Power")) or jps.bloodlusting()) },
							
	}
	
	spellTable[3] =
	{
	
		["ToolTip"] = "DK Kick Buff Debuff",
		
		-- Kicks
		{ "mind freeze",		jps.shouldKick() },
		{ "mind freeze",		jps.shouldKick("focus"), "focus" },
		{ "Strangulate",		jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",		jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",			jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },
		-- Buffs
		{ "frost presence",	 not jps.buff("frost presence") },
		{ "horn of winter",	 "onCD" },
		{ "Outbreak", frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		{ "Unholy Blight", frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		{ "Howling Blast", frostFeverDuration <= 1 or (jps.buff("Freezing Fog") and runicPower < 88) },
		{ "Plague Strike", bloodPlagueDuration <= 1 },
	}

	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)
	return spell,target
end