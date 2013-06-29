function warlock_demo()
   

function mouseover_dot()

if UnitExists("mouseover")
and not UnitIsDeadOrGhost("mouseover")
and IsPlayerSpell(172)
and jps.myDebuffDuration("Corruption","mouseover") < 3
and UnitCanAttack("player", "mouseover") == 1         
and IsSpellInRange(GetSpellInfo(172), "mouseover") == 1 
and jps.Defensive           
then return true end
      return false
end

local mouseover_dot = mouseover_dot()
   
---------------------------------------------------------------------
------------------------- axeToss target list------------------------
---------------------------------------------------------------------
function axeToss ()
   local table_axeToss =
   {
      "Twilight Sapper",
      "Energy Charge",
      "Celestial Protector",
      "Unstable Sha",
      "Zandalari Dinomancer",
      "Shadowed Loa Spirit",
      "Blessed Loa Spirit",
       
       
   }
   for i,j in pairs(table_axeToss) do
   if UnitName("target") == j then return true end
   end
   return false
end


---------------------------------------------------------------------
-------------------------check spell proc function ------------------
---------------------------------------------------------------------   
function haveProc ()
   if
            jps.buff("Dark Soul: Knowledge")       
      or jps.buff("Inner Brilliance")          
         or jps.buff("Acceleration")             
         or jps.buff("Lightweave")                
         or jps.buff("Blessing of the Celestials")    
         or jps.buff("Windsong")                
         or jps.buff("Synapse Springs")             
         or jps.buff("Jade Spirit")
         or jps.buff("Quickened Tongues")
         or jps.buff("Wushoolay's Lightning")
         or jps.buff("Electrified")
         
         then return true end
      return false
end

---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------   
   
   local focus = UnitExists("focus")   
   local pet = UnitExists("pet")
   local isAxeToss = axeToss ()
   local haveProc = haveProc ()
   
   
---------------------------------------------------------------------
---------------------Banish list on focus function ------------------
---------------------------------------------------------------------   
function banishFocus ()
   local table_banishList =
   { "Elemental", "Demon", "Aberration" }
for i,j in pairs(table_banishList) do
   if UnitCreatureType("focus") == j then return true end
   end
   return false
end
   

   ----------------------------
   --  debuffstack tsulong  ---
   ----------------------------
   local TsulongStack = jps.debuffStacks(122768,"player")
   ----------------------------
   
   local stunMe =  jps.StunEvents()
   
   local cpn_duration = jps.debuffDuration("corruption")
   local doom_duration = jps.debuffDuration("Doom")
   local cur_duration = jps.debuffDuration("curse of the elements")
   local meta_duration = jps.buffDuration("metamorphosis")
   
   local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
   local dpower = UnitPower("player",15)
   

   local DarkSoul = jps.buffDuration("dark soul: knowledge")
   local mana = UnitMana("player")/UnitManaMax("player")
   local playerHP = UnitHealth("player")/UnitHealthMax("player")
   local playerMaxHP = UnitHealthMax("player")
   local targetHP = UnitHealth("target")/UnitHealthMax("target")
   local targetMaxHP = UnitHealthMax("target")
   
   local targetThreatStatus = UnitThreatSituation("player","target")
   if not targetThreatStatus then targetThreatStatus = 0 end
   local isInRaid = GetNumGroupMembers() > 0
   
   local GulCharges = 0 -- GetSpellCharges returns nil if the spell have only one charge
   if GetSpellCharges("hand of gul'dan") ~= nil then GulCharges = select(1,GetSpellCharges("hand of gul'dan")) end
   
   
   if castGulnm == nil then castGulnm = false end
   if GulCharges == 2 then castGulnm = true end
   if GulCharges == 0 then castGulnm = false end
   
    local GDCD = select(3,GetSpellCharges(105174)) + select(4,GetSpellCharges(105174)) - GetTime()

    local form = GetShapeshiftForm("player")
   
    ----------------------------
    ------ banish focus var ----
    ----------------------------
    local banishFocus = banishFocus ()
    local banishDefuff = jps.debuffDuration("Banish","focus")
    local  spell1,_,_,_,_,end1,_,_,_ = UnitCastingInfo("player")
    if endtimeBan == nil then endtimeBan = 0 end
    if spell1 == "Banish" then endtimeBan = (end1/1000) end
   
   
    ----------------------------
    ------ Doting Focus     ----
    ----------------------------
   local focus_fear_dur = jps.debuffDuration("fear","focus")
   local focus_cpn_duration = jps.debuffDuration("corruption","focus")
   local focus_doom_duration = jps.debuffDuration("Doom","focus")

   
