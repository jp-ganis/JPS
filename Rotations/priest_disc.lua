function priest_disc(self)
   local tank = jps.findMeATank()
   local me = "player"
   local defaultTarget = jps.lowestFriendly()

   if UnitExists(tank) and jps.hpInc(tank) < 0.4 then defaultTarget = tank end
   if jps.hpInc(me) < 0.2 then   defaultTarget = me end

    local defaultHP = jps.hpInc(defaultTarget)
    local focusHP = jps.hp("focus")


   local pomUp = false

    local shieldUnit = nil
    local piUnit = nil
    local unitsBelow70 = 0
    local unitsBelow50 = 0
    local unitsBelow30 = 0

   local lowestHP = UnitHealthMax("player")*100
    local evangelismstacks =  jps.buffStacks("Evangelism")
    local dispelTarget = jps.FindMeADispelTarget({"Magic"})
    local diseaseTarget = jps.FindMeADispelTarget({"Disease"})

    local rangedTarget = nil


   for unit, unitTable in pairs(jps.RaidStatus) do
        -- Check for Prayer of Mending
      if jps.buffDuration("prayer of mending",unit) > 0 then
      pomUp = true
      end
      --Only check the relevant units
      if not UnitIsDeadOrGhost(unit) and UnitIsVisible(unit) and UnitInRange(unit) and not jps.PlayerIsBlacklisted(unit) then
        -- Find a unit to shield
        local thisHP = jps.hpInc(unit)
      if thisHP < lowestHP then
         if not jps.debuff("weakened soul",unit) then
            lowestHP = thisHP
            shieldUnit = unit
         end
        end
        -- Number of people below x%
        if thisHP < 0.3 then unitsBelow30 = unitsBelow30 + 1 end
        if thisHP < 0.5 then unitsBelow50 = unitsBelow50 + 1 end
        if thisHP < 0.7 then unitsBelow70 = unitsBelow70 + 1 end

        -- Find a target for Power Infusion
        local _,unitClass = UnitClass(unit)
        if unitClass ~= nil and (unitClass == "PRIEST" or unitClass == "WARLOCK" or unitClass == "MAGE")and UnitGroupRolesAssigned(unit) == "DAMAGER" then
          piUnit = unit
        end
        if jps.mana() < 0.3 or piUnit == nil then
          piUnit = me
        end
      end
    end

    -- Find a target smite/hoy fire.
    if UnitExists("focustarget") and UnitCanAttack(me, "focustarget") and IsSpellInRange("holy fire", "focustarget")  then
      rangedTarget = "focustarget"
    elseif UnitExists("target") and UnitCanAttack(me, "target")  and IsSpellInRange("holy fire", "target") then
      rangedTarget = "target"
   elseif UnitExists("targettarget") and UnitCanAttack(me, "targettarget")  and IsSpellInRange("holy fire", "targettarget") then
      rangedTarget = "targettarget"
   end



   -- Don't kick penance
   if UnitChannelInfo(me) then return nil end

   local spellTable =
   {
      { "pain surpression",     jps.hp("focus") < 0.35, "focus", true },
      { "divine hymn",          unitsBelow30 > 2, defaultTarget },

      -- swap Inner Fire & Inner Will, only if raid is not too low on health
      { "Inner Fire",          defaultHP > 0.5 and not jps.buff("Inner Fire") and jps.mana() > 0.7, "player" },
      { "Inner Will",          defaultHP > 0.5 and not jps.buff("Inner Will") and jps.mana() < 0.5, "player" },

      { "shadowfiend",          jps.mana(me) < 0.6 },
      { "hymn of hope",          jps.mana(me) < 0.6 and defaultHP > 0.4},

      { "power infusion",       UnitExists(piUnit), piUnit },
      { "archangel",            evangelismstacks > 4, me  },
      { "dispel magic",         UnitExists(dispelTarget), dispelTarget  },
      { "cure disease",         UnitExists(diseaseTarget), diseaseTarget  },
      {"nested",                UnitExists("focus") and focusHP <= 0.5,
          {
            { "power word: shield",   focusHP < 0.5 and not jps.debuff("weakened soul","focus"), "focus" },
            { "penance",       focusHP < 0.5 , "focus" },
            { "prayer of mending",   not pomUp and unitsBelow70 > 2, "focus" },
            { "binding heal",    jps.hpInc() < 0.7, "focus" },
            { "flash heal",          focusHP < 0.3, "focus" },


          },

      },
      {"nested",                unitsBelow70 > 2,
          {
            { "power word: shield",   not jps.debuff("weakened soul",defaultTarget), defaultTarget },
            { "prayer of mending",   not pomUp , defaultTarget },
            { "inner focus",   defaultHP < 0.6 , defaultTarget },
            { "prayer of healing",   defaultHP < 0.6 , defaultTarget },
          },

      },
      {"nested",                defaultHP < 0.5,
          {
            { "power word: shield",   not jps.debuff("weakened soul",defaultTarget), defaultTarget },
            { "penance",       defaultHP < 0.5 , defaultTarget },
            { "inner focus",   defaultHP < 0.5 , defaultTarget },
            { "greater heal",   defaultHP < 0.5 , defaultTarget },
            { "holy fire",       UnitExists(rangedTarget) and not jps.debuff("holy fire",rangedTarget), rangedTarget },
          },

      },
      {"binding heal",          UnitExists(defaultTarget) and not UnitIsUnit(defaultTarget, me) and defaultHP < 0.7 and jps.hpInc() < 0.7, defaultTarget },
      {"nested",                defaultHP <= 1,
          {
            { "Fear Ward",             "refresh" ,"focus"},
            { "penance",       defaultHP < 0.75 , defaultTarget },
            { "power word: shield",   defaultHP < 0.8 and not jps.debuff("weakened soul",defaultTarget), defaultTarget },
            { "holy fire",       UnitExists(rangedTarget) and not jps.debuff("holy fire",rangedTarget), rangedTarget },
            { "smite",           UnitExists(rangedTarget) , rangedTarget },
          },

      },
   }

   local spell,target = parseSpellTable(spellTable)
   return spell
   
end
