--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.World
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Bit")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Bit")
end
--------------------------------------------------------------------------------
MemLib.World = {}
--------------------------------------------------------------------------------
-- coordinates in sm
---@param _X integer
---@param _Y integer
---@return boolean
function MemLib.World.NodeIsValid(_X, _Y)
	local worldSize = Logic.WorldGetSize() / 100
	return type(_X) == "number" and type(_Y) == "number" and _X >= 0 and _Y >= 0 and _X <= worldSize and _Y <= worldSize
end
--------------------------------------------------------------------------------
-- coordinates in scm
---@param _X number
---@param _Y number
---@return boolean
function MemLib.World.PositionIsValid(_X, _Y)
	local worldSize = Logic.WorldGetSize()
	return type(_X) == "number" and type(_Y) == "number" and _X >= 0 and _Y >= 0 and _X <= worldSize and _Y <= worldSize
end
--------------------------------------------------------------------------------
if XNetwork.Manager_IsNATReady then

	--------------------------------------------------------------------------------
	---@param _TerrainType integer
	---@return boolean
	function MemLib.World.TerrainTypeIsValid(_TerrainType)
		local TerrainPropsLogic = MemLib.Internal.CGluePropsMgrGetMemory()[7]
		local lastValidIndex = MemLib.LAU.ToNumber((MemLib.LAU.ToTable(TerrainPropsLogic[MemLib.Offsets.CTerrainPropsMgr.VectorStart + 1]:GetInt()) - TerrainPropsLogic[MemLib.Offsets.CTerrainPropsMgr.VectorStart]:GetInt()) / 8)
		return _TerrainType >= 0 and _TerrainType < lastValidIndex
	end
	--------------------------------------------------------------------------------
	---@param _WaterType integer
	---@return boolean
	function MemLib.World.WaterTypeIsValid(_WaterType)
		local WaterPropsLogic = MemLib.Internal.CGluePropsMgrGetMemory()[8]
		local lastValidIndex = MemLib.LAU.ToNumber((MemLib.LAU.ToTable(WaterPropsLogic[MemLib.Offsets.CGlueWaterPropsMgr.VectorStart + 1]:GetInt()) - WaterPropsLogic[MemLib.Offsets.CGlueWaterPropsMgr.VectorStart]:GetInt()) / 4)
		return _WaterType >= 0 and _WaterType < lastValidIndex
	end

else

	--------------------------------------------------------------------------------
	---@param _TerrainType integer
	---@return boolean
	function MemLib.World.TerrainTypeIsValid(_TerrainType)
		local TerrainPropsLogic = MemLib.Internal.CGluePropsMgrGetMemory()[7]
		MemLib.ArmPreciseFPU()
		MemLib.SetPreciseFPU()
		local lastValidIndex = (TerrainPropsLogic[MemLib.Offsets.CTerrainPropsMgr.VectorStart + 1]:GetInt() - TerrainPropsLogic[MemLib.Offsets.CTerrainPropsMgr.VectorStart]:GetInt()) / 8
		MemLib.DisarmPreciseFPU()
		return _TerrainType >= 0 and _TerrainType < lastValidIndex
	end
	--------------------------------------------------------------------------------
	---@param _WaterType integer
	---@return boolean
	function MemLib.World.WaterTypeIsValid(_WaterType)
		local WaterPropsLogic = MemLib.Internal.CGluePropsMgrGetMemory()[8]
		MemLib.ArmPreciseFPU()
		MemLib.SetPreciseFPU()
		local lastValidIndex = (WaterPropsLogic[MemLib.Offsets.CGlueWaterPropsMgr.VectorStart + 1]:GetInt() - WaterPropsLogic[MemLib.Offsets.CGlueWaterPropsMgr.VectorStart]:GetInt()) / 4
		MemLib.DisarmPreciseFPU()
		return _WaterType >= 0 and _WaterType < lastValidIndex
	end

