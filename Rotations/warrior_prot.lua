
jps.registerRotation("WARRIOR","PROTECTION",function()
	-- Gocargo

	local spellTable =
	{
		{ "Battle Shout" ,		jps.hasAttackPowerBuff("player") , "player" },


		-- deff
		{ "Berserker Rage" ,	not jps.buff("Berserker Rage","player") , "player" },
		{ "Shield Wall" ,			jps.hp() < 0.30 and jps.UseCDs, "player" },
		{ "Last Stand" ,			jps.hp() < 0.40 and jps.UseCDs, "player" },
		{ "Impending Victory" ,jps.hp() < 0.70 and jps.UseCDs, "player" },
		{ "Lifeblood" ,			jps.hp() < 0.70 and jps.UseCDs, "player" },
		{ "Shield Block" ,			jps.hp() < 0.80 , "player" },
		{ "Shield Barrier" ,		jps.hp() < 0.80 , "player" },
		{ "Enraged Regeneration" ,	(jps.buff("Berserker Rage","player") or jps.buff("enraged","player")) and jps.hp() < 0.80 , "player" },

		-- interrupts
		{ "Pummel" ,				jps.shouldKick("target") , "target" },
		{ "Pummel" ,				jps.shouldKick("focus") , "focus" },
		{ "Spell Reflection" ,	UnitThreatSituation("player","target") == 3 and (UnitCastingInfo("target") or UnitChannelInfo("target")) , "target" },
		{ "Shield Slam" ,		jps.buff("Sword and Board") , "target" },

		-- multitarget
		{ "Thunder Clap" ,		jps.MultiTarget , "target" },
		{ "Recklessness" ,		jps.UseCDs , "player" },
		{ "Cleave" ,				jps.rage() > 70 and jps.MultiTarget , "target" },
		{ "Heroic Strike" ,		jps.rage() > 70  and jps.buff("player", "Ultimatum") and jps.MultiTarget , "target" },

		-- singletarget
		{ "Devastate" ,			not jps.debuff("Sunder Armor","target") , "target" },
		{ "Shield Slam" ,		},
		{ "Revenge" ,				},
		{ "Heroic Strike" ,		jps.buff("player", "Ultimatum") and not jps.MultiTarget , "target" },
		{ "Devastate" ,			jps.debuffStacks("Sunder Armor") < 3 , "target" },
		{ "Thunder Clap" ,		IsSpellInRange("Thunder Clap","target") == 1 and not jps.debuff("Weakend Blows", "target") },
		{ "Heroic Throw" ,		},
		{ "Battle Shout",			jps.rage() < 100, "player" },
		{ "Heroic Strike" ,		jps.rage()>90  and not jps.MultiTarget, "target" },
		{ "Impending Victory" ,	jps.hp() < 0.85 , "target" },
		{ "Devastate" ,			}
	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default")