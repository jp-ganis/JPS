function dk_frost(self)
	-- shorter code
	local ius = IsUsableSpell
	
	-- My attempt at rune counting, doesn't work (yet), Scribe
	-- for i=1, 6, 1 do
	-- 	runes_index = { "blood", "unholy", "frost", "death" };
	-- 	count = GetRuneCount(i);
	-- 	runetype = GetRuneType(i);
	-- 	local runes = {}
	-- 	if runes[runes_index[runetype]] == nil then
	-- 		runes[runes_index[runetype]] = 0
	-- 	end 
	-- 	if count > 0 then
	-- 		runes[runes_index[runetype]] = tonumber(runes[runes_index[runetype]])+1
	-- 	end 
	-- 	
	-- 	-- print(runes_index[runetype])
	-- 	-- print(runes[runes_index[runetype]])
	-- 	
	-- 	-- print(runes_index[runetype])
	-- 	-- print(runes[runes_index[runetype]])
	-- end
	-- 
	
	-- Scribe (v0.1)
	local spell = nil
	local power = UnitPower("player",6)
	

	if not ud("target","Blood Plague") and cd("Outbreak") == 0 then
		spell = "Outbreak"
	elseif not ud("target","Blood Plague") then
		spell = "Plague Strike"
	elseif ub("player","Killing Machine") and ius("Obliterate") then
		print("Killing machine!")
		spell = "Obliterate"
	elseif cd("Howling Blast") == 0 then
		spell = "Howling Blast"
	elseif power > 70 then
		print(power)
		spell = "Frost Strike"
	elseif ius("Obliterate") then
		spell = "Obliterate"
	end
	
	print(spell)
	return spell
end
