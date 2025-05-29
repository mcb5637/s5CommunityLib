if mcbPacker then
	mcbPacker.require("s5CommunityLib/lib/MemLib/MemLib")
	MemLib.Load("Weather")
end
--------------------------------------------------------------------------------
-- author: RobbiTheFox, current maintainer: RobbiTheFox, v1.3
-- requires:
-- MemLib.Weather
--------------------------------------------------------------------------------
WeatherCallbacks = {
	WeatherCallbacks = {
		OnStart	= {},
		OnEnd	= {},
	},
	GfxCallbacks = {
		OnStart	= {},
		OnEnd	= {},
	},
}
--------------------------------------------------------------------------------
function WeatherCallbacks.Init()

	WeatherCallbacks.OnWeatherIdChanged(nil, Logic.GetWeatherState())
	WeatherCallbacks.WeatherTriggerId = Trigger.RequestTrigger(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED, nil, "WeatherCallbacks_WeatherTrigger", 1)

	WeatherCallbacks.CurrentGfxId = MemLib.Weather.GetCurrentWeatherGfxState()
	WeatherCallbacks.GfxTriggerId = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "WeatherCallbacks_GfxTrigger", 1)

	WeatherCallbacks.OnGfxIdChanged(nil, WeatherCallbacks.CurrentGfxId)
end
--------------------------------------------------------------------------------
-- internal
function WeatherCallbacks_WeatherTrigger()
	WeatherCallbacks.OnWeatherIdChanged(Event.GetOldWeatherState(), Event.GetNewWeatherState())
end
--------------------------------------------------------------------------------
-- internal
---@param _OldWeatherState? integer
---@param _NewWeatherState? integer
function WeatherCallbacks.OnWeatherIdChanged(_OldWeatherState, _NewWeatherState)

	local CallbackEnd = WeatherCallbacks.WeatherCallbacks.OnEnd[_OldWeatherState]
	if CallbackEnd then
		for _, callback in pairs(CallbackEnd) do
			callback()
		end
	end

	local CallbackStart = WeatherCallbacks.WeatherCallbacks.OnStart[_NewWeatherState]
	if CallbackStart then
		for _, callback in pairs(CallbackStart) do
			callback()
		end
	end
end
--------------------------------------------------------------------------------
-- internal
function WeatherCallbacks_GfxTrigger()

	local CurrentGfxId = MemLib.Weather.GetCurrentWeatherGfxState()
	if WeatherCallbacks.CurrentGfxId ~= CurrentGfxId then

		WeatherCallbacks.OnGfxIdChanged(WeatherCallbacks.CurrentGfxId, CurrentGfxId)
		WeatherCallbacks.CurrentGfxId = CurrentGfxId
	end
end
--------------------------------------------------------------------------------
-- internal
---@param _OldGfxState? integer
---@param _NewGfxState? integer
function WeatherCallbacks.OnGfxIdChanged(_OldGfxState, _NewGfxState)

	local CallbackEnd = WeatherCallbacks.GfxCallbacks.OnEnd[_OldGfxState]
	if CallbackEnd then
		for _, callback in pairs(CallbackEnd) do
			callback()
		end
	end

	local CallbackStart = WeatherCallbacks.GfxCallbacks.OnStart[_NewGfxState]
	if CallbackStart then
		for _, callback in pairs(CallbackStart) do
			callback()
		end
	end
end
--------------------------------------------------------------------------------
---@param _WeatherState integer
---@param _CallbackStart? function
---@param _CallbackEnd? function
---@return integer CallbackStartId
---@return integer CallbackEndId
function WeatherCallbacks.AddWeatherCallback(_WeatherState, _CallbackStart, _CallbackEnd)
	WeatherCallbacks.WeatherCallbacks.OnStart[_WeatherState] = WeatherCallbacks.WeatherCallbacks.OnStart[_WeatherState] or {}
	table.insert(WeatherCallbacks.WeatherCallbacks.OnStart[_WeatherState], _CallbackStart)

	WeatherCallbacks.WeatherCallbacks.OnEnd[_WeatherState] = WeatherCallbacks.WeatherCallbacks.OnEnd[_WeatherState] or {}
	table.insert(WeatherCallbacks.WeatherCallbacks.OnEnd[_WeatherState], _CallbackEnd)

	return _CallbackStart and table.getn(WeatherCallbacks.WeatherCallbacks.OnStart[_WeatherState]) or 0, _CallbackEnd and table.getn(WeatherCallbacks.WeatherCallbacks.OnEnd[_WeatherState]) or 0
end
--------------------------------------------------------------------------------
---@param _WeatherState integer
---@param _Id integer
function WeatherCallbacks.RemoveWeatherCallbacks(_WeatherState, _Id)
	WeatherCallbacks.WeatherCallbacks.OnStart[_WeatherState][_Id] = nil
	WeatherCallbacks.WeatherCallbacks.OnEnd[_WeatherState][_Id] = nil
end
--------------------------------------------------------------------------------
---@param _GfxState integer
---@param _CallbackStart? function
---@param _CallbackEnd? function
---@return integer CallbackStartId
---@return integer CallbackEndId
function WeatherCallbacks.AddGfxCallback(_GfxState, _CallbackStart, _CallbackEnd)
	WeatherCallbacks.GfxCallbacks.OnStart[_GfxState] = WeatherCallbacks.GfxCallbacks.OnStart[_GfxState] or {}
	table.insert(WeatherCallbacks.GfxCallbacks.OnStart[_GfxState], _CallbackStart)

	WeatherCallbacks.GfxCallbacks.OnEnd[_GfxState] = WeatherCallbacks.GfxCallbacks.OnEnd[_GfxState] or {}
	table.insert(WeatherCallbacks.GfxCallbacks.OnEnd[_GfxState], _CallbackEnd)

	return _CallbackStart and table.getn(WeatherCallbacks.GfxCallbacks.OnStart[_GfxState]) or 0, _CallbackEnd and table.getn(WeatherCallbacks.GfxCallbacks.OnEnd[_GfxState]) or 0
end
--------------------------------------------------------------------------------
---@param _GfxState integer
---@param _Id integer
function WeatherCallbacks.RemoveGfxCallbacks(_GfxState, _Id)
	WeatherCallbacks.GfxCallbacks.OnStart[_GfxState][_Id] = nil
	WeatherCallbacks.GfxCallbacks.OnEnd[_GfxState][_Id] = nil
end