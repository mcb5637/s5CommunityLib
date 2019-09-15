
--- author:???		current maintainer:mcb		v1.0
-- Berechnet einen winkel zwischen 2 positionen.
function GetAngleBetween(_Pos1,_Pos2)
	local delta_X = 0;
	local delta_Y = 0;
	local alpha   = 0
	if type (_Pos1) == "string" or type (_Pos1) == "number" then
		_Pos1 = GetPosition(GetEntityId(_Pos1));
	end
	if type (_Pos2) == "string" or type (_Pos2) == "number" then
		_Pos2 = GetPosition(GetEntityId(_Pos2));
	end
	delta_X = _Pos1.X - _Pos2.X
	delta_Y = _Pos1.Y - _Pos2.Y
	if delta_X == 0 and delta_Y == 0 then -- Gleicher Punkt
		return 0
	end
	alpha = math.deg(math.asin(math.abs(delta_X)/(math.sqrt(__pow(delta_X, 2)+__pow(delta_Y, 2)))))
	if delta_X >= 0 and delta_Y > 0 then
		alpha = 270 - alpha 
	elseif delta_X < 0 and delta_Y > 0 then
		alpha = 270 + alpha
	elseif delta_X < 0 and delta_Y <= 0 then
		alpha = 90  - alpha
	elseif delta_X >= 0 and delta_Y <= 0 then
		alpha = 90  + alpha
	end
	return alpha
end
