--jpganis + SIMCRAFT
function mage_arcane(self)
	local max_mana_unbuffed = 80974
	local stacks = jps.debuffStacks("arcane blast","player")
	local dpsPhase = jps.buff("improved mana gem") and dpmPhase
	local dpmPhase = jps.cd("evocation") <= 20 and dpsPhase and jps.mana() < 0.22
	local manaGemCharges = GetItemCount("mana gem",0,1)
	local burnThisShitUp = jps.cd("evocation")<=20 or jps.buff("improved mana gem") or jps.itemCooldown(36799)<5
	burnThisShitUp = burnThisShitUp and jps.mana() >= 0.22
	
	local spellTable =
	{
		{ "evocation", (UnitManaMax("player") > max_mana_unbuffed and jps.mana() <= 0.4) or jps.mana() <= 0.35 },
		{ "flame orb" },
		{{ "macro","/cast mana gem" }, stacks > 3 and jps.itemCooldown(36799)==0 and manaGemCharges > 0},
		{ "arcane power", jps.buff("improved mana gem") },
		{ "mirror image", jps.buff("arcane power") },
		{ "presence of mind" },
		{ "conjure mana gem", jps.buff("presence of mind") and manaGemCharges==0 },
		{ "conjure mana gem", manaGemCharges==0 },
		{ "arcane blast", dpsPhase or burnThisShitUp },
		{ "arcane blast", jps.debuffDuration("arcane blast","player")<0.8 and stacks==4 },
		{ "arcane missiles", jps.mana() < 0.92 and jps.buff("arcane missiles!") },
		{ "arcane barrage", jps.mana() < 0.87 and stacks==2 },
		{ "arcane barrage", jps.mana() < 0.9 and stacks==3 },
		{ "arcane barrage", jps.mana() < 0.92 and stacks==4 },
		{ "arcane blast" },
		{ "arcane barrage" },
		{ "fire blast" },
		{ "ice lance" },
	}

	return parseSpellTable(spellTable)
end
