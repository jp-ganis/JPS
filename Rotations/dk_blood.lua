function dk_blood(self)
	-- Credit (and thanks!) to Soiidus.
 local spell = nil
       local power = UnitPower("player",6)

       if UnitHealth("player")/UnitHealthMax("player") <= 0.3 and cd("rune tap") == 0 then
          spell = "rune tap"
       elseif UnitHealth("player")/UnitHealthMax("player") <= .85 and cd("rune tap") == 0 then
          spell = "rune tap"
       elseif UnitHealth("player")/UnitHealthMax("player") <= 0.5 and cd("stoneform") == 0 then
          spell = "stoneform"
       elseif power >= 20 and UnitHealth("player")/UnitHealthMax("player") < .5 and cd("icebound fortitude") == 0 then
          spell = "icebound fortitude"
       elseif UnitHealth("player")/UnitHealthMax("player") < .4 and cd("vampiric blood") == 0 then
          spell = "vampiric blood"
       elseif UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("strangulate") == 0 and IsSpellInRange("strangulate", "target") == 1 then
          SpellStopCasting() spell = "strangulate"
       elseif UnitIsEnemy("player", "target") and (UnitCastingInfo("target") or UnitChannelInfo("target")) and cd("mind freeze") == 0 and IsSpellInRange("mind freeze", "target") == 1 and power > 20 then
          SpellStopCasting() spell = "mind freeze"
       elseif IsSpellInRange("plague strike","target") == 0 and cd("death grip") == 0 then
          spell = "death grip"
       elseif ius("death coil") then
          spell = "death coil"
       elseif IsSpellInRange("plague strike","target") == 0 and cd("chains of ice") == 0 then
          spell = "chains of ice"
       elseif not ud("target","frost fever") and cd("icy touch") == 0 then
          spell = "icy touch"
       elseif cd("raise dead") == 0 and IsSpellInRange("plague strike","target") == 1 then
          spell = "raise dead"
       elseif not ud("target","blood plague") then
          spell = "plague strike"
       elseif ud("target","frost fever") and ud("target","blood plague") and ius("heart strike") then
          spell = "heart strike"
       elseif ius("death strike") then
          spell = "death strike"
       elseif ius("icy touch") == 0 then
          spell = "icy touch"
       elseif ius("plague strike") == 0 then
          spell = "plague strike"
       end
		 return spell
end
