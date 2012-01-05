--[[
	 JPS - WoW Protected Lua DPS AddOn
    Copyright (C) 2011 Jp Ganis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--
-- JPS Helper Functions
--jpganis

-- Lookup Tables
-- Credit (and thanks!) to BenPhelps
jps.Dispellable_Debuff = {
	["Magic"] = {
		"Static Disruption", -- Akil'zon
		"Consuming Darkness", -- Argaloth
		"Emberstrike", -- Erunak Stonespeaker
		"Binding Shadows", -- Erudax
		"Divine Reckoning", -- Temple Guardian Anhuur
		"Static Cling", -- Asaad, noobs shouldn't get hit by this, but get real....
		"Pain and Suffering", -- Baron Ashbury
		"Cursed Veil" -- Baron Silverlaine
		-- "Wither", -- Ammunae
	},
	
	["Poison"] = {
		"Viscous Poison", -- Lockmaw

	},
	
	["Disease"] = {
		"Plague of Ages", -- High Prophet Barim
	},
	
	["Curse"] = {
		"Curse of Blood", -- High Priestess Azil
		"Cursed Bullets", -- Lord Godfrey
	},
	
	["Enrage"] = { -- hunters pretty much
		"Enrage", -- Generic Enrage, used all over the place
	}	
}

jps_StunDebuff = {
		"Deep Freeze", -- Mage type magie -- Etourdit la cible pendant 5 sec. Utilisable uniquement sur les cibles gelées -- Deep Freeze
		"Cyclone", -- Druide type nil  -- Elle est incapable d'agir mais elle est invulnérable pendant 6 sec
		"Cheap Shot", -- Voleur type nil -- Etourdit la cible pendant 4 sec. Vous devez être camouflé -- Cheap Shot
		"Kidney Shot", -- Voleur type nil -- Coup de grâce qui étourdit la cible -- Kidney Shot
		"Bash", -- Druide type nil -- Etourdit la cible pendant 4 sec -- Bash
		"Consussion Blow", -- War type nil -- Etourdit l'adversaire pendant 5 sec -- Concussion Blow
		"Cécité", -- Voleur type nil -- Aveugle la cible et la force à errer, désorientée, pendant 1 min
		"Pounce", -- Druide type nil -- Attaque la cible par surprise et l'étourdit pendant 3 sec -- Pounce
		"Maim", -- Druide type nil -- Coup de grâce qui inflige des dégâts et étourdit la cible -- Maim
		"Assommer", -- Voleur type nil -- Stupéfie la cible pendant 1 min. au maximum
		"Contresort amélioré", -- Mage type nil -- Votre Contresort réduit également la cible au silence pendant 4 sec
		"Verrou magique", -- Demo type nil -- Réduit au silence l'ennemi pendant 3 sec ou 6 sec
		"Maléfice", -- Shaman type malediction -- Transforme l'ennemi en grenouille
		"Cri psychique", -- Pretre type magie -- fait fuir 5 ennemis qui se trouvent à moins de 8 mètres pendant 8 sec
		"Silence", -- Pretre type magie -- Rend la cible silencieuse, l'empêchant de lancer des sorts pendant 5 sec
		"Peur", -- Demo type magie -- Effraie l'ennemi et l'oblige à s'enfuir pendant 20 sec. au maximum
		"Hammer of Justice", -- Paladin type magie -- Etourdit la cible pendant 6 sec -- Hammer of Justice
		"Contrôle mental", -- Pretre type magie
		"Métamorphose", -- Mage type magie
		"Strangulation", -- DK type magie -- Etrangle un ennemi, ce qui le réduit au silence pendant 5 sec
		"Bouclier du vengeur", -- Paladin type magie -- réduit la cible au silence et interrompt les incantations pendant 3 sec
		"Hurlement de terreur", -- Demo -- Un rugissement qui oblige 5 ennemis se trouvant dans un rayon de 10 mètres à fuir pendant 8 sec
		"Sarments", -- Druide -- Immobilise la cible sur place pendant 30 sec. Si la cible subit des dégâts, l'effet peut être interrompu
		"Contrôle mental", -- Pretre
		"Anneau de givre", -- Mage -- Les ennemis qui entrent dans l'anneau pleinement formé sont gelés pendant 10 sec
		"Hurlement de terreur", -- Demo -- Un rugissement qui oblige 5 ennemis se trouvant dans un rayon de 10 mètres à fuir pendant 8 sec
		"Impact", -- Mage -- 10% de chances d'étourdir la cible pendant 2 sec -- Impact
		"Intimidation" -- Chasseur type nil -- Ordonne à votre familier d'intimider la cible, étourdissant la cible pendant 3 sec -- Intimidation
		
}

jps_DispellOffensive = {
		"Innervation", -- Druide
		"Mot de pouvoir : Bouclier", -- Pretre
		"Loup fantôme", -- Shaman
		"Mot de pouvoir : Robustesse", -- Pretre
		"Récupération", -- Druide
		"Rétablissement", -- Druide
		"Marque du fauve", -- Druide
		"Héroïsme", -- Shaman
		"Furie sanguinaire", -- Shaman
		"Illumination des Arcanes", -- Mage
		"Barrière de glace", -- Mage
		"Armure du mage", -- Mage
		"Courroux vengeur", -- Paladin
		"Supplique divine" -- Paladin
}


jps_DispellMagic =  {
		"Mot de l'ombre : Douleur", -- Pretre
		"Cri psychique", -- Pretre
		"Horreur psychique", -- Pretre -- Vous terrifiez la cible, qui tremble, horrifiée, pendant 3 sec
		"Contrôle mental", -- Pretre
		"Sarments", -- Druide -- Immobilise la cible sur place pendant 30 sec. Si la cible subit des dégâts, l'effet peut être interrompu
		"Métamorphose", -- Mage
		"Souffle du dragon", -- Mage -- les cibles sont désorientées pendant 5 sec. Toute attaque directe qui inflige des dégâts réveille la cible
		"Anneau de givre", -- Mage -- Les ennemis qui entrent dans l'anneau pleinement formé sont gelés pendant 10 sec
		"Nova de givre", -- Mage -- gèle les cibles sur place pendant 8 sec. Si une cible subit des dégâts, l'effet peut être interrompu sur elle
		"Lenteur", -- Mage -- Réduit la vitesse de déplacement de la cible de 60%
		"Corruption", -- Demo -- Corrompt la cible et lui inflige 882 points de dégâts d'Ombre en 18 sec
		"Hurlement de terreur", -- Demo -- Un rugissement qui oblige 5 ennemis se trouvant dans un rayon de 10 mètres à fuir pendant 8 sec
		"Peur", -- Demo -- Effraie l'ennemi et l'oblige à s'enfuir pendant 20 sec. au maximum
		"Souffle de lave", -- Chasseur -- Votre familier projette sur la cible un double jet de lave en fusion qui réduit la vitesse d'incantation de celle-ci de 25% pendant 10 sec
		"Flèche-bâillon", -- Chasseur -- Un tir qui réduit la cible au silence et interrompt les incantations pendant 3 sec
		"Gel", -- Mage -- Elementaire d'eau gèle la cible sur place pendant 8 sec. au maximum. Si une cible subit des dégâts, l'effet peut être interrompu sur elle
		"Congélation", -- Mage
		"Strangulation", -- DK
		"Silence", -- Pretre
		"Marteau de la justice", -- Paladin
		"Bouclier du vengeur" -- Paladin
}


jps_DispellDisease =  {
		"Fièvre de givre", -- DK
		"Peste dévorante", -- Pretre
		"Peste de sang" -- DK impie
}


jps_Test = {
	{Name = "Mark", HP = 50, Breed = "Ghost"}, 
	{Name = "Stan", HP = 25, Breed = "Zombie"}, 
	{Name = "Julie", HP = 100, Breed = "Human"}
}

jps_Test_1 = { 
		["Mark"] = {Name = "Mark", HP = 50, Breed = "Ghost"}, 
		["Stan"] = {Name = "Stan", HP = 25, Breed = "Zombie"}, 
		["Julie"] = {Name = "Julie", HP = 100, Breed = "Human"}
}

function jps_test()

print("GetNumRaidMembers(): ",GetNumRaidMembers()) -- always nil
print("Spell: ",select(2,GetSpellBookItemInfo("Prière du désespoir"))) -- nothing
print("Spell: ",GetSpellBookItemInfo("Don des naaru")) -- spellID
print("Spellselect: ",select(2,GetSpellBookItemInfo("Don des naaru"))) -- spellID
end

----------------------------
-- Casting functions      --
----------------------------

function jps.Cast(spell)
	if not jps.Target then jps.Target = "target" end
	if not jps.Casting then jps.LastCast = spell end
	CastSpellByName(spell,jps.Target)
	jps.LastTarget = jps.Target
	if jps.IconSpell ~= spell then
		jps.set_jps_icon(spell)
		if jps.Debug then write(spell, GetUnitName(jps.Target)) end
	end
	jps.Target = nil
end

function jps.canCast(spell, unit)
	if not unit then unit = "target" end
	local _, spellID = GetSpellBookItemInfo(spell)
	local usable, nomana = IsUsableSpell(spell)
	local inrange = IsSpellInRange(spell, unit) -- '0' if out of range, '1' if in range, or 'nil' if the unit is invalid.

	if jps.cooldown(spell) ~= 0	then return false end
	if not UnitExists(unit) then return false end
	if UnitIsDeadOrGhost(unit) then return false end
	if not usable then return false end
	if nomana then return false end
	if not UnitIsVisible(unit) then return false end
	if not IsSpellKnown(spellID) then return false end
	if inrange==0 then return false end

	return true
end

function jps.canHeal(unit)
	if not unit then unit = "target" end

	if UnitExists(unit)~=1 then return false end
	if UnitIsVisible(unit)~=1 then return false end
	if UnitIsPlayer(unit)~=1 then return false end
	if UnitIsFriend("player",unit)~=1 then return false end
	if not UnitInRange(unit) then return false end
	if UnitIsDeadOrGhost(unit)==1 then return false end
	
	return true
end

function jps.groundClick()
	CameraOrSelectOrMoveStart()
	CameraOrSelectOrMoveStop()
end

--------------------------
-- Dispell TABLE
--------------------------

function jps.canDispell( unit, ... )
	for _, dtype in pairs(...) do
		if jps_Dispellable_Debuff[dtype] ~= nil then
			for _, spell in pairs(jps_Dispellable_Debuff[dtype]) do
				if ud(unit,spell) then return true end
			end
		end
	end
	return false
end

-- jps.findMeDispelTarget({"Poison"},{"Disease"},{"Magic"})
-- jps.findMeDispelTarget({"Boss"})
function jps.findMeDispelTarget(dispelType) 
    for unit, _ in pairs(jps.RaidStatus) do
		if jps.canDispell( unit, dispelType ) then return unit end
	end
end

function jps.isStun()
	for i, j in ipairs(jps_StunDebuff) do
		local stunName = select(1,UnitDebuff("player",j))
		if stunName then return true end
	end
	return false
end

function jps.canDispellMagic(unit)
	if not unit then unit = "player" end
	if UnitExists(unit)==1 and UnitIsFriend("player",unit)==1 and jps.canHeal(unit) then
		for i, j in ipairs(jps_DispellMagic) do
			local magicName = select(1,UnitDebuff(unit,j)) -- UnitDebuff(unit,j)
			if magicName then return true end
		end
	end
	return false
end

function jps.canDispellDisease(unit)
	if not unit then unit = "player" end
	if UnitExists(unit)==1 and UnitIsFriend("player",unit)==1 and jps.canHeal(unit) then
		for i, j in ipairs(jps_DispellDisease) do
			local disName = select(1,UnitDebuff(unit,j)) -- UnitDebuff(unit,j) 
			if disName then return true end
		end
	end
	return false
end

function jps.canDispellOffensive(unit)
	if not unit then return false end
	if UnitExists(unit)==1 and UnitIsEnemy("player",unit)==1 and UnitCanAttack("player", unit)==1 then
		for i, j in ipairs(jps_DispellOffensive) do 
			local offName,_,_,_,offType,_,_,_,_,_,_ = UnitBuff(unit,j)
			if offName and offType=="Magic" then  
			return true end
		end
	end
	return false
end

--------------------------
-- Dispell LOOP
--------------------------

function jps.DispellDebuff(unit,dispelType) -- jps.DispellDebuff(unit,"Magic") 
	if not unit then unit = "player" end 
	if not dispelType then dispelType = "Magic" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
	if UnitExists(unit)==1 and UnitIsFriend("player",unit)==1 and jps.canHeal(unit) then 
		while auraName do
			if debuffType == dispelType then -- Catch Poison/Curse/Magic/Disease
			return true end
			i = i + 1
			auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
		end
	end
	return false
end

function jps.findDispelTarget(dispelType) -- jps.findDispelTarget("Magic")
	for unit,_ in pairs(jps.GroupStatus) do	 
		if jps.DispellDebuff(unit,dispelType) then return unit end
	end
end

function jps.MagicDispell(unit) 
	if not unit then unit = "player" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
	if UnitExists(unit)==1 and UnitIsFriend("player",unit)==1 and jps.canHeal(unit) then 
		while auraName do
			if debuffType=="Magic" then 
			return true end
			i = i + 1
			auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
		end
	end
	return false
end

function jps.DiseaseDispell(unit) 
	if not unit then unit = "player" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
	if UnitExists(unit)==1 and UnitIsFriend("player",unit)==1 and jps.canHeal(unit) then 
		while auraName do
			if debuffType=="Disease" then 
			return true end
			i = i + 1
			auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, _ = UnitDebuff(unit, i)
		end
	end
	return false
end

----------------------------
-- Spell Cooldowns        --
----------------------------

function jps.MageSheepDuration(unit)
	if not unit then return 0 end
	local localizedClass, _ = UnitClass(unit)
	local spell, _, _, _, _, endTime = UnitCastingInfo(unit) 
	if localizedClass== "Mage" and spell == "Polymorph" then 
		local delay = endTime-GetTime()
	else delay = 0 end
	return delay
end

function jps.cooldown(spell)
	local start,duration,_ = GetSpellCooldown(spell)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

-- Shorthand
jps.cd = jps.cooldown

function jps.itemCooldown(item)
	local start,duration,_ = GetItemCooldown(item)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

function jps.petCooldown(index)
	local start,duration,_ = GetPetActionCooldown(index)
	local cd = start+duration-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end

----------------------------
-- Spell Buffs            --
----------------------------

function jps.buff( spell, unit )
	if unit == nil then unit = "player" end
	local buff,_,_,_,_,_,_,_,_,_,_ = UnitBuff(unit, spell)
	if buff ~= nil then return true end
	return false
end

function jps.buffDuration( spell, unit)
	if unit == nil then unit = "player" end
	local _,_,_,_,_,_,expire,caster,_,_,_ = UnitBuff(unit,spell)
	if caster ~= "player" then return 0 end
	if expire == nil then return 0 end
	duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmyBuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,expire,_,_,_,_ = UnitBuff(unit,spell)
	if expire == nil then return 0 end
	duration = expire-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.buffStacks( spell, unit )
	if unit == nil then unit = "player" end
	local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spell)
	if count == nil then count = 0 end
	return count
end

----------------------------
-- Spell Debuffs          --
----------------------------

function jps.debuff( spell, unit )
	if unit == nil then unit = "target" end
	if UnitDebuff(unit, spell) then return true end
	return false
end

function jps.debuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spell)
	if caster~="player" then return 0 end
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.notmyDebuffDuration( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,_,_,_,duration,_,caster,_,_ = UnitDebuff(unit,spell)
	if duration==nil then return 0 end
	duration = duration-GetTime()-jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffStacks( spell, unit )
	if unit == nil then unit = "target" end
	local _,_,_,count, _,_,_,caster, _,_ = UnitDebuff(unit,spell)
	if caster ~= "player" then return 0 end
	if count == nil then count = 0 end
	return count
end


function jps.bloodlusting()
	return jps.buff("bloodlust") or jps.buff("heroism") or jps.buff("time warp") or jps.buff("ancient hysteria")
end

function jps.shouldKick(unit)
	if unit == nil then unit = "target" end
    local target_spell, _, _, _, _, endTime, _, _, unInterruptable = UnitCastingInfo(unit)
	local channelling, _, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit)
	if target_spell == "Release Aberrations" then return false end

	if target_spell and not unInterruptable then
		return true
		--if not jps.PvP then return true 
		--else return endTime-GetTime()*1000 < 333+jps.Lag end

	elseif chanelling and not notInterruptible then
		return true

	end 
	return false
