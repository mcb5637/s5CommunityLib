if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore

--- EntityIdChangedHelper		mcb			1.0
-- fügt trigger SCRIPT_EVENT_ON_ENTITY_ID_CHANGED hinzu.
-- 
-- Benötigt:
-- 		Trigger-Fix
EntityIdChangedHelper = {}
function EntityIdChangedHelper.Init()
	TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_ENTITY_ID_CHANGED")
	EntityIdChangedHelper.GroupSelection_EntityIDChanged = GroupSelection_EntityIDChanged
	GroupSelection_EntityIDChanged = function(ol, ne)
		EntityIdChangedHelper.GroupSelection_EntityIDChanged(ol, ne)
		local e = TriggerFix.CreateEmptyEvent()
		e.GetEntityID1 = ol
		e.GetEntityID2 = ne
		TriggerFix_action(Events.SCRIPT_EVENT_ON_ENTITY_ID_CHANGED, e)
	end
end

AddMapStartCallback(EntityIdChangedHelper.Init)
