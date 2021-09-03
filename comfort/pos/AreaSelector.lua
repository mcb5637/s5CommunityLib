--AutoFixArg
if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/other/LuaObject")
mcbPacker.require("s5CommunityLib/comfort/pos/IsValidPosition")
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- Einfache Möglichkeit verschiedene mapbereiche zu testen.
--
-- - area = AreaSelectorCircle:New(center, range)		Ein Kreis.  
-- - area = AreaSelectorPolygon:New(...)				Ein polygon.  
-- 
-- - area:IsPosInside(p)								Prüft ob eine position in dem gebiet ist.  
-- - area:GetDistanceToPos(p)							Die entfernung der position zum gebiet (>=0).  
-- - area.GetModifiedDistanceToPos(p)					Die entfernung der position zum gebiet (beidseitig, <0 -> innen).  
-- 
-- Benötigt:
-- - LuaObject
-- - GetDistance
-- - TriggerFix
-- - IsValidPosition
AreaSelector = {}
AreaSelector = LuaObject:CreateSubClass("AreaSelector")

AreaSelector:AMethod()
AreaSelector.IsPosInside = LuaObject_AbstractMethod

AreaSelector:AMethod()
AreaSelector.GetDistanceToPos = LuaObject_AbstractMethod

AreaSelector:AMethod()
AreaSelector.GetModifiedDistanceToPos = LuaObject_AbstractMethod

AreaSelector:FinalizeClass()

AreaSelectorCircle = {Center=nil, Range=nil}
AreaSelectorCircle = AreaSelector:CreateSubClass("AreaSelectorCircle")

AreaSelectorCircle:AMethod()
function AreaSelectorCircle:Init(center, range)
	self:CallBaseMethod("Init", AreaSelectorCircle)
	if IsValid(center) then
		center = GetPosition(center)
	end
	assert(IsValidPosition(center))
	assert(range>0)
	self.Center = center
	self.Range = range
end

AreaSelectorCircle:AMethod()
function AreaSelectorCircle:IsPosInside(p)
	return GetDistance(p, self.Center) <= self.Range
end

AreaSelectorCircle:AMethod()
function AreaSelectorCircle:GetDistanceToPos(p)
	return math.abs(self:GetModifiedDistanceToPos(p))
end

AreaSelectorCircle:AMethod()
function AreaSelectorCircle:GetModifiedDistanceToPos(p)
	return GetDistance(p, self.Center) - self.Range
end

AreaSelectorCircle:FinalizeClass()

AreaSelectorPolygon = {Polygon=nil}
AreaSelectorPolygon = AreaSelector:CreateSubClass("AreaSelectorPolygon")

AreaSelectorPolygon:AMethod()
function AreaSelectorPolygon:Init(...)
	self:CallBaseMethod("Init", AreaSelectorPolygon)
	self.Polygon = Polygon.New(unpack(arg))
end

AreaSelectorPolygon:AMethod()
function AreaSelectorPolygon:IsPosInside(p)
	return self.Polygon:IsPointInside(p)~=-1
end

AreaSelectorPolygon:AMethod()
function AreaSelectorPolygon:GetDistanceToPos(p)
	return self.Polygon:GetDistanceToPoint(p)
end

AreaSelectorPolygon:AMethod()
function AreaSelectorPolygon:GetModifiedDistanceToPos(p)
	return self.Polygon:GetModifiedDistance(p)
end

AreaSelectorPolygon:FinalizeClass()

AreaSelectorMultiOr = {Selectors=nil}
AreaSelectorMultiOr = AreaSelector:CreateSubClass("AreaSelectorMultiOr")

AreaSelectorMultiOr:AMethod()
function AreaSelectorMultiOr:Init(...)
	self:CallBaseMethod("Init", AreaSelectorMultiOr)
	for _,s in ipairs(arg) do
		assert(s:InstanceOf(AreaSelector))
	end
	assert(arg[1])
	self.Selectors = arg
end

AreaSelectorMultiOr:AMethod()
function AreaSelectorMultiOr:IsPosInside(p)
	for _,s in ipairs(self.Selectors) do
		if s:IsPosInside(p) then
			return true
		end
	end
	return false
end

AreaSelectorMultiOr:AMethod()
function AreaSelectorMultiOr:GetDistanceToPos(p)
	local r = nil
	for _,s in ipairs(self.Selectors) do
		local r2 = s:GetDistanceToPos(p)
		if not r or r > r2 then
			r = r2
		end
	end
	return r
end

AreaSelectorMultiOr:AMethod()
function AreaSelectorMultiOr:GetModifiedDistanceToPos(p)
	local r = nil
	for _,s in ipairs(self.Selectors) do
		local r2 = s:GetModifiedDistanceToPos(p)
		if not r or math.abs(r) > math.abs(r2) then
			r = r2
		end
	end
	return r
end

AreaSelectorMultiOr:FinalizeClass()
