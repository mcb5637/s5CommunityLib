---
-- This module provides a simple SimpleSynchronizer for multiplayer maps.
--
-- Synchronizing is done by creating an event that houses a function and
-- optional parameters. These Events can be fired to synchronize code called
-- from the GUI by only one player.
--
-- @set sort=true
--

if mcbPacker then --mcbPacker.ignore
    mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
end --mcbPacker.ignore

SimpleSynchronizer = {
    SimpleSynchronizerEvent = {},
    Transactions = {},
    TransactionParameter = {},
    UniqueActionCounter = 1,
    UniqueTributeCounter = 9999,
};

-- -------------------------------------------------------------------------- --

---
-- Creates an script event and returns the event ID. Use the ID to call the
-- created event.
-- @param[type=function] _Function Function to call
-- @within Methods
--
function CreateSyncEvent(_Function)
    return SimpleSynchronizer:CreateSyncEvent(_Function);
end

---
-- Removes an script event.
-- @param[type=number] _ID ID of event
-- @within Methods
--
function DeleteSyncEvent(_ID)
    return SimpleSynchronizer:DeleteSyncEvent(_ID);
end

---
-- Calls the script event synchronous for all players.
-- @param[type=number] _ID ID of script event
-- @param              ... List of Parameters (String or Number)
-- @within Methods
--
function SynchronizedCall(_ID, ...)
    return SimpleSynchronizer:SynchronizedCall(_ID, unpack(arg));
end

---
-- Checks if the current mission is running as a Multiplayer game.
-- @return[type=boolean] Mission runs in multiplayer
-- @within Methods
--
function IsMultiplayerGame()
    return SimpleSynchronizer:IsMultiplayerGame();
end

---
-- Returns true, if the copy of the game is the History Edition.
-- @return[type=boolean] Game is History Edition
-- @within Methods
--
function IsHistoryEdition()
    return SimpleSynchronizer:IsHistoryEdition();
end

---
-- Returns true, if the copy of the game is the Community Edition.
-- (e.g. Kimichuras Community Server)
-- @return[type=boolean] Game is Community Edition
-- @within Methods
--
function IsCNetwork()
    return SimpleSynchronizer:IsCNetwork();
end

---
-- Returns true, if the copy of the game is the original version.
-- @return[type=boolean] Game is Original Edition
-- @within Methods
--
function IsOriginal()
    return SimpleSynchronizer:IsOriginal();
end

---
-- Returns true, if the game is properly patched to version 1.06.0217. If the
-- copy of the game is not the original than it is assumed that the game has
-- been patched.
-- @return[type=boolean] Game has latest patch
-- @within Methods
--
function IsPatched()
    return SimpleSynchronizer:IsPatched();
end

---
-- Returns true, if the player on this ID is active.
-- @param[type=number] _PlayerID ID of player
-- @return[type=boolean] Player is active
-- @within Methods
--
function IsPlayerActive(_PlayerID)
    return SimpleSynchronizer:IsPlayerActive(_PlayerID);
end

---
-- Returns the player ID of the host.
-- @return[type=number] ID of Player
-- @within Methods
--
function GetHostPlayerID()
    return SimpleSynchronizer:GetHostPlayerID();
end

---
-- Returns true, if the player is the host.
-- @param[type=number] _PlayerID ID of player
-- @return[type=boolean] Player is host
-- @within Methods
--
function IsPlayerHost(_PlayerID)
    return SimpleSynchronizer:IsPlayerHost(_PlayerID);
end

---
-- Returns the number of human players. In Singleplayer this will always be 1.
-- @return[type=number] Amount of humans
-- @within Methods
--
function GetActivePlayers()
    return SimpleSynchronizer:GetActivePlayers();
end

---
-- Returns all active teams.
-- @return[type=number] List of teams
-- @within Methods
--
function GetActiveTeams()
    return SimpleSynchronizer:GetActiveTeams();
end

