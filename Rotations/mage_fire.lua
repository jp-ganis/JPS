function mage_fire(self)
	-- Credit (and thanks!) to Soiidus.
	local mana = UnitMana("player")/UnitManaMax("player")
	local spell = nil

	if ub("player","hot streak") then
		spell = "pyroblast"
	elseif ud("target","critical mass") and ud("target","ignite") and ud("target","pyroblast") and ud("target","living bomb") and cd("combustion") == 0 then
		spell = "combustion"
	elseif cd("mirror image") == 0 and jps.UseCDs then
		spell = "mirror image"
	elseif cd("counterspell") ==0 and UnitCastingInfo("target") or UnitChannelInfo("target") then
		spell = "counterspell"
	elseif cd("lifeblood") == 0 then
		spell = "lifeblood"
	elseif not ud("target", "Living Bomb",unitCaster~="player") and IsUsableSpell("Living Bomb") then
		spell = "living bomb"
	elseif cd("flame orb") == 0 then
		spell = "flame orb"
	elseif cd("evocation") == 0 and mana <0.3 then
        spell = "evocation"
    elseif not ud("target","critical mass",unitCaster~="player") then
        spell = "scorch"
	elseif mana <0.1 then
		spell = "scorch"
	else
		spell = "fireball"
	end

   return spell
end
