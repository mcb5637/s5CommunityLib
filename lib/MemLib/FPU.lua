--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib FPU
-- author: RobbiTheFox, mcb
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
end
--------------------------------------------------------------------------------
function MemLib.ArmPreciseFPU() end
function MemLib.DisarmPreciseFPU() end
--------------------------------------------------------------------------------
if CUtilMemory then

	function MemLib.SetPreciseFPU()
		CUtilMemory.SetPreciseFPU()
	end

elseif S5Hook then

	function MemLib.SetPreciseFPU()
		S5Hook.SetPreciseFPU()
	end

elseif CppLogic then

	function MemLib.SetPreciseFPU()
		CppLogic.Memory.SetFPU()
	end

elseif XNetwork.Manager_IsNATReady then

	function MemLib.SetPreciseFPU() end

else

	if mcbPacker then
		mcbPacker.require("s5CommunityLib/Lib/MemLib/SV")
		mcbPacker.require("s5CommunityLib/Lib/MemLib/LAU")
	else
		MemLib.Load("SV", "LAU")
	end

	MemLib.SV.FPUAddress = MemLib.LAU.ToNumber(MemLib.LAU.ToTable(Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, 67)) + 47 * 4)
	Logic.SetEntityScriptingValue(MemLib.SV.AddressEntity, 1, 6063185)

	-- Vanilla: Call to enable MemLib.SetPreciseFPU()
	--
	-- Important: Call MemLib.DisarmPresiceFPU() in the same gametick. Otherwise the game might crash!
	function MemLib.ArmPreciseFPU()
		Logic.SetEntityScriptingValue(MemLib.SV.AddressEntity, -58, MemLib.SV.FPUAddress)
	end

	-- Sets 64bit precision on the FPU, allows accurate calculation in Lua with numbers exceeding 16mil.
	-- However most calls to engine functions will undo this. Therefore call directly before doing a calculation in Lua and don't call anything else until you're done.
	--
	-- Vanilla: You have to first call MemLib.ArmPreciseFPU() for the setting to work. After your calculations, but still in the same gametick, you need do call MemLib.DisarmPresiceFPU() to reset. Otherwise the game might crash.
	--
	-- Background: The vtp of AddressEntity is manipulated to redirect a call to the engine function which sets the FPU. While the manipulation is armed, most operations on this entity are therefore very dangerous! Avoid using the EntityIterator, while armed!
	--
	-- Can be ignored, if CUtilMemory or S5Hook are available.
	function MemLib.SetPreciseFPU()
		Logic.GetSector(MemLib.SV.AddressEntity)
	end

	-- Vanilla: Call resets MemLib.ArmPreciseFPU and disables MemLib.SetPreciseFPU.
	function MemLib.DisarmPreciseFPU()
		Logic.SetEntityScriptingValue(MemLib.SV.AddressEntity, -58, 7791564)
	end

end