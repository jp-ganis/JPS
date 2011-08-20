-- contains the average value of non critical healing spells

healtable = {}

-- Updates the healtable
function update_healtable(...)
        local temparglist = {...}
        if temparglist[5] == GetUnitName("player") and (temparglist[2] == "SPELL_HEAL" or temparglist[2] == "SPELL_PERIODIC_HEAL") and temparglist[15] == 0 then
          if healtable[temparglist[11]]== nil then
            healtable[temparglist[11]]= {["healtotal"]= temparglist[13],["healcount"]= 1,["averageheal"]= temparglist[13]}
          else
            healtable[temparglist[11]]["healtotal"]= healtable[temparglist[11]]["healtotal"]+temparglist[13];
            healtable[temparglist[11]]["healcount"]= healtable[temparglist[11]]["healcount"]+1;
            healtable[temparglist[11]]["averageheal"]= healtable[temparglist[11]]["healtotal"]/healtable[temparglist[11]]["healcount"];
          end;

  --          print(temparglist[11],"  ",healtable[temparglist[11]]["healtotal"],"  ",healtable[temparglist[11]]["healcount"],"  ",healtable[temparglist[11]]["averageheal"])
        end
end

-- Resets the count of each healing spell to 1 makes sure that the average takes continuously into account changes in stats due to buffs etc

function reset_healtable(self)
  for k,v in pairs(healtable) do
    healtable[k]["healtotal"]= healtable[k]["averageheal"];
    healtable[k]["healcount"]= 1;
  end
end

-- displays the different health values - mainly for tweaking/debugging

function print_healtable(self)
  for k,v in pairs(healtable) do
    print(k,":  ", healtable[k]["healtotal"],"  ", healtable[k]["healcount"],"  ", healtable[k]["averageheal"]);
  end
end

-- returns the average heal value of given spell. Needs to be extended for other classes, but takes into account Echo of Light (1+ GetMastery()* 0.0125) and Divine Touch (increaser) for holy priests

function getaverage_heal(spellname)
  local multiplier = 1
  local increaser = 0
  if spellname == "Renew" then
    if GetRangedHaste() < 12.5 then
      multiplier = 4
      else multiplayer = 5;
    end
    increaser =  getaverage_heal("Divine Touch");
  end

  if healtable[spellname] ~= nil then
    return (healtable[spellname]["averageheal"]+increaser) * (1+ GetMastery()* 0.0125) * multiplier
  else
    return 0
  end
end


function priest_holy(self)

	local priest_spell = nil
	local Priest_Target = "player"
	local Priest_Target_TANK = "focus"
	local health_deficiency = 0 
	local health_pct = 1
	local total_health_deficiency = 0
	local prayerofhealingcount = 0
	local playerhealth_deficiency = UnitHealthMax("player")-UnitHealth("player")
	local focushealth_deficiency = UnitHealthMax("focus")-UnitHealth("focus")
	
	local stackSerendip = jps.get_buff_stacks("player","Serendipity")
	local health_deficiency_TANK = 0
	local health_pct_TANK = 1
	
	local numberofinjured = 0
 	local focustarget_can_be_dispelled = false

   -- identify if group is a party or raid. This has NOT been tested at all in a raid modus, only 5-man's heroic --

    local group_type;
    group_type="raid";
    nps=1;
    npe=GetNumRaidMembers();
    if npe==0 then
    group_type="party"
    nps=0;
    npe=GetNumPartyMembers();
    end;

	for i=nps,npe do
		if i==0 then
		tt="player"
		else
		tt=group_type..i
		end

-- Find the partymember (including focus and self) who is missing most health in absolute terms
-- UnitGetIncomingHeals("player") to show incoming on "player" or UnitGetIncomingHeals("player", "party1") to show incoming to party1 from player
-- UnitGetIncomingHeals does not take all renew value add it to avoid overheal

		if UnitExists(tt) and UnitInRange(tt) and UnitIsDeadOrGhost(tt)~=1 and not jps.PlayerIsExcluded(tt) and (UnitHealth(tt) + UnitGetIncomingHeals(tt) + average_renew < UnitHealthMax(tt)) then
			abshealthdef= UnitHealthMax(tt) - UnitHealth(tt);
			relhealthdef= UnitHealth(tt) / UnitHealthMax(tt);
			if (abshealthdef > health_deficiency) then
				health_deficiency = abshealthdef;
				health_pct = relhealthdef;
				Priest_Target=tt;
			end
			
-- counts the number of party members having a significant health loss and the combined healthloss these have, used for Circle of Healing and Prayer of Mending

			if abshealthdef > average_POH then
				prayerofhealingcount = prayerofhealingcount + 1;
				total_health_deficiency = total_health_deficiency + abshealthdef;
			end
		end
		
