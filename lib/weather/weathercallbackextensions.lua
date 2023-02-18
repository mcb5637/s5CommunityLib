if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore


--------------------------------------------------------------------------------------------------------------------------------------------
-- Weather Callback Extensions by RobbiTheFox
-- v 1.0
-- for weather extensions v 1.5 or higher
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks = WeatherCallbacks or {}
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.StateCallbacks = {
	OnStart	= {},
	OnEnd	= {},
}
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.Init = function()
	
	if WeatherExtensions then
		EndJob(WeatherCallbacks.JobId)
		WeatherCallbacks.GfxId = nil
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.OnStateChanged = function(_Dim, _OldId, _NewId)
	
	local CallbackEnd = (WeatherCallbacks.StateCallbacks.OnEnd[_Dim] or {})[_OldId]
	if CallbackEnd then
		for _,v in pairs(CallbackEnd) do
			v()
		end
	end
	
	local CallbackStart = (WeatherCallbacks.StateCallbacks.OnStart[_Dim] or {})[_NewId]
	if CallbackStart then
		for _,v in pairs(CallbackStart) do
			v()
		end
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
WeatherCallbacks.AddStateCallback = function(_Dim, _Id, _CallbackStart, _CallbackEnd)
	WeatherCallbacks.StateCallbacks.OnStart[_Dim] = WeatherCallbacks.StateCallbacks.OnStart[_Dim] or {}
	WeatherCallbacks.StateCallbacks.OnStart[_Dim][_Id] = WeatherCallbacks.StateCallbacks.OnStart[_Dim][_Id] or {}
	table.inset(WeatherCallbacks.StateCallbacks.OnStart[_Dim][_Id], _CallbackStart)
	
	WeatherCallbacks.StateCallbacks.OnEnd[_Dim] = WeatherCallbacks.StateCallbacks.OnEnd[_Dim] or {}
	WeatherCallbacks.StateCallbacks.OnEnd[_Dim][_Id] = WeatherCallbacks.StateCallbacks.OnEnd[_Dim][_Id] or {}
	table.insert(WeatherCallbacks.StateCallbacks.OnEnd[_Dim][_Id], _CallbackEnd)
end
WeatherCallbacks.RemoveStateCallbacks = function(_Dim, _Id)
	WeatherCallbacks.WeatherCallbacks.OnStart[_Dim] = nil
	WeatherCallbacks.WeatherCallbacks.OnEnd[_Dim] = nil
end
