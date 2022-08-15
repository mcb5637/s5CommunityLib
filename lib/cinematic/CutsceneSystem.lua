---
--- This module allows to use cutscenes as cinematic events.
---
--- <b>FIXME:</b> This has not beed tested!
-- 
--- @sort=true
---

if mcbPacker then --mcbPacker.ignore
    mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
    mcbPacker.require("s5CommunityLib/comfort/other/SimpleSynchronizer")
    mcbPacker.require("s5CommunityLib/comfort/table/GetLanguage")
    mcbPacker.require("s5CommunityLib/comfort/table/GetLocalizedTextInTable")
    mcbPacker.require("s5CommunityLib/lib/placeholder/ReplacePlaceholders")
    mcbPacker.require("s5CommunityLib/lib/cinematic/CinematicEvent")
end --mcbPacker.ignore

CutsceneSystem = {
    SyncEvents = {},

    m_Book = {},
    m_Queue = {},
}

---
-- Starts the passed cutscene As cinematic event.
--
-- @param[type=number] _PlayerID ID of Player
-- @param[type=number] _Name     Name of cutscene
-- @param[type=table]  _Cutscene Cutscene description
-- @within Methods
--
function StartCutscene(_PlayerID, _Name, _Cutscene)
    CutsceneSystem:StartCutscene(_PlayerID, _Name, _Cutscene);
end

---
-- Returns true if a cutscene is active for the player. If no player was
-- passed, the local player is checked.
--
-- @param[type=number] _PlayerID (Optional) ID of player
-- @return[type=boolean] Cutscene is active
-- @within Methods
--
function IsCutsceneActive(_PlayerID)
    local PlayerID = _PlayerID or GUI.GetPlayerID();
    return CutsceneSystem.m_Book[PlayerID] ~= nil;
end

-- -------------------------------------------------------------------------- --

GameCallback_OnGameStart_Orig_CutsceneSystem = GameCallback_OnGameStart;
GameCallback_OnGameStart = function()
    GameCallback_OnGameStart_Orig_CutsceneSystem();
    CutsceneSystem:Install();
end

function CutsceneSystem:Install()
    if not self.m_Installed then
        self.m_Installed = true;
        CinematicEvent:Install();
        for k, v in pairs(GetActivePlayers()) do
            self.m_Book[k] = nil;
            self.m_Queue[k] = {};
        end

        self.SyncEvents.CutsceneStarted = CreateSyncEvent(function(_PlayerID)
            CutsceneSystem:CutsceneStarted(_PlayerID);
        end);
        self.SyncEvents.CutsceneFinished = CreateSyncEvent(function(_PlayerID)
            CutsceneSystem:CutsceneFinished(_PlayerID);
        end);
        self.SyncEvents.PageDisplayed = CreateSyncEvent(function(_PlayerID)
            CutsceneSystem:NextPage(_PlayerID);
        end);
    end
end

function CutsceneSystem:StartCutscene(_PlayerID, _CutsceneName, _Data)
    -- Abort if event can not be created
    if not CinematicEvent:CreateCinematicEvent(_PlayerID, _CutsceneName) then
        return;
    end
    -- Insert in m_Queue
    table.insert(self.m_Queue[_PlayerID], {_CutsceneName, _Data});
    -- Start cutscene if possible
    if CinematicEvent:IsAnyCinematicEventActive(_PlayerID) then
        return;
    end
    self:NextCutscene(_PlayerID);
end

function CutsceneSystem:NextCutscene(_PlayerID)
    if not self.m_Queue[_PlayerID] then
        return;
    end
    local Cutscene = table.remove(self.m_Queue[_PlayerID], 1);
    Cutscene.CurrentPage = 0;

    _G["Cutscene_" ..Cutscene[1].. "_Start"] = _G["Cutscene_" ..Cutscene[1].. "_Start"] or function()
        SynchronizedCall(CutsceneSystem.SyncEvents.CutsceneStarted, GUI.GetPlayerID());
    end
    _G["Cutscene_" ..Cutscene[1].. "_Finished"] = _G["Cutscene_" ..Cutscene[1].. "_Finished"] or function()
        SynchronizedCall(CutsceneSystem.SyncEvents.CutsceneFinished, GUI.GetPlayerID());
    end
    _G["Cutscene_" ..Cutscene[1].. "_Cancel"] = _G["Cutscene_" ..Cutscene[1].. "_Cancel"] or function()
        _G["Cutscene_" ..Cutscene[1].. "_Finished"]();
    end
    for i= 1, table.getn(Cutscene[2]) do
        _G["Cutscene_" ..Cutscene[1].. "_" ..Cutscene[2][i].Flight] = _G["Cutscene_" ..Cutscene[1].. "_" ..Cutscene[2][i].Flight] or function()
            SynchronizedCall(CutsceneSystem.SyncEvents.PageDisplayed, GUI.GetPlayerID());
        end
    end

    self.m_Book[_PlayerID] = CopyTable(Cutscene);
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    StartCutscene(Cutscene[1]);
end

