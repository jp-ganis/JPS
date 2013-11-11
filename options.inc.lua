
function jps.getConfigValue(key)
	return jps.db[key]
end

--http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
JPSAceOptions = { 
	name = "JPS Settings",
	type = "group",
	handler = jps,
	args = {
		general = {
			name ="General",
			type ="group",
			order = 1,
			args = {
					JPSEnabled = {
					name ="JPS Enabled",
					type ="toggle",
					set = function(info, value) 
						jps.db.JPSEnabled = value
						jps.enabled = value
					end,
					get = function(info) return jps.db[info[#info]] end
					},
					useInterrupts = {
						name ="Interrupt units",
						type ="toggle",
						set = function(info, value) 
							jps.db.interrupts = value 
							jps.Interrupts = value
						end,
					},
					useCooldowns = {
						name ="Use offensive Cooldowns",
						type ="toggle",
						set = function(info, value) 
							jps.db.useCooldowns = value 
							jps.UseCDs = value
						end,
					},
					defensiveEnabled = {
						name ="Use Defensive Cooldowns",
						type ="toggle",
						set = function(info, value) 
							jps.db.defensive = value 
							jps.Defensive = value
						end,
					},
					multitargetEnabled = {
						name ="Multitarget enabled",
						type ="toggle",
						set = function(info, value) 
							jps.db.multitargetEnabled = value 
							jps.MultiTarget = value
						end,
					},
					PVPEnabled = {
						name ="PVP Mode enabled",
						type ="toggle",
						set = function(info, value) 
							jps.db.PVPEnabled = value 
							jps.PVP = value
						end,
					},
					faceTargetEnabled = {
						name ="Target Facing enabled",
						type ="toggle",
						set = function(info, value) 
							jps.db.faceTargetEnabled = value 
							jps.FaceTarget = value
						end,
					},
			},
		},
		modules = {
			name ="JPS Modules",
			type ="group",
			args = {
			}
		},
		combatBehavior = {
			name ="Combat behavior",
			type ="group",
			args = {
				dismountInCombat = {
					name ="Dismount in combat",
					type ="toggle",
					set = function(info, value) jps.db.dismountInCombat = value end,
				},
				collectGarbageInfight = {
					name ="Collect addon garbage in combat",
					desc = "could cause a fps drop!",
					type ="toggle",
					set = function(info, value) jps.db.collectGarbageInfight = value end,
				},
				collectGarbageInfight = {
					name ="Collect addon garbage in combat",
					desc = "could cause a fps drop!",
					type ="toggle",
					set = function(info, value) jps.db.collectGarbageInfight = value end,
				},
				
			}
		},
		useSpells ={
			name ="Use Spells",
			type ="group",
			args = {
			
			}
		},
		jpsUI = {
			name ="JPS UI",
			type ="group",
			args = {
			
			}
		},
		customRotations ={
			name ="Custom Rotations",
			type ="group",
			args = {
			
			}
		},
		

	},
}
