-- SEE BOTTOM FOR USER NOTES
-- by: SwollNMember WoW v5.2 compliant
-- Thanks to Gocargo for original version

jps.registerStaticTable("WARRIOR","ARMS",function()
-- Player Specific
	local player = jpsName
	local playerRace = UnitRace(player)
	local stance = GetShapeshiftForm()
	local playerhealth_pct = jps.hp("player")
	local bZerk = jps.buff("berserker rage",player)
	local enrage = jps.buff("enrage",player)
	local rage = UnitPower(player,1)
	local shield = IsEquippedItemType("Shields")
	local twoHand = IsEquippedItemType("Two-Hand")
	local rooted = jps.LoseControl(player,"Root")
	local rogueStun = jps.debuff("cheap shot",player) or jps.debuff("kidney shot",player) or jps.debuff("gouge",player)
	local stun = jps.StunEvents()
	local isFalling = IsFalling()==1
-- Unit Info
	local targetName = GetUnitName("target")
	local targetClass = UnitClass("target")
	local targetSpec = GetSpecialization("target")
	local targethealth_pct = jps.hp("target")
	local isHarmSpell = IsHarmfulSpell("target")
	local melee = IsSpellInRange("pummel","target")==1
	local noMelee = IsSpellInRange("pummel","target")==0
	local isImmune = jps.LoseControl(rangedTarget,"Immune")
	local dmgBlock = jps.buff("ice block",rangedTarget) or jps.buff("devine shield",rangedTarget) or jps.buff("hand of protection",rangedTarget)
	local kick = jps.shouldKick(rangedTarget) or jps.IsCastingPoly(rangedTarget)
	local kickFocus = jps.shouldKick("focus") or jps.IsCastingPoly("focus")
------------------------
-- LOCAL FUNCTIONS -----
------------------------
-- COUNTERS
-- Death Knight
	local function parse_vsDK()
		local table =
		{
		{ "mass spell reflection", jps.cooldown("mass spell relfection")==0 and not jps.buff("spell reflection") , player },
		-- { UseEquipmentSet("PvP Tank"), not jps.buff("mass spell reflection") , player },
		{ "spell reflection", shield and not jps.buff("mass spell reflection") , player },
		}
		return table
	end
-- Druid
	local function parse_vsDruid()
		local table =
		{
		{ "pummel", jps.isCastingSpell("healing touch",rangedTarget) and jps.CastTimeLeft("target") <=1 , rangedTarget },
		{ {"macro","/cast every man for himself\n/cast pummel"}, melee and stun and jps.isCastingSpell("healing touch",rangedTarget) and jps.CastTimeLeft("target") <=1 , rangedTarget },
		{ {"macro","/cast every man for himself\n/cast pummel"}, melee and stun and jps.isCastingSpell("cyclone",rangedTarget) and jps.CastTimeLeft("target") <=1 , rangedTarget },
		{ "shattering throw", jps.buff("bear form",rangedTarget) , rangedTarget },
		{ "avatar", melee and targetSpec == "Feral" , rangedTarget },
		{ "recklessness", melee and targetSpec == "Feral" , rangedTarget },
		}
		return table
	end
-- Hunter
	local function parse_vsHunter()
		local table =
		{
		{ "taunt", jps.LastCast==charge , rangedTarget },
		{ "mocking banner", playerhealth_pct < 0.50 and not jps.buff("bestial wrath",rangedTarget), player },
		{ "disarm", true , rangedTarget },
		{ "intimidating shout", CheckInteractDistance("target",3)==1 and not jps.debuff("disarm",rangedTarget) , rangedTarget },
		-- { attack pet until 100 rage },
		}
		return table
	end
-- Mage
	local function parse_vsMage()
		local table =
		{
		-- { "nested", jps.LastCast("mirror image",rangedTarget) , parse_multitarget() },
		{ "shattering throw", dmgBlock , rangedTarget },
		{ "intimidating shout", not iceBlock and CheckInteractDistance("target",3)==1 , rangedTarget },
		{ "mortal strike", not jps.debuff("deep wounds",rangedTarget) , rangedTarget },
		{ "mass spell reflection", jps.cooldown("bladestorm",player) ~= 0 and jps.debuff("frost nova",player) or jps.debuff("freeze",player) , player },
		{ "mass spell reflection", noMelee and isHarmSpell and not jps.IsCastingPoly(rangedTarget) , player },
		-- { UseEquipmentSet("PvP Tank"), noMelee and isHarmSpell and not jps.IsCastingPoly(rangedTarget) and not jps.buff("mass spell reflection") , player },
		{ "spell reflection", noMelee and isHarmSpell and not jps.IsCastingPoly(rangedTarget) and not jps.buff("mass spell reflection") , player },
		}
		return table
	end
-- Monk
-- Paladin
	local function parse_vsPaladin()
		local table =
		{
		{ "disarm", jps.buff("avenging wrath",rangedTarget) , rangedTarget },
		{ "shattering throw", dmgBlock , rangedTarget },
		-- { trinket and pummel after stun },
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
		{ "demoralizing banner", true , rangedTarget },
		{ "intimidating shout", jps.buff("shadow dance",rangedTarget) , rangedTarget },
		{ "disarm", jps.debuff("dismantle",player) and not jps.LoseControl(rangedTarget,"CC") , rangedTarget },
		{ "disarm", jps.buff("shadow dance",rangedTarget) and not jps.LoseControl(rangedTarget,"CC") , rangedTarget },
		{ "berserker rage", jps.debuff("gouge",player) , player },
		{ {"macro","/cast every man for himself\n/cast defensive stance"}, rogueStun , player },
		-- { "battle stance", not jps.StunEvents() and playerhealth_pct > targethealth_pct , player },
		}
		return table
	end
-- Shaman
	local function parse_vsShaman()
		local table =
		{
		{ "disarm", targetSpec == "Enhancement" , rangedTarget },
		-- { "pummel", casting lesser healing wave targethealth_pct < 0.30 , rangedTarget },
		-- { "pummel", casting lava burst or lightning , rangedTarget },
		-- { trinket and pummel, jps.debuff("warstomp",player) and targethealth_pct < 0.30 , rangedTarget },
		{ "mortal strike", targethealth_pct < 0.50 and targetSpec == "Elemental" and not jps.debuff("mortal strike",rangedTarget) , rangedTarget },
		-- Lava Burst
		}
		return table
	end
-- Warlock
	local function parse_vsWarlock()
		local table =
		{
		-- { "spell reflect", casting chaos bolt , rangedTarget },
		-- { "spell reflect", is casting fear , rangedTarget },
		-- { "mass spell reflection", casting chaos bolt , rangedTarget },
		{ "pummel", kick , rangedTarget },
		}
		return table
	end
-- Warrior
	local function parse_vsWarrior()
		local table =
		{
		{ "demoralizing banner", true , rangedTarget },
		{ "berserker stance", melee and targetSpec == "Arms" or targetSpec == "Fury" and not jps.buff("avatar",rangedTarget) and not jps.buff("bladestorm",rangedTarget) , rangedTarget },
		{ "defensive stance", melee and jps.buff("avatar",rangedTarget) or jps.buff("bladestorm",rangedTarget) , rangedTarget },
		-- { UseEquipmentSet("PvP Tank"), melee and jps.buff("avatar",rangedTarget) or jps.buff("bladestorm",rangedTarget) , rangedTarget },
		}
		return table
	end

-- Battle Stance
	function bStance()
		if melee and twoHand then return true end
		return false
	end

-- Defensive Stance
	function dStance()
			if noMelee then return true end
			if shield then return true end
			if isPowerUp() then return true end
			if playerhealth_pct < 0.20 then return true end
			return false
	end

-- Shout Buffs
	function buffShout()
		if rage <= 10 then return true end
		if not jps.buff("battle shout") or not jps.buff("commanding shout") then return true end
		if rage < 85 and jps.cooldown("colossus smash") ~= 0
		and jps.cooldown("heroic strike") ~= 0
		and jps.cooldown("mortal strike") ~= 0 then return true end
		return false
	end

-- Heroic Strike
	function shouldHStrike()
		if rage >= 70 and jps.debuff("physical vulnerability",rangedTarget) then return true end
		if rage >= 85 then return true end
		if jps.buff("ultimatum",player) then return true end
		if jps.buff("taste for blood",player) and jps.buffDuration("taste for blood") <= 2 then return true end
		if jps.buffStacks("taste for blood") == 1 then return true end
		if jps.buff("Taste for blood",player) and jps.debuffDuration("physical vulnerability") <= 2 and jps.cooldown("colossus smash") ~= 0 then return true end
		-- if not jps.LoseControl(rangedTarget,"Snare") then return true end
		return false
	end

-- Colossus Smash
	function shouldSmash()
		if jps.buff("sudden death") and not jps.debuff("physical vulnerability",rangedTarget) then return true end
		if not jps.debuff("physical vulnerability",rangedTarget) then return true end
		if jps.debuffDuration("physical vulnerability",rangedTarget) < 1.50 then return true end
		return false
	end

-- Disarm
	function shouldDisarm()
		if targetClass == "Death Knight" or targetClass == "Hunter" or targetClass == "Rogue" or targetClass == "Warrior" then return true end
		if targetSpec == "Enhancement" or targetSpec == "Retribution" then return true end
		if jps.buff("bear form","target") or jps.buff("cat form","target") then return true end
		return false
	end

-- Enemy Powerups
	function isPowerUp()
		-- Death Knight
		if jps.buff("soul reaper",rangedTarget) then return true end
		-- Druid
		if jps.buff("chosen of elune",rangedTarget) or jps.buff("king of the jungle",rangedTarget)
		or jps.buff("son of ursoc",rangedTarget) then return true end
		-- Hunter
		if jps.buff("bestial wrath",rangedTarget) then return true end
		-- Mage
		if jps.buff("arcane power",rangedTarget) then return true end
		-- Monk
		-- Paladin
		if jps.buff("avenging wrath",rangedTarget) then return true end
		-- Priest
		-- Rogue
		-- if jps.buff("shadowstep",rangedTarget) then return true end
		-- Shaman
		if jps.buff("ascendance",rangedTarget) and targetSpec == "Elemental" then return true end
		if jps.buff("ascendance",rangedTarget) and targetSpec == "Enhancement" then return true end
		-- Warlock
		if jps.buff("metamorphosis",rangedTarget) then return true end
		-- Warrior
		if jps.buff("avatar",rangedTarget) or jps.buff("bloodbath",rangedTarget) then return true end
		return false
	end

-- Is the Target a World Boss?
	local isWorldBoss = false
	if (UnitClassification(r) == "worldboss" ) then
		isWorldBoss = true
	end

	-- Enemy Tracking
	local EnemyUnit = {}
	for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end -- EnemyUnit[1]
		local enemyTargetingMe = jps.IstargetMe()
		local enemycount,targetcount = jps.RaidEnemyCount()

		local rangedTarget = "target"
		if jps.canDPS("target") then rangedTarget = "target"
		elseif jps.canDPS("focustarget") then rangedTarget = "focustarget"
		elseif jps.canDPS("targettarget") then rangedTarget = "targettarget"
		elseif jps.canDPS(enemyTargetingMe) then rangedTarget = enemyTargetingMe
		elseif jps.canDPS(EnemyUnit[1]) then rangedTarget = EnemyUnit[1]
	end

	jps.Macro("/target "..rangedTarget)

	-- Multitarget Attack Table
	local function parse_multitarget()
		local table =
		{
		{ "thunder clap", not jps.debuff("weakened blows") , rangedTarget },
		{ "sweeping strikes", enemycount = 3 , rangedTarget },
		{ "bladestorm", true , rangedTarget },
		{ "cleave", enemycount = 3 and shouldHStrike() and targethealth_pct >= 0.21 , rangedTarget },
		{ "whirlwind", enemycount > 3 and rage > 29 , rangedTarget },
		}
		return table
	end
	------------------------
	-- SPELL TABLE ---------
	------------------------
	local spellTable =
	{
		-- Class Counters
		{ "nested", IsShiftKeyDown()~=nil , parse_multitarget() },
		{ "nested", enemycount > 2 , parse_multitarget() },
		{ "nested", targetClass=="Death Knight" , parse_vsDK() },
		{ "nested", targetClass=="Hunter" , parse_vsHunter() },
		{ "nested", targetClass=="Mage" or jps.debuff("frost nova",player) or jps.debuff("freeze",player) , parse_vsMage() },
		{ "nested", targetClass=="Paladin" , parse_vsPaladin() },
		{ "nested", targetClass=="Rogue" or jps.debuff("cheap shot",player) or jps.debuff("kidney shot",player) , parse_vsRogue() },
		{ "nested", targetClass=="Shaman" , parse_vsShaman() },
		{ "nested", targetClass=="Warlock" , parse_vsWarlock() },
		{ "nested", targetClass=="Warrior" , parse_vsWarrior() },
		-- Fall/Knockback Response
		-- "Charge" 100
		{ {"macro","/targetenemyplayer\n/cast charge"}, isFalling , player },
		-- "Heroic Leap" 6544 "Bond héroïque"
		-- { "heroic leap", isFalling and jps.cooldown("charge")==0 , player },
		-- "Defensive Stance" 71
		-- { "defensive stance", stance ~= 2 and isFalling , player },
		-- Gap Closers
		-- { "charge",	},
		{ "charge", noMelee , rangedTarget },
		-- { "heroic leap", noMelee and jps.cooldown("charge") > 0 , rangedTarget },
		{ "heroic leap", IsAltKeyDown() ~= nil },
		-- Remove Snares, Roots, Loss of Control, etc.
		{ "bladestorm", noMelee and rooted , player },
		-- { "avatar",	noMelee and rooted , player },
		{ "every man for himself", rooted and jps.cooldown("bladestorm")~=0 , player },
		{ "berserker rage", jps.LoseControl(player,"CC") , player },
		{ "every man for himself", jps.LoseControl(player,"CC") , player },
		-- Kicks, Crowd Control, etc.
		{ "charge",	kick and noMelee , rangedTarget },
		{ "pummel", kick and melee , rangedTarget },
		{ "intimidating shout", kick and melee and jps.cooldown("pummel") ~= 0 , rangedTarget },
		{ "intimidating shout", kick and noMelee and CheckInteractDistance(rangedTarget,3)==1 , rangedTarget },
		{ "throw", noMelee and jps.cooldown("heroic throw") ~= 0 , rangedTarget },
		-- Survival, Heals, etc.
		{ {"macro","/use "..14}, jps.useTrinket(1) and stance==2 and playerhealth_pct < 0.30 , "player", "Trinket14_"..tostring(jps.useTrinket(1)) },
		-- Healthstone 5512
		{ {"macro","/use item:5512"}, UnitAffectingCombat(player)==1 and select(1,IsUsableItem(5512))==1 and jps.itemCooldown(5512) == 0 and (playerhealth_pct < 0.50) , player , "UseItem" },
		{ "lifeblood", playerhealth_pct < 0.90, player },
		-- { "mass spell reflection", playerhealth_pct < 0.30, player },
		-- { "spell reflection", playerhealth_pct < 0.30 , player },
		-- { UseEquipmentSet("PvP Tank"), playerhealth_pct < 0.20 , player },
		{ "shield wall", playerhealth_pct < 0.20 , player },
		{ "die by the sword", playerhealth_pct < 0.30 or isPowerUp() , player },
		{ "rallying cry", playerhealth_pct < 0.20, player },
		-- Stance Dance
		{ "battle stance", bStance() and stance~=1 , player },
		{ "defensive stance", dStance() and stance~=2 , player },
		-- { "defensive stance", noMelee or shield and stance~=2 or isPowerUp() or playerhealth_pct < 0.20 , player },
		-- { "berserker stance", stance~=3 and playerhealth_pct > 0.30 and melee and rage < 50 , player},
		-- Gear Swap
		-- { UseEquipmentSet("PvP DPS"), melee and stance~=2 , player },
		-- { UseEquipmentSet("PvP Tank"), playerhealth_pct < 0.20 , player },
		-- { UseEquipmentSet("Raid DPS"),	stance == 1 or stance == 3 and shield },
		-- { UseEquipmentSet("Raid Tank"), stance == 2 and shield == nil},
		-- Debuffs
		{ "disarm", shouldDisarm() and targetName~="Training Dummy" , rangedTarget },
		{ "thunder clap", shouldDisarm() and not jps.debuff("weakend blows") , rangedTarget },
		{ "piercing howl", melee and not jps.LoseControl(rangedTarget,"Snare") , rangedTarget },
		{ "piercing howl", jps.buff("bladestorm",player) , rangedTarget },
		{ "hamstring", melee and not jps.LoseControl(rangedTarget,"Snare") , rangedTarget },
		-- { "shattering throw", shouldShatter and not jps.debuff("shattering throw") and not jps.Moving or isWorldBoss },
		-- Buffs
		-- Shouts
		{ "battle shout", stance==1 and buffShout() , player },
		{ "commanding shout", stance==2 and buffShout() and jps.LastCast~="charge" , player },
		-- DPS Buff/Cooldown Cascade
		{ "berserker rage", jps.UseCDs and melee and not jps.buff("enrage") and jps.TimeToDie(rangedTarget) > 8 , player },
		{ "berserker rage", jps.buff("avatar") and not jps.buff("enrage") and jps.TimeToDie(rangedTarget) > 8 , player },
		{ "berserker rage", not jps.buff("enrage") and jps.TimeToDie(rangedTarget) > 6 , player },

		-- { "recklessness", jps.UseCDs and melee and (jps.debuffDuration("Colossus Smash") >= 5 or jps.cooldown("Colossus Smash") <= 4 ) or targethealth_pct < 0.21 , player },
		{ "recklessness", jps.UseCDs and melee and jps.buff("avatar") and jps.TimeToDie(rangedTarget) > 11 or jps.buff("skull banner") , player },
		{ "avatar", jps.UseCDs and melee and targethealth_pct < 0.30 and jps.TimeToDie(rangedTarget) > 23 , player },
		{ "avatar", jps.UseCDs and melee and jps.buff("recklessness") or jps.buff("skull banner") and targethealth_pct < 0.30  and jps.TimeToDie(rangedTarget) > 23 , player },
		{ "skull banner", jps.UseCDs and jps.buff("avatar") or jps.buff("recklessness") , player },
		-- { "demoralizing banner", playerhealth_pct < 0.30, "player", jps.groundClick() or IsShiftKeyDown() ~= nil , player },
		-- { "alliance battle standard", playerhealth_pct < 0.30 and not jps.debuff("demoralizing banner"), jps.groundClick() , player },
		------------------------
		-- ATTACKS -------------
		------------------------
		-- Finishers
		{ "execute", jps.debuff("physical vulnerability") , rangedTarget },
		-- Base Attacks
		{ "heroic throw", noMelee and rooted , rangedTarget },
		{ "victory rush", jps.buff("victorious") , rangedTarget },
		{ "overpower", true , rangedTarget },
		{ "colossus smash", shouldSmash() , rangedTarget },
		{ "cleave", enemycount = 2 and shouldHStrike() and targethealth_pct >= 0.21 , rangedTarget },
		{ "heroic strike", shouldHStrike() and targethealth_pct >= 0.21 , rangedTarget },
		{ "mortal strike", targethealth_pct >= 0.21 or not jps.debuff("mortal strike") , rangedTarget },
		{ "mortal strike", true , rangedTarget },
		{ "slam", rage >= 90 and targethealth_pct >= 0.21 , rangedTarget },
		{ "slam", rage >= 40 , rangedTarget },
		{ {"macro","/startattack"}, nil , rangedTarget },
	}

	spell,target = parseSpellTable(spellTable)

	return spell,target
end, "Default", false, true)