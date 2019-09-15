
--- author:???		current maintainer:mcb		v1.0
-- Berechnet eine Position auf einer Kreisbahn.
function GetCirclePosition(_position, _range, _angle)
    assert(type(_position) == "table")
    local angle = math.rad(_angle)
    assert(type(angle) == "number")
    assert(type(_range) == "number")
    return {
        X = _position.X + math.cos(angle) * _range,
        Y = _position.Y + math.sin(angle) * _range  
    }
end
