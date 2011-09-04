-- VARIABLES_LOADED
function jps_VARIABLES_LOADED()
	if ( not jpsDB ) then
		jpsDB = {}
	end
	if ( not jpsDB[jpsRealm] ) then
		jpsDB[jpsRealm] = {}
	end
	if ( not jpsDB[jpsRealm][jpsName] ) then
		jpsDB[jpsRealm][jpsName] = {}
	end

	for i,saveVar in pairs( jps_saveVars ) do
		local thisSaveVar = saveVar[1]
		local thisDefaultSaveVar = saveVar[2]

		if ( not jpsDB[jpsRealm][jpsName][thisSaveVar] ) then
			jpsDB[jpsRealm][jpsName][thisSaveVar] = thisDefaultSaveVar
		end
	end

	jps_LOAD_VARIABLES()
	jps.detectSpec()
	jps.setClassCooldowns()
	jps_createConfigFrame()
	jps_variablesLoaded = true
end

-- LOAD_VARIABLES
function jps_LOAD_VARIABLES()
	for saveVar,value in pairs( jpsDB[jpsRealm][jpsName] ) do
		jps[saveVar] = value
	end

	jps.gui_toggleEnabled( jps.Enabled )
	jps.gui_toggleCDs( jps.UseCDs )
	jps.gui_toggleMulti( jps.MultiTarget )
	jps.gui_toggleToggles( jps.ExtraButtons )
	jps.gui_setToggleDir( "right" )
	jps.togglePvP( jps.PvP )
	jps.resize( jps.IconSize )
end

-- SAVE_VARIABLES
function jps_SAVE_VARIABLES()
	for _, varTable in pairs( jps_saveVars ) do
		local varName = varTable[1]
		jpsDB[jpsRealm][jpsName][varName] = jps[varName]
	end
end

-- Get Combat Function
function jps_getCombatFunction( class, spec )
	local Rotations =
	{ 
		["Druid"]        = { ["Feral Combat"]  = druid_feral,
							 ["Balance"]       = druid_balance,
							 ["Restoration"]   = druid_resto },

		["Death Knight"] = { ["Unholy"]        = dk_unholy,
							 ["Blood"]         = dk_blood,
							 ["Frost"]         = dk_frost  },  

		["Shaman"]       = { ["Enhancement"]   = shaman_enhancement,
							 ["Elemental"]     = shaman_elemental,
							 ["Restoration"]   = shaman_resto_pvp },

		["Paladin"]      = { ["Protection"]    = paladin_protadin,
							 ["Retribution"]   = paladin_ret,
							 ["Holy"]          = paladin_holy },

		["Warlock"]      = { ["Affliction"]    = warlock_affliction,
							 ["Destruction"]   = warlock_destro,
							 ["Demonology"]    = warlock_demo },

		["Hunter"]       = { ["Beast Mastery"] = hunter_bm,
							 ["Marksmanship"]  = hunter_mm,
							 ["Survival"]      = hunter_sv },

		["Mage"]         = { ["Fire"]          = mage_fire,
							 ["Arcane"]        = mage_arcane,
							 ["Frost"]         = mage_frost },

		["Rogue"]        = { ["Assassination"] = rogue_assass,
							 ["Subtlety"] 	   = rogue_sub,
							 ["Combat"] 	   = rogue_sub },

		["Warrior"]      = { ["Fury"]          = warrior_fury,
							 ["Protection"]    = warrior_prot,
							 ["Arms"]          = warrior_arms },

		["Priest"]       = { ["Shadow"]        = priest_shadow,
							 ["Holy"]          = priest_holy,
							 ["Discipline"]    = priest_disc },
	} 
	
	return Rotations[class][spec]
end

-- Get Class Cooldowns
function jps.setClassCooldowns()
	local cds = {}

	-- Shaman
	if jps.Class == "Shaman" then
		if jps.Spec == "Elemental" then
			table.insert(cds,"Elementary Mastery")
		end
	-- DK
	elseif jps.Class == "Death Knight" then
		table.insert(cds,"Icebound Fortitude")
		table.insert(cds,"Strangulate")
		table.insert(cds,"Blood Tap")
		table.insert(cds,"Empower Rune Weapon")
		if jps.Spec == "Frost" then
			table.insert(cds,"Pillar of Frost")
		end
	end

	-- Add spells
	for i,spell in pairs(cds) do

		table.insert(jps_saveVars, { spell,false })

		if not jpsDB[jpsRealm][jpsName][spell] then
			jpsDB[jpsRealm][jpsName][spell] = false
			jps[spell] = false
		else
			jps[spell] = jpsDB[jpsRealm][jpsName][spell]
		end
	end
end


-- Toggle PvP
function jps.togglePvP( value )
	if value == nil then jps.PvP = not jps.PvP
	else jps.PvP = value end

	if jps.PvP then jpsIcon.texture:SetTexture(jps.GUIpvp)
	else jpsIcon.texture:SetTexture(jps.GUInormal) end
end
