priestshadow = {}


	   
priestshadow.auspiciousSpirits = toSpellName(155271); 
priestshadow.bloodlust = "bloodlust";	   
priestshadow.cascade = toSpellName(121135);    
priestshadow.clarityOfPower = toSpellName(155246);      
priestshadow.cop = toSpellName(155246); 
priestshadow.devouringPlague = toSpellName(2944); 	   
priestshadow.dispersion = toSpellName(47585);
priestshadow.divineStar = toSpellName(110744);	   
priestshadow.halo = toSpellName(120644)    
priestshadow.insanity = toSpellName(132573);
priestshadow.mentalInstinct = toSpellName(167254);   
priestshadow.mindBlast = toSpellName(8092);	   
priestshadow.mindFlay = toSpellName(15407);   
priestshadow.mindHarvest = toSpellName(162532);	   
priestshadow.mindSear = toSpellName(48045);   
priestshadow.mindSpike = toSpellName(73510);	   
priestshadow.mindbender = toSpellName(123040);   
priestshadow.shadowOrb = function()
	return jps.shadowOrbs()
end   
priestshadow.shadowWordDeath =  toSpellName(32379);	   
priestshadow.shadowWordPain = toSpellName(589);	   
priestshadow.shadowfiend = toSpellName(34433);  
priestshadow.shadowyInsight = toSpellName(162452);
priestshadow.surgeOfDarkness = toSpellName(87160);  
priestshadow.vampiricTouch = toSpellName(34914);   
priestshadow.vent = toSpellName(155361);   
priestshadow.voidEntropy = toSpellName(155361);	   
priestshadow.powerInfusion = toSpellName(10060);
priestshadow.insanityTalent = toSpellName(139139)

priestshadow.powerWordShield = toSpellName(17);
priestshadow.pwsBuff = toSpellName(64129);
priestshadow.silence = toSpellName(15487);
priestshadow.gs = toSpellName(6788);
priestshadow.shadowForm = toSpellName(15473);
priestshadow.flashHeal = toSpellName(2061);
priestshadow.physicalScream = toSpellName(8122);
priestshadow.desperatePrayer = toSpellName(19236);

priestshadow.powerWordFortitude = toSpellName(21562);

