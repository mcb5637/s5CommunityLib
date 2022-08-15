---
--- Thismodule implements the cinematic events.
---
--- A cinematic event is a state in that a camera animation plays. Those events
--- are supposed to block anything else while one of them is running. Briefings
--- and cutscenes are cinematic events.
---
--- If you want to implement something that should not be interfered with by
--- briefings or cutscenes, make it a cinematic event.
---
--- @sort=true
--- @author totalwarANGEL
---

if mcbPacker then --mcbPacker.ignore
    mcbPacker.require("s5CommunityLib/comfort/other/SimpleSynchronizer")
end --mcbPacker.ignore

CinematicEvent = {
    CinematicEventID = 0;
    EventStatus = {},
}

---
--- List of states for cinematic events.
--- @class CinematicEventStatus
--- @field Inactive number Event is not active
--- @field Active   number Event is currently running
--- @field Over     number Event is over
CinematicEventStatus = {
    Inactive = 1,
    Active = 2,
    Over = 3
};

---
--- Checks if any cinematic event is active for the player.
--- @param _PlayerID number ID of player
--- @return boolean Cinematic Cinematic event is active
function IsAnyCinematicActive(_PlayerID)
    return CinematicEvent:IsAnyCinematicEventActive(_PlayerID)
end

---
--- Checks if the cinematic event is active.
---
--- If no event with that name exists, a new one is created.
---
--- @param _PlayerID number ID of player
--- @param _Name     string Name of event
--- @return boolean Cinematic Cinematic event is active
function IsCinematicActive(_PlayerID, _Name)
    return CinematicEvent:GetCinematicEventState(_PlayerID, _Name) == CinematicEventStatus.Active;
end

---
--- Checks if the cinematic event is over.
---
--- If no event with that name exists, a new one is created.
---
--- @param _PlayerID number ID of player
--- @param _Name     string Name of event
--- @return boolean Cinematic Cinematic event is over
function IsCinematicConcluded(_PlayerID, _Name)
    return CinematicEvent:GetCinematicEventState(_PlayerID, _Name) == CinematicEventStatus.Over;
end

---
--- Sets the state of a cinematic event.
---
--- If no event with that name exists, a new one is created.
---
--- @param _PlayerID number ID of player
--- @param _Name     string Name of event
--- @param _State    number State of event
--- @return boolean Cinematic Cinematic event is over
--- @see CinematicEventStatus
function SetCinematicEventState(_PlayerID, _Name, _State)
    return CinematicEvent:SetCinematicEventState(_PlayerID, _Name, _State);
end

-- -------------------------------------------------------------------------- --

function CinematicEvent:Install()
    if not self.m_Installed then
        self.m_Installed = true;
        for k, v in pairs(GetActivePlayers()) do
            self.EventStatus[k] = {};
        end
    end
end

function CinematicEvent:IsAnyCinematicEventActive(_PlayerID)
    if self.EventStatus[_PlayerID] then
        for k,v in pairs(self.EventStatus[_PlayerID]) do
            if v == CinematicEventStatus.Active then
                return true;
            end
        end
    end
    return false;
end

function CinematicEvent:CreateCinematicEvent(_PlayerID, _Name)
    if self.EventStatus[_PlayerID] then
        if not self.EventStatus[_PlayerID][_Name] then
            self.EventStatus[_PlayerID][_Name] = CinematicEventStatus.Inactive;
            return true;
        end
    end
    return false;
end

function CinematicEvent:DeleteCinematicEvent(_PlayerID, _Name)
    self.EventStatus[_PlayerID][_Name] = nil;
end

function CinematicEvent:GetCinematicEventState(_PlayerID, _Name)
    if self.EventStatus[_PlayerID] then
        if not self.EventStatus[_PlayerID][_Name] then
            self:CreateCinematicEvent(_PlayerID, _Name);
        end
        return self.EventStatus[_PlayerID][_Name];
    end
    return 0;
end

function CinematicEvent:SetCinematicEventState(_PlayerID, _Name, _State)
    if self.EventStatus[_PlayerID] then
        if not self.EventStatus[_PlayerID][_Name] then
            self:CreateCinematicEvent(_PlayerID, _Name);
        end
        self.EventStatus[_PlayerID][_Name] = _State;
        return true;
    end
    return false;
end

