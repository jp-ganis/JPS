function warlock_demo(self)
	local mana = UnitMana("player")/UnitManaMax("player")
	local shards = UnitPower("player",7)
  	local spell = nil

	local bod_duration = jps.debuffDuration("bane of doom")
	local cpn_duration = jps.debuffDuration("corruption")
	local imo_duration = jps.debuffDuration("immolate")

	if not ud("target","curse of the elements") then
		spell = "curse of the elements"
	elseif cd("soulburn") == 0 and shards > 1 then
		spell = "soulburn"
	elseif cd("lifeblood") == 0 then
		spell = "lifeblood"
	elseif cd("metamorphosis") == 0 and jps.UseCDs then
		spell = "metamorphosis"
	elseif cpn_duration < 2 then
		spell = "corruption" 
	elseif ub("player","decimation") or ub("player","soulburn") then
		spell = "soul fire"
	elseif bod_duration < 2 then
		spell = "bane of doom"
	elseif GetUnitSpeed("player") > 0 then
		spell = "fel flame"
	elseif imo_duration < 2 and jps.LastCast ~= "immolate" then
		spell = "immolate"
	elseif cd("hand of gul'dan") == 0 then
		spell = "hand of gul'dan"
	elseif mana < 0.3 then
	  	spell = "life tap"
	elseif ub("player","molten core") then
	  	spell = "incinerate"
	else
	  	spell = "incinerate"
	end

	return spell
	
end	
