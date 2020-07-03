


LuaObject = {Methods = {}, Base = nil, Statics={}, Creators={}}

LuaObjectDatabase = {LuaObject = LuaObject}

function LuaObject.Statics:CreateSubClass(classname)
	local t = {}
	t.Methods = {}
	t.Statics = {}
	for k,v in pairs(self.Statics) do
		t.Statics[k] = v
	end
	--t.Statics.Methods = nil
	for k,v in pairs(self.Methods) do
		t.Methods[k] = v
	end
	for _,n in ipairs{"AStatic", "AMethod", "FinalizeClass"} do
		t[n] = LuaObject.Creators[n]
	end
	t.Base = self
	LuaObjectDatabase[classname] = t
	return t
end

function LuaObject.Methods.Init()
	
end

function LuaObject.Statics:New(...)
	local t = {}
	for k,v in pairs(self.Methods) do
		t[k] = v
	end
	t.Class = self
	t:Init(unpack(arg))
	t.Init = nil
	return t
end

function LuaObject:AStatic()
	setmetatable(self, {
		__newindex = function(t, k, v)
			t.Statics[k] = v
			setmetatable(t, nil)
		end,
	})
end

function LuaObject:AMethod()
	setmetatable(self, {
		__newindex = function(t, k, v)
			t.Methods[k] = v
			setmetatable(t, nil)
		end,
	})
end

function LuaObject:FinalizeClass()
	for k,v in pairs(self.Statics) do
		self[k] = v
	end
	--self.Statics = nil
	setmetatable(self, nil)
	for _,n in ipairs{"AStatic", "AMethod", "FinalizeClass"} do
		self[n] = nil
	end
end

for _,n in ipairs{"AStatic", "AMethod", "FinalizeClass"} do
	LuaObject.Creators[n] = LuaObject[n]
end

LuaObject:AMethod()
function LuaObject:GetBaseMethod(name, thisclass)
	local c = thisclass.Base
	while c do
		if c.Methods[name] then
			return c.Methods[name]
		end
		c = c.Base
	end
end

LuaObject:AMethod()
function LuaObject:CallBaseMethod(name, thisclass, ...)
	local f = self:GetBaseMethod(name, thisclass)
	if f then
		f(self, unpack(arg))
	end
end

LuaObject:AStatic()
function LuaObject:GetBaseStatic(name, thisclass)
	local c = thisclass.Base
	while c do
		if c[name] then
			return c[name]
		end
		c = c.Base
	end
end

LuaObject:AStatic()
function LuaObject:CallBaseStatic(name, thisclass, ...)
	local f = self:GetBaseStatic(name, thisclass)
	if f then
		f(self, unpack(arg))
	end
end

LuaObject:AMethod()
function LuaObject:InstanceOf(class)
	local c = self.Class
	while c do
		if c==class then
			return true
		end
		c = c.Base
	end
	return false
end

LuaObject:AMethod()
function LuaObject:ToString()
	return tostring(self)
end

LuaObject:AMethod()
function LuaObject:Equals(other)
	return self==other
end

LuaObject:FinalizeClass()

ClassA = LuaObject:CreateSubClass("ClassA")

ClassA:AMethod()
function ClassA:Foo()
	Message("a")
end

ClassA:FinalizeClass()


ClassB = ClassA:CreateSubClass("ClassB")

ClassB:AMethod()
function ClassB:Foo()
	Message("b")
	self:CallBaseMethod("Foo", ClassB)
end

ClassB:FinalizeClass()

ClassB:New():Foo()
