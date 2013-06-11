-- jpganis
-- Ty to SIMCRAFT for this rotation

function rogue_combat_pve()

	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
	
	-- Using the same rotation as Noxxic http://Noxxic.com
	-- Talents: all are optional
	-- Tier 1: Shadow Focus
	-- Tier 2: Deadly Throw
	-- Tier 3: Leeching poison i usually prefer elusiveness though
	-- Tier 4: shadowstep
	-- Tier 5: dirty tricks
	-- Tier 6: marked for death-i usually use anticipation 
	
	-- Major Glyphs: Glyph of Adrenaline Rush, others are preference, if you take elusiveness use Glyph of Feint though
	
	-- Usage info: ToT will be cast on focus
	-- Enable cooldowns to use defensive cooldown along with vanish, preparation, trinkets, and combat spec specific cooldowns (ex: Adrenaline Rush)
	
	--todo:
	-- Multi-target
	-- ToT on Focus
	-- Vanish only cast if shadowstep is off cooldown 
	
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("rupture")
	local snd_duration = jps.buffDuration("slice and dice")
	local energy = UnitPower("player")
	local defensiveCDActive = jps.buff("Evasion") or jps.buff("Cloak of Shadows") or jps.buff("Smoke Bomb") or jps.buff("Dampen Harm")
	
	-- Spells should be ordered by priority.
	local possibleSpells = {
		-- Defensive Cooldowns.  
		{ "Recuperate", jps.hp() < .5 and not defensiveCDActive },
		
		-- Defensive Cooldown. 
		{ "Evasion", jps.UseCDs and jps.hp() < .35 and not defensiveCDActive },
		
		-- Defensive Cooldown. 
		{ "Cloak of Shadows", jps.UseCDs and jps.hp() < .25 and not defensiveCDActive },
		
		-- Defensive Cooldown. 
		{ "Smoke Bomb", jps.UseCDs and jps.hp() < .5 and not defensiveCDActive },
		
		-- Kick 
		{ "Kick", jps.shouldKick() and jps.LastCast ~= "Blind" and jps.LastCast ~= "Gouge" },
		
		-- Kick 
		{ "Blind", jps.shouldKick() and jps.LastCast ~= "Kick" and jps.LastCast ~= "Gouge" },
		
		-- Kick 
		{ "Kick", jps.shouldKick() },
		
		-- Kick 
		{ "Gouge", jps.shouldKick() and jps.LastCast ~= "Kick" },
		
		-- Trinket CDs. 
		-- Disabled one slot (the 1st one) just so the addon won't waste a cooldown, like PvP trinkets. Most people 
		-- don't even use 2 trinkets with USE effect anyways. Even if you DO use 2 trinkets with USE effect, having 
		-- one trinket slot spared will even time your burst or defensive cooldowns better. Put your most used and 
		-- faster, or the one you just forget most to activate at slot 2. You will thank me later.
		
		--{ jps.useSlot(13), -- jps.UseCDs },
		
		{ jps.useSlot(14), jps.UseCDs },
		
		-- Synapse Springs CD. (engineering gloves) 
		{ jps.useSlot(10), jps.UseCDs },
		
		-- Preparation if vanish has more than 60 seconds left 
		{ "Preparation", not jps.buff("Vanish") and jps.cd("Vanish") > 60 and jps.UseCDs },
		
		-- Lifeblood CD. (herbalists) 
		{ "Lifeblood", jps.UseCDs },
		
		-- DPS Racial CD. 
		{ jps.DPSRacial, jps.UseCDs },
		
		-- Use Vanish 
		{ "Vanish", not jps.debuff("Shadow Blades") and not jps.buff("Adrenaline Rush") and energy < 20 and jps.buff("Deep Insight") and cp < 4 and jps.UseCDs },
		
		-- Use Shadowstep After Vanish-Talent Specific 
		{ "Shadowstep", jps.LastCast ~= "Vanish" },
		
		-- Ambush after shadowstep 
		{ "Ambush", jps.UseCDs and jps.LastCast ~= "Shadowstep" },
		
		-- Slice and Dice 
		{ "Slice and Dice", snd_duration < 2 or snd_duration < 15 and jps.buffStacks("Bandits Guile") == 11 and cp >= 4 },
		
		-- Shadow Blades while bloodlusting 
		{ "Shadow Blades", jps.bloodlusting() and snd_duration >= jps.buffDuration("Shadow Blades") },
		
		-- Killing Spree CD 
		{ "Killing Spree", jps.UseCDs and energy < 35 and snd_duration > 4 and not jps.buff("Adrenaline Rush") },
		
		-- Adrenaline Rush CD 
		{ "Adrenaline Rush", jps.UseCDs and energy < 35 or jps.buff("Shadow's Blade") },
		
		-- Rupture/Rupture Refresh 
		{ "Rupture", rupture_duration < 4 and cp == 5 and jps.buff("Deep Insight") },
		
		-- eviscerate if combo point dump is needed 
		{ "Eviscerate", cp == 5 and jps.buff("Deep Insight") },
		
		-- rupture double check if you miss deep insight on time 
		{ "Rupture", rupture_duration < 4 and cp == 5 },
		
		-- Revealing Strike maintain debuff 
		{ "Revealing Strike", cp < 5 and not jps.debuff("Revealing Strike") },
		
		-- Sinister Strike as Cp builder 
		{ "Sinister Strike", cp < 5 }
	}
	return parseSpellTable(possibleSpells)
end