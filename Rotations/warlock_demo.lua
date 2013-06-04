-- WIP: need maybe some changes

function warlock_demo()
	
	-----------------------------------------------------------------
	------------------------- FUNCTION --------------------------
	-----------------------------------------------------------------
	
	function haveProc ()
		if jps.buff("Dark Soul: Knowledge")	
			or jps.buff("Inner Brilliance")	
			or jps.buff("Acceleration")	
			or jps.buff("Lightweave")	
			or jps.buff("Blessing of the Celestials")	
			or jps.buff("Windsong")	
			or jps.buff("Synapse Springs")	
			or jps.buff("Jade Spirit")
			or jps.buff("Quickened Tongues")
			then return true end
		return false
	end
	
	function banishFocus ()
		local table_banishList = { "Elemental", "Demon", "Aberration" }
		for i,j in pairs(table_banishList) do
			if UnitCreatureType("focus") == j then return true end
		end
		return false
	end
	
	---------------------------------------------------------------------
	---------------------------------------------------------------------
	---------------------------------------------------------------------

	local pet = UnitExists("pet")
	if pet == nil then pet = false
	else pet = true end
	
	local haveProc = haveProc ()
	local stunMe =  jps.StunEvents()
	
	local cpn_duration = jps.debuffDuration("corruption")
	local doom_duration = jps.debuffDuration("Doom")
	local cur_duration = jps.debuffDuration("curse of the elements")
	local meta_duration = jps.buffDuration("metamorphosis")
	
	local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
	local dpower = UnitPower("player",15)

	local mana = UnitMana("player")/UnitManaMax("player")
	local playerHP = UnitHealth("player")/UnitHealthMax("player")
	local playerMaxHP = UnitHealthMax("player")
	local targetHP = UnitHealth("target")/UnitHealthMax("target")
	local targetMaxHP = UnitHealthMax("target")
	
	local targetThreatStatus = UnitThreatSituation("player","target")
	if not targetThreatStatus then targetThreatStatus = 0 end
	local isInRaid = GetNumGroupMembers() > 0
	
	local GulCharges = 0 -- GetSpellCharges returns nil if the spell have only one charge
	if GetSpellCharges("hand of gul'dan") ~= nil then GulCharges = select(1,GetSpellCharges("hand of gul'dan")) end

	if castGulnm == nil then castGulnm = false end
	if GulCharges == 2 then castGulnm = true end
	if GulCharges == 0 then castGulnm = false end

	local forme = GetShapeshiftForm("player")
	
	----------------------------
	------ banish focus var ----
	----------------------------
	local banishFocus = banishFocus ()
	local banishDefuff = jps.debuffDuration("Banish","focus")
	local  spell1,_,_,_,_,end1,_,_,_ = UnitCastingInfo("player")
	if endtimeBan == nil then endtimeBan = 0 end
	if spell1 == "Banish" then endtimeBan = (end1/1000) end
	
	local GDCD = select(3,GetSpellCharges(105174)) + select(4,GetSpellCharges(105174)) - GetTime()

	------------------------
	-- SPELL TABLE ---------
	------------------------
	
	local spellTable = {}
	spellTable[1] =
	{ 
	
		["ToolTip"] = "Demo Raid",
		
		{ {"macro","/focus [target=mouseover,exists,nodead]"}, IsShiftKeyDown() ~= nil },
		
		------ banish focus if banishable ----
		{ "Banish", banishFocus  and not jps.debuff("Banish","focus") and endtimeBan+2 < GetTime(), "focus" },
		
		-- unStunt ---
		{ 108482, jps.cooldown(108482) == 0 and stunMe },
		 
		--- moving --
		{ "fel flame", currentSpeed > 0 and not jps.buff("metamorphosis") },
		{ "soulshatter", targetThreatStatus ~= 0 and isInRaid },
		
		-- regen mana --
		{ "life tap", mana < 0.25 and jps.hp("player") > 0.6 },
		
		-- survival cd --
		{ {"macro","/use Healthstone"},  jps.itemCooldown(5512)==0 and jps.hp() < 0.4 and GetItemCount(5512) > 0	},
		{ "mortal coil",	jps.hp("player") < 0.70 },
		
		-- sacrifical pact
		{ 108416, playerHP < 0.60 and jps.cooldown(108416) == 0  }, -- sacrifical pact
		{ "unending resolve",	jps.hp("player") < 0.35 },
		
		-- doomguard/Potion--
		{ {"macro","/use Potion of the Jade Serpent"},  jps.itemCooldown(76093)==0 and jps.bloodlusting() and GetItemCount(76093) > 0 and jps.UseCDs },
		{ "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.bloodlusting() and jps.UseCDs },
		{ "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.hp("target") < 0.25 and jps.UseCDs },
		 
		 
		--cd--
		{ "dark soul: knowledge" },	
		{ jps.DPSRacial, jps.UseCDs },
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-------------------
		----- opening -----
		-------------------
		
		--human opening--
		{ "imp swarm", jps.Opening },
		
		{ "hand of gul'dan", GulCharges > 1 and not jps.buff("metamorphosis") and jps.Opening }, 
		{ "hand of gul'dan", GulCharges < 2 and not jps.buff("metamorphosis") and jps.Opening and GDCD <= 11 },
		
		{ "Grimoire: Felguard", not jps.buff("metamorphosis") and jps.Opening },
		{ "corruption", not jps.debuff("corruption") and not jps.buff("metamorphosis") and jps.Opening },
		{ "metamorphosis", jps.Opening and not jps.buff("metamorphosis") and GulCharges == 0  },
		{ "corruption",  jps.buff("metamorphosis") and jps.Opening and not jps.debuff("Doom") },
		{ {"macro","/cancelaura metamorphosis"},  jps.buff("metamorphosis") and jps.Opening and jps.debuff("Doom") },
		
		-------------------
		----  nm cycle ----
		-------------------
		
		--cd talent--	
		{ "imp swarm" },
		{ "felstorm", jps.Interrupts and pet and not jps.Opening },	
		{ "Grimoire: Felguard", not jps.buff("metamorphosis") },
		
		{ 172, cpn_duration < 3 and not jps.buff("metamorphosis") },
		{ "metamorphosis", not jps.buff("metamorphosis") and jps.debuff("corruption") and not jps.debuff("Doom") and not jps.Opening  },
		{ "metamorphosis", dpower > 900 and not jps.buff("metamorphosis") and not haveProc },
		{ "metamorphosis", dpower > 850 and not jps.buff("metamorphosis") and haveProc },
		
		{ "corruption",  (jps.buff("metamorphosis") and doom_duration < 40 and dpower < 200) or (jps.buff("metamorphosis") and doom_duration < 20) and not jps.Opening },
		
		
		{ "shadow bolt", jps.buff("metamorphosis") },	
		{ "soul fire", jps.hp("target") <= 0.25 and jps.buff("metamorphosis") },
		{ "soul fire", jps.buff("metamorphosis") and jps.buffDuration("molten core") < 4 and jps.buff("molten core") },
		
		{ {"macro","/cancelaura metamorphosis"}, jps.buff("metamorphosis") and not jps.debuff("corruption") and not jps.Opening },
		{ {"macro","/cancelaura metamorphosis"}, jps.hp("target") > 0.25 and not jps.Opening and dpower < 750 and jps.buff("metamorphosis") and not haveProc },
		 
		{ "hand of gul'dan", GulCharges > 1 and castGulnm and not jps.buff("metamorphosis") and not jps.Opening }, 
		{ "hand of gul'dan", GulCharges < 2 and castGulnm and not jps.buff("metamorphosis") and not jps.Opening and GDCD <= 11 },
		 
		{ "soul fire", jps.hp("target") <= 0.25 and not jps.buff("metamorphosis") },
		{ "shadow bolt", not jps.buff("metamorphosis") and jps.buffDuration("molten core") <= 2.5 },
		{ "soul fire", jps.buffDuration("molten core") > 2.5 and not jps.buff("metamorphosis") },
		{ "shadow bolt", not jps.buff("metamorphosis") },
	}
	
	if jps.debuff("Doom") and forme == 0 then jps.Opening = false end
	
	local spellTableActive = jps.RotationActive(spellTable)
	local spell,target = parseSpellTable(spellTableActive)
	return spell,target

end