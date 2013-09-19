jps.registerRotation("MONK","MISTWEAVER",function()
	-- Healer
	local me = "player"
	local chi = UnitPower(me, 12)
	
	-- Tank is focus.
	local tank = jps.findMeATank()
	local tankHP = jps.hp(tank)
	
	-- Set the heal target to the lowest partymember.
	local healTarget = jps.LowestInRaidStatus()
	
	-- If the tank really needs healing, make him the heal target.
	if jps.canHeal(tank) and tankHP <= .5 then
		healTarget = tank
	end
	
	-- If I really need healing, make me the heal target.
	if jps.hp(me) < .4 then
		healTarget = me
	end
	
	-- Get the health of our heal target.
	local healTargetHP = jps.hp(healTarget)
	
	-- Check for an active defensive CD.
	local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")
	
	local channeling = UnitChannelInfo("player")
	local soothing = false
	local crackling = false
	if channeling and channeling == "Soothing Mist" then
		soothing = true
	else
		crackling = true
	end
	
	refreshTiger = ( not jps.buff("Tiger Power") or jps.buffDuration("Tiger Power") < 2 )
	 
	refreshSerpent = ( not jps.buff("Serpent's Zeal") or jps.buffStacks("Serpent's Zeal") < 2 or jps.buffDuration("Serpent's Zeal") < 5 )

	 -- Check if we should detox
	local dispelTarget = jps.FindMeDispelTarget({"Magic"}, {"Poison"}, {"Disease"})
	
	local spellTable = {
		{ "Summon Jade Serpent Statue", IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		{ "Healing Sphere", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		-- Fortifying Brew if you get low. 
		{ "Fortifying Brew", jps.UseCDs and jps.hp() < .4 and not defensiveCDActive },
		
		-- Diffuse Magic if you get low. (talent based) 
		{ "Diffuse Magic", jps.UseCDs and jps.hp() < .5 and not defensiveCDActive },
		
		-- Dampen Harm if you get low. (talent based) 
		{ "Dampen Harm", jps.UseCDs and jps.hp() < .6 and not defensiveCDActive },
		
		-- Healthstone if you get low. 
		{ "Healthstone", jps.hp() < .5 and GetItemCount("Healthstone", 0, 1) > 0 },
		
		-- Insta-kill single target when available 
		{ "Touch of Death", jps.UseCDs and jps.buff("Death Note") },
		
		-- Thunder Focus Tea on CD 
		{ "Thunder Focus Tea", jps.UseCDs and tankHP < .6 },
		
		-- Life Cocoon on the tank if he's low. 
		{ "Life Cocoon", tankHP < .4, tank },
		
		-- Detox if needed. 
		{ "Detox", dispelTarget ~= nil, dispelTarget },
		
		-- Water Spirit if you get low on mana. 
		{ "Water Spirit", jps.UseCDs and jps.mana() < .6 and GetItemCount("Water Spirit", 0, 1) > 0 },
		
		-- Engineers may have synapse springs on their gloves (slot 10). 
		{ jps.useSynapseSprings(), jps.useSynapseSprings() ~= "" and jps.UseCDs and healTargetHP < .7 },
		
		-- On-Use Trinkets. 
		{ jps.useTrinket(0), jps.UseCDs and healTargetHP < .7 },
		
		
		{ jps.useTrinket(1), jps.UseCDs and healTargetHP < .7 },
		
		-- Lifeblood (requires herbalism) 
		{ "Lifeblood", jps.UseCDs 	and healTargetHP < .7 },
		
		-- Invoke Xuen CD. (talent based) 
		{ "Invoke Xuen, the White Tiger", jps.UseCDs and healTargetHP < .55 },
		
		-- Mana Tea when we have 2 stacks. 
		{ "Mana Tea", jps.mana() < .9 and jps.buffStacks("Mana Tea") >= 2 },
		
		-- Surging Mist w/ Vital for moderate damage. 
		{ "Surging Mist", jps.buffStacks("Vital Mists") == 5 and healTargetHP < .7, healTarget },
		
		-- Uplift when someone with Renewing Mist is taking moderate damage. 
		{ "Uplift", healTargetHP < .75 and jps.buff("Renewing Mist", healTarget), healTarget },
		
		-- Renewing Mist when someone is taking mild damage who doesn't already have it. 
		{ "Renewing Mist", healTargetHP < .95 and not jps.buff("Renewing Mist", healTarget), healTarget },
		
		-- Expel Harm for cheap Chi when we've taken damage. 
		{ "Expel Harm", jps.hp() < .99 and chi < 4 },
		
		-- Zen Sphere on the tank. (talent based) 
		{ "Zen Sphere", tankHP < .85 and not jps.buff("Zen Sphere", tank), tank },
		
		-- Chi Burst on the tank. (talent based) 
		{ "Chi Burst", tankHP < .85, tank },
		
		-- Maintain Tiger Power 
		{ "Tiger Palm", refreshTiger and IsSpellInRange("Tiger Palm", "target") },
		
		-- Maintain Serpent's Zeal 
		{ "Blackout Kick", refreshSerpent and IsSpellInRange("Blackout Kick", "target") },
		
		-- Spinning Crane Kick for Chi when MultiTarget is enabled. 
		{ "Spinning Crane Kick", jps.MultiTarget and jps.mana() > .85 and chi < 4 and IsSpellInRange("Jab", "target") },
		
		-- Chi Wave when we're in melee range. (talent based) 
		{ "Chi Wave", healTargetHP < .85 and IsSpellInRange("Jab", "target") },
		
		-- Soothing Mist as filler if someone will be healed. 
		{ "Soothing Mist", not soothing and not jps.Moving and healTargetHP < .9, healTarget },
		
		-- Surging Mist for heavy damage. 
		{ "Surging Mist", not jps.Moving and healTargetHP < .3, healTarget },
		
		-- Enveloping Mist for moderate damage. 
		{ "Enveloping Mist", not jps.Moving and healTargetHP < .65, healTarget },
		
		-- Jab to cap our chi if we don't have tiger power to serpent's zeal up already. 
		{ "Jab", not soothing and IsSpellInRange("Jab", "target") and chi < 3 and refreshTiger and refreshSerpent },
		
		-- Tiger Palm as a chi dump only if someone will be healed. 
		{ "Tiger Palm", healTargetHP < .85 and chi > 2 and IsSpellInRange("Tiger Palm", "target") and not soothing },
		
		-- Make sure we're auto attacking if nothing else. 
		{ { "macro", "/startattack" }, not soothing, defaultTarget },
	
	}
	
	local spell, target = parseSpellTable(spellTable)
	
	-- Debug
	if IsAltKeyDown() ~= nil and spell then
		print( string.format("Healing: %s, Health: %s, Spell: %s", healTarget, healTargetHP, spell) )
	end
	
	return spell, target

end, "Default")

