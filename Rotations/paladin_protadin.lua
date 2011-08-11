focusshouldbesaved = false
focusthreatduration = 0
targetshouldbetaunted = false
targetthreatduration = 0

function paladin_protadin(self)
   -- Complete re-write for 4.2 by GoCarGo, Kyletxag and Kiwinall.
      local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
      local targetHealthPercent = UnitHealth("target")/UnitHealthMax("target") * 100
      local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100
      local hPower = UnitPower("player","9")
      local race = UnitRace("player")
      local spell = nil
      local ius = IsUsableSpell

      --Taunt if not attacking me and if my focus target pulls agro
          if UnitExists("focus") and UnitIsFriend("focus","player") then
              if UnitThreatSituation("focus") ~= nil and UnitThreatSituation("focus") == 3 then
                       if focusthreatduration == 0 then
                             focusthreatduration = GetTime()
                    elseif GetTime()-focusthreatduration > 2 and not focusshouldbesaved then
                             focusshouldbesaved = true
                          print("focus will be saved")
                    end
           elseif focusshouldbesaved or focusthreatduration > 0 then
                  focusshouldbesaved = false
                   focusthreatduration = 0
              end
         end
   
         if UnitExists("target") and UnitCanAttack("target","player") then
              if UnitThreatSituation("player","target") ~= nil and UnitThreatSituation("player","target") < 3 and not ub("targettarget","bear form") and not ub("targettarget","defensive stance") and not ub("targettarget","blood presence") and not ub("targettarget","righteous fury")  then
                   if targetthreatduration == 0 then
                        targetthreatduration = GetTime()
                   elseif GetTime()-targetthreatduration > 0.5 and not targetshouldbetaunted then
                        targetshouldbetaunted = true
                     print("Taunting Target")
                   end
      elseif targetshouldbetaunted or targetthreatduration > 0 then
                     targetshouldbetaunted = false
                     targetthreatduration = 0
      end
         end

        -- Interrupt, works equally well with "focus" instead of "target"
      if jps.Interrupts and jps.should_kick("target") and cd("Rebuke") == 0 and myManaPercent >= 25 then
            return "Rebuke"
      end
        -- Blood Elf Arcane Torrent
        if jps.Interrupts and jps.should_kick("target") and cd("Arcane Torrent") == 0 and race == "Blood Elf" then
            return "Arcane Torrent"
      end
        --Check for Righteous Fury, Seals and Mana levels
         if not ub("player","Righteous Fury") then
           return "Righteous Fury"
        elseif not ub("player", "Seal of Truth") and myManaPercent > 75 then
               return "Seal of Truth"
        elseif not ub("player", "Seal of Insight") and ius("Seal of Insight") and myManaPercent < 25 then
               return "Seal of Insight"       
        elseif myManaPercent < 65 and cd("Divine Plea") == 0 then
                return "Divine Plea"
        end
      -- Check we're in melee range, if not pull with AS.
      if UnitExists("target") and UnitCanAttack("player","target") and (IsSpellInRange("Crusader Strike","target") ~= 1) and cd("Avenger's Shield") == 0 then
            return "Avenger's Shield"
      end
      -- Cast WoG if health is below 45% and WoG is off CD
      if cd("Word of Glory") == 0 and myHealthPercent < 45 and hPower == 3 then
            return "Word of Glory"
      end
      -- Default Defensive Cooldowns
      if cd("Holy Shield") == 0 and myHealthPercent < 70 then 
            return "Holy Shield"
      elseif cd("Divine Protection") == 0 and myHealthPercent < 50 then
            return "Divine Protection"
      elseif cd("Lay on Hands") == 0 and myHealthPercent < 10 then
            return "Lay on Hands"
      end
     --On use Defensive
     if jps.Defensive then
        if myHealthPercent < 40 then 
             return ("Guardian of Ancient Kings")
        elseif myHealthPercent < 20 then 
             return "Ardent Defender"
      end
   end
   --Taunt the Targets if I should Taunt or save someone
      if targetshouldbetaunted  and cd("Hand of Reckoning")== 0 then
             return "Hand of Reckoning"

         elseif focusshouldbesaved and cd("Righteous Defense")== 0 then
             spell = "Righteous Defense"
             jps.Target = "focus"
      end
   -- Use Offensive CDs
   if jps.UseCDs and cd("Avenging Wrath") == 0 then
                return "Avenging Wrath"
   end
        -- Offense, Single-Target
      if UnitExists("target") and UnitCanAttack("player","target") and (not jps.MultiTarget) then
             if hPower == 3 and cd("Shield of the Righteous") == 0 and ub("player","Sacred Duty") then
                     return "Shield of the Righteous"
              elseif cd("Inquisition") == 0 and hPower == 3 and not ub("player","Inquisition") then
                     return "Inquisition"
              elseif ius("Avenger's Shield") and ub("player", "Grand Crusader") and cd("Avenger's Shield") == 0 then
                     return "Avenger's Shield"
              elseif ius("Crusader Strike") and cd("Crusader Strike") == 0 then
                    return "Crusader Strike"
              elseif ius("Judgement") and cd("Judgement") and cd("Judgement") == 0 then
                     return "Judgement"
              elseif  ius("Hammer of Wrath") and cd("Hammer of Wrath") == 0 and targetHealthPercent < 25 then
                     return "Hammer of Wrath"
              elseif  ius("Avenger's Shield") and cd("Avenger's Shield") == 0  then
                     return "Avenger's Shield"
              elseif  ius("Holy Wrath") and cd("Holy Wrath") == 0 then
                     return "Holy Wrath"
              end

      -- Multi-Target
      elseif UnitExists("target") and UnitCanAttack("player","target") and jps.MultiTarget then
            if cd("Inquisition") == 0 and hPower == 3 and not ub("player","Inquisition") then
                   return "Inquisition"
                elseif hPower == 3 and cd("Shield of the Righteous") == 0 then
                    return "Shield of the Righteous"
                elseif ius("Hammer of the Righteous") and cd("Hammer of the Righteous") == 0 then
                    return "Hammer of the Righteous"
                elseif ius("Avenger's Shield") and ub("player", "Grand Crusader") and cd("Avenger's Shield") == 0 then
                    return "Avenger's Shield"
                elseif ius("Judgement") and cd("Judgement") == 0 then
                    return "Judgement"
                elseif ius("Consecration") and myManaPercent > 65 and cd("Consecration") == 0 then
                    return "Consecration"
                elseif ius("Avenger's Shield") and cd("Avenger's Shield") == 0 then
                    return "Avenger's Shield"
                elseif ius("Holy Wrath") and cd("Holy Wrath") == 0 then
                    return "Holy Wrath"   
              end
      end

      -- Return
      return spell
end