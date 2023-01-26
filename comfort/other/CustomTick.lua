if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore



-- ************************************************************************************************
-- Custom Tick Library
-- v 1.2
-- by RobbiTheFox
-- ************************************************************************************************
-- Library to create Jobs with custom tick intervals
-- use CustomTick.AddCallback(_Callback, _TickRateMs) to add a job
-- jobs are active by default
-- for more details see below
-- self explanatory functions
-- CustomTick.PauseCallback(_Id)
-- CustomTick.ResumeCallback(_Id)
-- CustomTick.RemoveCallback(_Id)
-- ************************************************************************************************
CustomTick = {}
-- ************************************************************************************************
-- CustomTick.Init gets called automaticly on first use
-- passing an UpdateFunction of your choice does not work yet
-- ************************************************************************************************
function CustomTick.Init(_UpdateFunc)
	
	-- TODO: make it work, that you can pass an update function of your choice
	-- tho following does not work
	
	-- the uptade function should be one, which is called permanently, regardless of gamemode, GUIState etc.
	-- TODO: GUIUpdate_Population does not call in cinematic / briefing mode
	-- add more updatefunctions to call in these modes or add a widget which is always "visible" with a custom update function
	--[[if XGUIEng.IsWidgetExisting("CustomTick") == 0 then
		_UpdateFunc = _UpdateFunc or GUIUpdate_Population
		
		CustomTick.UpdateFunctionOrig = _UpdateFunc
		_UpdateFunc = function()
			
			CustomTick.ExecuteCallbacks()
			CustomTick.UpdateFunctionOrig()
		end
	end]]
	
	CustomTick.Callbacks = {
		--{Callback, TickRate, TickInRealTime, IgnoreGamePaused, IsPaused, LastCall,}
	}
	
	if XGUIEng.IsWidgetExisting("CustomTick") == 0 then
		
		GUIUpdate_Population_Orig = GUIUpdate_Population
		GUIUpdate_Population = function()
			
			CustomTick.ExecuteCallbacks()
			GUIUpdate_Population_Orig()
		end
		
	end
end
-- ************************************************************************************************
-- calls all callbacks which are not paused in their respective intervals
-- ************************************************************************************************
function CustomTick.ExecuteCallbacks()

	--for i = 1, table.getn(CustomTick.Callbacks) do
		--local callback = CustomTick.Callbacks[i]
		
	for _,callback in pairs(CustomTick.Callbacks) do
		
		if not callback.IsPaused then
			
			local factor = (callback.TickInRealTime) and 1 or Game.GameTimeGetFactor()
			local delta = Game.RealTimeGetMs() - callback.LastCall
			
			if factor == 0 or delta >= callback.TickRate / factor then
				
				-- is game running or do we have permission to call when game is paused?
				if Game.GameTimeGetFactor() ~= 0 or (callback.TickInRealTime and callback.IgnoreGamePaused) then -- is not the same as: if factor ~= 0 then !
					
					-- TODO: somehow save progess before game paused ?
					CustomTick.ExecuteCallback(callback)
				end
				
				-- currently the timer resets if game gets paused
				-- should not be a problem since this code is mostly designed for timigs < 100s
				-- above Events.LOGIC_EVENT_EVERY_TURN is the better alternative
				callback.LastCall = (factor > 0) and callback.LastCall + callback.TickRate / factor or Game.RealTimeGetMs()
			end
		end
	end
end
-- ************************************************************************************************
-- executes the callback function of the given callback
-- param: id or callback
-- ************************************************************************************************
function CustomTick.ExecuteCallback(_Callback)
	
	if type(_Callback) == "number" then
	
		if not CustomTick.IsValidCallback(_Callback) then
			return false
		end
		
		_Callback = CustomTick.Callbacks[_Callback]
	end
	
	if type(_Callback.Params) == "table" then

		_Callback.Callback(unpack(_Callback.Params))
	else
	
		_Callback.Callback(_Callback.Params)
	end
end
-- ************************************************************************************************
-- adds a callback to Callbacks table, callbacks start active by default
-- params:
-- Callback			function to call in given interval
-- TickRateMs		interval in ms to call _Callback
-- optional:
-- TickInRealTime	if true, interval uses real time instead of game time
-- IgnoreGamePaused	if true, _Callback will be called even if game is paused (TickInRealTime must also be true then)
-- IsPaused			if true, the callback starts paused and can be activated later
-- Params			table with additional params for _Callback
-- ************************************************************************************************
function CustomTick.AddCallback(_Callback, _TickRateMs, _TickInRealTime, _IgnoreGamePaused, _IsPaused, _Params)
	
	if type(_Callback) == "table" then
		_Params				= _Callback.Params
		_IsPaused			= _Callback.IsPaused
		_IgnoreGamePaused	= _Callback.IgnoreGamePaused
		_TickInRealTime		= _Callback.TickInRealTime
		_TickRateMs			= _Callback.TickRateMs
		_Callback			= _Callback.Callback
	end
	
	--if _IgnoreGamePaused then
		--_TickInRealTime = true
	--end
	
	assert(type(_Callback)=="function", "ERROR: CustomTick.AddCallback: _Callback must be of type function")
	assert(type(_TickRateMs)=="number", "ERROR: CustomTick.AddCallback: _TickRateMs must be of type number")
	
	-- call Init() if not done yet
	if not CustomTick.Callbacks then
		CustomTick.Init()
	end
	
	table.insert(CustomTick.Callbacks, {Callback = _Callback, TickRate = _TickRateMs, TickInRealTime = _TickInRealTime, IgnoreGamePaused = _IgnoreGamePaused, IsPaused = _IsPaused, Params = _Params, LastCall = Game.RealTimeGetMs(), } )
	local id = table.getn(CustomTick.Callbacks)
	
	return id
end
-- ************************************************************************************************
-- returns true if a callback is listed at the given id, false if not
-- ************************************************************************************************
function CustomTick.IsValidCallback(_Id)
	
	return CustomTick.Callbacks[_Id] ~= nil
end
-- ************************************************************************************************
-- pauses a callback
-- ************************************************************************************************
function CustomTick.PauseCallback(_Id)
	
	if CustomTick.IsValidCallback(_Id) then
		
		CustomTick.Callbacks[_Id].IsPaused = true
	end
end
-- ************************************************************************************************
-- returns true if callback is paused, false if not
-- returns nil if callback is invalid
-- ************************************************************************************************
function CustomTick.IsPausedCallback(_Id)
	
	if CustomTick.IsValidCallback(_Id) then
		
		return CustomTick.Callbacks[_Id].IsPaused == true
	end
end
-- ************************************************************************************************
-- resumes a callback
-- ************************************************************************************************
function CustomTick.ResumeCallback(_Id, _SupressInitialCall)
	
	if CustomTick.IsValidCallback(_Id) then
		
		CustomTick.Callbacks[_Id].IsPaused = false
		CustomTick.Callbacks[_Id].LastCall = Game.RealTimeGetMs()
	end
end
-- ************************************************************************************************
-- removes a callback from Callbacks table
-- ************************************************************************************************
function CustomTick.RemoveCallback(_Id)
	
	if CustomTick.IsValidCallback(_Id) then
		
		table.remove(CustomTick.Callbacks, _Id)
	end
end