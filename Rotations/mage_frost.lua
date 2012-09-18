--psycho + stolen code ;-)

function mage_frost(self)
--pcmd
	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local spellTable =
	{
	--interrupt
		{ "Counterspell",     jps.Interrupts and jps.shouldKick("target"), "target" },
		{ "Ice Barrier",      (UnitHealth("player") / UnitHealthMax("player") < 0.40)  and not jps.buff("Ice Barrier","player"), "player" },
		
		--buffs
		{ "Molten Armor",     not jps.buff("Molten Armor","player"), "player" },
		{ "Arcane Brilliance",     not jps.buff("Arcane Brilliance","player"), "player" },
		
		--CDs
		{ "Mirror Image",     jps.UseCDs },
		{jps.useTrinket(1),     jps.UseCDs},
		{jps.useTrinket(2),     jps.UseCDs},
		
		--aoe
		{ "Flamestrike",      jps.MultiTarget and IsShiftKeyDown() ~= nil },
		
		--rotation
		{ "frostfire bolt", jps.buff("brain freeze") },
		{ "ice lance", jps.buffStacks("fingers of frost") > 1 },
		{ "frostbolt" },
		{ "ice lance", jps.Moving },
	}

 local spell,target = parseSpellTable(spellTable)
   if spell == "Flamestrike" then
       jps.Cast( spell )
       jps.groundClick()
   end

   jps.Target = target
   return spell
end
