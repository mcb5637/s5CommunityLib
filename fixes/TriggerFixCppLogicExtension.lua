if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("comfort/FrameworkWrapper")
end --mcbPacker.ignore

if not CppLogic then
    return
end

TriggerFixCppLogicExtension = {CreatedTrigger=nil, FirstCreated=nil}

TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_CONVERT_ENTITY")

function TriggerFixCppLogicExtension.Init()
    CppLogic.Entity.Settler.EnableConversionHook(TriggerFixCppLogicExtension.Hook)
end

function TriggerFixCppLogicExtension.AddLeaveTrigger()
    Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_LEAVE_MAP, nil, "CppLogic.OnLeaveMap", 1)
    return true
end

function TriggerFixCppLogicExtension.Hook(targetId, player, isPost, converterId)
    if not isPost then
        TriggerFixCppLogicExtension.CreatedTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, TriggerFixCppLogicExtension.OnCreate, 1)
    else
        if TriggerFixCppLogicExtension.FirstCreated then
            local ev = TriggerFix.CreateEmptyEvent()
            ev.GetEntityID1 = targetId
            ev.GetEntityID2 = TriggerFixCppLogicExtension.FirstCreated
            ev.GetEntityID = converterId
            ev.GetPlayerID = player
            TriggerFix_action(Events.SCRIPT_EVENT_ON_CONVERT_ENTITY, ev)
            TriggerFixCppLogicExtension.FirstCreated = nil
        else
            EndJob(TriggerFixCppLogicExtension.CreatedTrigger)
        end
    end
end

function TriggerFixCppLogicExtension.OnCreate()
    if not TriggerFixCppLogicExtension.FirstCreated then
        TriggerFixCppLogicExtension.FirstCreated = Event.GetEntityID()
    end
    return true
end

AddMapStartAndSaveLoadedCallback("TriggerFixCppLogicExtension.Init")
AddMapStartCallback("TriggerFixCppLogicExtension.AddLeaveTrigger")
