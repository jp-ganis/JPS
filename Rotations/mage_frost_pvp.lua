-- SEE BOTTOM FOR USER NOTES
-- by: SwollNMember WoW v5.2 compliant
function mage_frost_pvp()

-- Player Specific
	local player = jpsName
	local mana = UnitPower(player,0)/UnitPowerMax(player,0)
	local stun = jps.StunEvents()
	local isFalling = IsFalling()==1
-- Unit Info
	local targetName = GetUnitName("target")
	local targetClass = UnitClass("target")
	local kick = jps.shouldKick(rangedTarget) or jps.IsCastingPoly(rangedTarget)

------------------------
-- LOCAL FUNCTIONS -----
------------------------
-- COUNTERS
-- Death Knight
	local function parse_vsDK()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end
-- Druid
	local function parse_vsDruid()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end
-- Hunter
	local function parse_vsHunter()
	local table =
	{
		-- { "empty", empty , empty },
	}	
	return table
	end
-- Mage
	local function parse_vsMage()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end	
-- Monk
-- Paladin
	local function parse_vsPaladin()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end
-- Priest
	local function parse_vsPriest()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end
-- Rogue
	local function parse_vsRogue()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end
-- Shaman
	local function parse_vsShaman()
	local table =
	{
		-- { "empty", empty , empty },	 
	}
	return table
	end
-- Warlock
	local function parse_vsWarlock()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end	
-- Warrior
	local function parse_vsWarrior()
	local table =
	{
		-- { "empty", empty , empty },
	}
	return table
	end
 

-- Remove Curse
	local function decurse()
		if jps.debuff("curse of the elements",player) then return true end
		if jps.debuff("curse of enfeeblement",player) then return true end
		if jps.debuff("curse of exhaustion",player) then return true end
		if jps.debuff("agony",player) then return true end
		if jps.debuff("doom",player) then return true end
		if jps.debuff("havok",player) then return true end
		if jps.debuff("hex",player) then return true end
		return false
	end
 
-- Enemy Tracking
	local enemycount,targetcount = jps.RaidEnemyCount()
	local EnemyUnit = {}
		for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end
	local rangedTarget = "target"
		if jps.canDPS("target") then rangedTarget = "target"
		elseif jps.canDPS("focustarget") then rangedTarget = "focustarget"
		elseif jps.canDPS("targettarget") then rangedTarget = "targettarget"
		elseif jps.canDPS(EnemyUnit[1]) then rangedTarget = EnemyUnit[1]
	end

		
	------------------------
	-- SPELL TABLE ---------
	------------------------
	local spellTable = {
		{ "slow fall", isFalling and not jps.buff("slow fall") , player },
		{ "nested", targetClass=="Death Knight" , parse_vsDK() },
		{ "nested", targetClass=="Hunter" , parse_vsHunter() },
		{ "nested", targetClass=="Mage" or jps.debuff("frost nova",player) or jps.debuff("freeze",player) , parse_vsMage() },
		{ "nested", targetClass=="Paladin" , parse_vsPaladin() },
		{ "nested", targetClass=="Rogue" or jps.debuff("cheap shot",player) or jps.debuff("kidney shot",player) , parse_vsRogue() },
		{ "nested", targetClass=="Shaman" , parse_vsShaman() },
		{ "nested", targetClass=="Warlock" , parse_vsWarlock() },
		{ "nested", targetClass=="Warrior" , parse_vsWarrior() },
		-- Gap Closers
		-- Remove Snares, Roots, Loss of Control, etc.
		{ "every man for himself", jps.LoseControl(player,"CC") , player },
		
		-- Kicks, Crowd Control, etc.
		{ "counterspell", kick , rangedTarget },
		{ "arcane brilliance", not jps.buff("arcane brilliance") }, 
		{ "frost armor", not jps.buff("frost armor") }, 
		{ "Freeze",	IsAltKeyDown() ~= nil },
		{ "rune of power", not jps.buff("rune of power") and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 
		{ "mirror image", jps.UseCds}, 
	
		{ {"macro","/use Mana Gem"}, mana < 0.70 and GetItemCount("Mana Gem", 0, 1) > 0 , player }, 
		{ {"macro","/cast icy veins\n/cast evocation"}, jps.hp() <= .4 and jps.cooldown("icy veins") == 0 and jps.cooldown("evocation") == 0 , player },
		{ "Healthstone",		jps.hp() < .7 and GetItemCount("Healthstone", 0, 1) > 0 },
		
		-- Debuffs
		{ "remove curse", decurse() , player },
		
		{ "rune of power", jps.buffDuration("rune of power") < jps.CastTimeLeft() and not jps.buff("alter time") and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 
		{ "rune of power", jps.cooldown("icy veins") == 0 and jps.buffDuration("rune of power") <20 and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil}, 
		{ "mirror image", jps.UseCds}, 
		{ "frozen orb", not jps.buff("fingers of frost")}, 
		{ "icy veins", (jps.debuffStacks("frostbolt") >= 3 and (jps.buff("brain freeze") or jps.buff("fingers of frost"))) or jps.TimeToDie("target") <22 and not jps.Moving}, 
		{ "berserking", jps.buff("icy veins") or jps.TimeToDie("target") <18}, 
		{ "jade serpent potion", jps.buff("icy veins") or jps.TimeToDie("target") <45}, 
		{ "presence of mind", jps.buff("icy veins") or jps.cooldown("icy veins") >15 or jps.TimeToDie("target") <15}, 
		{ "alter time", not jps.buff("alter time") and jps.buff("icy veins") }, 
		{ "flamestrike", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget }, 
		{ "frostfire bolt", jps.buff("alter time") and jps.buff("brain freeze") }, 
		{ "ice lance", jps.buff("alter time") and jps.buff("fingers of frost") }, 
		{ "frost bomb", jps.TimeToDie("target") > tonumber(jps.CastTimeLeft()) and not jps.Moving},
		{ "frostbolt", jps.debuffStacks("frostbolt") < 3 and not jps.Moving }, 
		{ "frostfire bolt", jps.buff("brain freeze") and jps.cooldown("icy veins") > 2 }, 
		{ "ice lance", jps.buff("fingers of frost") and jps.cooldown("icy veins") >2 }, 
		{ "frostbolt" , not jps.Moving }, 
		{ "fire blast", jps.Moving}, 
		{ "ice lance", jps.Moving}, 
	}
	spell,target = parseSpellTable(spellTable)
	return spell,target
end