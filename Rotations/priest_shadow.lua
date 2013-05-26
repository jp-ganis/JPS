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
  if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
  
	local swpDuration = jps.debuffDuration("Shadow Word: Pain")
	local plagueDuration = jps.debuffDuration("Devouring Plague")
	local vtDuration = jps.debuffDuration("Vampiric Touch")
	local orbs = UnitPower("player", 13)

	local possibleSpells = {
    
    -- Stay in Shadowform
		{ "Shadowform",
			not jps.buff("Shadowform") },

    -- Keep Inner Fire up
		{ "Inner Fire",
			not jps.buff("Inner Fire") },

    -- Healthstone if you get low.
    { "Healthstone",
      jps.hp() < .5
      and GetItemCount("Healthstone", 0, 1) > 0 },
    
    -- FD,CL proc
		{ "Mind Spike",
			jps.buff("Surge of Darkness") },

    -- Divine Insight proc
		{ "Mind Blast",
			jps.buff("Divine Insight") },

    -- Self heal when critical
		{ "Renew",
      not jps.buff("Renew")
			and jps.hp("player") <= .2,
			"player" },

		-- Engineers may have synapse springs on their gloves (slot 10).
    { jps.useSlot(10), 
      jps.UseCDs
      and orbs == 3 },

		-- On-use Trinkets when we have a damage buff.
    { jps.useSlot(13), 
      jps.UseCDs
      and orbs == 3 },
    { jps.useSlot(14), 
      jps.UseCDs
      and orbs == 3 },

    -- Lifeblood on cooldown. (profession based)
    { "Lifeblood",
      jps.UseCDs
      and orbs == 3 },

    -- DPS Racial on cooldown.
    { jps.DPSRacial, 
      jps.UseCDs },
    
    -- Mind Blast if we're not full on orbs.
		{ "Mind Blast", 
			jps.cooldown("Mind Blast") == 0 
      and orbs < 3
      and not jps.Moving },
		
    -- Keep SW:P up.
		{ "Shadow Word: Pain",
      jps.LastCast ~= "Shadow Word: Pain"
      and swpDuration < 2 },
		
    -- Keep VT up.
		{ "Vampiric Touch",
      jps.LastCast ~= "Vampiric Touch"
      and vtDuration < 4 },

		{ "Cascade",
			jps.MultiTarget },

    -- Plauge when we have 3 orbs
		{ "Devouring Plague",
			orbs > 2 },

    -- SW:D in burn phase
		{ "Shadow Word: Death",
			jps.hp("target") <= .25 },

    -- Pet when we need mana
		{ "Shadowfiend",
      jps.hp("target") >= .5
      and jps.mana() < .7 },

    -- Fill with flay
		{ "Mind Flay",
      not jps.Casting
      and not jps.Moving }
	}

	return parseSpellTable( possibleSpells )
end
