--AutoFixArg
if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")

-- try to load full version, if you do, just return and dont load this one
mcbPacker.require("comfort/FrameworkWrapper")
end --mcbPacker.ignore
--mcbPacker.returnIfDef:FrameworkWrapper
if FrameworkWrapper then
	return
end


--- author:mcb		current maintainer:mcb		v0.1b
-- FrameworkWrapper.Mapfile.			Funktionen um maps zu prüfen & starten.
-- 											typ, cm : beschreibt, was für eine Map gemeint ist. Usermap: 3, nil oder nil, nil.
-- IsValidMap(name, typ, cm)				Prüft anhand des filenames, ob eine Map vorhanden ist.
-- GetMapfileNameFromIndex(i, typ, cm)		Gibt den Filenamen einer bestimmten Map zurück.
-- GetAllMapfileNames(typ, cm)				gibt ein table mit den filenames ALLER maps zurück.
-- GetNumberOfMaps(typ, cm)					gibt die Anzahl der maps zurück.
-- GetMapNameAndDescription(name, typ, cm)	gibt den Mapnamen und den Beschreibungstext zurück.
-- GetCurrentMapNameAndDescription()		dasselbe für die aktuelle Map.
-- StartMap(name, typ, cm)					startet die Map ohne Rückfrage.
-- GetCampaignTypAndName(t)					gibt die letzten beiden Parameter zurück: cMain, cNebel, cLeg1-4, user, sp, mp.
--
-- Framework.							Diese funktionen verursachen keine Abstürze.
-- GetCurrentMapName()						gibt den filenamen der aktuellen Map zurück.
-- GetCurrentMapTypeAndCampaignName()		gibt die letzten beiden Parameter der aktuellen Map zurück.
-- CloseGame()								zurück zum Hauptmenü.
-- ExitGame()								zurück zum Desktop.
--
-- FrameworkWrapper.Savegame.			Funktionen die mit savegames zu tun haben.
-- 											slot ist normalerweise eine zahl zwischen 1 & 100.
-- IsValidSavegame(slot)					existiert das savegame und kann geladen werden?
-- GetSavegameName(slot)					gibt den Savegamename des savegames zurück.
-- LoadSave(slot)							lädt das savegame ohne Rückfrage.
-- createSavegameName()						erzeugt einen standard-Savegamenamen.
-- DoSaveInternal							intern, nicht benutzen!
-- DoSave(slot, name, cb)					Startet einen Job, der das Spiel speichert, sobald möglich. cb wird aufgerufen, nachdem gespeichert wurde.
--
-- Trigger:
-- Events.SCRIPT_EVENT_ON_LEAVE_MAP     	Der Grund wird als Event.Reason übergeben ("startMap", "loadSave", "restartMap", "quitMap", "quitGame").
-- Events.SCRIPT_EVENT_ON_PRE_SAVE  	    Wird vor dem Anlegen eines Savegames aufgerufen. Event.Slot is der slot.
-- Events.SCRIPT_EVENT_ON_POST_SAVE	        Wird nach dem Anlegen eines Savegames aufgerufen. Event.Slot is der slot.
-- 
-- Anderes:
-- FrameworkWrapper.Savegame.DoNotSaveGlobals	Table mit keys, die während dem speichern nicht aus _G erreichbar sind.
-- FrameworkWrapper.Savegame.LastSavegameslot	Letzter slot, mit dem die map gespeichert wurde.
--
-- FrameworkWrapper.GetOSTimeAsInt()			Gibt die OS Zeit als Int zurück (Sekunden seit Jahr 2000, 30 Tage Monat), für randomseed.
--
-- (dies ist die einfache version)
--
-- übershreibt die funktionen:
-- MainWindow_LoadGame_DoLoadGame, MainWindow_SaveGame_DoSaveGame, MainWindow_SaveGame_DoOverwriteSaveGame, GUIAction_RestartMap, QuitGame, QuickSave
--
-- benötigt:
-- Trigger-Fix
FrameworkWrapper={Mapfile={},Savegame={}}

TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_LEAVE_MAP")
TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_PRE_SAVE")
TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_POST_SAVE")

function FrameworkWrapper.Mapfile.IsValidMap(name, typ, cm)
	if type(name)~="string" then return false end
	return Framework.GetIndexOfMapName(name, typ or 3, cm)~=-1
end
function FrameworkWrapper.Mapfile.StartMap(name, typ, cm)
	assert(FrameworkWrapper.Mapfile.IsValidMap(name, typ, cm))
	FrameworkWrapper.Mapfile.DoLeaveMapCallback("startMap")
	Trigger.DisableTriggerSystem(1)
	Framework.StartMap(name, typ or 3, cm)
end
function FrameworkWrapper.Mapfile.GetMapNameAndDescription(name, typ, cm)
	assert(FrameworkWrapper.Mapfile.IsValidMap(name, typ, cm))
	return Framework.GetMapNameAndDescription(name, typ or 3, cm)
end
function FrameworkWrapper.Mapfile.GetNumberOfMaps(typ, cm)
	return Framework.GetNumberOfMaps(typ or 3, cm)
end
function FrameworkWrapper.Mapfile.GetMapfileNameFromIndex(i, typ, cm)
	local _,n = Framework.GetMapNames(i, 1, typ or 3, cm)
	return n
end
function FrameworkWrapper.Mapfile.GetAllMapfileNames(typ, cm)
	local n = FrameworkWrapper.Mapfile.GetNumberOfMaps(typ, cm)
	local d = {Framework.GetMapNames(0, n, typ or 3, cm)}
	assert(table.remove(d, 1)==n)
	return d
end
function FrameworkWrapper.Mapfile.GetCurrentMapNameAndDescription()
	return FrameworkWrapper.Mapfile.GetMapNameAndDescription(Framework.GetCurrentMapName(), Framework.GetCurrentMapTypeAndCampaignName())
end
function FrameworkWrapper.Mapfile.GetCampaignTypAndName(t)
	local t1 = {cMain=-1,cNebel=-1,cLeg1=-1,cLeg2=-1,cLeg3=-1,cLeg4=-1,user=3,sp=0,mp=2}
	local t2 = {cMain="Main",cNebel="Extra1",cLeg1="Extra2_1",cLeg2="Extra2_2",cLeg3="Extra2_3",cLeg4="Extra2_4"}
	return t1[t], t2[t]
end
function FrameworkWrapper.Mapfile.DoLeaveMapCallback(reason)
	local ev = TriggerFix.CreateEmptyEvent()
    ev.Reason = reason
    TriggerFix_action(Events.SCRIPT_EVENT_ON_LEAVE_MAP, ev)
end

function FrameworkWrapper.GetOSTimeAsInt()
	local str = Framework.GetSystemTimeDateString()
	local _, _, year, month, day, hour, min, sec = string.find(str, "(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-(%d+)")
	if CppLogic then
		CppLogic.Memory.SetFPU()
	end
	year = year - 2000 -- to get the number to manageable levels
	month = month + year*12
	day = day + month*30 -- easier than exact day per month
	hour = hour + day*24
	min = min + hour*60
	sec = sec + min*60
	return sec, str
end

function FrameworkWrapper.Savegame.IsValidSavegame(slot)
	local n = type(slot)=="string" and slot or "save_"..tostring(slot)
	return Framework.IsSaveGameValid(n)
end
function FrameworkWrapper.Savegame.GetSavegameName(slot)
	assert(FrameworkWrapper.Savegame.IsValidSavegame(slot))
	local n = type(slot)=="string" and slot or "save_"..tostring(slot)
	return Framework.GetSaveGameString(n)
end
function FrameworkWrapper.Savegame.IsSaveAllowed()
	if cutsceneIsActive then
		return false
	end
	if IsBriefingActive() and not mcbSaveDuringBriefingAllowed then
		return false
	end
	if CxTools and CxTools.tDelayFuncsJob then
		return false
	end
	if mcbDelay and mcbDelay.noSave() then
		return false
	end
	return true
