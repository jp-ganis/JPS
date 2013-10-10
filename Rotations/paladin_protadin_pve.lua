--[[[
@rotation Protection PVE 5.3 - Default
@class Paladin
@spec Protection
@author unknown
@description
This is a PVE Rotation. It uses most off your cooldowns to migitate incoming damage. It interrupts your target&focus. Seal of Insight is auomatic used for a survivability boost.
<br><br>
Talents:<br>

-- Tier 1: Pursuit of Justice for permament speed increase(up to 30%) or Speed of Light for 70% speed increase every 45 sec.
-- Tier 2: Fist of Justice
-- Tier 3: Sacred Shield
-- Tier 4: Unbreakable Spirit
-- Tier 5: Holy Avenger
-- Tier 6: Depending on the encounter, Use Execution Sentence for Survivability & threat, Holy Prism & Lights Hammer for Healing. Lights Hammer for AOE fights.
-- Major Glyphs: Glyph of Alabaster Shield other Glyphs are optional


[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Light's Hammer @ mouse position[br]

]]--
jps.registerRotation("PALADIN","PROTECTION",function()
	local spell = nil
	local target = nil
	local holyPower = jps.holyPower()
	local stance = GetShapeshiftForm()
	--Paladin (only when arg1 is nil)
	--1 = Seal of Truth
	--2 = Seal of Righteousness
	--3 = Seal of Insight - Seal of Justice if retribution
	--4 = Seal of Insight if retribution

	local spellTable = {
		-- Seal
		{ "Seal of Insight", stance ~= 3 , player },

		-- Interrupt
		{ "Rebuke", jps.shouldKick() },
		{ "Rebuke", jps.shouldKick("focus"), "focus" },

		-- Interrupt
		{ "Avenger's Shield",	jps.shouldKick() and IsSpellInRange("Avenger's Shield","target") == 0 and jps.LastCast ~= "Rebuke" },
		{ "Avenger's Shield",	jps.shouldKick("focus") and IsSpellInRange("Avenger's Shield","focus") == 0 and jps.LastCast ~= "Rebuke", "focus" },

		-- Stun
		{ "Hammer of Justice",	jps.shouldKick() },
		{ "Hammer of Justice",	jps.shouldKick("focus"), "focus" },

		-- Stun
		{ "Fist of Justice",	jps.shouldKick() },
		{ "Fist of Justice",	jps.shouldKick("focus"), "focus" },

		-- Aggro
		{ "Holy Avenger",	jps.UseCDs },

		-- Aggro
		{ "Avenging Wrath",	jps.UseCDs },

		-- Oh shit button
		{ "Lay on Hands",	jps.hp() < 0.3  and jps.UseCDs },

		-- Mitigation
		{ "Ardent Defender",	jps.hp() < 0.5  and jps.UseCDs },

		-- Mitigation
		{ "Divine Protection",	jps.hp() < 0.8  and jps.UseCDs },

		-- Heal
		{ "Word of Glory",	jps.hp() < 0.7 and holyPower > 2 },

		-- Heal
		{ "Hand of Purity",	jps.hp() < .6 and jps.UseCDs, "player" },

		-- Heal
		{ "Holy Prism",	jps.hp() < .6  and jps.UseCDs, "player" },

		-- Heal / Damage
		{ "Light's Hammer", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil  and jps.UseCDs },

		-- Buff
		{ "Righteous Fury",	not jps.buff("Righteous Fury") },

		-- Buff
		{ "Sacred Shield",	not jps.buff("Sacred shield") },

		-- Execute
		{ "Hammer of Wrath",	jps.hp("target") <= .2 },

		-- Damage
		{ "Execution Sentence", "onCD" },

		-- Damage
		{ "Avenger's Shield" , "onCD"},

		-- Damage (Multi target or missing debuff)
		{ "Hammer of the Righteous", not jps.debuff("Weakened Blows") or jps.MultiTarget },

		-- Damage
		{ "Shield of the Righteous",	holyPower > 3 },

		-- Damage (Single target)
		{ "Crusader Strike", not jps.MultiTarget },

		-- Damage
		{ "Judgment" , "onCD"},

		{ "Holy Wrath" , "onCD"},

		-- Damage
		{ "Consecration" , "onCD"},
	}


	local spell, target = parseSpellTable(spellTable)
	return spell, target
end, "Default",true,false)



--[[[
@rotation Protection PVE 5.3 Default no AOE/only Off Tank
@class Paladin
@spec Protection
@author unknown
@description
This is a PVE Rotation. It uses most off your cooldowns to migitate incoming damage. It interrupts your target&focus. Seal of Insight is auomatic used for a survivability boost. It doesn't use any AOE Spells. Avengers Shield is used with ControlKeyDown;
<br><br>
Talents:<br>

-- Tier 1: Pursuit of Justice for permament speed increase(up to 30%) or Speed of Light for 70% speed increase every 45 sec.
-- Tier 2: Fist of Justice
-- Tier 3: Sacred Shield
-- Tier 4: Unbreakable Spirit
-- Tier 5: Holy Avenger
-- Tier 6: Depending on the encounter, Use Execution Sentence for Survivability & threat, Holy Prism & Lights Hammer for Healing. Lights Hammer for AOE fights.
-- Major Glyphs: Glyph of Alabaster Shield other Glyphs are optional


[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Light's Hammer @ mouse position[br]
[*] [code]CONTROL[/code]: Avenger's Shield[br]
]]--
jps.registerRotation("PALADIN","PROTECTION",function()
	local spell = nil
	local target = nil
	local holyPower = jps.holyPower()
	local stance = GetShapeshiftForm()
	--Paladin (only when arg1 is nil)
	--1 = Seal of Truth
	--2 = Seal of Righteousness
	--3 = Seal of Insight - Seal of Justice if retribution
	--4 = Seal of Insight if retribution

	local spellTable = {
		-- Seal
		{ "Seal of Insight", stance ~= 3 , player },

		-- Interrupt
		{ "Rebuke", jps.shouldKick() },
		{ "Rebuke", jps.shouldKick("focus"), "focus" },

		-- Stun
		{ "Hammer of Justice",	jps.shouldKick() },
		{ "Hammer of Justice",	jps.shouldKick("focus"), "focus" },

		-- Stun
		{ "Fist of Justice",	jps.shouldKick() },
		{ "Fist of Justice",	jps.shouldKick("focus"), "focus" },

		-- Aggro
		{ "Holy Avenger",	jps.UseCDs },

		-- Aggro
		{ "Avenging Wrath",	jps.UseCDs },

		-- Oh shit button
		{ "Lay on Hands",	jps.hp() < 0.3  and jps.UseCDs },

		-- Mitigation
		{ "Ardent Defender",	jps.hp() < 0.5  and jps.UseCDs },

		-- Mitigation
		{ "Divine Protection",	jps.hp() < 0.8  and jps.UseCDs },

		-- Heal
		{ "Word of Glory",	jps.hp() < 0.7 and holyPower > 2 },

		-- Heal
		{ "Hand of Purity",	jps.hp() < .6 and jps.UseCDs, "player" },

		-- Heal
		{ "Holy Prism",	jps.hp() < .6  and jps.UseCDs, "player" },

		-- Heal / Damage
		{ "Light's Hammer",  IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil  and jps.UseCDs },

		-- Buff
		{ "Righteous Fury",	not jps.buff("Righteous Fury") },

		-- Buff
		{ "Sacred Shield",	not jps.buff("Sacred shield") },

		-- Execute
		{ "Hammer of Wrath",	jps.hp("target") <= .2 },

		-- Damage
		{ "Execution Sentence", "onCD" },

		-- Damage
		{ "Avenger's Shield" , IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

		-- Damage
		{ "Shield of the Righteous",	holyPower > 3 },

		-- Damage (Single target)
		{ "Crusader Strike", not jps.MultiTarget },

		-- Damage
		{ "Judgment" , "onCD"},

	}

	local spell, target = parseSpellTable(spellTable)
	return spell, target
end, "Default no AOE/only Off Tank",true,false)


--[[[
@rotation Protection PVE more Control(no deff cd's)
@class Paladin
@spec Protection
@author PCMD
@description
This is a PVE Rotation. It interrupts your target&focus. Seal of Insight is auomatic used for a survivability boost.
Damage Mitigation CD's + CD's applying forbearance debuff should be used manually in this rotation. It allows you too better migitate incoming damage.<br>

<br><br>
Talents:<br>
-- Tier 1: Pursuit of Justice for permament speed increase(up to 30%) or Speed of Light for 70% speed increase every 45 sec.
-- Tier 2: Fist of Justice
-- Tier 3: Sacred Shield
-- Tier 4: Unbreakable Spirit
-- Tier 5: Holy Avenger
-- Tier 6: Depending on the encounter, Use Execution Sentence for Survivability & threat, Holy Prism & Lights Hammer for Healing. Lights Hammer for AOE fights.
-- Major Glyphs: Glyph of Alabaster Shield other Glyphs are optional


[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Light's Hammer @ mouse position[br]
]]--
jps.registerRotation("PALADIN","PROTECTION",function()

	local holyPower = jps.holyPower()
	local stance = GetShapeshiftForm()
	--Paladin (only when arg1 is nil)
	--1 = Seal of Truth
	--2 = Seal of Righteousness
	--3 = Seal of Insight - Seal of Justice if retribution
	--4 = Seal of Insight if retribution

-- damage mitigation CD's + CD's applying forbearance debuff should be used manually in this rotation
	spellTable {
		-- Seal
		{ "Seal of Insight", stance ~= 3 , player },

		-- Interrupt
		{ "Rebuke", jps.shouldKick() },
		{ "Rebuke", jps.shouldKick("focus"), "focus" },

		-- Interrupt
		{ "Avenger's Shield",	jps.shouldKick() and IsSpellInRange("Avenger's Shield","target") == 0 and jps.LastCast ~= "Rebuke" },
		{ "Avenger's Shield",	jps.shouldKick("focus") and IsSpellInRange("Avenger's Shield","focus") == 0 and jps.LastCast ~= "Rebuke", "focus" },

		-- Stun
		{ "Hammer of Justice",	jps.shouldKick() },
		{ "Hammer of Justice",	jps.shouldKick("focus"), "focus" },

		-- Stun
		{ "Fist of Justice",	jps.shouldKick() },
		{ "Fist of Justice",	jps.shouldKick("focus"), "focus" },

		-- Heal
		{ "Word of Glory",	jps.hp() < 0.7 and holyPower > 2 },

		-- Heal
		{ "Holy Prism",	jps.hp() < .6  and jps.UseCDs, "player" },

		-- Heal / Damage
		{ "Light's Hammer",  IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil  and jps.UseCDs },

		-- Buff
		{ "Righteous Fury",	not jps.buff("Righteous Fury") },

		-- Buff
		{ "Sacred Shield",	not jps.buff("Sacred shield") },

		-- Execute
		{ "Hammer of Wrath",	jps.hp("target") <= .2 },

		-- Damage
		{ "Execution Sentence", "onCD" },

		-- Damage
		{ "Avenger's Shield" , "onCD"},

		-- Damage (Multi target or missing debuff)
		{ "Hammer of the Righteous", not jps.debuff("Weakened Blows") or jps.MultiTarget },

		-- Damage
		{ "Shield of the Righteous",	holyPower > 3 },

		-- Damage (Single target)
		{ "Crusader Strike", not jps.MultiTarget },

		-- Damage
		{ "Judgment" , "onCD"},

		{ "Holy Wrath" , "onCD"},

		-- Damage
		{ "Consecration" , "onCD"},
	}

	local spell, target = parseSpellTable(spellTable)
	return spell, target
end, "PVE more Control(no deff cd's)",true,false)
