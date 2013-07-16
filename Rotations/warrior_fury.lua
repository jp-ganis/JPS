--kyletxag  & atx 
warrior = {}
function warrior.rangedTarget()
	local rangedTarget = "target"
	if jps.canDPS("target") then
		return "target"
	elseif jps.canDPS("focustarget") then
		return "focustarget"
	else jps.canDPS("targettarget") then
		return "targettarget"
	end
end

jps.registerStaticTable("WARRIOR","FURY",
	{
		-- Interrupts
		{"Pummel",'jps.shouldKick()'},
		{"Pummel",'jps.shouldKick("focus"), "focus"'},
		{"Disrupting Shout",'jps.shouldKick()'},
		{"Disrupting Shout",'jps.shouldKick("focus"), "focus"'},
		
		-- Cooldowns and Utility
		{"Impending Victory",'jps.buff("Victorious") and jps.rage() >= 10 and jps.hp("player") < 0.8', warrior.rangedTarget },
		{"Victory Rush",'jps.buff("Victorious") and jps.rage() >= 10 and jps.hp("player") < 0.8', warrior.rangedTarget },
		{"Recklessness",'jps.UseCDs and jps.debuffDuration("Colossus Smash") >= 5', warrior.rangedTarget },
		{"Recklessness",'jps.UseCDs and jps.cooldown("Colossus Smash") == 0', warrior.rangedTarget },
		{"Skull Banner",'jps.UseCDs and jps.debuffDuration("Colossus Smash") >= 5', warrior.rangedTarget }, 
		{"Skull Banner",'jps.UseCDs and jps.cooldown("Colossus Smash") == 0', warrior.rangedTarget }, 
		
		{"Berserker Rage",'jps.debuffDuration("Colossus Smash") > 0 and not jps.buff("Berserker Rage","player")', warrior.rangedTarget },
		{"Bloodbath",'jps.UseCDs'},
		
		{ jps.getDPSRacial(),'jps.UseCDs and jps.debuffDuration("Colossus Smash") >= 5'},
		{ jps.useTrinket(0),'jps.useTrinket(0) ~= nil and jps.UseCDs and jps.debuffDuration("Colossus Smash") >= 5'},
		{ jps.useTrinket(1),'jps.useTrinket(1) ~= nil and jps.UseCDs and jps.debuffDuration("Colossus Smash") >= 5'},
		{ jps.useSynapseSprings(),'jps.useSynapseSprings() ~= nil and jps.UseCDs and jps.debuffDuration("Colossus Smash") >= 5'},
		-- Requires herbalism
		{"Lifeblood",'jps.UseCDs and jps.debuffDuration("Colossus Smash") >= 5'},
		
		-- AoE Rotation
		
		{"Whirlwind",'jps.MultiTarget and jps.buffStacks("Meat Cleaver") < 3 and jps.rage() >= 30', warrior.rangedTarget },
		{"Colossus Smash",'jps.MultiTarget', warrior.rangedTarget },
		{"Bloodthirst",'jps.MultiTarget', warrior.rangedTarget },
		{"Cleave",'jps.MultiTarget and jps.cooldown("Colossus Smash") >= 3 and jps.rage() > 105', warrior.rangedTarget },
		{"Raging Blow",'jps.MultiTarget and jps.buff("Raging Blow!") and jps.buffStacks ("Raging Blow!") == 2 and jps.cooldown("Colossus Smash") >= 3 and jps.buffStacks("Meat Cleaver") == 3', warrior.rangedTarget },
		{"Raging Blow",'jps.MultiTarget and jps.buff("Raging Blow!") and jps.buffStacks ("Raging Blow!") == 1 and jps.cooldown("Colossus Smash") >= 3 and jps.buffStacks("Meat Cleaver") == 3', warrior.rangedTarget },
		{"Bladestorm",'jps.MultiTarget and IsShiftKeyDown() ~= nil'},
		
		-- Colossus Smash Rotation
		
		{"Bloodthirst",'jps.mydebuff("Colossus Smash","target")', warrior.rangedTarget },
		{"Execute",'jps.rage() >= 30 and jps.hp("target") < 0.2 and jps.mydebuff("Colossus Smash","target")', warrior.rangedTarget}, 
		{"Raging Blow",'jps.buff("Raging Blow!") and jps.rage() >= 10 and jps.mydebuff("Colossus Smash","target")', warrior.rangedTarget },
		{"Wild Strike",'jps.buff("Bloodsurge") and jps.mydebuff("Colossus Smash","target")', warrior.rangedTarget },
		{"Heroic Strike",'jps.hp("target") > 0.2 and jps.rage() >= 30 and jps.mydebuff("Colossus Smash","target")', warrior.rangedTarget },
		
		-- Normal Rotation
		
		{"Colossus Smash",'jps.rage() >= 100', warrior.rangedTarget },
		{"Bloodthirst","onCD", warrior.rangedTarget},
		{"Heroic Strike",'jps.cooldown("Colossus Smash") >= 3 and jps.rage() > 105', warrior.rangedTarget },
		{"Raging Blow",'jps.rage() >= 10 and jps.buff("Raging Blow!") and jps.buffStacks ("Raging Blow!") == 2 and jps.cooldown("Colossus Smash") >= 3', warrior.rangedTarget },
		{"Wild Strike",'jps.buff("Bloodsurge")', warrior.rangedTarget },
		{"Dragon Roar",'(CheckInteractDistance(warrior.rangedTarget(), 3) == 1)', warrior.rangedTarget },
		{"Raging Blow",'jps.buff("Raging Blow!") and jps.buffStacks ("Raging Blow!") == 1 and jps.cooldown("Colossus Smash") >= 3 and jps.rage() >= 10', warrior.rangedTarget },
		{"Battle Shout",'jps.rage() <= 20 and jps.cooldown("Colossus Smash") < 3 ', "player" },
		{"Battle Shout",'jps.rage() <= 20 and jps.debuffDuration("Colossus Smash") < 6' , "player"},
		
		{"Wild Strike",'jps.rage() > 106 and jps.cooldown("Colossus Smash") >= 3', warrior.rangedTarget },
	}
,"DEFAULT")