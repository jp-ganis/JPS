--[[[
@rotation Default
@class HUNTER
@spec MARKSMANSHIP
@author Chiffon, Scribe, jpganis
@description 
SimCraft
]]--

jps.registerRotation("HUNTER","MARKSMANSHIP", function()
	------------------------------------------
	local up = UnitPower
	local r = jps.Macro;
	local spell = nil
	local focus = UnitPower("player")

	-- Interupting, Borrowed directly from feral cat
	if jps.Interrupts and jps.shouldKick("target") and cd("Silencing Shot") == 0 then
		return "Silencing Shot"

	-- Misdirecting to pet if not in a party
	elseif GetNumSubgroupMembers() == 0 and jps.Opening and not UnitIsDead("pet") then
		jps.Target = "pet"
		spell = "Misdirection"
		jps.Opening = false	
		
	-- Misdirecting to focus if set
	elseif jps.Opening and UnitExists("focus") and cd("Misdirection") then
		print("Misdirecting to",GetUnitName("focus", showServerName)..".")
		jps.Target = "focus"
		spell = "Misdirection"
		jps.Opening = false
		
	-- Main rotation (Shift to launch trap in Multi Mob situations)
	elseif UnitThreatSituation("player") == 3 and cd("Feign Death") == 0 and jps.checkTimer("feign") and GetNumSubgroupMembers() > 0 then
		print("Aggro! Feign Death cast.")
		jps.createTimer("feign", "2")
		spell = "Feign Death"
	elseif jps.checkTimer("feign") > 0 then
		spell = nil
	elseif jps.buff("Feign Death") and jps.checkTimer("feign") == 0 then
		CancelUnitBuff("player", "Feign Death")
		spell = nil
	elseif UnitIsDead("pet") then
		spell = "Revive Pet"
	
	--SIMCRAFT
	else
		local spellTable = 
		{
			{ "aspect of the iron hawk", 
				not jps.Moving
				and not jps.buff("aspect of the iron hawk") },

			{ "aspect of the fox",
				jps.Moving
				and not jps.buff("aspect of the fox") },

			{ "explosive trap",
				jps.MultiTarget },

			-- Lifeblood. (requires herbalism)
			{ "Lifeblood",
				jps.UseCDs
				and jps.hp() < .7 },

			{ "glaive toss" },

			{ "powershot" },

			{ "barrage" },

			{ "blink strike" },

			{ "lynx rush" },

			{ "multi-shot",
				jps.MultiTarget },

			{ "steady shot",
				jps.MultiTarget },

			{ "serpent sting",
				not jps.debuff("Serpent Sting") 
				and jps.hp("target") <= 0.9 },

			{ "chimera shot",
				jps.hp("target") <= 0.9 },

			{ "dire beast" },

			{ "rapid fire",
				not jps.buff("rapid fire") },

			{ "stampede" },

			{ "readiness",
				jps.buff("rapid fire") },

			{ "kill shot" },

			{ "aimed shot",
				jps.buff("Fire!") },

			{ "a murder of crows",
				not jps.debuff("a murder of crows") },

			{ "arcane shot",
				jps.buff("thrill of the hunt") },

			{ "aimed shot",
				jps.hp("target") > 0.9 
				or jps.buff("rapid fire") 
				or jps.bloodlusting() },

			{ "arcane shot",
				( focus >= 66 
					or jps.cooldown("chimera shot") >= 5) 
				and (jps.hp("target") < 90 
					and not jps.buff("rapid fire") 
					and not jps.bloodlusting() ) },

			{ "fervor",
				focus <= 50 },

			{ "steady shot" },
		}

		return parseSpellTable(spellTable)
	end
	
	return spell
end, "Default")
