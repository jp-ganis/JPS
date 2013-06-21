local L = MyLocalizationTable
-- TO DO : need better code style!!!!
function warrior_fury()

	local player = jpsName
	local playerhealth_deficiency =  UnitHealthMax(player) - UnitHealth(player)
	local playerhealth_pct = jps.hp(player) 

	local EnemyUnit = {}
	for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end -- EnemyUnit[1]
	local enemyTargetingMe = jps.IstargetMe()

	local rangedTarget = "target"
	if jps.canDPS("target") then
	rangedTarget = "target"
	elseif jps.canDPS("focustarget") then
	rangedTarget = "focustarget"
	elseif jps.canDPS("targettarget") then
	rangedTarget = "targettarget"
	elseif jps.canDPS(enemyTargetingMe) then
	rangedTarget = enemyTargetingMe
	elseif jps.canDPS(EnemyUnit[1]) then
	rangedTarget = EnemyUnit[1]
	end
	
	local Class, _ = UnitClass(rangedTarget)
	local ClassCac = false
	local ClassCaCTable = {L["Warrior"],L["Paladin"],L["Death Knight"],L["Rogue"]}
	for i,unitClass in pairs(ClassCaCTable) do
		if Class == unitClass then 
			ClassCac = true 
		break end
	end
	
	local player_Aggro = jps.checkTimer( "Player_Aggro" )
	local nRage = jps.buff(12880) -- "Enrage" 12880 "Enrager"
	local targetHealth = jps.hp("target")
	local targetHealthAbs = jps.hp("target","abs")
	local nPower = UnitPower("Player",1) -- Rage est PowerType 1
	local stunMe = jps.StunEvents() -- return true/false
	local enemycount,targetcount = jps.RaidEnemyCount()  
	local leap = tostring(select(1,GetSpellInfo(6544))) -- select(1,GetSpellBookItemName(17, "spell"))  -- "Heroic Leap" 6544 "Bond héroïque"
	local rally = select(1,GetSpellBookItemName(25, "spell")) -- "Cri de ralliement" 97462 "Rallying Cry"
	local isboss = UnitLevel(rangedTarget) == -1 or UnitClassification(rangedTarget) == "elite"
	
	local isAlone = (GetNumGroupMembers() == 0)  and UnitAffectingCombat(player)==1
	local isInBG = ((GetNumGroupMembers() > 0) and (UnitIsPVP(player) == 1) and UnitAffectingCombat(player)==1) or isAlone
	local isInPvE = (GetNumGroupMembers() > 0) and (UnitIsPVP(player) ~= 1) and UnitAffectingCombat(player)==1
	local mcStks = jps.buffStacks("Meat Cleaver") --MC Stacks Count
	
	jps.Macro("/target "..rangedTarget)
	--jps.Macro("/startattack")
	--jps.Macro("/target "..rangedTarget.."\n/startattack")

	------------------------
	-- SPELL TABLE ---------
	------------------------
	
	local spellTable = {}
	
	spellTable[1] =
	{
		["ToolTip"] = "Warrior Fury",
		
		-- "Bloodthirst" 23881 "Sanguinaire"
		{ 23881, true , rangedTarget , "Bloodthirst" },
		-- "Heroic Leap" 6544 "Bond héroïque"
		--{ {"macro","/cast "..leap} , isInBG and (jps.cooldown(6544)==0) and (CheckInteractDistance(rangedTarget, 3) == nil) , rangedTarget  },
		-- "Charge" 100 -- IsFalling() returns 1 if the character is currently falling, nil otherwise
		{ 100, (CheckInteractDistance(rangedTarget, 3) ~= 1) and IsFalling() == 1 , rangedTarget , "Charge" },
		-- TRINKETS -- jps.useTrinket(0) est "Trinket0Slot" est slotId  13 -- "jps.useTrinket(1) est "Trinket1Slot" est slotId  14  -- Do not use while Dispersion jps.checkTimer(47585) == 0
		--{ jps.useTrinket(0), jps.UseCds },
		--{ jps.useTrinket(1), jps.UseCds },
		-- "Pierre de soins" 5512
		{ {"macro","/use item:5512"}, UnitAffectingCombat(player)==1 and select(1,IsUsableItem(5512))==1 and jps.itemCooldown(5512)==0 and (playerhealth_pct < 0.50) , player , "UseItem"},
		-- "Heroic Throw" 57755 "Lancer héroïque"
		{ 57755, true , rangedTarget , "Heroic Throw" },
		-- "Charge" 100
		{ 100, jps.UseCDs and (CheckInteractDistance(rangedTarget, 3) ~= 1) , rangedTarget , "Charge"},
		-- "Impending Victory" 103840 "Victoire imminente"
		{ 103840, nPower > 10 , rangedTarget , "Impending Victory" },
		-- "Victory Rush" 34428 "Ivresse de la victoire" -- buff "Victorious" 32216 "Victorieux"
		{ 34428, jps.buff(32216) , rangedTarget , "Impending Victory" },
		-- "Berserker Rage" 18499 "Rage de berserker"
		{ 18499 , (not nRage) , player , "Berserker Rage" },
		
		-- "Pummel" 6552 "Volée de coups"
		{ 6552, jps.shouldKick(rangedTarget) , rangedTarget , "Pummel" },
		-- "Dragon Roar" 118000 "Rugissement de dragon"
		{ 118000, (CheckInteractDistance(rangedTarget, 3) == 1), rangedTarget , "Dragon Roar" },
		-- "Shockwave" 46968 "Onde de choc"
		{ 46968, (CheckInteractDistance(rangedTarget, 3) == 1), rangedTarget , "Shockwave" },
		-- "Disrupting Shout" 102060 "Cri perturbant"
		{ 102060, jps.IsCasting(rangedTarget) , rangedTarget , "Disrupting Shout" },
		-- "Mass Spell Reflection" 114028 "Renvoi de sort de masse"
		{ 114028, jps.IsCasting(rangedTarget) , rangedTarget , "Mass Spell Reflection" },
		
		-- "Stoneform" 20594 "Forme de pierre"
		{ 20594, player_Aggro > 0 , player , "Stoneform" },
		-- "Disarm" 676 "Désarmement"
		{ 676, ClassCac , rangedTarget , "Disarm"  },
		-- "Lifeblood" 74497 same ID spell & buff
		{ 74497, UnitAffectingCombat(player)==1 , player , "Lifeblood" }, -- if I'm an Herbalist.
		
		-- "Bloodsurge" 46916 "Afflux sanguin"
		-- buff "Raging Blow!" 131116 "Coup déchaîné !"
		-- "Avatar" 107574 "Avatar" -- "Colossus Smash" 86346 same ID spell & debuff
		{ 107574, (jps.buff(131116,"player") or jps.buff(46916)) and nPower > 30 and (targetHealthAbs > 200000) , rangedTarget , "Avatar" },
		-- "Colossus Smash" 86346 "Frappe du colosse" -- "Colossus Smash" 86346 same ID spell & debuff
		{ 86346, (jps.buff(131116,"player") or jps.buff(46916)) and nPower > 30 , rangedTarget , "Colossus Smash" },
		-- "Recklessness" 1719 "Témérité"
		{ 1719, jps.UseCDs and (UnitAffectingCombat(player)==1) and (jps.buff(131116,"player") or jps.buff(46916)) and nPower > 30 , player , "Recklessness" },
		-- "Raging Blow" 85288 "Coup déchaîné" -- buff Raging Blow! 131116
		{ 85288, jps.buff(131116,"player") , rangedTarget , "Raging Blow" },
		-- "Wild Strike" 100130 "Frappe sauvage" -- donne DEBUFF "Mortal Wounds" 115804 "Blessures mortelles" -- Healing effects received reduced by 25%
		{ 100130, jps.buff(46916) and nPower > 20 , rangedTarget ,"Wild Strike" },
		-- "Execute" 5308 "Exécution"
		{ 5308, targetHealth < 0.20 , rangedTarget , "Execute" },
		-- "Cleave" 845 "Enchaînement"
		{ 845, (enemycount > 1) and nPower > 60 , rangedTarget , "Cleave" },
		-- "Thunder Clap" 6343 "Coup de tonnerre" 
		{ 6343, (enemycount > 3) , rangedTarget , "Thunder Clap" },
		-- "Deadly Calm" 85730 "Calme mortel" same ID spell & buff -- REMOVED 5.2
		--{ 85730, nPower > 40 , rangedTarget , "Deadly Calm" },
		-- "Heroic Strike" 78 "Frappe héroïque"
		{ 78, nPower > 60 , rangedTarget , "Heroic Strike" },
		-- "Bloodthirst" 23881 "Sanguinaire"
		{ 23881, true , rangedTarget , "Bloodthirst" },
		-- "Shattering Throw" 64382 "Lancer fracassant"
		{ 64382, nPower > 30 and isboss and not jps.debuff(64382,rangedTarget) , rangedTarget , "Shattering Throw" },
		
		-- "Commanding Shout" 469 "Cri de commandement"
		{ 469, nPower < 70 and not jps.debuff(86346,rangedTarget) , player , "Commanding Shout" },
		-- "Brise-genou" 1715 "Hamstring"
		{ 1715, nPower > 10 and (jps.myDebuffDuration(1715) < 3)  , rangedTarget , "Hamstring" },
	}



	local spellTableActive = jps.RotationActive(spellTable)
	local spell,target = parseSpellTable(spellTableActive)
	return spell,target