---
-- Returns the team the player is in.
-- @param[type=number] _PlayerID ID of player
-- @return[type=number] Team of player
-- @within Methods
--
function GetTeamOfPlayer(_PlayerID)
    return SimpleSynchronizer:GetTeamOfPlayer(_PlayerID);
end

-- -------------------------------------------------------------------------- --

function SimpleSynchronizer:Install()
    if not self.m_Installed then
        self.m_Installed = true;
        for k, v in pairs(Score.Player) do
            self.SimpleSynchronizerEvent[k] = {};
        end

        self:OverrideMessageReceived();
        self:ActivateTributePaidTrigger();
    end
end

function SimpleSynchronizer:CreateSyncEvent(_Function)
    self.UniqueActionCounter = self.UniqueActionCounter +1;
    local ActionIndex = self.UniqueActionCounter;

    self.SimpleSynchronizerEvent[ActionIndex] = {
        Function = _Function,
        CNetwork = "SimpleSynchronizer_CNetworkHandler_" .. self.UniqueActionCounter;
    };
    if CNetwork then
        CNetwork.SetNetworkHandler(
            self.SimpleSynchronizerEvent[ActionIndex].CNetwork,
            function(_Name, _PlayerID, _ID, ...)
                if SimpleSynchronizer.SimpleSynchronizerEvent[_ID] then
                    if CNetwork.IsAllowedToManipulatePlayer(_Name, _PlayerID) then
                        SimpleSynchronizer.SimpleSynchronizerEvent[_ID].Function(_Name, _PlayerID, unpack(arg));
                    end
                end
            end
        );
    end
    return self.UniqueActionCounter;
end

function SimpleSynchronizer:DeleteSyncEvent(_ID)
    if _ID and self.SimpleSynchronizerEvent[_ID] then
        self.SimpleSynchronizerEvent[_ID] = nil;
    end
end

function SimpleSynchronizer:SynchronizedCall(_ID, ...)
    arg = arg or {};
    local Msg = "";
    if table.getn(arg) > 0 then
        for i= 1, table.getn(arg), 1 do
            Msg = Msg .. tostring(arg[i]) .. ":::";
        end
    end
    if CNetwork then
        local Name = self.SimpleSynchronizerEvent[_ID].CNetwork;
        CNetwork.SendCommand(Name, GUI.GetPlayerID(), _ID, unpack(arg));
    else
        local PlayerID = GUI.GetPlayerID();
        local Time = Logic.GetTimeMs();
        self:TransactionSend(_ID, PlayerID, Time, Msg, arg);
    end
end

function SimpleSynchronizer:TransactionSend(_ID, _PlayerID, _Time, _Msg, _Parameter)
    -- Create message
    _Msg = _Msg or "";
    local PreHashedMsg = "".._ID..":::" .._PlayerID..":::" .._Time.. ":::" .._Msg;
    local Hash = _ID.. "_" .._PlayerID.. "_" .._Time;
    local TransMsg = "___MPTransact:::"..Hash..":::" ..PreHashedMsg;
    self.Transactions[Hash] = {};
    -- Send message
    if self:IsMultiplayerGame() then
        XNetwork.Chat_SendMessageToAll(TransMsg);
    else
        MPGame_ApplicationCallback_ReceivedChatMessage(TransMsg, 0, _PlayerID);
    end
    -- Wait for ack
    StartSimpleHiResJob(function(_PlayerID, _Hash, _Time, ...)
        if _Time +2 < Logic.GetTime() then
            -- Message("DEBUG: Timeout for " .._Hash);
            return true;
        end
        local ActivePlayers = SimpleSynchronizer:GetActivePlayers();
        local AllAcksReceived = true;
        for i= 1, table.getn(ActivePlayers), 1 do
            if _PlayerID ~= ActivePlayers[i] and not SimpleSynchronizer.Transactions[Hash][ActivePlayers[i]] then
                AllAcksReceived = false;
            end
        end
        if AllAcksReceived == true then
            table.insert(_Parameter, 1, -1);
            local ID = SimpleSynchronizer:CreateTribute(_PlayerID, _ID, unpack(_Parameter));
            SimpleSynchronizer:PayTribute(_PlayerID, ID);
            return true;
        end
    end, _PlayerID, Hash, Logic.GetTime(), unpack(_Parameter));
