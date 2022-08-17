gvWaypointData = {};

---
--- Moves an entity over the passed waypoints. The entity can be replaced with
--- an script entity once it reaches the final destination.
---
--- Waypoints are passed as table. They can contain the following fields:
--- <table border="1">
--- <tr>
--- <td><b>Field</b></td>
--- <td><b>Description</b></td>
--- </tr>
--- <tr>
--- <td>Target</td>
--- <td>Script name of the waypoint</td>
--- </tr>
--- <tr>
--- <td>Distance</td>
--- <td>(Optional) Radius the entity must be in around the target.</td>
--- </tr>
--- <tr>
--- <td>IgnoreBlocking</td>
--- <td>(Optional) Entity is using the direct way and ignores evenry blocking. (This can
--- be used to move them in and out of buildings)</td>
--- </tr>
--- <tr>
--- <td>Waittime</td>
--- <td>(Optional) Time in seconds the entity waits until moving to the next waypoint.</td>
--- </tr>
--- <tr>
--- <td>Callback</td>
--- <td>(Optional) Function called when entity passes waypoint. (If a waittime is
--- set the function is called after waittime is over)</td>
--- </tr>
--- </table>
---
--- @param _Entity number  Entity to move
--- @param _Vanish boolean Delete on last waypoint
--- @param ...     table   List of waypoints
--- @return number  ID ID of moving job
--- @author totalwarANGEL
function MoveOnWaypoints(_Entity, _Vanish, ...)
    if not IsExisting(_Entity) then
        return 0;
    end
    local ID = GetID(_Entity);
    gvWaypointData[ID] = {
        Vanish = _Vanish == true,
        Current = 1,
    };
    for i= 1, table.getn(arg), 1 do
        table.insert(
            gvWaypointData[ID],
            ---@diagnostic disable-next-line: undefined-field
            {arg[i].Target,
            ---@diagnostic disable-next-line: undefined-field
             arg[i].Distance or 50,
            ---@diagnostic disable-next-line: undefined-field
             arg[i].IgnoreBlocking == true,
            ---@diagnostic disable-next-line: undefined-field
             (arg[i].Waittime or 0) * 10,
            ---@diagnostic disable-next-line: undefined-field
             arg[i].Callback}
        );
    end
    ---@diagnostic disable-next-line: return-type-mismatch
    return Trigger.RequestTrigger(
        Events.LOGIC_EVENT_EVERY_SECOND,
        "",
        "Internal_MoveOnWaypointsController",
        1,
        {},
        {GetID(_Entity)}
    );
end

function Internal_MoveOnWaypointsController(_ID)
    if not IsExisting(_ID) or not gvWaypointData[_ID] then
        return true;
    end
    local Index = gvWaypointData[_ID].Current;
    local Data  = gvWaypointData[_ID][Index];

    local Task = Logic.GetCurrentTaskList(_ID);
    if not string.find(Task or "", "WALK") then
        local x, y, z = Logic.EntityGetPos(GetID(Data[1]));
        if Data[3] then
            Logic.SetTaskList(_ID, TaskLists.TL_NPC_WALK);
            Logic.MoveEntity(_ID, x, y);
        else
            Logic.MoveSettler(_ID, x, y);
        end
    end

    if IsNear(_ID, Data[1], Data[2]) then
        if gvWaypointData[_ID][Index][4] > 0 then
            gvWaypointData[_ID][Index][4] = Data[4] -1;
            if string.find(Task or "", "WALK") then
                Logic.SetTaskList(_ID, TaskLists.TL_NPC_IDLE);
            end
        else
            gvWaypointData[_ID].Current = Index +1;
            if Data[5] then
                Data[5](Data);
            end
        end
        if Index == table.getn(gvWaypointData[_ID]) then
            if gvWaypointData[_ID].Vanish then
                local PlayerID = Logic.EntityGetPlayer(_ID);
                local Orientation = Logic.GetEntityOrientation(_ID);
                local ScriptName = Logic.GetEntityName(_ID);
                local x, y, z = Logic.EntityGetPos(_ID);
                DestroyEntity(_ID);
                local NewID = Logic.CreateEntity(Entities.XD_ScriptEntity, x, y, Orientation, PlayerID);
                Logic.SetEntityName(NewID, ScriptName);
            end
            gvWaypointData[_ID] = nil;
            return true;
        end
    end
end