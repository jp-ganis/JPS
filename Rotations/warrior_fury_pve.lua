
--[[[
@rotation Default
@class warrior
@spec fury
@talents ZZ!!c
@author atx, kyletxag
@description 
This Rotation requires Glyph of Unending Rage. Shouldn't be used at lower levels
]]--

fury = {}
fury.angermanagement =	 "anger management";
fury.arcanetorrent =	 "arcane torrent";
fury.avatar =	"avatar";
fury.battlestance =	 "battle stance"
fury.berserkerrage =	 "berserker rage";
fury.berserking =	 "berserking";
fury.bladestorm =	 "bladestorm"
fury.bloodbath =	 "bloodbath";
fury.bloodfury =	 "blood fury";
fury.bloodsurge =	 "bloodsurge";
fury.bloodthirst =	 "bloodthirst"
fury.defensivestance =	 "defensive stance"
fury.diebythesword =	 "die by the sword"
fury.dragonroar =	 "dragon roar";
fury.enrage =	 "enrage";
fury.execute =	 "execute"
fury.heroicleap =	 "heroic leap";
fury.impendingvictory =	 "impending victory";
fury.lifeblood =	 "lifeblood"
fury.meatcleaver =	 "meat cleaver";
fury.ragingblow =	 "raging blow";
fury.ravager =	 "ravager"
fury.recklessness =	 "recklessness";
fury.shieldbarrier =	 "shield barrier"
fury.shockwave =	 "shockwave"
fury.siegebreaker =	 "siegebreaker"
fury.stormbolt =	 "storm bolt";
fury.suddendeath =	 "sudden death";
fury.unquenchablethirst =	 "unquenchable thirst";
fury.whirlwind =	 "whirlwind"
fury.wildstrike =	 "wild strike";
fury.charge = "charge"
fury.heroicleap ="Heroic Leap" 
fury.pummel ="pummel"

fury.shouldRecklessness = function()
	return ((jps.TimeToDie("target") > 190 or jps.hp("target") < 0.20) and (jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath))) or jps.TimeToDie("target") <= 10 or jps.talentInfo(fury.angermanagement)
end
fury.rage = function() return UnitPower("player") end
fury.maxRage = function(minus)
	if not minus then minus = 0 end
	return UnitPowerMax("player") -minus
end
fury.canCharge = function()
	if IsSpellInRange(fury.charge, "target") == 1 then return true end
	return false
