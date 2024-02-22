--- author: ???		current maintainer: mcb			v1.0
--- gibt den key zurück unter dem _wert gespeichert ist
---@generic K
---@generic V
---@param _wert V
---@param _table {[K]:V}
---@return K?
function KeyOf(_wert, _table)
	if _table == nil then return false end
	for k, v in pairs(_table) do
		if v == _wert then
			return k
		end
	end
	return nil
end
