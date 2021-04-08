
--- author:mcb		current maintainer:mcb		v1.2
-- 
-- metatable.set(table, metatable) anstatt setmetatable verwenden.
-- Automatische Speicherung und Wiederherstellung nach dem Laden.
-- metatable == nil löscht aus der Wiederherstellung und entfernt metatable.
-- Ist ein table nur noch im Speicher für die Wiederherstellung, wird es trotzdem vom gc gelöscht (weak table).
-- Achtung, im Gegensatz zu setmetatable, wird das metatable kopiert, nicht referenziert!
-- 
---@diagnostic disable-next-line: lowercase-global
metatable = {weak = {}, metas = {}, key = 0}
function metatable.set(tab, meta)
	assert(type(tab)=="table", "metatables koennen nur fuer tables gesetzt werden! "..tostring(tab))
	assert(type(meta)=="table" or meta==nil, "metatable muss table oder nil sein! "..tostring(meta))
	if not metatable.Mission_OnSaveGameLoaded then -- erster Aufruf: init Loaded-Callback & weak table
		metatable.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
		Mission_OnSaveGameLoaded = function()
			metatable.Mission_OnSaveGameLoaded()
			metatable.recreate()
		end
		metatable.recreate()
	end
	local oldmeta = meta -- nötig für keySave bei verschiedenen tables mit demselben metatable
	meta = {}
	for k,v in pairs(oldmeta) do
		meta[k] = v
	end
	oldmeta = getmetatable(tab)
	setmetatable(tab, meta) -- setze metatable
	--metatable.weak[tab] = CopyTable(meta)   fehler!!! key = table => absturz!!!
	local k = 0
	if oldmeta and oldmeta.keySave and tab == metatable.weak[oldmeta.keySave] then -- hatte vorher schon metatable => alter key
		k = oldmeta.keySave
		if meta == nil then -- löschen!
			metatable.weak[k] = nil
			metatable.metas[k] = nil
			return
		end
	else -- neuer key
		k = metatable.key + 1
		metatable.key = k
	end
	metatable.weak[k] = tab
	metatable.metas[k] = meta
	meta.keySave = k
end
metatable.recreate = function()
	for k, tab in pairs(metatable.weak) do
		setmetatable(tab, metatable.metas[k])
	end
	setmetatable(metatable.weak, {__mode = "v"}) -- weak table => wird gelöscht, wenn value nur noch dort referenziert ist
	setmetatable(metatable.metas, {__mode = "v"})
end
