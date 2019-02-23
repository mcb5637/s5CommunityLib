
--- author:???		current maintainer:mcb		v1.0
-- prüft eine position.
function IsValidPosition( _position )
	if ( type(_position) == "table" ) then
		if ( type(_position.X) == "number" ) and ( type(_position.Y) == "number" ) then
			local x,y = Logic.WorldGetSize();
			if ( (_position.X <= x+100) and (_position.X >= 0) ) and ( (_position.Y <= y+100) and (_position.Y >= 0) ) then
				return true;
			end
		end
	end
	return false;
end
