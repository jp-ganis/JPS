function mage_fire(self)
--pcmd
	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
	
	local slot1ID,_,_ = GetInventorySlotInfo("Trinket0Slot")
	local trinket1ID = GetInventoryItemID("player", slot1ID)
	local trinket1Name, _, _, _, _, _, _, _ = GetItemInfo(trinket1ID)
	local trinket1Use, _ = IsUsableItem(trinket1ID)
	
	local slot2ID,_,_ = GetInventorySlotInfo("Trinket1Slot")
	local trinket2ID = GetInventoryItemID("player", slot2ID)
	local trinket2Name, _, _, _, _, _, _, _ = GetItemInfo(trinket2ID)
	local trinket2Use, _ = IsUsableItem(trinket2ID)
	

	local spellTable = 
	{
	   --interrupt
		{ "Counterspell",     jps.Interrupts and jps.shouldKick("target"), "target" },
		{ "Ice Barrier",      (UnitHealth("player") / UnitHealthMax("player") < 0.40)  and not jps.buff("Ice Barrier","player"), "player" },
		
		--buffs
		{ "Molten Armor",     not jps.buff("Molten Armor","player"), "player" },
		{ "Arcane Brilliance",     not jps.buff("Arcane Brilliance","player"), "player" },
		
		--aoe
		{ "Dragon's Breath",  CheckInteractDistance("target", 3) == 1, "target" }, 
		{ "Flamestrike",      jps.MultiTarget },
		
		--dots & opener
		{ "Combustion",       jps.debuffDuration("Ignite") > 0 and jps.debuffDuration("Pyroblast") > 0  and jps.UseCDs, "target" },
		
		--CDs
		{ "Mirror Image",     jps.UseCDs },
		{ jps.DPSRacial,    jps.UseCDs and jps["DPS Racial"]},
		{{"macro","/use " ..trinket1Name}, GetItemCooldown(trinket1ID) == 0 and jps.UseCds and trinket1Use == 1},
		{{"macro","/use " ..trinket2Name}, GetItemCooldown(trinket2ID) == 0 and jps.UseCds and trinket2Use == 1},

		--{ "Living Bomb",    jps.debuffDuration("Living Bomb") == 0 , "target" },
		{ "Frost Bomb",       jps.debuffDuration("Frost Bomb") == 0, "target" }, --depending on your talent tree
		
		--rotation
		{ "Inferno Blast",    jps.buff("Heating Up","player"), "target" },
		{ "Pyroblast",        jps.buff("Pyroblast!","player"), "target" },
		{ "Scorch",           jps.Moving, "target" },
		{ "Fireball",         "onCD", "target" },
		
		
	}
   local spell,target = parseSpellTable(spellTable)
   if spell == "Flamestrike" then
       jps.Cast( spell )
       jps.groundClick()
   end

   jps.Target = target
   return spell
end
