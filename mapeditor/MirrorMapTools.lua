----------------------------------------------------------------------------------------------------------------
-- MirrorMapTools v1.2
-- Mirror Tools for Ingame and MapEditor in LuaDebugger mode
-- by RobbiTheFox
----------------------------------------------------------------------------------------------------------------
MMT = MMT or {}
----------------------------------------------------------------------------------------------------------------
-- point mirror
----------------------------------------------------------------------------------------------------------------
MMT.PM = {}
MMT.PM90 = {}
----------------------------------------------------------------------------------------------------------------
-- comfort func
-- named by map editor defaults
----------------------------------------------------------------------------------------------------------------
function MMT.PM.X()
	MMT.PointMirror(90)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.Y()
	MMT.PointMirror(180)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.XUp()
	MMT.PointMirror(270)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.YUp()
	MMT.PointMirror(0)
end
----------------------------------------------------------------------------------------------------------------
-- 180° - named by derection; N = north, E = east, S = south, W = west; <from>2<to>
-- mirror one half of the map to the other half of the map
----------------------------------------------------------------------------------------------------------------
function MMT.PM.N2S()
	MMT.PointMirror(315)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.NE2SW()
	MMT.PointMirror(270)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.E2W()
	MMT.PointMirror(225)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.SE2NW()
	MMT.PointMirror(180)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.S2N()
	MMT.PointMirror(135)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.SW2NE()
	MMT.PointMirror(90)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.W2E()
	MMT.PointMirror(45)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM.NW2SE()
	MMT.PointMirror(0)
end
----------------------------------------------------------------------------------------------------------------
-- 90° - named by derection
-- mirror one quarter of the map to an other quarter of the map
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.N2E()
	MMT.PointMirror({AngleMin = 0, AngleMax = 90}, 270)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.N2S()
	MMT.PointMirror({AngleMin = 0, AngleMax = 90}, 180)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.N2W()
	MMT.PointMirror({AngleMin = 0, AngleMax = 90}, 90)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.NE2SE()
	MMT.PointMirror({AngleMin = -45, AngleMax = 45}, 225)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.NE2SW()
	MMT.PointMirror({AngleMin = -45, AngleMax = 45}, 135)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.NE2NW()
	MMT.PointMirror({AngleMin = -45, AngleMax = 45}, 45)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.E2S()
	MMT.PointMirror({AngleMin = -90, AngleMax = 0}, 180)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.E2W()
	MMT.PointMirror({AngleMin = -90, AngleMax = 0}, 90)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.E2N()
	MMT.PointMirror({AngleMin = -90, AngleMax = 0}, 0)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.SE2SW()
	MMT.PointMirror({AngleMin = 225, AngleMax = 315}, 135)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.SE2NW()
	MMT.PointMirror({AngleMin = 225, AngleMax = 315}, 45)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.SE2NE()
	MMT.PointMirror({AngleMin = 225, AngleMax = 315}, 315)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.S2W()
	MMT.PointMirror({AngleMin = 180, AngleMax = 270}, 90)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.S2W()
	MMT.PointMirror({AngleMin = 180, AngleMax = 270}, 0)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.S2W()
	MMT.PointMirror({AngleMin = 180, AngleMax = 270}, 270)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.SW2NW()
	MMT.PointMirror({AngleMin = 135, AngleMax = 225}, 45)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.SW2NE()
	MMT.PointMirror({AngleMin = 135, AngleMax = 225}, 315)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.SW2SE()
	MMT.PointMirror({AngleMin = 135, AngleMax = 225}, 225)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.W2N()
	MMT.PointMirror({AngleMin = 90, AngleMax = 180}, 0)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.W2E()
	MMT.PointMirror({AngleMin = 90, AngleMax = 180}, 270)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.W2S()
	MMT.PointMirror({AngleMin = 90, AngleMax = 180}, 180)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.NW2NE()
	MMT.PointMirror({AngleMin = 45, AngleMax = 135}, 315)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.NW2SE()
	MMT.PointMirror({AngleMin = 45, AngleMax = 135}, 225)
end
----------------------------------------------------------------------------------------------------------------
function MMT.PM90.NW2SW()
	MMT.PointMirror({AngleMin = 45, AngleMax = 135}, 135)
end
----------------------------------------------------------------------------------------------------------------
-- point mirror function
-- see doku for more information
----------------------------------------------------------------------------------------------------------------
function MMT.PointMirror(_Source, _TargetAngle)
	
	if type(_Source) == "number" then
		
		_Source = {
			AngleMin = _Source,
			AngleMax = _Source + 180,
		}
		
		_TargetAngle = _Source.AngleMax
		
	elseif type(_Source) == "table" then
		
		if not _Source.AngleMin then
			LuaDebugger.Log("Error: PointMirror: invalid _Source.AngleMin")
			return
		else
			if not _Source.AngleMax then
				
				_Source.AngleMax = _Source.AngleMin + 180
				_TargetAngle = _Source.AngleMax
			end
		end
	else
		LuaDebugger.Log("Error: PointMirror: invalid _Source")
		return
	end
	
	_TargetAngle = _TargetAngle or _Source.AngleMax
	
	if type(_TargetAngle) ~= "number" then
		LuaDebugger.Log("Error: PointMirror: invalid _TargetAngle")
		return
	end
	
	MMT.Mirror(_Source, _TargetAngle)
