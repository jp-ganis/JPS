--[[[
@rotation Default
@class monk
@spec WINDWALKER
@description
Using the same rotation as SimulationCraft. Tested with a 480 ilvl against a raid target dummy with only self buffs (and 
ghetto enchants). imulationCraft with these settings gives a DPS of 72k. This script gives a DPS of 62k. So we're 10k off target.
This script in LFR easily does between 70-85k single target.
]]--

jps.registerRotation("MONK","WINDWALKER",function()
	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
	
	local energy = UnitMana("player")
	local energyPerSec = 13
	local energyTimeToMax = (100 - energy) / energyPerSec
	
	local chi = UnitPower("Player", 12)
	local defensiveCDActive = jps.buff("Touch of Karma") or jps.buff("Zen Meditation") or jps.buff("Fortifying Brew") or jps.buff("Dampen Harm") or jps.buff("Diffuse Magic")
	local tigerPowerDuration = jps.buffDuration("Tiger Power")

	local spellTable = {
		-- Defensive Cooldowns.
		-- { "Zen Meditation", 
		--	jps.hp() < .4 
		--	and not defensiveCDActive },
			
		{ "Fortifying Brew", jps.hp() < .6 and not defensiveCDActive },
		
		 -- Defensive Cooldown. (talent specific) 
		{ "Diffuse Magic", jps.hp() < .6 and not defensiveCDActive },
		
		 -- Defensive Cooldown. (talent specific) 
		{ "Dampen Harm", jps.hp() < .6 and not defensiveCDActive },
		
		 -- Defensive Cooldown. 
		{ "Touch of Karma", jps.UseCDs and jps.hp() < .65 and not defensiveCDActive },
		
		 -- Insta-kill single target when available 
		{ "Touch of Death", jps.UseCDs and jps.buff("Death Note") and not jps.MultiTarget },
		
		 -- Interrupts 
		{ "Spear Hand Strike", jps.Interrupts and jps.shouldKick() },
		 
		{ "Paralysis", jps.Interrupts and jps.shouldKick() },
		
		 -- Chi Brew if we have no chi. (talent based) 
		{ "Chi Brew", chi == 0 },
		
		{ jps.DPSRacial, jps.UseCDs },
		
		-- On-use Trinkets.
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and jps.UseCDs },
		
		 -- Lifeblood CD. (herbalists) 
		{ "Lifeblood", jps.UseCDs },
		
		 -- Rising Sun Kick on cooldown. 
		{ "Rising Sun Kick", not jps.debuff("Rising Sun Kick") or jps.debuffDuration("Rising Sun Kick") <= 3 },
		
		 -- Tiger Palm single-target if the buff is close to falling off. 
		{ "Tiger Palm", not jps.MultiTarget and tigerPowerDuration <= 3 },
		
		 -- Tigereye Brew when we have 10 stacks. 
		{ "Tigereye Brew", jps.UseCDs and jps.buffStacks("Tigereye Brew") >= 10 },
		
		 -- Tigereye Brew to heal you if you have the Healing Elixirs talent. This is a more PvP -- oriented strategy, but can also help you in PvE enviroment). 
		{ "Tigereye Brew", jps.UseCDs and jps.buff("Healing Elixirs") and jps.hp() < .85 },
		
		 -- Energizing Brew whenever if it'll take approximately more than 5 seconds of regen to max energy. 
		{ "Energizing Brew", energyTimeToMax > 5 },
		
		 -- Invoke Xuen CD. (talent based) 
		{ "Invoke Xuen, the White Tiger", jps.UseCDs },
		
		 -- Rushing Jade Wind. (talent based) 
		{ "Rushing Jade Wind", jps.MultiTarget and chi >= 2},
		
		 -- Rising Sun Kick on cooldown. 
		{ "Rising Sun Kick" },
		
		 -- Fist of fury is a very situational chi dump, and is mainly filler to regenerate energy while it channels. -- Only use it with low energy and if RSK will be on CD and Tiger Power will be up for it's duration. 
		{ "Fists of Fury", not jps.buff("Energizing Brew") and energyTimeToMax >= 3.5 and tigerPowerDuration >= 3.5 and not jps.Moving and IsSpellInRange("jab","target") },
		
		 -- Blackout Kick single-target on clearcast. 
		{ "Blackout Kick", not jps.MultiTarget and jps.buff("Combo Breaker: Blackout Kick") },
		
		 -- Blackout Kick as single-target chi dump. 
		{ "Blackout Kick", not jps.MultiTarget and chi >= 4 and energyTimeToMax <= 2 },
		
		 -- Tiger Palm single-target if the buff is close to falling off. 
		{ "Tiger Palm", not jps.MultiTarget and jps.buff("Combo Breaker: Tiger Palm") and energyTimeToMax >= 2 },
		
		 -- Chi Wave if we're not at full health. (talent based) 
		{ "Chi Wave", jps.hp() < .8 },
		
		 -- Chi Burst if we're not at full health. (talent based) 
		{ "Chi Burst", jps.hp() < .8 },
		
		 -- Zen Sphere if we're not at full health. (talent based) 
		{ "Zen Sphere", jps.hp() < .8 and not jps.buff("Zen Sphere") },
		
		 -- Expel Harm to build chi and heal if we're not at full health. 
		{ "Expel Harm", chi < 3 and energy >= 40 and jps.hp() < .85 },
		
		 -- Jab to build chi if we're at 3 or less. 
		{ "Jab", not jps.MultiTarget and chi <= 3 },
		
		 -- Blackout Kick when we're chi capped. 
		{ "Blackout Kick", not jps.MultiTarget },
		
		 -- Leg sweep on cooldown during multi-target to reduce tank damage. TODO: Check if our target is stunned already. 
		{ "Leg Sweep", jps.MultiTarget },
		
		 -- Spinning Crane Kick when we're multi-target (4+ targets ideal). 
		{ "Spinning Crane Kick", jps.MultiTarget },
		
	}

	local spell, target = parseSpellTable(spellTable)
	return spell, target
end, "Default")