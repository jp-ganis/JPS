function dk_frost(self)
	--sphoenix

   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

local spell = nil
local targetHealth = UnitHealth("target")/UnitHealthMax("target")
local rpPower = UnitPower("Player",1) -- Runic Power is PowerType 1
local dr1 = select(3,GetRuneCooldown(1))
local dr2 = select(3,GetRuneCooldown(2))
local fr1 = select(3,GetRuneCooldown(3))
local fr2 = select(3,GetRuneCooldown(4))
local ur1 = select(3,GetRuneCooldown(5))
local ur2 = select(3,GetRuneCooldown(6))
local one_dr = dr1 or dr2
local two_dr = dr1 and dr2
local one_fr = fr1 or fr2
local two_fr = fr1 and fr2
local one_ur = ur1 or ur2
local two_ur = ur1 and ur2

local spellTable =
   {

    --Interupts--
       { "Mind Freeze",         jps.shouldKick() },
       { "Strangulate",         jps.shouldKick() and IsSpellInRange("Mind Freeze","target")==0 and jps.LastCast ~= "Mind Freeze" },
       { "Asphyxiate",          jps.shouldKick() and IsSpellInRange("Mind Freeze","target")==0 and jps.LastCast ~= "Mind Freeze" },
    
    --Buffs--
       { "Horn of Winter",      "onCD" },
    
    --Cooldowns--
       { "Pillar of Frost",     jps.UseCDs },
       { "Empower Rune Weapon", jps.UseCDs and not (one_dr or one_fr or one_ur) },
       { "raise dead",          jps.UseCDs and jps["Raise Dead (DPS)"] },
       { jps.DPSRacial,    jps.UseCDs and jps["DPS Racial"]},
       
    --AoE--
       { "Unholy Blight",       jps.MultiTarget and jps.debuffDuration("Frost Fever") <= 2 and jps.debuffDuration("Blood Plague") <= 2 },
       { "Outbreak",            jps.MultiTarget and jps.cooldown("Unholy Blight") > 4 and jps.debuffDuration("Frost Fever") <= 2 and jps.debuffDuration("Blood Plague") <= 2 },
       { "Pestilence",          jps.LastCast ~= "Outbreak" },
       { "Howling Blast",       jps.MultiTarget },
       {"Death and Decay"},     jps.MultiTarget },
       
    
    --Rotation--
       { "Outbreak",            jps.debuffDuration("Frost Fever") <= 2 and jps.debuffDuration("Blood Plague") <= 2, "target" },
       { "Plague Strike",       jps.debuffDuration("Blood Plague") <= 2 and (one_dr or one_ur), "target" },
       { "Obliterate",          jps.buff("Killing Machine") and ((one_dr and one_uh) or (one_dr and one_fr) or (one_uh and one_fr) or two_dr) and not jps.cooldown("Obliterate"), "target" },
       { "Frost Strike",        rpPower >= 20 and jps.buff("Killing Machine") and jps.cooldown("Obliterate") > jps.buffDuration("Killing Machine"), "target" },
       { "Frost strike",        rpPower >= 70 , "target" },
       { "Howling Blast",       jps.buff("freezing fog"), "target" },
       { "Obliterate",          "onCD" , "target" },
    

   }

   local spell,target = parseSpellTable(spellTable)
   if spell == "Death and Decay" then
       jps.Cast( spell )
       jps.groundClick()
   end

   jps.Target = target
   return spell
end
