function shaman_resto_arena()
-- TO DO : better code/rotation style 

local spell = nil
local target = nil
	
   local lsStacks = jps.buffStacks("lightning shield")
   local focus = "focus"
   local me = "player"
   local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()
   local engineering ="/use 10"
   local r = jps.Macro
   local tank = nil
   
   local my_friend_name = jpsName -- Player
   local stunAly = jps.StunEvents() -- return true/false
   
   -- Totems
   local haveFireTotem, fireName, _, _, _ = GetTotemInfo(1)
   local haveEarthTotem, earthName, _, _, _ = GetTotemInfo(2)
   local haveWaterTotem, waterName, _, _, _ = GetTotemInfo(3)
   local haveAirTotem, airName, _, _, _ = GetTotemInfo(4)

   -- Setting Arena enemies
   local arenaEnemy1 = "arena1"
   local arenaEnemy2 = "arena2"

   -- Getting their classes
   local arenaEnemy1Class, _ = UnitClass(arenaEnemy1)
   local arenaEnemy2Class, _ = UnitClass(arenaEnemy2)
   
   -- Getting the spell they're casting
   local spellArenaEnemy1, _, _, _, startTime1, endTime1 = UnitCastingInfo(arenaEnemy1)
   local spellArenaEnemy2, _, _, _, startTime2, endTime2 = UnitCastingInfo(arenaEnemy2)
   
   -- Creating variables in case enemy are druid mage or paladin
   local druid = nil
   local mage = nil
   local paladin = nil
   
   -- Creating variable that will hold enemies class
   local classArenaEnemy1 = nil
   local classArenaEnemy2 = nil
   
   if UnitClass(arenaEnemy1) then
      classArenaEnemy1, _ = UnitClass(arenaEnemy1)
   end
   
   if UnitClass(arenaEnemy2) then
      classArenaEnemy2, _ = UnitClass(arenaEnemy2)
   end
   
   -- Checking if there is any druid, paladin or mage
   if UnitExists(arenaEnemy1) and classArenaEnemy1=="Druid" then
      druid = arenaEnemy1
   elseif UnitExists(arenaEnemy2) and classArenaEnemy2=="Druid" then
      druid = arenaEnemy2
   end
   
   if UnitExists(arenaEnemy1) and classArenaEnemy1=="Mage" then
      mage = arenaEnemy1
   elseif UnitExists(arenaEnemy2) and classArenaEnemy2=="Mage" then
      mage = arenaEnemy2
   end
   
   if UnitExists(arenaEnemy1) and classArenaEnemy1=="Paladin" then
      paladin = arenaEnemy1
   elseif UnitExists(arenaEnemy2) and classArenaEnemy2=="Paladin" then
      paladin = arenaEnemy2
   end
   
   -- Creating variables that will hold their spells
   local spellArenaMage, _, _, _, startTimeM, endTimeM = nil
   local spellArenaPaladin, _, _, _, startTimeP, endTimeP = nil
   local spellArenaDruid, _, _, _, startTimeD, endTimeD = nil
   
   -- Getting their spells
   if UnitExists(mage) then
      spellArenaMage, _, _, _, startTimeM, endTimeM = UnitCastingInfo(mage)
   end
   
   if UnitExists(paladin) then
      spellArenaPaladin, _, _, _, startTimeP, endTimeP = UnitCastingInfo(paladin)
   end
   
   if UnitExists(druid) then
      spellArenaDruid, _, _, _, startTimeD, endTimeD = UnitCastingInfo(druid)
   end
   
   -- Creating variable for enemy healer
   local enemyHealer = nil
      
    -- Update spec from API for arenaEnemy1 to check if he is a healer
   if UnitExists(arenaEnemy1) then
      local specID1 = GetArenaOpponentSpec(1)
      if (specID1 > 0) then
         local _, spec1, _, specIcon1, _, role1, class1 = GetSpecializationInfoByID(specID1);
         if role1=="HEALER" then
            enemyHealer = arenaEnemy1
            jps.Macro("/focus [@arena1]")
         end
      end
   end   

    -- Update spec from API for arenaEnemy2 to check if he is a healer
   if UnitExists(arenaEnemy2) then
      local specID2 = GetArenaOpponentSpec(2);
      if (specID2 > 0) then
         local _, spec2, _, specIcon2, _, role2, class2 = GetSpecializationInfoByID(specID2);
         if role2=="HEALER" then
            enemyHealer = arenaEnemy2
            jps.Macro("/focus [@arena2]")
         end
      end
   end

   
   -- If there isn't any healer I want to have in focus these classes with this order of priority
   if  UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy1) and classArenaEnemy1=="Warlock" then
      jps.Macro("/focus [@arena1]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy1) and classArenaEnemy1=="Mage" then
      jps.Macro("/focus [@arena1]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy1) and classArenaEnemy1=="Shaman" then
      jps.Macro("/focus [@arena1]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy1) and classArenaEnemy1=="Priest" then
      jps.Macro("/focus [@arena1]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy1) and classArenaEnemy1=="Druid" then
      jps.Macro("/focus [@arena1]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy2) and classArenaEnemy2=="Warlock" then
      jps.Macro("/focus [@arena2]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy2) and classArenaEnemy2=="Mage" then
      jps.Macro("/focus [@arena2]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy2) and classArenaEnemy2=="Shaman" then
      jps.Macro("/focus [@arena2]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy2) and classArenaEnemy2=="Priest" then
      jps.Macro("/focus [@arena2]")
   elseif UnitExists(enemyHealer)==nil and UnitExists(arenaEnemy2) and classArenaEnemy2=="Druid" then
      jps.Macro("/focus [@arena2]")
   end
   
      
   -- Getting enemy healer spell
   local enemyHealerSpell, _, _, _, EHstartTime, EHendTime = nil
   if UnitExists(enemyHealer)==1 then
      enemyHealerSpell, _, _, _, EHstartTime, EHendTime = UnitCastingInfo(enemyHealer)
   end
   

   -- CD WHEN I'm in trouble
   if  IsEquippedItem("Malevolent Gladiator's Emblem of Meditation") and select(1,GetItemCooldown(84939))==0 and IsUsableItem("Malevolent Gladiator's Emblem of Meditation") and jps.hp(me) < 0.25 then 
      jps.Macro("/use Malevolent Gladiator's Emblem of Meditation")
      spell = "Healing Tide Totem"
      return spell
   end

   if jps.cooldown("Ancestral Swiftness")==0 and jps.hp(me) < 0.3 then
      SpellStopCasting()
      jps.Target = me
      print("-- EMERGENCY INSTANT --")
      jps.Macro("/cast Ancestral Swiftness")
      spell = "Greater Healing Wave"
   return spell end


   -- CD WHEN my_friend_name is in trouble
   if jps.cooldown("Ancestral Swiftness")==0 and jps.hp(my_friend_name) < 0.30 and UnitIsVisible(my_friend_name) and IsSpellInRange("Greater Healing Wave", my_friend_name) then
      SpellStopCasting()
      jps.Target = my_friend_name
      print("-- EMERGENCY INSTANT ON my_friend_name --")
      jps.Macro("/cast Ancestral Swiftness")
      spell = "Greater Healing Wave"
   return spell end   


   -- ANTI FEAR
   local feared = jps.debuff("fear","player") or jps.debuff("intimidating shout","player") or jps.debuff("howl of terror","player") or jps.debuff("psychic scream","player")
   if feared and jps.cooldown("Grounding Totem")==0 then
      spell = "Tremor totem"
      print("-- ANTI FEAR --")
   return spell end


   -- MAGE BUSINESS (glebe and kick damn polymorph)
   if spellArenaMage == "Polymorph" and UnitExists(mage)==1 and jps.CastTimeLeft(mage) < 1 and jps.cooldown("Grounding Totem")==0 then
      SpellStopCasting()
      jps.Target = mage
      spell = "Grounding Totem"
      print("-- GLEBE MAGE --")
      return spell
   elseif spellArenaMage == "Polymorph" and UnitExists(mage)==1 and jps.CastTimeLeft(mage) < 0.5 and jps.CastTimeLeft(mage)  > 0.01 and jps.cooldown("Wind Shear")==0 and not (airName=="Grounding Totem")  and not (jps.cooldown("Grounding Totem")==0) and UnitIsVisible(mage) then
      SpellStopCasting()
      jps.Target = mage
      spell = "Wind Shear"
      print("-- KICK MAGE --")
      return spell
   end


   -- PALADIN BUSINESS (glebe and kick damn repentance)
   if spellArenaPaladin == "Repentance" and UnitExists(paladin)==1 and jps.CastTimeLeft(paladin) < 1 and jps.cooldown("Grounding Totem")==0 then
      SpellStopCasting()
      jps.Target = paladin
      spell = "Grounding Totem"
      print("-- GLEBE PALADIN --")
      return spell
   elseif spellArenaPaladin == "Repentance" and UnitExists(paladin)==1 and jps.CastTimeLeft(paladin) < 0.5 and jps.CastTimeLeft(paladin)  > 0.01 and jps.cooldown("Wind Shear")==0 and not (airName=="Grounding Totem")  and not (jps.cooldown("Grounding Totem")==0) and UnitIsVisible(paladin) then
      SpellStopCasting()
      jps.Target = paladin
      spell = "Wind Shear"
      print("-- KICK PALADIN --")
      return spell
   end

   
   -- DRUID BUSINESS (glebe and kick damn cyclone)
   if spellArenaDruid == "Cyclone" and UnitExists(druid)==1 and jps.CastTimeLeft(druid) < 1 and jps.cooldown("Grounding Totem")==0 then
      SpellStopCasting()
      jps.Target = druid
      spell = "Grounding Totem"
      print("-- GLEBE --")
      return spell
   elseif spellArenaDruid == "Cyclone" and UnitExists(druid)==1 and jps.CastTimeLeft(druid) < 0.5 and jps.CastTimeLeft(druid)  > 0.01 and jps.cooldown("Wind Shear")==0 and not (airName=="Grounding Totem")  and not (jps.cooldown("Grounding Totem")==0) and UnitIsVisible(druid) then
      SpellStopCasting()
      jps.Target = druid
      spell = "Wind Shear"
      print("-- KICK --")
      return spell
   end
   

   -- Dispel my friend Stun
   if UnitIsVisible(my_friend_name) and IsSpellInRange("Purify Spirit", my_friend_name) and stunAly then
      jps.Target = my_friend_name
      spell = "Purify Spirit"
      return spell
   end

   -- Auto Kick penance as soon as he started it
   if UnitExists(enemyHealer)==1 and enemyHealerSpell=="Penance" and jps.CastTimeLeft(enemyHealer)  < 2 and jps.CastTimeLeft(enemyHealer)  > 0.01 and jps.cooldown("Wind Shear")==0 and UnitIsEnemy("player",enemyHealer)==1 and UnitIsVisible(enemyHealer) and not (spellEnemyHealer == "Cyclone") and not (spellEnemyHealer == "Repentance") and not (spellEnemyHealer == "Polymorph") then
      SpellStopCasting()
      jps.Target = enemyHealer
      spell = "Wind Shear"
      print("-- AUTO KICK PENANCE --")
      return spell
   end


   -- Auto Kick by priority order, if there's a healer he gets kicked first then his friend
   if UnitExists(enemyHealer)==1 and jps.CastTimeLeft(enemyHealer)  < 0.8 and jps.CastTimeLeft(enemyHealer)  > 0.01 and jps.cooldown("Wind Shear")==0 and UnitIsEnemy("player",enemyHealer)==1 and UnitIsVisible(enemyHealer) and not (spellEnemyHealer == "Cyclone") and not (spellEnemyHealer == "Repentance") and not (spellEnemyHealer == "Polymorph") then
      -- I know this is stupid to check if healer cast polymorph but that way I feel like everything is checked ...
      SpellStopCasting()
      jps.Target = enemyHealer
      spell = "Wind Shear"
      print("-- AUTO KICK HEALER --")
      return spell
   elseif UnitExists(arenaEnemy1)==1 and jps.CastTimeLeft(arenaEnemy1)  < 0.8 and jps.CastTimeLeft(arenaEnemy1)  > 0.01 and jps.cooldown("Wind Shear")==0 and UnitIsEnemy("player",arenaEnemy1)==1 and UnitIsVisible(arenaEnemy1) and not (spellArenaEnemy1 == "Cyclone") and not (spellArenaEnemy1 == "Repentance") and not (spellArenaEnemy1 == "Polymorph") then
      SpellStopCasting()
      jps.Target = arenaEnemy1
      spell = "Wind Shear"
      print("-- AUTO KICK ARENA 1 --")
      return spell
   elseif UnitExists(arenaEnemy2)==1 and jps.CastTimeLeft(arenaEnemy2)  < 0.8 and jps.CastTimeLeft(arenaEnemy2)  > 0.01 and jps.cooldown("Wind Shear")==0 and UnitIsEnemy("player",arenaEnemy2)==1 and UnitIsVisible(arenaEnemy2) and not (spellArenaEnemy2 == "Cyclone") and not (spellArenaEnemy2 == "Repentance") and not (spellArenaEnemy2 == "Polymorph") then
      SpellStopCasting()
      jps.Target = arenaEnemy2
      spell = "Wind Shear"
      print("-- AUTO KICK ARENA 2 --")
      return spell
   end


   -- Dispel offensive with a priority order, the healer then my target then enemy1 then enemy2
   local dispelOffensive_Enemy1 = jps.DispelOffensive(arenaEnemy1) -- return true/false
   local dispelOffensive_Enemy2 = jps.DispelOffensive(arenaEnemy2) -- return true/false
   local dispelOffensive_Healer = jps.DispelOffensive(enemyHealer) -- return true/false
   local dispelOffensive_Target = jps.DispelOffensive("target") -- return true/false
   if dispelOffensive_Healer and IsSpellInRange("Purge", enemyHealer) and UnitIsVisible(enemyHealer) and UnitExists(enemyHealer)==1 and UnitIsEnemy("player", enemyHealer)==1 then
      jps.Target = enemyHealer
      spell = "Purge"
      return spell
   elseif dispelOffensive_Target and IsSpellInRange("Purge", "Target") and UnitIsVisible("Target") and UnitExists("Target")==1 and UnitIsEnemy("player", "Target")==1 then
      jps.Target = "Target"
      spell = "Purge"
      return spell
   elseif dispelOffensive_Enemy1 and IsSpellInRange("Purge", arenaEnemy1) and UnitIsVisible(arenaEnemy1) and UnitExists(arenaEnemy1)==1 and UnitIsEnemy("player", arenaEnemy1)==1 then
      jps.Target = arenaEnemy1      
      spell = "Purge"
      return spell
   elseif dispelOffensive_Enemy2 and IsSpellInRange("Purge", arenaEnemy2) and UnitIsVisible(arenaEnemy2) and UnitExists(arenaEnemy2)==1 and UnitIsEnemy("player", arenaEnemy2)==1 then
      jps.Target = arenaEnemy2
      spell = "Purge"
      return spell
   end
   
   -- Priority Table
   local spellTable = {
   }
   
	spell,target = parseSpellTable(spellTable)
	return spell,target 
end