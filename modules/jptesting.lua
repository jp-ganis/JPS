--[[
|cffe5cc80 = beige (artifact)
|cffff8000 = orange (legendary)
|cffa335ee = purple (epic)
|cff0070dd = blue (rare)
|cff1eff00 = green (uncommon)
|cffffffff = white (normal)
|cff9d9d9d = gray (crappy)
|cFFFFff00 = yellow
|cFFFF0000 = red
]]

-----------------------
-- FUNCTION TEST 
-----------------------

function jps_Test()

	LookupRaid ()

end

function LookupRaid ()
-- jps.EnemyTable[enemyGuid] = { ["friend"] = enemyFriend } 
	for unit,index in pairs(jps.EnemyTable) do 
		print("|cffa335ee","EnemyGuid_",unit,"|cff1eff00","Name_",index.friend)
	end
end

function LookupRaidTimeToDie ()
-- jps.RaidTimeToDie[unitGuid] = { [1] = {GetTime(), eventtable[15] },[2] = {GetTime(), eventtable[15] },[3] = {GetTime(), eventtable[15] } }
	for unit,index in pairs(jps.RaidTimeToDie) do 
		local dataset = jps.RaidTimeToDie[unit]
		for i,j in ipairs(dataset) do
			print("|cffa335ee","Guid_",unit,"/",i,"|cff1eff00","Time_",j[1],"|cff1eff00","Dmg_",j[2] )
		end
	end
end