end

	-- "Victorieux" 32216 " Victorious -- Ivresse de la victoire activée -- Attaque instantanément la cible, lui inflige 1246 points de dégâts et vous soigne pour un montant égal à 20% de votre maximum de points de vie
	-- "Enrage" 13046 12880 "Enrager" -- Les coups critiques de FRAPPE MORTELLE, DE SANGUINAIRE ET DE FRAPPE DU COLOSSE ainsi que les blocages critiques vous font enrager 
	-- "Enrage" 13046 12880 "Enrager" -- augmente les dégâts physiques infligés de 10% pendant 6 s
	-- "Flurry" buff 12968 "Rafale" -- Vos coups critiques en mêlée ont 9% de chances d'augmenter votre vitesse d'attaque de 25% pour les 3 prochains coups
	-- "Commanding Shout" 469 "Cri de commandement" -- Augmente de 10% l’Endurance de tous les membres du groupe et du raid dans un rayon de 100 mètres. Dure 5 min. Génère 20 points de rage.
	-- "Bloodsurge" 46916 "Afflux sanguin" -- Vos coups réussis avec Sanguinaire ont 101% de chances d’abaisser le temps de recharge global à 1 s et de réduire le coût en rage de vos 3 prochaines Frappes sauvages de 20

	-- "Deadly Calm" 85730 "Calme mortel" -- vos 3 prochaines attaques avec Frappe héroïque ou Enchaînement d’avoir un coût en rage réduit de 10 points
	-- "Heroic Throw" 57755 "Lancer héroïque" -- Vous lancez votre arme sur l'ennemi et lui infligez 50% des dégâts de l’arme
	-- Glyphe d’imposition du silence -- Volée de coups et Lancer héroïque réduisent aussi la cible au silence pendant 3 s. Ne fonctionne pas contre les personnages-joueurs.
	-- "Charge" 100 -- Vous chargez un ennemi et l’étourdissez pendant 1 s. Génère 20 points de rage.
	-- "Impending Victory" 103840 "Victoire imminente" -- Attaque instantanément la cible et lui inflige 1246 points de dégâts tout en vous rendant 20% de votre maximum de points de vie
	-- "Berserker Rage" 18499 "Rage de berserker" -- Vous devenez Enragé, ce qui vous fait générer 10 points de rage. si vous étiez apeuré, assommé ou stupéfié, vous en êtes libéré et vous devenez insensible à ces types d'effet pendant la durée de la Rage de berserker

	-- "Pummel" 6552 "Volée de coups" -- interrompt l'incantation en cours et empêche le lancement de tout sort de cette école de magie pendant 4 s
	-- "Dragon Roar" 118000 "Rugissement de dragon" -- inflige 126 points de dégâts à tous les ennemis à moins de 8 mètres et les fait tomber à la renverse
	-- "Disrupting Shout" 102060 "Cri perturbant" -- Interrompt toutes les incantations de sorts à moins de 10 mètres et empêche tout sort de la même école d’être lancé pendant 4 s
	-- "Mass Spell Reflection" 114028 "Renvoi de sort de masse" BUFF same ID -- Renvoie le prochain sort lancé sur vous et les membres du groupe ou raid à moins de 20 mètres d’un sort unique pendant 5 s.
	-- "Stoneform" 20594 "Forme de pierre" -- réduit tous les dégâts subis de 10% pendant 8 s
	-- "Disarm" 676 "Désarmement" -- Retire ses armes et son bouclier à l’ennemi pendant 8 s

	-- "Raging Blow" 85288 "Coup déchaîné" -- Le fait de devenir Enragé permet une utilisation de Coup déchaîné.
	-- "Colossus Smash" 86346 "Frappe du colosse" -- permet à vos attaques d'ignorer 100% de son armure pendant 6 s
	-- "Recklessness" 1719 "Témérité" -- Confère à vos attaques spéciales 50% de chances supplémentaires d’être critiques. Dure 12 s.
	-- "Cleave" 845 "Enchaînement" -- Une attaque circulaire qui frappe la cible et une cible proche supplémentaire
	-- "Thunder Clap" 6343 "Coup de tonnerre" -- Foudroie les ennemis à moins de 8 mètres, leur infligeant 312 points de dégâts, et applique sur eux l'effet Coups affaiblis
	-- "Heroic Strike" 78 "Frappe héroïque" -- 
	-- Glyphe de coups gênants -- Frappe héroïque et Enchaînement diminuent aussi la vitesse de déplacement de la cible de 50% pendant 8 s
	-- "Wild Strike" 100130 "Frappe sauvage" -- donne DEBUFF "Mortal Wounds" 115804 "Blessures mortelles" -- Healing effects received reduced by 25%
	-- "Bloodthirst" 23881 "Sanguinaire" -- Vous avez deux fois plus de chances d’infliger un coup critique avec Sanguinaire.

	-- "Shattering Throw" 64382 "Lancer fracassant" -- réduire son armure de 20% pendant 10 s ou d'annuler les invulnérabilités.
	-- "Die by the Sword" 118038 "Par le fil de l’épée" -- Augmente vos chances de parer de 100% et réduit les dégâts subis de 20% pendant 8 s.
	-- "Whirlwind" 1680 "Tourbillon" -- Dans un tourbillon d'acier, vous attaquez tous les ennemis se trouvant à moins de 8 mètres et infligez 85% des dégâts des armes à chacun d'eux.
	-- "Enraged Regeneration" 55694 "Régénération enragée" -- Vous rend instantanément 10% de votre total de points de vie, plus 10% supplémentaires en 5 s. Peut être utilisé pendant que vous êtes étourdi. Ne coûte pas de rage lorsque vous êtes Enragé.
