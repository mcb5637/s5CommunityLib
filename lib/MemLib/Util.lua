--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Util
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
-- here belongs everything that cant really be assigned or doesnt deserve its own namespace (yet)
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
end
--------------------------------------------------------------------------------
MemLib.Util = {}
--------------------------------------------------------------------------------
---@param _ResourceType integer
---@return boolean
function MemLib.Util.ResourceTypeIsValid(_ResourceType)
	return type(_ResourceType) == "number" and _ResourceType > 0 and _ResourceType <= 17
end
--------------------------------------------------------------------------------
---@param _CostInfoMemory userdata
---@return table
function MemLib.Util.GetCostTable(_CostInfoMemory)
	local costTable = {}
	for i = 1, 17 do
		local cost = _CostInfoMemory[i]:GetFloat()
		if cost > 0 then
			costTable[i] = cost
		end
	end
	return costTable
end