function CutsceneSystem:CutsceneStarted(_PlayerID)
    CinematicEvent:SetCinematicEventState(_PlayerID, self.m_Book[_PlayerID][1], CinematicEventStatus.Active);
    if self.m_Book[_PlayerID][2].Starting then
        self.m_Book[_PlayerID][2]:Starting();
    end
    self:EnableCinematicMode(_PlayerID);
end

function CutsceneSystem:CutsceneFinished(_PlayerID)
    CinematicEvent:SetCinematicEventState(_PlayerID, self.m_Book[_PlayerID][1], CinematicEventStatus.Over);
    if self.m_Book[_PlayerID][2].Finished then
        self.m_Book[_PlayerID][2]:Finished();
    end
    self:DisableCinematicMode(_PlayerID);
end

function CutsceneSystem:NextPage(_PlayerID)
    self.m_Book[_PlayerID][2].CurrentPage = self.m_Book[_PlayerID][2].CurrentPage +1;

    local PageID = self.m_Book[_PlayerID][2].CurrentPage;
    if self.m_Book[_PlayerID][2][PageID].Action then
        self.m_Book[_PlayerID][2][PageID]:Action();
    end

    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    local Title = self.m_Book[_PlayerID][2][PageID].Title;
    PrintBriefingHeadline(Title);
    local Text  = self.m_Book[_PlayerID][2][PageID].Text;
    PrintBriefingHeadline(Text);

    -- Fader?
end

function CutsceneSystem:EnableCinematicMode(_PlayerID)
    -- Only for receiving player
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    self:SetPageApperance(false);

    -- Backup camera
    if self.m_Book[_PlayerID][2].RestoreCamera then
        local x, y = Camera.ScrollGetLookAt();
        self.Local.RestorePosition = {X= x, Y= y};
    end
    -- Backup selection
    local SelectedEntities = {GUI.GetSelectedEntities()};
    self.Local.SelectedEntities = SelectedEntities;

    GUI.ClearSelection();
    GUIAction_GoBackFromHawkViewInNormalView();
    Interface_SetCinematicMode(1);
    Camera.StopCameraFlight();
    Camera.ScrollUpdateZMode(0);
    Camera.RotSetAngle(-45);
    Display.SetRenderFogOfWar(0);
    GUI.MiniMap_SetRenderFogOfWar(1);
    Display.SetRenderSky(1);
    GUI.EnableBattleSignals(false);
    Sound.PlayFeedbackSound(0,0);
    Input.CutsceneMode();
    GUI.SetFeedbackSoundOutputState(0);
    Logic.SetGlobalInvulnerability(1);
    LocalMusic.SongLength = 0;

    XGUIEng.ShowWidget("Cinematic",1);
    XGUIEng.ShowWidget("Cinematic_Text", 1);
    XGUIEng.ShowWidget("Cinematic_Headline", 1);
    XGUIEng.ShowWidget("CinematicMC_Container", 0);
    XGUIEng.ShowWidget("CinematicMC_Text", 0);
    XGUIEng.ShowWidget("CinematicMC_Headline", 0);
    XGUIEng.ShowWidget("CinematicMiniMapContainer", 0);

    XGUIEng.ShowWidget("Normal",1);
    XGUIEng.ShowAllSubWidgets("Windows",0);
    XGUIEng.ShowWidget("Top",0);
    XGUIEng.ShowWidget("MiniMapOverlay",0);
    XGUIEng.ShowWidget("ResourceView",0);
    XGUIEng.ShowWidget("SelectionView",0);
    XGUIEng.ShowWidget("TooltipBottom",0);
    XGUIEng.ShowWidget("ShortMessagesListWindow",0);
    XGUIEng.ShowWidget("ShortMessagesOutputWindow",0);
    XGUIEng.ShowWidget("BackGround_Top",0);
    XGUIEng.ShowWidget("MapProgressStuff",0);
    XGUIEng.ShowWidget("VCMP_Window",0);
    XGUIEng.ShowWidget("MultiSelectionContainer",0);
    XGUIEng.ShowWidget("MinimapButtons",0);
    XGUIEng.ShowWidget("BackGroundBottomContainer",0);
    XGUIEng.ShowWidget("TutorialMessageBG",0);
    XGUIEng.ShowWidget("MiniMap",0);
    XGUIEng.ShowWidget("VideoPreview",0);
    XGUIEng.ShowWidget("Movie",0);

    GUIAction_ToggleMenu("NetworkWindow", 0);
