if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/fixes/metatable")
end --mcbPacker.ignore


--- author:mcb		current maintainer:mcb		v1.0
-- Einfache lua Vektorimplementierung mittels OOP.
-- 
-- Vector.New(d)					Erzeugt einen neuen Vektor mit dem table d als Elemente.
-- Vector:Size()					Gibt zurück, wie groß der Vektor ist (dimension).
-- Vector:Add(v)					Addiert 2 Vektoren.
-- Vector:SkalarMultiplication(s)	Skalarmultiplikation.
-- Vector:Dot(v)					Skalarprodukt.
-- Vector:MakeSavegameCompatible()	Macht diesen Vektor über den metatable fix Savegamesicher.
-- Vector:Length()					Länge des Vektors.
-- 
-- Über metatable definiert:		*, -, +, .x, .y, .z
-- 
-- Benötigt:
-- - CopyTable
-- - metatable-fix (nur wenn vektoren gespeichert werden sollen)
Vector = {}

function Vector.New(d)
	local t = CopyTable(Vector)
	t.data = d
	setmetatable(t, Vector.mt)
	return t
end

function Vector:Size()
	return table.getn(self.data)
end

function Vector:Add(v)
	assert(self:Size()==v:Size())
	local newd = {}
	for i,d in ipairs(self.data) do
		newd[i] = d + v.data[i]
	end
	return Vector.New(newd)
end

function Vector:SkalarMultiplication(s)
	local newd = {}
	for i,d in ipairs(self.data) do
		newd[i] = d * s
	end
	return Vector.New(newd)
end

function Vector:Dot(v)
	assert(self:Size()==v:Size())
	local newd = 0
	for i,d in ipairs(self.data) do
		newd = newd + d * v.data[i]
	end
	return newd
end

function Vector:Length()
	return self:Dot(self)
end

function Vector:MakeSavegameCompatible()
	setmetatable(self, nil)
	metatable.set(self, Vector.mt)
end

Vector.mt = {
	__add = function(a, b)
		return a:Add(b)
	end,
	__mul = function(a, b)
		if type(a)=="table" and type(b)=="number" then
			return a:SkalarMultiplication(b)
		elseif type(b)=="table" and type(a)=="number" then
			return b:SkalarMultiplication(a)
		else
			assert(false, "Vector-Vector multiplocation not implemented!")
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

