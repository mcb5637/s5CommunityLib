

---author:mcb		current maintainer:mcb		v1.0b
-- Einfache implementierung von require.
-- 
-- - mcbPacker.mainPath							auf den pfad setzen, von dem die scripte geladen werden sollen.
-- - mcbPacker.require(file)					lädt file wenn es noch nicht geladen ist.
-- 
-- Beispiel:
-- Script.Load("data/maps/externalmap/s5CommunityLib/packer/devLoad.lua")			--genau dieses script laden.
-- mcbPacker.mainPath = "data/maps/externalmap/"									--am besten, wenn eine map als s5x gepackt wird.
-- mcbPacker.require("s5CommunityLib/fixes/TriggerFix")								--zum laden eines scriptes.
-- 
mcbPacker = {loaded={}, mainPath=GDB.IsKeyValid("workspace") and GDB.GetString("workspace") or "data/maps/externalmap/"}

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
	Script.Load(mcbPacker.mainPath..file..".lua")
	mcbPacker.loaded[file] = true
end
