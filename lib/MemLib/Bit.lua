--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Bit
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
MemLib.Bit = {}
--------------------------------------------------------------------------------
if CUtilMemory then

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
	function MemLib.Bit.And(_Value1, _Value2) return CUtilBit32.BitAnd(_Value1, _Value2) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.ARShift(_Amount, _Value) return CUtilBit32.BitAShR(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.LRotate(_Amount, _Value) return CUtilBit32.BitRoL(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.LShift(_Amount, _Value) return CUtilBit32.BitShL(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Value integer
	---@return integer
	function MemLib.Bit.Not(_Value) return CUtilBit32.BitNot(_Value) end

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
	function MemLib.Bit.Or(_Value1, _Value2) return CUtilBit32.BitOr(_Value1, _Value2) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.RRotate(_Amount, _Value) return CUtilBit32.BitRoR(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.RShift(_Amount, _Value) return CUtilBit32.BitShR(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
	function MemLib.Bit.Xor(_Value1, _Value2) return CUtilBit32.BitXor(_Value1, _Value2) end

elseif S5Hook then

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
    function MemLib.Bit.And(_Value1, _Value2) return S5Hook.BitAnd(_Value1, _Value2) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.ARShift(_Amount, _Value) return S5Hook.BitAShR(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.LRotate(_Amount, _Value) return S5Hook.BitRoL(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.LShift(_Amount, _Value) return S5Hook.BitShL(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Value integer
	---@return integer
	function MemLib.Bit.Not(_Value) return S5Hook.BitNot(_Value) end

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
	function MemLib.Bit.Or(_Value1, _Value2) return S5Hook.BitOr(_Value1, _Value2) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.RRotate(_Amount, _Value) return S5Hook.BitRoR(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.RShift(_Amount, _Value) return S5Hook.BitShR(_Amount, _Value) end

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
	function MemLib.Bit.Xor(_Value1, _Value2) return S5Hook.BitXor(_Value1, _Value2) end

else

	if mcbPacker then
		mcbPacker.require("s5CommunityLib/Lib/MemLib/LAU")
	else
		MemLib.Load("LAU")
	end

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
	function MemLib.Bit.And(_Value1, _Value2) return MemLib.LAU.ToNumber(MemLib.LAU.And(MemLib.LAU.ToTable(_Value1), MemLib.LAU.ToTable(_Value2))) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
	function MemLib.Bit.ARShift(_Amount, _Value) return MemLib.LAU.ToNumber(MemLib.LAU.RShift(_Amount, MemLib.LAU.ToTable(_Value))) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
    function MemLib.Bit.LRotate(_Amount, _Value) return MemLib.LAU.ToNumber(MemLib.LAU.LRotate(_Amount, MemLib.LAU.ToTable(_Value))) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
    function MemLib.Bit.LShift(_Amount, _Value) return MemLib.LAU.ToNumber(MemLib.LAU.LShift(_Amount, MemLib.LAU.ToTable(_Value))) end

	--------------------------------------------------------------------------------
	---@param _Value integer
	---@return integer
    function MemLib.Bit.Not(_Value) return MemLib.LAU.ToNumber(MemLib.LAU.Not(MemLib.LAU.ToTable(_Value))) end

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
    function MemLib.Bit.Or(_Value1, _Value2) return MemLib.LAU.ToNumber(MemLib.LAU.Or(MemLib.LAU.ToTable(_Value1), MemLib.LAU.ToTable(_Value2))) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
    function MemLib.Bit.RRotate(_Amount, _Value) return MemLib.LAU.ToNumber(MemLib.LAU.RRotate(_Amount, MemLib.LAU.ToTable(_Value))) end

	--------------------------------------------------------------------------------
	---@param _Amount integer
	---@param _Value integer
	---@return integer
    function MemLib.Bit.RShift(_Amount, _Value) return MemLib.LAU.ToNumber(MemLib.LAU.RShift(_Amount, MemLib.LAU.ToTable(_Value))) end

	--------------------------------------------------------------------------------
	---@param _Value1 integer
	---@param _Value2 integer
	---@return integer
    function MemLib.Bit.Xor(_Value1, _Value2) return MemLib.LAU.ToNumber(MemLib.LAU.Xor(MemLib.LAU.ToTable(_Value1), MemLib.LAU.ToTable(_Value2))) end

end