--------------------------------------------------------------
----------------------Guld'an  function--------------------------
--------------------------------------------------------------   

 function canMetha_Gul ()
 if GulCharges < 2  and GDCD <= 11 or GetShapeshiftForm("player") == 1
         then return false end
      return true
end
--------------------------------------------------------------
----------------------canDpsFocus function--------------------
-----------------use jps.defensive for activate---------------   
 function canDpsFocus ()

   if focus
   and  jps.canDPS("focus")
   and  not banishFocus
   and jps.Defensive
   then return true end
      return false
end

 
--------------------------------------------------------------
----------------------special boss function-------------------
--------------------------------------------------------------   
function bossSpecial ()
   local table_boss =
   { "Horridon",
   "Ji-Kun", }
   for i,j in pairs(table_boss) do
   if UnitName("boss1") == j then return true end
   end
   return false
end



 
local canMetha_Gul = canMetha_Gul ()
local canDpsfocus = canDpsFocus ()
local bossSpecial = bossSpecial ()

local player = jpsName
local autoDispelMAgic = jps.MagicDispel("player")


----------------------------------
---------- talent spy ------------
----------------------------------

function jps.talentInfo (talentInfo)
   local numTalents = GetNumTalents();
   for t = 1, numTalents do
      local name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq, previewRank, meetsPreviewPrereq= GetTalentInfo(t);
      if name == talentInfo and ( rank ) then return true end
   end
   return false
end

local dpsMoving = jps.talentInfo("Kil'jaeden's Cunning")


   

 
-------------------
-- trinket stack --
-------------------

local trinketstack = jps.buffStacks("Electrified","player")
   
   
---------------------------------------
-------- canMeta function ------------
---------------------------------------
function canMeta ()

   if
   
   ( not jps.buff("metamorphosis")
   and not jps.Opening )
         
   and
   
   ( ( jps.debuff("corruption") and not jps.debuff("Doom") )
   or ( dpower >= 900 and not haveProc and GulCharges == 0 )
   or ( dpower >= 850 and haveProc and GulCharges == 0 )
   or ( trinketstack >= 8 and doom_duration < 60 ) )
           
   then return true end
      return false
    end

local canMeta = canMeta()

---------------------------------------
-------- cancelMeta function ----------
---------------------------------------
function cancelMeta ()

   if
   
   ( jps.buff("metamorphosis")
   and not jps.Opening
   and jps.hp("target") >= 0.25
   and doom_duration >= 25 )
 
   and
   
   (  ( dpower < 700 and not haveProc )
   or ( dpower < 500 and haveProc )
   )

           
   then return true end
      return false
    end

local cancelMeta = cancelMeta()


---------------------------------------
-------- reCastdot function -----------
---------------------------------------
function reCastdoom ()

   if not jps.Opening
   and
   (
   ( trinketstack >= 9 and doom_duration < 85 )
   or (doom_duration <= 40 and dpower <= 200 )
   or (doom_duration <= 60 and haveProc )
   or doom_duration < 28 )
       
   then return true end
      return false
    end

local reCastdoom = reCastdoom ()

