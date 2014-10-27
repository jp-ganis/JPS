if not rogue then rogue = {} end
rogue.adrenalinerush = "adrenaline rush";				
rogue.anticipation = "anticipation";				
rogue.arcanetorrent = "arcane torrent";				
rogue.banditsguile = "bandits guile";				
rogue.bladeflurry = "blade flurry";				
rogue.bloodfury = "blood fury";				
rogue.bloodlust = "bloodlust";				
rogue.deepinsight = "deep insight";				
rogue.killingspree = "killing spree";				
rogue.markedfordeath = "marked for death";				
rogue.revealingstrike = "revealing strike";				
rogue.shadowfocus = "shadow focus";				
rogue.shadowreflection = "shadow reflection";				
rogue.sliceanddice = "slice and dice";				
rogue.vanish = "vanish";				
rogue.eviscerate = "Eviscerate";
rogue.cimsontempest = "Crimson Tempest";
rogue.sinisterstrike = "Sinister Strike";

rogue.cp = function()
	return GetComboPoints("player")
end
rogue.energy = function() 
	return UnitPower("player")
end
rogue.conditionsGenerator = function()
	return rogue.cp() < 5 or (jps.talentInfo(rogue.anticipation) and select(1,GetSpellCharges(rogue.anticipation)) <= 4 and not jps.buff(rogue.deepinsight))
end
rogue.conditionsFinisher = function()
	return rogue.cp() == 5 and (jps.buff(deepinsight) or not jps.talentInfo(rogue.anticipation) or (jps.talentInfo(rogue.anticipation) and select(1,GetSpellCharges(rogue.anticipation)) >= 4))
end

local spellTable = {
	{rogue.kick, 'jps.shouldKick("target")' },
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	
	{ "nested",'IsSpellInRange(rogue.revealingstrike, "target") == 1 and jps.UseCDs',{	
		{rogue.preparation, 'not jps.buff(rogue.vanish) and jps.cooldown(rogue.vanish) > 60' },
		{rogue.bloodFury},
		{rogue.berserking},
		{rogue.arcanetorrent, 'rogue.energy() < 60' },
		{rogue.vanish,'jps.combatTime()>10 and rogue.cp()<3 and jps.talentInfo(rogue.shadowfocus) and not jps.buff(adrenalinerush) and rogue.enegery()<20' },
		{rogue.shadowreflection, 'jps.buff(rogue.adrenalinerush)' },
		{rogue.shadowreflection, 'jps.cooldown(rogue.killingspree) < 10 and rogue.cp() > 3' },
		{rogue.killingspree, 'rogue.energy() < 50 and not jps.talentInfo(shadowReflection)' },
		{rogue.killingspree, 'rogue.energy() < 50 and jps.cooldown(shadowReflection) > 30' },
		{rogue.killingspree, 'rogue.energy() < 50 and jps.buffDuration(shadowReflection) > 3)' },
		{rogue.adrenalinerush, 'rogue.energy() < 35' },
	}},
	
	{{"macro", "/cancelaura "..rogue.bladeflurry}, 'not jps.MultiTarget and jps.buff(rogue.bladeflurry)' },
	{rogue.bladeflurry, 'jps.MultiTarget and not jps.buff(rogue.bladeflurry)' },

	{rogue.ambush, 'onCD' },

	{rogue.sliceanddice, 'jps.buffDuration(rogue.sliceanddice) < 2' },
	{rogue.sliceanddice, 'jps.buffDuration(rogue.sliceanddice) < 15 and jps.buffStacks(rogue.banditsguile)==11 and rogue.cp() >= 4' },
	{ "nested",'IsSpellInRange(rogue.revealingstrike, "target") == 1 and jps.UseCDs',{	
		{rogue.markedfordeath, 'rogue.cp() <= 1 and jps.myDebuff(rogue.revealingstrike) and not jps.talentInfo(rogue.shadowReflection)' },
		{rogue.markedfordeath, 'rogue.cp() <= 1 and jps.myDebuff(rogue.revealingstrike) and jps.buff(rogue.shadowReflection)' },
		{rogue.markedfordeath, 'rogue.cp() <= 1 and jps.myDebuff(rogue.revealingstrike) and jps.cooldown(rogue.shadowReflection) > 30' },
	}},
	{"nested", "rogue.conditionsGenerator() == true",{
		{rogue.revealingstrike, 'jps.myDebuffDuration(rogue.revealingstrike) < 3'},
		{rogue.sinisterstrike}
	}},
	{"nested", "rogue.conditionsFinisher() == true",{
		{rogue.cimsontempest, "jps.MultiTarget and jps.myDebuffDuration(rogue.crimsontempest) < 2"},
		{rogue.eviscerate},
	}},

}