priestshadowspellTable = {
	
	{"nested","jps.Defensive",{
		{ priestshadow.powerWordShield, 'jps.talentInfo(toSpellName(64129)) and not jps.debuff(priestshadow.gs, "player") and jps.hp("player") <= 0.8','player'},
		{ priestshadow.desperatePrayer,'jps.hp("player") <= 0.5','player'},	
		{ priestshadow.physicalScream , 'jps.hp("player") <= 0.4 and jps.talentInfo(priestshadow.physicalScream ) and GetNumGroupMembers() == 0','player'},
		{ priestshadow.flashHeal, 'jps.hp("player") <= 0.2 and not jps.Moving','player'},
	}},
	{ priestshadow.silence, 'jps.shouldKick()' },
	{ priestshadow.powerWordShield, 'jps.talentInfo(toSpellName(64129)) and not jps.debuff(priestshadow.gs, "player") and jps.Moving','player'},
	{ priestshadow.powerWordFortitude, 'not jps.hasStaminaBuff("player")','player'},
	
	{ priestshadow.shadowForm, 'not jps.buff(priestshadow.shadowForm)'},
	{ "nested",'not jps.talentInfo(priestshadow.clarityOfPower) and not jps.MultiTarget',{
		{priestshadow.mindbender, 'jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{priestshadow.shadowfiend, 'not jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{"nested",'priestshadow.shadowOrb() >= 3',{ 
			{ priestshadow.powerInfusion, 'jps.UseCDs'},		
			{ jps.getDPSRacial(), 'jps.UseCDs' },
			{ {"macro","/use 13"}, 'jps.useEquipSlot(13) and jps.UseCDs'},
			{ {"macro","/use 14"}, 'jps.useEquipSlot(14) and jps.UseCDs'},
		}},

		
		{priestshadow.shadowWordDeath, 'jps.hp("target") < 0.20 and priestshadow.shadowOrb() <= 4'},
		{priestshadow.mindBlast, 'jps.glyphInfo(priestshadow.mindHarvest) and priestshadow.shadowOrb() <= 2 and jps.cooldown(priestshadow.mindBlast) == 0'},
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb()==5 and jps.talentInfo(priestshadow.surgeOfDarkness)'},
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb()==5'},
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb() >= 3 and jps.cooldown(priestshadow.mindBlast) < 1.5 and jps.myDebuffDuration(priestshadow.devouringPlague) == 0 and jps.talentInfo(priestshadow.surgeOfDarkness)'},
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb() >= 3 and jps.hp("target") < 0.20 and jps.cooldown(priestshadow.shadowWordDeath) < 1.5 and jps.myDebuffDuration(priestshadow.devouringPlague) == 0 and jps.talentInfo(priestshadow.surgeOfDarkness)'},
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb() >= 3 and jps.hp("target") < 0.20 and jps.cooldown(priestshadow.shadowWordDeath) < 1.5'},		
		{priestshadow.mindBlast, 'jps.cooldown(priestshadow.mindBlast) == 0'},
		{priestshadow.mindFlay, 'jps.buffDuration(priestshadow.insanity) < 2 and jps.buffDuration(priestshadow.insanity) > 0'},
		--{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target") and priestshadow.activeEnemies > 2'},
	--	{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and priestshadow.activeEnemies > 2 and jps.IsSpellInRange(priestshadow.cascade,"target")'},
		jps.dotTracker.castTableStatic(priestshadow.shadowWordPain),
		jps.dotTracker.castTableStatic(priestshadow.vampiricTouch),
	
		{priestshadow.devouringPlague, 'not jps.talentInfo(priestshadow.voidEntropy) and priestshadow.shadowOrb() >= 3 and jps.myDebuffDuration(priestshadow.devouringPlague) < 0.5'},
		{priestshadow.mindSpike, 'jps.buff(priestshadow.surgeOfDarkness)==3'},
		{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target")'},
	--	{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and ((priestshadow.activeEnemies > 1 or jps.IsSpellInRange(priestshadow.cascade,"target")) and jps.IsSpellInRange(priestshadow.cascade,"target"))'},
		{priestshadow.mindSpike, 'jps.buff(priestshadow.surgeOfDarkness)'},
		{priestshadow.shadowWordPain, 'priestshadow.shadowOrb() >= 2 and jps.myDebuffDuration(priestshadow.shadowWordPain) < 4 and jps.talentInfo(priestshadow.insanity)'},
		{priestshadow.vampiricTouch, 'priestshadow.shadowOrb() >= 2 and jps.myDebuffDuration(priestshadow.vampiricTouch) < 4 and jps.talentInfo(priestshadow.insanity)'},
	--	{priestshadow.mindFlay,priestshadow.chain==1,priestshadow.interruptIf==(jps.cooldown(priestshadow.mindBlast) <= 0.1 or jps.cooldown(priestshadow.shadowWordDeath) <= 0.1 or priestshadow.shadowOrb()==5), 'onCD'},
		{priestshadow.mindBlast , 'jps.buff(priestshadow.shadowyInsight) and jps.cooldown(priestshadow.mindBlast) == 0 and jps.Moving'},
		{priestshadow.cascade , 'jps.talentInfo(priestshadow.cascade) and jps.IsSpellInRange(priestshadow.cascade,"target")'},
		{priestshadow.shadowWordDeath , 'onCD'},
		{priestshadow.shadowWordPain , 'jps.Moving'},
		{priestshadow.mindFlay, 'jps.CastTimeLeft("player") == 0'},

	}},

	
	{"nested","jps.MultiTarget",{
		{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target") and jps.Moving'},
		{priestshadow.divineStar, 'jps.talentInfo(priestshadow.divineStar) and jps.IsSpellInRange(priestshadow.divineStar,"target") and jps.Moving'},
		{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and jps.IsSpellInRange(priestshadow.cascade,"target") and jps.Moving'},
		jps.dotTracker.castTableStatic(priestshadow.shadowWordPain),
		jps.dotTracker.castTableStatic(priestshadow.vampiricTouch),
		{priestshadow.mindSear, 'not jps.IsCastingSpell(priestshadow.mindSear, "player")'},
		{priestshadow.shadowWordDeath , 'onCD'},		
		{priestshadow.mindSpike, 'onCD'},
		{priestshadow.mindBlast, 'jps.cooldown(priestshadow.mindBlast) == 0'},
	}},
	
	{"nested",' jps.talentInfo(priestshadow.clarityOfPower) and jps.talentInfo(priestshadow.insanityTalent) and jps.hp("target") > 0.20',{
		{priestshadow.shadowWordPain, 'priestshadow.shadowOrb()==5 and not jps.myDebuff(priestshadow.devouringPlague) and not jps.myDebuff(priestshadow.shadowWordPain)'},
		{priestshadow.vampiricTouch, 'priestshadow.shadowOrb()==5 and not jps.myDebuff(priestshadow.devouringPlague) and not jps.myDebuff(priestshadow.vampiricTouch)'},
		
		{priestshadow.devouringPlague, 'jps.myDebuff(priestshadow.vampiricTouch) and jps.myDebuff(priestshadow.shadowWordPain) and priestshadow.shadowOrb()==5'},
		{priestshadow.devouringPlague, 'jps.buffDuration(priestshadow.mentalInstinct) < 2 and jps.buffDuration(priestshadow.mentalInstinct) > 0 and priestshadow.shadowOrb()==5 '},
		{priestshadow.devouringPlague, 'jps.myDebuff(priestshadow.vampiricTouch) and jps.myDebuff(priestshadow.shadowWordPain) and jps.buffDuration(priestshadow.insanity) == 0 and jps.cooldown(priestshadow.mindBlast) > 0.4 and priestshadow.shadowOrb()==5 '},
		{priestshadow.mindBlast, 'jps.glyphInfo(priestshadow.mindHarvest) and priestshadow.shadowOrb() <= 2'},
		{priestshadow.mindBlast, 'priestshadow.shadowOrb() <= 4'},
		
		{priestshadow.mindbender, 'jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{priestshadow.shadowfiend, 'not jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{"nested",'priestshadow.shadowOrb() >= 3',{ 
			{ priestshadow.powerInfusion, 'jps.UseCDs'},		
			{ jps.getDPSRacial(), 'jps.UseCDs' },
			{ {"macro","/use 13"}, 'jps.useEquipSlot(13) and jps.UseCDs'},
			{ {"macro","/use 14"}, 'jps.useEquipSlot(14) and jps.UseCDs'},
		}},

		--{priestshadow.shadowWordPain, 'priestshadow.shadowOrb()==4 and priestshadow.setBonus.tier172pc and not jps.myDebuff(priestshadow.shadowWordPain) and not jps.myDebuff(priestshadow.devouringPlague) and jps.cooldown(priestshadow.mindBlast) < 1.2 and jps.cooldown(priestshadow.mindBlast) > 0.2'},

		{priestshadow.mindFlay, 'jps.buffDuration(priestshadow.insanity) > 0 and jps.buffDuration(priestshadow.insanity) > 0'},
		--{priestshadow.shadowWordPain, 'priestshadow.shadowOrb() >= 2 and jps.myDebuffDuration(priestshadow.shadowWordPain) >= 6 and jps.cooldown(priestshadow.mindBlast) > 0.5 and jps.myDebuffDuration(priestshadow.vampiricTouch) and jps.buff(priestshadow.bloodlust) and not priestshadow.setBonus.tier172pc'},
	--	{priestshadow.vampiricTouch, 'priestshadow.shadowOrb() >= 2 and jps.myDebuffDuration(priestshadow.vampiricTouch) >= 5 and jps.cooldown(priestshadow.mindBlast) > 0.5 and jps.buff(priestshadow.bloodlust) and not priestshadow.setBonus.tier172pc'},
		{priestshadow.halo, 'jps.cooldown(priestshadow.mindBlast) > 0.5 and jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target")'},
		--{priestshadow.divineStar, 'jps.cooldown(priestshadow.mindBlast) > 0.5 and gcd and jps.talentInfo(priestshadow.divineStar) and (priestshadow.activeEnemies > 1 or jps.IsSpellInRange(priestshadow.divineStar,"target"))'},
	--	{priestshadow.cascade, 'jps.cooldown(priestshadow.mindBlast) > 0.5 and jps.talentInfo(priestshadow.cascade) and ((priestshadow.activeEnemies > 1 or jps.IsSpellInRange(priestshadow.cascade,"target")) and jps.IsSpellInRange(priestshadow.cascade,"target"))'},
		{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target") and jps.Moving'},
		{priestshadow.divineStar, 'jps.talentInfo(priestshadow.divineStar) and jps.IsSpellInRange(priestshadow.divineStar,"target") and jps.Moving'},
		{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and jps.IsSpellInRange(priestshadow.cascade,"target") and jps.Moving'},
		
		{priestshadow.vampiricTouch, 'jps.myDebuff(priestshadow.devouringPlague) and jps.myDebuffDuration(priestshadow.vampiricTouch) <= 3'},
		{priestshadow.shadowWordPain, 'jps.myDebuff(priestshadow.devouringPlague) and jps.myDebuffDuration(priestshadow.vampiricTouch) <= 3'},
		jps.dotTracker.castTableStaticOtherUnits(priestshadow.shadowWordPain),
		jps.dotTracker.castTableStaticOtherUnits(priestshadow.vampiricTouch),
		
		{priestshadow.mindSpike, 'jps.buffDuration(priestshadow.insanity) <= 1 and jps.buff(priestshadow.bloodlust) and jps.myDebuffDuration(priestshadow.shadowWordPain) == 0 and jps.myDebuffDuration(priestshadow.vampiricTouch) == 0'},		
		{priestshadow.mindSpike, 'jps.myDebuffDuration(priestshadow.shadowWordPain) and jps.myDebuffDuration(priestshadow.vampiricTouch) == 0 and priestshadow.shadowOrb() <= 2 and jps.cooldown(priestshadow.mindBlast) > 0.5'},
		
		--{priestshadow.mindFlay, 'priestshadow.setBonus.tier172pc and jps.myDebuffDuration(priestshadow.shadowWordPain) and jps.myDebuffDuration(priestshadow.vampiricTouch) and jps.cooldown(priestshadow.mindBlast) > 0.9*priestshadow.gcd,priestshadow.interruptIf==(jps.cooldown(priestshadow.mindBlast) <= 0.1 or jps.cooldown(priestshadow.shadowWordDeath) <= 0.1)'},
		{priestshadow.shadowWordDeath , 'onCD'},
		{priestshadow.mindSpike, 'onCD'},

	
		jps.dotTracker.castTableStaticOtherUnits(priestshadow.shadowWordPain),
	}},
	
	{"nested",'jps.talentInfo(priestshadow.clarityOfPower) and jps.talentInfo(priestshadow.insanityTalent) and jps.hp("target") <= 0.20',{
		{priestshadow.shadowWordPain, 'priestshadow.shadowOrb()==5 and not jps.myDebuff(priestshadow.devouringPlague) and not jps.myDebuff(priestshadow.shadowWordPain)'},
		{priestshadow.vampiricTouch, 'priestshadow.shadowOrb()==5 and not jps.myDebuff(priestshadow.devouringPlague) and not jps.myDebuff(priestshadow.vampiricTouch)'},
		
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb()==5'},
		{priestshadow.mindBlast, 'jps.glyphInfo(priestshadow.mindHarvest)'},
		{priestshadow.shadowWordDeath, 'jps.hp("target") < 0.20'},
		{priestshadow.devouringPlague, 'jps.myDebuff(priestshadow.vampiricTouch) and jps.myDebuff(priestshadow.shadowWordPain) and priestshadow.shadowOrb()==5'},
		{priestshadow.devouringPlague, 'jps.buffDuration(priestshadow.mentalInstinct) < 2 and jps.buffDuration(priestshadow.mentalInstinct) > 0 and priestshadow.shadowOrb()==5 '},
		{priestshadow.devouringPlague, 'jps.myDebuff(priestshadow.vampiricTouch) and jps.myDebuff(priestshadow.shadowWordPain) and jps.buffDuration(priestshadow.insanity) == 0 and jps.cooldown(priestshadow.mindBlast) > 0.4 and priestshadow.shadowOrb()==5 '},
		
		{priestshadow.mindBlast, 'jps.cooldown(priestshadow.mindBlast) == 0'},
		
		{priestshadow.mindbender, 'jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{priestshadow.shadowfiend, 'not jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{"nested",'priestshadow.shadowOrb() >= 3',{ 
			{ priestshadow.powerInfusion, 'jps.UseCDs'},		
			{ jps.getDPSRacial(), 'jps.UseCDs' },
			{ {"macro","/use 13"}, 'jps.useEquipSlot(13) and jps.UseCDs'},
			{ {"macro","/use 14"}, 'jps.useEquipSlot(14) and jps.UseCDs'},
		}},
		jps.dotTracker.castTableStaticOtherUnits(priestshadow.shadowWordPain),
		jps.dotTracker.castTableStaticOtherUnits(priestshadow.vampiricTouch),
		
		{priestshadow.mindFlay, 'jps.buffDuration(priestshadow.insanity) > 0 and jps.buffDuration(priestshadow.insanity) > 0'},
		{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target")'},
		{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and jps.IsSpellInRange(priestshadow.cascade,"target")'},
		{priestshadow.divineStar, 'jps.talentInfo(priestshadow.divineStar) and jps.IsSpellInRange(priestshadow.divineStar,"target")'},
		{priestshadow.shadowWordDeath , 'onCD'},


		{priestshadow.mindBlast, 'jps.buff(priestshadow.shadowyInsight) and jps.cooldown(priestshadow.mindBlast) == 0 and jps.Moving'},
		{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target") and jps.Moving'},
		{priestshadow.divineStar, 'jps.talentInfo(priestshadow.divineStar) and jps.IsSpellInRange(priestshadow.divineStar,"target") and jps.Moving'},
		{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and jps.IsSpellInRange(priestshadow.cascade,"target") and jps.Moving'},
		{priestshadow.mindSpike, 'onCD'},
		jps.dotTracker.castTableStaticOtherUnits(priestshadow.shadowWordPain),
	}},
	
	{"nested",'jps.talentInfo(priestshadow.clarityOfPower) and not jps.talentInfo(priestshadow.insanityTalent)',{
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb() >= 3 and (jps.cooldown(priestshadow.mindBlast) <= 1.0 or (jps.cooldown(priestshadow.shadowWordDeath) <= 1.0 and jps.hp("target") < 20)) and primarytarget==0'},
		{priestshadow.devouringPlague, 'priestshadow.shadowOrb() >= 3 and (jps.cooldown(priestshadow.mindBlast) <= 1.0 or (jps.cooldown(priestshadow.shadowWordDeath) <= 1.0 and jps.hp("target") < 20))'},
		{priestshadow.mindBlast, 'priestshadow.mindHarvest==0'},
		{priestshadow.mindBlast, 'jps.cooldown(priestshadow.mindBlast) == 0'},
		{priestshadow.shadowWordDeath, 'jps.hp("target") < 20'},
		{priestshadow.mindbender, 'jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{priestshadow.shadowfiend, 'not jps.talentInfo(priestshadow.mindbender) and jps.UseCDs'},
		{"nested",'priestshadow.shadowOrb() >= 3',{ 
			{ priestshadow.powerInfusion, 'jps.UseCDs'},		
			{ jps.getDPSRacial(), 'jps.UseCDs' },
			{ {"macro","/use 13"}, 'jps.useEquipSlot(13) and jps.UseCDs'},
			{ {"macro","/use 14"}, 'jps.useEquipSlot(14) and jps.UseCDs'},
		}},
		{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target")'},
		{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and ((priestshadow.activeEnemies > 1 or jps.IsSpellInRange(priestshadow.cascade,"target")) and jps.IsSpellInRange(priestshadow.cascade,"target"))'},
		{priestshadow.divineStar, 'jps.talentInfo(priestshadow.divineStar) and (priestshadow.activeEnemies > 1 or jps.IsSpellInRange(priestshadow.divineStar,"target"))'},
		{priestshadow.shadowWordPain, 'priestshadow.missReact and not ticking and priestshadow.activeEnemies <= 5 and primarytarget==0,priestshadow.maxCycleTargets==5'},
		{priestshadow.vampiricTouch, 'remains < jps.CastTimeLeft("player") and priestshadow.missReact and priestshadow.activeEnemies <= 5 and primarytarget==0,priestshadow.maxCycleTargets==5'},
		{priestshadow.mindSear, 'priestshadow.activeEnemies >= 5,priestshadow.chain==1,priestshadow.interruptIf==(jps.cooldown(priestshadow.mindBlast) <= 0.1 or jps.cooldown(priestshadow.shadowWordDeath) <= 0.1)'},
		{priestshadow.mindSpike, 'priestshadow.activeEnemies <= 4 and jps.buff(priestshadow.surgeOfDarkness)'},
		{priestshadow.mindSear, 'priestshadow.activeEnemies >= 3,priestshadow.chain==1,priestshadow.interruptIf==(jps.cooldown(priestshadow.mindBlast) <= 0.1 or jps.cooldown(priestshadow.shadowWordDeath) <= 0.1)'},
		{priestshadow.mindFlay, 'dot.priestshadow.devouringPlaguetick.priestshadow.ticksRemain > 1 and priestshadow.activeEnemies==1,priestshadow.chain==1,priestshadow.interruptIf==(jps.cooldown(priestshadow.mindBlast) <= 0.1 or jps.cooldown(priestshadow.shadowWordDeath) <= 0.1)'},
		{priestshadow.shadowWordDeath , 'onCD'},
		{priestshadow.mindBlast, 'jps.buff(priestshadow.shadowyInsight) and jps.cooldown(priestshadow.mindBlast) == 0 jps.Moving'},
		{priestshadow.halo, 'jps.talentInfo(priestshadow.halo) and jps.IsSpellInRange(priestshadow.halo,"target") and jps.Moving'},
		{priestshadow.divineStar, 'jps.talentInfo(priestshadow.divineStar) and jps.IsSpellInRange(priestshadow.divineStar,"target") and jps.Moving'},
		{priestshadow.cascade, 'jps.talentInfo(priestshadow.cascade) and jps.IsSpellInRange(priestshadow.cascade,"target") jps.Moving'},	
		{priestshadow.shadowWordDeath , 'onCD'},
		{priestshadow.mindSpike, 'onCD'},
		
		jps.dotTracker.castTableStaticOtherUnits(priestshadow.shadowWordPain),
	}},

}
spellTableOOCPS = {
	{ priestshadow.powerWordShield, 'jps.talentInfo(toSpellName(64129)) and not jps.debuff(priestshadow.gs, "player") and jps.Moving','player'},
	{ priestshadow.desperatePrayer,'jps.hp("player") <= 0.5','player'},	
	{ priestshadow.powerWordFortitude, 'not jps.hasStaminaBuff("player")','player'},
	{ priestshadow.physicalScream , 'jps.hp("player") <= 0.4 and jps.talentInfo(priestshadow.physicalScream ) and GetNumGroupMembers() == 0','player'},
	{ priestshadow.flashHeal, 'jps.hp("player") <= 0.2 and not jps.Moving','player'},
}

jps.registerRotation("PRIEST","SHADOW",function()
	local spell = nil
	local target = nil
	spell,target = parseStaticSpellTable(priestshadowspellTable)
	return spell,target
end, "Simcraft Priest-SHADOW")

jps.registerRotation("PRIEST","SHADOW",function()
	return parseStaticSpellTable(spellTableOOCPS)
end,"Out of Combat",false,false,nil, true)
