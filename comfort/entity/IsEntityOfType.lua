
--- author: Noigi,mcb		current maintainer: mcb		v2.0
--
-- Gibt zurück, ob ein Entity von einem der angegebenen Typen ist.
--
-- Parameter:
-- - id			Entity (id, name)
-- - ...		typen (Entities.XXX, XXX)
--
-- Rückgabe:
-- - true/false
--
function IsEntityOfType(id, ...)
	if IsDestroyed(id) then
		return false
	end
	local ty = Logic.GetEntityType(GetID(id))
	assert(table.getn(arg)>0)
	for _,t in ipairs(arg) do
		if type(t)=="string" then
			t = Entities[t]
		end
		if ty == t then
			return true
		end
	end
	return false
end
