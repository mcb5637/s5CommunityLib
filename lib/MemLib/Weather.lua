--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Weather
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
MemLib.Weather = {}
--------------------------------------------------------------------------------
---@return integer
function MemLib.Weather.GetCurrentWeatherGfxState()
	return MemLib.GetMemory(8758176)[0][11][10]:GetInt()
end