if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/LuaObject")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1
--- small timer object that does not require constant counting of seconds
---@class UpdatelessTimer : LuaObject
UpdatelessTimer = {Timer = 0}

---@type UpdatelessTimer
UpdatelessTimer = LuaObject:CreateSubClass("UpdatelessTimer")

UpdatelessTimer:AStatic()
UpdatelessTimer.Type = {Seconds = 1, Ticks = 2, RealTime = 3}

UpdatelessTimer:AReference()
---@return UpdatelessTimer
---@param type number|nil
function UpdatelessTimer:New(type)
end

UpdatelessTimer:AMethod()
function UpdatelessTimer:Init(type)
	if not type or type == UpdatelessTimer.Type.Seconds then
		self.Get = function() return Logic.GetTime() end
	elseif type == UpdatelessTimer.Type.Ticks then
		self.Get = function() return Logic.GetCurrentTurn() end
	elseif type == UpdatelessTimer.Type.RealTime then
		self.Get = function() return XGUIEng.GetSystemTime() end
	else
		assert(false, "invalid timer type")
	end
	self.Timer = 0
end

UpdatelessTimer:AMethod()
---@param time number
---@param fromNow boolean|nil
function UpdatelessTimer:Set(time, fromNow)
	if fromNow or fromNow == nil then
		time = time + self.Get()
	end
	self.Timer = time
end

UpdatelessTimer:AMethod()
---@return boolean
function UpdatelessTimer:Check()
	return self.Timer <= self.Get()
end

UpdatelessTimer:FinalizeClass()
