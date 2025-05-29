--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.SettlerType
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/EntityType")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Util")
    mcbPacker.require("s5CommunityLib/Tables/EntityTypeClasses")
    mcbPacker.require("s5CommunityLib/Comfort/Table/Table")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("EntityType", "Util", "Comfort/Table/Table", "Tables/EntityTypeClasses")
end
--------------------------------------------------------------------------------
MemLib.SettlerType = {}
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return userdata|table
function MemLib.SettlerType.GetMemory(_SettlerType)
    assert(MemLib.SettlerType.IsValid(_SettlerType), "MemLib.SettlerType.GetMemory: _SettlerType invalid")
    return MemLib.EntityType.GetMemory(_SettlerType)
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return boolean
function MemLib.SettlerType.IsValid(_SettlerType)
    return MemLib.EntityType.GetMemory(_SettlerType)[0]:GetInt() == EntityTypeClasses.CGLSettlerProps
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return integer
function MemLib.SettlerType.GetArmor(_SettlerType)
	return MemLib.SettlerType.GetMemory(_SettlerType)[61]:GetInt()
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@param _Amount integer
function MemLib.SettlerType.SetArmor(_SettlerType, _Amount)
	return MemLib.SettlerType.GetMemory(_SettlerType)[61]:SetInt(_Amount)
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return integer
function MemLib.SettlerType.GetArmorClass(_SettlerType)
	return MemLib.SettlerType.GetMemory(_SettlerType)[60]:GetInt()
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@param _ArmorClass integer
function MemLib.SettlerType.SetArmorClass(_SettlerType, _ArmorClass)
    assert(table.find(ArmorClasses, _ArmorClass))
	return MemLib.SettlerType.GetMemory(_SettlerType)[60]:SetInt(_ArmorClass)
end
--------------------------------------------------------------------------------
---@param _ResourceEntityType integer
---@param _SerfEntityType integer?
---@return number? Delay
---@return integer? Amount
function MemLib.SettlerType.SerfGetExtractionDelayAndAmount(_ResourceEntityType, _SerfEntityType)

	-- only for modding compatibility (eg if there are multiple types of serfs)
	_SerfEntityType = _SerfEntityType or Entities.PU_Serf

	local serfBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SerfEntityType, BehaviorProperties.CSerfBehaviorProps)

	if serfBehaviorProps then

		local vectorStartMemory = serfBehaviorProps[8]
		local vectorEndMemory = serfBehaviorProps[9]
		local lastindex = (vectorEndMemory:GetInt() - vectorStartMemory:GetInt()) / 4 - 1

		for i = 0, lastindex, 3 do
			if vectorStartMemory[i]:GetInt() == _ResourceEntityType then
				return vectorStartMemory[i + 1]:GetFloat(), vectorStartMemory[i + 2]:GetInt()
			end
		end
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return integer?
function MemLib.SettlerType.RefinerGetRawResourceType(_SettlerType)

	local workerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SettlerType, BehaviorProperties.CWorkerBehaviorProps)

	if workerBehaviorProps then
		return workerBehaviorProps[27]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return integer?
function MemLib.SettlerType.RefinerGetTransportAmount(_SettlerType)

	local workerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SettlerType, BehaviorProperties.CWorkerBehaviorProps)

	if workerBehaviorProps then
		return workerBehaviorProps[24]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return integer?
function MemLib.SettlerType.WorkerGetWorkWaitUntil(_SettlerType)

	local workerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SettlerType, BehaviorProperties.CWorkerBehaviorProps)

	if workerBehaviorProps then
		return workerBehaviorProps[7]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return integer?
function MemLib.SettlerType.WorkerGetWorkTimeChangeWork(_SettlerType)

	local workerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SettlerType, BehaviorProperties.CWorkerBehaviorProps)

	if workerBehaviorProps then
		return workerBehaviorProps[17]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return number?
---@return integer?
function MemLib.SettlerType.WorkerGetWorkTimeChangeFarmAndMax(_SettlerType)

	local workerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SettlerType, BehaviorProperties.CWorkerBehaviorProps)

	if workerBehaviorProps then
		return workerBehaviorProps[18]:GetFloat(), workerBehaviorProps[21]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return number?
---@return integer?
function MemLib.SettlerType.WorkerGetWorkTimeChangeResidenceAndMax(_SettlerType)

	local workerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SettlerType, BehaviorProperties.CWorkerBehaviorProps)

	if workerBehaviorProps then
		return workerBehaviorProps[19]:GetFloat(), workerBehaviorProps[22]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return number?
function MemLib.SettlerType.WorkerGetWorkTimeChangeCamp(_SettlerType)

	local workerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_SettlerType, BehaviorProperties.CWorkerBehaviorProps)

	if workerBehaviorProps then
		return workerBehaviorProps[20]:GetFloat()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerType integer
---@return integer
function MemLib.SettlerType.GetAttractionSlots(_SettlerType)
	assert(MemLib.SettlerType.IsValid(_SettlerType))
	return Logic.GetAttractionLimitValueByEntityType(_SettlerType)
end
--------------------------------------------------------------------------------
if CLogic then

	--------------------------------------------------------------------------------
	---@param _SettlerType integer
	---@param _Amount integer
	function MemLib.SettlerType.SetAttractionSlots(_SettlerType, _Amount)
		assert(MemLib.SettlerType.IsValid(_SettlerType))
		assert(type(_Amount) == "number" and _Amount >= 0)
		CLogic.SetEntitiesAttractionUsage(_SettlerType, _Amount)
	end

else

	--------------------------------------------------------------------------------
	---@param _SettlerType integer
	---@param _Amount integer
	function MemLib.EntityType.SetAttractionSlots(_SettlerType, _Amount)
		assert(MemLib.SettlerType.IsValid(_SettlerType))
		assert(type(_Amount) == "number" and _Amount >= 0)
		MemLib.SettlerType.GetMemory(_SettlerType)[136]:SetInt(_Amount)
	end

end

if CppLogic then

	--------------------------------------------------------------------------------
	-- like Logic.FillSettlerCostTable but 0s are left out
	---@param _SettlerType integer
	---@return table
	function MemLib.SettlerType.GetCostTable(_SettlerType)
		local result = {}
		local costs = CppLogic.EntityType.Settler.GetCost(_SettlerType)
		for i = 1, 17 do
			if costs[i] > 0 then
				result[i] = costs[i]
			end
		end
		return result
	end
	--------------------------------------------------------------------------------
	---@param _SettlerType integer
	---@return integer
	function MemLib.SettlerType.GetUpgradeCategory(_SettlerType)
		return CppLogic.EntityType.Settler.GetUpgradeCategory(_SettlerType)
	end

else

	--------------------------------------------------------------------------------
	-- like Logic.FillSettlerCostTable but 0s are left out
	---@param _SettlerType integer
	---@return table
	function MemLib.SettlerType.GetCostTable(_SettlerType)
		return MemLib.Util.GetCostTable(MemLib.SettlerType.GetMemory(_SettlerType):Offset(40))
	end
	--------------------------------------------------------------------------------
	---@param _SettlerType integer
	---@return integer
	function MemLib.SettlerType.GetUpgradeCategory(_SettlerType)
		return MemLib.SettlerType.GetMemory(_SettlerType)[84]:GetInt()
	end

end