-- UnitGroupRolesAssigned(tt)=="TANK" health + average_renew to avoid overheal TANK

		if UnitExists(tt) and UnitInRange(tt) and UnitIsDeadOrGhost(tt)~=1 and not jps.PlayerIsExcluded(tt) and UnitGroupRolesAssigned(tt)=="TANK" then
			health_deficiency_TANK = (UnitHealthMax(tt) + average_renew) - UnitHealth(tt)
			health_pct_TANK = UnitHealth(tt) / UnitHealthMax(tt)
			Priest_Target_TANK=tt;
		elseif UnitGroupRolesAssigned(tt)==nil then
			health_deficiency_TANK = (UnitHealthMax("focus") + average_renew) - UnitHealth("focus")
			health_pct_TANK = UnitHealth("focus") / UnitHealthMax("focus")
			Priest_Target_TANK = "focus"
		end

	end

   if UnitExists("focustarget")~=nil then

         for j=1,40 do
            d={UnitBuff("focustarget",j)}
            if d~=nil and d[5]=="Magic" then
               focustarget_can_be_dispelled = true
            end
         end
   end

-- Let's buff --
   if not ub("player", "Inner Fire") then
     priest_spell = "Inner Fire"
     jps.Target = "player" 

   elseif not ub("player", "Power Word: Fortitude") then
     priest_spell = "Power Word: Fortitude"
     jps.Target = "player" 
     
-- Chakra
	elseif cd("Chakra")==0 and not ub("player","Chakra") and not ub("player","Chakra: Serenity") then
		priest_spell = "Chakra"
	elseif ub("player","Chakra") and not ub("player","Chakra: Serenity") then
		if (health_deficiency < getaverage_heal("Flash Heal")) and IsSpellInRange("Heal",Priest_Target)==1 then
		priest_spell = "Heal"
		jps.Target = Priest_Target
		elseif (health_deficiency > getaverage_heal("Flash Heal")) and IsSpellInRange("Heal",Priest_Target)==1 then
		priest_spell = "Flash Heal"
		jps.Target = Priest_Target
		else
		priest_spell = "Heal"
		jps.Target = "player"
		end

   -- Guardian Spirit in case tank is very low on health, guardian spirit will never be cast on dps--
   elseif (health_pct < 0.25) and cd("Guardian Spirit")==0 and IsUsableSpell("Guardian Spirit") and jps.can_cast("Guardian Spirit", Priest_Target) then
      SpellStopCasting()
      priest_spell = "Guardian Spirit"
      jps.Target = Priest_Target 

   -- Cast Desperate Prayer on self in case of trouble--
   elseif cd("Desperate Prayer")==0 and UnitHealth("player")/UnitHealthMax("player") < 0.40 then
      SpellStopCasting()
      priest_spell = "Desperate Prayer"
      jps.Target = "player" 
		
   -- cast fade in case you are being attacked
   elseif UnitThreatSituation("player")==3 and cd("Fade")==0 then
    	priest_spell = "Fade"
		jps.Target = "player"
		
   -- Renew is top priority on targets who have moderate damage
   elseif cd("Renew")==0 and IsUsableSpell("Renew") and jps.can_cast("Renew", Priest_Target) and not ub(Priest_Target,"renew")
   and health_deficiency > (getaverage_heal("Renew") + getaverage_heal("Heal")) then
     	priest_spell = "Renew"
		jps.Target = Priest_Target
		
	-- Prayer of mending on tank
	elseif cd("Prayer of Mending")==0 and not ub(Priest_Target_TANK,"Prayer of Mending") and jps.can_cast("Prayer of Mending",Priest_Target_TANK)==1 then
		spell = "Prayer of Mending"
		jps.Target = Priest_Target_TANK
	
   -- Prayer of mending in case  at least 2 party members have suffered enough healthloss
   elseif cd("Prayer of Mending")==0 and not ub(Priest_Target,"Prayer of Mending") and jps.can_cast("Prayer of Mending", Priest_Target)
   and health_deficiency > getaverage_heal("Prayer of Mending") and prayerofhealingcount > 1 then
     	priest_spell = "Prayer of Mending"
		jps.Target = Priest_Target
	
   -- Insta cast flashheal for 0 mana in case surge of light and target is missing enough health to avoid overhealing--
   elseif ub("player", "surge of light") and cd("Flash Heal")==0 and IsUsableSpell("Flash Heal") and jps.can_cast("Flash Heal", Priest_Target)
   and health_deficiency > getaverage_heal("Flash Heal") then
      priest_spell = "Flash Heal"
      jps.Target = Priest_Target
      
   -- Cast Holy Word: Serenity - CanCast does not work on this type of spell, so I take renew for IsSpellInRange
   elseif cd(88684)==0 and IsUsableSpell(88684) and IsSpellInRange("Renew",Priest_Target)==1 and health_deficiency > (getaverage_heal("Renew") + getaverage_heal("Heal")) then
      priest_spell = "Holy Word: Serenity"
      jps.Target = Priest_Target
      
   -- Circle of healing in case at least 4 party members require healing --
   elseif prayerofhealingcount > 3 and cd("Circle of Healing")==0 then
      	if IsSpellInRange("Circle of Healing",Priest_Target)==1 then
			spell = "Circle of Healing"
			jps.Target = Priest_Target
		else
			spell = "Circle of Healing"
			jps.Target = "player"
		end

   -- if at least 4 partymembers around you require at least 8k health, cast prayer of healing--
   elseif prayerofhealingcount > 3 and (total_health_deficiency > 8*getaverage_heal("Prayer of Healing")) and cd("Prayer of Healing")==0 and IsUsableSpell("Prayer of Healing") then
		if (IsSpellInRange("Prayer of Healing",Priest_Target)==1) then
			spell = "Prayer of Healing"
			jps.Target = Priest_Target
		else
			spell = "Prayer of Healing"
			jps.Target = "player"
		end

   -- cast flashheal if very high health loss and serendipitystacks < 2  --
   elseif health_pct < 0.50 and stackSerendip < 2 and cd("Flash Heal")==0 and IsUsableSpell("Flash Heal") and jps.can_cast("Flash Heal", Priest_Target) then
     priest_spell = "Flash Heal"
     jps.Target = Priest_Target

   -- main healing spell when high damage  --
   elseif health_pct < 0.70 and cd("Greater Heal")==0 and IsUsableSpell("Greater Heal") and jps.can_cast("Greater Heal", Priest_Target)
   and health_deficiency > (getaverage_heal("Greater Heal") + getaverage_heal("Renew")) then
     priest_spell = "Greater Heal"
     jps.Target = Priest_Target

   elseif (GetUnitName(Priest_Target)~=GetUnitName("player")) and cd("Soins de lien")==0 and IsUsableSpell("Soins de lien") and jps.can_cast("Binding Heal", Priest_Target)
   and health_deficiency > (getaverage_heal("Binding Heal") + getaverage_heal("Renew")) and playerhealth_deficiency > (getaverage_heal("Binding Heal") + getaverage_heal("Renew")) then
      priest_spell = "Binding Heal"
      jps.Target = Priest_Target

   -- dispel magic on tanks target, only when right mouse button is pressed--
   elseif focustarget_can_be_dispelled and IsMouseButtonDown(2) and jps.can_cast("Dispel Magic", "focustarget") then
        print("Dispelling: ",GetUnitName("focustarget"))
        priest_spell = "Dispel Magic"
        Priest_Target = "focustarget" 

   --cleanse if right MouseButtonDown
   elseif IsMouseButtonDown(2) then priest_holy_cleanse()

   -- main heal spell --
   elseif cd("Heal")==0 and IsUsableSpell("Heal") and jps.can_cast("Heal", Priest_Target) and health_deficiency > (getaverage_heal("Heal") + getaverage_heal("Renew")) then
     priest_spell = "Heal"
     jps.Target = Priest_Target
   end

  return priest_spell

