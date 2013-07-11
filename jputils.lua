--[[
         JPS - WoW Protected Lua DPS AddOn
    Copyright (C) 2011 Jp Ganis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--

--------------------------
-- LOCALIZATION
--------------------------
local L = MyLocalizationTable


---------------------------
-- FUNCTIONS CLASS SPEC
---------------------------

function jps_getCombatFunction_fr( class, spec )
	local Rotations =
	{
		["Prêtre"]       = { ["Ombre"]         		= priest_shadow,
							 ["Sacré"]         		= priest_holy,
							 ["Discipline"]    		= priest_disc },
		["Guerrier"]     = { ["Fureur"]        		= warrior_fury,
							 ["Protection"]    		= warrior_prot,
							 ["Armes"]         		= warrior_arms },
		["Mage"]         = { ["Feu"]           		= mage_fire,
							 ["Arcanes"]      		= mage_arcane,
							 ["Givre"]				= mage_givre},
		["Druide"]       = { ["Farouche"]    		= druid_feral,
							 ["Restauration"]       = druid_resto,
							 ["Balance"]       		= druid_balance },
		["Moine"]        = { ["Maître brasseur"]    = monk_brewmaster,
							 ["Marche-vent"]    	= monk_windwalker,
							 ["Tisse-brume"]    	= monk_mistweaver },
		["Paladin"]      = { ["Protection"]    		= paladin_protadin,
							 ["Retribution"]   		= paladin_ret,
							 ["Sacré"]          	= paladin_holy },
		["Chevalier de la mort"]	= { ["Givre"]   = dk_frost,
							 			["Sang"]   	= dk_blood,
										["Impie"]   = dk_unholy },
		["Chamane"]		= { ["Élémentaire"]   		= shaman_elemental,
							["Amélioration"]   		= shaman_enhancement,
							["Restauration"]   		= shaman_resto },
	}
	
	return Rotations[class][spec]
end

function jps_getCombatFunction( class, spec )
	local Rotations =
	{ 
	
		["Druid"]    	 = { ["Feral"]  	   = druid_feral,
							 ["Guardian"]	   = druid_guardian,
							 ["Balance"]       = druid_balance,
							 ["Restoration"]   = druid_resto },
		["Death Knight"] = { ["Unholy"]        = dk_unholy,
							 ["Blood"]         = dk_blood,
							 ["Frost"]         = dk_frost  },  
		["Shaman"]       = { ["Enhancement"]   = shaman_enhancement,
							 ["Elemental"]     = shaman_elemental,
							 ["Restoration"]   = shaman_resto },
		["Paladin"]      = { ["Protection"]    = paladin_protadin,
							 ["Retribution"]   = paladin_ret,
							 ["Holy"]          = paladin_holy },
		["Warlock"]      = { ["Affliction"]    = warlock_affliction,
							 ["Destruction"]   = warlock_destro,
							 ["Demonology"]    = warlock_demo },
		["Hunter"]       = { ["Beast Mastery"] = hunter_bm,
							 ["Marksmanship"]  = hunter_mm,
							 ["Survival"]      = hunter_sv },
		["Mage"]         = { ["Fire"]          = mage_fire,
							 ["Arcane"]        = mage_arcane,
							 ["Frost"]         = mage_frost },
		["Rogue"]        = { ["Assassination"] = rogue_assass,
							 ["Subtlety"] 	   = rogue_sub,
							 ["Combat"] 	   = rogue_combat },
		["Warrior"]      = { ["Fury"]          = warrior_fury,
							 ["Protection"]    = warrior_prot,
							 ["Arms"]          = warrior_arms },
		["Priest"]       = { ["Shadow"]        = priest_shadow,
							 ["Holy"]          = priest_holy,
							 ["Discipline"]    = priest_disc },
		["Monk"]       	 = { ["Brewmaster"]    = monk_brewmaster,
							 ["Windwalker"]    = monk_windwalker,
							 ["Mistweaver"]    = monk_mistweaver },
	}
	
	return Rotations[class][spec]
end

---------------------------
-- FUNCTION HARMSPELL For Checking Inrange Enemy
---------------------------

-- isHarmful = IsHarmfulSpell(index, "bookType") or IsHarmfulSpell("name")
-- name, texture, offset, numEntries, isGuild, offspecID = GetSpellTabInfo(tabIndex)
-- tabIndex Number - The index of the tab, ascending from 1.
-- numTabs = GetNumSpellTabs() -- numTabs Number - number of ability tabs in the player's spellbook (e.g. 4 -- "General", "Arcane", "Fire", "Frost") 
-- Name, Subtext = GetSpellBookItemName(index, "bookType") or GetSpellBookItemName("spellName")
-- Name - Name of the spell. (string)
-- skillType, spellId = GetSpellBookItemInfo(index, "bookType") or GetSpellBookItemInfo("spellName") -- spellId - The global spell id (number) 

function jps_GetHarmSpell()
	local HarmSpell = nil
	local HarmSpell40 = {}
	local HarmSpell30 = {}
	local HarmSpell20 = {}
	local _, _, offset, numSpells, _ = GetSpellTabInfo(2)
	local booktype = "spell"
	for index = offset+1, numSpells+offset do
		-- Get the Global Spell ID from the Player's spellbook
		-- local spellname,rank,icon,cost,isFunnel,powerType,castTime,minRange,maxRange = GetSpellInfo(spellID)
		local name = select(1,GetSpellBookItemName(index, booktype))
		local spellID = select(2,GetSpellBookItemInfo(index, booktype))
		local maxRange = select(9,GetSpellInfo(spellID))
		local minRange = select(8,GetSpellInfo(spellID))
		local harmful =  IsHarmfulSpell(index, booktype)
		
		if minRange ~= nil and maxRange ~= nil and harmful ~= nil then
			if (maxRange > 39) and (harmful == 1) and (minRange == 0) then
				table.insert(HarmSpell40,name)
			elseif (maxRange > 29) and (harmful == 1) and (minRange == 0) then
				table.insert(HarmSpell30,name)
			elseif (maxRange > 19) and (harmful == 1) and (minRange == 0) then
				table.insert(HarmSpell20,name)
			end
		end
	end
	if HarmSpell40[1] then
		HarmSpell = HarmSpell40[1]
	elseif HarmSpell30[1] then
		HarmSpell = HarmSpell30[1]
	else 
		HarmSpell = HarmSpell20[1]
	end
	
	return HarmSpell
end


---------------------------
-- GET CLASS COOLDOWNS
---------------------------

function jps.getDPSRacial()
	-- Trolls n' Orcs
	if jps.DPSRacial ~= nil then return jps.DPSRacial end -- no more checks needed
	if jps.Race == nil then jps.Race = UnitRace("player") end
	if jps.Race == "Troll" then
		return "Berserking"
	elseif jps.Race == "Orc" then
		return "Blood Fury"
	end
	return nil
end

function jps.setClassCooldowns()
	local options = {}
	jps.DPSRacial = nil
	jps.DPSRacial =  jps.getRacial()
	if jps.DPSRacial then table.insert(options,"DPS Racial") end

	-- Add spells
	for i,spell in pairs(options) do
		if jpsDB[jpsRealm][jpsName][spell] == nil then
			jpsDB[jpsRealm][jpsName][spell] = true
			jps[spell] = true
		end
	end
end


---------------------------
-- TABLES
---------------------------

jps_DebuffToDispel_Name = 
{
	L["Death Coil"] ,
	L["Dragon's Breath"] ,
	L["Polymorph"] ,
	L["Frost Nova"] ,
	L["Fear"] ,
	L["Psychic Scream"] ,
	L["Freeze"] ,
	L["Deep Freeze"] ,
	L["Howl of Terror"] ,
	L["Counterspell"] ,
	L["Entangling Roots"] ,
	L["Hammer of Justice"] ,
	L["Cyclone"] ,
	L["Chilled"] ,
	L["Earthbind"] ,							
	L["Ring of Frost"] ,
	L["Living Bomb"] ,
	L["Combustion"] ,
	L["Repentance"] ,
	L["Freezing Trap"] ,	
}

jps_BuffToDispel_Name = 
{
	L["Archangel"] ,
	-- L["Frost Armor"] , --Dispel type	n/a
	L["Power Word: Shield"] ,
	L["Fear Ward"] ,
	L["Hand of Protection"] ,
	L["Incanter's Ward"] ,
	-- L["Avenging Wrath"] , -- Dispel type	n/a
	L["Predatory Swiftness"] ,
	L["Ice Barrier"] , -- Dispel type Magic
}

jps_Dispels = {
	["Deathwing"] = {
		"Plasma incendiaire", -- Boss Debuff 
		"Searing Plasma",
	},
	["Yor'sahj"] = {
		"Corruption profonde", -- Boss Debuff 
		"Deep Corruption",
	},
	["Magic"] = {
		"Static Disruption", -- Akil'zon
		"Consuming Darkness", -- Argaloth
		"Emberstrike", -- Erunak Stonespeaker
		"Binding Shadows", -- Erudax
		"Divine Reckoning", -- Temple Guardian Anhuur
		"Static Cling", -- Asaad
		"Pain and Suffering", -- Baron Ashbury
		"Cursed Veil", -- Baron Silverlaine
	},
	
	["Poison"] = {
		"Viscous Poison", -- Lockmaw
	},
	
	["Disease"] = {
		"Plague of Ages", -- High Prophet Barim
	},
	
	["Curse"] = {
		"Curse of Blood", -- High Priestess Azil
		"Cursed Bullets", -- Lord Godfrey
	},
}


---------------------------
-- TABLES
---------------------------

jps_SpellControl = {
-- Death Knight
	[108194] = "CC",		-- Asphyxiate
	[115001] = "CC",		-- Remorseless Winter
	[47476]  = "Silence",		-- Strangulate
	[96294]  = "Root",		-- Chains of Ice (Chilblains)
	[45524]  = "Snare",		-- Chains of Ice
	[50435]  = "Snare",		-- Chilblains
	--[43265]  = "Snare",		-- Death and Decay (Glyph of Death and Decay) - no way to distinguish between glyphed spell and normal. :(
	[115000] = "Snare",		-- Remorseless Winter
	[115018] = "Immune",		-- Desecrated Ground
	[48707]  = "ImmuneSpell",	-- Anti-Magic Shell
	[48792]  = "Other",		-- Icebound Fortitude
	[49039]  = "Other",		-- Lichborne
	--[51271] = "Other",		-- Pillar of Frost
	-- Death Knight Ghoul
	[91800]  = "CC",		-- Gnaw
	[91797]  = "CC",		-- Monstrous Blow (Dark Transformation)
	[91807]  = "Root",		-- Shambling Rush (Dark Transformation)
	-- Druid
	[113801] = "CC",		-- Bash (Force of Nature - Feral Treants)
	[102795] = "CC",		-- Bear Hug
	[33786]  = "CC",		-- Cyclone
	[99]     = "CC",		-- Disorienting Roar
	[2637]   = "CC",		-- Hibernate
	[22570]  = "CC",		-- Maim
	[5211]   = "CC",		-- Mighty Bash
	[9005]   = "CC",		-- Pounce
	[102546] = "CC",		-- Pounce (Incarnation)
	[114238] = "Silence",		-- Fae Silence (Glyph of Fae Silence)
	[81261]  = "Silence",		-- Solar Beam
	[339]    = "Root",		-- Entangling Roots
	[113770] = "Root",		-- Entangling Roots (Force of Nature - Balance Treants)
	[19975]  = "Root",		-- Entangling Roots (Nature's Grasp)
	[45334]  = "Root",		-- Immobilized (Wild Charge - Bear)
	[102359] = "Root",		-- Mass Entanglement
	[50259]  = "Snare",		-- Dazed (Wild Charge - Cat)
	[58180]  = "Snare",		-- Infected Wounds
	[61391]  = "Snare",		-- Typhoon
	[127797] = "Snare",		-- Ursol's Vortex
	--[???] = "Snare",		-- Wild Mushroom: Detonate
	-- Druid Symbiosis
	[110698] = "CC",		-- Hammer of Justice (Paladin)
	[113004] = "CC",		-- Intimidating Roar [Fleeing in fear] (Warrior)
	[113056] = "CC",		-- Intimidating Roar [Cowering in fear] (Warrior)
	[126458] = "Disarm",		-- Grapple Weapon (Monk)
	[110693] = "Root",		-- Frost Nova (Mage)
	--[110610] = "Snare",		-- Ice Trap (Hunter)
	[110617] = "Immune",		-- Deterrence (Hunter)
	[110715] = "Immune",		-- Dispersion (Priest)
	[110700] = "Immune",		-- Divine Shield (Paladin)
	[110696] = "Immune",		-- Ice Block (Mage)
	[110570] = "ImmuneSpell",	-- Anti-Magic Shell (Death Knight)
	[110788] = "ImmuneSpell",	-- Cloak of Shadows (Rogue)
	[113002] = "ImmuneSpell",	-- Spell Reflection (Warrior)
	[110791] = "Other",		-- Evasion (Rogue)
	[110575] = "Other",		-- Icebound Fortitude (Death Knight)
	[122291] = "Other",		-- Unending Resolve (Warlock)
	-- Hunter
	[117526] = "CC",		-- Binding Shot
	[3355]   = "CC",		-- Freezing Trap
	[1513]   = "CC",		-- Scare Beast
	[19503]  = "CC",		-- Scatter Shot
	[19386]  = "CC",		-- Wyvern Sting
	[34490]  = "Silence",		-- Silencing Shot
	[19185]  = "Root",		-- Entrapment
	[128405] = "Root",		-- Narrow Escape
	[35101]  = "Snare",		-- Concussive Barrage
	[5116]   = "Snare",		-- Concussive Shot
	[61394]  = "Snare",		-- Frozen Wake (Glyph of Freezing Trap)
	[13810]  = "Snare",		-- Ice Trap
	[19263]  = "Immune",		-- Deterrence
	-- Hunter Pets
	[90337]  = "CC",		-- Bad Manner (Monkey)
	[24394]  = "CC",		-- Intimidation
	[126246] = "CC",		-- Lullaby (Crane)
	[126355] = "CC",		-- Paralyzing Quill (Porcupine)
	[126423] = "CC",		-- Petrifying Gaze (Basilisk)
	[50519]  = "CC",		-- Sonic Blast (Bat)
	[56626]  = "CC",		-- Sting (Wasp)
	[96201]  = "CC",		-- Web Wrap (Shale Spider)
	[50541]  = "Disarm",		-- Clench (Scorpid)
	[91644]  = "Disarm",		-- Snatch (Bird of Prey)
	[90327]  = "Root",		-- Lock Jaw (Dog)
	[50245]  = "Root",		-- Pin (Crab)
	[54706]  = "Root",		-- Venom Web Spray (Silithid)
	[4167]   = "Root",		-- Web (Spider)
	[50433]  = "Snare",		-- Ankle Crack (Crocolisk)
	[54644]  = "Snare",		-- Frost Breath (Chimaera)
	[54216]  = "Other",		-- Master's Call (root and snare immune only)
	-- Mage
	[118271] = "CC",		-- Combustion Impact
	[44572]  = "CC",		-- Deep Freeze
	[31661]  = "CC",		-- Dragon's Breath
	[118]    = "CC",		-- Polymorph
	[61305]  = "CC",		-- Polymorph: Black Cat
	[28272]  = "CC",		-- Polymorph: Pig
	[61721]  = "CC",		-- Polymorph: Rabbit
	[61780]  = "CC",		-- Polymorph: Turkey
	[28271]  = "CC",		-- Polymorph: Turtle
	[82691]  = "CC",		-- Ring of Frost
	[102051] = "Silence",		-- Frostjaw (also a root)
	[55021]  = "Silence",		-- Silenced - Improved Counterspell
	[122]    = "Root",		-- Frost Nova
	[111340] = "Root",		-- Ice Ward
	[121288] = "Snare",		-- Chilled (Frost Armor)
	[120]    = "Snare",		-- Cone of Cold
	[116]    = "Snare",		-- Frostbolt
	[44614]  = "Snare",		-- Frostfire Bolt
	[113092] = "Snare",		-- Frost Bomb
	[31589]  = "Snare",		-- Slow
	[45438]  = "Immune",		-- Ice Block
	[115760] = "ImmuneSpell",	-- Glyph of Ice Block
	-- Mage Water Elemental
	[33395]  = "Root",		-- Freeze
	-- Monk
	[123393] = "CC",		-- Breath of Fire (Glyph of Breath of Fire)
	[126451] = "CC",		-- Clash
	[122242] = "CC",		-- Clash (not sure which one is right)
	[119392] = "CC",		-- Charging Ox Wave
	[120086] = "CC",		-- Fists of Fury
	[119381] = "CC",		-- Leg Sweep
	[115078] = "CC",		-- Paralysis
	[117368] = "Disarm",		-- Grapple Weapon
	--[???] = "Disarm",		-- Ring of Peace
	--[???] = "Silence",		-- Ring of Peace
	[116709] = "Silence",		-- Spear Hand Strike
	[116706] = "Root",		-- Disable
	[113275] = "Root",		-- Entangling Roots (Symbiosis)
	[123407] = "Root",		-- Spinning Fire Blossom
	[116095] = "Snare",		-- Disable
	[118585] = "Snare",		-- Leer of the Ox
	[123727] = "Snare",		-- Dizzying Haze
	[123586] = "Snare",		-- Flying Serpent Kick
	[131523] = "ImmuneSpell",	-- Zen Meditation
	-- Paladin
	[105421] = "CC",		-- Blinding Light
	[115752] = "CC",		-- Blinding Light (Glyph of Blinding Light)
	[105593] = "CC",		-- Fist of Justice
	[853]    = "CC",		-- Hammer of Justice
	[119072] = "CC",		-- Holy Wrath
	[20066]  = "CC",		-- Repentance
	[10326]  = "CC",		-- Turn Evil
	[31935]  = "Silence",		-- Avenger's Shield
	[110300] = "Snare",		-- Burden of Guilt
	[63529]  = "Snare",		-- Dazed - Avenger's Shield
	[20170]  = "Snare",		-- Seal of Justice
	[642]    = "Immune",		-- Divine Shield
	[31821]  = "Other",		-- Aura Mastery
	-- Priest
	[113506] = "CC",		-- Cyclone (Symbiosis)
	[605]    = "CC",		-- Dominate Mind
	[88625]  = "CC",		-- Holy Word: Chastise
	[64044]  = "CC",		-- Psychic Horror
	[8122]   = "CC",		-- Psychic Scream
	[113792] = "CC",		-- Psychic Terror (Psyfiend)
	[9484]   = "CC",		-- Shackle Undead
	[87204]  = "CC",		-- Sin and Punishment
	[15487]  = "Silence",		-- Silence
	[64058]  = "Disarm",		-- Psychic Horror
	[113275] = "Root",		-- Entangling Roots (Symbiosis)
	[87194]  = "Root",		-- Glyph of Mind Blast
	[114404] = "Root",		-- Void Tendril's Grasp
	[15407]  = "Snare",		-- Mind Flay
	[47585]  = "Immune",		-- Dispersion
	[114239] = "ImmuneSpell",	-- Phantasm
	-- Rogue
	[2094]   = "CC",		-- Blind
	[1833]   = "CC",		-- Cheap Shot
	[1776]   = "CC",		-- Gouge
	[408]    = "CC",		-- Kidney Shot
	[113953] = "CC",		-- Paralysis (Paralytic Poison)
	[6770]   = "CC",		-- Sap
	[1330]   = "Silence",		-- Garrote - Silence
	[51722]  = "Disarm",		-- Dismantle
	[115197] = "Root",		-- Partial Paralysis
	[3409]   = "Snare",		-- Crippling Poison
	[26679]  = "Snare",		-- Deadly Throw
	[119696] = "Snare",		-- Debilitation
	[31224]  = "ImmuneSpell",	-- Cloak of Shadows
	[45182]  = "Other",		-- Cheating Death
	[5277]   = "Other",		-- Evasion
	--[76577]  = "Other",		-- Smoke Bomb
	[88611]  = "Other",		-- Smoke Bomb
	-- Shaman
	[76780]  = "CC",		-- Bind Elemental
	[77505]  = "CC",		-- Earthquake
	[51514]  = "CC",		-- Hex
	[118905] = "CC",		-- Static Charge (Capacitor Totem)
	[113287] = "Silence",		-- Solar Beam (Symbiosis)
	[64695]  = "Root",		-- Earthgrab (Earthgrab Totem)
	[63685]  = "Root",		-- Freeze (Frozen Power)
	[3600]   = "Snare",		-- Earthbind (Earthbind Totem)
	[77478]  = "Snare",		-- Earthquake (Glyph of Unstable Earth)
	[8034]   = "Snare",		-- Frostbrand Attack
	[8056]   = "Snare",		-- Frost Shock
	[51490]  = "Snare",		-- Thunderstorm
	[8178]   = "ImmuneSpell",	-- Grounding Totem Effect (Grounding Totem)
	-- Shaman Primal Earth Elemental
	[118345] = "CC",		-- Pulverize
	-- Warlock
	[710]    = "CC",		-- Banish
	[137143] = "CC",		-- Blood Horror
	[54786]  = "CC",		-- Demonic Leap (Metamorphosis)
	[5782]   = "CC",		-- Fear
	[118699] = "CC",		-- Fear
	[130616] = "CC",		-- Fear (Glyph of Fear)
	[5484]   = "CC",		-- Howl of Terror
	[22703]  = "CC",		-- Infernal Awakening
	[6789]   = "CC",		-- Mortal Coil
	[132412] = "CC",		-- Seduction (Grimoire of Sacrifice)
	[30283]  = "CC",		-- Shadowfury
	[104045] = "CC",		-- Sleep (Metamorphosis)
	[132409] = "Silence",		-- Spell Lock (Grimoire of Sacrifice)
	[31117]  = "Silence",		-- Unstable Affliction
	[18223]  = "Snare",		-- Curse of Exhaustion
	[47960]  = "Snare",		-- Shadowflame
	[110913] = "Other",		-- Dark Bargain
	[104773] = "Other",		-- Unending Resolve
	-- Warlock Pets
	[89766]  = "CC",		-- Axe Toss (Felguard/Wrathguard)
	[115268] = "CC",		-- Mesmerize (Shivarra)
	[6358]   = "CC",		-- Seduction (Succubus)
	[115782] = "Silence",		-- Optical Blast (Observer)
	[24259]  = "Silence",		-- Spell Lock (Felhunter)
	[118093] = "Disarm",		-- Disarm (Voidwalker/Voidlord)
	-- Warrior
	[7922]   = "CC",		-- Charge Stun
	[118895] = "CC",		-- Dragon Roar
	[5246]   = "CC",		-- Intimidating Shout (aoe)
	[20511]  = "CC",		-- Intimidating Shout (targeted)
	[132168] = "CC",		-- Shockwave
	[107570] = "CC",		-- Storm Bolt
	[105771] = "CC",		-- Warbringer
	[18498]  = "Silence",		-- Silenced - Gag Order (PvE only)
	[676]    = "Disarm",		-- Disarm
	[107566] = "Root",		-- Staggering Shout
	[1715]   = "Snare",		-- Hamstring
	[12323]  = "Snare",		-- Piercing Howl
	[129923] = "Snare",		-- Sluggish (Glyph of Hindering Strikes)
	[137637] = "Snare",		-- Warbringer
	[46924]  = "Immune",		-- Bladestorm
	[23920]  = "ImmuneSpell",	-- Spell Reflection
	[114028] = "ImmuneSpell",	-- Mass Spell Reflection
	[18499]  = "Other",		-- Berserker Rage
	-- Other
	[30217]  = "CC",		-- Adamantite Grenade
	[67769]  = "CC",		-- Cobalt Frag Bomb
	[30216]  = "CC",		-- Fel Iron Bomb
	[107079] = "CC",		-- Quaking Palm
	[13327]  = "CC",		-- Reckless Charge
	[20549]  = "CC",		-- War Stomp
	[25046]  = "Silence",		-- Arcane Torrent (Energy)
	[28730]  = "Silence",		-- Arcane Torrent (Mana)
	[50613]  = "Silence",		-- Arcane Torrent (Runic Power)
	[69179]  = "Silence",		-- Arcane Torrent (Rage)
	[80483]  = "Silence",		-- Arcane Torrent (Focus)
	[129597] = "Silence",		-- Arcane Torrent (Chi)
	[39965]  = "Root",		-- Frost Grenade
	[55536]  = "Root",		-- Frostweave Net
	[13099]  = "Root",		-- Net-o-Matic
	[1604]   = "Snare",		-- Dazed
	-- PvE
	--[123456]  = "PvE",		-- not real, just an example
}

--------------------------------------------------------------------
-- FUNCTION RETURNS SPEC OF UNITFRAME WHEN MOUSEOVER THE FRAME
--------------------------------------------------------------------

--local _G = getfenv(0)
local _G = _G 

local function InspectTalents(inspect)
	local numLines, linesNeeded = GameTooltip:NumLines()
	local unit = select(2, GameTooltip:GetUnit())
	if not unit then return end
	local guild, guildRankName, guildRankIndex = GetGuildInfo(unit)
	local isInRange = CheckInteractDistance(unit, 1)
	local UnitIsPlayerControlled = UnitPlayerControlled(unit)

	if UnitIsPlayerControlled == false then return end

	for i=1, GetNumSpecGroups(unit) do -- check for Dualspec
		local group = GetActiveSpecGroup(unit) --check which Spec is active
		if group == 1 then
			activegroup = "|cffddff55<|r"
		elseif group == 2 then
			activegroup = "|cFFdddd55<<|r"
		end
	end

	local specID = GetInspectSpecialization(unit)
	local id, name, description, icon, background, role, class = GetSpecializationInfoByID(specID)

	local customRole
	if role == "HEALER" then
		customRole = "Heal"
	elseif role == "DAMAGER" then
		customRole = "Damage"
	elseif role == "TANK" then
		customRole = "Tank"
	end

	if not icon then return end
	local linetext = ((string.format("|T%s:%d:%d:0:-1|t", icon, 16, 16)).." "..name.." ("..customRole..")")

	if isInRange then
		if guild then
			_G["GameTooltipTextLeft4"]:SetText(linetext)
			_G["GameTooltipTextLeft4"]:Show()
		elseif not guild then
			_G["GameTooltipTextLeft3"]:SetText(linetext)
			_G["GameTooltipTextLeft3"]:Show()
		else
			GameTooltip:AddLine(linetext)
		end
	end
	GameTooltip:AppendText("")
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent",function(self, event, guid)
	self:UnregisterEvent("INSPECT_READY")
	InspectTalents(1)
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local unit = select(2, GameTooltip:GetUnit())
	if not unit then return end

	if UnitIsPlayer(unit) and (UnitLevel(unit) > 9 or UnitLevel(unit) == -1) then
		if not InspectFrame or not InspectFrame:IsShown() then
			if CheckInteractDistance(unit,1) and CanInspect(unit) then

				f:RegisterEvent("INSPECT_READY")
				NotifyInspect(unit)
			end
		end
	end
end)

--------------------------------------------------------------------
-- FUNCTION RETURNS SPELL ID -- on mouseover item/spell/glyph/aura/buff/Debuff
--------------------------------------------------------------------

local select, UnitBuff, UnitDebuff, UnitAura, tonumber, strfind, hooksecurefunc =
	select, UnitBuff, UnitDebuff, UnitAura, tonumber, strfind, hooksecurefunc
local GetGlyphSocketInfo = GetGlyphSocketInfo

local function addLine(self,id,isItem)
	if isItem then
		self:AddDoubleLine("ItemID:","|cffffffff"..id)
	else
		self:AddDoubleLine("SpellID:","|cffffffff"..id)
	end
	self:Show()
end

hooksecurefunc(GameTooltip, "SetUnitBuff", function(self,...)
	local id = select(11,UnitBuff(...))
	if id then addLine(self,id) end
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self,...)
	local id = select(11,UnitDebuff(...))
	if id then addLine(self,id) end
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	local id = select(11,UnitAura(...))
	if id then addLine(self,id) end
end)

-- local enabled, glyphType, glyphTooltipIndex, glyphSpellID, icon = GetGlyphSocketInfo(i)  
hooksecurefunc(GameTooltip, "SetGlyph", function(self,...)
	local id = select(4,GetGlyphSocketInfo(...))
	if id then addLine(self,id) end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local id = select(3,self:GetSpell())
	if id then addLine(self,id) end
end)

hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))
	if id then addLine(ItemRefTooltip,id) end
