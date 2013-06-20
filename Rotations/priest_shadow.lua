function priest_shadow()
	local swpDuration = jps.debuffDuration("shadow word: pain")
	local plagueDuration = jps.debuffDuration("devouring plague")
	local vtDuration = jps.debuffDuration("vampiric touch")
	local sorbs = UnitPower("player",13)
	local spell1,_,_,_,_,end1,_,_,_ = UnitCastingInfo("player")
	if endtimevt == nil then endtimevt = 0 end
	if spell1 == "Vampiric Touch" then endtimevt = (end1/1000) end
	
	local spellTable = {
		{ "shadowform", not jps.buff("shadowform") },
		{ "Dispersion", IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.UseCDs },
		{ "inner fire", not jps.buff("inner fire") },
		{ "Power Word: Shield", jps.Moving or jps.hp() < 0.5 },
		{ "Arcane Torrent", jps.mana() < .9 },
		{ "Power Infusion", jps.UseCDs },
		{ "mind spike", jps.buff("surge of darkness") },
		{ "mind blast", jps.buff("divine insight") },
		{ "renew", 	jps.hp("player") <= 0.20, 	"player" },
		{ "shadowfiend", 	jps.cooldown("shadowfiend") == 0 and jps.UseCDs },
		{ "devouring plague", 	sorbs > 2 },
		{ "mind blast", jps.cooldown("mind blast") == 0 and sorbs < 3 },
		{ "shadow word: death", 	jps.hp("target") < 0.2 },
		{ {"macro","/cast mind flay"}, jps.cooldown("mind flay") == 0 and not jps.Casting and jps.debuff("devouring plague","target")},
		{ "shadow word: pain", 	not jps.debuff("shadow word: pain") or swpDuration < 3 },
		{ "vampiric touch", 	endtimevt+2 < GetTime() and (not jps.debuff("vampiric touch") or vtDuration < 4) },
		{ "Halo", 	jps.MultiTarget or IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ {"macro","/cast mind flay"}, jps.cooldown("mind flay") == 0 and not jps.Casting }
	}

	return parseSpellTable(spellTable)
end