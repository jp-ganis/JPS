	dk = {}
	
	function dk.canCastPlagueLeech(timeLeft)  
		if not jps.mydebuff("Frost Fever") or not jps.mydebuff("Blood Plague") then return false end
		if jps.myDebuffDuration("Frost Fever") <= timeLeft then
			return true
		end
		if jps.myDebuffDuration("Blood Plague") <= timeLeft then
			return true
		end
		return false
	end
		
	function dk.updateRunes() 
		dk.dr1 = select(3,GetRuneCooldown(1))
		dk.dr2 = select(3,GetRuneCooldown(2))
		dk.ur1 = select(3,GetRuneCooldown(3))
		dk.ur2 = select(3,GetRuneCooldown(4))
		dk.fr1 = select(3,GetRuneCooldown(5))
		dk.fr2 = select(3,GetRuneCooldown(6))
		dk.oneDr = dk.dr1 or dk.dr2
		dk.twoDr = dk.dr1 and dk.dr2
		dk.oneFr = dk.fr1 or dk.fr2
		dk.twoFr = dk.fr1 and dk.fr2
		dk.oneUr = dk.ur1 or dk.ur2
		dk.twoUr = dk.ur1 and dk.ur2
	end
	
	function dk.rune(name)
		dk.updateRunes()
		if dk[name] ~= nil then
			return dk[name]
		end
		print(" there is no rune with the name: "..name)
		return 0
	end