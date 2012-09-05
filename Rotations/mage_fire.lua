function mage_fire(self)

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
	
--	local nBombe = UnitAura("target", "Living Bomb", nil, "PLAYER|HARMFUL") 
--	local nEnflam = UnitAura("target", "Ignite", nil, "PLAYER|HARMFUL") 
--	local nPyro = UnitAura("target", "Pyroblast", nil, "PLAYER|HARMFUL")

	local nBombe = false -- "Living Bomb" 44457 -- jps.debuff("Living Bomb","target")
	local nEnflam = false -- "Ignite" -- 12654 -- jps.debuff("Ignite","target")
	local nPyro = false -- "Pyroblast!" -- 92315 -- jps.debuff("Pyroblast!","target")
	local nFrost = false -- "Frostfire Bolt" 44614 -- jps.debuff("Frostfire Bolt","target")
	local nMass = false -- "Critical Mass" 22959 -- jps.debuff("Critical mass","target")

   	for i=1,40 do
    	local ID = select(11,UnitDebuff("target",i))
    	if ID  == 44457 then nBombe = true end
    	if ID  == 12654 then nEnflam = true end
    	if ID  == 92315 then nPyro = true end
    	if ID  == 44614 or ID  == 59638 then nFrost = true end
    	if ID  == 22959 then nMass = true end
   	end

	local spellTable = 
	{
		{ "inferno blast", jps.Moving },
		{ "ice lance", jps.Moving },
		{ "evocation",	not jps.buff("invocation") and not jps.buff("alter time") },
		{ "mana gem", 	jps.mana() < 0.84 and not jps.buff("alter time") },
		{ "alter time",	not jps.buff("alter time") and jps.buff("pyroblast") and jps.buffDuration("invocation") > 6 },
		{ "evocation", jps.mana() < 0.1 },
		{ "pyroblast", jps.buff("pyroblast") },
		{ "pyroblast", jps.buff("presence of mind") },
		{ "inferno blast", jps.buff("heating up") and not jps.buff("pyroblast") },
		{ "mirror image" },
		{ "presence of mind" },
		{ "nether tempest", not jps.debuff("nether tempest") },
		{ "fireball" },
	}

	return parseSpellTable(spellTable)
end
