

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
-- Beispiel:
-- Script.Load("data/maps/externalmap/s5CommunityLib/packer/devLoad.lua")			--genau dieses script laden.
-- mcbPacker.require("s5CommunityLib/fixes/TriggerFix")								--zum laden eines scriptes.
-- 
---@diagnostic disable-next-line: lowercase-global
mcbPacker = {loaded={}}
mcbPacker.Paths = {
	{"data/maps/externalmap/", ".lua"},
	{"data/maps/externalmap/", ".luac"}
}
if GDB.IsKeyValid("workspace") then
	table.insert(mcbPacker.Paths, 1, {GDB.GetString("workspace"), ".lua"})
end

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
	if CppLogic then
		for _,lp in ipairs(mcbPacker.Paths) do
			if CppLogic.API.DoesFileExist(lp[1]..file..lp[2]) then
				p = lp
				if LuaDebugger.Log then
					LuaDebugger.Log(lp[1])
				end
				break
			end
		end
	end
	Script.Load(p[1]..file..p[2])
	mcbPacker.loaded[file] = true
end
