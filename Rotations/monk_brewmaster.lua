--[[[
@rotation PVE 5.4
@class monk
@spec brewmaster
@description
modifiers:
alt: place healing sphere<br>
shift+alt: black Ox statue<br>
alt+ctrl: dizzying haze<br>
shift: spinning crane kick<br>
left ctrl: breath on fire single target<br>
]]--

jps.registerRotation("MONK","BREWMASTER",function()
 
   local chi = jps.chi()
   local energy = jps.energy()
   local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")

   local spellTable ={
      -- GROUND SPELLS
      { "Healing Sphere",   keyPressed("alt") },
      { "Summon Black Ox Statue",   keyPressed("shift","alt") },
      { "Dizzying Haze", keyPressed("ctrl") },

      -- SHORT COOLDOWNS
      -- Guard when Power Guard buff is available and while taking some damage.
      { "Guard", jps.buff("Power Guard") and jps.hp() < 0.90 and chi >= 2 },

      -- BREWS
      -- Chi Brew if we have no chi and less than 5 Elusive Brew stacks (talent based).
      { "Chi Brew", chi == 0 and jps.buffStacks("Elusive Brew") < 5 },
      -- Purifying Brew to clear stagger when it's moderate or heavy.
      { "Purifying Brew", jps.debuff("Moderate Stagger") or jps.debuff("Heavy Stagger") and chi >= 1},
      -- Elusive Brew with 10 or more stacks.
      { "Elusive Brew", jps.buffStacks("Elusive Brew") >= 10 },

      -- ITEMS, BUFFS AND SURVAVIBILITY
      { "Legacy of the Emperor", not jps.buff("Legacy of the Emperor") and energy >= 40 },
      { jps.useBagItem("Alchemist's Flask"), not jps.buff("Enhanced Agility") and not jps.buff("Flask of Spring Blossoms") },
      { jps.useBagItem("Healthstone"), jps.hp("player") < 0.50},
      { jps.useBagItem("Master Healing Potion"), jps.hp("player") < 0.30},
       
       -- On-Use Trinket 2.
      { jps.useTrinket(0), jps.UseCDs },
      { jps.useTrinket(1), jps.UseCDs },

      -- SELF-HEALING
      -- Expel Harm when below 35% heatlh does not have cooldown due Desperate Measures.
      { "Expel Harm", jps.hp() < 0.35 and energy >= 40 },
      -- Chi Wave for heal (talent based).
      { "Chi Wave", jps.hp() < 0.85 },
      -- Zen Sphere for heal (talent based).
      { "Zen Sphere", jps.hp() < 0.85 },
      -- Chi Wave for heal (talent based).
      { "Chi Burst", jps.hp() < 0.85 },
      -- Purifying Brew to heal you if yoy have Healing Elixirs talent.
      { "Purifying Brew", jps.buff("Healing Elixirs") and jps.hp() < 0.80 and chi >= 1},

      -- Spinning Crane Kick for multi-target threat&dps. Triggers with Left Shift Key pressed.
      { "Spinning Crane Kick", keyPressed("shift") and not jps.buff("Spinning Crane Kick"),"player"},
      
      
      -- INTERRUPTS
      { "Spear Hand Strike", jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.4 },
      { "Paralysis", jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" },
      { "Breath of Fire", jps.shouldKick("target") and chi >= 2 and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },
      { "Arcane Torrent", jps.shouldKick("target") and CheckInteractDistance("target",3)==1 and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },

      -- INTERRUPT FOCUS
      { "Spear Hand Strike", jps.shouldKick("focus") and jps.CastTimeLeft("focus") < 1.4 },
      { "Paralysis", jps.shouldKick("focus") and jps.CastTimeLeft("focus") < 1.4 and IsSpellInRange("Spear Hand Strike","focus")==0 and jps.LastCast ~= "Spear Hand Strike" },
      { "Arcane Torrent", jps.shouldKick("focus") and CheckInteractDistance("focus",3)==1 and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },


      -- PROFESSIONS AND RACIALS
      { jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and chi > 3 and energy >= 50 },
      -- Herbalists have Lifeblood.
      { "Lifeblood", jps.UseCDs },
      -- DPS Racial on cooldown.
      { jps.DPSRacial, jps.UseCDs },

      -- COOLDOWNS
      -- Fortifying Brew if you get low. Is set to 35% health because when at or below it, Desperate Measures triggers.
      { "Fortifying Brew", jps.Defensive and jps.hp() < 0.35 and not defensiveCDActive },
      -- Diffuse Magic if you get low. (talent based)
      { "Diffuse Magic", jps.Defensive and jps.hp() < 0.5 and not defensiveCDActive },
      -- Dampen Harm if you get low. (talent based)
      { "Dampen Harm", jps.Defensive and jps.hp() < 0.6 and not defensiveCDActive },
      -- Invoke Xuen on cooldown for single-target. (talent based)
      --{ "Invoke Xuen, the White Tiger", jps.UseCDs },

      -- MAIN ROTATION
      -- Keg Smash to build some chi and keep the Weakened Blows debuff up.
      { "Keg Smash", chi < 3 or not jps.debuff("Weakened Blows") },
      -- Blackout Kick if shuffle is missing or about to drop.
      { "Blackout Kick", (not jps.buff("Shuffle") or jps.buffDuration("Shuffle") < 3 ) and chi >= 2 },
      -- Expel Harm for building some chi and healing if not at full health.
      { "Expel Harm", jps.hp() < 0.85 and energy >= 40 and chi < 4 },
      -- Jab is our basic chi builder.
      { "Jab", chi < 4 and energy > 70 },
      -- Tiger Palm to keep the Tiger Power buff up. No chi cost due to Brewmaster specialization at level 34.
      { "Tiger Palm", not jps.buff("Tiger Power") or jps.buffDuration("Tiger Power") <= 1.5 },
      { "Chi Wave", jps.hp() > 0.90 },

      -- AOE ROTATION
      -- Rushing Jade Wind for multi-target threat & dps
      { "Rushing Jade Wind", jps.MultiTarget and not jps.buff("Rushing Jade Wind"),"player"},
      -- Breath of Fire when target(s) have Dizzying Haze debuff.
      { "Breath of Fire", jps.MultiTarget and jps.debuff("Dizzying Haze") and chi >= 2},
         -- Breath of Fire when Left Control is pressed.
      { "Breath of Fire", keyPressed("left-ctrl") },

      -- FINISHERS
      -- Insta-kill single target when available.
      { "Touch of Death", not jps.MultiTarget and jps.UseCDs and jps.buff("Death Note") },

      -- CHI DUMPERS AND ROTATION FILLERS
      -- Blackout Kick as a chi dump.
      { "Blackout Kick", chi >= 4 },
      -- Tiger Palm as a filler.
      { "Tiger Palm" },
   }
   
   return parseSpellTable(spellTable)
end, "PVE 5.4")


--[[[
@rotation Default
@class monk
@spec brewmaster
@description
Usage info:[br]
[*] [code]SHIFT[/code]:  "Dizzying Haze" at mouse position - AoE threat builder - "Hurl a keg of your finest brew"[br]
]]--
jps.registerRotation("MONK","BREWMASTER",function()
 	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
 
	local chi = UnitPower("player", "12") -- 12 is chi
	local energy = UnitPower("player", "3") -- 3 is energy
	local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")

	local spellTable = {
		
		-- Fortifying Brew if you get low. 
		{ "Fortifying Brew", jps.UseCDs and jps.hp() < .35 and not defensiveCDActive }, -- Changed to 35% health because when at or below it, Desperate Measures triggers. 
		
		-- Diffuse Magic if you get low. (talent based) 
		{ "Diffuse Magic", jps.UseCDs and jps.hp() < .5 and not defensiveCDActive },
		
		-- Dampen Harm if you get low. (talent based) 
		{ "Dampen Harm", jps.UseCDs and jps.hp() < .6 and not defensiveCDActive },
		
		-- Healthstone if you get low.
		{ jps.useBagItem(5512), jps.hp("player") < 0.5 },
		
		-- Spinning Crane Kick for multi-target threat. 	
		{ "Spinning Crane Kick", IsLeftControlKeyDown() ~= nil and not jps.buff("Spinning Crane Kick"),"player"},
		
		-- Insta-kill single target when available. 
		{ "Touch of Death", jps.UseCDs and jps.buff("Death Note") and chi > 2 and not jps.MultiTarget },
		
		-- Purifying Brew to clear stagger when it's moderate or heavy. 	
		{ "Purifying Brew", 	jps.debuff("Moderate Stagger") 	or jps.debuff("Heavy Stagger") 	or jps.buff("Healing Elixirs") 	and jps.hp() < .85 and chi >= 1},
		
		-- Elusive Brew with 10 or more stacks. 	
		{ "Elusive Brew", 	jps.buffStacks("Elusive Brew") >= 10 },
		
		{ "Dizzying Haze" , IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil, "player"},
		
		-- Chi Brew if we have no chi (talent based). 
		{ "Chi Brew", chi == 0 },
		
		-- Rushing Jade Wind applies shuffle and multi-target damage. -- Use it instead of Blackout kick when it's available. (talent based) 
		{ "Rushing Jade Wind", jps.MultiTarget  or jps.hp() < .85 or ( not jps.buff("Shuffle") or jps.buffDuration("Shuffle") < 3 ) 	and chi >= 2},
		
		-- Blackout Kick if shuffle is missing or about to drop. 
		{ "Blackout Kick", (not jps.buff("Shuffle") or jps.buffDuration("Shuffle") < 3 ) and chi >= 2 },
		
		-- Guard when Power Guard buff is available and while taking some damage. 	
		{ "Guard", 	jps.buff("Power Guard") 	and jps.hp() < .9 	and chi >= 2 },
		
		-- On-Use Trinket 1. 
		{ jps.useTrinket(0), jps.UseCDs },
		
		-- On-Use Trinket 2. 
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Engineers may have synapse springs on their gloves (slot 10). 
		{ jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and chi > 3 and energy >= 50 },
		
		-- Herbalists have Lifeblood. 
		{ "Lifeblood", jps.UseCDs },
		
		-- Keg Smash to build some chi and keep the weakened blows debuff up. 	
		{ "Keg Smash", 	chi < 3 or not jps.debuff("Weakened Blows") },
		
		-- Interrupt. 
		{ "Spear Hand Strike", jps.Interrupts and jps.shouldKick() },
		
		{ "Paralysis", jps.Interrupts and jps.shouldKick() },
		
		-- Invoke Xuen on cooldown for single-target. (talent based) 
		{ "Invoke Xuen, the White Tiger", jps.UseCDs },
		
		-- Breath of Fire when target(s) have Dizzying Haze debuff. 	
		{ "Breath of Fire", 	jps.MultiTarget 	and jps.debuff("Dizzying Haze") 	and chi >= 2 },
		
		-- Expel Harm for building some chi and healing if not at full health. 	
		{ "Expel Harm", 	jps.hp() < .85 	and energy >= 40 	and chi < 4 },
		
		-- Expel Harm when below 35% heatlh does not have cooldown due Desperate Measures. 	
		{ "Expel Harm", 	jps.hp() < .35 	and energy >= 40 },
		
		-- Tiger Palm to keep the Tiger Power buff up. No chi cost due to Brewmaster specialization at level 34. 
		{ "Tiger Palm", not jps.MultiTarget and not jps.buff("Tiger Power") or jps.buffDuration("Tiger Power") <= 1.5 },
		
		-- Zen Sphere for threat and heal (talent based). 
		{ "Zen Sphere", jps.hp() < .85 },
		
		-- Chi Wave for threat and heal (talent based). 	
		{ "Chi Wave", 	jps.hp() < .85 },
		
		-- Chi Wave for threat and heal (talent based). 	
		{ "Chi Burst", 	jps.hp() < .85 },
		
		-- DPS Racial on cooldown. 
		{ jps.DPSRacial, jps.UseCDs },
		
		-- Jab is our basic chi builder. 	
		{ "Jab", 	chi < 4 },
		
		-- Blackout Kick as a chi dump. 
		{ "Blackout Kick", chi >= 4 },
		
		-- Tiger Palm filler. 	
		{ "Tiger Palm" },
	}
	
	local spell,target = parseSpellTable(spellTable)
	
	return spell,target
end, "PVE 5.2")
