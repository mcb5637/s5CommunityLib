if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/pos/GetAngleBetween")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1
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
