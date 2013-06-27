-- SEE BOTTOM FOR USER NOTES
-- by: SwollNMember WoW v5.2 compliant

ma_fr = {}
-- Enemy Tracking
function ma_fr.rangedTarget()
	local rangedTarget = "target"
	if jps.canDPS("target") then 
		return "target"
	elseif jps.canDPS("focustarget") then 
		return "focustarget"
	elseif jps.canDPS("targettarget") then 
		return "targettarget"
	else
		local enemycount,targetcount = jps.RaidEnemyCount()
		local EnemyUnit = {}
		for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end
		if jps.canDPS(EnemyUnit[1]) then 
			return EnemyUnit[1] 
		else
			return "target" 
		end
	end
end

function ma_fr.kick(unit)
	return jps.shouldKick(unit) or jps.IsCastingPoly(unit)
end

local spellTable ={}

spellTable[1] = {
	["ToolTip"] = "Frost Mage PVE",
	-- SIMCRAFT 5.3
	-- pre fight
	{ "slow fall", 'IsFalling()==1 and not jps.buff("slow fall")' },
	{ "arcane brilliance", 'not jps.buff("arcane brilliance")' }, 
	{ "frost armor", 'not jps.buff("frost armor")' }, 
	{ "ice barrier", 'not jps.buff("ice barrier")' }, 
	{ "Freeze",	'IsAltKeyDown() ~= nil' },
	{ "rune of power", 'not jps.buff("rune of power") and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'}, 
	{ "mirror image", 'jps.UseCds'}, 

	-- Remove Snares, Roots, Loss of Control, etc.
	{ "every man for himself", 'jps.LoseControl(player,"CC")' },
	-- Kicks, Crowd Control, etc.
	{ "counterspell", 'ma_fr.kick(ma_fr.rangedTarget())' , ma_fr.rangedTarget },
	
	{ {"macro","/use Mana Gem"}, 'jps.mana() < 0.70 and GetItemCount("Mana Gem", 0, 1) > 0' }, 
	{ {"macro","/cast icy veins\n/cast evocation"}, 'jps.hp() <= 0.4 and jps.cooldown("icy veins") == 0 and jps.cooldown("evocation") == 0'  },
	{ "Healthstone",		'jps.hp() < 0.7 and GetItemCount("Healthstone", 0, 1) > 0' },
	
	-- Rotation
	{ "rune of power", 'jps.buffDuration("rune of power") < jps.CastTimeLeft() and not jps.buff("alter time") and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil' }, 
	{ "rune of power", 'jps.cooldown("icy veins") == 0 and jps.buffDuration("rune of power") <20 and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'}, 
	{ "mirror image",'jps.UseCds'}, 
	{ "frozen orb", 'not jps.buff("fingers of frost")'}, 
	{ "icy veins", 'jps.debuffStacks("frostbolt") >= 3 and jps.buff("brain freeze")'}, 
	{ "icy veins", 'jps.debuffStacks("frostbolt") >= 3 and jps.buff("fingers of frost")'}, 
	{ "icy veins", 'jps.TimeToDie("target") <22 and not jps.Moving'}, 
	{ "berserking", 'jps.buff("icy veins") or jps.TimeToDie("target") < 18 and jps.UseCds'}, 
	{ "jade serpent potion", 'jps.buff("icy veins") or jps.TimeToDie("target") <45'}, 
	{ "presence of mind", 'jps.buff("icy veins") or jps.cooldown("icy veins") >15 or jps.TimeToDie("target") <15'}, 
	{ "alter time", 'not jps.buff("alter time") and jps.buff("icy veins") and jps.UseCds'}, 
	{ "frostfire bolt", 'jps.buff("alter time") and jps.buff("brain freeze")' }, 
	{ "ice lance", 'jps.buff("alter time") and jps.buff("fingers of frost")' }, 
	{ "frost bomb", 'jps.TimeToDie("target") > tonumber(jps.CastTimeLeft()) and not jps.Moving'},
	{ "frostbolt", 'jps.debuffStacks("frostbolt") < 3 and not jps.Moving' }, 
	{ "frostfire bolt", 'jps.buff("brain freeze") and jps.cooldown("icy veins") > 2' }, 
	{ "ice lance", 'jps.buff("fingers of frost")' }, 
	{ "frostbolt" , 'not jps.Moving' }, 
	{ "fire blast", 'jps.Moving'}, 
	{ "ice lance", 'jps.Moving'}, 
}
spellTable[2] = {
	["ToolTip"] = "Noxxic PVE",
	-- Noxxic
	-- pre fight
	{ "slow fall", 'IsFalling()==1 and not jps.buff("slow fall")' },
	{ "arcane brilliance", 'not jps.buff("arcane brilliance")' }, 
	{ "frost armor", 'not jps.buff("frost armor")' }, 
	{ "ice barrier", 'not jps.buff("ice barrier")' }, 
	{ "Freeze",	'IsAltKeyDown() ~= nil' },
	{ "rune of power", 'not jps.buff("rune of power") and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'}, 
	{ "mirror image", 'jps.UseCds'}, 

	-- Remove Snares, Roots, Loss of Control, etc.
	{ "every man for himself", 'jps.LoseControl(player,"CC")' },
	-- Kicks, Crowd Control, etc.
	{ "counterspell", 'ma_fr.kick(ma_fr.rangedTarget())' , ma_fr.rangedTarget },
	
	{ {"macro","/use Mana Gem"}, 'jps.mana() < 0.70 and GetItemCount("Mana Gem", 0, 1) > 0' }, 
	{ {"macro","/cast icy veins\n/cast evocation"}, 'jps.hp() <= 0.4 and jps.cooldown("icy veins") == 0 and jps.cooldown("evocation") == 0'  },
    { jps.useBagItem(5512), 'jps.hp("player") < 0.7' }, -- Healthstone
	
	-- Rotation ALL
	{ "nether tempest", 'jps.myDebuffDuration("nether tempest", "target") < 1' }, 
	
	-- Rotation AoE
	{ "freeze", 'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget' }, 
	{ "flamestrike", 'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget' }, 
	{ "frozen orb", 'jps.MultiTarget' }, 
	{ "arcane explosion", 'jps.MultiTarget' }, 
	
	-- Rotation Single
	{ "rune of power", 'jps.buffDuration("rune of power") < jps.CastTimeLeft() and not jps.buff("alter time") and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil' }, 
	{ "rune of power", 'jps.cooldown("icy veins") == 0 and jps.buffDuration("rune of power") <20 and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil'}, 
	{ "mirror image",'jps.UseCds'}, 
	{ "frozen orb", 'not jps.buff("fingers of frost")'}, 
	{ "icy veins", 'jps.debuffStacks("frostbolt") >= 3 and jps.buff("brain freeze")'}, 
	{ "icy veins", 'jps.debuffStacks("frostbolt") >= 3 and jps.buff("fingers of frost")'}, 
	{ "icy veins", 'jps.TimeToDie("target") <22 and not jps.Moving'}, 
	{ "berserking", 'jps.buff("icy veins") or jps.TimeToDie("target") < 18 and jps.UseCds'}, 
	{ "jade serpent potion", 'jps.buff("icy veins") or jps.TimeToDie("target") <45'}, 
	{ "presence of mind", 'jps.buff("icy veins") or jps.cooldown("icy veins") >15 or jps.TimeToDie("target") <15'}, 
	{ "alter time", 'not jps.buff("alter time") and jps.buff("icy veins") and jps.UseCds'}, 
	{ "frostfire bolt", 'jps.buff("alter time") and jps.buff("brain freeze")' }, 
	{ "ice lance", 'jps.buff("alter time") and jps.buff("fingers of frost")' }, 
	{ "frost bomb", 'jps.TimeToDie("target") > tonumber(jps.CastTimeLeft()) and not jps.Moving'},
	{ "frostbolt", 'jps.debuffStacks("frostbolt") < 3 and not jps.Moving' }, 
	{ "frostfire bolt", 'jps.buff("brain freeze") and jps.cooldown("icy veins") > 2' }, 
	{ "ice lance", 'jps.buff("fingers of frost")' }, 
	{ "frostbolt" , 'not jps.Moving' }, 
	{ "fire blast", 'jps.Moving'}, 
	{ "ice lance", 'jps.Moving'}, 
}




function mage_frost_pve()
	return parseStaticSpellTable(jps.RotationActive(spellTable))
end