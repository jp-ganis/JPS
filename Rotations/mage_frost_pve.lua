--[[[
@rotation Frost Mage PvE
@class mage
@spec frost
@author SwollNMember
@description 
SimCraft 5.3
]]--

frostMage = {}
-- Enemy Tracking
function frostMage.rangedTarget()
	local rangedTarget = "target"
	if jps.canDPS("target") then 
		return "target"
	elseif jps.canDPS("focustarget") then 
		return "focustarget"
	elseif jps.canDPS("targettarget") then 
		return "targettarget"
	else
		local enemycount,targetcount = jps.RaidEnemyCount()
		local EnemyUnit = {}
		for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end
		if jps.canDPS(EnemyUnit[1]) then 
			return EnemyUnit[1] 
		else
			return "target" 
		end
	end
end

function frostMage.hasRune()
	local hasOne,_ = GetTotemInfo(1)
	local hasSecond,_ = GetTotemInfo(2)
	if hasOne ~= false then 
		return true
	end
	if hasSecond ~= false then 
		return true
	end
	return false
end


function frostMage.hasPet() 
	if UnitExists("pet") == false then return false end
	return true
end

function frostMage.kick(unit)
	return jps.shouldKick(unit) or jps.IsCastingPoly(unit)
end


--[[[
@rotation Frost Mage PvE
@class mage
@spec frost
@author SwollNMember
@description
SimCraft 5.3
]]--

-- Enemy Tracking
function frostMage.rangedTarget()
        local rangedTarget = "target"
        if jps.canDPS("target") then
                return "target"
        elseif jps.canDPS("focustarget") then
                return "focustarget"
        elseif jps.canDPS("targettarget") then
                return "targettarget"
        else
                local enemycount,targetcount = jps.RaidEnemyCount()
                local EnemyUnit = {}
                for name, index in pairs(jps.RaidTarget) do table.insert(EnemyUnit,index.unit) end
                if jps.canDPS(EnemyUnit[1]) then
                        return EnemyUnit[1]
                else
                        return "target"
                end
        end
end

function frostMage.hasRune()
        local hasOne,_ = GetTotemInfo(1)
        local hasSecond,_ = GetTotemInfo(2)
        if hasOne ~= false then
                return true
        end
        if hasSecond ~= false then
                return true
        end
        return false
end


function frostMage.hasPet()
        if UnitExists("pet") == false then return false end
        return true
end

function frostMage.kick(unit)
        return jps.shouldKick(unit) or jps.IsCastingPoly(unit)
end

function frostMage.targetIsCrystal()
	if not UnitExists("target") then return false end 
	return UnitName("target") == toSpellName(152087)
end
function frostMage.crystalIsActive()
end

--[[[
@rotation Noxxic PvE
@class mage
@spec frost
@author Kirk24788
@description
]]--

mageFrostCooldowns = {
        { {"macro", "/use icy veins"}, 'jps.cooldown(toSpellName(12472)) == 0'},
        { toSpellName(26297)},
        { toSpellName(20572)},
        { {"macro","/use 13"}, 'jps.useEquipSlot(13)'},
        { {"macro","/use 14"}, 'jps.useEquipSlot(14)'},
}

mageFrostCrystalRotation = {
       -- { toSpellName(112948),'jps.myDebuffDuration(toSpellName(112948),"target") < 9 and not frostMage.targetIsCrystal() and not jps.isRecast(toSpellName(112948),"target")'},
        { toSpellName(84721),'jps.UseCDs'},
        { "nested",'jps.UseCDs', mageFrostCooldowns},
        { toSpellName(152087),"IsShiftKeyDown()"},
     --   { toSpellName(112948),'jps.myDebuffDuration(toSpellName(112948),"target") == 0 and frostMage.targetIsCrystal() and jps.MultiTarget'},
        { toSpellName(105298),'jps.buffStacks(toSpellName(112965)) == 2'},
        { toSpellName(105298),'jps.buffStacks(toSpellName(112965)) == 1 and jps.myDebuffDuration(toSpellName(84721)) > 0'},
        { toSpellName(157997),'GetSpellCharges(toSpellName(157997)) == 2'},
        { toSpellName(44614),'jps.buff(toSpellName(57761))'},
        { toSpellName(105298),'jps.buffStacks(toSpellName(112965))>0'},
        { toSpellName(157997)},
        { toSpellName(116)}
}

mageFrostCrystal = {
        -- Noxxic
        -- pre fight
        { toSpellName(31687), 'frostMage.hasPet() == false and not jps.Moving'},
		{ toSpellName(130), 'jps.fallingFor() > 1.5 and not jps.buff(toSpellName(130))' ,"player"},
        { toSpellName(1459), 'not jps.buff(toSpellName(1459))' },

        { toSpellName(116011), 'IsAltKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.IsSpellKnown(toSpellName(116011))'},

        { "nested",'jps.UseCDs and not jps.Moving and jps.canDPS("target")',{
                { "mirror image"}
        }},

        { "nested",'jps.UseCDs and jps.hp("target") <= 0.10', mageFrostCooldowns},
        { "nested",'jps.talentInfo(toSpellName(152087)) and jps.cooldown(toSpellName(152087)) <= 0.5 and IsShiftKeyDown()', mageFrostCrystalRotation},
        { "nested",'jps.talentInfo(toSpellName(152087)) and frostMage.crystalIsActive() and IsShiftKeyDown()', mageFrostCrystalRotation},
        { "nested",'jps.MultiTarget', {
                { toSpellName(84721),'jps.UseCDs'},
                { toSpellName(157997)},
				{ toSpellName(153595),'not jps.dotTracker.isTrivial("target")'},
                { toSpellName(112948),'jps.myDebuffDuration(toSpellName(112948),"target") < 10'},
                { toSpellName(120),'jps.glyphInfo(115705)'},
                { toSpellName(42208),"IsControlKeyDown() == true"},
                { toSpellName(105298)},
        }},
        { "nested",'jps.UseCDs and not jps.talentInfo(toSpellName(152087))', mageFrostCooldowns},
        { "nested",'jps.UseCDs and jps.talentInfo(toSpellName(152087)) and jps.cooldown(toSpellName(152087)) > 15', mageFrostCooldowns},

        { toSpellName(105298),'jps.buffStacks(toSpellName(112965))>0 and jps.buffDuration(toSpellName(112965)) < 2'},
		--{ toSpellName(112948),'jps.myDebuffDuration(toSpellName(112948),"target") == 0 and jps.dotTracker.isTrivial("target") and not frostMage.targetIsCrystal() and not jps.isRecast(toSpellName(112948),"target") and UnitHealth("target") > 100000'},

        { toSpellName(44614),'jps.buff(toSpellName(57761))'},

        { toSpellName(84721),'jps.buffStacks(toSpellName(112965)) < 2 and not jps.talentInfo(toSpellName(152087)) and jps.cooldown(toSpellName(12472)) > 45 and jps.UseCDs'},
        { toSpellName(157997),'GetSpellCharges(toSpellName(157997)) == 2'},
        { toSpellName(105298),'jps.buffStacks(toSpellName(112965)) == 2 and jps.myDebuffDuration(toSpellName(84721)) > 0'},
        {toSpellName(153595),'not jps.dotTracker.isTrivial("target")'},
--        { toSpellName(157997),'not jps.talentInfo(toSpellName(152087)) and GetSpellCharges(toSpellName(157997)) == 1 and },
        { toSpellName(44614),'jps.buff(toSpellName(57761))'},
        { toSpellName(105298), 'jps.buff(toSpellName(112965))' },
		{ toSpellName(105298),'jps.talentInfo(toSpellName(155149)) and jps.buff(toSpellName(12472)) and jps.buffDuration(toSpellName(12472)) < 10 and jps.combatTime() < 40'},
        { toSpellName(116),"not jps.Moving"},
        { toSpellName(105298)},


}
jps.registerRotation("MAGE","FROST",function()

	return parseStaticSpellTable(mageFrostCrystal)
	
end,"6.0.3 PVE lvl 100 Prismatic Crystal",true,false)
	
	
	
	
	spellTableOOC = {
	--cds defensive
	{toSpellName(130), 'jps.fallingFor() > 1.5 and not jps.buff(toSpellName(130))' ,"player"},
	--cds offensive
	{ toSpellName(31687), 'frostMage.hasPet() == false and not jps.Moving'},

	{ toSpellName(116011), 'IsAltKeyDown() == true and GetCurrentKeyBoardFocus() == nil and jps.IsSpellKnown(toSpellName(116011))'}, 
	{ toSpellName(1459), 'not jps.buff(toSpellName(1459))' ,"player"},
}
jps.registerRotation("MAGE","FROST",function() 

	return parseStaticSpellTable(spellTableOOC)
end,"OOC 6.0.2 90",false,false,nil,true)
