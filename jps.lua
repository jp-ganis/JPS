function UnitGUIDnorm(unit, convert)
	local guid = 0;
	if convert == nil then
		guid = UnitGUID(unit)
	else
		guid = unit
	end
	if guid then
		guid = string.gsub(guid, ":","")
		guid = string.gsub(guid, "%.","")
	end
	return guid
end
