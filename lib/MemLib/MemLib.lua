--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.2
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if MemLib then
	return
end
--------------------------------------------------------------------------------
MemLib = {}
MemLib.Internal = {}
--------------------------------------------------------------------------------
function MemLib.Load(...)
	for i = 1, table.getn(arg) do
		local module = arg[i]
		if type(module) == "string" and not MemLib[module] then
			module = string.gsub(module, "/", "\\")
			if string.find(module, "\\") then
				Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\" .. module .. ".lua")
			else
				Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\Lib\\MemLib\\" .. module .. ".lua")
			end
		end
	end
end
--------------------------------------------------------------------------------
if CUtilMemory and CUtilMemory.GetMemory then

	---@param _Address integer
	---@return userdata|table
	function MemLib.GetMemory(_Address)
		assert(type(_Address) == "number" and _Address > 0, "MemLib.GetMemory: _Address invalid")
		return CUtilMemory.GetMemory(_Address)
	end

elseif S5Hook and S5Hook.GetRawMem then

	---@param _Address integer
	---@return userdata|table
	function MemLib.GetMemory(_Address)
		assert(type(_Address) == "number" and _Address > 0, "MemLib.GetMemory: _Address invalid")
		return S5Hook.GetRawMem(_Address)
	end

else

	if mcbPacker then
		mcbPacker.require("s5CommunityLib/Lib/MemLib/SV")
	else
		MemLib.Load("SV")
	end

	---@param _Address integer
	---@return userdata|table
	function MemLib.GetMemory(_Address)
		assert(type(_Address) == "number" and _Address > 0, "MemLib.GetMemory: _Address invalid")
		return MemLib.SV.New(_Address)
	end

end
--------------------------------------------------------------------------------
-- use S5Hook if available
if not CNetwork and S5Hook and S5Hook.ReAllocMem and S5Hook.FreeMem then

	---@param _Bytes integer
	---@return integer address
	function MemLib.Alloc(_Bytes)
		assert(type(_Bytes) == "number" and _Bytes > 0, "MemLib.GetMemory: _Bytes invalid")
		return S5Hook.ReAllocMem(0, _Bytes)
	end

	---@param _Address integer
	function MemLib.Free(_Address)
		assert(type(_Address) == "number" and _Address > 0, "MemLib.GetMemory: _Address invalid")
		return S5Hook.FreeMem(_Address)
	end

	---@param _Address integer
	---@param _Bytes integer
	---@return integer address
	function MemLib.ReAlloc(_Address, _Bytes)
		assert(type(_Address) == "number" and _Address > 0, "MemLib.GetMemory: _Address invalid")
		assert(type(_Bytes) == "number" and _Bytes > 0, "MemLib.GetMemory: _Bytes invalid")
		return S5Hook.ReAllocMem(_Address, _Bytes)
	end

--------------------------------------------------------------------------------
-- otherwise use replacement
else

	if mcbPacker then
		mcbPacker.require("s5CommunityLib/Lib/MemLib/Entity")
	else
		MemLib.Load("Entity")
	end

	---@param _Bytes integer
	---@return integer address
	function MemLib.Alloc(_Bytes)
		assert(type(_Bytes) == "number" and _Bytes > 0, "MemLib.GetMemory: _Bytes invalid")

		local name = string.rep("a", _Bytes)
		local oldid = Logic.GetEntityIDByName(name)

		if Logic.IsEntityAlive(oldid) then
			Logic.SetEntityName(oldid, nil)
		end

		local id = Logic.CreateEntity(Entities.XD_Rock1, 500, 500, 0, 0)

		Logic.SetEntityName(id, name)

		local namepointer = MemLib.Entity.GetMemory(id)[MemLib.Offsets.Entity.NamePointer]
		local address = namepointer:GetInt()

		namepointer:SetInt(0)
		Logic.DestroyEntity(id)

		if Logic.IsEntityAlive(oldid) then
			Logic.SetEntityName(oldid, name)
		else
			MemLib.Internal.ScriptNameRemoveFromMap(name)
		end

		return address
	end
	------------------------------------------------------------------------
	---@param _Address integer
	function MemLib.Free(_Address)
		assert(type(_Address) == "number" and _Address > 0, "MemLib.GetMemory: _Address invalid")

		local id = Logic.CreateEntity(Entities.XD_Rock1, 500, 500, 0, 0)
		local namepointer = MemLib.Entity.GetMemory(id)[MemLib.Offsets.Entity.NamePointer]

		namepointer:SetInt(_Address)
		Logic.SetEntityName(id, nil)
		Logic.DestroyEntity(id)
	end
	------------------------------------------------------------------------
	---@param _Address integer
	---@param _Bytes integer
	---@return integer address
	function MemLib.ReAlloc(_Address, _Bytes)
		assert(type(_Address) == "number" and _Address > 0, "MemLib.GetMemory: _Address invalid")
		assert(type(_Bytes) == "number" and _Bytes > 0, "MemLib.GetMemory: _Bytes invalid")

		local address = MemLib.Alloc(_Bytes)
		MemLib.Copy(_Address, address, _Bytes) -- crashes for some reason?
		MemLib.Free(_Address)

		return address
	end

