function paladin_ret_pve(self)

	local holyPower = jps.holyPower()
	local stance = GetShapeshiftForm() -- stance
	
	local spellTable = {}
	spellTable[1] = {
		["ToolTip"] = "Retribution Paladin PVE",

		-- Paladin stance ( Seal)
		{ "Seal of Truth", stance ~= 1 and stance ~=  2 , player },  --allows to switch between seal of truth or seal of Righteousness
		
		-- Might
		{ "Blessing of Might", not jps.buff("Blessing of Might") }, 
	
		-- Oh shit button
		{ "Lay on Hands", jps.UseCDs and jps.hp() < .2 and jps.Defensive }, 
	
		-- Bubble
		{ "Divine Shield", jps.UseCDs and jps.hp() < .2 and jps.Defensive }, 
	
		-- Big Heal
		{ "Flash of Light", jps.hp() < .75 and jps.buff("The Art of War") }, 
	
		-- Heal
		{ "Sacred Shield", jps.hp() < .7 and not jps.buff("Sacred Shield") }, 
	
		-- Guardian of Ancient Kings
		{ "Guardian of Ancient Kings", jps.UseCDs }, 
	
		-- Avenging Wrath
		{ "Avenging Wrath", jps.UseCDs }, 
	
		-- Holy Avenger
		{ "Holy Avenger", jps.UseCDs and jps.hp() < .7 and jps.Defensive}, 	
		-- Heal
		{ "Word of Glory", jps.hp() < .6 and jps.Defensive }, 
	
		-- Interrupts
		{ "Rebuke",  jps.shouldKick() },
		{ "Rebuke", jps.shouldKick("focus"), "focus" }, 
		
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
		{ "Divine Storm", jps.MultiTarget and holyPower > 2 },  -- AOE
		{ "Templar's Verdict", holyPower == 5 },   -- Single Target
	
		-- Execute
		{ "Hammer of Wrath", jps.buff("Avenging Wrath") or jps.hp("target") <= .2 }, 
	
		-- Exorcism proc
		{ "Exorcism", jps.buff("The Art of War") }, 
	
		-- Damage
		{ "Judgment" }, 
	
		-- Damage
		{ "Hammer of the Righteous", jps.MultiTarget },
		{ "Crusader Strike" },
		 -- Damage
		{ "Exorcism" },
	}
	
	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)
	return spell,target
end
