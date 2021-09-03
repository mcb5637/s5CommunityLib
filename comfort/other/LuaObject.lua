--AutoFixArg


---author:mcb		current maintainer:mcb		v0.9b
-- basic lua clases and objects.
-- TODO: Multi inheritance
-- 
-- to create a class:
-- - NewClass = BaseClass:CreateSubClass("NewClass")		creates a subclass NewClass with a parent class BaseClass.
-- to add methods/variables to your class use the annotations:
-- - NewClass:AStatic()					available in NewClass.
-- - NewClass:AMethod()					available in objects of NewClass.
-- - NewClass:AReference()				only shown to LuaDoc (when you want something to autocomplete but its defined in a subclass).
-- after all methods are added, call:
-- - NewClass:FinalizeClass()			this sets up all static members, and enables you to create subclasses and objects from it.
-- (optional) add a constructor:
-- - NewClass:Init(params)				this gets called when a new object is created. make sure to call its base constructor first.
-- to create objects from a class use:
-- - local obj = Class:New(params)		creates a new object of a class by calling its constructor.
-- call a base method:
-- - self:CallBaseMethod("MethodName", NewClass, ...)		needs a reference to the class implementing the method.
-- call a base static method:
-- - NewClass.CallBaseStatic("MethodName", NewClass, ...)	needs a reference to the class implementing the method.
-- check if a object is of a specific class (or one of its subclasses):
-- - Obj:InstanceOf(NewClass)			if you use Object as class to test against, this is always true.
-- these 2 also exist:
-- - Obj:ToString()						gets a string describing the object. by default it is tostring(self).
-- - Obj:Equals(otherObj)				checks equality, by default Obj==otherObj.
-- 
-- visibility rules (like public and private) do not exist, cause they would be hard to implement and only work with metatables.
-- also make sure you dont override members of a parent class, there is no way to separate them.
-- 
--- @class LuaObject
LuaObject = {Methods = {}, Base = nil, Statics={}, Creators={}, Class=nil}

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
	for _,n in ipairs{"AStatic", "AMethod", "AReference", "FinalizeClass"} do
		t[n] = LuaObject.Creators[n]
	end
	t.Base = self
	LuaObjectDatabase[classname] = t
	return t
end

function LuaObject.Methods.Init()
	
end

--- @return LuaObject
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
			rawset(t, k, v)
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

function LuaObject:AReference()
	setmetatable(self, {
		__newindex = function(t, k, v)
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
	for _,n in ipairs{"AStatic", "AMethod", "AReference", "FinalizeClass"} do
		self[n] = nil
	end
end

for _,n in ipairs{"AStatic", "AMethod", "AReference", "FinalizeClass"} do
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

function LuaObject_AbstractMethod()
	assert(false, "error: called an abstract method")
end

--[[
ClassA = {}
ClassA = LuaObject:CreateSubClass("ClassA")

ClassA:AMethod()
function ClassA:Foo()
	Message("a")
end

ClassA:FinalizeClass()

ClassB = {}
ClassB = ClassA:CreateSubClass("ClassB")

ClassB:AMethod()
function ClassB:Foo()
	Message("b")
	self:CallBaseMethod("Foo", ClassB)
end

ClassB:FinalizeClass()

ClassB:New():Foo()
]]