jps.registerRotation("ROGUE","COMBAT",function()
	local spell = nil
	local target = nil
	spell,target = parseStaticSpellTable(spellTable)
	return spell,target
end, "WIP Simcraft Combat Rogue 6.0.2")




--[[[
@rotation PVE single target/PVE 2-5 targets/PVE 5+ targets
@class rogue
@spec combat
@talents c!201121!R
@author jpganis
@description 
Using the same rotation as Noxxic, talents are optional - i usually prefer elusiveness for tier 3 and anticipation for 
tier 6, if you take elusiveness use Glyph of Feint though.[br]
[br]
Usage info:[br]
[*]ToT will be cast on focus[br]
[*]Enable cooldowns to use defensive cooldown along with vanish, preparation, trinkets, and combat spec specific cooldowns (ex: Adrenaline Rush)[br]
[br]
TODO:[br]
[*]Vanish only cast if shadowstep is off cooldown[br]
]]--

jps.registerRotation("ROGUE","COMBAT",function()

local cp = GetComboPoints("player")
local rupture_duration = jps.debuffDuration("rupture")
local snd_duration = jps.buffDuration("slice and dice")
local energy = UnitPower("player")
local defensiveCDActive = jps.buff("Evasion") or jps.buff("Cloak of Shadows") or jps.buff("Smoke Bomb") or jps.buff("Shroud of Concealment")
   
       -- Spells should be ordered by priority.
       local spellTable = {
          -- Defensive Cooldowns.
              { "Recuperate", jps.hp() < .5 and not defensiveCDActive },
             
              -- TOT on focus
              { "Tricks of the Trade", jps.UseCDs , "focus" },
             
              -- Defensive Cooldown.
              { "Evasion", jps.UseCDs and jps.hp() < .35 and not defensiveCDActive },
             
              -- Defensive Cooldown.
              { "Cloak of Shadows", jps.UseCDs and jps.hp() < .25 and not defensiveCDActive },
             
              -- Defensive Cooldown.
              { "Smoke Bomb", jps.UseCDs and jps.hp() < .5 and not defensiveCDActive },
             
              -- Kick
              { "Kick", jps.shouldKick() and jps.LastCast ~= "Blind" and jps.LastCast ~= "Gouge" },
             
              -- Kick
              { "Blind", jps.shouldKick() and jps.LastCast ~= "Kick" and jps.LastCast ~= "Gouge" },
             
              -- Kick
              { "Kick", jps.shouldKick() },
             
              -- Kick
              { "Gouge", jps.shouldKick() and jps.LastCast ~= "Kick" },
             
              -- Trinket CDs.
              -- Disabled one slot (the 1st one) just so the addon won't waste a cooldown, like PvP trinkets. Most people
              -- don't even use 2 trinkets with USE effect anyways. Even if you DO use 2 trinkets with USE effect, having
              -- one trinket slot spared will even time your burst or defensive cooldowns better. Put your most used and
              -- faster, or the one you just forget most to activate at slot 2. You will thank me later.
             
              --{ jps.useSlot(13), jps.UseCDs },
             
              { jps.useSlot(14), jps.UseCDs },
             
              -- Synapse Springs CD. (engineering gloves)
              { jps.useSlot(10), jps.UseCDs },
             
              -- Preparation if vanish has more than 60 seconds left
              { "Preparation", not jps.buff("Vanish") and jps.cooldown("Vanish") > 60 and jps.UseCDs },
             
              -- Lifeblood CD. (herbalists)
              { "Lifeblood", jps.UseCDs },
             
              -- DPS Racial CD.
              { jps.DPSRacial, jps.UseCDs },
             
              -- Use Vanish
              { "Vanish", not jps.buff("Adrenaline Rush") and energy < 20 and jps.buff("Deep Insight") and cp < 4 and jps.UseCDs and jps.cooldown("Shadowstep") == 0 },
             
              -- Use Shadowstep After Vanish-Talent Specific
              { "Shadowstep", jps.LastCast == "Vanish" },
             
              -- Ambush after shadowstep
              { "Ambush", jps.UseCDs and jps.LastCast == "Shadowstep" },
             
              -- Slice and Dice
              { "Slice and Dice", snd_duration < 2 or snd_duration < 15 and jps.buffStacks("Bandits Guile") == 11 and cp >= 4 },
             
              -- Killing Spree CD
              { "Killing Spree", jps.UseCDs and energy < 35 and snd_duration > 4 and not jps.buff("Adrenaline Rush") },
             
              -- Adrenaline Rush CD
              { "Adrenaline Rush", jps.UseCDs and energy < 35 or jps.buff("Shadow's Blade") },
             
              -- Rupture/Rupture Refresh
              { "Rupture", rupture_duration < 4 and cp == 5 and jps.buff("Deep Insight") },
             
              -- eviscerate if combo point dump is needed or you dont have buff bonus for rupture
              { "Eviscerate", cp == 5 and jps.buff("Deep Insight") },
             
              -- rupture double check if you miss deep insight on time and somehow have extra combo points
              { "Rupture", rupture_duration < 4 and cp == 5 },
             
              -- Revealing Strike maintain debuff
              { "Revealing Strike", cp < 5 and not jps.debuff("Revealing Strike") },
             
              -- Sinister Strike as Cp builder
              { "Sinister Strike", cp < 5 },
           }

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end, "PVE single target", true, false)
       
jps.registerRotation("ROGUE","COMBAT",function()
       
local cp = GetComboPoints("player")
local rupture_duration = jps.debuffDuration("rupture")
local snd_duration = jps.buffDuration("slice and dice")
local energy = UnitPower("player")
local defensiveCDActive = jps.buff("Evasion") or jps.buff("Cloak of Shadows") or jps.buff("Smoke Bomb") or jps.buff("Shroud of Concealment")
       
       -- Spells should be ordered by priority.
       local spellTable = {
              -- Defensive Cooldowns.
              { "Recuperate", jps.hp() < .5 and not defensiveCDActive },
             
              -- TOT on focus
              { "Tricks of the Trade", jps.UseCDs , "focus" },
             
              -- Defensive Cooldown.
              { "Evasion", jps.UseCDs and jps.hp() < .35 and not defensiveCDActive },
             
              -- Defensive Cooldown.
              { "Cloak of Shadows", jps.UseCDs and jps.hp() < .25 and not defensiveCDActive },
             
              -- Defensive Cooldown.
              { "Smoke Bomb", jps.UseCDs and jps.hp() < .5 and not defensiveCDActive },
             
              -- Kick
              { "Kick", jps.shouldKick() and jps.LastCast ~= "Blind" and jps.LastCast ~= "Gouge" },
             
              -- Kick
              { "Blind", jps.shouldKick() and jps.LastCast ~= "Kick" and jps.LastCast ~= "Gouge" },
             
              -- Kick
              { "Kick", jps.shouldKick() },
             
              -- Kick
              { "Gouge", jps.shouldKick() and jps.LastCast ~= "Kick" },
             
              -- Trinket CDs.
              -- Disabled one slot (the 1st one) just so the addon won't waste a cooldown, like PvP trinkets. Most people
              -- don't even use 2 trinkets with USE effect anyways. Even if you DO use 2 trinkets with USE effect, having
              -- one trinket slot spared will even time your burst or defensive cooldowns better. Put your most used and
              -- faster, or the one you just forget most to activate at slot 2. You will thank me later.
             
              --{ jps.useSlot(13), jps.UseCDs },
             
              { jps.useSlot(14), jps.UseCDs },
             
              -- Synapse Springs CD. (engineering gloves)
              { jps.useSlot(10), jps.UseCDs },
             
              -- Lifeblood CD. (herbalists)
              { "Lifeblood", jps.UseCDs },
             
              -- DPS Racial CD.
              { jps.DPSRacial, jps.UseCDs },
             
              --2 to 4 target rotation
              { "Ambush" , jps.buff("Stealth") },
             
              --Start Blade Flurry
              { "Blade Flurry", not jps.buff("Blade Flurry") },
             
              -- Slice and Dice
              { "Slice and Dice", snd_duration < 2 or snd_duration < 15 and jps.buffStacks("Bandits Guile") == 11 and cp >= 4 },
             
              -- Killing Spree CD
              { "Killing Spree", energy < 35 and snd_duration > 4 and not jps.buff("Adrenaline Rush") },
             
              -- Adrenaline Rush CD
              { "Adrenaline Rush", jps.UseCDs and energy < 35 or jps.buff("Shadow's Blade") },
             
              -- eviscerate if combo point dump is needed or you dont have buff bonus for rupture
              { "Eviscerate", cp == 5 and jps.buff("Deep Insight") },
             
              -- Revealing Strike maintain debuff
              { "Revealing Strike", cp < 5 and not jps.debuff("Revealing Strike") },
             
              -- Sinister Strike as Cp builder
              { "Sinister Strike", cp < 5 },   
       }

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end, "PVE 2-5 targets", true, false)
       
jps.registerRotation("ROGUE","COMBAT",function()
       
local cp = GetComboPoints("player")
local rupture_duration = jps.debuffDuration("rupture")
local snd_duration = jps.buffDuration("slice and dice")
local energy = UnitPower("player")
local defensiveCDActive = jps.buff("Evasion") or jps.buff("Cloak of Shadows") or jps.buff("Smoke Bomb") or jps.buff("Shroud of Concealment")

       -- Spells should be ordered by priority.
       local spellTable = {
              -- Defensive Cooldowns.
              { "Recuperate", jps.hp() < .5 and not defensiveCDActive },
             
              -- TOT on focus
              { "Tricks of the Trade", jps.UseCDs , "focus" },
             
              -- Defensive Cooldown.
              { "Evasion", jps.UseCDs and jps.hp() < .35 and not defensiveCDActive },
             
              -- Defensive Cooldown.
              { "Cloak of Shadows", jps.UseCDs and jps.hp() < .25 and not defensiveCDActive },
             
              -- Defensive Cooldown.
              { "Smoke Bomb", jps.UseCDs and jps.hp() < .5 and not defensiveCDActive },
             
              -- Kick
              { "Kick", jps.shouldKick() and jps.LastCast ~= "Blind" and jps.LastCast ~= "Gouge" },
             
              -- Kick
              { "Blind", jps.shouldKick() and jps.LastCast ~= "Kick" and jps.LastCast ~= "Gouge" },
             
              -- Kick
              { "Kick", jps.shouldKick() },
             
              -- Kick
              { "Gouge", jps.shouldKick() and jps.LastCast ~= "Kick" },
             
              -- Trinket CDs.
              -- Disabled one slot (the 1st one) just so the addon won't waste a cooldown, like PvP trinkets. Most people
              -- don't even use 2 trinkets with USE effect anyways. Even if you DO use 2 trinkets with USE effect, having
              -- one trinket slot spared will even time your burst or defensive cooldowns better. Put your most used and
              -- faster, or the one you just forget most to activate at slot 2. You will thank me later.
             
              --{ jps.useSlot(13), jps.UseCDs },
             
              { jps.useSlot(14), jps.UseCDs },
             
              -- Synapse Springs CD. (engineering gloves)
              { jps.useSlot(10), jps.UseCDs },
             
              -- Lifeblood CD. (herbalists)
              { "Lifeblood", jps.UseCDs },
             
              -- DPS Racial CD.
              { jps.DPSRacial, jps.UseCDs },
             
              --Rotation 5+ targets
              { "Ambush" , jps.buff("Stealth") },
             
              -- Blade Flurry only for killing machine
              { "Blade Flurry", not jps.buff("Blade Flurry") and jps.cooldown("Killing Spree") == 0 },
             
              -- Killing Spree CD
              { "Killing Spree", energy < 35 and snd_duration > 4 and jps.buff("Blade Flurry") },
             
              -- --cancel blade flurry after killing spree
              {{"macro", "/cancelaura blade flurry"}, not jps.buff("Killing Spree") and jps.cooldown("Killing Spree") > 0 },
             
              --use Fan of Knives till 5 cp
              { "Fan of Knives", cp < 5 },
             
              -- Crimson Tempest at 5 cp
              { "Crimson Tempest", cp == 5 },  
		}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end, "PVE 5+ targets", true, false)
