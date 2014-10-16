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

function ma_fr.kick(unit)
	return jps.shouldKick(unit) or jps.IsCastingPoly(unit)
end
ma_fr.invokersEnergy = select(1,GetSpellInfo(116257))
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
	{ "slow fall", 'IsFalling()==1 and not jps.buff("slow fall")' },
	{ "arcane brilliance", 'not jps.buff("arcane brilliance")' }, 
	{ "ice barrier", 'not jps.buff("ice barrier")' }, 
	{ "Freeze",	'IsAltKeyDown() == true' },
	{ "rune of power", 'not jps.buff("rune of power") and IsShiftKeyDown() == true and GetCurrentKeyBoardFocus() == nil'}, 
	{ "mirror image", 'jps.UseCDs'}, 

	-- Remove Snares, Roots, Loss of Control, etc.
	{ "every man for himself", 'jps.LoseControl(player,"CC")' },
	-- Kicks, Crowd Control, etc.
	{ "counterspell", 'ma_fr.kick(ma_fr.rangedTarget())' , ma_fr.rangedTarget },
	
	{ {"macro","/use Mana Gem"}, 'jps.mana() < 0.70 and GetItemCount("Manaa Gem", 0, 1) > 0' }, 
    { jps.useBagItem(5512), 'jps.hp("player") < 0.7' }, -- Healthstone
	
	-- Rotation ALL
	{ "nether tempest", 'jps.myDebuffDuration("nether tempest", "target") < 1' }, 
	{ "living bomb", 'jps.myDebuffDuration("living bomb","target") < 2 and not jps.Moving'},
	{ "living bomb", 'jps.myDebuffDuration("living bomb","mouseover") < 2 and not jps.Moving and jps.canDPS("mouseover")',"mouseover"},
	{ "frost bomb", 'jps.TimeToDie("target") > tonumber(jps.CastTimeLeft()) and not jps.Moving'},
	
	{ "nested", "jps.buffDuration(ma_fr.invokersEnergy) < 6 and not jps.Moving",{
		{ "Evocation", 'jps.myDebuffDuration("frost bomb","target") > 5'},
		{ "Evocation", 'jps.myDebuffDuration("living bomb","target") > 5'},
		{ "Evocation", 'jps.myDebuffDuration("nether tempest","target") > 5'},
	}},
	
	-- Rotation AoE
	{ "freeze", 'IsShiftKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget' }, 
	{ "frozen orb", 'jps.MultiTarget' }, 
	
	-- Rotation Single
	{ "rune of power", 'jps.buffDuration("rune of power") < jps.CastTimeLeft() and not jps.buff("alter time") and IsShiftKeyDown() == true and GetCurrentKeyBoardFocus() == nil' }, 
	{ "rune of power", 'jps.cooldown("icy veins") == 0 and jps.buffDuration("rune of power") <20 and IsShiftKeyDown() == true and GetCurrentKeyBoardFocus() == nil'}, 
	{ "mirror image",'jps.UseCDs'}, 
	{ "frozen orb", 'not jps.buff("fingers of frost")'}, 
	{ "icy veins", 'jps.buff("brain freeze")'}, 
	{ "icy veins", 'jps.buff("fingers of frost")'}, 
	{ "icy veins", 'jps.TimeToDie("target") <22 and not jps.Moving'}, 
	{ "berserking", 'jps.buff("icy veins") or jps.TimeToDie("target") < 18 and jps.UseCDs'}, 
	{ "jade serpent potion", 'jps.buff("icy veins") or jps.TimeToDie("target") <45'}, 
	{ "presence of mind", 'jps.buff("icy veins") or jps.cooldown("icy veins") >15 or jps.TimeToDie("target") <15'}, 
	{ "alter time", 'not jps.buff("alter time") and jps.buff("icy veins") and jps.UseCDs'}, 
	{ "frostfire bolt", 'jps.buff("alter time") and jps.buff("brain freeze")' }, 
	{ "ice lance", 'jps.buff("alter time") and jps.buff("fingers of frost")' }, 
	
	{ "frostfire bolt", 'jps.buff("brain freeze") and jps.cooldown("icy veins") > 2' }, 
	{ "ice lance", 'jps.buff("fingers of frost")' }, 
	{ "frostbolt" , 'not jps.Moving' }, 
	{ "fire blast", 'jps.Moving'}, 
	{ "ice lance", 'jps.Moving'}, 
},"Noxxic PvE",true,false)
