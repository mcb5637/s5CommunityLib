--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Player
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
end
--------------------------------------------------------------------------------
MemLib.Player = {}
--------------------------------------------------------------------------------
---@param _PlayerId integer
---@return userdata|table
function MemLib.Player.StatusGetMemory(_PlayerId)
    assert(MemLib.Player.IsValid(_PlayerId), "MemLib.Player.GetState: _PlayerId invalid")
	return MemLib.GetMemory(MemLib.Offsets.CGLGameLogic.GlobalObject)[0][MemLib.Offsets.CGLGameLogic.PlayerManager][_PlayerId * 2 + 1]
end
--------------------------------------------------------------------------------
---@param _PlayerId integer
---@return boolean
function MemLib.Player.IsValid(_PlayerId)
    return type(_PlayerId) == "number" and _PlayerId >= 0 and _PlayerId <= (CNetwork and 17 or 8)
end
--------------------------------------------------------------------------------
---@param _PlayerId integer
function MemLib.Player.PaydayReset(_PlayerId)
	local playerStatusMemory = MemLib.Player.StatusGetMemory(_PlayerId)
	playerStatusMemory[MemLib.Offsets.CPlayerStatus.CPlayerAttractionHandler][MemLib.Offsets.CPlayerAttractionHandler.PaydayStartTurn]:SetInt(Logic.GetCurrentTurn() - 1)
end
--------------------------------------------------------------------------------
---@param _PlayerId integer
---@param _R integer
---@param _G integer
---@param _B integer
---@param _A integer
function MemLib.Player.SetColor(_PlayerId, _R, _G, _B, _A)

    assert(MemLib.Player.IsValid(_PlayerId), "MemLib.Player.SetColor: _PlayerId invalid")

	_R = _R or 0
	_G = _G or 0
	_B = _B or 0
	_A = _A or 255

	assert(type(_R) == "number", "Memory.Player.SetColor: _R invalid")
	assert(type(_G) == "number", "Memory.Player.SetColor: _G invalid")
	assert(type(_B) == "number", "Memory.Player.SetColor: _B invalid")
	assert(type(_A) == "number", "Memory.Player.SetColor: _A invalid")

	if CNetwork then
		_A = math.max(_A, 17)
		Display.SetPlayerColorMapping(_PlayerId, XNetwork.EXTENDED_RGBAToColorCode(_R, _G, _B, _A))
		return
	end

	local playerColors = MemLib.GetMemory(MemLib.Offsets.CGlobalsBaseEx.GlobalObject)[0][MemLib.Offsets.CGlobalsBaseEx.CPlayerColors]

	-- set GUI color in BGRA
	playerColors[_PlayerId + 1]:SetByte(0, _B)
	playerColors[_PlayerId + 1]:SetByte(1, _G)
	playerColors[_PlayerId + 1]:SetByte(2, _R)
	playerColors[_PlayerId + 1]:SetByte(3, _A)

	-- set unknown color in RGBA (because of matching structure)
	playerColors[_PlayerId + 10]:SetByte(0, _R)
	playerColors[_PlayerId + 10]:SetByte(1, _G)
	playerColors[_PlayerId + 10]:SetByte(2, _B)
	playerColors[_PlayerId + 10]:SetByte(3, _A)

	-- set entity colors
    playerColors[_PlayerId * 4 + 19]:SetFloat(_R / 255)
    playerColors[_PlayerId * 4 + 20]:SetFloat(_G / 255)
    playerColors[_PlayerId * 4 + 21]:SetFloat(_B / 255)
    playerColors[_PlayerId * 4 + 22]:SetFloat(_A / 255)

	-- set minimap color in RGBA
	playerColors[_PlayerId + 55]:SetByte(0, _R)
	playerColors[_PlayerId + 55]:SetByte(1, _G)
	playerColors[_PlayerId + 55]:SetByte(2, _B)
	playerColors[_PlayerId + 55]:SetByte(3, _A)
end