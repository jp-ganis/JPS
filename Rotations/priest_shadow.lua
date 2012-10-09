-- Shadow Priest updated for MoP

-- Make sure you are using the correct talent build/glyphs for optimal rotation
-- Tier 1: Void Tendrils
-- Tier 2: Body and Soul
-- Tier 3: From Darkness, Comes Light (required)
-- Tier 4: Angelic Bulwark
-- Tier 5: Divine Insight (required)
-- Tier 6: Cascade (required)
-- Major Glyphs: Mind Spike (required), Dark Binding (required)

-- You should have the following on your bar, which are hard/dangerous to automate:
--   Dispersion - Use when you have high damage incoming (90% reduction) or when
--                you are super low on mana (6% regen/sec)
--   Void Shift - Swaps health with targeted friendly.

function priest_shadow(self)
	local swpDuration = jps.debuffDuration("shadow word: pain")
	local plagueDuration = jps.debuffDuration("devouring plague")
	local vtDuration = jps.debuffDuration("vampiric touch")
	local sorbs = UnitPower("player",13)

	local spellTable = {
		{ "shadowform", -- Stay in Shadowform
			not jps.buff("shadowform") },

		{ "inner fire", -- Keep Inner Fire up
			not jps.buff("inner fire") },

		{ "mind spike", -- FD,CL proc
			jps.buff("surge of darkness") },

		{ "mind blast", -- Divine Insight proc
			jps.buff("divine insight") },

		{ "renew", -- Self heal when critical
			jps.hp("player") <= 0.20,
			"player" },

		{ "mind blast", -- Stack shadow orbs
			jps.cooldown("mind blast") == 0 and sorbs < 3 },
		
		{ "shadow word: pain", -- Keep SW:P up
			not jps.debuff("shadow word: pain") or swpDuration < 2 },
		
		{ "vampiric touch", -- Keep VT up
			not jps.debuff("vampiric touch") or vtDuration < 4 and jps.LastCast ~= "vampiric touch" },

		{ "Cascade",
			jps.MultiTarget },

		{ "devouring plague", -- Plauge when we have 3 orbs
			sorbs > 2 },

		{ "shadow word: death", -- SW:D in burn phase
			jps.hp("target") <= 0.25 },

		{ "shadowfiend", -- Pet on CD
			jps.cooldown("shadowfiend") == 0 },

		{ {"macro","/cast mind flay"}, -- Fill with flay
			jps.cooldown("mind flay") == 0 and not jps.Casting }
	}

	return parseSpellTable( spellTable )
end
