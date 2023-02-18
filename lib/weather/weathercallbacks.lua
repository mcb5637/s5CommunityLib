if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
if not CUtil then
mcbPacker.require("s5CommunityLib/lib/weather/WeatherCallbackExtensions")
end
end --mcbPacker.ignore

--------------------------------------------------------------------------------------------------------------------------------------------
-- Weather Callbacks by RobbiTheFox
-- v 1.1
-- requires:
-- TriggerFix
-- CUtilMemory or WeatherCallbackExtensions
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks = WeatherCallbacks or {}
WeatherCallbacks.GfxId = 0
	
WeatherCallbacks.WeatherCallbacks = {
	OnStart	= {},
	OnEnd	= {},
}
WeatherCallbacks.GfxCallbacks = {
	OnStart	= {},
	OnEnd	= {},
}
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.Init = function()

	WeatherCallbacks.OnWeatherIdChanged(nil, Logic.GetWeatherState())
	Trigger.RequestTrigger(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED, nil, WeatherCallbacks.WeatherTrigger, 1)
	
	if CUtilMemory then
		WeatherCallbacks.GfxId = CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][11][10]:GetInt()
		WeatherCallbacks.JobId = StartSimpleJob(WeatherCallbacks.GfxJob)
	end
	
	WeatherCallbacks.OnGfxIdChanged(nil, WeatherCallbacks.GfxId)
end
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.WeatherTrigger = function()
	WeatherCallbacks.OnWeatherIdChanged(Event.GetOldWeatherState(), Event.GetNewWeatherState())
end
WeatherCallbacks.OnWeatherIdChanged = function(_oldId, _newId)

	local CallbackEnd = WeatherCallbacks.WeatherCallbacks.OnEnd[_oldId]
	if CallbackEnd then
		for _,v in pairs(CallbackEnd) do
			v()
		end
	end
	
	local CallbackStart = WeatherCallbacks.WeatherCallbacks.OnStart[_newId]
	if CallbackStart then
		for _,v in pairs(CallbackStart) do
			v()
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.GfxJob = function()

	local CurrentGfxId = CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][11][10]:GetInt()
	if WeatherCallbacks.GfxId ~= CurrentGfxId then
	
		WeatherCallbacks.OnGfxIdChanged(WeatherCallbacks.GfxId, CurrentGfxId)
		WeatherCallbacks.GfxId = CurrentGfxId
	end
end
WeatherCallbacks.OnGfxIdChanged = function(_oldId, _newId)
	
	local CallbackEnd = WeatherCallbacks.GfxCallbacks.OnEnd[_oldId]
	if CallbackEnd then
		for _,v in pairs(CallbackEnd) do
			v()
		end
	end
	
	local CallbackStart = WeatherCallbacks.GfxCallbacks.OnStart[_newId]
	if CallbackStart then
		for _,v in pairs(CallbackStart) do
			v()
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.AddWeatherCallback = function(_Id, _CallbackStart, _CallbackEnd)
	WeatherCallbacks.WeatherCallbacks.OnStart[_Id] = WeatherCallbacks.WeatherCallbacks.OnStart[_Id] or {}
	table.insert(WeatherCallbacks.WeatherCallbacks.OnStart[_Id], _CallbackStart)
	
	WeatherCallbacks.WeatherCallbacks.OnEnd[_Id] = WeatherCallbacks.WeatherCallbacks.OnEnd[_Id] or {}
	table.insert(WeatherCallbacks.WeatherCallbacks.OnEnd[_Id], _CallbackEnd)
end
WeatherCallbacks.RemoveWeatherCallbacks = function(_Id)
	WeatherCallbacks.WeatherCallbacks.OnStart[_Id] = nil
	WeatherCallbacks.WeatherCallbacks.OnEnd[_Id] = nil
end
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.AddGfxCallback = function(_Id, _CallbackStart, _CallbackEnd)
	WeatherCallbacks.GfxCallbacks.OnStart[_Id] = WeatherCallbacks.GfxCallbacks.OnStart[_Id] or {}
	table.insert(WeatherCallbacks.GfxCallbacks.OnStart[_Id], _CallbackStart)
	
	WeatherCallbacks.GfxCallbacks.OnEnd[_Id] = WeatherCallbacks.GfxCallbacks.OnEnd[_Id] or {}
	table.insert(WeatherCallbacks.GfxCallbacks.OnEnd[_Id], _CallbackEnd)
end
WeatherCallbacks.RemoveGfxCallbacks = function(_Id)
	WeatherCallbacks.GfxCallbacks.OnStart[_Id] = nil
	WeatherCallbacks.GfxCallbacks.OnEnd[_Id] = nil
end
--------------------------------------------------------------------------------------------------------------------------------------------