if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore


-- ************************************************************************************************
-- Next Tick by RobbiTheFox
-- requires trigger fix
-- ************************************************************************************************
function NextTick(_Callback, ...)

	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, NextTick_Internal, 1, nil, {_Callback, unpack(arg)})
end
function NextTick_Internal(_Callback, ...)

	_Callback(unpack(arg))
	return true
end