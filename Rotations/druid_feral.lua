function druid_feral(self)
	--if ub("player","cat form") then return druid_feral_cat()
	--elseif ub("player","bear form") then return druid_feral_bear()
	-- 5.0 won't need this! woop
	if ub("player","cat form") then return druid_cat()
	elseif ub("player","bear form") then return druid_guardian()
	end
end
