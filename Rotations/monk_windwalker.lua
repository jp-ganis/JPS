--[[[
@rotation Default
@class monk
@spec WINDWALKER
@description
]]--

jps.registerRotation("MONK","WINDWALKER",function()
	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
	
	local energy = UnitMana("player")
	local energyPerSec = 13
	local energyTimeToMax = (100 - energy) / energyPerSec
	
	local chi = UnitPower("Player", 12)
	local defensiveCDActive = jps.buff("Touch of Karma") or jps.buff("Zen Meditation") or jps.buff("Fortifying Brew") or jps.buff("Dampen Harm") or jps.buff("Diffuse Magic")
	local tigerPowerDuration = jps.buffDuration("Tiger Power")

------------------------
-- Bagged items usage --
------------------------
-- 5512 for "Healthstone", 75525 for "Alchemist's Flask"
function canUseItemInBags(itemID)										
	local itemID = itemID
	if GetItemCount(itemID, false, false) > 0 and select(2,GetItemCooldown(itemID)) == 0 then return true end
	return false
end

----------------
--- HOT-KEYS ---
----------------
-- Reset keys to zero
local shiftKEY_binary = 0
local altKEY_binary = 0
local controlKEY_binary = 0

-- Register key downs
if IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil then shiftKEY_binary = 1 end
if IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil then altKEY_binary = 2 end
if IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil then controlKEY_binary = 4 end

-- Binary calculation
hotKEY_combo = shiftKEY_binary + altKEY_binary + controlKEY_binary

-- Binary key combinations
-- 1 = Shift
-- 2 = Alt
-- 3 = Shift + Alt
-- 4 = Control
-- 5 = Shift + Control
-- 6 = Alt + Control
-- 7 = Shift + Alt + Control

if hotKEY_combo == 2 then HealingSphere_KEY = true else HealingSphere_KEY = false end -- Put Healing Spheres on the ground

	local spellTable = {

		-- GROUND SPELLS
		{ "Healing Sphere",	HealingSphere_KEY },

		-- BREWS
		-- Chi Brew if we have no chi and less than 5 Elusive Brew stacks (talent based).
		{ "Chi Brew", chi == 0 and jps.buffStacks("Tigereye Brew") < 5 },
		-- Tigereye Brew when we have 10 stacks.
		{ "Tigereye Brew", jps.UseCDs and jps.buffStacks("Tigereye Brew") >= 15 },
		-- Energizing Brew whenever if it'll take approximately more than 5 seconds of regen to max energy.
		{ "Energizing Brew", energyTimeToMax > 5 },

		-- ITEMS, BUFFS AND SURVAVIBILITY
		-- Legacy of the Emperor
		{ "Legacy of the Emperor", not jps.buff("Legacy of the Emperor") and energy >= 40 },
		-- Legacy of the White Tiger
		{ "Legacy of the White Tiger", not jps.buff("Legacy of the White Tiger") and energy >= 40 },
		-- Alchemist's Flask
		{ jps.useBagItem("Alchemist's Flask"), not jps.buff("Enhanced Agility") and not jps.buff("Flask of Spring Blossoms") },
		-- Healthstone
    	{ {"macro","/use Healthstone"}, jps.hp("player") < 0.50 and canUseItemInBags(5512) },
    	-- Master Healing Potion
    	{ {"macro","/use Master Healing Potion"}, jps.hp("player") < 0.30 and canUseItemInBags(76097) },
   		-- On-Use Trinket 2.
		{ jps.useTrinket(1), jps.UseCDs },

		-- PROFESSIONS AND RACIALS
		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and chi > 3 and energy >= 50 },
		-- Herbalists have Lifeblood.
		{ "Lifeblood", jps.UseCDs },
		-- DPS Racial on cooldown.
		{ jps.DPSRacial, jps.UseCDs },

		-- COOLDOWNS
		-- Fortifying Brew if you get low. Is set to 35% health because when at or below it, Desperate Measures triggers.
		{ "Fortifying Brew", jps.Defensive and jps.hp() < .5 and not defensiveCDActive },
		-- Diffuse Magic if you get low. (talent based)
		{ "Diffuse Magic", jps.Defensive and jps.hp() < .5 and not defensiveCDActive },
		-- Dampen Harm if you get low. (talent based)
		{ "Dampen Harm", jps.Defensive and jps.hp() < .6 and not defensiveCDActive },
		{ "Touch of Karma", jps.Defensive and jps.hp() < .65 and not defensiveCDActive },
		-- Invoke Xuen on cooldown for single-target. (talent based)
		{ "Invoke Xuen, the White Tiger", jps.UseCDs },

		-- MAIN ROTATION
		-- Rising Sun Kick to keep debuff up. 
		{ "Rising Sun Kick", not jps.debuff("Rising Sun Kick") or jps.debuffDuration("Rising Sun Kick") <= 3 },
		-- Rising Sun Kick on cooldown.
		{ "Rising Sun Kick" },
		-- Blackout Kick on clearcast. 
		{ "Blackout Kick", jps.buff("Combo Breaker: Blackout Kick") },
		-- Blackout Kick as single-target chi dump. 
		{ "Blackout Kick", not jps.MultiTarget and chi >= 4 and energyTimeToMax <= 2 },
		{ "Chi Wave", },
		-- Expel Harm for building some chi and healing if not at full health.
		{ "Expel Harm", jps.hp() < .85 and energy >= 40 and chi < 3 },
		-- Jab is our basic chi builder.
		{ "Jab", not jps.MultiTarget and chi <= 3 },
		-- Tiger Palm on clearcast. 
		{ "Tiger Palm", jps.buff("Combo Breaker: Tiger Palm") },
		-- Tiger Palm single-target if the buff is close to falling off.
		{ "Tiger Palm", not jps.MultiTarget and tigerPowerDuration <= 3 },
		-- Fist of fury is a very situational chi dump.
		{ "Fists of Fury", not jps.buff("Energizing Brew") and energyTimeToMax >= 3.5 and tigerPowerDuration >= 3.5 and not jps.Moving and IsSpellInRange("jab","target") },
		-- Blackout Kick as filler and if we're chi capped. 
		{ "Blackout Kick", not jps.MultiTarget },

		-- AOE ROTATION
		-- Spinning Crane Kick for multi-target threat. Triggers with Left Control Key pressed.
		{ "Spinning Crane Kick", jps.MultiTarget and not jps.buff("Spinning Crane Kick"),"player"},
		-- Rushing Jade Wind for multi-target threat. Triggers with Left Control Key pressed.
		{ "Rushing Jade Wind", jps.MultiTarget and not jps.buff("Rushing Jade Wind"),"player"},

		-- FINISHERS
		-- Insta-kill single target when available.
		{ "Touch of Death", not jps.MultiTarget and jps.UseCDs and jps.buff("Death Note") },

		-- SELF-HEALING
		-- Expel Harm when below 35% heatlh.
		{ "Expel Harm", jps.hp() < .35 },
		-- Chi Wave for heal (talent based).
		{ "Chi Wave", jps.hp() < .80 },
		-- Zen Sphere for heal (talent based).
		{ "Zen Sphere", jps.hp() < .80 },
		-- Chi Wave for heal (talent based).
		{ "Chi Burst", jps.hp() < .80 },

		-- INTERRUPTS
		{ "Spear Hand Strike", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.4 },
		{ "Paralysis", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" },
		{ "Arcane Torrent", jps.Interrupts and jps.shouldKick("target") and CheckInteractDistance("target",3)==1 and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },

		-- INTERRUPT FOCUS
		{ "Spear Hand Strike", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < 1.2 },
		{ "Paralysis", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < 1.2 and IsSpellInRange("Spear Hand Strike","focus")==0 and jps.LastCast ~= "Spear Hand Strike" },
		{ "Arcane Torrent", jps.Interrupts and jps.shouldKick("focus") and CheckInteractDistance("focus",3)==1 and jps.CastTimeLeft("target") < 1.2 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },	
	}

	local spell,target = parseSpellTable(spellTable)
	
	return spell,target
end, "Default")
