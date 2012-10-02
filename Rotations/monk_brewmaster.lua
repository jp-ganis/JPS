function monk_brewmaster(self)
   -- Talents:
   -- Tier 1: Celerity
   -- Tier 2: Chi Wave
   -- Tier 3: Power Strikes
   -- Tier 4: Leg Sweep
   -- Tier 5: Dampen Harm
   -- Tier 6: Rushing Jade Wind

   -- Usage info:
   -- Shift to use "Dizzying Haze" at mouse position - AoE threat builder - "Hurl a keg of your finest brew"
   -- Left control and mouseover target to use "Chi Wave" - can be used on friendlies and enemies

   -- To do:
   -- Do not taunt if current boss target is another tank
   -- Correct "Expel harm" according to health pool at level 90
   
   local targetThreatStatus = UnitThreatSituation("player","target")
   if not targetThreatStatus then targetThreatStatus = 0 end

   local chi = UnitPower("player","12") -- 12 = SPELL_POWER_LIGHT_FORCE (chi)
   local energy = UnitPower("player","3") -- 3 = SPELL_POWER_ENERGY (rogues, monks, druids (feral))
   local stance = GetShapeshiftForm()

   local spellTable =
   {
      -- Stance
      { "Stance of the Sturdy Ox",    stance ~= 2 },
      -- Taunt
      { "Provoke",             targetThreatStatus ~= 3 }, -- and not jps.targetTargetTank()
      -- Provoke on Black Ox Statue for AoE taunt
         -- AoE threat builder - hurl a keg of your finest brew
      { "Dizzying Haze",         IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },      
      -- Kick
      { "Spear Hand Strike",       jps.shouldKick() },
      -- Defensive cooldowns 
      { "Fortifying Brew",       jps.hp("player") < 0.3 }, -- Increases health by 20%, and reduces damage taken by 20% for 20 sec.
      { "Dampen Harm",          jps.hp("player") < 0.5 }, -- The next 3 attacks within 45 sec that deal damage equal to 10% or more of your total health are reduced in half.
      -- Try to finish target
      { "Touch of Death",         UnitHealth("target") < UnitHealth("player") and chi >= 3 }, -- UnitHealth("target") < UnitHealth("player") 
      -- AoE
      { "Breath of Fire",         jps.MultiTarget },
      { "Rushing Jade Wind",      jps.MultiTarget },
      { "Spinning Crane Kick",   jps.MultiTarget },
      -- Mouseover + left control key
      { "Chi Wave",            IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil, "mouseover" },      
      -- Single target
      -- Chi Builders
      { "Keg Smash",            chi < 3 },
      { "Expel Harm",            jps.hp("player") < 0.90 }, -- 50% of heal will be done in damage. Correct according to health pool at level 90
      { "Jab",               energy >= 90 },
      -- Chi Finishers
      { "Purifying Brew",         jps.debuff("Heavy Stagger") or jps.debuff("Moderate Stagger") }, -- Yellow or Red
      { "Elusive Brew",         jps.buffStacks("Elusive Brew") > 10 }, -- Can stack up 15 times
      { "Guard",               jps.buffStacks("Power Guard") == 3 }, -- Can stack up 3 times
      { "Tiger Palm",            jps.buffDuration("Tiger Power") <= 1.5 or jps.buffStacks("Tiger Power") < 3 }, -- No chi cost due to Brewmaster specialization at level 34
      { "Blackout Kick",         "onCD" },
      { "Chi Brew" ,             chi == 0 },   -- If Chi Brew talent instead of Power Strikes. Almost equal Chi generation
   }

   spell = parseSpellTable(spellTable)   
   if spell == "Dizzying Haze" then jps.groundClick() end -- Hurl a keg of your finest brew!
   return spell
   
end