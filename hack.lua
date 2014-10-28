-- this is from the PE Addon , thx to phelps
function fh.Distance(a, b)
	if UnitExists(a) and UnitIsVisible(a) and UnitExists(b) and UnitIsVisible(b) then
		local ax, ay, az = ObjectPosition(a)
		local bx, by, bz = ObjectPosition(b)
		return math.sqrt(((bx-ax)^2) + ((by-ay)^2) + ((bz-az)^2)) - ((UnitCombatReach(a)) + (UnitCombatReach(b)))
	end
	return 0
end

function fh.UnitsAroundUnit(unit, distance)
	local total = 0
	 -- for OSX Users it's a little bit dirty since there is no FireHack on OSX.. we need to check for jps.MultiTarget and return a default value
	if not FireHack and jps.MultiTarget == true then return 4 end
	if not distance then distance = 10 end
	if UnitExists(unit) then
		local totalObjects = ObjectCount()
		for i = 1, totalObjects do
			local object = ObjectWithIndex(i)
			if bit.band(ObjectType(object), ObjectTypes.Unit) > 0 then
				local reaction = UnitReaction("player", object)
				local combat = UnitAffectingCombat(object)
				if reaction and reaction <= 4 and combat then
					if fh.Distance(object, unit) <= distance then
						total = total + 1
					end
				end
			end
		end
	end
	return total
end
