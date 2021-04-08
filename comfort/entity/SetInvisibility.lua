--- author:schmeling65		current maintainer:schmeling65		v0.1a
-- Macht Entities unsichtbar bzw. sichtbar basierend auf den EntityScripting-Values
-- 
-- id entweder EntityID oder Skriptname als String
-- flag true oder false: 	true -> unsichtbar
-- false -> sichtbar
function SetInvisibility(id, flag)
	if HistoryFlag == nil then
		if XNetwork.Manager_IsNATReady then
			HistoryFlag = 1
		else
			HistoryFlag = 0
		end
	end

	local idtemp
	if type(id) == "number" then
		idtemp = id
	end
	if type(id) == "string" then
		idtemp = Logic.GetEntityIDByName(id)
	end

	if flag then
		if HistoryFlag == 1 then
			Logic.SetEntityScriptingValue(idtemp, -26, 513)
		elseif HistoryFlag == 0 then
			Logic.SetEntityScriptingValue(idtemp, -30, 513)
		end
	else
		if HistoryFlag == 1 then
			Logic.SetEntityScriptingValue(idtemp, -26, 65793)
		elseif HistoryFlag == 0 then
			Logic.SetEntityScriptingValue(idtemp, -30, 65793)
		end
	end
end