end

-- Racial/Profession CDs Check
function jps.checkProfsAndRacials()
	-- Draenei, Dwarf, Worgen, Human, Gnome, Night Elf
	-- Tauren, Goblin, Orc, Troll, Forsaken, Blood Elf
	local usables = {}
	local moves =
	{
		"lifeblood",
		"berserking",
		"blood fury",
		--"engiGloves",
		--"gift of the naaru",
		--"stoneform",
		--"arcane torrent",
		--"will of the forsaken",
	}

	for _, move in pairs(moves) do
		if GetSpellBookItemInfo(move) then
			table.insert(usables,move)
		end
	end

	return usables

end

function jps.targetTargetTank()
	if jps.buff("bear form","targettarget") then return true end
	if jps.buff("blood presence","targettarget") then return true end
	if jps.buff("righteous fury","targettarget") then return true end
	
	local _,_,_,_,_,_,_,caster,_,_ = UnitDebuff("target","Sunder Armor")
	if caster ~= nil then
		if UnitName("targettarget") == caster then return true end end
	
	return false
end

----------------------------
-- Functions for Finding Tanks  --
----------------------------

function jps.couldBeTank( unit )
	if UnitGroupRolesAssigned(unit) == "TANK" then return true
	elseif jps.buff( "righteous fury",unit ) then return true
	elseif jps.buff( "blood presence",unit ) then return true
	elseif jps.buff( "bear form",unit ) then return true
	end
end

function jps.findMeATank()
	if UnitExists("focus") then return "focus" end

	for unit, _ in pairs(jps.RaidStatus) do
		if jps.couldBeTank( unit ) then return unit end
	end

	return "player"
end

local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local function GetSpellIfo(a)
	return unpack(a)
end

-- Ty to CDO for this code.
hooksecurefunc("UseAction", function(...)
	if jps.Enabled and select(3, ...) ~= nil then
		local stype, id = GetActionInfo( select(1, ...) )
		if stype == "spell" then
			local name,_,_,_,_,_,_,_,_ = GetSpellInfo(id)
			if jps.NextCast ~= name then 
				jps.NextCast = name
				if jps.Combat then write("Set",name,"for next cast.") end
			end
		end
	end
end)

----------------------------
-- Rotation Timers | Thanks Phelps! --
----------------------------

function jps.createTimer( name, duration )
	jps.Timers[name] = duration+GetTime()
end

function jps.checkTimer( name )
	if jps.Timers[name] ~= nil then
		local now = GetTime()
		if jps.Timers[name] < now then
			jps.Timers[name] = nil
			return 0
		else
			return jps.Timers[name] - now
		end
	end
	return 0
end