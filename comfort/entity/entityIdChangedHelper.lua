if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore

--- EntityIdChangedHelper		mcb			1.0
-- Speichert Id-Änderungen (z.B. durch SetPosition oder ChangePlayer) für 3 Sekunden und macht sie abrufbar
-- 
-- .Init()			in der FMA aufrufen
-- .GetNewID(oid)	wenn diese Id in den letzten 3 Sekunden ersetzt wurde, wird die neue Id zurückgegeben
-- 
-- Benötigt:
-- 		Trigger-Fix
EntityIdChangedHelper = {}
function EntityIdChangedHelper.Init()
	EntityIdChangedHelper.idChanges = {}
	EntityIdChangedHelper.GroupSelection_EntityIDChanged = GroupSelection_EntityIDChanged
	GroupSelection_EntityIDChanged = function(ol, ne)
		EntityIdChangedHelper.GroupSelection_EntityIDChanged(ol, ne)
		EntityIdChangedHelper.idChanges[ol] = {ne, 2}
	end
	StartSimpleJob(function()
		for ol, t in pairs(EntityIdChangedHelper.idChanges) do
			if t[2] <= 0 then
				EntityIdChangedHelper.idChanges[ol] = nil
			else
				t[2] = t[2] - 1
			end
		end
	end)
end
function EntityIdChangedHelper.GetNewID(ol)
	return EntityIdChangedHelper.idChanges[ol] and EntityIdChangedHelper.idChanges[ol][1]
end
