--(Kiwi Blood 1.5)--

function dk_blood(self)

  local ius = IsUsableSpell
  local spell = nil
  local power = UnitPower("player",6)
  local HP = UnitHealth("player")/UnitHealthMax("player")

--Taunting Logic V2--
  if UnitExists("target") and UnitCanAttack("player","target") and ius("dark command") and UnitThreatSituation("player","target") ~= 3 and not ub("targettarget","bear form") and not ub("targettarget","defensive stance") and not ub("targettarget","blood presence") and not ub("targettarget","righteous fury") then
    spell = "dark command"

--Interrupts--
  elseif UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("mind freeze") == 0 and IsSpellInRange("mind freeze", "target") == 1 and power >= 20 then
     SpellStopCasting() spell = "mind freeze"
  elseif UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("strangulate") == 0 and IsSpellInRange("strangulate", "target") == 1 then
     SpellStopCasting() spell = "strangulate"

--Cooldowns--
  elseif cd("Raise Dead") == 0 and jps.UseCDs then 
     spell = "Raise Dead"
  elseif cd("Dancing Rune Weapon") == 0 and ius("Dancing Rune Weapon") and power >= 60 and jps.UseCDs then
     spell = "Dancing Rune Weapon"

--Buffs--
  elseif not ub("player","Horn of Winter") and cd("Horn of Winter") == 0 then
     spell = "Horn of Winter" 
  elseif HP < 0.3 and ius("Icebound Fortitude") then
     spell = "Icebound Fortitude"
  elseif not ub("player","Blood Presence") and ius("Blood Presence") then
     spell = "Blood Presence"
  elseif not ub("player","Bone Shield") and cd("Bone Shield") == 0 and ius("Bone Shield") then
     spell = "Bone Shield"
      
--Multitarget--
  elseif UnitExists("target") and UnitCanAttack("player","target") and jps.MultiTarget then
     if cd("Death and Decay") == 0 and IsShiftKeyDown() then
        spell = "Death and Decay"
        CameraOrSelectOrMoveStart()
        CameraOrSelectOrMoveStop()
     elseif targetshouldbetaunted and ius("Dark Command") and cd("Dark Command") == 0 then
        spell = "Dark Command"
     elseif HP <= 0.8 and cd("rune tap") == 0 then
        spell = "rune tap"
     elseif power >= 20 and HP < 0.4 and cd("icebound fortitude") == 0 then
        spell = "icebound fortitude"
     elseif HP < 0.5 and cd("vampiric blood") == 0 then
        spell = "vampiric blood"
     elseif IsSpellInRange("plague strike","target") == 0 and cd("death grip") == 0 then
        spell = "death grip"
     elseif HP <= 0.75 and ius("death strike") then
        spell = "death strike"
     elseif power >= 100 and ius("rune strike") then
        spell = "rune strike"
     elseif not ud("target","Blood Plague") and cd("Outbreak")== 0 then
        spell = "Outbreak"
     elseif not ud("target","Blood Plague") then
        spell = "Plague Strike"
     elseif not ud("target","frost fever") and cd("icy touch") == 0 then
        spell = "icy touch"
     elseif not (ud("focus","frost fever") and ud("focus","Blood Plague")) and ius("pestilence") then
        spell = "pestilence"
     elseif ud("target","frost fever") and ud("target","blood plague") and ius("heart strike") then
        spell = "heart strike"
     elseif cd("Blood Tap") == 0 then 
        spell= "Blood Tap"
     elseif cd("Horn of Winter") == 0 then
        spell= "Horn of Winter"
     elseif ius("death strike") then
        spell = "death strike"  
     end

--Single Target--
  elseif UnitExists("target") and UnitCanAttack("player","target") and (not jps.MultiTarget)   then
     if HP <= 0.8 and cd("rune tap") == 0 then
        spell = "rune tap"
     elseif targetshouldbetaunted and ius("Dark Command") and cd("Dark Command") == 0 then
        spell = "Dark Command"
     elseif power >= 20 and HP < 0.4 and cd("icebound fortitude") == 0 then
        spell = "icebound fortitude"
     elseif HP < 0.5 and cd("vampiric blood") == 0 then
        spell = "vampiric blood"
     elseif IsSpellInRange("plague strike","target") == 0 and cd("death grip") == 0 then
        spell = "death grip"
     elseif ius("death strike") then
        spell = "death strike"
     elseif power >= 100 and ius("rune strike") then
        spell = "rune strike"
     elseif not ud("target","Blood Plague") and cd("Outbreak")== 0 then
        spell = "Outbreak"
     elseif not ud("target","Blood Plague") then
        spell = "Plague Strike"
     elseif not ud("target","frost fever") and cd("icy touch") == 0 then
        spell = "icy touch"
     elseif cd("Blood Tap") == 0 then 
        spell= "Blood Tap"
     elseif cd("Horn of Winter") == 0 then
        spell= "Horn of Winter"
     elseif ius("death strike") then
        spell = "death strike"
     elseif ud("target","frost fever") and ud("target","blood plague") and ius("heart strike") then
        spell = "heart strike"  
   end
  end
return spell
end