function priest_shadow(self)

local spell = nil
local nVampTouch = UnitDebuff("target", "Vampiric Touch",unitCaster=="player")
local nFouet = UnitDebuff("target","Mind Flay",unitCaster=="player")
local nOmbre = UnitBuff("player", "Empowered Shadow")
local nOrbe,_,_,nStackOrbe = UnitBuff("player", "Shadow Orb")
local nPain = UnitDebuff("target", "Shadow Word: Pain",unitCaster=="player")
local nPest = UnitDebuff("target","Devouring Plague",unitCaster=="player")
local nEvang,_,_,nStackEvang = UnitBuff("player","Dark Evangelism")


if not UnitChannelInfo("player") then 
   if not ub("player","Vampiric Embrace") and cd("Vampiric Embrace")==0 then
      spell= "Vampiric Embrace"
   elseif (UnitMana("player")/UnitManaMax("Player") < 0.80) and cd("Shadowfiend")==0 then
      spell= "Shadowfiend"
   elseif nOrbe~=nil and nOmbre==nil and cd("Mind Blast")==0 then
      spell= "Mind Blast"
   elseif nOrbe~=nil and nOmbre~=nil and nStackOrbe>=2 and cd("Mind Blast")==0 then
      spell= "Mind Blast"
   elseif nVampTouch==nil and cd("Vampiric Touch")==0 then 
      spell= "Vampiric Touch"
   elseif nPain==nil then
      spell= "Shadow Word: Pain"
   elseif nPest==nil and cd("Devouring Plague")==0 then
      spell= "Devouring Plague"
   elseif nEvang~=nil and nStackEvang>4 and cd("Archangel")==0 then
      spell= "Archangel"
   elseif cd("Shadow Word: Death")==0 and UnitHealth("player")/UnitHealthMax("player") > 0.5 then
      spell= "Shadow Word: Death"
      print("Shadow Word: Death")
   elseif nFouet==nil and cd("Mind Flay")==0 then
      spell= "Mind Flay"
   end
else return nil end
return spell
end

--[[
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