end

function SimpleSynchronizer:TransactionAcknowledge(_Hash, _Time)
    -- Create message
    local PlayerID = GUI.GetPlayerID();
    local TransMsg = "___MPAcknowledge:::" .._Hash.. ":::" ..PlayerID.. ":::" .._Time.. ":::";
    -- Send message
    if self:IsMultiplayerGame() then
        XNetwork.Chat_SendMessageToAll(TransMsg);
    else
        MPGame_ApplicationCallback_ReceivedChatMessage(TransMsg, 0, PlayerID);
    end
end

function SimpleSynchronizer:TransactionManage(_Type, _Msg)
    -- Handle received request
    if _Type == 1 then
        local Parameters      = self:TransactionSplitMessage(_Msg);
        local Hash            = table.remove(Parameters, 1);
        local Action          = table.remove(Parameters, 1);
        local SendingPlayerID = table.remove(Parameters, 1);
        local Timestamp       = table.remove(Parameters, 1);
        if SendingPlayerID ~= GUI.GetPlayerID() then
            self:TransactionAcknowledge(Hash, Timestamp);
            SimpleSynchronizer:CreateTribute(SendingPlayerID, Action, unpack(Parameters));
        end
    -- Handle received client ack
    elseif _Type == 2 then
        local Parameters = self:TransactionSplitMessage(_Msg);
        local Hash       = table.remove(Parameters, 1);
        local PlayerID   = table.remove(Parameters, 1);
        local Timestamp  = table.remove(Parameters, 1);
        self.Transactions[Hash] = self.Transactions[Hash] or {};
        self.Transactions[Hash][PlayerID] = true;
    end
end

function SimpleSynchronizer:TransactionSplitMessage(_Msg)
    local MsgParts = {};
    local Msg = _Msg;
    repeat
        local s, e = string.find(Msg, ":::");
        local PartString = string.sub(Msg, 1, s-1);
        local PartNumber = tonumber(PartString);
        local Part = (PartNumber ~= nil and PartNumber) or PartString;
        table.insert(MsgParts, Part);
        Msg = string.sub(Msg, e+1);
    until Msg == "";
    return MsgParts;
end

function SimpleSynchronizer:CreateTribute(_PlayerID, _ID, ...)
    self.UniqueTributeCounter = self.UniqueTributeCounter +1;
    Logic.AddTribute(_PlayerID, self.UniqueTributeCounter, 0, 0, "", {[ResourceType.Gold] = 0});
    self.TransactionParameter[self.UniqueTributeCounter] = {
        Action    = _ID,
        Parameter = CopyTable(arg),
    };
    return self.UniqueTributeCounter;
end

function SimpleSynchronizer:PayTribute(_PlayerID, _TributeID)
    GUI.PayTribute(_PlayerID, _TributeID);
end

function SimpleSynchronizer:ActivateTributePaidTrigger()
    Trigger.RequestTrigger(
        Events.LOGIC_EVENT_TRIBUTE_PAID,
        "",
        "Internal_SimpleSynchronizer_TributePayedTrigger",
        1
    );
end

function Internal_SimpleSynchronizer_TributePayedTrigger()
    SimpleSynchronizer:OnTributePaidTrigger(Event.GetTributeUniqueID());
end

function SimpleSynchronizer:OnTributePaidTrigger(_ID)
    if self.TransactionParameter[_ID] then
        local ActionID  = self.TransactionParameter[_ID].Action;
        local Parameter = self.TransactionParameter[_ID].Parameter;
        if self.SimpleSynchronizerEvent[ActionID] then
            self.SimpleSynchronizerEvent[ActionID].Function(unpack(Parameter));
        end
    end
end

