
--- author:???		current maintainer: mcb		v1.0
--  mathematisch runden
function Round( _n )
	return math.floor( _n + 0.5 );
end
---@diagnostic disable-next-line: lowercase-global
round = Round
