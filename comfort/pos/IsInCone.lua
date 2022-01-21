if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/pos/GetAngleBetween")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1
-- checks if a position is in a cone originating from another position.
-- imagine it as checking if an entity at the position center, looking at direction middleAlpha
-- and a field of view of betaAvailable to either side can see pos.
-- (assumes being able to look through any other object and having infinite vision range).
-- (the angle of the entire cone is betaAvaiable * 2, its outer birders are at middleAlpha+betaAvaiable and middleAlpha-betaAvaiable).
-- (depending on the circumstances, should be coupled by a distance check via GetDistance).
function IsInCone(pos, center, middleAlpha, betaAvaiable)
	local a = GetAngleBetween(center, pos)
	local lb = middleAlpha - betaAvaiable
	local hb = middleAlpha + betaAvaiable
	if a >= lb and a <= hb then
		return true
	end
	a = math.mod((a + 180), 360)
	lb = math.mod((lb + 180), 360)
	hb = math.mod((hb + 180), 360)
	if a >= lb and a <= hb then
		return true
	end
end