end

function priest_holy_cleanse(self)

   local debufftimeleft = 0;
   local debufftype= nil;
   local debufftarget = nil;
   local numberofmagicaffectedunits = 0
   local priest_spell = nil;

-- identify if group is a party or raid. This has NOT been tested at all in a raid modus, only 5-man's normal atm--

    local group_type;
    group_type="raid";
    nps=1;
    npe=GetNumRaidMembers();
    if npe==0 then
    group_type="party"
    nps=0;
    npe=GetNumPartyMembers();
    end;

	for i=nps,npe do
   		if i==0 then
        tt="player"
        else
        tt=group_type..i
    	end;

   -- identifies the partymember who has the longest running disease or magic running --

        if UnitExists(tt) and UnitInRange(tt) and UnitIsDeadOrGhost(tt)~=1 then
      		unit_has_magic = false;
         	for j=1,40 do
            	d={UnitDebuff(tt,j)};
            	if d~=nil and (d[5]=="Magic" or d[5]=="Disease") then
               		if unit_has_magic == false and d[5] == "Magic" then
                  		numberofmagicaffectedunits = numberofmagicaffectedunits+1;
                  		unit_has_magic = true;
               		end;
               		if d[7]>debufftimeleft then
                  		debufftype = d[5];
                  		debufftarget=tt;
                  		debufftimeleft = d[7] ;
               		end;
            	end
         	end

        end
    end


   if debufftype == "Magic" and debufftype ~= nil then
       	priest_spell = "Dispel Magic"
       	jps.Target = debufftarget;

   elseif debufftype == "Disease" and debufftype ~= nil then
      	priest_spell = "Cure Disease"
    	jps.Target = debufftarget;
   end
return priest_spell
end
