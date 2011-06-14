function warlock_destro(self)
	local mana = UnitMana("player")/UnitManaMax("player");
	local shards = UnitPower("player",7);
	local spell = nil;

	local isf_duration = jps.buff_duration("player","improved soul fire");
	local bod_duration = jps.debuff_duration("target","bane of doom");
	local cpn_duration = jps.debuff_duration("target","corruption");
	local isb_duration = jps.debuff_duration("target","shadow and flame");
	local imo_duration = jps.debuff_duration("target","immolate");

	if cd("demon soul") == 0 then 
		spell = "demon soul";
	elseif cd("lifeblood") == 0 then
		spell = "lifeblood";
	elseif not ud("target","curse of the elements") then
		spell = "curse of the elements";
	elseif cd("soulburn") == 0 and shards > 0 then
		spell = "soulburn";
	elseif ub("player","soulburn") or ub("player","empowered imp") then
		spell = "soul fire";
	elseif bod_duration < 2 and not jps.Havoc then
		spell = "bane of doom";
	elseif cpn_duration < 2 then
		spell = "corruption";
	elseif GetUnitSpeed("player") > 0 then
		spell = "fel flame";
	elseif isf_duration < 3 and jps.LastCast ~= "soul fire" then
		spell = "soul fire";
	elseif not ud("target","shadow and flame") and jps.LastCast ~= "shadow bolt" then
		spell = "shadow bolt";
	elseif IsSpellInRange("shadowflame","target") == 1 and cd("shadowflame") == 0 then
		spell = "shadowflame";
	elseif imo_duration < 2 and jps.LastCast ~= "immolate" then
		spell = "immolate";
	elseif cd("conflagrate") == 0 and ud("target","immolate") then
		spell = "conflagrate";
	elseif cd("chaos bolt") == 0 then
		spell = "chaos bolt";
	elseif mana < 0.3 then
		spell = "life tap";
	else
		spell = "incinerate";
	end

	return spell;

end		

