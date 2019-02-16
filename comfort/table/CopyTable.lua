
--- author: Noigi?		current maintainer: mcb		v2.0
--  kopiert ein table.
-- referenzerhaltend/metatablekopierend
function CopyTable(_t, ref)
	ref = ref or {}
	if type(_t) == "table" then
		if ref[_t] then
			return ref[_t]
		end
		local r = {}
		ref[_t] = r
		for k,v in pairs(_t) do
			r[k] = CopyTable(v, ref)
		end
		local mt = getmetatable(_t)
		if mt then
			if metatable then
				mt = CopyTable(mt, ref)
				mt.keySave = nil
				metatable.set(r, mt)
			else
				setmetatable(r, CopyTable(mt, ref))
			end
		end
		return r
	else
		return _t
	end
end
