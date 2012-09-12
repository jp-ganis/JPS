function warrior_fury(self)

if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local spell = nil
   local targetHealth = UnitHealth("target")/UnitHealthMax("target") *100
   local nRage = jps.buff("Berserker Rage","player")
   local nPower = UnitPower("Player",1)
   local spellTable = {

--Buffs and Shiz
    { "Battle Shout",   "onCD" and nPower <= 70, "player" },
    { "Berserker Rage",   jps.UseCDs and (not nRage or (jps.buffStacks("Raging Blow") == 2 and targetHealth > 20 )), "player" },
    { "Recklessness",   jps.UseCDs and (jps.debuffDuration("Colossus Smash") >= 5 or jps.cooldown("Colossus Smash") <= 4 ) and (targetHealth < 20 or targetHealth >= 40) , "target" },
    { "Deadly Calm",   jps.UseCDs and nPower >= 40, "player" },
    { "Lifeblood",   "onCD", "player" },  --if I'm an Herbalist.  Otherwise, ignore me!!

--Interrupt that bad boy
	{ "Pummel",       jps.shouldKick("target") },

--Rage Dump w/ various situational implementations
    { "Heroic Strike",   (((jps.buff("player", "Colossus Smash") and nPower >= 40) or (jps.buff("Deadly Calm") and nPower >= 30)) and targetHealth >= 20 ) or nPower >=75 , "target" },

--Multi-Target / AOE
	{ "Whirlwind", jps.MultiTarget, "target" },
	{ "Raging Blow", jps.MultiTarget and jps.buff("Meat Cleaver") and nPower>10, "target" },

--Start Rotation w/ rate checks where appropriate
    { "Bloodthirst",   "onCD", "target" },
    { "Colossus Smash",   "onCD", "target" },
    { "Execute",      "onCD" and targetHealth <= 20, "target" }, --Execute when target <=20% HP
    { "Raging Blow",   "onCD" and nPower >= 10, "target" },
    { "Wild Strike",   jps.buff("Bloodsurge") and targetHealth >= 20 and nPower >= 30, "target" },
    { "Dragon Roar",   "onCD", "target" },
    { "Impending Victory",   nPower >= 10, "target" },
    { "Heroic Throw",   "onCD", "target" },
    
--Catch all for AA / swing timer generation
    { {"macro","/startattack"}, nil, "target" },
}
   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end