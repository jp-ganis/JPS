--(Kiwi 1.1) Thanks to htordeux for his superior syntaxing skillz :)--

function dk_frost(self)

  local ius = IsUsableSpell
  local spell = nil
  local power = UnitPower("player",6)
  local frost1a,frost1b,frost1c = GetRuneCooldown(5)
  local frost2a,frost2b,frost2c = GetRuneCooldown(6)
  local death1a,death1b,death1c = GetRuneCooldown(1)
  local death2a,death2b,death2c = GetRuneCooldown(2)
  local unholy1a,unholy1b,unholy1c = GetRuneCooldown(3)
  local unholy2a,unholy2b,unholy2c = GetRuneCooldown(4)
  local HP = UnitHealth("player")/UnitHealthMax("player")


--Interrupts--
if UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("mind freeze") == 0 and IsSpellInRange("mind freeze", "target") == 1 and power >= 20 then
         SpellStopCasting() spell = "mind freeze"
elseif UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("strangulate") == 0 and IsSpellInRange("strangulate", "target") == 1 then
         SpellStopCasting() spell = "strangulate"

--Cooldowns--
elseif ius("Pillar of Frost") and cd("Pillar of Frost") == 0 and jps.UseCDs then
     spell = "Pillar of Frost"   
elseif cd("Raise Dead") == 0 and jps.UseCDs then 
     spell = "Raise Dead"

--Buffs--
  elseif not ub("player","Horn of Winter") and cd("Horn of Winter") == 0 then
     spell = "Horn of Winter" 
  elseif HP < 0.2 and ius("Icebound Fortitude") then
     spell = "Icebound Fortitude"
      
--Multitarget--
  elseif UnitExists("target") and UnitCanAttack("player","target") and jps.MultiTarget then
     if cd("Death and Decay") == 0 and IsShiftKeyDown() then
        spell = "Death and Decay"
        CameraOrSelectOrMoveStart()
        CameraOrSelectOrMoveStop()
     elseif ub("player","Freezing Fog") and ius("Howling Blast") then
        spell = "Howling Blast"
     elseif ius ("Howling Blast") then
         spell = "Howling Blast"
     elseif power >= 80 and ius("Frost Strike") then
        spell = "Frost Strike"
     elseif unholy1c == true and ius("Plague Strike") then
        spell = "Plague Strike"
     elseif power >= 32 and ius("Frost Strike") then
        spell = "Frost Strike"
     elseif cd("Horn of Winter") == 0 then
            spell= "Horn of Winter"
     end

--Single Target--
--Boss Rotation [stops if aggro]--
  elseif UnitExists("target") and UnitCanAttack("player","target") and (not jps.MultiTarget) and (UnitLevel("target") >= 87 or UnitClassification("target") == "worldboss") and UnitThreatSituation("player","target") ~= 3 then
        if not ud("target","Blood Plague") and cd("Outbreak")== 0 then
            spell = "Outbreak"
        elseif not ud("target","Blood Plague") then
            spell = "Plague Strike"
        elseif not ud("target","Frost Fever") then
            spell = "Howling Blast"
        elseif ub("player","Freezing Fog") and ius("Howling Blast") then
            spell = "Howling Blast"
        elseif ub("player","Killing Machine") and ius("Obliterate") then
            spell = "Obliterate"
        elseif ub("player","Killing Machine") and ius("Frost Strike") and ((death1b > 2 and death2b >2) or (death1b>2 and frost1b>2) or (death1b>2 and frost2b>2) or (death1b>2 and unholy1b>2) or 
        (death1b>2 and unholy2b>2) or (death2b>2 and frost1b>2) or (death2b>2 and frost2b>2) or (death2b>2 and unholy1b>2) or (death2b>2 and unholy2b>2) or (frost1>2 and unholy1>2) or 
        (frost1b>2 and unholy2b>2) or (frost2b>2 and unholy1b>2) or (frost2b>2 and unholy2b>2)) then
            spell = "Frost Strike"
        elseif power >= 80 then
            spell= "Frost Strike"
        elseif ius("Obliterate") then
            spell = "Obliterate"
        elseif power >= 32 then
            spell = "Frost Strike"
        elseif cd("Blood Tap") == 0 then 
            spell= "Blood Tap"
        elseif cd("Horn of Winter") == 0 then
            spell= "Horn of Winter"
     end

--Regular Rotation--
  elseif UnitExists("target") and UnitCanAttack("player","target") and (not jps.MultiTarget) and UnitLevel("target") < 87 then
        if not ud("target","Blood Plague") and cd("Outbreak")== 0 then
            spell = "Outbreak"
        elseif not ud("target","Blood Plague") then
            spell = "Plague Strike"
        elseif not ud("target","Frost Fever") then
            spell = "Howling Blast"
        elseif ub("player","Freezing Fog") and ius("Howling Blast") then
            spell = "Howling Blast"
        elseif ub("player","Killing Machine") and ius("Obliterate") then
            spell = "Obliterate"
        elseif ub("player","Killing Machine") and ius("Frost Strike") and ((death1b > 2 and death2b >2) or (death1b>2 and frost1b>2) or (death1b>2 and frost2b>2) or (death1b>2 and unholy1b>2) or 
        (death1b>2 and unholy2b>2) or (death2b>2 and frost1b>2) or (death2b>2 and frost2b>2) or (death2b>2 and unholy1b>2) or (death2b>2 and unholy2b>2) or (frost1>2 and unholy1>2) or 
        (frost1b>2 and unholy2b>2) or (frost2b>2 and unholy1b>2) or (frost2b>2 and unholy2b>2)) then
            spell = "Frost Strike"
        elseif power >= 80 then
            spell= "Frost Strike"
        elseif ius("Obliterate") then
            spell = "Obliterate"
        elseif power >= 32 then
            spell = "Frost Strike"
        elseif cd("Blood Tap") == 0 then 
            spell= "Blood Tap"
        elseif cd("Horn of Winter") == 0 then
            spell= "Horn of Winter"
     end
  end
return spell
end