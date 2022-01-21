
--- author:mcb		current maintainer:mcb		v1
-- checks all global reachable data for savegame-compatibility.
-- outputs to LuaDebugger.Log, so should only be used from the debugger.
-- (you may ignore any of this if you are doing a MP script, but your map might not be able to work correctly when started in SP).
--
-- Usage:
-- CheckGlobalsForSavegame()
--
-- error types:
-- - invalid table key: tables may only contain keys that are strings or numbers, saving crashes otherwise.
-- - function/string too long: there is a size limit for functions and strings (exact limit not known), crashes on saving or loading.
--		split functions/strings up into multiples as a workaround.
-- warning types:
-- - numeric table key < 0: numeric keys below 0 get changed into strings somewhere between saving and loading. No fix known.
-- - metatable: metatables do get ignored by savegames (they become nil on loadig). manually re-setting them works.
-- - function upvalues: they cannot get saved and loaded. usually after loading all upvalues are nil, but there are no gurantees. no workaround known.
--		(note: upvalue detection only works with CppLogic).
--		(some of the C lib funcs have upvalues, this is completely normal).
-- - thread (coroutine): coroutines cannot be saved (they become nil on loadig). no generic workaround known.
-- note types:
-- - userdata: userdata canot get saved, but as they are used only by c lib code, this is usually of no concern to scripters.
--		(they become nil on loadig).
--		(there seems to be always one userdata at _G._BBIH, other userdata may be used by CppLogic or Kimichuras dlls).
-- currently no reporting:
-- - C lib function: theoretically also a note, but as S5 makes extensive use of them, does not generate a note. they become nil on loadig.
-- - tables of C lib funcs that get added by C lib code: savegame routine most likely overrides your lib table by the empty one from the savegame.
--		(use FrameworkWrapper.Savegame.DoNotSaveGlobals as a workaround).
function CheckGlobalsForSavegame(t, str, done)
	if t==nil then
		t = _G
		str = "_G"
		done = {}
	end
	local maxs = 25000
	if type(t)=="table" then
		if not done[t] then
			done[t] = true
			for k,v in pairs(t) do
				if type(k)~="string" and type(k)~="number" then
					LuaDebugger.Log("error: table has invalid key "..type(k).." at "..str.."."..tostring(k))
				elseif type(k)=="number" and k < 0 then
					LuaDebugger.Log("warning: table has numeric key < 0 at "..str.."."..tostring(k))
				end
				CheckGlobalsForSavegame(v, str.."."..k, done)
			end
			if getmetatable(t) then
				LuaDebugger.Log("warning: table has metatable at "..str)
			end
		end
	elseif type(t)=="function" then
		xpcall(function()
			local l = string.len(string.dump(t))
			if l > maxs then
				LuaDebugger.Log("error: func to long "..str.." with "..l)
			end
		end, function()end)
		if CppLogic and CppLogic.API.GetFuncDebug then
			local f = CppLogic.API.GetFuncDebug(t)
			if f.nups > 0 then
				LuaDebugger.Log("warning: func has upvalues "..str)
			end
		end
	elseif type(t)=="string" then
		local l = string.len(t)
		if l > maxs then
			LuaDebugger.Log("error: string to long "..str.." with "..l)
		end
	elseif type(t)=="userdata" then
		LuaDebugger.Log("note: userdata at "..str)
	elseif type(t)=="thread" then
		LuaDebugger.Log("warning: thread (coroutine) at "..str)
	end
end
