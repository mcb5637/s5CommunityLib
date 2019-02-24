if mcbPacker then --mcbPacker.ignore
mcbPacker.require("S5Hook")
mcbPacker.require("s5CommunityLib/fixes/metatable")
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
mcbPacker.require("Umlaute")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb	   v0.5  
-- Lädt den S5Hook beim Start und danach automatisch nach jedem laden.  
-- Callbacks mit table.insert in s5HookLoader.cb eintragen.  
-- Callbacks, die nach dem GUI-Laden aufgerufen werden sollen, in s5HookLoader.xmlLoaded eintragen. (auch mit table.insert)  
-- S5Hook.SetCustomNames wird automatisch aufgerufen, das globale namesTable kann genauso verwendet werden wie ein normales table für S5Hook.SetCustomNames, allerdings werden die Namen vorher mit Umlaute bearbeitet.  
-- Neu in v0.4: Anpassung für neuen Lademechanismus ab S5Hook v1.2, entfernung von SCV 2.0 da S5Hook schnellere implementierung bietet)
-- 
-- s5HookLoader.init(fma) 			in der FMA aufrufen.  
-- 											fma wird nach dem ersten laden einer GUI-xml aufgerufen, für Startbriefing oder Ähnliches.  
-- s5HookLoader.xmlLoaded() 		nach dem laden einer GUI aufrufen.  
-- s5HookLoader.isHookSCVLoaded() 	prüft, ob S5Hook und SCV 2.0 geladen sind. (SCV 2.0 ab v0.4 nicht mehr automatisch geladen)  
-- s5HookLoader.reloadNamesTable()	parst die Texte in namesTable erneut. Hilfreich wenn verschiedene Namen über @string geladen werden.  
-- 
-- benötigt:
-- - S5Hook ab v1.2
-- - Trigger-Fix
-- - metatable-savegame-fix
-- - Umlaute
s5HookLoader = {cb = {}, xmlLoad={}, namesTable = {}, fma=nil}
function s5HookLoader.init(fma)
	s5HookLoader.fma = fma
	s5HookLoader.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
	Mission_OnSaveGameLoaded = function()
		s5HookLoader.Mission_OnSaveGameLoaded()
		s5HookLoader.load()
	end
	s5HookLoader.load(true)
end

--- vom s5HookLoader über metatable und Umlaute als CustomNamesTable geladen
namesTable = namesTable or {}

function s5HookLoader.hookPreLoad()
	if not InstallS5Hook() then
		Message("Hook loading failed, please restart map or reload savegame!")
		Message("Hook laden fehlgeschlagen, bitte Map neu starten oder Spielstand neu laden!")
		return
	end
end

function s5HookLoader.load(mapstart)
	if not S5Hook then
		if not InstallS5Hook() then
			Message("Hook loading failed, please restart map or reload savegame!")
			Message("Hook laden fehlgeschlagen, bitte Map neu starten oder Spielstand neu laden!")
			return
		end
	end
	for _,f in ipairs(s5HookLoader.cb) do
		f(mapstart)
	end
	S5Hook.SetCustomNames(s5HookLoader.namesTable)
end

function s5HookLoader.xmlLoaded(loadedWid)
	StartSimpleHiResJob(function(loadedWid)
		if XGUIEng.IsWidgetExisting(loadedWid)==0 then
			return
		end
		for _,f in ipairs(s5HookLoader.xmlLoad) do
			f()
		end
		if s5HookLoader.fma then
			s5HookLoader.fma()
			s5HookLoader.fma = nil
		end
		return true
	end, loadedWid)
end
function s5HookLoader.reloadNamesTable()
	for k,v in pairs(namesTable) do
		s5HookLoader.namesTable[k] = Umlaute(v)
	end
end

function s5HookLoader.isHookSCVLoaded()
	return S5Hook and ZO and true or false
end

metatable.set(namesTable, {
	__newindex = function(nt, k, v)
		s5HookLoader.namesTable[k] = Umlaute(v)
		rawset(namesTable, k, v)
	end,
})