end
----------------------------------------------------------------------------------------------------------------
-- axis mirror
----------------------------------------------------------------------------------------------------------------
MMT.AM = {}
----------------------------------------------------------------------------------------------------------------
-- comfort func
-- named by map editor defaults
----------------------------------------------------------------------------------------------------------------
function MMT.AM.X()
	MMT.AxisMirror(90)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.Y()
	MMT.AxisMirror(180)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.XUp()
	MMT.AxisMirror(270)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.YUp()
	MMT.AxisMirror(0)
end
----------------------------------------------------------------------------------------------------------------
-- 180° - named by derection; N = north, E = east, S = south, W = west; <from>2<to>
-- mirror one half of the map to the other half of the map
----------------------------------------------------------------------------------------------------------------
function MMT.AM.N2S()
	MMT.AxisMirror(315)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.NE2SW()
	MMT.AxisMirror(270)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.E2W()
	MMT.AxisMirror(225)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.SE2NW()
	MMT.AxisMirror(180)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.S2N()
	MMT.AxisMirror(135)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.SW2NE()
	MMT.AxisMirror(90)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.W2E()
	MMT.AxisMirror(45)
end
----------------------------------------------------------------------------------------------------------------
function MMT.AM.NW2SE()
	MMT.AxisMirror(0)
end
----------------------------------------------------------------------------------------------------------------
-- axis mirror function
-- see doku for more information
----------------------------------------------------------------------------------------------------------------
function MMT.AxisMirror(_Source)
	
	if type(_Source) == "number" then
		
		_Source = {
			AngleMin = _Source,
			AngleMax = _Source + 180,
		}
		
	elseif type(_Source) == "table" then
		
		if type(_Source.AngleMin) ~= "number" then
			LuaDebugger.Log("Error: AxisMirror: invalid _Source.AngleMin")
			return
		else
				
			_Source.AngleMax = _Source.AngleMin + 180
		end
	else
		LuaDebugger.Log("Error: AxisMirror: invalid _Source")
		return
	end
	
	MMT.Mirror(_Source, _Source.AngleMax, 1)
end
----------------------------------------------------------------------------------------------------------------
-- mirror function
-- do not use directly !!! use MMT.PointMirror or MMT.AxisMirror instead
----------------------------------------------------------------------------------------------------------------
function MMT.Mirror(_Source, _TargetAngle, _Mode)
	
	-- get size in low res first
	local mapsize = Logic.WorldGetSize() / 100
	local maphalf = mapsize / 2
	local mapdiag = math.sqrt(2 * (maphalf ^ 2))
	
	_Source.DistanceMin = _Source.DistanceMin or 0
	_Source.DistanceMax = _Source.DistanceMax or mapdiag
	
	local targetAngleMin = _TargetAngle
	local targetAngleMax = _TargetAngle + (_Source.AngleMax - _Source.AngleMin)
	
	-- how much do we rotate
	local mirrorAngle = targetAngleMin - _Source.AngleMin
	
	-- terrain (low res) - loop throug targets and copy data from source
	for x = 0, mapsize do
		-- get zeroed coords
		local x1 = x - maphalf
		
		for y = 0, mapsize do
			-- get zeroed coords
			local y1 = y - maphalf
			
			local dist = math.sqrt(x1^2 + y1^2)
			
			if dist >= _Source.DistanceMin and dist <= _Source.DistanceMax then
				
				local angle = MMT.AllignAngle(math.deg(math.atan2(y1, x1)), targetAngleMin)
				
				if angle >= targetAngleMin and angle < targetAngleMax then
					
					local x2, y2 = MMT.GetMirrorPosition(dist, _Source.AngleMin, targetAngleMin, angle, maphalf, _Mode)
					x2 = math.floor(x2 + 0.5)
					y2 = math.floor(y2 + 0.5)
					
					if (x2 >= 0 and x2 <= mapsize and y2 >= 0 and y2 <= mapsize) then
						-- terrain height
						local terrainHeight = CUtil.GetTerrainNodeHeight(x2, y2)
						Logic.SetTerrainNodeHeight(x, y, terrainHeight)
						
						-- vertex color
						local r, g, b = CUtil.GetTerrainVertexColor(x2, y2)
						Logic.SetTerrainVertexColor(x, y, r, g, b)
					else
						-- set defaults
						Logic.SetTerrainNodeHeight(x, y, 2000)
						Logic.SetTerrainVertexColor(x, y, 127, 127, 127)
					end
					-- every 4th node
					if math.mod(x+2, 4) == 0 and math.mod(y+2, 4) == 0 then
						
						x2 = math.floor(x2 / 4) * 4
						y2 = math.floor(y2 / 4) * 4
						
						if x2 >= 0 and x2 < mapsize and y2 >= 0 and y2 < mapsize then
							-- terrain texture
							local terrainTexture = CUtil.GetTerrainNodeType(x2, y2)
							Logic.SetTerrainNodeType(x-2, y-2, terrainTexture)
							
							-- water height
							local waterHeight = CUtil.GetWaterHeight(x2, y2)
							Logic.WaterSetAbsoluteHeight(x-2, y-2, x-2, y-2, waterHeight)
							
							-- water texture
							local waterTexture = CUtil.GetWaterType(x2, y2) - 64
							Logic.WaterSetType(x-2, y-2, x-2, y-2, waterTexture)
						else
							-- set defaults
							Logic.SetTerrainNodeType(x-2, y-2, 120)
							Logic.WaterSetAbsoluteHeight(x-2, y-2, x-2, y-2, 1500)
							Logic.WaterSetType(x-2, y-2, x-2, y-2, 1)
						end
					end
				end
			end
		end
	end
	
	-- make size hi res
	mapsize = mapsize * 100
	maphalf = maphalf * 100
	_Source.DistanceMin = _Source.DistanceMin * 100
	_Source.DistanceMax = _Source.DistanceMax * 100
	
	-- create entity table to copy
	local ct = {}
	local dt = {}
	
	-- entities (hi res) - loop throug (potential) sources and copy them to target
	for e in CEntityIterator.Iterator() do
		
		local x, y = Logic.EntityGetPos(e)
		local dist = math.sqrt((x - maphalf)^2 + (y - maphalf)^2)
		
		if dist >= _Source.DistanceMin and dist <= _Source.DistanceMax then
			
			local angle = MMT.AllignAngle(math.deg(math.atan2(y - maphalf, x - maphalf)), _Source.AngleMin)
			
			if angle >= _Source.AngleMin and angle < _Source.AngleMax then
				
				local x2, y2 = MMT.GetMirrorPosition(dist, targetAngleMin, _Source.AngleMin, angle, maphalf, _Mode)
				
				if x2 >= 0 and x2 < mapsize and y2 >= 0 and y2 < mapsize then
					
					table.insert(ct, {e, x2, y2})
				end
			else
				
				angle = MMT.AllignAngle(angle, targetAngleMin)
				
				if angle >= targetAngleMin and angle < targetAngleMax then
					table.insert(dt, e)
				end
			end
		end
	end
	
	for _,v in pairs(dt) do
		Logic.DestroyEntity(v)
	end
	
	for _,v in pairs(ct) do
		MMT.CopyEntity(v[1], v[2], v[3], mirrorAngle)
	end
