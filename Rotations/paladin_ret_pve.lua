function paladin_ret_pve(self)

	local holyPower = UnitPower("player", "9")
	
	local spellTable = {  
		
		-- Might
		{ "Blessing of Might", not jps.buff("Blessing of Might") }, 
	
		-- Oh shit button
		{ "Lay on Hands", jps.UseCDs and jps.hp() < .2 }, 
	
		-- Bubble
		{ "Divine Shield", jps.UseCDs and jps.hp() < .2 }, 
	
		-- Big Heal
		{ "Flash of Light", jps.hp() < .75 and jps.buff("The Art of War") }, 
	
		-- Heal
		{ "Sacred Shield", jps.hp() < .7 and not jps.buff("Sacred Shield") }, 
	
		-- Guardian of Ancient Kings
		{ "Guardian of Ancient Kings", jps.UseCDs }, 
	
		-- Avenging Wrath
		{ "Avenging Wrath", jps.UseCDs and jps.hp() < .8 }, 
	
		-- Holy Avenger
		{ "Holy Avenger", jps.UseCDs and jps.hp() < .7 }, 	
		-- Heal
		{ "Word of Glory", jps.hp() < .7 }, 
	
		-- Interrupts
		{ "Rebuke", jps.Interrupts  and jps.shouldKick() }, 
	
		-- Trinket CDs.
		{ jps.useTrinket(0), jps.UseCDs }, 
		{ jps.useTrinket(1), jps.UseCDs }, 
	
		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), jps.UseCDs }, 
	
		-- Lifeblood CD. (herbalists)
		{ "Lifeblood", jps.UseCDs }, 
	
		-- DPS Racial CD.
		{ jps.DPSRacial, jps.UseCDs }, 
	
		-- Buff
		{ "Inquisition", jps.buffDuration("Inquisition") < 5  and (holyPower > 2 or jps.buff("Divine Purpose")) }, 
		
		-- Damage
		{ "Templar's Verdict", holyPower == 5 }, 
	
		-- Execute
		{ "Hammer of Wrath", jps.buff("Avenging Wrath") 
		or jps.hp("target") <= .2 }, 
	
		-- Exorcism proc
		{ "Exorcism", jps.buff("The Art of War") }, 
	
		-- Damage
		{ "Judgment" }, 
	
		-- Damage
		{ "Crusader Strike" },
		 -- Damage
		{ "Exorcism" },
	}
	
	local spell, target = parseSpellTable(spellTable)
	return spell, target
end
