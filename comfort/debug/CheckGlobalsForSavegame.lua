
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
-- - function/string too long: there is a size limit for functions and strings, might crashes on saving or loading, depending on what the buffer owerflow overrides.
--		split functions/strings up into multiples as a workaround.
-- - string table key with len >= 100: key sometines gets truncated, sometimes vanishes completely, might also crash. No fix known.
-- warning types:
-- - numeric table key < 0: key 0 gets changed to a string somewhere between saving and loading. No fix known.
-- - string table key that translates to a number >= 0: key gets changed to a number somewhere between saving and loading. No fix known.
-- - metatable: metatables do get ignored by savegames (they become nil on loadig). manually re-setting them works.
-- - function upvalues: they cannot get saved and loaded. usually the function is nil after loading. no workaround known.
--		(note: upvalue detection only works with CppLogic).
--		(some of the C lib funcs have upvalues, this is completely normal).
-- 		(note that without CppLogic the check cannot distinguish between C funcs and lua funcs with upvalues, because of this, common C func tables get ignored)
-- - thread (coroutine): coroutines cannot be saved (they become nil on loadig). no generic workaround known.
-- - C function: cannot get saved, but they usually get reapplied after loading a save. only gets reported, if it is unexpected.
-- 		(note that this check only gets performed with CppLogic)
-- note types:
-- - userdata: userdata canot get saved, but as they are used only by c lib code, this is usually of no concern to scripters.
--		(they become nil on loadig).
--		(there seems to be always one userdata at _G._BBIH, other userdata may be used by CppLogic or Kimichuras dlls).
-- currently no reporting:
-- - tables of C lib funcs that get added by C lib code: savegame routine most likely overrides your lib table by the empty one from the savegame.
--		(use FrameworkWrapper.Savegame.DoNotSaveGlobals as a workaround).
---@param t nil|table
---@param str nil|string
---@param done nil|table
---@param ignoreCFuncsIn nil|table
function CheckGlobalsForSavegame(t, str, done, ignoreCFuncsIn)
	if t==nil then
		t = _G
		str = "_G"
		done = {}
		ignoreCFuncsIn = {
			["_G.collectgarbage"]=true,
			["_G.math"]=true,
			["_G.gcinfo"]=true,
			["_G.SoundOptions"]=true,
			["_G.xpcall"]=true,
			["_G.Cutscene"]=true,
			["_G.tostring"]=true,
			["_G.Stream"]=true,
			["_G.assert"]=true,
			["_G.Event"]=true,
			["_G.loadstring"]=true,
			["_G.GUI"]=true,
			["_G.AI"]=true,
			["_G.table"]=true,
			["_G.ipairs"]=true,
			["_G.loadfile"]=true,
			["_G.Logic"]=true,
			["_G.Game"]=true,
			["_G.setmetatable"]=true,
			["_G.Input"]=true,
			["_G.getmetatable"]=true,
			["_G.rawset"]=true,
			["_G.rawget"]=true,
			["_G.dofile"]=true,
			["_G.Framework"]=true,
			["_G.Display"]=true,
			["_G.print"]=true,
			["_G.Script"]=true,
			["_G.LuaDebugger"]=true,
			["_G.getfenv"]=true,
			["_G.Mouse"]=true,
			["_G.pow"]=true,
			["_G._BBIH"]=true,
			["_G.__pow"]=true,
			["_G.rawequal"]=true,
			["_G.GDB"]=true,
			["_G.setfenv"]=true,
			["_G.pairs"]=true,
			["_G.pcall"]=true,
			["_G.coroutine"]=true,
			["_G.string"]=true,
			["_G.DisplayOptions"]=true,
			["_G.tonumber"]=true,
			["_G.Camera"]=true,
			["_G.XGUIEng"]=true,
			["_G.type"]=true,
			["_G.Music"]=true,
			["_G.XNetworkUbiCom"]=true,
			["_G.require"]=true,
			["_G.next"]=true,
			["_G.Sound"]=true,
			["_G.newproxy"]=true,
			["_G.Trigger"]=true,
			["_G.XNetwork"]=true,
			["_G.unpack"]=true,
			["_G.error"]=true,
			["_G.CppLogic"]=true,
			["_G.CppLogic_ResetGlobal"]=true,
		}
	end
	str = str or "_G"
	done = done or {}
	local maxs = 16000-1
	if type(t)=="table" then
		if not done[t] then
			done[t] = true
			for k,v in pairs(t) do
				if type(k)=="string" then
					if string.len(k) >= 100 then
						LuaDebugger.Log("error: table has string key with len >= 100 at "..str.."."..tostring(k))
					else
						local n = tonumber(k)
						if n and n >= 0 then
							LuaDebugger.Log("warning: table has string key wich translates to a number >= 0 at "..str.."."..tostring(k))
						end
					end
				elseif type(k)=="number" then
					if k < 0 then
						LuaDebugger.Log("warning: table has numeric key < 0 at "..str.."."..tostring(k))
					end
				else
					LuaDebugger.Log("error: table has invalid key "..type(k).." at "..str.."."..tostring(k))
				end
				CheckGlobalsForSavegame(v, str.."."..k, done, ignoreCFuncsIn)
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
		end, function()
			if not (CppLogic and CppLogic.API.GetFuncDebug) and not CheckGlobalsForSavegame_IsCFuncPath(str, ignoreCFuncsIn) then
				LuaDebugger.Log("warning: cannot dump function "..str..", might be c func or have upvalues (use CppLogic to get more info)")
			end
		end)
		if CppLogic and CppLogic.API.GetFuncDebug then
			local f = CppLogic.API.GetFuncDebug(t)
			if f.nups > 0 and f.what~="C" then
				LuaDebugger.Log("warning: func has upvalues "..str)
			end
			if f.what=="C" and not CheckGlobalsForSavegame_IsCFuncPath(str, ignoreCFuncsIn) then
				LuaDebugger.Log("warning: unexpected C function "..str)
			end
		end
	elseif type(t)=="string" then
		local l = string.len(t)
		if l > maxs then
			LuaDebugger.Log("error: string to long "..str.." with "..l)
		end
	elseif type(t)=="userdata" then
		if not CheckGlobalsForSavegame_IsCFuncPath(str, ignoreCFuncsIn) then
			LuaDebugger.Log("note: userdata at "..str)
		end
	elseif type(t)=="thread" then
		LuaDebugger.Log("warning: thread (coroutine) at "..str)
	end
end

function CheckGlobalsForSavegame_IsCFuncPath(str, ignoreCFuncsIn)
	if not ignoreCFuncsIn then
		return false
	end
	if ignoreCFuncsIn[str] then
		return true
	end
	if string.find(str, "^_G%.CppLogic%.") then
		return true
	end
	local i = 1
	while true do
		local n = string.find(str, ".", i+1, true)
		if not n then
			break
		end
		i = n
	end
	if i == 1 then
		return false
	end
	str = string.sub(str, 1, i-1)
	if ignoreCFuncsIn[str] then
		return true
	end
end
