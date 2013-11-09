
--[[[
@rotation Default
@class warrior
@spec fury
@talents ZZ!!c
@author atx, kyletxag
@description 
This Rotation requires Glyph of Unending Rage. Shouldn't be used at lower levels
]]--
jps.registerStaticTable("WARRIOR","FURY",
	{
-- Interrupts
		-- "Pummel" 6552 "Volée de coups"
		{ 6552, 'jps.shouldKick()' , warrior.rangedTarget , "Pummel" },
		{warrior.spells["Pummel"],'jps.shouldKick()'},
		{warrior.spells["Pummel"],'jps.shouldKick("focus")', "focus"},
		{warrior.spells["Disrupting Shout"],'jps.shouldKick()'},
		{warrior.spells["Disrupting Shout"],'jps.shouldKick("focus")', "focus"},
		
-- Cooldowns and Utility
		{warrior.spells["Impending Victory"],'jps.buff("Victorious") and jps.rage() >= 10 and jps.hp("player") < 0.8', warrior.rangedTarget },
		-- "Victory Rush" 34428 "Ivresse de la victoire" -- buff "Victorious" 32216 "Victorieux"
		{warrior.spells["Victory Rush"],'jps.buff(32216) and jps.rage() >= 10 and jps.hp("player") < 0.8', warrior.rangedTarget },
		{warrior.spells["Recklessness"],'jps.UseCDs and jps.debuffDuration( 86346) >= 5', warrior.rangedTarget },
		{warrior.spells["Recklessness"],'jps.UseCDs and jps.cooldown( 86346) == 0', warrior.rangedTarget },
		{warrior.spells["Skull Banner"],'jps.UseCDs and jps.debuffDuration( 86346) >= 5', warrior.rangedTarget }, 
		{warrior.spells["Skull Banner"],'jps.UseCDs and jps.cooldown( 86346) == 0', warrior.rangedTarget }, 
		
		{warrior.spells["Berserker Rage"],'jps.debuffDuration( 86346) > 0 and not jps.buff("Berserker Rage","player")', warrior.rangedTarget },
		{warrior.spells["Bloodbath"],'jps.UseCDs'},
		
		{ jps.getDPSRacial(),'jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		{ jps.useTrinket(0),'jps.useTrinket(0) ~= "" and jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		{ jps.useTrinket(1),'jps.useTrinket(1) ~= "" and jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		{ jps.useSynapseSprings() ,'jps.useSynapseSprings() ~= "" and jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		-- Requires herbalism
		{warrior.spells["Lifeblood"],'jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		
		-- AoE Rotation
		-- "Raging Blow" 85288 "Coup déchaîné" -- buff Raging Blow! 131116
		
		{warrior.spells["Whirlwind"],'jps.MultiTarget and jps.buffStacks(12950) < 3 and jps.rage() >= 30', warrior.rangedTarget },
		{warrior.spells["Colossus Smash"],'jps.MultiTarget', warrior.rangedTarget },
		{warrior.spells["Bloodthirst"],'jps.MultiTarget', warrior.rangedTarget },
		{warrior.spells["Cleave"],'jps.MultiTarget and jps.cooldown( 86346) >= 3 and jps.rage() > 105', warrior.rangedTarget },
		{warrior.spells["Raging Blow"],'jps.MultiTarget and jps.buff("131116") and jps.buffStacks ("131116") == 2 and jps.cooldown( 86346) >= 3 and jps.buffStacks(12950) == 3', warrior.rangedTarget },
		{warrior.spells["Raging Blow"],'jps.MultiTarget and jps.buff("131116") and jps.buffStacks ("131116") == 1 and jps.cooldown( 86346) >= 3 and jps.buffStacks(12950) == 3', warrior.rangedTarget },
		{warrior.spells["Bladestorm"],'jps.MultiTarget and IsShiftKeyDown() ~= nil'},
		
		-- Colossus Smash Rotation
		
		{warrior.spells["Bloodthirst"],'jps.myDebuff( 86346,"target")', warrior.rangedTarget },
		{warrior.spells["Execute"],'jps.rage() >= 30 and jps.hp("target") < 0.2 and jps.myDebuff( 86346,"target")', warrior.rangedTarget}, 
		{warrior.spells["Raging Blow"],'jps.buff("131116") and jps.rage() >= 10 and jps.myDebuff( 86346,"target")', warrior.rangedTarget },
		{warrior.spells["Wild Strike"],'jps.buff("Bloodsurge") and jps.myDebuff( 86346,"target")', warrior.rangedTarget },
		{warrior.spells["Heroic Strike"],'jps.hp("target") > 0.2 and jps.rage() >= 30 and jps.myDebuff( 86346,"target")', warrior.rangedTarget },
		
		-- Normal Rotation
		
		{warrior.spells["Colossus Smash"],'jps.rage() >= 100', warrior.rangedTarget },
		{warrior.spells["Bloodthirst"],'onCD', warrior.rangedTarget},
		{warrior.spells["Heroic Strike"],'jps.cooldown( 86346) >= 3 and jps.rage() > 105', warrior.rangedTarget },
		{warrior.spells["Raging Blow"],'jps.rage() >= 10 and jps.buff("131116") and jps.buffStacks ("131116") == 2 and jps.cooldown( 86346) >= 3', warrior.rangedTarget },
		{warrior.spells["Wild Strike"],'jps.buff("Bloodsurge")', warrior.rangedTarget },
		{warrior.spells["Dragon Roar"],'(CheckInteractDistance(warrior.rangedTarget(), 3) == 1)', warrior.rangedTarget },
		{warrior.spells["Raging Blow"],'jps.buff("131116") and jps.buffStacks ("131116") == 1 and jps.cooldown( 86346) >= 3 and jps.rage() >= 10', warrior.rangedTarget },
		{warrior.spells["Battle Shout"],'jps.rage() <= 20 and jps.cooldown( 86346) < 3 ', "player" },
		{warrior.spells["Battle Shout"],'jps.rage() <= 20 and jps.debuffDuration( 86346) < 6' , "player"},
		{warrior.spells["Wild Strike"],'jps.rage() > 106 and jps.cooldown( 86346) >= 3', warrior.rangedTarget },
	}
,"Default PvE" , true, false)



--[[[
@rotation Noxxic 5.3
@class warrior
@spec fury
@author Kirk24788
@description 
This Rotation is based on Noxxic, but aims to be also used at lower levels.
This is based on the Default Rotation by atx and kyletxag.
]]--
jps.registerStaticTable("WARRIOR","FURY",
	{
-- Interrupts
		{warrior.spells["Pummel"],'jps.shouldKick()'},
		{warrior.spells["Pummel"],'jps.shouldKick("focus")', "focus"},
		{warrior.spells["Disrupting Shout"],'jps.shouldKick()'},
		{warrior.spells["Disrupting Shout"],'jps.shouldKick("focus")', "focus"},
		
-- Cooldowns and Utility
		-- "Victory Rush" 34428 "Ivresse de la victoire" -- buff "Victorious" 32216 "Victorieux"
		{warrior.spells["Victory Rush"],'jps.buff(32216) and jps.rage() >= 10 and jps.hp("player") < 0.8', warrior.rangedTarget },
		{warrior.spells["Recklessness"],'jps.UseCDs and jps.debuffDuration( 86346) >= 5', warrior.rangedTarget },
		{warrior.spells["Recklessness"],'jps.UseCDs and jps.cooldown( 86346) == 0', warrior.rangedTarget },
		{warrior.spells["Skull Banner"],'jps.UseCDs and jps.debuffDuration( 86346) >= 5', warrior.rangedTarget }, 
		{warrior.spells["Skull Banner"],'jps.UseCDs and jps.cooldown( 86346) == 0', warrior.rangedTarget }, 
		
		{warrior.spells["Berserker Rage"],'jps.debuffDuration( 86346) > 0 and not jps.buff(18499,"player")', warrior.rangedTarget },
		{warrior.spells["Bloodbath"],'jps.UseCDs'},
		
		{ jps.getDPSRacial(),'jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		{ jps.useTrinket(0),'jps.useTrinket(0) ~= "" and jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		{ jps.useTrinket(1),'jps.useTrinket(1) ~= "" and jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		{ jps.useSynapseSprings() ,'jps.useSynapseSprings() ~= "" and jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		{warrior.spells["Lifeblood"],'jps.UseCDs and jps.debuffDuration( 86346) >= 5'},
		
-- AoE Rotation
		{"nested", 'jps.MultiTarget', {
			{warrior.spells["Whirlwind"],'jps.buffStacks(12950) < 3', warrior.rangedTarget },
			{warrior.spells["Raging Blow"],'jps.buffStacks(12950) == 3', warrior.rangedTarget },
			{warrior.spells["Dragon Roar"],'onCD', warrior.rangedTarget },
		}},
		
		{"nested", 'not jps.MultiTarget', {
			-- Colossus Smash Rotation
			{"nested", 'jps.myDebuff( 86346,"target")', {
				{warrior.spells["Bloodthirst"],'onCD', warrior.rangedTarget },
				{warrior.spells["Execute"],'jps.hp("target") < 0.2', warrior.rangedTarget}, 
				{warrior.spells["Heroic Leap"],'onCD', warrior.rangedTarget}, 
				{warrior.spells["Heroic Strike"],'onCD', warrior.rangedTarget},
				-- "Raging Blow" 85288 "Coup déchaîné" -- buff Raging Blow! 131116
				{warrior.spells["Raging Blow"],'jps.buff(131116)', warrior.rangedTarget },
				-- "Bloodsurge" 46916 "Afflux sanguin"
				{warrior.spells["Wild Strike"],'jps.buff(46916)', warrior.rangedTarget },
			}},
			{"nested", 'jps.Level >= 81', {
				{warrior.spells["Colossus Smash"],'jps.rage() >= warrior.relativeRage(0.75)', warrior.rangedTarget },
				{warrior.spells["Bloodthirst"],'onCD', warrior.rangedTarget },
				{warrior.spells["Heroic Strike"],'jps.rage() >= warrior.relativeRage(0.8)', warrior.rangedTarget },
				-- "Raging Blow" 85288 "Coup déchaîné" -- buff Raging Blow! 131116
				{warrior.spells["Raging Blow"],'jps.buffStacks(131116) == 2', warrior.rangedTarget },
				-- "Bloodsurge" 46916 "Afflux sanguin"
				{warrior.spells["Wild Strike"],'jps.buff(46916)', warrior.rangedTarget },
				{warrior.spells["Battle Shout"],'jps.rage() <= warrior.relativeRage(0.2) and jps.cooldown( 86346) < 3', "player" },
				{warrior.spells["Impending Victory"],'onCD', warrior.rangedTarget },
				{warrior.spells["Heroic Throw"],'onCD', warrior.rangedTarget },
			}},
			{"nested", 'jps.Level < 81', {
				{warrior.spells["Bloodthirst"],'onCD', warrior.rangedTarget },
				{warrior.spells["Execute"],'jps.hp("target") < 0.2', warrior.rangedTarget}, 
				{warrior.spells["Heroic Leap"],'onCD', warrior.rangedTarget}, 
				{warrior.spells["Impending Victory"],'onCD', warrior.rangedTarget },
				{warrior.spells["Heroic Throw"],'onCD', warrior.rangedTarget },
				{warrior.spells["Heroic Strike"],'onCD', warrior.rangedTarget },
				-- "Raging Blow" 85288 "Coup déchaîné" -- buff Raging Blow! 131116
				{warrior.spells["Raging Blow"],'jps.buffStacks(131116) == 2', warrior.rangedTarget },
				-- "Bloodsurge" 46916 "Afflux sanguin"
				{warrior.spells["Wild Strike"],'jps.buff(46916)', warrior.rangedTarget },
				{warrior.spells["Battle Shout"],'jps.rage() <= warrior.relativeRage(0.2)', "player" },
			}},
		}},
	}
,"Noxxic 5.3" , true, false)


jps.registerStaticTable("WARRIOR","FURY",
	{
		-- "Heroic Throw" 57755 "Lancer héroïque"
		{warrior.spells["Heroic Throw"], 'true' , warrior.rangedTarget },
		-- "Raging Blow" 85288 "Coup déchaîné" -- buff Raging Blow! 131116
		{warrior.spells["Raging Blow"],'jps.buff(131116)', warrior.rangedTarget },
		-- "Bloodthirst" 23881 "Sanguinaire"
		{warrior.spells["Bloodthirst"],'true', warrior.rangedTarget },
		-- "Thunder Clap" 6343 "Coup de tonnerre" 
		{warrior.spells["Thunder Clap"], 'true' , warrior.rangedTarget   },
		-- "Shockwave" 46968 "Onde de choc"
		{warrior.spells["Shockwave"], 'CheckInteractDistance(warrior.rangedTarget(), 3) == 1', warrior.rangedTarget },
		-- "Whirlwind" 1680 "Tourbillon"
		{warrior.spells["Whirlwind"], 'true' , warrior.rangedTarget },
		-- "Dragon Roar" 118000 "Rugissement de dragon"
		{warrior.spells["Dragon Roar"],'onCD', warrior.rangedTarget },
	}
	,"MultiTarget PvE", true, false)