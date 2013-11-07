--[[[
@rotation Default
@class monk
@spec brewmaster
@description
]]--

jps.registerRotation("MONK","BREWMASTER",function()
 	if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
 
	local chi = UnitPower("player", "12") -- 12 is chi
	local energy = UnitPower("player", "3") -- 3 is energy
	local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")

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
if hotKEY_combo == 3 then OxStatue_KEY = true else OxStatue_KEY = false end -- Put Ox Statue
if hotKEY_combo == 6 then DizzyingHaze_KEY= true else DizzyingHaze_KEY = false end -- Dizzying Haze

	local spellTable = {

		-- GROUND SPELLS
		{ "Healing Sphere",	HealingSphere_KEY },
		{ "Summon Black Ox Statue",	OxStatue_KEY },
		{ "Dizzying Haze", DizzyingHaze_KEY },

		-- SHORT COOLDOWNS
		-- Guard when Power Guard buff is available and while taking some damage.
		{ "Guard", jps.buff("Power Guard") and jps.hp() < .90 and chi >= 2 },

		-- BREWS
		-- Chi Brew if we have no chi and less than 5 Elusive Brew stacks (talent based).
		{ "Chi Brew", chi == 0 and jps.buffStacks("Elusive Brew") < 5 },
		-- Purifying Brew to clear stagger when it's moderate or heavy.
		{ "Purifying Brew", jps.debuff("Moderate Stagger") or jps.debuff("Heavy Stagger") and chi >= 1},
		-- Elusive Brew with 10 or more stacks.
		{ "Elusive Brew", jps.buffStacks("Elusive Brew") >= 10 },

		-- ITEMS, BUFFS AND SURVAVIBILITY
		-- Legacy of the Emperor
		{ "Legacy of the Emperor", not jps.buff("Legacy of the Emperor") and energy >= 40 },
		-- Alchemist's Flask
		{ jps.useBagItem("Alchemist's Flask"), not jps.buff("Enhanced Agility") and not jps.buff("Flask of Spring Blossoms") },
		-- Healthstone
    	{ {"macro","/use Healthstone"}, jps.hp("player") < 0.50 and canUseItemInBags(5512) },
    	-- Master Healing Potion
    	{ {"macro","/use Master Healing Potion"}, jps.hp("player") < 0.30 and canUseItemInBags(76097) },
   		-- On-Use Trinket 2.
		{ jps.useTrinket(1), jps.UseCDs },

		-- SELF-HEALING
		-- Expel Harm when below 35% heatlh does not have cooldown due Desperate Measures.
		{ "Expel Harm", jps.hp() < .35 and energy >= 40 },
		-- Chi Wave for heal (talent based).
		{ "Chi Wave", jps.hp() < .85 },
		-- Zen Sphere for heal (talent based).
		{ "Zen Sphere", jps.hp() < .85 },
		-- Chi Wave for heal (talent based).
		{ "Chi Burst", jps.hp() < .85 },
		-- Purifying Brew to heal you if yoy have Healing Elixirs talent.
		{ "Purifying Brew", jps.buff("Healing Elixirs") and jps.hp() < .80 and chi >= 1},

		-- PROFESSIONS AND RACIALS
		-- Engineers may have synapse springs on their gloves (slot 10).
		{ jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and chi > 3 and energy >= 50 },
		-- Herbalists have Lifeblood.
		{ "Lifeblood", jps.UseCDs },
		-- DPS Racial on cooldown.
		{ jps.DPSRacial, jps.UseCDs },

		-- COOLDOWNS
		-- Fortifying Brew if you get low. Is set to 35% health because when at or below it, Desperate Measures triggers.
		{ "Fortifying Brew", jps.Defensive and jps.hp() < .35 and not defensiveCDActive },
		-- Diffuse Magic if you get low. (talent based)
		{ "Diffuse Magic", jps.Defensive and jps.hp() < .5 and not defensiveCDActive },
		-- Dampen Harm if you get low. (talent based)
		{ "Dampen Harm", jps.Defensive and jps.hp() < .6 and not defensiveCDActive },
		-- Invoke Xuen on cooldown for single-target. (talent based)
		--{ "Invoke Xuen, the White Tiger", jps.UseCDs },

		-- MAIN ROTATION
		-- Keg Smash to build some chi and keep the Weakened Blows debuff up.
		{ "Keg Smash", chi < 3 or not jps.debuff("Weakened Blows") },
		-- Blackout Kick if shuffle is missing or about to drop.
		{ "Blackout Kick", (not jps.buff("Shuffle") or jps.buffDuration("Shuffle") < 3 ) and chi >= 2 },
		-- Expel Harm for building some chi and healing if not at full health.
		{ "Expel Harm", jps.hp() < .85 and energy >= 40 and chi < 4 },
		-- Jab is our basic chi builder.
		{ "Jab", chi < 4 and energy > 70 },
		-- Tiger Palm to keep the Tiger Power buff up. No chi cost due to Brewmaster specialization at level 34.
		{ "Tiger Palm", not jps.buff("Tiger Power") or jps.buffDuration("Tiger Power") <= 1.5 },
		{ "Chi Wave", jps.hp() > .90 },

		-- AOE ROTATION
		-- Spinning Crane Kick for multi-target threat. Triggers with Left Control Key pressed.
		{ "Spinning Crane Kick", jps.MultiTarget and not jps.buff("Spinning Crane Kick"),"player"},
		-- Rushing Jade Wind for multi-target threat. Triggers with Left Control Key pressed.
		{ "Rushing Jade Wind", jps.MultiTarget and not jps.buff("Rushing Jade Wind"),"player"},
		-- Breath of Fire when target(s) have Dizzying Haze debuff.
		{ "Breath of Fire", jps.MultiTarget and jps.debuff("Dizzying Haze") and chi >= 2},
   		-- Breath of Fire when Left Control is pressed.
		{ "Breath of Fire", IsLeftControlKeyDown() ~= nil },

		-- FINISHERS
		-- Insta-kill single target when available.
		{ "Touch of Death", not jps.MultiTarget and jps.UseCDs and jps.buff("Death Note") },

		-- INTERRUPTS
		{ "Spear Hand Strike", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.4 },
		{ "Paralysis", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" },
		{ "Breath of Fire", jps.Interrupts and jps.shouldKick("target") and chi >= 2 and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },
		{ "Arcane Torrent", jps.Interrupts and jps.shouldKick("target") and CheckInteractDistance("target",3)==1 and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },

		-- INTERRUPT FOCUS
		{ "Spear Hand Strike", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < 1.4 },
		{ "Paralysis", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < 1.4 and IsSpellInRange("Spear Hand Strike","focus")==0 and jps.LastCast ~= "Spear Hand Strike" },
		{ "Arcane Torrent", jps.Interrupts and jps.shouldKick("focus") and CheckInteractDistance("focus",3)==1 and jps.CastTimeLeft("target") < 1.4 and jps.LastCast ~= "Spear Hand Strike" and jps.LastCast ~= "Paralysis" },

		-- CHI DUMPERS AND ROTATION FILLERS
		-- Blackout Kick as a chi dump.
		{ "Blackout Kick", chi >= 4 },
		-- Tiger Palm as a filler.
		{ "Tiger Palm" },
	}
	
	local spell,target = parseSpellTable(spellTable)
	
	return spell,target
end, "Default")
