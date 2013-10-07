--[[[
@rotation Default
@class SHAMAN
@spec ELEMENTAL
@talents W!22020.
@author duplicate
@description 
Updated for MoP
]]--

function weaponMainhandEnchant()
	return select(1, GetWeaponEnchantInfo())
end

function totemActive(totemId)
	-- 1 = fire
	-- 2 = earth
	-- 3 = water
	-- 4 = air
	local _, totemName, _, _, _ = GetTotemInfo(totemId)
	return totemName ~= ""
end

jps.registerStaticTable("SHAMAN","ELEMENTAL",
	{
		{ "Wind Shear", 'jps.shouldKick("target")',"target"},
		{ "Wind Shear", 'jps.shouldKick("focus")',"focus"},
		{ "Lightning Shield",'not jps.buff("Lightning Shield")' },
		{ "Flametongue Weapon", 'not weaponMainhandEnchant()', "player"  },
		{ "Astral Shift", 'jps.hp() < 0.35 '},
		{ "Healing Tide Totem",' jps.hp() < 0.5 and jps.UseCDs'},
		{ "Healing Surge", 'jps.hp() < 0.70' },
		{ "Fire Elemental Totem", 'jps.UseCDs '},
		{ "Searing Totem", 'not totemActive(1)' },
		{ "Earth Elemental Totem", 'jps.UseCDs and jps.bloodlusting()' },
		{ "Stormlash Totem",' jps.UseCDs and jps.bloodlusting()' },
		
		{ jps.getDPSRacial(),'jps.UseCDs '},
		{ jps.useTrinket(0),'jps.useTrinket(0) ~= "" and jps.UseCDs '},
		{ jps.useTrinket(1),'jps.useTrinket(1) ~= "" and jps.UseCDs '},
		{ jps.useSynapseSprings,'jps.useSynapseSprings() ~= "" and jps.UseCDs '},
		-- Requires herbalism
		{"Lifeblood",'jps.UseCDs '},
		-- Prio-List
		{ "Unleash Elements",' jps.myDebuffDuration("Flame Shock") < 2'},
		{ "Flame Shock",' jps.buff("Unleash Flame")' },
		{ "Lava Burst", 'jps.mydebuff("Flame Shock")' },
		{ "Earth Shock", 'jps.buffStacks("lightning shield") > 5 and jps.myDebuffDuration("Flame Shock") > 5 '},
		{ "Spiritwalker's Grace", 'jps.Moving' },
		{ "Chain Lightning", 'jps.MultiTarget' },
		{ "Thunderstorm", 'jps.mana() < 0.6 and jps.UseCDs' },
		{ "Lightning Bolt",'onCD' },
	}
,"Elemental Shaman PVE")