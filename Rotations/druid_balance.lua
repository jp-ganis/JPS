druidBalance = {};
druidBalance.activeEnemies = "active enemies";	      
druidBalance.arcaneTorrent = "arcane torrent";	      
druidBalance.berserking = "berserking";	      
druidBalance.bloodFury = "blood fury";	      
druidBalance.celestialAlignment = "celestial alignment";	      
druidBalance.forceOfNature = "force of nature";	      
druidBalance.incarnation = "Incarnation: Chosen of Elune";	      
druidBalance.lunarEmpowerment = "lunar empowerment";	      
druidBalance.lunarMax = "lunar max";	      
druidBalance.lunarPeak = "lunar peak";	      
druidBalance.moonfire = "moonfire";	      
druidBalance.rechargeTime = "recharge time";	      
druidBalance.singleTarget = "single target";	      
druidBalance.solarEmpowerment = "solar empowerment";	      
druidBalance.solarPeak = "solar peak";	      
druidBalance.starfall = "starfall";	      
druidBalance.starfire = "starfire";	      
druidBalance.starsurge = "starsurge";	      
druidBalance.stellarFlare = "stellar flare";	      
druidBalance.sunfire = "sunfire";	      
druidBalance.wrath = "wrath";	 
druidBalance.solarBeam ="Solar Beam";
druidBalance.moonkinForm ="Moonkin Form";
druidBalance.starsurgeRecharge = function()
	currentCharges, maxCharges, cooldownStart, cooldownDuration = GetSpellCharges(druidBalance.starsurge)
	return (GetTime() - cooldownStart) or 0
end

druidBalance.eclipseChange = function() 
	local cycleTime = 40/2
	if jps.talentInfo("Euphoria") then
		cycleTime = cycleTime/2
	end
	if jps.buff(druidBalance.celestialAlignment) then
		cycleTime = cycleTime/10
	end
	local power = jps.eclipsePower() 
	if power == 0 then power =  1 end
	if power < 0 then power = power *-1 end
	
	return ((power / 100 ) * cycleTime)+3.5
end


druidBalance.lunarPower = function()
	local power = jps.eclipsePower()
	if power > 0 then return 0 end 
	if power < 0 then power = power * -1 end
	return power
end
druidBalance.direction = "sun"

druidBalance.shouldCastWrath = function()
	local power = jps.eclipsePower()
end
druidBalance.shouldCastStarfire = function() 
	local power = jps.eclipsePower()
end
spellTableBalance = {
		
 -- buffs
 -- [buffs]
 -- cooldowns
	{druidBalance.solarBeam, 'jps.shouldKick()'},
	{"nested", 'jps.canDPS("target") and not jps.Moving', {
		{druidBalance.bloodFury, 'jps.buff(druidBalance.celestialAlignment) and jps.UseCDs' },
		{druidBalance.berserking, 'jps.buff(druidBalance.celestialAlignment) and jps.UseCDs' },
		{druidBalance.arcaneTorrent, 'jps.buff(druidBalance.celestialAlignment) and jps.UseCDs' },
		{druidBalance.forceOfNature, 'jps.UseCDs' },
		{ jps.useTrinket(0), 'jps.UseCDs and jps.useTrinketBool(0) ' },
		{ jps.useTrinket(1), 'jps.UseCDs and jps.useTrinketBool(1) ' },	
		{druidBalance.celestialAlignment, 'jps.UseCDs' },
		{druidBalance.incarnation, 'jps.UseCDs' },
	}},
	-- multitarget druidBalance.target, remove if empty

	{druidBalance.moonkinForm, 'GetShapeshiftForm() == 0'},
	{'nested' , 'jps.MultiTarget',{

		{druidBalance.starfall, 'not jps.buff(druidBalance.starfall)' },
		
		{druidBalance.moonfire, 'druidBalance.lunarPower() > 0 and jps.buffDuration(druidBalance.celestialAlignment) < 4'},
		
		{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.sunfire) < 4 and jps.eclipsePower() > 0'},
		{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.moonfire) < 4 and druidBalance.lunarPower() > 0' },	
		{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.sunfire,"mouseover") < 4 and jps.eclipsePower() > 0 and jps.canDPS("mouseover")',"mouseover"},
		{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.moonfire,"mouseover") < 4 and druidBalance.lunarPower() > 0 and jps.canDPS("mouseover")',"mouseover" },	
		{druidBalance.moonfire, 'jps.eclipsePower() > 0 and jps.eclipsePower() < 30 and jps.myDebuffDuration(druidBalance.sunfire) < 15'},
		{druidBalance.moonfire, 'druidBalance.lunarPower() < 30 and druidBalance.lunarPower() > 0 and jps.myDebuffDuration(druidBalance.moonfire) < 15' },	
		
		
		{druidBalance.starsurge, 'GetSpellCharges(druidBalance.starsurge)==2 and druidBalance.starsurgeRecharge() < 6' },
		{druidBalance.starsurge, 'GetSpellCharges(druidBalance.starsurge)==3 ' },
		
		{druidBalance.wrath, 'druidBalance.direction  == "moon"' },
		{druidBalance.starfire, 'druidBalance.direction  == "sun"' },
	}},
		

 -- single druidBalance.target, remove if empty
		
  {'nested' , 'not jps.MultiTarget', 
		
   {
	
	{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.sunfire,"mouseover") < 4 and jps.eclipsePower() > 0 and jps.canDPS("mouseover")',"mouseover"},
	{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.moonfire,"mouseover") < 4 and druidBalance.lunarPower() > 0 and jps.canDPS("mouseover")',"mouseover" },	
	{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.sunfire) < 4 and jps.eclipsePower() > 0'},
	{druidBalance.moonfire, 'jps.myDebuffDuration(druidBalance.moonfire) < 4 and druidBalance.lunarPower() > 0' },	
	{druidBalance.moonfire, 'jps.eclipsePower() > 0 and jps.eclipsePower() < 30 and jps.myDebuffDuration(druidBalance.sunfire) < 15'},
	{druidBalance.moonfire, 'druidBalance.lunarPower() < 30 and druidBalance.lunarPower() > 0 and jps.myDebuffDuration(druidBalance.moonfire) < 15' },	


    {druidBalance.starsurge, 'not jps.buff(druidBalance.lunarEmpowerment) and jps.eclipsePower() > 20' },
	{druidBalance.starsurge, 'not jps.buff(druidBalance.solarEmpowerment) and druidBalance.lunarPower() > 40' },
	{druidBalance.starsurge, 'GetSpellCharges(druidBalance.starsurge)==2 and druidBalance.starsurgeRecharge() < 6' },
	{druidBalance.starsurge, 'GetSpellCharges(druidBalance.starsurge)==3 ' },

	
	{druidBalance.wrath, 'druidBalance.direction  == "moon"' },
	{druidBalance.starfire, 'druidBalance.direction  == "sun"' },
	
}
		
  },
}

jps.registerRotation("DRUID","BALANCE",function()
	local spell = nil
	local target = nil
	spell,target = parseStaticSpellTable(spellTableBalance)
	druidBalance.direction = GetEclipseDirection()
	return spell,target
end, "Simcraft druid-BALANCE")
