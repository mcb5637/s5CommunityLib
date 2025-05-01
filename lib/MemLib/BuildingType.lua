--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.BuildingType
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/EntityType")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Util")
    mcbPacker.require("s5CommunityLib/Tables/BehaviorProperties")
    mcbPacker.require("s5CommunityLib/Tables/EntityTypeClasses")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("EntityType", "Util", "Tables/BehaviorProperties", "Tables/EntityTypeClasses")
end
--------------------------------------------------------------------------------
MemLib.BuildingType = {}
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return userdata|table
function MemLib.BuildingType.GetMemory(_BuildingType)
    assert(MemLib.BuildingType.IsValid(_BuildingType), "MemLib.BuildingType.GetMemory: _BuildingType invalid")
    return MemLib.EntityType.GetMemory(_BuildingType)
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return boolean
function MemLib.BuildingType.IsValid(_BuildingType)
    local entityTypeVtp = MemLib.EntityType.GetMemory(_BuildingType)[0]:GetInt()
    return entityTypeVtp == EntityTypeClasses.CGLBuildingProps or entityTypeVtp == EntityTypeClasses.CBridgeProperties
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return integer
function MemLib.BuildingTypeGetArmor(_BuildingType)
	return MemLib.BuildingType.GetMemory(_BuildingType)[103]:GetInt()
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return number
---@return number
---@return number
---@return number
function MemLib.BuildingType.GetAproachAndDoorPosition(_BuildingType)
    local buildingTypeMemory = MemLib.BuildingType.GetMemory(_BuildingType)
    return buildingTypeMemory[7]:GetFloat(), buildingTypeMemory[8]:GetFloat(), buildingTypeMemory[46]:GetFloat(), buildingTypeMemory[47]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return integer
function MemLib.BuildingType.GetMaxNumWorkers(_BuildingType)
	return MemLib.BuildingType.GetMemory(_BuildingType)[42]:GetInt()
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return number
function MemLib.BuildingType.GetUpgradeAmount(_BuildingType)
	return 0.1 / MemLib.BuildingType.GetMemory(_BuildingType)[80]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return number
---@return number
---@return number
---@return number
function MemLib.BuildingType.GetBuildBlockArea(_BuildingType)
	local buildingTypeMemory = MemLib.BuildingType.GetMemory(_BuildingType)
	return buildingTypeMemory[38]:GetFloat(), buildingTypeMemory[39]:GetFloat(), buildingTypeMemory[40]:GetFloat(), buildingTypeMemory[41]:GetFloat()
end
--------------------------------------------------------------------------------
-- like Logic.FillBuildingCostTable but 0s are left out
---@param _BuildingType integer
---@return table
function MemLib.BuildingType.GetConstructionCostTable(_BuildingType)
	return MemLib.Util.GetCostTable(MemLib.BuildingType.GetMemory(_BuildingType):Offset(56))
end
--------------------------------------------------------------------------------
-- like Logic.FillBuildingUpgradeCostTable but 0s are left out
---@param _BuildingType integer
---@return table
function MemLib.BuildingType.GetUpgradeCostTable(_BuildingType)
	return MemLib.Util.GetCostTable(MemLib.BuildingType.GetMemory(_BuildingType):Offset(81))
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return integer?
function MemLib.BuildingType.GetMineAmount(_BuildingType)

	local mineBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_BuildingType, BehaviorProperties.CMineBehaviorProperties)

	if mineBehaviorProps then
		return mineBehaviorProps[4]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return number?
function MemLib.BuildingType.GetRefineAmount(_BuildingType)

	local refinerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_BuildingType, BehaviorProperties.CResourceRefinerBehaviorProperties)

	if refinerBehaviorProps then
		return refinerBehaviorProps[5]:GetFloat()
	end
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return integer?
function MemLib.BuildingType.GetRefineResourceType(_BuildingType)

	local refinerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_BuildingType, BehaviorProperties.CResourceRefinerBehaviorProperties)

	if refinerBehaviorProps then
		return refinerBehaviorProps[4]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _BuildingType integer
---@return integer?
function MemLib.BuildingType.SetRefineResourceType(_BuildingType)

	local refinerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_BuildingType, BehaviorProperties.CResourceRefinerBehaviorProperties)

	if refinerBehaviorProps then
		return refinerBehaviorProps[4]:GetInt()
	end
end
--------------------------------------------------------------------------------
if CLogic then

	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@return integer
	function MemLib.BuildingType.GetAttractionSlots(_BuildingType)
		assert(MemLib.BuildingType.IsValid(_BuildingType))
		return CLogic.GetBuildingsAttractionLimit(_BuildingType)
	end
	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@param _Amount integer
	function MemLib.BuildingType.SetAttractionSlots(_BuildingType, _Amount)
		assert(MemLib.BuildingType.IsValid(_BuildingType))
		assert(type(_Amount) == "number" and _Amount >= 0)
		CLogic.SetBuildingsAttractionLimit(_BuildingType, _Amount)
	end
	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@return integer?
	function MemLib.BuildingType.SetMineAmount(_BuildingType, _Amount)
		assert(MemLib.BuildingType.IsValid(_BuildingType))
		assert(type(_Amount) == "number" and _Amount >= 0)
		CLogic.SetMinedResourcesValue(_BuildingType, _Amount)
	end
	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@param _Amount integer
	function MemLib.BuildingType.SetRefineAmount(_BuildingType, _Amount)
		assert(MemLib.BuildingType.IsValid(_BuildingType))
		assert(type(_Amount) == "number" and _Amount >= 0)
		CLogic.SetRefinedResourcesValue(_BuildingType, _Amount)
	end

else

	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@return integer
	function MemLib.BuildingType.GetAttractionSlots(_BuildingType)
		return MemLib.BuildingType.GetMemory(_BuildingType)[44]:GetInt()
	end
	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@param _Amount integer
	function MemLib.BuildingType.SetAttractionSlots(_BuildingType, _Amount)
		MemLib.BuildingType.GetMemory(_BuildingType)[44]:SetInt(_Amount)
	end
	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@return integer?
	function MemLib.BuildingType.SetMineAmount(_BuildingType)

		local mineBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_BuildingType, BehaviorProperties.CMineBehaviorProperties)

		if mineBehaviorProps then
			return mineBehaviorProps[4]:GetInt()
		end
	end
	--------------------------------------------------------------------------------
	---@param _BuildingType integer
	---@return number?
	---@return integer?
	function MemLib.BuildingType.SetRefineAmount(_BuildingType)

		local refinerBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_BuildingType, BehaviorProperties.CResourceRefinerBehaviorProperties)

		if refinerBehaviorProps then
			return refinerBehaviorProps[5]:GetFloat(), refinerBehaviorProps[4]:GetInt()
		end
	end

end