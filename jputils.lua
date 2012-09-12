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
-- VARIABLES_LOADED
function jps_VARIABLES_LOADED()
	if ( not jpsDB ) then
		jpsDB = {}
	end
	if ( not jpsDB[jpsRealm] ) then
		jpsDB[jpsRealm] = {}
	end
	if ( not jpsDB[jpsRealm][jpsName] ) then
		write("Initializing new character names")
		jpsDB[jpsRealm][jpsName] = {}
		
		jpsDB[jpsRealm][jpsName].Enabled = true
		jpsDB[jpsRealm][jpsName].MoveToTarget = false
		jpsDB[jpsRealm][jpsName].FaceTarget = false
		jpsDB[jpsRealm][jpsName].Interrupts = false
		jpsDB[jpsRealm][jpsName].UseCDs = false
		jpsDB[jpsRealm][jpsName].PvP = false
		jpsDB[jpsRealm][jpsName].MultiTarget = false
		jpsDB[jpsRealm][jpsName].ExtraButtons = false
		jpsDB[jpsRealm][jpsName].spellConfig = {}
		jpsDB[jpsRealm][jpsName].useRotation = 1
		write("init")
    else
		if ( not jpsDB[jpsRealm][jpsName].spellConfig) then
		  jpsDB[jpsRealm][jpsName].spellConfig = {}
		end 
		if ( not jpsDB[jpsRealm][jpsName].useRotation) then
		  jpsDB[jpsRealm][jpsName].useRotation = 1
		end 
	end
	

	jps_LOAD_PROFILE()
	jps_variablesLoaded = true
end

-- LOAD_PROFILE
function jps_LOAD_PROFILE()
	for saveVar,value in pairs( jpsDB[jpsRealm][jpsName] ) do
		jps[saveVar] = value
	end

	jps.gui_toggleEnabled( jps.Enabled )
	jps.gui_toggleCDs( jps.UseCDs )
	jps.gui_toggleMulti( jps.MultiTarget )
	jps.gui_toggleInt(jps.Interrupts)
	jps.gui_toggleToggles( jps.ExtraButtons )
	jps.gui_setToggleDir( "right" )
	jps.togglePvP( jps.PvP )
	jps.resize( 36 )
end

-- SAVE_PROFILE
function jps_SAVE_PROFILE()
	for varName, _ in pairs( jpsDB[jpsRealm][jpsName] ) do
		jpsDB[jpsRealm][jpsName][varName] = jps[varName]
	end
end

-- Get Combat Function
function jps_getCombatFunction( class, spec )
	local Rotations =
	{ 
		["Druid"]        = { ["Feral"]  = druid_feral,
							 ["Guardian"]	   = druid_guardian,
							 ["Balance"]       = druid_balance,
							 ["Restoration"]   = druid_resto },
		["Death Knight"] = { ["Unholy"]        = dk_unholy,
							 ["Blood"]         = new_dk_blood,
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
							 ["Combat"] 	   = rogue_combat },
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
	local options = {}

	-- Trolls n' Orcs
	if jps.Race == "Troll" then
		jps.DPSRacial = "berserking"
	elseif jps.Race == "Orc" then
		jps.DPSRacial = "blood fury"
	end
	if jps.DPSRacial then table.insert(options,"DPS Racial") end

	-- Add spells
	for i,spell in pairs(options) do
		if jpsDB[jpsRealm][jpsName][spell] == nil then
			jpsDB[jpsRealm][jpsName][spell] = true
			jps[spell] = true
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

--PLua Test
function jps.PLuaTest()
	jps.groundClick()
	if jps.PLuaFlag == true then
		write("PLua commands not available, deactivating JPS.")
		jpsIcon.texture:SetTexture(jps.GUInoplua)
		jpsIcon.border:SetTexture(jps.GUIborder_combat)
		jps.PLuaFlag = false
	end
end

--If function like C / PHP ternary operator val = (condition) ? true : false
function sif(condition, doIt, notDo)
	if condition then return doIt else return notDo end
end

--get table length
function count(data) 
    local count = 0
    for k,v in pairs(data) do 
        count = count+1
    end
    return count
end