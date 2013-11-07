--http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
JPSAceOptions = { 
	name = "JPS General",
	type = "group",
	handler = "jps",
	args = {
		{
			name ="JPS Modules",
			type ="group",
			args = {
			}
		},
		{
			name ="Combat behavior",
			type ="group",
			args = {
				dismountInCombat = {
					name ="Dismount in combat",
					default = false,
					type ="toggle",
					set = function(info, value) jps.db.dismountInCombat = value end,
					get = "getDismountInCombat"
				},
				collectGarbageInfight = {
					name ="Collect addon garbage in combat",
					desc = "could cause a fps drop!",
					default = false,
					type ="toggle",
					set = function(info, value) jps.db.collectGarbageInfight = value end,
					get = "getCollectGarbageInfight"
				},
				collectGarbageInfight = {
					name ="Collect addon garbage in combat",
					desc = "could cause a fps drop!",
					default = false,
					type ="toggle",
					set = function(info, value) jps.db.collectGarbageInfight = value end,
					get = "getCollectGarbageInfight"
				},
				
			}
		},
		{
			name ="Use Spells",
			type ="group",
			args = {
			
			}
		},
		{
			name ="JPS UI",
			type ="group",
			args = {
			
			}
		},
		{
			name ="Custom Rotations",
			type ="group",
			args = {
			
			}
		},
		{
			name ="Combat behavior",
			type ="group",
			args = {
			
			}
		},
		JPSEnabled = {
			name ="JPS Enabled",
			default = true,
			type ="toggle",
			set = function(info, value) 
				jps.db.JPSEnabled = value
				jps.enabled = value
			end,
			get = "getJPSEnabled"
		},
		useInterrupts = {
			name ="Interrupt units",
			default = true,
			type ="toggle",
			set = function(info, value) 
				jps.db.interrupts = value 
				jps.Interrupts = value
			end,
			get = "getUseInterrupts"
		},
		useCooldowns = {
			name ="Use offensive Cooldowns",
			default = true,
			type ="toggle",
			set = function(info, value) 
				jps.db.useCooldowns = value 
				jps.UseCDs = value
			end,
			get = "getUseCooldowns"
		},
		defensiveEnabled = {
			name ="Use Defensive Cooldowns",
			default = true,
			type ="toggle",
			set = function(info, value) 
				jps.db.defensive = value 
				jps.Defensive = value
			end,
			get = "getDefensiveEnabled"
		},
		multitargetEnabled = {
			name ="Multitarget enabled",
			default = false,
			type ="toggle",
			set = function(info, value) 
				jps.db.multitargetEnabled = value 
				jps.MultiTarget = value
			end,
			get = "getMultiTargetEnabled"
		},
		PVPEnabled = {
			name ="PVP Mode enabled",
			default = false,
			type ="toggle",
			set = function(info, value) 
				jps.db.PVPEnabled = value 
				jps.PVP = value
			end,
			get = "getPVPEnabled"
		},
		faceTargetEnabled = {
			name ="Target Facing enabled",
			default = false,
			type ="toggle",
			set = function(info, value) 
				jps.db.faceTargetEnabled = value 
				jps.FaceTarget = value
			end,
			get = "getFaceTargetEnabled"
		},

	},
}


function jps.getJPSEnabled(info) return jps.db.JPSEnabled   end
function jps.getUseInterrupts(info) return jps.db.interrupts   end
function jps.getUseCooldowns(info) return jps.db.useCooldowns   end
function jps.getDefensiveEnabled(info) return jps.db.defensive   end
function jps.getMultiTargetEnabled(info) return jps.db.multitargetEnabled   end
function jps.getPVPEnabled(info) return jps.db.PVPEnabled   end
function jps.getFaceTargetEnabled(info) return jps.db.faceTargetEnabled   end
