if not mage then mage = {} end

mage.pyroblast = "Pyroblast"
mage.infenroBlast = "Inferno Blast"
mage.fireball = "Fireball"
mage.scorch =  "Scorch"
mage.meteor =  "Meteor"
mage.livingBomb = "Living Bomb"
mage.dragonsBreath = "Dragon's Breath"
mage.flamestrike = "Flamestrike"
mage.coldSnap =  "Cold Snap"
mage.combustion = "Combustion"
mage.ignite =  "Ignite"
mage.potentFlames ="Potent Flames"
mage.pyromaniac = "Pyromaniac"
mage.heatingUp  = "Heating Up"
mage.incanters = "Incanter's Flow"
mage.slowFall = "Slow Fall"
mage.iceBarrier = "Ice Barrier"
mage.runeOfPower = "Rune of Power"
mage.mirrorImage = "Mirror Image"
mage.arcaneBrilliance = "Arcane Brilliance"
mage.glyphCombustion = "Combustion"
mage.incantersFlow = "Incanter's Flow"
mage.lifeblood = "Lifeblood"
mage.pyroblastBuff = "Pyroblast!"


mage.spellInFlight = nil
mage.IsSpellInFlight = function(spell)
	if spell == mage.spellInFlight then
		return true
	end
	return false
end

jps.registerEvent("UNIT_SPELLCAST_SUCCEEDED", function(...)
		local unitID = select(1,...)
		local spellname = select(2,...)
		if unitID == "player" then
			mage.spellInFlight = spellname
		end
end)

mage.lastCast = nil
function spellFlightStop(...) 
	local spellname =  select(13,...)
	if sourceName == UnitName("player") and spellname == mage.spellInFlight then
		mage.lastCast = sourceName
		mage.spellInFlight = nil
	end
end
jps.registerEvent("COMBAT_LOG_EVENT_UNFILTERED", spellFlightStop)


mage.gotTalent = function(talent) return false end
mage.hasGlyph = function(glyph) 
	return false--glyphInfo(glyph)
end

mage.unitIsCrystal = function(unit)
	if UnitName(unit) == mage.prismaticCrystalName then return true end
	return false
end

mage.incantersLastBuffstacks = 0
mage.incantersIsGrowing = false
mage.gotIncantersBuff = function(percentage)
	local buffStacks = jps.buffStacks(mage.incantersFlow) or 0
	if buffStacks > mage.incantersLastBuffstacks then 
		mage.incantersIsGrowing = true
	elseif buffstacks < mage.incantersLastBuffstacks then
		mage.incantersIsGrowing = false
	end
		mage.incantersLastBuffstacks = buffStacks 
	return (mage.incantersLastBuffstacks * 4) >= percentage
end

mage.incantersBuffIsGrowing = function()
	return mage.incantersIsGrowing
end

mage.targetsInRangeForAOE = function(numberOfTargets, range)
--	if FireHack then
		--return UnitsAroundUnit("target",range) >= numberOfTargets
--	else
		if jps.MultiTarget then return true end
	--end
	return false
end

function mage.hasTwoRunes()
	local hasOne,_ = GetTotemInfo(1)
	local hasSecond,_ = GetTotemInfo(2)
	return hasOne and hasSecond
end

function mage.gotProc(min)
	local power = 0
	local id = 0;
	
	if jps.buff(126577) then power = power +1; id = 126577; end  --Inner Brilliance, int
	if jps.buff(138703) then power = power +1; id = 138703; end  --Acceleration, haste
	if jps.buff(139133) then power = power +1; id = 139133; end  --Mastermind, int
	if jps.buff(125487) then power = power +1; id = 125487; end 	--Lightweave, int
	if jps.bloodlusting() then power = power +1; id = 40; end 
	if jps.buff(105702) then power = power +2; id = 105702; end  --potion of jade serpent
	if jps.buff(128985) then power = power +1; id = 128985; end 	--Blessing of the Celestials, int
	if jps.buff(104423) then power = power +1; id = 104423; end 	--Windsong, haste
	if jps.buff(104993) then power = power +0.5; id = 104993; end --Jade Spirit, int
	if jps.buff(126659) then power = power +1; id = 126659; end --Quickened Tongues,haste
	if jps.buff(138786) then power = power +1; id = 138786; end --Wushoolay's Lightning,  int
	if jps.buff(138788) then power = power +1; id = 138788; end --Electrified, int
	if jps.debuff(138002) then power = power +1; id = 138002; end  --fluidity jinrokh, dmg
	if jps.buff(112879) then power = power +1; id = 112879; end  -- primal nutriment jikun, dmg
	if jps.buff(138963) then power = power +1; id = 138963; end  --Perfect Aim, 1005 crit
	--t16

	if jps.buff(146046) then power = power +1; id = 146046; end  -- expanded mind, immerseus trinket, int
	if jps.buff(148906) then power = power +1; id = 148906; end  -- toxic power, shamans trinket, int
	if jps.buff(146184) then power = power +1; id = 146184; end  -- garrosh trinket, int
	if jps.buff(148897) then power = power +1; id = 148897; end  -- malkorok trinket int

	if power >= min then return true end
	return false
	
