--[[[
@rotation Frost Mage PvE
@class mage
@spec frost
@author SwollNMember
@description 
SimCraft 5.3
]]--

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

function ma_fr.hastTwoRunes()
local hasOne,_ = GetTotemInfo(1)
	local hasSecond,_ = GetTotemInfo(2)
	return hasOne and hasSecond
end


function ma_fr.hasPet() 
	if UnitExists("pet") == false then return false end
	return true
end

function ma_fr.kick(unit)
	return jps.shouldKick(unit) or jps.IsCastingPoly(unit)
end

--[[[
@rotation Noxxic PvE
@class mage
@spec frost
@author Kirk24788
@description 
Based on Noxxic 5.3
]]--


jps.registerStaticTable("MAGE","FROST",{
	-- Noxxic
	-- pre fight
	{ "Summon Water Elemental", 'ma_fr.hasPet() == false and not jps.Moving'},
	{ "slow fall", 'IsFalling()==1 and not jps.buff("slow fall")' },
	{ "arcane brilliance", 'not jps.buff("arcane brilliance")' }, 

	{ "ice barrier", 'not jps.buff("ice barrier")' }, 

	{ "rune of power", 'IsAltKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.IsSpellKnown("Rune of Power") and ma_fr.hastTwoRunes()'}, 

	-- Remove Snares, Roots, Loss of Control, etc.
	{ "every man for himself", 'jps.LoseControl(player,"CC")' },
	-- Kicks, Crowd Control, etc.
	{ "counterspell", 'ma_fr.kick(ma_fr.rangedTarget())' , ma_fr.rangedTarget },
	{ "Comet Storm", "jps.UseCDs"},
	{ "Prismatic Crystal","jps.UseCDs and IsShiftKeyDown() == true"},

	{ jps.useBagItem(5512), 'jps.hp("player") < 0.7' }, -- Healthstone
	-- Rotation ALL
	{ "frost bomb", 'not jps.myDebuff("frost bomb","mouseover") and not jps.Moving'},
	{ "frost bomb", 'not jps.myDebuff("frost bomb","mouseover") and not jps.Moving and jps.canDPS("mouseover")',"mouseover"},

	
	-- Rotation AoE
	{ "frozen orb", 'jps.MultiTarget' }, 
	
	-- Rotation Single
	{"nested", 'jps.canDPS("target") and not jps.Moving', {
		{ "mirror image",'jps.UseCDs'}, 
		{ "frozen orb", 'not jps.buff("fingers of frost")'}, 
		{ "icy veins", 'jps.buff("brain freeze")'}, 
		{ "icy veins", 'jps.buff("fingers of frost")'}, 
		{ "berserking", 'jps.buff("icy veins") and jps.UseCDs'}, 
	}},
	{ "frostfire bolt", 'jps.buff("brain freeze")' }, 
	{ "ice lance", 'jps.buff("fingers of frost")' }, 
	
	{ "frostfire bolt", 'jps.buff("brain freeze") and jps.cooldown("icy veins") > 2' }, 
	{ "ice lance", 'jps.buff("fingers of frost")' }, 
	{ "frostbolt" , 'not jps.Moving' }, 
	{ "ice lance", 'jps.Moving'}, 
},"6.0.2 lvl 90 PVE",true,false)
