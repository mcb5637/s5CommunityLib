if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
end --mcbPacker.ignore


--- author:mcb		current maintainer:mcb		v1.0
-- Datenstruktur priorityQueue als OOP.
-- 
-- q = priorityQueue:init()			Gibt eine neue leere priorityQueue zurück
-- q:add(a, v)						Fügt den Wert a mit der gewichtung v hinzu.
-- q:remove()						Entfernt den Wert mit der geringsten Gewichtung und gibt ihn zurück.
-- q:isEmpty()						Gibt zurück, ob die priorityQueue leer ist.
-- q:decrease(a, v)					Verringert die gewichtung von a auf v.
-- 
-- Benötigt:
-- - CopyTable
priorityQueue = {vals={}}
function priorityQueue:init()
	return CopyTable(self)
end
function priorityQueue:add(a, v)
	local ins = {v=v, a=a}
	for i=1,table.getn(self.vals) do
		if self.vals[i].v > v then
			table.insert(self.vals, i, ins)
			return
		end
	end
	table.insert(self.vals, ins)
end
function priorityQueue:remove()
	return table.remove(self.vals, 1).a
end
function priorityQueue:isEmpty()
	return not self.vals[1]
end
function priorityQueue:decrease(a, v)
	for i=1,table.getn(self.vals) do
		if self.vals[i].a == a then
			table.remove(self.vals, i)
			self:add(a, v)
			return
		end
	end
end
