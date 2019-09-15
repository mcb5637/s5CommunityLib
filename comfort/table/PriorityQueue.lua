if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
end --mcbPacker.ignore


--- author:mcb		current maintainer:mcb		v1.0
-- Datenstruktur PriorityQueue als OOP.
-- 
-- q = PriorityQueue:New()			Gibt eine neue leere PriorityQueue zurück
-- q:Add(a, v)						Fügt den Wert a mit der gewichtung v hinzu.
-- q:Remove()						Entfernt den Wert mit der geringsten Gewichtung und gibt ihn zurück.
-- q:IsEmpty()						Gibt zurück, ob die PriorityQueue leer ist.
-- q:Decrease(a, v)					Verringert die gewichtung von a auf v.
-- 
-- Benötigt:
-- - CopyTable
PriorityQueue = {vals={}}
function PriorityQueue:New()
	return CopyTable(self)
end
function PriorityQueue:Add(a, v)
	local ins = {v=v, a=a}
	for i=1,table.getn(self.vals) do
		if self.vals[i].v > v then
			table.insert(self.vals, i, ins)
			return
		end
	end
	table.insert(self.vals, ins)
end
function PriorityQueue:Remove()
	return table.remove(self.vals, 1).a
end
function PriorityQueue:IsEmpty()
	return not self.vals[1]
end
function PriorityQueue:Decrease(a, v)
	for i=1,table.getn(self.vals) do
		if self.vals[i].a == a then
			table.remove(self.vals, i)
			self:add(a, v)
			return
		end
	end
end
