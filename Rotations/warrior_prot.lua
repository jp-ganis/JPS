function warrior_prot(self)
-- Gocargo
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
   
   local spell = nil
   local playerHealth = UnitHealth("player")/UnitHealthMax("player")
   local targetHealth = UnitHealth("target")/UnitHealthMax("target")
   local nRage = jps.buff("Berserker Rage","player")
   local nPower = UnitPower("Player",1) -- Rage est PowerType 1
   local stackSunder = jps.debuffStacks("Sunder Armor")

   local spellTable = 
   {
      { "Battle Shout" ,          not ub("player","Battle Shout") and not ub("player","Roar of Courage") and not ub("player","Horn of Winter") and not ub("player","Strength of earth totem") , "player" },
      { "Berserker Rage" ,       not nRage , "player" },
      { "Shield Wall" ,          playerHealth < 0.30 , "player" },
      { "Last Stand" ,          playerHealth < 0.40 , "player" },
      { "Impending Victory" ,    playerHealth < 0.70 , "player" },
      { "Lifeblood" ,           playerHealth < 0.70 , "player" },
   --   { "Shield Block" ,          playerHealth < 0.80 , "player" },
      { "Shield Barrier" ,       playerHealth < 0.80 , "player" and jps.Defensive },
   --   { "Enraged Regeneration" ,    nRage and playerHealth < 0.80 , "player" },   
   --   { "Charge" ,             jps.UseCDs , "target" },
   --   { "Taunt" ,             UnitThreatSituation("player","target")~=3 , "target" },
      { "Pummel" ,             jps.shouldKick("target") , "target" },
      { "Spell Reflection" ,       UnitThreatSituation("player","target") == 3 and (UnitCastingInfo("target") or UnitChannelInfo("target")) , "target" },
      { "Shield Slam" ,          ub("player","Sword and Board") , "target" },
   --   { "Victory Rush" ,          nVictory, "target" },
   --   { "Shockwave" ,          jps.MultiTarget , "target" },
      { "Thunder Clap" ,          jps.MultiTarget , "target" },
      { "Deadly Calm" ,          jps.MultiTarget and jps.UseCDs , "player" },
      { "Recklessness" ,          jps.UseCDs , "player" },
      { "Cleave" ,             nPower > 70 and jps.MultiTarget , "target" },   
      { "Devastate" ,          not ud("target","Sunder Armor") , "target" },
      { "Shield Slam" ,           },
      { "Revenge" ,              },
      { "Heroic Strike" ,       jps.buff("player", "Ultimatum") , "target" },
      { "Devastate" ,          stackSunder < 3 , "target" },
      { "Thunder Clap" ,          not jps.debuff("Weakend Blows", "target") },
      { "Heroic Throw" ,           },
      { "Battle Shout",          nPower < 100, "player" },
      { "Deadly Calm" ,          jps.UseCDs , "target" },
      { "Heroic Strike" ,       jps.buff("player", "Deadly Calm") , "target" },
      { "Heroic Strike" ,       nPower>90 , "target" },
      { "Impending Victory" ,    playerHealth < 0.90 , "target" },
      { "Devastate" ,           },
      
      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end