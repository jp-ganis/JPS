function druid_feral(self)
	--if ub("player","cat form") then return druid_feral_cat()
	if ub("player","cat form") then return hydra_cat()
	elseif ub("player","bear form") then return druid_feral_bear()
	end
end