end

function CutsceneSystem:DisableCinematicMode(_PlayerID)
    -- Only for receiving player
    if GUI.GetPlayerID() ~= _PlayerID then
        return;
    end
    -- Restore camera
    if self.Local.RestorePosition then
        Camera.ScrollSetLookAt(self.Local.RestorePosition.X, self.Local.RestorePosition.Y);
        self.Local.RestorePosition = nil;
    end
    -- Restore selection
    if self.Local.SelectedEntities then
        for i= 1, table.getn(self.Local.SelectedEntities), 1 do
            GUI.SelectEntity(self.Local.SelectedEntities[i]);
        end
        self.Local.SelectedEntities = nil;
    end

    Interface_SetCinematicMode(0);
    Display.SetRenderFogOfWar(1);
    Display.SetRenderSky(0);
    Camera.FollowEntity(0);
    Logic.SetGlobalInvulnerability(0);
    GUI.EnableBattleSignals(true);
    GUI.ActivateSelectionState();
    Input.GameMode();
    GUI.SetFeedbackSoundOutputState(1);
    Stream.Stop();
    LocalMusic.SongLength = 0;

    XGUIEng.ShowWidget("Normal",1);
    XGUIEng.ShowWidget("3dOnScreenDisplay",1);
    XGUIEng.ShowWidget("Cinematic",0);
    XGUIEng.ShowWidget("CinematicMiniMapContainer",0);

    XGUIEng.ShowWidget("Windows",1);
    XGUIEng.ShowWidget("Top",1);
    XGUIEng.ShowWidget("MiniMapOverlay",1);
    XGUIEng.ShowWidget("ResourceView",1);
    XGUIEng.ShowWidget("SelectionView",1);
    XGUIEng.ShowWidget("ShortMessagesListWindow",1);
    XGUIEng.ShowWidget("BackGround_Top",1);
    XGUIEng.ShowWidget("MapProgressStuff",1);
    XGUIEng.ShowWidget("VCMP_Window",1);
    XGUIEng.ShowWidget("MinimapButtons",1);
    XGUIEng.ShowWidget("BackGroundBottomContainer",1);
    XGUIEng.ShowWidget("MiniMap",1);

    GUIAction_ToggleMenu("NetworkWindow", 0);
end

function CutsceneSystem:SetPageApperance(_DisableMap)
    local size = {GUI.GetScreenSize()};
    local titlePosY = 45;
    local textPosY = ((size[2]*(768/size[2])))-100;
    local titleSize = (size[1]-200);

    -- Set widget apperance
    XGUIEng.SetWidgetPositionAndSize("Cinematic_Text",(200),textPosY,(680),100);
    XGUIEng.SetWidgetPositionAndSize("Cinematic_Headline",100,titlePosY,titleSize,15);
    XGUIEng.SetWidgetPositionAndSize("CinematicBar01",0,size[2],size[1],180);
    XGUIEng.SetWidgetPositionAndSize("CinematicBar00",0,0,size[1],size[2]);
    XGUIEng.SetMaterialTexture("CinematicBar02", 0, "data/graphics/textures/gui/cutscene_top.dds");
    XGUIEng.SetMaterialColor("CinematicBar02", 0, 255, 255, 255, 255);
    XGUIEng.SetWidgetPositionAndSize("CinematicBar02", 0, 0, size[1], 180);
    -- Set widget visability
    XGUIEng.ShowWidget("Cinematic_Text", 1);
    XGUIEng.ShowWidget("Cinematic_Headline", 1);
    XGUIEng.ShowWidget("CinematicMiniMapOverlay", (_DisableMap and 0) or 1);
    XGUIEng.ShowWidget("CinematicMiniMap", (_DisableMap and 0) or 1);
    XGUIEng.ShowWidget("CinematicFrameBG", (_DisableMap and 0) or 1);
    XGUIEng.ShowWidget("CinematicFrame", (_DisableMap and 0) or 1);
    XGUIEng.ShowWidget("CinematicBar02", 1);
    XGUIEng.ShowWidget("CinematicBar01", 1);
    XGUIEng.ShowWidget("CinematicBar00", 1);
end

