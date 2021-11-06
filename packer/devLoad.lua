--mcbPacker.returnIfDef:CopyToOneFile

---author:mcb		current maintainer:mcb		v1.0b
-- Einfache implementierung von require.
-- korrete suche von scripten funktioniert nur mit CppLogic. Ohne wird immer das erste script geladen.
-- 
-- - mcbPacker.Paths							array von pfaden, im format {[1],[2]}. das zu ladende script wird zwischen den beiden eingefügt.
-- 					default: {"data/maps/externalmap/", ".lua"}, {"data/maps/externalmap/", ".luac"}
-- 
-- - mcbPacker.require(file)					lädt file wenn es noch nicht geladen ist.
-- - mcbPacker.forceLoad(file)					lädt file, egal ob es bereits geladen ist. trägt außerdem nichts in die geladenen dateien ein.
-- 													auch aus file mit require geladene scripte werden nicht als geladen eingetragen.
-- 
-- Paths for folder maps "data\\maps\\user\\"..mapname.."\\" (may only use \\)
-- Usual path for s5x "data/maps/externalmap/" (may use / or \\, but not mixed).
-- require changes all path separators to \\.
--
-- Beispiel:
-- Script.Load("data/maps/externalmap/s5CommunityLib/packer/devLoad.lua")			--genau dieses script laden.
-- mcbPacker.require("s5CommunityLib/fixes/TriggerFix")								--zum laden eines scriptes.
-- 
---@diagnostic disable-next-line: lowercase-global
mcbPacker = {loaded={}, assertIfNotFound=false}
mcbPacker.Paths = {
	{"data/maps/externalmap/", ".lua"},
	{"data/maps/externalmap/", ".luac"},
	{Folders.Map, ".lua"},
	{Folders.Map, ".luac"},
}
if GDB.IsKeyValid("workspace") then --mcbPacker.ignore
	table.insert(mcbPacker.Paths, 1, {GDB.GetString("workspace"), ".lua"}) --mcbPacker.ignore
end --mcbPacker.ignore

function mcbPacker.require(file)
	if not mcbPacker.loaded[file] then
		mcbPacker.loaded[file] = true
		mcbPacker.load(file)
	end
end

function mcbPacker.forceLoad(file)
	local fl = mcbPacker.loaded
	mcbPacker.loaded = {}
	mcbPacker.load(file)
	mcbPacker.loaded = fl
end

function mcbPacker.load(file)
	local p = mcbPacker.Paths[1]
	local path = string.gsub(p[1]..file..p[2], "/", "\\")
	if CppLogic then
		for _,lp in ipairs(mcbPacker.Paths) do
			local newpath = string.gsub(lp[1]..file..lp[2], "/", "\\")
			if CppLogic.API.DoesFileExist(newpath) then
				path = newpath
				break
			end
		end
		if mcbPacker.assertIfNotFound then
			assert(CppLogic.API.DoesFileExist(path), "mcbPacker cound not find file: "..file.."\n"..CppLogic.API.StackTrace())
		elseif mcbPacker.DoesReallyHaveDebugger() and not CppLogic.API.DoesFileExist(path) then
			LuaDebugger.Log("mcbPacker cound not find file: "..file.."\n"..CppLogic.API.StackTrace())
		end
	end
	Script.Load(path)
	mcbPacker.loaded[file] = true
end

function mcbPacker.DoesReallyHaveDebugger()
	if mcbPacker.HasDebugger == nil then
		mcbPacker.HasDebugger = false
		if LuaDebugger.Log then
			-- c funcs cannot be dumped, so dump throws an error
			xpcall(function()
				string.dump(LuaDebugger.Log)
			end, function() mcbPacker.HasDebugger = true end)
		end
	end
	return mcbPacker.HasDebugger
end
