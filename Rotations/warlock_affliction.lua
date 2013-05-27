function warlock_affliction()

	jps.Tooltip = "Warlock by Tropic"
	-- by tropic
	-- Talents: http://www.wowhead.com/talent#o!i]|
	-- Tier 1: Soul Leech
	-- Tier 2: Mortal Coil
	-- Tier 3: Dark Bargain
	-- Tier 4: Burning Rush
	-- Tier 5: Grimoire of Sacrifice
	-- Tier 6: Kil'jaeden's Cunning
	-- Major Glyphs: Glyph of Soul Shards, Glyph of Siphon Life
	
	-- Usage info:
	-- Automatic summon pet and use Grimoire of Sacrifice for 50% damage buff
	-- Automatic intellect buff
	-- Use Healthstone at low health if available in inventory
	-- Lots of survivability CDs and Soulshatter if you get aggro, Drain Life at really low health
	-- Cooldowns: trinkets, dark soul: misery, summon doomguard
	-- Recast delay for spells with travel time: Unstable Affliction, Haunt, Seed of Corruption
	-- Life tap when low on mana
	
	-- Todo:
	-- Focus dotting (maybe, not sure it's worth it)
	-- Improve AoE, at some point it can hang somehow
	-- Burning Rush when Kil'jaeden's Cunning debuff
	-- Disable Soulshatter when soloing
	
	local mana = UnitMana("player")/UnitManaMax("player")
	local shards = UnitPower("player",7)
	local playerHP = UnitHealth("player")/UnitHealthMax("player")
	local playerMaxHP = UnitHealthMax("player")
	local targetHP = UnitHealth("target")/UnitHealthMax("target")
	local targetMaxHP = UnitHealthMax("target")

	local targetThreatStatus = UnitThreatSituation("player","target")
		if not targetThreatStatus then targetThreatStatus = 0 end
	
	local ago_duration = jps.debuffDuration("agony")
	local cor_duration = jps.debuffDuration("corruption")
	local uaf_duration = jps.debuffDuration("Unstable Affliction")
	local haunt_duration = jps.debuffDuration("haunt")
	local uaf_casttime = 0
	local uaf = select(7,GetSpellInfo("Unstable Affliction"))
	if uaf ~= nil then uaf_casttime = uaf/1000 end

	-- Recast delay (ty robottech)
	local  spell1,_,_,_,_,end1,_,_,_ = UnitCastingInfo("player")
	if endtimeua == nil then endtimeua = 0 end
	if endtimehaunt == nil then endtimehaunt = 0 end
	if endtimeseed == nil then endtimeseed = 0 end
	if spell1 == "Unstable Affliction" then endtimeua = (end1/1000) end
	if spell1 == "Haunt" then endtimehaunt = (end1/1000) end
	if spell1 == "Seed of Corruption" then endtimeseed = (end1/1000) end

	-- Intelligent trinkets
	local trinket1ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket0Slot"))
	local canUseTrinket1,_ = GetItemSpell(trinket1ID)
	local _,Trinket1ready,_ = GetItemCooldown(trinket1ID)

	local trinket2ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket1Slot"))
	local canUseTrinket2,_ = GetItemSpell(trinket2ID)
	local _,Trinket2ready,_ = GetItemCooldown(trinket2ID)
	
	-- Healthstone check
	local HealthstoneIsReady = false
	if GetItemCount(5512, false, false) > 0 and select(2,GetItemCooldown(5512)) == 0 then
		HealthstoneIsReady = true
	end

	local spellTable =
	{
		-- Survivability
		{ {"macro","/use Healthstone"}, playerHP < 0.60 and HealthstoneIsReady }, -- restores 20% of total health
		{ "mortal coil",				 playerHP < 0.60 }, -- restores 15% of total health
		{ "mortal coil",				 playerHP < 0.80 and jps.Moving}, -- restores 15% of total health
		{ "dark bargain",				 playerHP < 0.30 }, -- absorbs damage for 8 sec, afterwards 50% is dealt over 8 sec.
		{ "unending resolve",			 playerHP < 0.25 }, -- -40% damage for 8 sec.
		{ "drain life",				 playerHP < 0.25 }, 
		{ "soulshatter",				 targetThreatStatus ~= 0 }, -- reduces threat by 90% for all enemies within 50 yards - TODO: disable when soloing
		
		-- Buff
		{ "dark intent",				 not jps.buff("dark intent") and not jps.buff("arcane brilliance") and not jps.buff("dalaran brilliance") and not jps.buff("burning wrath") and not jps.buff("still water") }, 
		{ "soulburn",					 UnitExists("pet") == nil and not jps.buff("grimoire of sacrifice") and not jps.buff("soulburn") and jps.cooldown("summon felhunter") <= 0 }, 
		{ "grimoire of sacrifice",		 UnitExists("pet") ~= nil and not jps.buff("grimoire of sacrifice") }, 
		{ "summon felhunter",			 UnitExists("pet") == nil and not jps.buff("grimoire of sacrifice") }, 
		
		-- CDs
		{ "dark soul: misery",			 jps.UseCDs }, 
		{ {"macro","/use Potion of the Jade Serpent"},  jps.itemCooldown(76093)==0 and jps.bloodlusting() and GetItemCount(76093) > 0 and jps.UseCDs },
		{ "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.bloodlusting() and jps.UseCDs },
		{ "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.hp("target") < 0.25 and jps.UseCDs },		
		
		{ jps.DPSRacial, jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		{ jps.useTrinket(2), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-- Mana regain
		{ "life tap",					 mana < 0.35 }, 
		
		-- Curse
		{ "curse of the elements",		 not jps.debuff("curse of the elements") and UnitHealth("target") > playerMaxHP and not jps.buff("soulburn") }, 
		
		-- Aoe
		{ "soulburn",					 shards >= 1 and not jps.debuff("seed of corruption") and not jps.buff("soulburn") and jps.MultiTarget }, 
		{ "seed of corruption",			not jps.debuff("seed of corruption") and jps.buff("soulburn") and endtimeseed+1 < GetTime() and not jps.Moving and jps.MultiTarget }, 
		{ "seed of corruption",		 not jps.debuff("seed of corruption") and shards < 1 and endtimeseed+1 < GetTime() and jps.MultiTarget },
		
		-- Spells
		{ "soul swap",				 jps.buff("soulburn") }, 
		{ "Haunt",						haunt_duration < ((uaf_casttime)+1) and (endtimehaunt+2.75) < GetTime() },	 
		{ "soulburn",					 shards >= 1 and not jps.debuff("agony") and not jps.debuff("corruption") and not jps.debuff("unstable affliction") and not jps.buff("soulburn") }, 
		
		-- Dots
		{ "agony",						ago_duration < 7 and not jps.buff("soulburn") }, 
		{ "corruption",					cor_duration < 7 and not jps.buff("soulburn") }, 
		{ "unstable affliction",		uaf_duration < 6 and endtimeua+1 < GetTime() },  
		
		-- Fillers
		{ "drain soul",				 targetHP <= 0.20 },
		{ "malefic grasp",				 targetHP > 0.20 },
		{ "fel flame",					 jps.Moving },
	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end

