---------------------------
-- TABLES
---------------------------

--[[ 
-- Declare this near the top of your addon
local L = setmetatable({}, {__index=function(L,key) return key end})
 
-- Later when you want to add a locale, change the declaration of L to include the new language in the base table
local L = setmetatable(GetLocale() == "frFR" and {
   ["Hello World"] = "Bonjour la Terre",
} or {}, {__index=function(L,key) return key end})
]]

--[[
local function defaultFunc(L, key)
	return key
end
MyLocalizationTable = setmetatable({}, {__index=defaultFunc})

local L = MyLocalizationTable
if GetLocale() == "frFR" then
 L["Hello World"] = "Bonjour la Terre"
end
]]

--[[
if (GetLocale() == "frFR") then
      MyLocalizationTable = setmetatable({
        ["Hello World"] = "Bonjour la Terre",
        ["Smite"] = "Brulure",         
      }, {
         __index = function(t, index) return index end
      })
end
local L = MyLocalizationTable
]]

do
	if (GetLocale() == "frFR") then
		MyLocalizationTable = setmetatable({
	-- Spells for crowd Control
		["Strikes"] = "Effraie",
		["Roots"] = "Immobilise",
		["Transforms"] = "Transforme",
		["Forces"] = "Force",
		["Seduces"] = "Séduit", 
	-- Spells for healtable
		["Renew"] = "Rénovation",
		["Heal"] = "Soins",
		["Greater Heal"] = "Soins supérieurs",
		["Penance"] = "Pénitence",
		["Flash Heal"] = "Soins rapides",
	-- DeBuff to dispel	
		["Death Coil"] = "Voile mortel",
		["Dragon's Breath"] = "Souffle du dragon",
		["Polymorph"] = "Métamorphose",
		["Frost Nova"] = "Nova de givre",
		["Fear"] = 	"Peur",
		["Psychic Scream"] = "Cri psychique",
		["Freeze"] = "Gel",
		["Deep Freeze"] = "Congélation",
		["Howl of Terror"] = "Hurlement de terreur",
		["Counterspell"] = "Contresort",
		["Entangling Roots"] = "Sarments",
		["Hammer of Justice"] = "Marteau de justice",
		["Cyclone"] = "Cyclone",
		["Chilled"] = "Transi",
		["Earthbind"] =	"Lien à la terre",								
		["Ring of Frost"] = "Anneau de givre",
		["Living Bomb"] = "Bombe vivante",
		["Combustion"] = "Combustion",
		["Repentance"] = "Repentir",
		["Freezing Trap"] = "Piège givrant",
	-- Buff to dispel
		["Archangel"] = "Archange",
		["Frost Armor"] = "Armure de givre",
		["Power Word: Shield"] = "Mot de pouvoir : Bouclier",
		["Fear Ward"] = "Gardien de peur",
		["Hand of Protection"] = "Main de protection",
		["Incanter's Ward"] = "Protection de l’incantateur",
		["Avenging Wrath"] = "Courroux vengeur",
		["Predatory Swiftness"] = "Rapidité du prédateur",
		["Ice Barrier"] = "Barrière de glace",
	-- Stun debuff
		["Silenced Improved Counterspell"] = "Réduit au silence - Contresort amélioré",
		["Fist of Justice"] = "Poing de la justice",
		["Silence"] = "Silence",
		["Garrote"] = "Garrot",
		["Garrote - Silence"] = "Garrot - Silence",
		["Can't do that while silenced"] = "Impossible lorsque vous êtes réduit(e) au silence",
		["Can't do that while stunned"] = "Impossible lorsque vous êtes étourdi(e)", -- "Impossible lorsque vous êtes assomé(e)",
		["Can't do that while horrified"] = "Impossible lorsque vous êtes horrifié(e)",
		["Can't do that while disoriented"] = "Impossible lorsque vous êtes désorienté(e)",
		["Can't do that while banished"] = "Impossible lorsque vous êtes banni(e)",
		["Can't do that while fleeing"] =  "Impossible lorsque vous êtes en fuite" ,
		["Can't do that while asleep"] =  "Impossible lorsque vous êtes endormi(e)" ,
	-- localization for jps.lua & jps.data & Rotations
		["You are facing the wrong way!"] = "Vous ne faites pas face à la bonne direction !",
		["Target not in line of sight"] = "Cible hors du champ de vision",
		["Target needs to be in front of you."] = "Les cibles doivent être devant vous.",
		["Out of range"] = "Hors de portée",
		["Your vision of the target is obscured"] = "Votre vision de la cible est obscurci(e)",
		["Release Aberrations"] = "Libération des aberrations",
		["Murglesnout"] = "Murgouilla",
		["Golden Carp"] = "Carpe dorée",
		["Drink"] = "Boisson",
		["Polymorph"] = "Métamorphose",
	-- Localization for Class & Spec
		["Training Dummy"]= "Mannequin d'entraînement",
		["Raider's Training Dummy"] = "Mannequin d'entraînement d'écumeur de raids",
		["Dungeoneer's Training Dummy"] ="",
		["Healing Dummy"] ="",
		["Combat Dummy"] ="",
		["Advanced Target Dummy"] ="",
		["Dummy"] ="Mannequin",
		["Discipline"] = "Discipline",
		["Holy"] = "Sacré",
		["Restoration"] = "Restauration",
		["Mistweaver"] = "Tisse-brume",
		["Priest"] = "Prêtre",
		["Druid"] = "Druide",
		["Paladin"] = "Paladin",
		["Mage"] = "Mage",
		["Warlock"] = "Démoniste",
		["Shaman"] = "Shaman",
		["Warrior"] = "Guerrier",
		["Paladin"] = "Paladin",
		["Death Knight"] = "Chevalier de la mort",
		["Hunter"] = "Chasseur",
		["Rogue"] = "Voleur",
		["Use"] = "Utiliser",
		} , {__index = function(t, index) return index end})
	elseif (GetLocale() == "deDE") then
			MyLocalizationTable = setmetatable({
	-- localization for jps.lua & jps.data & Rotations
		["Drink"] = "Trinken",
	-- Localization for Class & Spec

		["Dummy"] ="Trainingsattrappe",
		["Discipline"] = "Disziplin",
		["Holy"] = "Heilig",
		["Restoration"] = "Wiederherstellungs",
		["Mistweaver"] = "Nebelwiker",
		["Priest"] = "Priester",
		["Druid"] = "Druide",
		["Paladin"] = "Paladin",
		["Mage"] = "Magier",
		["Warlock"] = "Hexenmeister",
		["Shaman"] = "Schamane",
		["Warrior"] = "Krieger",
		["Paladin"] = "Paladin",
		["Death Knight"] = "Todesritter",
		["Hunter"] = "Jäger",
		["Rogue"] = "Schurke",
		["Use"] = "Benutzen",
		} , {__index = function(t, index) return index end})
	elseif (GetLocale() == "ruRU") then
			MyLocalizationTable = setmetatable({		
				-- DeBuff to dispel	
		["Death Coil"] = "Лик смерти",
		["Dragon's Breath"] = "Дыхание дракона",
		["Polymorph"] = "Превращение",
		["Frost Nova"] = "Кольцо льда",
		["Fear"] = 	"Страх",
		["Psychic Scream"] = "Ментальный крик",
		["Freeze"] = "Холод",
		["Deep Freeze"] = "Глубокая заморозка",
		["Howl of Terror"] = "Вой ужаса",
		["Counterspell"] = "Антимагия",
		["Entangling Roots"] = "Гнев деревьев",
		["Hammer of Justice"] = "Молот правосудия",
		["Cyclone"] = "Смерч",
		["Chilled"] = "Окоченение",
		["Earthbind"] =	"Тотем оков земли",								
		["Ring of Frost"] = "Кольцо мороза",
		["Living Bomb"] = "Живая бомба",
		["Combustion"] = "Возгорание",
		["Repentance"] = "Покаяние",
		["Freezing Trap"] = "Замораживающая ловушка",
			-- Buff to dispel
		["Archangel"] = "Архангел",
		["Frost Armor"] = "Морозный доспех",
		["Power Word: Shield"] = "Слово силы: Щит",
		["Fear Ward"] = "Защита от страха",
		["Длань защиты"] = "Длань защиты",
		["Incanter's Ward"] = 1463, --not found ru spellname
		["Avenging Wrath"] = "Гнев карателя",
		["Predatory Swiftness"] = "Стремительность хищника",
		["Ice Barrier"] = "Ледяная преграда",
		-- Spells for healtable
		["Renew"] = "Обновление",
		["Heal"] = "Исцеление",
		["Greater Heal"] = "Великое исцеление",
		["Penance"] = "Исповедь",
		["Flash Heal"] = "Быстрое исцеление",
			-- Stun debuff
		["Silenced Improved Counterspell"] = "Улучшенная Антимагия",
		["Fist of Justice"] = "Кулак правосудия",
		["Silence"] = "Безмолвие",
		["Garrote"] = "Гаррота",
		["Garrote - Silence"] = "Гаррота - немота",
		["Can't do that while silenced"] = "Не могу этого сделать, пока Безмолвие",
		["Can't do that while stunned"] = "Не могу этого сделать, пока Оглушение(я)", -- "Impossible lorsque vous êtes assomé(e)",
		["Can't do that while horrified"] = "Не могу этого сделать, пока Ужас",
		["Can't do that while disoriented"] = "Не могу этого сделать, пока Дезориентирован",
		["Can't do that while banished"] = "Не могу этого сделать, пока Изгнание(я)",
		["Can't do that while fleeing"] =  "Не могу этого сделать, пока бежите" ,
		["Can't do that while asleep"] =  "Не могу этого сделать, пока Сон(ны)" ,
			-- localization for jps.lua & jps.data & Rotations
		["You are facing the wrong way!"] = "Вы повернуты не в ту сторону!",
		["Target not in line of sight"] = "Цель не в зоне прямой видимости",
		["Target needs to be in front of you."] = "Цель должна быть перед вами.",
		["Out of range"] = "Вне досягаемости",
		["Your vision of the target is obscured"] = "Ваша цель скрылась",
		["Release Aberrations"] = "Освобождение аберраций",
		["Murglesnout"] = "Мурглонос",
		["Golden Carp"] = "Золотистый карп",
		["Drink"] = "Питье",
		["Polymorph"] = "Превращение",
				-- Localization for Class & Spec
		["Training Dummy"]= "Тренировочный манекен",
		["Raider's Training Dummy"] = "Тренировочный манекен рейдера",
		["Dungeoneer's Training Dummy"] ="",
		["Healing Dummy"] ="",
		["Combat Dummy"] ="",
		["Advanced Target Dummy"] ="",
		["Dummy"] ="Тренировочный манекен",
		["Discipline"] = "Послушание",
		["Holy"] = "Свет",
		["Restoration"] = "Исцеление",
		["Mistweaver"] = "Ткач туманов",
		["Priest"] = "Жрец",
		["Druid"] = "Друид",
		["Paladin"] = "Паладин",
		["Mage"] = "Маг",
		["Warlock"] = "Чернокнижник",
		["Shaman"] = "Шаман",
		["Warrior"] = "Воин",
		["Paladin"] = "Паладин",
		["Death Knight"] = "Рыцарь смерти",
		["Hunter"] = "Охотник",
		["Rogue"] = "Разбойник",
		["Use"] = "Использовать",
		} , {__index = function(t, index) return index end})
	else
		MyLocalizationTable = setmetatable({}, {__index = function(t, index) return index end})
	end
end


