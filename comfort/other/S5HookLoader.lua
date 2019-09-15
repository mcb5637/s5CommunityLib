if mcbPacker then --mcbPacker.ignore
mcbPacker.require("S5Hook")
mcbPacker.require("s5CommunityLib/fixes/metatable")
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
mcbPacker.require("Umlaute")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb	   v0.5  
-- Lädt den S5Hook beim Start und danach automatisch nach jedem laden.  
-- Callbacks mit table.insert in S5HookLoader.cb eintragen.  
-- Callbacks, die nach dem GUI-Laden aufgerufen werden sollen, in S5HookLoader.GuiXMLLoaded eintragen. (auch mit table.insert)  
-- S5Hook.SetCustomNames wird automatisch aufgerufen, das globale GlobalNamesTable kann genauso verwendet werden wie ein normales table für S5Hook.SetCustomNames, allerdings werden die Namen vorher mit Umlaute bearbeitet.  
-- Neu in v0.4: Anpassung für neuen Lademechanismus ab S5Hook v1.2, entfernung von SCV 2.0 da S5Hook schnellere implementierung bietet)
-- 
-- S5HookLoader.Init(fma) 			in der FMA aufrufen.  
-- 											fma wird nach dem ersten laden einer GUI-xml aufgerufen, für Startbriefing oder Ähnliches.  
-- S5HookLoader.GuiXMLLoaded() 		nach dem laden einer GUI aufrufen.  
-- S5HookLoader.IsHookSCVLoaded() 	prüft, ob S5Hook und SCV 2.0 geladen sind. (SCV 2.0 ab v0.4 nicht mehr automatisch geladen)  
-- S5HookLoader.ReloadGlobalNamesTable()	parst die Texte in GlobalNamesTable erneut. Hilfreich wenn verschiedene Namen über @string geladen werden.  
-- 
-- benötigt:
-- - S5Hook ab v1.2
-- - Trigger-Fix
-- - metatable-savegame-fix
-- - Umlaute
S5HookLoader = {cb = {}, xmlLoad={}, GlobalNamesTable = {}, fma=nil}
function S5HookLoader.Init(fma)
	S5HookLoader.fma = fma
	S5HookLoader.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
	Mission_OnSaveGameLoaded = function()
		S5HookLoader.Mission_OnSaveGameLoaded()
		S5HookLoader.Load()
	end
	S5HookLoader.Load(true)
end

--- vom S5HookLoader über metatable und Umlaute als CustomNamesTable geladen
GlobalNamesTable = GlobalNamesTable or {}

function S5HookLoader.HookPreLoad()
	if not InstallS5Hook() then
		Message("Hook loading failed, please restart map or reload savegame!")
		Message("Hook laden fehlgeschlagen, bitte Map neu starten oder Spielstand neu laden!")
		return
	end
end

function S5HookLoader.Load(mapstart)
	if not S5Hook then
		if not InstallS5Hook() then
			Message("Hook loading failed, please restart map or reload savegame!")
			Message("Hook laden fehlgeschlagen, bitte Map neu starten oder Spielstand neu laden!")
			return
		end
	end
	for _,f in ipairs(S5HookLoader.cb) do
		f(mapstart)
	end
	S5Hook.SetCustomNames(S5HookLoader.GlobalNamesTable)
end

function S5HookLoader.GuiXMLLoaded(loadedWid)
	StartSimpleHiResJob(function(loadedWid)
		if XGUIEng.IsWidgetExisting(loadedWid)==0 then
			return
		end
		for _,f in ipairs(S5HookLoader.xmlLoad) do
			f()
		end
		if S5HookLoader.fma then
			S5HookLoader.fma()
			S5HookLoader.fma = nil
		end
		return true
	end, loadedWid)
end
function S5HookLoader.ReloadGlobalNamesTable()
	for k,v in pairs(GlobalNamesTable) do
		S5HookLoader.GlobalNamesTable[k] = Umlaute(v)
	end
end

function S5HookLoader.IsHookSCVLoaded()
	return S5Hook and ZO and true or false
end

metatable.set(GlobalNamesTable, {
	__newindex = function(nt, k, v)
		S5HookLoader.GlobalNamesTable[k] = Umlaute(v)
		rawset(GlobalNamesTable, k, v)
	end,
})
