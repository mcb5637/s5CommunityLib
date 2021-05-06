if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("comfort/FrameworkWrapper")
end --mcbPacker.ignore

if not CppLogic then
    return
end

TriggerFixCppLogicExtension = {CreatedTrigger=nil}

TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_CONVERT_ENTITY")

function TriggerFixCppLogicExtension.Init()
    CppLogic.Entity.Settler.EnableConversionHook(TriggerFixCppLogicExtension.Hook)
end

function TriggerFixCppLogicExtension.AddLeaveTrigger()
    Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_LEAVE_MAP, nil, "CppLogic.OnLeaveMap", 1)
    return true
end

function TriggerFixCppLogicExtension.Hook(targetId, player, newid, converterId)
    local ev = TriggerFix.CreateEmptyEvent()
    ev.GetEntityID1 = targetId
    ev.GetEntityID2 = newid
    ev.GetEntityID = converterId
    ev.GetPlayerID = player
    TriggerFix_action(Events.SCRIPT_EVENT_ON_CONVERT_ENTITY, ev)
end

AddMapStartAndSaveLoadedCallback("TriggerFixCppLogicExtension.Init")
AddMapStartCallback("TriggerFixCppLogicExtension.AddLeaveTrigger")
