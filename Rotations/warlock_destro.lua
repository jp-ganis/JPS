local spellTable = {
	-- Interrupts
	wl.getInterruptSpell("target"),
	wl.getInterruptSpell("focus"),
	wl.getInterruptSpell("mouseover"),

	-- Def CD's
	{wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
	{wl.spells.createHealthstone, 'jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= wl.spells.createHealthstone'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{wl.spells.emberTap, 'jps.Defensive and jps.hp() <= 0.30 and jps.burningEmbers() > 0' },

	-- Soulstone
	wl.soulStone("target"),

	-- Rain of Fire
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1 and not GetCurrentKeyBoardFocus()'	},
	{wl.spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },

	{wl.spells.shadowfury, 'IsShiftKeyDown() and IsAltKeyDown() and not GetCurrentKeyBoardFocus()' },-- Shadowfury


	-- COE Debuff
	{wl.spells.curseOfTheElements, 'not jps.debuff(wl.spells.curseOfTheElements) and not wl.isTrivial("target") and not wl.isCotEBlacklisted("target")' },
	{wl.spells.curseOfTheElements, 'wl.attackFocus() and not jps.debuff(wl.spells.curseOfTheElements, "focus") and not wl.isTrivial("focus") and not wl.isCotEBlacklisted("focus")' , "focus" },

	{wl.spells.fireAndBrimstone, 'jps.burningEmbers() > 0 and not jps.buff(wl.spells.fireAndBrimstone, "player") and jps.MultiTarget and not jps.isRecast(wl.spells.fireAndBrimstone, "target")' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.burningEmbers() == 0' },
	{ {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },

	-- On the move
	{wl.spells.felFlame, 'jps.Moving and not wl.hasKilJaedensCunning()' },

	-- CD's
	{ {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and not jps.buff(wl.spells.darkSoulInstability) and jps.UseCDs' },
	{ jps.getDPSRacial(), 'jps.UseCDs' },
	{wl.spells.lifeblood, 'jps.UseCDs' },
	{ jps.useSynapseSprings() , 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
	{ jps.useTrinket(0),	   'jps.UseCDs' },
	{ jps.useTrinket(1),	   'jps.UseCDs' },

	-- Shadowburn mouseover!
	{wl.spells.shadowburn, 'jps.hp("mouseover") < 0.20 and jps.burningEmbers() > 0 and jps.myDebuffDuration(wl.spells.shadowburn, "mouseover")<=0.5', "mouseover"  },

	{"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
		{wl.spells.havoc, 'not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
		{wl.spells.havoc, 'not jps.Moving and wl.attackFocus()', "focus" },
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.burningEmbers() > 0 and	jps.buffStacks(wl.spells.havoc)>=3'},
		{"nested", 'not jps.Moving', {
			jps.dotTracker.castTableStatic("immolate"),
		}},
		{wl.spells.conflagrate },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.buff(wl.spells.darkSoulInstability) and jps.emberShards() >= 19' },
		{wl.spells.chaosBolt, 'not jps.Moving and jps.TimeToDie("target", 0.2) > 5.0 and jps.burningEmbers() >= 3 and jps.buffStacks(wl.spells.backdraft) < 3'},
		{wl.spells.chaosBolt, 'not jps.Moving and jps.emberShards() >= 35'},
		{wl.spells.incinerate },
	}},

	{"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.conflagrate },
		{wl.spells.felFlame },
	}},
	{"nested", 'jps.MultiTarget', {
		{wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
		{wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and jps.LastCast ~= wl.spells.immolate'},
		{wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player")' },
		{wl.spells.incinerate },
	}},
}


--[[[
@rotation Destruction 5.4
@class warlock
@spec destruction
@talents Vb!112101!ZbS
@author Kirk24788
@description
This is a Raid-Rotation, which will do fine on normal mobs, even while leveling but might not be optimal for PvP.
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Cast Rain of Fire @ Mouse - [b]ONLY[/b] if RoF Duration is less than 1 seconds[br]
[*] [code]CTRL-SHIFT[/code]: Cast Rain of Fire @ Mouse - ignoring the current RoF duration[br]
[*] [code]ALT-SHIFT[/code]: Cast Shadowfury @ Mouse[br]
[*] [code]CTRL[/code]: If target is dead or ghost cast Soulstone, else cast Havoc @ Mouse[br]
[*] [code]ALT[/code]: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)[br]
[*] [code]jps.Interrupts[/code]: Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)[br]
[*] [code]jps.Defensive[/code]: Create Healthstone if necessary, cast mortal coil and use ember tap[br]
[*] [code]jps.UseCDs[/code]: Use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated![br]
]]--
jps.registerRotation("WARLOCK","DESTRUCTION",function()
	wl.deactivateBurningRushIfNotMoving(1)

	if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
		SpellStopCasting()
		jps.NextSpell = nil
	end

	return parseStaticSpellTable(spellTable)
end,"Destruction 5.3")

jps.registerEvent("PLAYER_ENTERING_WORLD", function()
mConfig:createConfig("Rotation Config WL","Warlock Destruction", "Default" ,{"/wl"})
	mconfig_VARIABLES_LOADED()
	mConfig:addSlider("darkSoulThreshold", "Dark Soul Threshold","Number of Ember Shards at which to cast Last Dark Soul (Only important with Talent Archimonde's Darkness!)", 10, 40, 35, 1)
	mConfig:addSlider("shadowBurnThreshold", "Shadow Burn Threshold","Number of Ember Shards at which to cast Shadow Burn", 10, 40, 35, 1)
	mConfig:addSlider("shadowBurnThresholdEmpowered", "Shadow Burn Threshold (Empowered)","Number of Ember Shards at which to cast Shadow Burn, when a strong Proc is present", 10, 40, 10, 1)
	mConfig:addSlider("chaosBoltThreshold", "Chaos Bolt Threshold","Number of Ember Shards at which to cast Chaos Bolt", 10, 40, 35, 1)
	mConfig:addSlider("chaosBoltThresholdEmpowered", "Chaos Bolt Threshold (Empowered)","Number of Ember Shards at which to cast Chaos Bolt, when a strong Proc is present", 10, 40, 10, 1)
	mConfig:addSlider("mortalCoilPercentage", "Mortal Coil %","Percentage at which to use mortal coil, if available", 0, 100, 80, 1)
	mConfig:addSlider("healthStonePercentage", "Health Stone %","Percentage at which to use health stones", 0, 100, 65, 1)
	mConfig:addSlider("emberTapPercentage", "Ember Tap %","Percentage at which to use ember tap", 0, 100, 30, 1)
	mConfig:addSlider("felFlameMinMana", "Fel Flame Mana","Minimum Mana needed before Fel Flames are casted", 0, 100, 50, 1)
	mConfig:addSlider("autoDeactivateBurningRush", "Burning Rush Auto-Deactivation","Number of seconds until Burning Rush is deactivated if not moving", 0, 2, 1, 0.1)
	mConfig:addDropDown("altKeyAction", "Alt-Key Action", "Action to do when Alt-Key is pressed", {SHADOWFURY="Shadowfury", STOPCASTING="Stop Casting", BANISHTARGET="Banish Target", BANISHMOUSEOVER="Banish Mouseover"}, "SHADOWFURY")
end)
function wl.altKeyAction(name)
    return IsAltKeyDown() and not GetCurrentKeyBoardFocus() and wl.get("altKeyAction")==name
end


function wl.hasArchimondesDarkness()
    local selected, talentIndex = GetTalentRowSelectionInfo(6)
    return talentIndex == 16
end

function wl.get(name)
    return mConfig:get(name)
end
function wl.getPercent(name)
    return mConfig:get(name)/100
end

wl.shadowBurnTable = {"nested", 'jps.hp("target") <= 0.20', {
    {wl.spells.shadowburn, 'jps.buffStacks(wl.spells.havoc)>=1 and jps.burningEmbers() > 0' },
    {wl.spells.shadowburn, 'jps.emberShards() > wl.get("shadowBurnThreshold")' },
    {wl.spells.shadowburn, 'jps.buff(wl.spells.darkSoulInstability) and jps.burningEmbers() > 0' },
    {wl.spells.shadowburn, 'jps.buff("Synapse Springs") and jps.emberShards() > wl.get("shadowBurnThresholdEmpowered")' },
    {wl.spells.shadowburn, 'jps.mana() < 0.20'  },
    {wl.spells.shadowburn, 'jps.TimeToDie("target") <= 20'  },
}}

local spellTable = {
    -- Interrupts
    wl.getInterruptSpell("target"),
    wl.getInterruptSpell("focus"),
    wl.getInterruptSpell("mouseover"),

    -- Def CD's
    {wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= wl.getPercent("mortalCoilPercentage")' },
    {wl.spells.createHealthstone, 'jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= wl.spells.createHealthstone'},
    {jps.useBagItem(5512), 'jps.hp("player") < wl.getPercent("healthStonePercentage")' }, -- Healthstone
    {wl.spells.emberTap, 'jps.Defensive and jps.hp() <= wl.getPercent("emberTapPercentage") and jps.burningEmbers() > 0' },

    -- Soulstone
    wl.soulStone("target"),

    -- Rain of Fire
    {wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1 and not GetCurrentKeyBoardFocus()'  },
    {wl.spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },
    
    -- Alt Key
    {wl.spells.shadowfury, 'wl.altKeyAction("SHADOWFURY")' },-- Shadowfury
    {wl.spells.banish, 'wl.altKeyAction("BANISHTARGET")' },-- Banish
    {wl.spells.banish, 'wl.altKeyAction("BANISHMOUSEOVER")', "mouseover"},-- Banish Mouseover
    
    
    -- COE Debuff
    {wl.spells.curseOfTheElements, 'not jps.debuff(wl.spells.curseOfTheElements) and not wl.isTrivial("target") and not wl.isCotEBlacklisted("target")' },
    {wl.spells.curseOfTheElements, 'wl.attackFocus() and not jps.debuff(wl.spells.curseOfTheElements, "focus") and not wl.isTrivial("focus") and not wl.isCotEBlacklisted("focus")' , "focus" },
    
    {wl.spells.fireAndBrimstone, 'jps.burningEmbers() > 0 and not jps.buff(wl.spells.fireAndBrimstone, "player") and jps.MultiTarget and not jps.isRecast(wl.spells.fireAndBrimstone, "target")' },
    { {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.burningEmbers() == 0' },
    { {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },
    
    -- CD's
    { jps.getDPSRacial(), 'jps.UseCDs' },
    {wl.spells.lifeblood, 'jps.UseCDs' },
    --{ {"macro","/use 10"}, 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
    { jps.useSynapseSprings, 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
    { jps.useTrinket(0),       'jps.UseCDs' },
    { jps.useTrinket(1),       'jps.UseCDs' },
    
    -- Dark Soul
    {"nested", 'not wl.hasArchimondesDarkness()', {
        { {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and jps.UseCDs' },   
    }},
    {"nested", 'wl.hasArchimondesDarkness()', {
        { {"macro","/cast " .. wl.spells.darkSoulInstability}, 'GetSpellCharges(wl.spells.darkSoulInstability) == 2 and not jps.buff(wl.spells.darkSoulInstability) and jps.UseCDs' },
        { {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and not jps.buff(wl.spells.darkSoulInstability) and jps.UseCDs and jps.emberShards() > wl.get("darkSoulThreshold")' },
    }},
    
    -- Shadowburn mouseover!
    {wl.spells.shadowburn, 'jps.hp("mouseover") < 0.20 and jps.burningEmbers() > 0 and jps.myDebuffDuration(wl.spells.shadowburn, "mouseover")<=0.5', "mouseover"  },

    -- Single Target
    {"nested", 'not jps.MultiTarget', {
        -- Non-Moving
        {"nested", 'not wl.altKeyAction("STOPCASTING") and not jps.Moving', {
            {wl.spells.havoc, 'not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
            {wl.spells.havoc, 'not jps.Moving and wl.attackFocus()', "focus" },
            wl.shadowBurnTable,
            {wl.spells.chaosBolt, 'not jps.Moving and jps.burningEmbers() > 0 and jps.buffStacks(wl.spells.havoc)>=3'},
            jps.dotTracker.castTableStatic("immolate"),
            {wl.spells.conflagrate, 'GetSpellCharges(wl.spells.conflagrate) >= 2' },
            
            {wl.spells.chaosBolt, 'jps.TimeToDie("target", 0.2) > 5.0 and jps.emberShards() > wl.get("chaosBoltThreshold")' },
            {wl.spells.chaosBolt, 'jps.buff("Skull Banner") and jps.buffDuration("Skull Banner") > 3 and jps.emberShards() > wl.get("chaosBoltThresholdEmpowered")' },
            {wl.spells.chaosBolt, 'jps.buff("Synapse Springs") and jps.buffDuration("Synapse Springs") > 3 and jps.emberShards() > wl.get("chaosBoltThresholdEmpowered")' },
            {wl.spells.chaosBolt, 'jps.buff(wl.spells.darkSoulInstability) and jps.buffDuration(wl.spells.darkSoulInstability) > 3 and jps.burningEmbers() > 0' },
            
            {wl.spells.conflagrate, 'GetSpellCharges(wl.spells.conflagrate) >= 1' },
            {wl.spells.incinerate},            
        }},
        
        -- Moving
        {"nested", 'not wl.altKeyAction("STOPCASTING") and jps.Moving', {
            wl.shadowBurnTable,
            {wl.spells.incinerate, 'jps.buff("Backlash")'},
            {wl.spells.incinerate, 'wl.hasKilJaedensCunning()'},
            {wl.spells.conflagrate},
            {wl.spells.felFlame, 'jps.mana() > wl.getPercent("felFlameMinMana")' },
        }},
        
        -- Stop-Casting, if selected
        {"nested", 'wl.altKeyAction("STOPCASTING")', {
            wl.shadowBurnTable,
            {wl.spells.incinerate, 'jps.buff("Backlash")'},
            {wl.spells.conflagrate},
            {wl.spells.felFlame, 'jps.mana() > wl.getPercent("felFlameMinMana")' },
        }},
    }},

    {"nested", 'jps.MultiTarget', {
        {wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
        {wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and jps.LastCast ~= wl.spells.immolate'},
        {wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player")' },
        {wl.spells.incinerate, 'not jps.Moving or wl.hasKilJaedensCunning() or jps.buff("Backlash")' },
    }},
}
	
jps.registerRotation("WARLOCK","DESTRUCTION",function()
    wl.deactivateBurningRushIfNotMoving(wl.get("autoDeactivateBurningRush"))

    if wl.altKeyAction("STOPCASTING") and jps.CastTimeLeft("player") >= 0 then
        SpellStopCasting()
        jps.NextSpell = nil
    end

    return parseStaticSpellTable(spellTable)
end,"Adv. Destruction Lock")


--[[[
@rotation Interrupt Only
@class warlock
@spec destruction
@author Kirk24788
@description
This is Rotation will only take care of Interrupts. [i]Attention:[/i] [code]jps.Interrupts[/code] still has to be active!
]]--
jps.registerStaticTable("WARLOCK","DESTRUCTION",wl.interruptSpellTable,"Interrupt Only")



