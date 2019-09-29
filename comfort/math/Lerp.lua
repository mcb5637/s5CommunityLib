
--- author:RobbiTheFox		current maintainer:RobbiTheFox		v1.0
-- Lineare interpolation zwischen 2 werten.
function Lerp(_a, _b, _factor)
	return _a * _factor + _b * (1 - _factor)
end