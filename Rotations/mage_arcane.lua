--[[[
@rotation Arcane PVE Simcraft lvl 90 6.0.2
@class mage
@spec arcane
@author pcmd
@description 
SimCraft 6.0.2
]]--

if not mage then mage = {} end
mage.activeDot = "active dot";
mage.activeEnemies = "active enemies";
mage.arcaneBarrage = "arcane barrage";
mage.arcaneBlast = "arcane blast";
mage.arcaneBrilliance = "arcane brilliance";
mage.arcaneCharge = "arcane charge";
mage.arcaneExplosion = "arcane explosion";
mage.arcaneInstability = "arcane instability";
mage.arcaneMissiles = "arcane missiles";
mage.arcaneMissilesBuff = "arcane missiles!"
mage.arcaneOrb = "arcane orb";
mage.arcanePower = "arcane power";
mage.arcaneTorrent = "arcane torrent";
mage.blazingSpeed = "blazing speed";
mage.bloodFury = "blood fury";
mage.berserking ="Berserking";
mage.blink = "blink";
mage.coldSnap = "cold snap";
mage.coneOfCold = "cone of cold";
mage.counterspell = "counterspell";
mage.crystalSequence = "crystal sequence";
mage.currentTarget = "current target";
mage.danger = "danger";
mage.evocation = "evocation";
mage.executeTime = "execute time";
mage.iceFloes = "ice floes";
mage.mirrorImage = "mirror image";
mage.netherTempest = "nether tempest";
mage.overpowered = "overpowered";
mage.presenceOfMind = "presence of mind";
mage.prismaticCrystal = "prismatic crystal";
mage.rechargeTime = "recharge time";
mage.runeOfPower = "rune of power";
mage.supernova = "supernova";
mage.slowFall = "slow fall";
mage.aspecOfTheFox = "Aspect of The Fox";

mage.hasRune = function()
	local hasOne,_ = GetTotemInfo(1)
	local hasSecond,_ = GetTotemInfo(2)
	if hasOne ~= false or hasSecond ~= false then 
		return true
	end
	return false
end

mage.hasCrystal = function()
	return false
end
mage.crystalTimeLeft = function()
	return 0
end

mage.shouldBurn = function()
	return jps.TimeToDie("target") < jps.mana()*0.35*UnitSpellHaste("player") or jps.cooldown(mage.evocation) <= (jps.mana()-30)*0.3*UnitSpellHaste("player") or (jps.buff(mage.arcanePower) and jps.cooldown(mage.evocation) <= (jps.mana()-30)*0.4*UnitSpellHaste("player"))
end
mage.supernovaCharges = function() 
	local cur, max = GetSpellCharges(mage.supernova)
	return cur
end
mage.targetIsCrystal = function()
	if UnitName("target") == mage.prismaticCrystal then
		return true
	end
	return false
end

mage.shouldUseCDs = function() 
	return jps.UseCDs and jps.TimeToDie("target") < 30 or (jps.debuffStacks(mage.arcaneCharge,"player")==4 and ( not jps.talentInfo(mage.prismaticCrystal) or jps.cooldown(mage.prismaticCrystal) > 15))
end

mage.spellhasteCalc = function(no)
	return UnitSpellHaste("player") * no
end
mage.canCastWhileMove = function()
	local cur, max = GetSpellCharges(mage.iceFloes)
	if cur > 0 or jps.buff(mage.aspecOfTheFox) then
		return true
	end
	return false
end
spellTable = {
	--interrupts
	{mage.counterspell, 'jps.shouldKick("target")' },

	--cds defensive
	{mage.slowFall, 'jps.fallingFor() > 1.5 and not jps.buff(mage.slowFall)' ,"player"},
	
	--cds offensive
	{mage.runeOfPower, 'IsAltKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.IsSpellKnown(mage.runeOfPower)'},
	{mage.arcaneBrilliance, 'not jps.buff(mage.arcaneBrilliance)',"player" }, 

	{"nested",'mage.shouldUseCDs() and jps.canDPS("target") and not jps.Moving',{
		{mage.coldSnap, 'not jps.buff(mage.presenceOfMind) and jps.cooldown(mage.presenceOfMind) > 75 and jps.UseCDs' },
		{mage.mirrorImage, 'jps.UseCDs' },
		{mage.arcanePower},
		{mage.bloodFury},
		{mage.berserking}
		
	}},
	
	--prepare crsytal
	{"nested","jps.cooldown(mage.prismaticCrystal) == 0", {
		{mage.prismaticCrystal, 'jps.debuffStacks(mage.arcaneCharge,"player") >= 4 and jps.cooldown(mage.arcanePower) < 0.5'},
		{mage.prismaticCrystal, 'jps.debuffStacks(mage.arcaneCharge,"player") >= 4 and jps.cooldown(mage.arcanePower) > 45 and jps.glyphInfo(62210)'},
	}},
	
	--crystal rotation
	{"nested","mage.hasCrystal()",{
		{mage.netherTempest,'jps.debuffStacks(mage.arcaneCharge,"player") >= 4 and mage.crystalTimeLeft() >8 and not jps.myDebuff(mage.netherTempest)'}
	}},
	--aoe > 5 enemies
	{"nested",'fh.UnitsAroundUnit("target", 10) >= 5 or jps.MultiTarget', {
		{mage.netherTempest,'jps.debuffStacks(mage.arcaneCharge,"player") >= 4 and jps.myDebuffDuration(mage.netherTempest) < 3.5'},
		{mage.supernova},
		{mage.arcaneBarrage, 'jps.debuffStacks(mage.arcaneCharge,"player") >= 4'},
		{mage.arcaneOrb,'jps.debuffStacks(mage.arcaneCharge,"player") >= 4'},
		{mage.coneOfCold,'jps.glyphInfo(115705)'},
		{mage.arcaneExplosion}
	}},
	
	--burn
	{"nested","mage.shouldBurn()",{
		{mage.arcaneMissiles, 'jps.buff(mage.arcaneMissiles)==3 and jps.ChannelTimeLeft("player") == 0' },
		{mage.arcaneMissiles, 'jps.buff(mage.arcaneInstability) and jps.buffDuration(mage.arcaneInstability) < jps.spellCastTime(mage.arcaneBlast) and jps.ChannelTimeLeft("player") == 0' },
		{mage.supernova, 'jps.TimeToDie("target") < 8 or mage.supernovaCharges()==2 ' },
		{mage.netherTempest,'jps.debuffStacks(mage.arcaneCharge,"player") >= 4 and jps.myDebuffDuration(mage.netherTempest) < 3.5'},
		{mage.arcaneOrb, 'jps.buffStacks(arcaneCharge) < 4' },
		{mage.supernova, 'mage.targetIsCrystal()' },
		{mage.presenceOfMind, 'jps.mana() > 0.96 and not jps.Moving' },
		{mage.arcaneBlast, 'jps.buffStacks(arcaneCharge)>=4 and jps.mana() > 0.93' },
		{mage.arcaneMissiles, 'jps.buffStacks(arcaneCharge)>=4 and jps.ChannelTimeLeft("player") == 0' },
		{mage.supernova, 'jps.mana() < 0.96' },
		
		--{callactionlist,mage.name==mage.conserve, 'jps.cooldown(mage.evocation)-jps.cooldown(mage.evocation) < 5 ' },
		{mage.evocation,'jps.TimeToDie("target") > 10 and jps.mana() < 0.50 ' },
		{mage.presenceOfMind, 'not jps.Moving' },
		{mage.arcaneBlast, 'not jps.Moving or mage.canCastWhileMove()' },
	}},
	--low mana
	{mage.arcaneMissiles, 'jps.buff(mage.arcaneMissiles)==3 or (jps.talentInfo(mage.overpowered) and jps.buff(mage.arcanePower) and jps.buffDuration(mage.arcanePower) < jps.spellCastTime(mage.arcaneBlast)) and jps.ChannelTimeLeft("player") == 0' },
	{mage.arcaneMissiles, 'jps.buff(mage.arcaneInstability) and jps.buffDuration(mage.arcaneInstability) < jps.spellCastTime(mage.arcaneBlast) and jps.ChannelTimeLeft("player") == 0' },
	{mage.netherTempest,'jps.debuffStacks(mage.arcaneCharge,"player") >= 4 and jps.myDebuffDuration(mage.netherTempest) < 3.5'},
	{mage.supernova, 'jps.TimeToDie("target") < 8' },
	{mage.supernova, 'jps.buff(mage.arcanePower) and not mage.hasCrystal() and mage.supernovaCharges() == 2' },
	{mage.arcaneOrb, 'jps.debuffStacks(mage.arcaneCharge,"player") < 2' },
	{mage.presenceOfMind, 'jps.mana() > 0.96  and not jps.Moving' },
	{mage.arcaneBlast, 'jps.debuffStacks(mage.arcaneCharge,"player")==4 and jps.mana() > 0.93' },
	{mage.arcaneMissiles, 'jps.debuffStacks(mage.arcaneCharge,"player")==4 and not jps.talentInfo(mage.overpowered) and jps.ChannelTimeLeft("player") == 0'},
	{mage.arcaneMissiles, 'jps.debuffStacks(mage.arcaneCharge,"player")==4 and jps.cooldown(mage.arcanePower) > mage.spellhasteCalc(10) and jps.ChannelTimeLeft("player") == 0' },
	{mage.supernova, 'jps.mana() < 0.96 and jps.buffStacks(mage.arcaneMissilesBuff) < 2 and jps.buff(mage.arcanePower) ' },
	{mage.supernova, 'jps.mana() < 0.96 and jps.debuffStacks(mage.arcaneCharge,"player")==4 and jps.buff(mage.arcanePower) ' },
	{mage.arcaneBarrage, 'jps.debuffStacks(mage.arcaneCharge,"player")==4' },
	{mage.presenceOfMind, 'jps.debuffStacks(mage.arcaneCharge,"player") < 2  and not jps.Moving' },
	{mage.arcaneBlast, 'not jps.Moving or mage.canCastWhileMove()' },
	{mage.arcaneBarrage,'jps.Moving'},
}

jps.registerRotation("MAGE","ARCANE",function() 

	return parseStaticSpellTable(spellTable)
end,"Arcane Simcraft 6.0.2 90")



spellTableOOC = {
	--cds defensive
	{mage.slowFall, 'jps.fallingFor() > 1.5 and not jps.buff(mage.slowFall)' ,"player"},
	--cds offensive
	{mage.runeOfPower, 'IsAltKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.IsSpellKnown(mage.runeOfPower)'}, 
	{mage.arcaneBrilliance, 'not jps.buff(mage.arcaneBrilliance)' },
}
jps.registerRotation("MAGE","ARCANE",function() 

	return parseStaticSpellTable(spellTableOOC)
end,"Arcane Simcraft 6.0.2 90",false,false,nil,true)