end
--------------------------------------------------------------------------------
---@param _Name string
function MemLib.Internal.ScriptNameRemoveFromMap(_Name)
	local id = Logic.CreateEntity(Entities.XD_Rock1, 500, 500, 0, 0)
	Logic.SetEntityName(id, _Name)
	Logic.SetEntityName(id, nil)
	Logic.DestroyEntity(id)
end
--------------------------------------------------------------------------------
---@param _SourceAddress integer
---@param _TargetAddress integer
---@param _Bytes integer
function MemLib.Copy(_SourceAddress, _TargetAddress, _Bytes)
	assert(type(_Bytes) == "number" and _Bytes > 0, "MemLib.GetMemory: _Bytes invalid")
	local sourceMemory = MemLib.GetMemory(_SourceAddress)
	local targetMemory = MemLib.GetMemory(_TargetAddress)
	for i = 0, _Bytes - 1 do
		targetMemory:SetByte(i, sourceMemory:GetByte(i))
	end
end
--------------------------------------------------------------------------------
---@param _MapMemory userdata|table
---@param _NodeSize integer
---@param _Nodes? table
---@return table
function MemLib.Internal.MapGetNodes(_MapMemory, _NodeSize, _Nodes)
	_Nodes = _Nodes or {}
	for i = 0, 2 do
		local nodeAddress = _MapMemory[i]:GetInt()
		if not _Nodes[nodeAddress] then
			_Nodes[nodeAddress] = {}
			_MapMemory = MemLib.GetMemory(nodeAddress)
			for j = 1, _NodeSize do
				_Nodes[nodeAddress][j] = _MapMemory[j + 2]:GetInt()
			end
			MemLib.Internal.MapGetNodes(_MapMemory, _NodeSize, _Nodes)
		end
	end
	return _Nodes
end
--------------------------------------------------------------------------------
---@param _MapMemory userdata|table
---@param _KeyIndex integer
---@param _Key integer
---@param _ValueIndex integer
---@param _Value integer
---@param _Nodes? table
---@return boolean
function MemLib.Internal.MapNodeSetValue(_MapMemory, _KeyIndex, _Key, _ValueIndex, _Value, _Nodes)
	_Nodes = _Nodes or {}
	for i = 0, 2 do
		local nodeAddress = _MapMemory[i]:GetInt()
		if not _Nodes[nodeAddress] then
			_Nodes[nodeAddress] = true
			_MapMemory = MemLib.GetMemory(nodeAddress)
			if _Nodes[nodeAddress][_KeyIndex]:GetInt() == _Key then
				_Nodes[nodeAddress][_ValueIndex]:SetInt(_Value)
				return true
			end
			if MemLib.Internal.MapNodeSetValue(_MapMemory, _KeyIndex, _Key, _ValueIndex, _Value, _Nodes) then
				return true
			end
		end
	end
	return false
end
--------------------------------------------------------------------------------
MemLib.Load("FPU", "Offsets")