-------------------- mouseover / focus conditions ---------------------
    local attackFocus = false
    local attackMouseOver = false
 
    -- If focus exists and is not the same as target, consider attacking focus too
    if UnitExists("focus") ~= nil and UnitGUID("target") ~= UnitGUID("focus") and not UnitIsFriend("player", "focus") and not jps.debuff("Banish","focus")then
        attackFocus = true
    end
    -- If focus exists and is not the same as target, consider attacking focus too
    if not jps.debuff("Banish","mouseover") and UnitExists("mouseover") ~= nil and UnitGUID("target") ~= UnitGUID("mouseover") and not UnitIsFriend("player", "mouseover") then
        attackMouseOver = true
    end
---------------------------------------
----------- opening table -------------
---------------------------------------

local function opening() -- return table
   local table=
         {
   { "dark soul: knowledge", jps.Opening  },
    { "imp swarm", jps.Opening },
    { "hand of gul'dan", GulCharges > 1 and not jps.buff("metamorphosis") and jps.Opening }, 
    { "hand of gul'dan", GulCharges < 2 and not jps.buff("metamorphosis") and jps.Opening and GDCD <= 11 },
    { "Grimoire: Felguard", not jps.buff("metamorphosis") and jps.Opening },
    { "corruption", not jps.debuff("corruption") and not jps.buff("metamorphosis") and jps.Opening },
    { "metamorphosis", jps.Opening and not jps.buff("metamorphosis") and GulCharges == 0  },
    { "corruption",  jps.buff("metamorphosis") and jps.Opening and not jps.debuff("Doom") },
    { "corruption",  jps.buff("metamorphosis") and jps.Opening and doom_duration < 70 }, -- doom for pandemic effect --
    { 1490, jps.debuff(1490) and jps.buff("metamorphosis") and not jps.buff(116202,"player") },
    { {"macro","/cancelaura metamorphosis"},  jps.buff("metamorphosis") and jps.Opening and doom_duration > 80},
         }
return table
end
   
---------------------------------------------------------------------------------------------------------------------
----------------------------------- corruption and doom on mouseover table ------------------------------------------
---------------------------------------------------------------------------------------------------------------------


local function dot_mousover() -- return table
   local table=
               {
    { "corruption", not jps.buff("metamorphosis") and not jps.mydebuff("Corruption","mouseover") and attackMouseOver, "mouseover" },    ----- corruption mouseover ----
      { "corruption", jps.buff("metamorphosis") and jps.mydebuff("Corruption","mouseover") and attackMouseOver , "mouseover" },          ----- doom nmouseover ----
   
    { "corruption", not jps.buff("metamorphosis") and not jps.mydebuff("Corruption","focus") and attackFocus, "focus" },    ----- corruption focus ----
      { "corruption", jps.buff("metamorphosis") and jps.mydebuff("Corruption","focus") and attackFocus , "focus" },          ----- doom focus -------     
               }
return table
end   

   

------------------------------------------------------------------------------------------------------
-----------------------------------------  Aoe Table in meta form ------------------------------------
------------------------------------------------------------------------------------------------------

local function AOEmeta_table() -- return table
   local table=
               {
           { "hellfire", not jps.buff("Immolation Aura") },
            { "hand of gul'dan" }, 
            { 103967  },         --carion swarm
                 }
return table
end   


------------------------------------------------------------------------------------------------------
-----------------------------------------  meta table ------------------------------------------------
------------------------------------------------------------------------------------------------------

local function meta_table() -- return table
   local table=
            {
   { "corruption", doom_duration < 40 or reCastdoom },
   { "nested",jps.MultiTarget , AOEmeta_table() },                        -------- Aoe with jps.MultiTarget
   { {"macro","/cancelaura metamorphosis"},  cancelMeta and not reCastdoom  },
   { "soul fire", jps.buffDuration("molten core") >= 2.2 },
   { "soul fire", jps.hp("target") <= 0.25 },
   { "shadow bolt" },   
              }
return table
end   

------------------------------------------------------------------------------------------------------
-----------------------------------------  human table -----------------------------------------------
------------------------------------------------------------------------------------------------------

