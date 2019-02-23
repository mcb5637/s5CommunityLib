if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("fixes/metatable")
end --mcbPacker.ignore


--- author:mcb		current maintainer:mcb		v1.0
-- Einfache lua Vektorimplementierung mittels OOP.
-- 
-- vector.new(d)					Erzeugt einen neuen Vektor mit dem table d als Elemente.
-- vector:size()					Gibt zurück, wie lang der Vektor ist.
-- vector:add(v)					Addiert 2 Vektoren.
-- vector:mulSkalar(s)				Skalarmultiplikation.
-- vector:dot(v)					Skalarprodukt.
-- vector:makeSavegameCompatible()	Macht diesen Vektor über den metatable fix Savegamesicher.
-- 
-- Über metatable definiert:		*, -, +, .x, .y, .z
-- 
-- Benötigt:
-- - CopyTable
-- - metatable-fix (nur wenn vektoren gespeichert werden sollen)
vector = {}

function vector.new(d)
	local t = CopyTable(vector)
	t.data = d
	setmetatable(t, vector.mt)
	return t
end

function vector:size()
	return table.getn(self.data)
end

function vector:add(v)
	assert(self:size()==v:size())
	local newd = {}
	for i,d in ipairs(self.data) do
		newd[i] = d + v.data[i]
	end
	return vector.new(newd)
end

function vector:mulSkalar(s)
	local newd = {}
	for i,d in ipairs(self.data) do
		newd[i] = d * s
	end
	return vector.new(newd)
end

function vector:dot(v)
	assert(self:size()==v:size())
	local newd = 0
	for i,d in ipairs(self.data) do
		newd = newd + d * v.data[i]
	end
	return newd
end

function vector:makeSavegameCompatible()
	setmetatable(self, nil)
	metatable.set(self, vector.mt)
end

vector.mt = {
	__add = function(a, b)
		return a:add(b)
	end,
	__mul = function(a, b)
		if type(a)=="table" and type(b)=="number" then
			return a:mulSkalar(b)
		elseif type(b)=="table" and type(a)=="number" then
			return b:mulSkalar(a)
		else
			assert(false, "vector-vector multiplocation not implemented!")
		end
	end,
	__sub = function(a, b)
		return a + (-b)	-- forward to unm and add
	end,
	__unm = function(a)
		return -1 * a	-- forward to scalar mult
	end,
	__index = function(s, i)		-- allow numeric index acces to members
		if type(i)=="number" then
			return rawget(s, "data")[i]
		elseif i=="x" or i=="X" then
			return rawget(s, "data")[1]
		elseif i=="y" or i=="Y" then
			return rawget(s, "data")[2]
		elseif i=="z" or i=="Z" then
			return rawget(s, "data")[3]
		else
			return rawget(s, i)
		end
	end,
	__newindex = function(s, i, d)		-- allow numeric index acces to members
		if type(i)=="number" then
			rawget(s, "data")[i] = d
		elseif i=="x" or i=="X" then
			rawget(s, "data")[1] = d
		elseif i=="y" or i=="Y" then
			rawget(s, "data")[2] = d
		elseif i=="z" or i=="Z" then
			rawget(s, "data")[3] = d
		else
			return rawset(s, i, d)
		end
	end,
}

