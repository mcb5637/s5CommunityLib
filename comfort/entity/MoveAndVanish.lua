---
--- Moves an entity to the destination and replaces it with an script entity.
--- @param _Entity   number Entity to move
--- @param _Target   number Position where to move
--- @return number ID ID of moving job
--- @author totalwarANGEL
function MoveAndVanish(_Entity, _Target)
    ---@diagnostic disable-next-line: return-type-mismatch
    return Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_SECOND,
        "",
        "Internal_MoveAndVanishController",
        1,
        {},
        {GetID(_Entity), _Target}
    );
end

function Internal_MoveAndVanishController(_EntityID, _Target)
    if not IsExisting(_EntityID) then
        return true;
    end
    if not Logic.IsEntityMoving(_EntityID) then
        Move(_EntityID, _Target);
    end
    if IsNear(_EntityID, _Target, 150) then
        -- Entity is not destroyed on arrival!
        local PlayerID = Logic.EntityGetPlayer(_EntityID);
        local Orientation = Logic.GetEntityOrientation(_EntityID);
        local ScriptName = Logic.GetEntityName(_EntityID);
        local x, y, z = Logic.EntityGetPos(_EntityID);
        DestroyEntity(_EntityID);
        local ID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, Orientation, PlayerID);
        Logic.SetEntityName(ID, ScriptName);
        return true;
    end
end