end
----------------------------------------------------------------------------------------------------------------
-- Mirror Utility
----------------------------------------------------------------------------------------------------------------
function MMT.AllignAngle(_Angle, _Offset)

	_Offset = _Offset or 0
	
	while _Angle >= 360 + _Offset do
		_Angle = _Angle - 360
	end
	while _Angle < _Offset do
		_Angle = _Angle + 360
	end
	
	return _Angle
end
----------------------------------------------------------------------------------------------------------------
function MMT.GetMirrorPosition(_Dist, _SourceAngle, _TargetAngle, _Angle, _Maphalf, _Mode)
	
	if _Mode == 1 then
		_Angle = -(_Angle - _SourceAngle * 2)
	else
		_Angle = _SourceAngle + (_Angle - _TargetAngle)
	end
	
	local x = _Dist * math.cos(math.rad(_Angle)) + _Maphalf
	local y = _Dist * math.sin(math.rad(_Angle)) + _Maphalf
	
	return x, y
end
----------------------------------------------------------------------------------------------------------------
function MMT.CopyEntity(_e, _x, _y, _r)
	
	_r = _r or 0
	
	if type(_e) == "string" then
		_e = Logic.GetEntityIDByName(_e)
	end
	
	if Logic.IsBuilding(_e) == 1 or Logic.GetResourceDoodadGoodAmount(_e) > 0 then
		_r = 0
	end
	
	local e = Logic.CreateEntity(Logic.GetEntityType(_e), _x, _y, MMT.AllignAngle(Logic.GetEntityOrientation(_e) + _r), Logic.EntityGetPlayer(_e))
	
	local name = Logic.GetEntityName(_e)
	if name then
		Logic.SetEntityName(e, name)
	end
	
	-- scale
	Logic.SetEntityScriptingValue(e, -33, Logic.GetEntityScriptingValue(_e, -33))
	
	if Logic.GetEntityType(_e) == Entities.XS_Ambient then
		Logic.SetEntityScriptingValue(e,  -8, Logic.GetEntityScriptingValue(_e,  -8))
		Logic.SetEntityScriptingValue(e,   9, Logic.GetEntityScriptingValue(_e,   9))
	else
		local resourceAmount = Logic.GetResourceDoodadGoodAmount(_e)
		if resourceAmount > 0 then
			Logic.SetResourceDoodadGoodAmount(e, resourceAmount)
		end
	end
	
	return e
end
----------------------------------------------------------------------------------------------------------------
function SnapToGrid(_grid, ...)
	for i,v in ipairs(arg) do
		arg[i] = math.floor(v / _grid + 0.5) * _grid
	end
	return unpack(arg)
end