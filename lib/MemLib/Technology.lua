--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Technology
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Entity")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Player")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Util")
    mcbPacker.require("s5CommunityLib/Tables/Modifiers")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Entity", "Player", "Util", "Tables/Modifiers")
end
--------------------------------------------------------------------------------
MemLib.Technology = {}
--------------------------------------------------------------------------------
---@param _Technology integer
---@return userdata|table
function MemLib.Technology.GetMemory(_Technology)
	assert(MemLib.Technology.IsValid(_Technology), "MemLib.Technology.GetModifierMemory: _Technology invalid")
	return MemLib.GetMemory(MemLib.Offsets.CGLGameLogic.GlobalObject)[0][MemLib.Offsets.CGLGameLogic.TechManager][MemLib.Offsets.TechManager.VectorStart][_Technology - 1]
end
--------------------------------------------------------------------------------
if XNetwork.Manager_IsNATReady then

	--------------------------------------------------------------------------------
	---@param _Technology integer
	---@return boolean
	function MemLib.Technology.IsValid(_Technology)
		local techManager = MemLib.GetMemory(MemLib.Offsets.CGLGameLogic.GlobalObject)[0][MemLib.Offsets.CGLGameLogic.TechManager]
		local lastValidIndex = MemLib.LAU.ToNumber((MemLib.LAU.ToTable(techManager[MemLib.Offsets.TechManager.VectorStart + 1]:GetInt()) - techManager[MemLib.Offsets.TechManager.VectorStart]:GetInt()) / 4)
		return type(_Technology) == "number" and _Technology > 0 and _Technology <= lastValidIndex
	end

else

	--------------------------------------------------------------------------------
	---@param _Technology integer
	---@return boolean
	function MemLib.Technology.IsValid(_Technology)
		local techManager = MemLib.GetMemory(MemLib.Offsets.CGLGameLogic.GlobalObject)[0][MemLib.Offsets.CGLGameLogic.TechManager]
		local vectorStart = techManager[MemLib.Offsets.TechManager.VectorStart]:GetInt()
		local vectorEnd = techManager[MemLib.Offsets.TechManager.VectorStart + 1]:GetInt()
		MemLib.ArmPreciseFPU()
		MemLib.SetPreciseFPU()
		local lastValidIndex = (vectorEnd - vectorStart) / 4
		MemLib.DisarmPreciseFPU()
		return type(_Technology) == "number" and _Technology > 0 and _Technology <= lastValidIndex
	end

end
--------------------------------------------------------------------------------
---@param _Technology integer
---@param _Modifier integer
---@return userdata|table
function MemLib.Technology.GetModifierMemory(_Technology, _Modifier)
	local offset = MemLib.Offsets.Modifiers[_Modifier]
	assert(offset, "MemLib.Technology.GetModifierMemory: _Modifier invalid")
	return MemLib.Technology.GetMemory(_Technology)[offset]
end
--------------------------------------------------------------------------------
---@param _Technology integer
---@param _Modifier integer
---@return number
function MemLib.Technology.GetModifierValue(_Technology, _Modifier)
	return MemLib.Technology.GetModifierMemory(_Technology, _Modifier):GetFloat()
end
--------------------------------------------------------------------------------
---@param _Technology integer
---@param _Modifier integer
---@param _Value integer
function MemLib.Technology.SetModifierValue(_Technology, _Modifier, _Value)
	assert(type(_Value) == "number", "MemLib.Technology.SetModifierValue: _Value invalid")
	return MemLib.Technology.GetModifierMemory(_Technology, _Modifier):SetFloat(_Value)
end
--------------------------------------------------------------------------------
---@param _PlayerId integer
---@param _Technology integer
function MemLib.Technology.CancelResearch(_PlayerId, _Technology)
	assert(MemLib.Technology.IsValid(_Technology), "MemLib.Technology.CancelResearch: _Technology invalid")

	local playerState = MemLib.Player.StatusGetMemory(_PlayerId)
	local playerTechManagerOffset = MemLib.Offsets.CPlayerStatus.PlayerTechManager
	local playerTechManagerTable = MemLib.Offsets.PlayerTechManager
	local techVector = playerState[playerTechManagerOffset + playerTechManagerTable.TechVectorStart]
	local technology4 = _Technology * 4

	MemLib.Entity.GetMemory(techVector[technology4 + 3]:GetInt())[73]:SetInt(0)
	techVector[technology4]:SetInt(2)
	techVector[technology4 + 1]:SetInt(0)
	techVector[technology4 + 2]:SetInt(0)
	techVector[technology4 + 3]:SetInt(0)

	local autoResearchStartMemory = playerState[playerTechManagerOffset + playerTechManagerTable.AutoResearchVectorStart]
	local autoResearchEndMemory = playerState[playerTechManagerOffset + playerTechManagerTable.AutoResearchVectorStart + 1]
	local autoResearchStart = autoResearchStartMemory:GetInt()
	local autoResearchEnd = autoResearchEndMemory:GetInt()
	MemLib.ArmPreciseFPU()
	MemLib.SetPreciseFPU()
	local amount = (autoResearchEnd - autoResearchStart) / 4 - 1

	for i = 0, amount do
		if autoResearchStartMemory[i]:GetInt() == _Technology then
			local techAtLastIndex = autoResearchEndMemory[-1]:GetInt()
			autoResearchStartMemory[i]:SetInt(techAtLastIndex)
			local lastIndex = autoResearchEndMemory:GetInt()
			MemLib.ArmPreciseFPU()
			MemLib.SetPreciseFPU()
			lastIndex = lastIndex - 4
			autoResearchEndMemory:SetInt(lastIndex)
			return
		end
	end
	--MemLib.DisarmPreciseFPU() is eigher done by GetInt or unnesseccary
end
--------------------------------------------------------------------------------
---@param _Technology integer
---@return table
function MemLib.TechnologyGetCostTable(_Technology)
	local technology = MemLib.Technology.GetMemory(_Technology)
	return MemLib.Util.GetCostTable(technology:Offset(3))
end