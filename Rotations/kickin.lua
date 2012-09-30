function kickin(self)
	if not jps.shouldKick() then return nil
	else
		local spellTable =
		{
			--Paladin
			{ "rebuke" },
			--Hunter
			{ "silencing shot" },
			--Rogue
			{ "kick" },
			--Mage
			{ "counterspell" },
			--Shaman
			{ "wind shear" },
			--Druid
			{ "skull bash(cat form)" },
			{ "skull bash(bear form)" },
			{ "solar beam" },
			--DK
			{ "mind freeze" },
			{ "strangulate" },
			--Warrior
			{ "pummel" },
			--Priest
			{ "silence" },
			--Warlock
			{ {"macro","/cast spell lock"}, jps.petCooldown("5")==0 }, -- need to find which pet action it actually isfreeze
		}
	end
end
