if mcbPacker then
mcbPacker.require("s5CommunityLib/comfort/pos/GetCirclePosition")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/pos/GetAngleBetween")
end

--- author:mcb		current maintainer:mcb		v1.0
-- rotiert eine position oder ein blocking table um einen bestimmten winkel.
--
-- Benötigt:
-- - GetCirclePosition
-- - GetDistance
-- - GetAngleBetween
--
--- @param pos table position oder table von positionen
--- @param angle number winkel in deg
--- @param center table|nil position um die rotiert wird, {X=0,Y=0} wenn nicht angegeben
--- @return table rpos rotierte position(en), selbes format wie pos
function RotatePositionAround(pos, angle, center)
	if not center then
		center = {X=0,Y=0}
	end
	if not pos.X then
		local pr = {}
		for i,p in ipairs(pos) do
			pr[i] = RotatePositionAround(p, angle, center)
		end
		return pr
	end
	angle = math.rad(angle)
    local s = math.sin(angle)
    local c = math.cos(angle)
	local x = pos.X - center.X
	local y = pos.Y - center.Y
    return { X= x * c - y * s + center.X, Y= x * s + y * c + center.Y }
	--return GetCirclePosition(center, GetDistance(center, pos), GetAngleBetween(center, pos)+angle)
end