end
FrameworkWrapper.Savegame.DoNotSaveGlobals = {"LuaDebugger", "CppLogic"}
function FrameworkWrapper.Savegame.DoPreSaveCallback(slot)
	local ev = TriggerFix.CreateEmptyEvent()
    ev.Slot = slot
    TriggerFix_action(Events.SCRIPT_EVENT_ON_PRE_SAVE, ev)
end
function FrameworkWrapper.Savegame.DoPostSaveCallback(slot)
	local ev = TriggerFix.CreateEmptyEvent()
    ev.Slot = slot
    TriggerFix_action(Events.SCRIPT_EVENT_ON_POST_SAVE, ev)
end
function FrameworkWrapper.Savegame.DoSaveInternal(slot, name, nomessage, cb, ...)
	if FrameworkWrapper.Savegame.PreventMultiSave then
		FrameworkWrapper.Savegame.PreventMultiSave = nil
		return "save2"
	end
	if not name then
		name = FrameworkWrapper.Savegame.CreateSavegameName()
	end
	if not FrameworkWrapper.Savegame.IsSaveAllowed() then
		return false
	end
	local n = type(slot)=="string" and slot or "save_"..tostring(slot)
	FrameworkWrapper.Savegame.LastSavegameslot = slot
	FrameworkWrapper.Savegame.DoPreSaveCallback(slot)
	local globalsSave = {}
	for _,gl in ipairs(FrameworkWrapper.Savegame.DoNotSaveGlobals) do
		globalsSave[gl] = _G[gl]
		_G[gl] = nil
	end
	FrameworkWrapper.Savegame.PreventMultiSave = true
	Framework.SaveGame(n, name)
	FrameworkWrapper.Savegame.PreventMultiSave = nil
	for _,gl in ipairs(FrameworkWrapper.Savegame.DoNotSaveGlobals) do
		 _G[gl] = globalsSave[gl]
	end
	FrameworkWrapper.Savegame.DoPostSaveCallback(slot)
	if not nomessage then
		Message(string.gsub(XGUIEng.GetStringTableText("InGameMessages/GUI_GameSaved"), "!", ": ")..name)
	end
	if cb then
		cb(unpack(arg))
	end
	return true
end
function FrameworkWrapper.Savegame.DoSave(slot, name, cb, ...)
	StartSimpleJob("FrameworkWrapper.Savegame.DoDelayedSaveJob", slot, name, cb, arg)
end
function FrameworkWrapper.Savegame.DoDelayedSaveJob(sl, na, cb, arg)
	local r = FrameworkWrapper.Savegame.DoSaveInternal(sl, na, nil, cb, unpack(arg))
	if r == true or r == "save2" then return true end
end
function FrameworkWrapper.Savegame.LoadSave(slot)
	assert(FrameworkWrapper.Savegame.IsValidSavegame(slot))
	local n = type(slot)=="string" and slot or "save_"..tostring(slot)
	FrameworkWrapper.Mapfile.DoLeaveMapCallback("loadSave")
	Trigger.DisableTriggerSystem(1)
	Framework.LoadGame(n)
end
function FrameworkWrapper.Savegame.CreateSavegameName()
	return FrameworkWrapper.Mapfile.GetCurrentMapNameAndDescription().." - "..Framework.GetSystemTimeDateString()
end

