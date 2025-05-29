--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- NextTick
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.1
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

-- executes function with params in the next game tick
---@param _Callback function
---@param ... any
function NextTick(_Callback, ...)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "NextTick_Internal", 1, nil, {_Callback, unpack(arg)})
end
function NextTick_Internal(_Callback, ...)
	_Callback(unpack(arg))
	return true
end