end
--------------------------------------------------------------------------------
-- TODO: find CGLELandscape`s global object
if MemLib.Offsets.CGLELandscape.GlobalObject then

	--------------------------------------------------------------------------------
	---@return userdata|table
	function MemLib.Internal.LandscapeGetMemory()
		return MemLib.GetMemory(MemLib.Offsets.CGLEGameLogic.GlobalObject)[0][MemLib.Offsets.CGLEGameLogic.CGLELandscape]
	end

else

	--------------------------------------------------------------------------------
	---@return userdata|table
	function MemLib.Internal.LandscapeGetMemory()
		return MemLib.GetMemory(MemLib.Offsets.CGLELandscape.GlobalObject)[0]
	end

end
--------------------------------------------------------------------------------
-- this looks exactly the same in all versions, no need for external offsets
---@return userdata|table
function MemLib.Internal.CGluePropsMgrGetMemory()
	return MemLib.GetMemory(MemLib.Offsets.CMain.GlobalObject)[0][MemLib.Offsets.CMain.CGLUEPropsMgr]
end
--------------------------------------------------------------------------------
-- returns a bitfield of blocking at position in sm
--
-- 0: free
--
-- 1: entity (not yet implemented)
--
-- 2: bridgearea
--
-- 4: buildblock
--
-- 8: terrain
--
-- 16: water
--
-- 32: isUnderWater
--
-- 64: isWaterFreezing
---@param _X integer
---@param _Y integer
---@return integer
function MemLib.World.NodeGetBlockingExtended(_X, _Y)
	assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeGetBlocking: node invalid")
	local blocking = MemLib.World.NodeGetBlocking(_X, _Y)
	local entity = 0
	local bridge = MemLib.Bit.And(blocking, 2)
	local buildblock = MemLib.Bit.And(blocking, 4)
	local terrain = MemLib.Bit.Or(MemLib.Bit.And(blocking, 8), MemLib.World.NodeIsBlockedByTerrainType(_X, _Y) and 8 or 0)
	local isUnderWater = MemLib.World.NodeIsUnderWater(_X, _Y) and 16 or 0
	local isWaterFreezing = MemLib.World.NodeIsWaterFreezing(_X, _Y) and 32 or 0
	return entity + bridge + buildblock + terrain + isUnderWater + isWaterFreezing
end
--------------------------------------------------------------------------------
-- params in sm
---@param _X integer
---@param _Y integer
---@param _BitField? integer
---@param _WeatherState? integer
---@return boolean
function MemLib.World.NodeIsBlockedExtended(_X, _Y, _BitField, _WeatherState)
	assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeIsBlocked: node invalid")
	_BitField = _BitField or 159
	_WeatherState = _WeatherState or Logic.GetWeatherState()
	if MemLib.Bit.And(_BitField, MemLib.World.NodeGetBlocking(_X, _Y)) ~= 0 then
		return true
	elseif MemLib.Bit.And(_BitField, 8) ~= 0 and MemLib.World.NodeIsBlockedByTerrainType(_X, _Y) then
		return true
	elseif MemLib.Bit.And(_BitField, 16) ~= 0 and MemLib.World.NodeIsUnderWater(_X, _Y) then
		return true
	elseif MemLib.Bit.And(_BitField, 32) ~= 0 and MemLib.World.NodeIsWaterFreezing(_X, _Y) and _WeatherState ~= 3 then
		return true
	end
	return false
end
--------------------------------------------------------------------------------
-- coordinates in sm
---@param _X integer
---@param _Y integer
---@return boolean
function MemLib.World.NodeIsBlockedByTerrainType(_X, _Y)
	assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeIsBlockedByTerrainType: node invalid")
	return MemLib.TerrainTypeIsBlocked(MemLib.World.NodeGetTerrainType(_X, _Y))
end
--------------------------------------------------------------------------------
---@param _TerrainType integer
---@return boolean
function MemLib.World.TerrainTypeIsBlocked(_TerrainType)
	assert(MemLib.World.TerrainTypeIsValid(_TerrainType), "MemLib.World.WaterTypeIsFreezing: _WaterType invalid")
	return MemLib.Internal.CGluePropsMgrGetMemory()[7][MemLib.Offsets.CTerrainPropsMgr.VectorStart][_TerrainType * 2]:GetByte(0) == 1
end
--------------------------------------------------------------------------------
-- coordinates in sm
---@param _X integer
---@param _Y integer
---@return boolean
function MemLib.World.NodeIsBlockedByWater(_X, _Y, _WeatherState)
	assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeIsBlockedByWater: node invalid")
	_WeatherState = _WeatherState or Logic.GetWeatherState()
	return MemLib.World.NodeIsUnderWater(_X, _Y) and (_WeatherState ~= 3 or MemLib.World.NodeIsWaterFreezing(_X, _Y))
end
--------------------------------------------------------------------------------
-- coordinates in sm
---@param _X integer
---@param _Y integer
---@return boolean
function MemLib.World.NodeIsUnderWater(_X, _Y)
	assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeIsUnderWater: node invalid")
	return MemLib.World.NodeGetTerrainHeight(_X, _Y) < MemLib.World.NodeGetWaterHeight(_X, _Y)
end
--------------------------------------------------------------------------------
-- coordinates in sm
---@param _X integer
---@param _Y integer
---@return boolean
function MemLib.World.NodeIsWaterFreezing(_X, _Y)
	assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeIsWaterFreezing: node invalid")
	return MemLib.WaterTypeIsFreezing(MemLib.NodeGetWaterType(_X, _Y))
end
--------------------------------------------------------------------------------
---@param _WaterType integer
---@return boolean
function MemLib.World.WaterTypeIsFreezing(_WaterType)
	assert(MemLib.World.WaterTypeIsValid(_WaterType), "MemLib.World.WaterTypeIsFreezing: _WaterType invalid")
	return MemLib.Internal.CGluePropsMgrGetMemory()[8][MemLib.Offsets.CGlueWaterPropsMgr.VectorStart][_WaterType]:GetByte(0) == 1
end
--------------------------------------------------------------------------------
---@param _X integer
---@param _Y integer
---@return integer
function MemLib.World.NodeGetWaterType(_X, _Y)
	assert(MemLib.World.NodeIsValid(_X, _Y))
	_X, _Y = math.floor(_X / 4), math.floor(_Y / 4)
	local CGLETerrainLowRes = MemLib.Internal.LandscapeGetMemory()[MemLib.Offsets.CGLELandscape.CGLETerrainLowRes]
	local y = CGLETerrainLowRes[MemLib.Offsets.CGLETerrainLowRes.ArraySizeY]:GetInt()
	local data = CGLETerrainLowRes[MemLib.Offsets.CGLETerrainLowRes.DataVectorStart][(_Y + 1) * y + _X + 1]:GetInt()
	return MemLib.Bit.RShift(8, MemLib.Bit.And(data, 16128))
end
--------------------------------------------------------------------------------
---@param _X integer
---@param _Y integer
---@return integer
function MemLib.World.NodeGetWaterHeight(_X, _Y)
	assert(MemLib.World.NodeIsValid(_X, _Y))
	_X, _Y = math.floor(_X / 4), math.floor(_Y / 4)
	local CGLETerrainLowRes = MemLib.Internal.LandscapeGetMemory()[MemLib.Offsets.CGLELandscape.CGLETerrainLowRes]
	local y = CGLETerrainLowRes[11]:GetInt()
	local data = CGLETerrainLowRes[MemLib.Offsets.CGLETerrainLowRes.DataVectorStart][(_Y + 1) * y + _X + 1]:GetInt()
	return MemLib.Bit.RShift(14, MemLib.Bit.And(data, 1073725440))
end
--------------------------------------------------------------------------------
-- coordinates in sm
---@param _X integer
---@param _Y integer
---@return integer R
---@return integer G
---@return integer B
function MemLib.World.NodeGetVertexColor(_X, _Y)
	assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeGetVertexColor: node invalid")
	local CTerrainVertexColors = MemLib.Internal.LandscapeGetMemory()[MemLib.Offsets.CGLELandscape.CTerrainVertexColors]
	local y = CTerrainVertexColors[2]:GetInt()
	local color = CTerrainVertexColors[3][(_Y + 1) * y + _X + 1]:GetInt()
	local r = MemLib.Bit.And(MemLib.Bit.RShift(16, color), 255)
	local g = MemLib.Bit.And(MemLib.Bit.RShift(8, color), 255)
	local b = MemLib.Bit.And(color, 255)
	return r, g, b
end
--------------------------------------------------------------------------------
if CUtil then

	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetTerrainType(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeGetTerrainType: node invalid")
		return CUtil.GetTerrainNodeType(_X, _Y)
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetTerrainHeight(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeGetTerrainHeight: node invalid")
		return CUtil.GetTerrainNodeHeight(_X, _Y)
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetWaterHeight(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeGetWaterHeight: node invalid")
		return CUtil.GetWaterHeight(_X, _Y)
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetWaterType(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.NodeGetWaterType: node invalid")
		return CUtil.GetWaterType(_X, _Y)
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetBlocking(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.GetBlocking: node invalid")
		return CUtil.GetBlocking100(_X * 100, _Y * 100)
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetSector(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.GetBlocking: node invalid")
		return CUtil.GetSector(_X, _Y)
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer R
	---@return integer G
	---@return integer B
	function MemLib.World.NodeGetVertexColor(_X, _Y)
		return CUtil.GetTerrainVertexColor(_X, _Y)
	end

elseif S5Hook then

	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetTerrainHeight(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y))
		local height = S5Hook.GetTerrainInfo(_X * 100, _Y * 100)
		return height
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetBlocking(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y))
		local _, blocking = S5Hook.GetTerrainInfo(_X * 100, _Y * 100)
		return blocking
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetSector(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y))
		local _, _, sector = S5Hook.GetTerrainInfo(_X * 100, _Y * 100)
		return sector
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetTerrainType(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y))
		local _, _, _, terrainType = S5Hook.GetTerrainInfo(_X * 100, _Y * 100)
		return terrainType
	end

elseif CppLogic then

	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetTerrainHeight(_X, _Y)
		return CppLogic.Logic.LandscapeGetTerrainHeight({X = _X * 100, Y = _Y * 100})
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetBlocking(_X, _Y)
		return CppLogic.Logic.LandscapeGetBlocking({X = _X * 100, Y = _Y * 100})
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetSector(_X, _Y)
		return CppLogic.Logic.LandscapeGetSector({X = _X * 100, Y = _Y * 100})
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetTerrainType(_X, _Y)
		return CppLogic.Logic.LandscapeGetTerrainType({X = _X * 100, Y = _Y * 100})
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetWaterHeight(_X, _Y)
		return CppLogic.Logic.LandscapeGetWaterHeight({X = _X * 100, Y = _Y * 100})
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetWaterType(_X, _Y)
		return CppLogic.Logic.LandscapeGetWaterType({X = _X * 100, Y = _Y * 100})
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer R
	---@return integer G
	---@return integer B
	function MemLib.World.NodeGetVertexColor(_X, _Y)
		local color = CppLogic.Logic.LandscapeGetTerrainVertexColor({X = _X * 100, Y = _Y * 100})
		local r = MemLib.Bit.And(MemLib.Bit.RShift(16, color), 255)
		local g = MemLib.Bit.And(MemLib.Bit.RShift(8, color), 255)
		local b = MemLib.Bit.And(color, 255)
		return r, g, b
	end

else

	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X integer
	---@param _Y integer
	---@return integer
	function MemLib.World.NodeGetTerrainType(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y))
		_X, _Y = math.floor(_X / 4), math.floor(_Y / 4)
		local CGLETerrainLowRes = MemLib.Internal.LandscapeGetMemory()[MemLib.Offsets.CGLELandscape.CGLETerrainLowRes]
		local y = CGLETerrainLowRes[MemLib.Offsets.CGLETerrainLowRes.ArraySizeY]:GetInt()
		local data = CGLETerrainLowRes[MemLib.Offsets.CGLETerrainLowRes.DataVectorStart][(_Y + 1) * y + _X + 1]:GetInt()
		return MemLib.Bit.And(data, 255)
	end
	--------------------------------------------------------------------------------
	-- coordinates in sm
	---@param _X number
	---@param _Y number
	---@return integer
	function MemLib.World.NodeGetBlocking(_X, _Y)
		assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.GetBlocking: node invalid")
		-- this was not missed, but it simply the same in all versions
		local LandscapeBlockingData = MemLib.Internal.LandscapeGetMemory()[1]
		local arraySize = LandscapeBlockingData[0]:GetInt()
		return LandscapeBlockingData[1][0]:GetByte(_Y * arraySize + _X)
	end
	--------------------------------------------------------------------------------
	if XNetwork.Manager_IsNATReady then

		--------------------------------------------------------------------------------
		-- coordinates in sm
		---@param _X integer
		---@param _Y integer
		---@return integer
		function MemLib.World.NodeGetTerrainHeight(_X, _Y)
			assert(MemLib.World.NodeIsValid(_X, _Y))
			local CGLETerrainHiRes = MemLib.Internal.LandscapeGetMemory()[MemLib.Offsets.CGLELandscape.CGLETerrainHiRes]
			local y = CGLETerrainHiRes[MemLib.Offsets.CGLETerrainHiRes.DataVectorStart]:GetInt()
			local address = CGLETerrainHiRes[MemLib.Offsets.CGLETerrainHiRes.ArraySizeY]:GetInt()
			address = MemLib.LAU.ToNumber(MemLib.LAU.ToTable(address) + ((_Y + 1) * y + _X + 1) * 2)
			return MemLib.Bit.And(MemLib.GetMemory(address)[0]:GetInt(), 65535)
		end
		--------------------------------------------------------------------------------
		-- coordinates in sm
		---@param _X integer
		---@param _Y integer
		---@return integer
		function MemLib.World.NodeGetSector(_X, _Y)
			assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.GetBlocking: node invalid")
			local LandscapeBlockingDataArraySize = MemLib.Internal.LandscapeGetMemory()[1][0]:GetInt()
			local eax = _Y * LandscapeBlockingDataArraySize + _X
			local ecx = MemLib.GetMemory(MemLib.Offsets.Sector_Unknown1)[0]:GetInt()
			eax = MemLib.LAU.ToNumber(MemLib.LAU.ToTable(ecx) + eax * 2)
			eax = MemLib.GetMemory(eax)[0]:GetInt()
			eax = MemLib.Bit.And(eax, 65535)
			return MemLib.GetMemory(MemLib.Offsets.Sector_Unknown2)[eax * 5]:GetInt()
		end

	else

		--------------------------------------------------------------------------------
		-- coordinates in sm
		---@param _X integer
		---@param _Y integer
		---@return integer
		function MemLib.World.NodeGetTerrainHeight(_X, _Y)
			assert(MemLib.World.NodeIsValid(_X, _Y))
			local CGLETerrainHiRes = MemLib.Internal.LandscapeGetMemory()[MemLib.Offsets.CGLELandscape.CGLETerrainHiRes]
			local y = CGLETerrainHiRes[MemLib.Offsets.CGLETerrainHiRes.DataVectorStart]:GetInt()
			local address = CGLETerrainHiRes[MemLib.Offsets.CGLETerrainHiRes.ArraySizeY]:GetInt()
			MemLib.ArmPreciseFPU()
			MemLib.SetPreciseFPU()
			address = address + ((_Y + 1) * y + _X + 1) * 2
			MemLib.DisarmPreciseFPU()
			return MemLib.Bit.And(MemLib.GetMemory(address)[0]:GetInt(), 65535)
		end
		--------------------------------------------------------------------------------
		-- coordinates in sm
		---@param _X integer
		---@param _Y integer
		---@return integer
		function MemLib.World.NodeGetSector(_X, _Y)
			assert(MemLib.World.NodeIsValid(_X, _Y), "MemLib.World.GetBlocking: node invalid")
			local LandscapeBlockingDataArraySize = MemLib.Internal.LandscapeGetMemory()[1][0]:GetInt()
			local eax = _Y * LandscapeBlockingDataArraySize + _X
			local ecx = MemLib.GetMemory(MemLib.Offsets.Sector_Unknown1)[0]:GetInt()
			MemLib.ArmPreciseFPU()
			MemLib.SetPreciseFPU()
			eax = ecx + eax * 2
			-- no need to disarm, its done by GetMemory
			eax = MemLib.GetMemory(eax)[0]:GetInt()
			eax = MemLib.Bit.And(eax, 65535)
			return MemLib.GetMemory(MemLib.Offsets.Sector_Unknown2)[eax * 5]:GetInt()
		end

	end

end