end)

local function attachItemTooltip(self)
	local link = select(2,self:GetItem())
	if not link then return end
	local id = select(3,strfind(link, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)"))
	if id then addLine(self,id,true) end
end

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)

-----------------------
-- FUNCTION LOOKUP RAID
-----------------------

function LookupSpec ()
	local function printing()
		print("All Rotations return no Lua Error")
	end
	local Table_Spec = 	{
		druid_feral(),
		druid_guardian(),
		druid_balance(),
		druid_resto() ,
		dk_unholy(),
		dk_blood( ),
		dk_frost( ),  
		shaman_enhancement( ),
		shaman_elemental( ),
		shaman_resto( ),
		paladin_protadin( ),
		paladin_ret( ),
		paladin_holy( ),
		warlock_affliction( ),
		warlock_destro( ),
		warlock_demo( ),
		hunter_bm( ),
		hunter_mm( ),
		hunter_sv( ),
		mage_fire( ),
		mage_arcane( ),
		mage_frost( ),
		rogue_assass( ),
		rogue_sub( ),
		rogue_combat( ),
		warrior_fury( ),
		warrior_prot( ),
		warrior_arms( ),
		priest_shadow( ),
		priest_holy( ),
		priest_disc( ),
		monk_brewmaster( ),
		monk_windwalker( ),
		monk_mistweaver( ),
		printing( ),
	}
	for i, j in ipairs(Table_Spec) do
		RunMacroText("/run "..j)
	end
end
