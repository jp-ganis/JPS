
if not druid then druid = {} end
if not druid.spells then druid.spells = {} end
druid.spells.arcaneTorrent = "arcane torrent";	      
druid.spells.berserk = "berserk";	    
druid.spells.berserking = "Berserking";  
druid.spells.bloodFury = "blood fury";	      
	      
druid.spells.dreamOfCenarius = "Dream of Cenarius";	      
druid.spells.faerieFire = "faerie fire";	      
druid.spells.feralRage = "feral rage";	      
druid.spells.ferociousBite = "ferocious bite";	      
druid.spells.forNext = "for next";	      
druid.spells.forceOfNature = "force of nature";	      
druid.spells.healingTouch = "healing touch";	      
druid.spells.name = "name";	      
druid.spells.omenOfClarity = "omen of clarity";	      
druid.spells.poolResource = "pool resource";	      
druid.spells.predatorySwiftness = "predatory swiftness";	      
druid.spells.rake = "rake";	      
druid.spells.rip = "rip";	      
druid.spells.runeOfReorigination = "rune of reorigination";	      
druid.spells.savageRoar = "savage roar";	      
druid.spells.skullBashCat = "skull bash";	      
druid.spells.slot = "slot";	      
druid.spells.stealthed = "prowl";	
druid.spells.prowl = "prowl";	
druid.spells.shred = "shred";
druid.spells.kingOfTheJungle = "King Of the Jungle";    
druid.spells.swipeCat = "swipe";	      
druid.spells.thrashCat = "thrash";	      
druid.spells.tigersFury = "tiger's fury";	      
druid.spells.vicious = "vicious";	      
druid.spells.virmensBitePotion = "virmens bite potion";	      
druid.spells.weakenedArmor = "weakened armor";	    
druid.spells.markOfTheWild = "Mark of the Wild";
druid.spells.mangle = "mangle";
druid.spells.feralFury ="Feral Fury";

druid.spells.energyRegen = function() 
	return select(1,GetPowerRegen())
end

druid.spells.cp = function()
	return GetComboPoints("player")
end
druid.spells.timeToMax = function() 
	return (100- UnitMana("player")) / druid.spells.energyRegen()
end

druid.spells.energy = function()
	return UnitMana("player")
end

if jps.TimetoDie == nil then
	jps.TimetoDie = function(unit) 
		if DeathClock_TimeTillDeath ~= nil then
			return jps.cachedValue(function()
				return  DeathClock_TimeTillDeath(unit) 
			end , 1)
		end
	end
end


