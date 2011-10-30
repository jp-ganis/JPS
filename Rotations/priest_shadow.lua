function priest_shadow(self)

local spell = nil
--local nVampTouch = UnitDebuff("target", "Vampiric Touch",unitCaster=="player")
local nFouet = UnitDebuff("target","Mind Flay",unitCaster=="player")
local nOmbre = UnitBuff("player", "Empowered Shadow")
local nOrbe,_,_,nStackOrbe = UnitBuff("player", "Shadow Orb")
local nPain = UnitDebuff("target", "Shadow Word: Pain",unitCaster=="player");
local nPest = UnitDebuff("target","Devouring Plague",unitCaster=="player")
local nEvang,_,_,nStackEvang = UnitBuff("player","Dark Evangelism")
local nMelt,_,_,nStackMelt = UnitBuff("player","Mind Melt")

-- adjust VTcastingtime to the value of Tooltip
VTcastingtime = 1.26
local nVampTouch, _, _,_, _, duration, VTexpire, _, _, _, _ = UnitAura("target", "Vampiric Touch", nil, "PLAYER|HARMFUL")
VTtouchRemainingTime = 999
if nVampTouch then VTtouchRemainingTime = VTexpire - GetTime() end

if not UnitChannelInfo("player") and UnitCanAttack("player","target") then 
	if not ub("player","Vampiric Embrace") and cd("Vampiric Embrace")==0 then
		spell= "Vampiric Embrace"
	elseif not ub("player","Shadowform") then
		spell = "Shadowform"
	-- Mot de pouvoir Bouclier
	elseif (UnitHealth("player") / UnitHealthMax("player") < 0.10) and cd("Power Word: Shield")==0 and not ud("player","Weakened Soul") and not ub("player","Power Word: Shield") then
		spell= "Power Word: Shield"
	elseif (UnitMana("player")/UnitManaMax("Player") < 0.70) and cd("Shadowfiend")==0 and IsUsableSpell("Shadowfiend") and UnitHealth("target") > 1000000 then
		spell= "Shadowfiend"

	-- IsMouseButtonDown([button]) 1 or LeftButton - 2 or RightButton - 3 or MiddleButton or clickable scroll control
	elseif IsMouseButtonDown(3) and cd("Mind Sear")==0 and IsUsableSpell("Mind Sear") then
		if nOmbre~=nil then
			spell= "Mind Sear"
		elseif nOrbe~=nil and nOmbre==nil and cd("Mind Blast")==0 and IsUsableSpell("Mind Blast") then
			spell= "Mind Blast"
		else
			spell= "Mind Sear"
		end
	-- to avoid dot on a unique target with low life
	elseif IsMouseButtonDown(2) and UnitHealth("target") < 40000 and cd("Mind Spike")==0 and IsUsableSpell("Mind Spike") then
		if nMelt~=nil and nStackMelt>1 and cd("Mind Blast")==0 and IsUsableSpell("Mind Blast") then
			spell= "Mind Blast"
		else
			spell= "Mind Spike"
		end
	-- moving
	elseif (GetUnitSpeed("player") / 7) > 0 then
		if (UnitMana("player")/UnitManaMax("Player") < 0.70) and cd("Shadowfiend")==0 and IsUsableSpell("Shadowfiend") and UnitHealth("target") > 1000000 then
			spell= "Shadowfiend"
		elseif cd("Shadow Word: Death")==0 and IsUsableSpell("Shadow Word: Death") and UnitHealth("player")/UnitHealthMax("player") > 0.75 then
			spell= "Shadow Word: Death"
		elseif nPain==nil and IsUsableSpell("Shadow Word: Pain") then
			spell= "Shadow Word: Pain"
		elseif nPest==nil and cd("Devouring Plague")==0 and IsUsableSpell("Devouring Plague") then
			spell= "Devouring Plague"
		end

	elseif nOrbe~=nil and nOmbre==nil and cd("Mind Blast")==0 and IsUsableSpell("Mind Blast") then
		spell= "Mind Blast"
	elseif (VTtouchRemainingTime < VTcastingtime) and cd("Vampiric Touch")==0 and IsUsableSpell("Vampiric Touch") and not (jps.LastCast=="Vampiric Touch") then 
		spell= "Vampiric Touch"
	elseif nVampTouch==nil and cd("Vampiric Touch")==0 and IsUsableSpell("Vampiric Touch") and not (jps.LastCast=="Vampiric Touch") then 
		spell= "Vampiric Touch"
	elseif nOrbe~=nil and nOmbre~=nil and nStackOrbe >= 1 and cd("Mind Blast")==0 and IsUsableSpell("Mind Blast")  then
		spell= "Mind Blast"
	elseif nPain==nil and IsUsableSpell("Shadow Word: Pain") then
		spell= "Shadow Word: Pain"
	elseif nPest==nil and cd("Devouring Plague")==0 and IsUsableSpell("Devouring Plague") then
		spell= "Devouring Plague"
	elseif nEvang~=nil and nStackEvang > 4 and cd("Archangel")==0 and IsUsableSpell("Archangel") then
		spell= "Archangel"
	elseif cd("Shadow Word: Death")==0 and IsUsableSpell("Shadow Word: Death") and UnitHealth("player")/UnitHealthMax("player") > 0.75 then
		spell= "Shadow Word: Death"
	elseif nFouet==nil and cd("Mind Flay")==0 and IsUsableSpell("Mind Flay") then
		spell= "Mind Flay"
	end
else return end
return spell
end

--[[
Pointe mentale - Mind Spike
Fonte de l'esprit - Mind Melt
Incandescence mentale - Mind Sear
Ame affaiblie - Weakened Soul
Mot de pouvoir : Bouclier - Power Word: Shield
Forme d'ombre - Shadowform
Etreinte vampirique - Vampiric Embrace
Toucher vampirique - Vampiric Touch
Mot de l'ombre : Douleur - Shadow Word: Pain
Peste dévorante - Devouring Plague
Attaque mentale - Mind Blast
Mot de l'ombre : Mort - Shadow Word: Death
Ombrefiel - Shadowfiend
Sombre évangélisme - Dark Evangelism
Archange - Archangel
Fouet mental - Mind Flay
Ombre surpuissante - Empowered Shadow
Orbe d'ombre - Shadow Orb
]]
