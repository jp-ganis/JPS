function warlock_demo(self)
	local mana = UnitMana("player")/UnitManaMax("player");
	local shards = UnitPower("player",7);
   	local spell = nil;

  	local bod_duration = jps.debuff_duration("target","bane of doom");
   	local cpn_duration = jps.debuff_duration("target","corruption");
   	local imo_duration = jps.debuff_duration("target","immolate");

   	if not ud("target","curse of the elements") and UnitHealthMax("target") > 500000 and UnitHealth("target") > 350000 then
      		spell = "curse of the elements";
   	elseif cd("soulburn") == 0 and shards > 1 and UnitHealth("target") > 90000 then
      		spell = "soulburn";
   	elseif ub("player","decimation") or ub("player","soulburn") then
      		spell = "soul fire";
   	elseif UnitHealthMax("target") > 450000 and UnitHealth("target") > 400000 and not jps.Havoc and bod_duration < 2 then
      		spell = "bane of doom";
   	elseif cpn_duration < 2 then
      		spell = "corruption";
   	elseif GetUnitSpeed("player") > 0 then
      		spell = "fel flame";
   	elseif imo_duration < 2 and jps.LastCast ~= "immolate" then
      		spell = "immolate";
   	elseif cd("hand of gul'dan") == 0 then
      		spell = "hand of gul'dan";
   	elseif mana < 0.3 then
      		spell = "life tap";
   	elseif ub("player","molten core") then
      		spell = "incinerate";
   	else
      		spell = "shadow bolt";
   end

   return spell;
   
end   