AddMapStartCallback(function()
	function MainWindow_LoadGame_DoLoadGame(i)
		i = MainWindow_SaveGame_LoadListOffset + i
		if i < table.getn(MainWindow_LoadGame_NameList) then
			FrameworkWrapper.Savegame.LoadSave(MainWindow_LoadGame_NameList[i+1].Name)
		end
		GUIAction_ToggleMenu("MainMenuWindow", 0)
	end
	
	function MainWindow_SaveGame_DoSaveGame(i)
		i = MainWindow_SaveGame_SaveListOffset + i
		local slot
		if MainWindow_SaveGame_NameList[i+1] ~= nil then
			slot = "save_" .. MainWindow_SaveGame_NameList[i+1].Index
		else
			slot = "save_" .. ( i + 1 )
		end
		MainWindow_SaveGame_SaveGameName = nil
		MainWindow_SaveGame_SaveGameDescOld = nil
		MainWindow_SaveGame_SaveGameDescNew = nil
		local desc = MainWindow_SaveGame_CreateSaveGameDescription()
		if MainWindow_SaveGame_NameList[i+1] ~= nil then
			MainWindow_SaveGame_SaveGameName = slot
			MainWindow_SaveGame_SaveGameDescOld = MainWindow_SaveGame_NameList[i+1].Desc
			MainWindow_SaveGame_SaveGameDescNew = desc
			GUIAction_ToggleMenu( "MainMenuBoxOverwriteWindow", 1 )
			return
		end
		FrameworkWrapper.Savegame.DoSaveInternal(slot, desc)
		GUIAction_ToggleMenu("MainMenuWindow" ,0)
	end
	
	function MainWindow_SaveGame_DoOverwriteSaveGame()
		if MainWindow_SaveGame_SaveGameName ~= nil then
			FrameworkWrapper.Savegame.DoSaveInternal(MainWindow_SaveGame_SaveGameName, MainWindow_SaveGame_SaveGameDescNew)
			GUIAction_ToggleMenu("MainMenuWindow" ,0)
			MainWindow_SaveGame_SaveGameName = nil
			MainWindow_SaveGame_SaveGameDescOld = nil
			MainWindow_SaveGame_SaveGameDescNew = nil
		end
	end
	
	function GUIAction_RestartMap()
		FrameworkWrapper.Mapfile.DoLeaveMapCallback("restartMap")
		Trigger.DisableTriggerSystem(1)
		Framework.RestartMap()
	end
	function QuitGame()
		FrameworkWrapper.Mapfile.DoLeaveMapCallback("quitMap")
		if XNetwork ~= nil and XNetwork.Manager_IsGameRunning() == 1 then
			if XNetwork.GameSystem_IsHanging() == 1 then
				Framework.GameResult_Update()
				if XNetwork ~= nil and XNetwork.Manager_DoesExist() == 1 then
					XNetwork.Broadcast_Stop()
					XNetwork.Manager_Stop()
					XNetwork.Manager_Destroy()
				end
				Framework.CloseGame()
			else
				XNetwork.Manager_LocalPlayerWantsToLeaveGame()
			end
		else
			Framework.GameResult_Update()
			Trigger.DisableTriggerSystem(1)
			Framework.CloseGame()
		end
	end
	function QuitApplication()
		if Framework.CheckIDV() then
			QuitGame()
		else
			FrameworkWrapper.Mapfile.DoLeaveMapCallback("quitGame")
			Trigger.DisableTriggerSystem(1)
			Framework.ExitGame()	
		end
	end

    function QuickLoad()
        if Logic.PlayerGetGameState(GUI.GetPlayerID())  ~= 1 then
            return
        end
        if Framework.GetCurrentMapName() == "00_Tutorial1" then
            return
        end 
        if XNetwork == nil or XNetwork.Manager_DoesExist() == 0 then
            FrameworkWrapper.Savegame.LoadSave("quicksave")
            GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/GUI_GameLoaded"))
        end
    end
    function QuickSave()
        if Logic.PlayerGetGameState(GUI.GetPlayerID())  ~= 1 then
            return
        end
        if Framework.GetCurrentMapName() == "00_Tutorial1"  then
            return
        end
        if XNetwork == nil or XNetwork.Manager_DoesExist() == 0 then
            local desc = "(*) - " .. MainWindow_SaveGame_CreateSaveGameDescription()
            if FrameworkWrapper.Savegame.DoSaveInternal("quicksave", desc)== false then
                Message(str.FrameworkWrapper_noSave)
            end
        end
    end
end)
