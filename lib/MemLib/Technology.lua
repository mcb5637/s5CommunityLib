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
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Entity", "Player", "Util")
end
--------------------------------------------------------------------------------
MemLib.Technology = {}
--------------------------------------------------------------------------------
---@param _Technology integer
---@return userdata|table
function MemLib.Technology.GetMemory(_Technology)
	assert(MemLib.Technology.IsValid(_Technology), "MemLib.Technology.GetModifierMemory: _Technology invalid")
	return MemLib.GetMemory(8758176)[0][13][1][_Technology - 1]
end
--------------------------------------------------------------------------------
---@param _Technology integer
---@return boolean
function MemLib.Technology.IsValid(_Technology)
	local techManager = MemLib.GetMemory(8758176)[0][13]
	return type(_Technology) == "number" and _Technology > 0 and _Technology <= (techManager[2]:GetInt() - techManager[1]:GetInt()) / 4
end
--------------------------------------------------------------------------------
---@param _Technology integer
---@param _Modifier integer
---@return userdata|table
function MemLib.Technology.GetModifierMemory(_Technology, _Modifier)

	local offsets = {
		[Modifiers.Exploration]	=  48,
		[Modifiers.Speed]		=  56,
		[Modifiers.Hitpoints]	=  64,
		[Modifiers.Damage]		=  72,
		[Modifiers.DamageBonus]	=  80,
		[Modifiers.MaxRange]	=  88,
		[Modifiers.MinRange]	=  96,
		[Modifiers.Armor]		= 104,
		[Modifiers.DodgeChance]	= 112,
		[Modifiers.GroupLimit]	= 120,
	}
	local offset = offsets[_Modifier]

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

	local playerState = MemLib.Player.GetState(_PlayerId)
	local techVector = playerState[61]

	MemLib.Entity.GetMemory(techVector[_Technology * 4 + 3]:GetInt())[73]:SetInt(0)
	techVector[_Technology * 4]:SetInt(2)
	techVector[_Technology * 4 + 1]:SetInt(0)
	techVector[_Technology * 4 + 2]:SetInt(0)
	techVector[_Technology * 4 + 3]:SetInt(0)

	local autoResearchStart = playerState[65]
	local autoResearchEnd = playerState[66]
	local amount = (autoResearchEnd:GetInt() - autoResearchStart:GetInt()) / 4 - 1

	for i = 0, amount do
		if autoResearchStart[i]:GetInt() == _Technology then
			local techAtLastIndex = autoResearchEnd[-1]:GetInt()
			autoResearchStart[i]:SetInt(techAtLastIndex)
			local lastIndex = autoResearchEnd:GetInt()
			CUtilMemory.SetPreciseFPU()
			autoResearchEnd:SetInt(lastIndex + (-4))
			return
		end
	end
end
--------------------------------------------------------------------------------
---@param _Technology integer
---@return table
function MemLib.TechnologyGetCostTable(_Technology)
	local technology = MemLib.Technology.GetMemory(_Technology)
	return MemLib.Util.GetCostTable(technology:Offset(3))
end