local function human_table() -- return table
   local table=
            {
      { 172, cpn_duration < 3  or (cpn_duration < 15 and haveProc)  },
      { "felstorm", pet and not jps.Opening and jps.Interrupts },
    { "hand of gul'dan", not jps.Opening },
     { "soul fire", jps.hp("target") <= 0.25  },
     { "shadow bolt", jps.buffDuration("molten core") <= 2.2 },
     { "soul fire", jps.buffDuration("molten core") > 2.2 },
     { "shadow bolt", not jps.buff("metamorphosis") },
              }
return table
end   

-----------------------------------------------------------------------------------
--------------   function SpellStopCasting for unwanted soulfire ------------------
-----------------------------------------------------------------------------------
function StopCasting ()
if jps.IsCastingSpell(6353,"player") and jps.castTimeLeft(player) >= 3
   then return true end
      return false
    end
   
local StopCasting = StopCasting ()
if  jps.IsCasting("player") and StopCasting then SpellStopCasting() end


local spellTable = { }
spellTable[1] = {
      
   ["ToolTip"] = "Demo Raid",
   
   { {"macro","/focus [target=mouseover,exists,nodead]"}, IsShiftKeyDown() ~= nil },
      
---------------------------- banish focus if banishable -------------------------------------------------
    { "Banish", banishFocus  and not jps.debuff("Banish","focus") and endtimeBan+2 < GetTime() and jps.Interrupts, "focus" },
   
---------------------------------------- Survival Cd/regen ----------------------------------------------   
    { "soulshatter", targetThreatStatus ~= 0 and isInRaid },                                          --- aggro reduction ----
    { jps.Macro("/use Healthstone"),  jps.itemCooldown(5512)==0 and jps.hp() < 0.4 and GetItemCount(5512) > 0   },   --- Healthstone ----
     { 108482, jps.cooldown(108482) == 0 and (stunMe or autoDispelMAgic and jps.Interrupts )   },                -- unStunt/dispell jps.Interrupts for on/off ---
    { 6229, (TsulongStack > 9 and jps.cooldown(6229) == 0) or (dmgSchool and jps.cooldown(6229) == 0) },          -- shield on shadow damage ---
      { "life tap", mana < 0.25 and jps.hp("player") > 0.6 },                                             -- regen mana --
   { 108416, playerHP < 0.70 and jps.cooldown(108416) == 0  },                                          -- sacrifical pact--
      { "mortal coil",      jps.hp("player") < 0.60 },
      { "unending resolve",   jps.hp("player") < 0.35 },
      
-----------------------  Curse of Element human/meta form ----------------------------------------------       
   { 1490, not jps.debuff(1490) and not jps.buff("metamorphosis") },
   { 1490, jps.debuff(1490) and jps.buff("metamorphosis") and not jps.buff(116202,"player") },
   
---------------------------------------- Cd when up ----------------------------------------------------      
   { jps.Macro("/use 10"), jps.glovesCooldown() == 0 },                     --inge --
      { jps.DPSRacial },                                             --racial --
      { "dark soul: knowledge", not jps.Opening   },   
      { "imp swarm" },
      { "Grimoire: Felguard", not jps.buff("metamorphosis") and not jps.Opening },
----------------- axe toss to interupts or stunt if target is in stuntlist ----
   { 89766, jps.cooldown("axe toss") == 0 and ((pet and isAxeToss ) or (jps.shouldKick and pet))  },
   
---------------------------------------- opening ------------------------------------------------------     
      { "nested", jps.Opening , opening() },
      
---------------------------------------- Dot/ban on focus or Mouseover --------------------------------
   { "nested", mouseover_dot , dot_mousover() },
   
---------------------------------------- Methamorphosis -----------------------------------------------   
   { "metamorphosis", canMeta  },
   { "nested", jps.buff("metamorphosis") and not jps.Opening , meta_table() },
   
---------------------------------------- human form --------------------------------------------------- 
     { "nested", not jps.buff("metamorphosis") and not jps.Opening , human_table() },
}

if jps.debuff("Doom") and form == 0 then jps.Opening = false end

local spellTableActive = jps.RotationActive(spellTable)
   spell,target = parseSpellTable(spellTableActive)
   return spell,target
end