local spellTable = {
		
 -- buffs
	{nil, 'IsControlKeyDown() == true'},
	{druid.spells.barksin, 'jps.hp("player") < 0.5'},
	{druid.spells.markOfTheWild, 'not jps.hasStatsBuff("player") and not jps.buff("Cat Form")'},
	{jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
	{jps.useBagItem(5512), 'jps.hp("player") < 0.90 and jps.debuff("weak ancient barrier")' }, --malk barrier
	{jps.useBagItem(5512), 'jps.hp("player") < 0.99 and jps.debuff("ancient barrier")' }, --malk barrier
	{jps.useBagItem(86569), 'not jps.buff("Flask of the spring blossom") and not jps.buff("Crystal of Insanity")'},
	
	{ "Cat Form", ' not jps.buff("Cat Form")'},

 -- cooldowns
 
 	{druid.spells.skullBashCat, 'jps.Interrupts and jps.shouldKick("target")' },
	{druid.spells.arcaneTorrent, 'jps.Interrupts and jps.shouldKick("target") and IsSpellInRange("Shred", "target") == 1' },

	{ "nested",'IsSpellInRange("Shred", "target") == 1 and jps.UseCDs',{	
		{druid.spells.berserking, 'jps.buff(druid.spells.tigersFury)' },
		{druid.spells.tigersFury, 'not jps.buff(druid.spells.clearcasting) and jps.energy() >= 60' },
		{druid.spells.tigersFury, 'jps.energy() <= 40' },
		{druid.spells.incarnation, 'jps.buff(druid.spells.berserk)' },
		{druid.spells.berserk, 'jps.buff(druid.spells.tigersFury)' },
		{"Lifeblood", 'jps.UseCDs' },
		{ jps.useTrinket(0), 'jps.buff(druid.spells.tigersFury)' },
		{ jps.useTrinket(1), 'jps.buff(druid.spells.tigersFury)' },
		{druid.spells.bloodFury, 'jps.buff(druid.spells.tigersFury)' },
		
	}},
			
	{druid.spells.rake, 'jps.buff(druid.spells.prowl)' },
	{druid.spells.feralforceOfNature, 'select(1,GetSpellCharges(druid.spells.feralforceOfNature))==3 and not jps.isRecast(druid.spells.feralforceOfNature)' },
	{druid.spells.feralforceOfNature, 'not jps.isRecast(druid.spells.feralforceOfNature) and jps.TimeToDie("target") < 20' },
	
	{druid.spells.ferociousBite, 'jps.myDebuff(druid.spells.rip) and jps.myDebuffDuration(druid.spells.rip) < 3 and jps.hp("target") < 0.25' },
	{druid.spells.ferociousBite, 'GetComboPoints("player") == 5 and not jps.targetIsRaidBoss() and jps.TimeToDie("target") < 15' },
	
	--blood talons is L100 {druid.spells.healingTouch, 'jps.talentInfo(druid.spells.bloodtalons) and jps.buff(druid.spells.predatorySwiftness) and (comboPoints >= 4 or jps.buffDuration(druid.spells.predatorySwiftness) < 1.5)' },
	{druid.spells.savageRoar, 'jps.buffDuration(druid.spells.savageRoar) < 3' },
	{druid.spells.thrashCat, 'jps.buff(druid.spells.omenOfClarity) and jps.myDebuffDuration(druid.spells.thrashCat) <= 4 and jps.MultiTarget' },
	{druid.spells.ferociousBite, 'GetComboPoints("player") == 5 and jps.hp("target") < 0.25 and jps.myDebuff(druid.spells.rip)' },
	{druid.spells.rip, 'GetComboPoints("player") == 5 and jps.myDebuffDuration(druid.spells.rip) <= 3' },
	{druid.spells.rip, 'GetComboPoints("player") == 5 and jps.myDebuffDuration(druid.spells.rip) <= 4' },
	{druid.spells.savageRoar, 'GetComboPoints("player") == 5 and jps.energy() >= 90 and jps.buffDuration(druid.spells.savageRoar) < 12' },
	{druid.spells.savageRoar, 'GetComboPoints("player") == 5 and jps.buff(druid.spells.berserk) and jps.buffDuration(druid.spells.savageRoar) < 12' },
	{druid.spells.savageRoar, 'GetComboPoints("player") == 5 and jps.cooldown(druid.spells.tigersFury) < 3 and jps.buffDuration(druid.spells.savageRoar) < 12' },
	
	{druid.spells.ferociousBite, 'GetComboPoints("player") == 5 and jps.energy() >= 90' },
	{druid.spells.ferociousBite, 'GetComboPoints("player") == 5 and jps.cooldown(druid.spells.tigersFury) < 3' },
	{druid.spells.ferociousBite, 'GetComboPoints("player") == 5 and jps.buff(druid.spells.berserk)' },
	
	{druid.spells.rake, 'jps.myDebuffDuration(druid.spells.rake) <= 3 and GetComboPoints("player") < 5' },
	--{druid.spells.rake, 'jps.myDebuffDuration(druid.spells.rip) <= 7 and GetComboPoints("player") < 5' },
	{druid.spells.thrashCat, 'jps.myDebuffDuration(druid.spells.thrashCat) <= 4 and jps.MultiTarget' },
	--wtf?:{druid.spells.moonfire, 'jps.myDebuffDuration(druid.spells.rip) <= 7' },
	--{druid.spells.rake, 'druid.spells.persistentMultiplier > dot.druid.spells.rake.pmultiplier and comboPoints < 5' },
	{druid.spells.swipe, 'GetComboPoints("player") < 5 and jps.MultiTarget' },
	{druid.spells.shred, 'GetComboPoints("player") < 5' },
}

jps.registerRotation("DRUID","FERAL",function()
	local spell = nil
	local target = nil
	
	spell,target = parseStaticSpellTable(spellTable)

	return spell,target
end, "Simcraft druid-FERAL")
