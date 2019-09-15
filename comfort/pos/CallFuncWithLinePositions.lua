
--- author:mcb		current maintainer:mcb		v2.0
-- Neue Funktion auf Grundlage von Effektlinie von Noigi.
-- Führt eine Funktion auf erzeugten Positionen zwischen a und b in ungefähr periode Abstand aus.
-- (neudefinition mit Vektoren)
-- 
-- CallFuncWithLinePositions(GetPosition(id1), GetPosition(id1), function(p)
-- 		Logic.CreateEffect(GGL_Effects.FXChopTree, p.X, p.Y, nil)
-- end, 100)
function CallFuncWithLinePositions(a, b, func, periode)
    local ax = a.X
	local ay = a.Y
	local bx = b.X
	local by = b.Y
	
	-- vector a->b
	local dx = bx - ax
	local dy = by - ay
	
	-- number of points
	local d = math.sqrt(dx*dx + dy*dy)
	local n = round(d/periode)
	
	-- "normalize"
	dx = dx / n
	dy = dy / n
	
	for i=1, n do
		func{X=ax+dx*i, Y=ay+dy*i}
	end
end
