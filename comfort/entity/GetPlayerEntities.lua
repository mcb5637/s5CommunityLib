---
--- Finds all entities of the player that have the type.
--- @param _PlayerID   number ID of player
--- @param _EntityType number Type to search
--- @return table List of entities
--- @author totalwarANGEL
function GetPlayerEntities(_PlayerID, _EntityType)
    local PlayerEntities = {}
    if _EntityType ~= 0 then
        local n,eID = Logic.GetPlayerEntities(_PlayerID, _EntityType, 1);
        if (n > 0) then
            local firstEntity = eID;
            repeat
                table.insert(PlayerEntities,eID)
                eID = Logic.GetNextEntityOfPlayerOfType(eID);
            until (firstEntity == eID);
        end
    elseif _EntityType == 0 then
        for k,v in pairs(Entities) do
            if string.find(k, "PU_")
            or string.find(k, "PB_")
            or string.find(k, "CU_")
            or string.find(k, "CB_")
            or string.find(k, "XD_DarkWall")
            or string.find(k, "XD_Wall")
            or string.find(k, "PV_") then
                local n,eID = Logic.GetPlayerEntities(_PlayerID, v, 1);
                if (n > 0) then
                local firstEntity = eID;
                repeat
                    table.insert(PlayerEntities,eID)
                    eID = Logic.GetNextEntityOfPlayerOfType(eID);
                until (firstEntity == eID);
                end
            end
        end
    end
    return PlayerEntities;
end