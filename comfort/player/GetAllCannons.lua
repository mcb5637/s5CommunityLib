---
--- Returns a list of all cannons of the player.
--- @param _PlayerID number ID of player
--- @return table Cannons List of cannons
--- @author ???
function GetAllCannons(_PlayerID)
    local CannonList = {};
    for i= 1, 4, 1 do
        local n, FirstID = Logic.GetPlayerEntities(_PlayerID, Entities["PV_Cannon" ..i], 1);
        if n > 0 then
            local PrevID = FirstID;
            table.insert(CannonList, FirstID);
            while true do
                local NextID = Logic.GetNextEntityOfPlayerOfType(PrevID);
                if NextID == FirstID then
                    break;
                end
                table.insert(CannonList, NextID);
                PrevID = NextID;
            end
        end
    end
    return CannonList;
end