end 

mage.highestIgnite = 0
mage.lowestIgnite = 0
mage.currentIgnite = 0
function mage.shouldCombustion()
	if jps.cooldown(mage.combustion) > 15 then return false end
	if mage.lastCast == mage.infernoBlast or mage.lastCast == mage.pyroblast then
		if mage.gotProc(3) == true then
			return true
		end
	end
	return false
end
local spellTable = {
	--buffs
	{mage.slowFall, 'IsFalling()==1 and not jps.buff("slow fall")' },
	{mage.arcaneBrilliance, 'not jps.buff("arcane brilliance")' }, 
	{mage.iceBarrier, 'not jps.buff("ice barrier")' }, 
	{mage.runeOfPower, 'mage.hasTwoRunes() and IsAltKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.IsSpellKnown("Rune of Power")'}, 
	
	--cds
	{mage.mirrorImage,'jps.UseCDs'}, 
	{jps.getDPSRacial(), 'jps.UseCDs' },
	{mage.lifeblood, 'jps.UseCDs' },
	{jps.useTrinket(0), 'jps.UseCDs' },
	{jps.useTrinket(1), 'jps.UseCDs' },	
	
	
	--aoe
	{mage.meteor, 'IsShiftKeyDown() and mage.targetsInRangeForAOE(5,8) and mage.hasGlyph(mage.glyphCombustion) and mage.gotTalent(mage.incanters) and mage.gotIncantersBuff(16) and jps.cooldown(mage.combustion) <= 7'},
	{"nested",'mage.targetsInRangeForAOE(3,10)', {
		{mage.livingBomb, 'not mage.unitIsCrystal("target") and not jps.myDebuff(mage.livingBomb,"target") and mage.incantersBuffIsGrowing() == true',"target"},
		{mage.livingBomb, 'not mage.unitIsCrystal("mouseover") and not jps.myDebuff(mage.livingBomb,"mouseover") and mage.gotIncantersBuff(4) and mage.incantersBuffIsGrowing() == true',"mouseover"},
	}},
	
	{"nested","jps.MultiTarget",{
		{mage.pyroblast, 'jps.buff(mage.pyroblastBuff) or jps.buff(mage.pyromaniac)' },
		{mage.pyroblast, 'not jps.myDebuff(mage.pyroblast)' },
		{mage.coldSnap, 'jps.glyphInfo(mage.dragonsBreath) and jps.cooldown(mage.dragonsBreath) == 0' },
		{mage.dragonsBreath, 'jps.glyphInfo(mage.dragonsBreath)' },
		{mage.flamestrike, 'jps.Mana() > 0.10 and remains	 < 2.4' },
	}},
	
	{"nested","not jps.MultiTarget",{
		--single
		{mage.combustion, 'mage.shouldCombustion()'},
		{mage.infernoBlast, 'jps.myDebuff(mage.combustion) and not jps.myDebuff(mage.combustion,"mouseover") and mage.targetsInRangeForAOE(2,8)'},
		{mage.infernoBlast, 'jps.myDebuff(mage.livingBomb) and not jps.myDebuff(mage.livingBomb,"mouseover") and mage.targetsInRangeForAOE(2,8)'},
		{mage.pyroblast, 'jps.buff(mage.pyroblastBuff) and jps.buff(mage.heatingUp)' },
		{mage.pyroblast, 'jps.buff(mage.pyromaniac)'},
		{mage.pyroblast, 'jps.buff(mage.pyroblastBuff) and jps.buff(mage.heatingUp) and mage.IsSpellInFlight(mage.fireball)' },
	
		{mage.infernoBlast, 'not jps.buff(mage.pyroblastBuff) and jps.buff(mage.heatingUp)' },
		{mage.infernoBlast, 'jps.buff(mage.pyroblastBuff) and not jps.buff(mage.heatingUp) and mage.IsSpellInFlight(mage.fireball)' },
		--{mage.infernoBlast, 'not jps.buff(mage.pyroblastBuff) and jps.buff(mage.heatingUp)' },
		{mage.fireball, 'not jps.Moving' },
		
	}},
	{mage.scorch,'jps.Moving' },
	
	--{mage.blast_wave, 'mage.gotIncantersBuff(16) and not !talent.prismatic_crystal.enabled|(charges=1&cooldown.prismatic_crystal.remains>recharge_time)|charges=2|current_target=prismatic_crystal)

}

jps.registerRotation("MAGE","FIRE",function() 

	return parseStaticSpellTable(spellTable)
end,"Fire 6.0.2 90")
