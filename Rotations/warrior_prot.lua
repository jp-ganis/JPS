function warrior_prot(self)

if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

local spell = nil
local playerHealth = UnitHealth("player")/UnitHealthMax("player")
local targetHealth = UnitHealth("target")/UnitHealthMax("target")
local nEnrage = jps.buff("Enrage","player")
local nRage = jps.buff("Berserker Rage","player")
local nPower = UnitPower("Player",1) -- Rage est PowerType 1
local stackSunder = jps.debuffStacks("Sunder Armor")
local stackThunder = jps.buffStacks("Thunderstruck")

	local spellTable = 
	{
		{ "Battle Shout" , not ub("player","Battle Shout") , "player" },
		{ "Berserker Rage" , not nRage , "player" },
		{ "Shield Wall" , UnitHealth('player')<30000 , "target" },
		{ "Last Stand" , UnitHealth('player')<30000 , "target" },
		{ "Enraged Regeneration" , playerHealth<0.60 , "target" },
		{ "Lifeblood" , "onCD" , "player" },
		{ "Shield Block" , playerHealth<0.60 , "target" },
		{ "Charge" , jps.UseCDs , "target" },
		{ "Heroic Throw" , "onCD" , "target" },
		{ "Taunt" , jps.UseCDs and UnitThreatSituation("player","target")~=3 , "target" },
		{ "Pummel" , jps.shouldKick("target") , "target" },
		{ "Spell Reflection" , (UnitCastingInfo("target") or UnitChannelInfo("target")) , "target" },
		{ "Victory Rush" , ub("player","Victorious") , "target" },
		{ "Shockwave" , jps.MultiTarget and stackThunder>1 , "target" },
		{ "Thunder Clap" , jps.MultiTarget , "target" },
		{ "Devastate" , not ud("target","Sunder Armor") , "target" },
		{ "Shield Slam" , "onCD" , "target" },
		{ "Devastate" , stackSunder<3 , "target" },
		{ "Devastate" , ub("player","Sword and Board") , "target" },
		{ "Revenge" , "onCD" , "target" },
		{ "Heroic Strike" , ub("player","Incite") , "target" },
		{ "Heroic Strike" , nPower>70 , "target" },
		{ "Concussion Blow" , "onCD" , "target" },
		{ "Devastate" , "onCD" , "target" },
		{ "Rend" , not UnitDebuff("target","Rend") , "target" },
		{ {"macro","/startattack"}, nil, "target" },
	}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
end