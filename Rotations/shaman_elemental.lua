--[[[
@rotation Default
@class SHAMAN
@spec ELEMENTAL
@talents W!22020. & PCMD
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

local deactivateGhostWolfNotMovingSeconds = 0
function deactivateGhostWolfNotMoving(seconds)
	if not seconds then seconds = 0 end
	if jps.Moving or not jps.buff("Ghost Wolf") then
		deactivateGhostWolfNotMovingSeconds = 0
	else
		if deactivateGhostWolfNotMovingSeconds >= seconds then
			RunMacroText("/cancelaura Ghost Wolf")
		else
			deactivateGhostWolfNotMovingSeconds = deactivateGhostWolfNotMovingSeconds + jps.UpdateInterval
		end
	end
end

-- what is missning: purge, more keybinds
spellTable = {
	{ "Wind Shear", 'jps.shouldKick("target")',"target"},
	{ "Wind Shear", 'jps.shouldKick("focus")',"focus"},
	{ "Hex", 'keyPressed("shift","alt") and jps.canDPS("mouseover")' , 'mouseover' },
	
	{ "Lightning Shield",'not jps.buff("Lightning Shield")' },
	{ "Flametongue Weapon", 'not weaponMainhandEnchant()', "player"  },
	{ "Astral Shift", 'jps.hp() < 0.35 '},
	{ "Ascendance", 'jps.myDebuffDuration("Flame Shock") >= 15 and jps.UseCDs'},
	{ "Elemental Mastery", 'jps.UseCDs'},
	{ "Ancestral Swiftness", 'jps.UseCDs and not jps.MultiTarget' },
	{ "Healing Tide Totem",' jps.hp() < 0.5 and jps.UseCDs'},
	{ "Healing Surge", 'jps.hp() < 0.70 and jps.Defensive' },
	{ "Magma Totem", 'jps.UseCDs and jps.MultiTarget and not totemActive(1)'},
	{ "Fire Elemental Totem", 'jps.UseCDs and not totemActive(1)'},
	{ "Searing Totem", 'not totemActive(1)' },
	{ "Earth Elemental Totem", 'jps.UseCDs and jps.bloodlusting()' },
	{ "Stormlash Totem",' jps.UseCDs and jps.bloodlusting()' },

	{ jps.getDPSRacial(),'jps.UseCDs '},
	{ jps.useTrinket(0),'jps.useTrinket(0) ~= "" and jps.UseCDs '},
	{ jps.useTrinket(1),'jps.useTrinket(1) ~= "" and jps.UseCDs '},
	{ jps.useSynapseSprings() ,'jps.useSynapseSprings() ~= "" and jps.UseCDs '},
	-- Requires herbalism
	{"Lifeblood",'jps.UseCDs '},
	-- Prio-List
	{ "Unleash Elements",' jps.myDebuffDuration("Flame Shock") < 2'},
	{ "Flame Shock",' jps.buff("Unleash Flame") or not jps.myDebuff("Flame Shock")' },
	{ "Lava Burst", 'jps.myDebuff("Flame Shock") and not jps.MultiTarget' },
	{ "Earth Shock", 'jps.buffStacks("lightning shield") > 5 and jps.myDebuffDuration("Flame Shock") > 5 '},
	{ "Spiritwalker's Grace", 'jps.Moving' },
	{ "Chain Lightning", 'jps.MultiTarget' },
	{ "Lava Beam", 'jps.MultiTarget' }, --ascendance , maybe this works

	{ "Thunderstorm", 'jps.mana() < 0.6 and jps.UseCDs' }, --need we check for the glyph?
	{ "Lightning Bolt",'onCD' },
}

jps.registerRotation("SHAMAN","ELEMENTAL",function()
	deactivateGhostWolfNotMoving(0.5)

	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	return parseStaticSpellTable(spellTable)
end,"Elemental Shaman PVE")

