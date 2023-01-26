if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore


-- ************************************************************************************************
-- Next Tick by RobbiTheFox
-- requires trigger fix
-- ************************************************************************************************
function NextTick(_Callback, ...)

	StartSimpleHiResJob(NextTick_Internal, _Callback, unpack(arg))
end
function NextTick_Internal(_Callback, ...)

	_Callback(unpack(arg))
	return true
end