mcbPacker.require("s5CommunityLib/comfort/pos/IsValidPosition")

--- author:mcb		current maintainer:mcb		v1.1
-- Neue Funktion auf Grundlage von KreisPosition von Noigi.
-- Führt eine Funktion in einem Kreis um _pos aus, mit _spacing Abstand zwischen den Punkten.
-- Übergeben wird ein erweitertes Positionstable mit zusätzlicher Rotation r.
-- 
-- FuncInCirclePos(GetPosition(id), 1000, 100, function(p)
-- 		Logic.CreateEffect(GGL_Effects.FXChopTree, p.X, p.Y, nil)
-- end)
function FuncInCirclePos(_pos, _range, _spacing, _func)
	-- Validate input
	if type(_pos) == "string" or type(_pos) == "number" then
		_pos = GetPosition(_pos);
	end
	assert( IsValidPosition(_pos), "Benoetigt Position!" );
	assert( type(_range) == "number", "Benoetigt Reichweitenangabe!" );
	_spacing = _spacing or 100;
	assert( type(_spacing) == "number", "Benoetigt Abstandsangabe!" );
	assert( type(_func) == "function", "Benoetigt Funktion!" );
	
	-- Determine angle step size
	local perimeter = 2 * _range * math.pi;
	local n = math.floor(perimeter / _spacing);
	local angleStep = 360/n;
	
	-- Go!
	local nSin;
	local nCos;
	local angle;
	local x,y,eID;
	for i = 0,(n-1) do
		angle = i*angleStep;
		nSin = math.sin((math.rad(angle)));
		nCos = math.cos((math.rad(angle)));
		x = _pos.X - nCos*_range;
		y = _pos.Y - nSin*_range;
		_func({X=x,Y=y,r=angle});
	end
end