end
jps.registerStaticTable("WARRIOR","FURY",
	{
	-- Interrupts
	{fury.pummel, 'jps.shouldKick()'},
	{fury.charge, 'IsAltKeyDown() == true and fury.canCharge() == true'},
	{fury.heroicleap, 'IsShiftKeyDown() == true'},
	
	-- Damage Mitigation
	{"nested",'jps.Defensive',{
		{fury.lifeblood, 'jps.hp("player") < 0.95'},
		{fury.arcanetorrent, 'jps.hp("player") <= 0.85'},
		{jps.useBagItem(5512), 'jps.hp("player") < 0.30'}, -- Healthstone
		{fury.diebythesword, 'UnitThreatSituation("player","target") == 3 and IsSpellInRange("execute","target") == 1 and jps.hp("player") < 0.30 and jps.UseCDs'},
		{fury.shieldbarrier, 'jps.hp() < 0.30 and jps.UseCDs and jps.buff(fury.defensivestance)'},
		{fury.defensivestance, 'not jps.buff(fury.defensivestance) and jps.hp() < 0.20'},
	}},

	{fury.battlestance, 'not jps.buff(fury.battlestance) and jps.hp() > 0.20'},
	{"nested",'IsSpellInRange(fury.execute,"target") == 1 and jps.UseCDs', {
		{jps.useTrinket(0), 'jps.UseCDs'},
		{jps.useTrinket(1), 'jps.UseCDs'},
		{fury.recklessness, 'fury.shouldRecklessness()' },
		{fury.avatar, 'jps.buff(fury.recklessness) or jps.TimeToDie("target") <= 25' },
		{fury.berserkerrage, 'not jps.buff(fury.enrage)' },
		{fury.berserkerrage, 'jps.talentInfo(fury.unquenchablethirst) and not jps.buff(fury.ragingblow)' },
		{fury.bloodfury, 'jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath) or jps.buff(fury.recklessness)' },
		{fury.berserking, 'jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath) or jps.buff(fury.recklessness)' },
		{fury.arcanetorrent, 'jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath) or jps.buff(fury.recklessness)' },
		{fury.bloodbath, 'onCD' },
	}},
	
	-- single target
	{"nested", 'fh.UnitsAroundUnit("target") <= 1',{
		{fury.wildstrike, 'fury.rage() > 110 and jps.hp("target") > 0.20' },
		{fury.bloodthirst, 'not jps.talentInfo(fury.unquenchablethirst) and fury.rage() < 80' },
		{fury.bloodthirst, 'not jps.buff(fury.enrage)' },
		{fury.ravager, 'jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath)' },
		{fury.execute, 'jps.buff(fury.suddendeath)' },
		{fury.siegebreaker, 'onCD' },
		{fury.stormBolt, 'onCD' },
		{fury.wildstrike, 'jps.buff(fury.bloodsurge)' },
		{fury.execute, 'jps.buff(fury.enrage) or jps.TimeToDie("target") < 12' },
		{fury.dragonroar, 'jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath)' },
		{fury.ragingblow, 'onCD' },
		{fury.wildstrike, 'jps.buff(fury.enrage) and jps.hp("target") > 0.20' },
		{fury.shockwave, 'not jps.talentInfo(fury.unquenchablethirst)' },
		{fury.arcanetorrent, 'not jps.talentInfo(fury.unquenchablethirst) and jps.hp("target") > 0.20' },
		{fury.bloodthirst, 'onCD' },
	}},
	
	{"nested", 'fh.UnitsAroundUnit("target") == 2',{
			{fury.ravager, 'jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath)' },
			{fury.dragonroar, 'jps.buff(fury.bloodbath) or  not jps.talentInfo(fury.bloodbath)' },
			{fury.bladestorm, 'jps.buff(fury.enrage)' },
			{fury.bloodthirst, 'not jps.buff(fury.enrage) or fury.rage() < 50 or not jps.buff(fury.ragingblow)' },
			{fury.execute, 'jps.hp("target") < 0.20 or jps.buff(fury.suddendeath)' },
			{fury.ragingblow, 'jps.buff(fury.meatcleaver)' },
			{fury.whirlwind, 'not jps.buff(fury.meatcleaver)' },
			{fury.wildstrike, 'jps.buff(fury.bloodsurge) and fury.rage() > 75' },
			{fury.bloodthirst, 'onCD' },
			{fury.whirlwind, 'fury.rage() > fury.maxRage(20)' },
			{fury.wildstrike, 'jps.buff(fury.bloodsurge)' },
	}},
	
	{"nested", 'fh.UnitsAroundUnit("target") == 3',{
	 	{ravager, 'jps.buff(fury.bloodbath) or  not jps.talentInfo(fury.bloodbath)' },
		{fury.bladestorm, 'jps.buff(fury.enrage) and IsControlKeyDown() == true' },
		{fury.bloodthirst, 'not jps.buff(fury.enrage) or fury.rage() < 50 or not jps.buff(fury.ragingblow)' },
		{fury.execute, 'jps.buff(fury.suddendeath)' },
		{fury.ragingblow, 'jps.buffStacks(fury.meatcleaver) >= 2' },
		{fury.dragonroar, 'jps.buff(fury.bloodbath) or  not jps.talentInfo(fury.bloodbath)' },
		{fury.whirlwind, 'onCD' },
		{fury.bloodthirst, 'onCD' },
		{fury.wildstrike, 'jps.buff(fury.bloodsurge)' },
	}},
	
	{"nested", 'fh.UnitsAroundUnit("target") > 3',{
		{fury.ravager, 'jps.buff(fury.bloodbath) or  not jps.talentInfo(fury.bloodbath)' },
		{fury.ragingblow, 'jps.buffStacks(fury.meatcleaver) >= 3 and jps.buff(fury.enrage)' },
		{fury.bloodthirst, 'not jps.buff(fury.enrage) or fury.rage() < 50 or not jps.buff(fury.ragingblow)' },
		{fury.ragingblow, 'jps.buffStacks(fury.meatcleaver) >= 3' },
		{fury.bladestorm, 'jps.buff(fury.enrage)  and IsControlKeyDown() == true' },
		{fury.whirlwind, 'onCD' },
		{fury.execute, 'jps.buff(fury.suddendeath)' },
		{fury.dragonroar, 'jps.buff(fury.bloodbath) or not jps.talentInfo(fury.bloodbath)' },
		{fury.bloodthirst, 'onCD' },
		{fury.wildstrike, 'jps.buff(fury.bloodsurge)' },
	}},
}
,"Default PvE" , true, false)