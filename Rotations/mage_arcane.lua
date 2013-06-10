--jpganis + SIMCRAFT
function mage_arcane()
	local spell = nil
	local target = nil	

	local player = jpsName
	local mana = UnitPower(player,0)/UnitPowerMax(player,0)
	local stacks = jps.debuffStacks("arcane charge","player")
	local mStacks = jps.buffStacks("arcane missiles!")
	local alterTimeActive = jps.buff("alter time")
	
	local spellTable = {}
	
	spellTable[1] = {
		["ToolTip"] = "Arcane PVE SingleTarget 5.3",
		
		{ "arcane brilliance",				 not jps.buff("arcane brilliance") }, 
		
		{ "mage armor",				 not jps.buff("frost mage") }, 
		{ "ice barrier",				 not jps.buff("ice barrier") }, 
		
		{ "Ice Block",				 ((UnitHealth("player") / UnitHealthMax("player")) < 0.20 ) and not jps.buff("Ice Block","player") },
		
		{ "rune of power",				 jps.buffDuration("rune of power") < jps.CastTimeLeft() and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ "mirror image",				 jps.UseCDs },
		{ "Counterspell",				 jps.Interrupts and jps.shouldKick("target") },
		
		{ "rune of power",				 (not jps.buff("rune of power") or jps.buffDuration("rune of power")) and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ "rune of power",				 jps.cooldown("arcane power")==0 and jps.buffDuration("rune of power") < jps.buffDuration("arcane power") and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ "mirror image",				 jps.UseCDs },
		{ {"macro",				"/use Mana Gem"}, mana < 0.8 and GetItemCount("Mana Gem", 0, 1) > 0 and not alterTimeActive, player }, 
		
		{ "arcane power",				(jps.buffDuration("rune of power") >=jps.buffDuration("arcane power") and mStacks ==2 and stacks >2) or jps.TimeToDie("target") <jps.buffDuration("arcane power")+5 and not jps.Moving },
		
		{ jps.DPSRacial, jps.UseCDs and not alterTimeActive and ( jps.buff("arcane power") or jps.TimeToDie("target") < 15) },
		-- On-use Trinkets.
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		-- Requires herbalism
		{ "Lifeblood",						jps.UseCDs},

		{ "alter time",				 not alterTimeActive and jps.buff("arcane power") and jps.UseCDs},
		
		{ "arcane barrage",				 alterTimeActive and jps.buffDuration("alter time") <2 },
		{ "arcane missiles",				 alterTimeActive and mStacks >= 2 },
		{ "arcane blast",				 alterTimeActive },
		{ "arcane missiles",				 mStacks == 2 and jps.cooldown("arcane power") >0 and stacks ==4 },
		{ "Nether Tempest" , not jps.debuff("Nether Tempest")},
		{ "living bomb",				 not jps.debuff("Living Bomb") and jps.TimeToDie("target") > 11 },
		{ "arcane barrage",				 stacks == 4 and mana < .95 },
		{ "presence of mind" , jps.UseCds },
		{ "arcane blast" },
		{ "arcane barrage",				 jps.Moving },
		{ "fire blast ",				 jps.Moving },
		{ "ice lance ",				 jps.Moving },
	}
	
	-- only short cd's 
	spellTable[2] = {
		["ToolTip"] = "Arcane PVE > 4 Targets 5.3",

		{ "arcane brilliance",				 not jps.buff("arcane brilliance") }, 
		
		{ "mage armor",				 not jps.buff("mage armor") }, 
		{ "ice barrier",				 not jps.buff("ice barrier") }, 
		
		{ "Ice Block",				 ((UnitHealth("player") / UnitHealthMax("player")) < 0.20 ) and not jps.buff("Ice Block","player") },
		
		{ "rune of power",				 (not jps.buff("rune of power") or jps.buffDuration("rune of power") < jps.CastTimeLeft()) and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ "Counterspell",				 jps.Interrupts and jps.shouldKick("target") },


		{ {"macro",				"/use Mana Gem"}, mana < 0.8 and GetItemCount("Mana Gem",0, 1) > 0 and not alterTimeActive, player }, 
		
		{ "arcane power",				(jps.buffDuration("rune of power") >=jps.buffDuration("arcane power") and mStacks ==2 and stacks >2) or jps.TimeToDie("target") <jps.buffDuration("arcane power")+5 and not jps.Moving },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		-- Requires herbalism
		
		{ "arcane missiles",				mStacks == 2 },
		{ "Nether Tempest" , not jps.debuff("Nether Tempest")},
		{ "living bomb",				 not jps.debuff("Living Bomb") and jps.TimeToDie("target") > 11 },
		{ "arcane barrage",				 },
		{ "arcane Explosion",				 },
		{ "fire blast ",				 jps.Moving },
		{ "ice lance ",				 jps.Moving },
	}
		
	
	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)
	return spell,target
end