function SimpleSynchronizer:OverrideMessageReceived()
    if self.IsActive then
        return true;
    end
    self.IsActive = true;

    MPGame_ApplicationCallback_ReceivedChatMessage_Orig_SimpleSynchronizer = MPGame_ApplicationCallback_ReceivedChatMessage
    MPGame_ApplicationCallback_ReceivedChatMessage = function(_Message, _AlliedOnly, _SenderPlayerID)
        -- Receive transaction
        local s, e = string.find(_Message, "___MPTransact:::");
        if e then
            SimpleSynchronizer:TransactionManage(1, string.sub(_Message, e+1));
            return;
        end
        -- Receive ack
        local s, e = string.find(_Message, "___MPAcknowledge:::");
        if e then
            SimpleSynchronizer:TransactionManage(2, string.sub(_Message, e+1));
            return;
        end
        -- Execute callback
        MPGame_ApplicationCallback_ReceivedChatMessage_Orig_SimpleSynchronizer(_Message, _AlliedOnly, _SenderPlayerID);
    end
end

function SimpleSynchronizer:IsMultiplayerGame()
    return XNetwork.Manager_DoesExist() == 1;
end

function SimpleSynchronizer:IsHistoryEdition()
    return XNetwork.Manager_IsNATReady ~= nil;
end

function SimpleSynchronizer:IsCNetwork()
    return CNetwork ~= nil;
end

function SimpleSynchronizer:IsOriginal()
    return not self:IsHistoryEdition() and not self:IsCNetwork();
end

function SimpleSynchronizer:IsPatched()
    if not self:IsOriginal() then
        return true;
    end
    return string.find(Framework.GetProgramVersion(), "1.06.0217") ~= nil;
end

function SimpleSynchronizer:IsPlayerActive(_PlayerID)
    local Players = {};
    if self:IsMultiplayerGame() then
        return Logic.PlayerGetGameState(_PlayerID) == 1;
    end
    return _PlayerID == GUI.GetPlayerID();
end

function SimpleSynchronizer:GetHostPlayerID()
    if self:IsMultiplayerGame() then
        for k, v in pairs(self:GetActivePlayers()) do
            local HostNetworkAddress   = XNetwork.Host_UserInSession_GetHostNetworkAddress();
            local PlayerNetworkAddress = XNetwork.GameInformation_GetNetworkAddressByPlayerID(v);
            if HostNetworkAddress == PlayerNetworkAddress then
                return v;
            end
        end
    end
    return GUI.GetPlayerID();
end

function SimpleSynchronizer:IsPlayerHost(_PlayerID)
    if self:IsMultiplayerGame() then
        local HostNetworkAddress   = XNetwork.Host_UserInSession_GetHostNetworkAddress();
        local PlayerNetworkAddress = XNetwork.GameInformation_GetNetworkAddressByPlayerID(_PlayerID);
        return HostNetworkAddress == PlayerNetworkAddress;
    end
    return true;
end

function SimpleSynchronizer:GetActivePlayers()
    local Players = {};
    if self:IsMultiplayerGame() then
        -- TODO: Does that fix everything for Community Server?
        for i= 1, table.getn(Score.Player), 1 do
            if Logic.PlayerGetGameState(i) == 1 then
                table.insert(Players, i);
            end
        end
    else
        table.insert(Players, GUI.GetPlayerID());
    end
    return Players;
end

function SimpleSynchronizer:GetActiveTeams()
    if self:IsMultiplayerGame() then
        local Teams = {};
        for k, v in pairs(self:GetActivePlayers()) do
            local Team = self:GetTeamOfPlayer(v);
            if KeyOf(Team, Teams) == nil then
                table.insert(Teams, Team);
            end
        end
        return Teams;
    else
        return {1};
    end
end

function SimpleSynchronizer:GetTeamOfPlayer(_PlayerID)
    if self:IsMultiplayerGame() then
        return XNetwork.GameInformation_GetPlayerTeam(_PlayerID);
    else
        return _PlayerID;
    end
end