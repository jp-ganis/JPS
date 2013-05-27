-- SEE BOTTOM FOR USER NOTES
-- by: SwollNMember WoW v5.2 compliant
function mage_frost()

-- Player Specific
	local player = jpsName
	local mana = UnitPower(player,0)/UnitPowerMax(player,0)
	local atActive = jps.buff("Altered Time")
	local fofActive = jps.buff("Fingers of Frost")
	local bfActive = jps.buff("Brain Freeze")
	local fbStacks = jps.debuffStacks("frostbolt")
	local stun = jps.StunEvents()
	local isFalling = IsFalling()==1
-- Unit Info
	local targetName = GetUnitName("target")
	local targetClass = UnitClass("target")
	local targetSpec = GetSpecialization("target")
	local targethealth_pct = jps.hpInc("target")
	local dmgBlock = jps.buff("ice block",rangedTarget) or jps.buff("devine shield",rangedTarget) or jps.buff("hand of protection",rangedTarget) or jps.buff("deterrence",rangedTarget)
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
	local enemycount,targetcount = jps.TableEnemyCount()
	local EnemyUnit = {}
		for name, _ in pairs(jps.RaidTarget) do table.insert(EnemyUnit,name) end
	local rangedTargetCount = jps.RaidEnemyTargetCount()
	local rangedTarget = "target"
		if jps.canDPS("target") then rangedTarget = "target"
		elseif jps.canDPS("focustarget") then rangedTarget = "focustarget"
		elseif jps.canDPS("targettarget") then rangedTarget = "targettarget"
		elseif jps.canDPS(EnemyUnit[1]) then rangedTarget = EnemyUnit[1]
	end

	RunMacroText("/target "..rangedTarget)
	
------------------------
-- SPELL TABLE ---------
------------------------
local spellTable =
{
	{ SetView(1), },
-- Class Counters
	{ "nested", targetClass=="Death Knight" , parse_vsDK() },
	{ "nested", targetClass=="Hunter" , parse_vsHunter() },
	{ "nested", targetClass=="Mage" or jps.debuff("frost nova",player) or jps.debuff("freeze",player) , parse_vsMage() },
	{ "nested", targetClass=="Paladin" , parse_vsPaladin() },
	{ "nested", targetClass=="Rogue" or jps.debuff("cheap shot",player) or jps.debuff("kidney shot",player) , parse_vsRogue() },
	{ "nested", targetClass=="Shaman" , parse_vsShaman() },
	{ "nested", targetClass=="Warlock" , parse_vsWarlock() },
	{ "nested", targetClass=="Warrior" , parse_vsWarrior() },
	
-- Fall/Knockback Response
	{ "slow fall", isFalling , player },
	
-- Gap Closers
-- Remove Snares, Roots, Loss of Control, etc.
	{ "every man for himself", jps.LoseControl(player,"CC") , player },
	
-- Kicks, Crowd Control, etc.
	{ {"macro","/use High-Powered Bolt Gun"}, kick , rangedTarget },
	{ "counterspell", kick , rangedTarget },
	
-- Survival, Heals, etc.
	{ {"macro","/use Mana Gem"}, mana < 0.70 and GetItemCount("Mana Gem", 0, 1) > 0 , player }, 
	{ {"macro","/cast icy veins\n/cast evocation"}, jps.hp() < .41 , player },
	{ "Healthstone",		jps.hp() < .7 and GetItemCount("Healthstone", 0, 1) > 0 },

-- Debuffs
	{ "remove curse", decurse() , player },
-- Buffs
	{ "ice barrier", not jps.buff("ice barrier") , player },
------------------------
-- ATTACKS -------------
------------------------

--CDs
	{ "Mirror Image",	 jps.UseCDs },
	{ jps.DPSRacial, jps.UseCDs },
	{ jps.useTrinket(1), jps.UseCDs },
	{ jps.useTrinket(2), jps.UseCDs },
	
	-- Requires engineerins
	{ jps.useSynapseSprings(), jps.UseCDs },
	
	-- Requires herbalism
	{ "Lifeblood", jps.UseCDs },
	
	
-- Finishers
	{ {"macro","/cast alter time\n/use 13\n/use 14\n/cast presence of mind\n/cast frostbolt"}, targethealth_pct < 0.30 or jps.debuff("deep freeze") and not dmgBlock , rangedTarget },
	{ {"macro","/cast alter time\n/use 13\n/use 14\n/cast presence of mind\n/cast frostbolt"}, atActive and not dmgBlock , rangedTarget },
	
-- Base Attacks
	{ "ice lance", jps.debuff("deep freeze") or jps.LastCast == frostbolt or jps.Moving or fofActive , rangedTarget },
	{ "frostfire bolt", bfActive , rangedTarget },
	{ "frost bomb", not jps.debuff("frost bomb") , rangedTarget },
	{ "frost orb", not jps.buff("fingers of frost") or enemycount > 2 , rangedTarget },
	{ "fire blast", IsSpellInRange("fire blast",rangedTarget) == 1 , rangedTarget },
	{ "cone of cold", CheckInteractDistance(rangedTarget,3) == 1 , rangedTarget },
	{ "frostbolt", fbStacks < 3 and not jps.Moving , rangedTarget },
	{ {"macro","/startattack"}, nil , rangedTarget },
}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end