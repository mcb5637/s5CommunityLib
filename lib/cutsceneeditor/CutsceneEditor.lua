if mcbPacker then -- mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/comfort/math/Vector")
end -- mcbPacker.ignore

assert(CppLogic)
--- allows editing cutscenes ingame (requires CppLogic).
--- usage: load required scripts, then call CutsceneEditor.EnterEditor() (from FMA or debugger).
--- type the cutscenes name into the text field or select a existing cutscene to open it.
--- move the camera with keys, the numeric control or click into the screen to use the joystick.
--- create flights and points in the lower screen, and assign position, lookat, func and durations to them.
--- allows to preview the full cutscene or a single flight (func are not called in preview).
--- click on export to select a location to save all cutscenes in memory to.
---
--- note: this is a development tool, it should not be packaged into a map release.
---
--- how do i continue editing a cutscene?
--- - export it into the map, then start the map and open it.
---
--- can i open the old debugger cutscene files?
--- - not directly, only the exported cutscenes can be opened and edited.
CutsceneEditor = {
	Name = "",
	---@type CutScene|nil
	Editing = nil,
	---@type CSFlight|nil
	SelectedFlight = nil,
	---@type CSElement|nil
	SelectedElement = nil,
	---@type table<string, function>
	FuncBackup = {},
	---@type string[]
	CutsceneNames = {}
}

if mcbPacker then -- mcbPacker.ignore
mcbPacker.require("s5CommunityLib/lib/cutsceneeditor/CutsceneEditorUI")
end -- mcbPacker.ignore

---@class CSPos
---@field x number
---@field y number
---@field z number

---@class CSElement
---@field Pos CSPos|nil
---@field PosInTan CSPos|nil
---@field PosOutTan CSPos|nil
---@field LookAt CSPos|nil
---@field LookAtInTan CSPos|nil
---@field LookAtOutTan CSPos|nil
---@field Func string|nil
---@field Time number
---@field Duration number

---@class CSFlight
---@field Elements CSElement[]
---@field Time number

---@class CutScene
---@field Flights CSFlight[]

function CutsceneEditor.Init()
	if LuaDebugger.Log then
		LuaDebugger.Log("CutsceneEditor loaded, remove for release!")
	end
end

---@param name string
---@return CutScene
function CutsceneEditor.LoadCutscene(name)
	---@type CutScene
	local cs = {Flights = {}}
	---@return CSFlight
	local function searchflight(t)
		for _, f in ipairs(cs.Flights) do
			if f.Time == t then
				return f
			end
		end
		local a = {Elements = {}, Time = t}
		table.insert(cs.Flights, a)
		return a
	end
	---@return CSElement
	local function searchelem(t, fl)
		for _, e in ipairs(fl.Elements) do
			if e.Time == t then
				return e
			end
		end
		local a = {Time = t}
		table.insert(fl.Elements, a)
		return a
	end

	local l = CppLogic.UI.GetCutscene(name)
	if not l then
		return cs
	end

	-- build internal format
	for _, fl in ipairs(l.CameraPos.Flights.Element) do
		local f = searchflight(fl.Time)
		for _, el in ipairs(fl.Data.Positios.Element) do
			local e = searchelem(el.Time, f)
			e.Pos = el.Data.Position.Position
			e.PosInTan = el.Data.InTangent.Position
			e.PosOutTan = el.Data.OutTangent.Position
		end
	end
	for _, fl in ipairs(l.CameraLookAt.Flights.Element) do
		local f = searchflight(fl.Time)
		for _, el in ipairs(fl.Data.Positios.Element) do
			local e = searchelem(el.Time, f)
			e.LookAt = el.Data.Position.Position
			e.LookAtInTan = el.Data.InTangent.Position
			e.LookAtOutTan = el.Data.OutTangent.Position
		end
	end
	for _, fl in ipairs(l.LuaFunctions.Flights.Element) do
		local f = searchflight(fl.Time)
		for _, el in ipairs(fl.Data.Element) do
			local e = searchelem(el.Time, f)
			e.Func = el.FuncName
		end
	end

	-- sort flights (should not do anything, but just to be sure...)
	table.sort(cs.Flights, function(a, b)
		return a.Time < b.Time
	end)
	-- sort elements (can be in wrong order, if a element has no pos attached)
	for _, f in ipairs(cs.Flights) do
		table.sort(f.Elements, function(a, b)
			return a.Time < b.Time
		end)
	end

	-- recover durations
	for _, f in ipairs(cs.Flights) do
		local lasttime = nil
		for i = table.getn(f.Elements), 1, -1 do
			if lasttime == nil then
				lasttime = f.Elements[i].Time
				f.Elements[i].Duration = 0
			else
				f.Elements[i].Duration = lasttime - f.Elements[i].Time
				lasttime = f.Elements[i].Time
			end
		end
	end
	return cs
end

---@param name string
---@param cs CutScene
function CutsceneEditor.SaveCutscene(name, cs)
	-- preconvert
	local cstime = 0
	assert(table.getn(cs.Flights) >= 1, "no flights in cutscene")
	for fi, f in ipairs(cs.Flights) do
		local ftime = 0
		---@type CSElement[], CSElement[]
		local pos, lookat = {}, {}

		assert(table.getn(f.Elements) >= 2, "flight " .. fi .. " has not enough points")

		-- time, fill tangent lists
		f.Time = cstime
		for _, e in ipairs(f.Elements) do
			e.Time = ftime
			cstime = cstime + e.Duration
			ftime = ftime + e.Duration
			if e.Pos then
				table.insert(pos, e)
			end
			if e.LookAt then
				table.insert(lookat, e)
			end
		end

		-- pos tangents
		for i = 1, table.getn(pos), 1 do
			local curr = pos[i]
			local prev = pos[i - 1]
			local next = pos[i + 1]
			if not prev then
				prev = curr
			end
			if not next then
				next = curr
			end

			local middle_c_n = (CutsceneEditor.ToVector(curr.Pos) + CutsceneEditor.ToVector(next.Pos)) * 0.5
			local middle_c_p = (CutsceneEditor.ToVector(curr.Pos) + CutsceneEditor.ToVector(prev.Pos)) * 0.5

			local t = middle_c_n - middle_c_p
			t = t:Normalize()
			local p = CutsceneEditor.FromVector(t)
			curr.PosInTan = p
			prev.PosOutTan = p
		end
		pos[1].PosInTan = {x = 1, y = 1, z = 1}
		pos[table.getn(pos)].PosOutTan = {x = 1, y = 1, z = 1}

		-- lookat tangents
		for i = 1, table.getn(lookat) - 1, 1 do
			local curr = lookat[i]
			local next = lookat[i + 1]

			local t = CutsceneEditor.ToVector(next.LookAt) - CutsceneEditor.ToVector(curr.LookAt)
			t = t:Normalize()
			curr.LookAtOutTan = CutsceneEditor.FromVector(t)
			next.LookAtInTan = CutsceneEditor.FromVector(-t)
		end
		lookat[1].PosInTan = {x = 1, y = 1, z = 1}
		lookat[table.getn(lookat)].PosOutTan = {x = 1, y = 1, z = 1}
	end

	-- convert
	local c = {CameraPos = {Flights = {Element = {}}}, CameraLookAt = {Flights = {Element = {}}}, LuaFunctions = {Flights = {Element = {}}}}
	for _, f in ipairs(cs.Flights) do
		local cp = {Time = f.Time, Data = {Positios = {Element = {}}}}
		table.insert(c.CameraPos.Flights.Element, cp)
		local lp = {Time = f.Time, Data = {Positios = {Element = {}}}}
		table.insert(c.CameraLookAt.Flights.Element, lp)
		local fp = {Time = f.Time, Data = {Element = {}}}
		table.insert(c.LuaFunctions.Flights.Element, fp)
		for _, e in ipairs(f.Elements) do
			if e.Pos then
				table.insert(cp.Data.Positios.Element,
				             {Time = e.Time, Data = {Position = {Position = e.Pos}, InTangent = {Position = e.PosInTan}, OutTangent = {Position = e.PosOutTan}}})
			end
			if e.LookAt then
				table.insert(lp.Data.Positios.Element, {
					Time = e.Time,
					Data = {Position = {Position = e.LookAt}, InTangent = {Position = e.LookAtInTan}, OutTangent = {Position = e.LookAtOutTan}}
				})
			end
			if e.Func then
				table.insert(fp.Data.Element, {Time = e.Time, Data = {FuncName = e.Func}})
			end
		end
	end

	CppLogic.UI.SetCutscene(name, c)
end

function CutsceneEditor.EnterEditor()
	Display.SetRenderFogOfWar(0)
	GUI.MiniMap_SetRenderFogOfWar(0)
	GUI.ClearSelection()
	GUI.CancelState()
	XGUIEng.ShowWidget("Cinematic", 1)
	XGUIEng.ShowWidget("Normal", 0)
	XGUIEng.ShowWidget("3dOnScreenDisplay", 0)
	Display.SetRenderSky(1)
	Camera.RotSetFlipBack(0)
	GameCallback_Camera_CalculateZoom(1)
	Camera.StopCameraFlight()
	XGUIEng.ShowAllSubWidgets("Windows", 0)
	gvCamera.DefaultFlag = 0

	Camera.ScrollUpdateZMode(3)
	Display.SetFarClipPlaneMinAndMax(1000000, 0)
	Camera.ZoomSetDistance(0)
	Camera.SetControlMode(1)

	if XGUIEng.IsWidgetExisting("CutsceneEditor") == 0 then
		CutsceneEditor.LoadUI()
	end
	XGUIEng.ShowWidget("CutsceneEditor", 1)
	CutsceneEditor.ToSelect()
	XGUIEng.ShowWidget("CutsceneEditor_OpenUpdateRender", 1)

	XGUIEng.SetText("Cinematic_Text", "")
	XGUIEng.SetText("Cinematic_Headline", "")
	XGUIEng.SetText("CutsceneEditor_ErrorMsg",
	                "Camera keys: WASD directional movement, QE yaw angle, RF Height, TG pitch angle @cr Click and Drag into the main screen: virtual joystick")
end

function CutsceneEditor.ExitEditor()
	XGUIEng.ShowWidget("CutsceneEditor", 0)

	Camera.StopCameraFlight()
	Camera.SetControlMode(0)
	Display.SetRenderSky(0)
	GUI.ActivateSelectionState()
	Camera.RotSetAngle(-45)
	Camera.RotSetFlipBack(1)
	gvCamera.DefaultFlag = 1
	Camera.ScrollUpdateZMode(0)
	XGUIEng.ShowWidget("Cinematic", 0)
	XGUIEng.ShowWidget("Cinematic_Text", 0)
	XGUIEng.ShowWidget("Normal", 1)
	XGUIEng.ShowWidget("3dOnScreenDisplay", 1)
	Display.SetRenderFogOfWar(1)
	GUI.MiniMap_SetRenderFogOfWar(1)

	Camera_InitParams()
end

function CutsceneEditor.ToSelect()
	XGUIEng.ShowAllSubWidgets("CutsceneEditor", 0)
	XGUIEng.ShowWidget("CutsceneEditor_Open", 1)
	XGUIEng.ShowWidget("CutsceneEditor_Close", 1)
	CppLogic.UI.InputCustomWidgetSetFocus("CutsceneEditor_OpenInput", true)
	CutsceneEditor.InitCSList()
end

function CutsceneEditor.Open(text)
	XGUIEng.ShowAllSubWidgets("CutsceneEditor", 0)
	XGUIEng.ShowWidget("CutsceneEditor_Edit", 1)
	XGUIEng.ShowWidget("CutsceneEditor_Close", 1)
	CutsceneEditor.Editing = CutsceneEditor.LoadCutscene(text)
	CutsceneEditor.Name = text
	CutsceneEditor.SelectedFlight = nil
	CutsceneEditor.SelectedElement = nil
	CutsceneEditor.InitFlightList()
	CppLogic.UI.InputCustomWidgetSetFocus("CutsceneEditor_EditCamControl", true)
end

function CutsceneEditor.NumericCamXY(txt, wid, event)
	if event == 0 then
		CutsceneEditor.NumericCamSet()
	elseif event == 2 then
		txt = tonumber(txt) or 0
		return txt >= 0 and Logic.WorldGetSize() + 100 > txt
	end
end
function CutsceneEditor.NumericCamPitch(txt, wid, event)
	if event == 0 then
		CutsceneEditor.NumericCamSet()
	elseif event == 2 then
		txt = tonumber(txt) or 0
		return txt <= 90 and txt >= -90
	end
end
function CutsceneEditor.NumericCamYaw(txt, wid, event)
	if event == 0 then
		CutsceneEditor.NumericCamSet()
	elseif event == 2 then
		txt = tonumber(txt) or 0
		return txt <= 180 and txt > -180
	end
end
function CutsceneEditor.NumericCamSet()
	local x = tonumber(CppLogic.UI.TextInputCustomWidgetGetText("CutsceneEditor_NC_xin"))
	local y = tonumber(CppLogic.UI.TextInputCustomWidgetGetText("CutsceneEditor_NC_yin"))
	local z = tonumber(CppLogic.UI.TextInputCustomWidgetGetText("CutsceneEditor_NC_zin"))
	local pitch = tonumber(CppLogic.UI.TextInputCustomWidgetGetText("CutsceneEditor_NC_pitchin"))
	local yaw = tonumber(CppLogic.UI.TextInputCustomWidgetGetText("CutsceneEditor_NC_yawin"))
	---@diagnostic disable-next-line: param-type-mismatch
	CppLogic.UI.SetCameraData(x, y, z, 0, yaw, pitch)
	CppLogic.UI.InputCustomWidgetSetFocus("CutsceneEditor_EditCamControl", true)
end
function CutsceneEditor.UpdateNumericCam()
	local x, y, z, _, yaw, pitch = CppLogic.UI.GetCameraData()
	if not CutsceneEditor.LastCam or CutsceneEditor.LastCam.x ~= x or CutsceneEditor.LastCam.y ~= y or CutsceneEditor.LastCam.z ~= z or
					CutsceneEditor.LastCam.yaw ~= yaw or CutsceneEditor.LastCam.pitch ~= pitch then
		CutsceneEditor.LastCam = {x = x, y = y, z = z, yaw = yaw, pitch = pitch}
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_NC_xin", tostring(x))
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_NC_yin", tostring(y))
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_NC_zin", tostring(z))
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_NC_pitchin", tostring(pitch))
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_NC_yawin", tostring(yaw))
	end
	local s = XGUIEng.GetBaseWidgetUserVariable("CutsceneEditor_EditCamControl", 0)
	if s ~= CutsceneEditor.LastSpeed then
		CutsceneEditor.LastSpeed = s
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_NC_speedin", tostring(s))
	end
end
function CutsceneEditor.JumpHeightOverTerrain()
	local x, y, z, d, ya, pi = CppLogic.UI.GetCameraData()
	z = CppLogic.Logic.LandscapeGetTerrainHeight({X = x, Y = y}) + 4000
	CppLogic.UI.SetCameraData(x, y, z, d, ya, pi)
	XGUIEng.ShowWidget("CutsceneEditor_OpenUpdateRender", 0)
end
function CutsceneEditor.NumericCamSpeed(txt)
	txt = tonumber(txt) or 0
	XGUIEng.SetBaseWidgetUserVariable("CutsceneEditor_EditCamControl", 0, txt)
end

function CutsceneEditor.InitCSList()
	CutsceneEditor.CutsceneNames = CppLogic.UI.ListCutscenes()
	CppLogic.UI.InitAutoScrollCustomWidget("CutsceneEditor_CSListScroll", table.getn(CutsceneEditor.CutsceneNames))
end

function CutsceneEditor.UpdateCutsceneName()
	local i = XGUIEng.GetBaseWidgetUserVariable(XGUIEng.GetCurrentWidgetID(), 0) + 1
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), "@center " .. CutsceneEditor.CutsceneNames[i])
end

function CutsceneEditor.ActionCutsceneName()
	local i = XGUIEng.GetBaseWidgetUserVariable(XGUIEng.GetCurrentWidgetID(), 0) + 1
	CutsceneEditor.Open(CutsceneEditor.CutsceneNames[i])
end

function CutsceneEditor.InitFlightList()
	CppLogic.UI.InitAutoScrollCustomWidget("CutsceneEditor_FlightScroll", table.getn(CutsceneEditor.Editing.Flights))
	XGUIEng.ShowWidget("CutsceneEditor_Points", CutsceneEditor.SelectedElement and 1 or 0)
	CutsceneEditor.InitPointList()
end

function CutsceneEditor.AddFlight()
	table.insert(CutsceneEditor.Editing.Flights, {Elements = {}, Time = 0})
	CutsceneEditor.InitFlightList()
end

function CutsceneEditor.UpdateFlight()
	local i = XGUIEng.GetBaseWidgetUserVariable(XGUIEng.GetCurrentWidgetID(), 0) + 1
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), "@center flight " .. i)
	XGUIEng.HighLightButton(XGUIEng.GetCurrentWidgetID(), CutsceneEditor.Editing.Flights[i] == CutsceneEditor.SelectedFlight and 1 or 0)
end

function CutsceneEditor.ActionFlight()
	local i = XGUIEng.GetBaseWidgetUserVariable(XGUIEng.GetCurrentWidgetID(), 0) + 1
	CutsceneEditor.SelectedFlight = CutsceneEditor.Editing.Flights[i]
	CutsceneEditor.SelectedElement = nil
	XGUIEng.ShowWidget("CutsceneEditor_Points", 1)
	CutsceneEditor.InitPointList()
end

function CutsceneEditor.RemoveFlight()
	for i = table.getn(CutsceneEditor.Editing.Flights), 1, -1 do
		if CutsceneEditor.Editing.Flights[i] == CutsceneEditor.SelectedFlight then
			table.remove(CutsceneEditor.Editing.Flights, i)
		end
	end
	CutsceneEditor.SelectedFlight = nil
	CutsceneEditor.SelectedElement = nil
	CutsceneEditor.InitFlightList()
end

function CutsceneEditor.FlightUp()
	for k, f in ipairs(CutsceneEditor.Editing.Flights) do
		if f == CutsceneEditor.SelectedFlight then
			if CutsceneEditor.Editing.Flights[k - 1] then
				CutsceneEditor.Editing.Flights[k - 1], CutsceneEditor.Editing.Flights[k] = CutsceneEditor.Editing.Flights[k],
				                                                                           CutsceneEditor.Editing.Flights[k - 1]
			end
			return
		end
	end
end

function CutsceneEditor.FlightDown()
	for k, f in ipairs(CutsceneEditor.Editing.Flights) do
		if f == CutsceneEditor.SelectedFlight then
			if CutsceneEditor.Editing.Flights[k + 1] then
				CutsceneEditor.Editing.Flights[k + 1], CutsceneEditor.Editing.Flights[k] = CutsceneEditor.Editing.Flights[k],
				                                                                           CutsceneEditor.Editing.Flights[k + 1]
			end
			return
		end
	end
end

function CutsceneEditor.InitPointList()
	CppLogic.UI.InitAutoScrollCustomWidget("CutsceneEditor_PointScroll",
	                                       CutsceneEditor.SelectedFlight and table.getn(CutsceneEditor.SelectedFlight.Elements) or 0)
	CutsceneEditor.UpdateElement()
end

function CutsceneEditor.AddPoint()
	table.insert(CutsceneEditor.SelectedFlight.Elements, {Time = 0, Duration = 0})
	CutsceneEditor.InitPointList()
end

function CutsceneEditor.UpdatePoint()
	local i = XGUIEng.GetBaseWidgetUserVariable(XGUIEng.GetCurrentWidgetID(), 0) + 1
	XGUIEng.SetText(XGUIEng.GetCurrentWidgetID(), "@center point " .. i)
	XGUIEng.HighLightButton(XGUIEng.GetCurrentWidgetID(), CutsceneEditor.SelectedFlight.Elements[i] == CutsceneEditor.SelectedElement and 1 or 0)
end

function CutsceneEditor.ActionPoint()
	local i = XGUIEng.GetBaseWidgetUserVariable(XGUIEng.GetCurrentWidgetID(), 0) + 1
	CutsceneEditor.SelectedElement = CutsceneEditor.SelectedFlight.Elements[i]
	CutsceneEditor.UpdateElement()
end

function CutsceneEditor.RemovePoint()
	for i = table.getn(CutsceneEditor.SelectedFlight.Elements), 1, -1 do
		if CutsceneEditor.SelectedFlight.Elements[i] == CutsceneEditor.SelectedElement then
			table.remove(CutsceneEditor.SelectedFlight.Elements, i)
		end
	end
	CutsceneEditor.SelectedElement = nil
	CutsceneEditor.InitPointList()
end

function CutsceneEditor.PointUp()
	for k, f in ipairs(CutsceneEditor.SelectedFlight.Elements) do
		if f == CutsceneEditor.SelectedElement then
			if CutsceneEditor.SelectedFlight.Elements[k - 1] then
				CutsceneEditor.SelectedFlight.Elements[k - 1], CutsceneEditor.SelectedFlight.Elements[k] = CutsceneEditor.SelectedFlight.Elements[k],
				                                                                                           CutsceneEditor.SelectedFlight.Elements[k - 1]
			end
			return
		end
	end
end

function CutsceneEditor.PointDown()
	for k, f in ipairs(CutsceneEditor.SelectedFlight.Elements) do
		if f == CutsceneEditor.SelectedElement then
			if CutsceneEditor.SelectedFlight.Elements[k + 1] then
				CutsceneEditor.SelectedFlight.Elements[k + 1], CutsceneEditor.SelectedFlight.Elements[k] = CutsceneEditor.SelectedFlight.Elements[k],
				                                                                                           CutsceneEditor.SelectedFlight.Elements[k + 1]
			end
			return
		end
	end
end

function CutsceneEditor.UpdateElement()
	if CutsceneEditor.SelectedElement then
		XGUIEng.ShowWidget("CutsceneEditor_PointEdit", 1)
		XGUIEng.HighLightButton("CutsceneEditor_SetCamLoc", CutsceneEditor.SelectedElement.Pos and 1 or 0)
		XGUIEng.HighLightButton("CutsceneEditor_SetLookAt", CutsceneEditor.SelectedElement.LookAt and 1 or 0)
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_FuncInput", CutsceneEditor.SelectedElement.Func or "")
		CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_Dur", tostring(CutsceneEditor.SelectedElement.Duration or 0))
	else
		XGUIEng.ShowWidget("CutsceneEditor_PointEdit", 0)
	end
end

function CutsceneEditor.SetCamPos()
	local x, y, z = CppLogic.UI.GetCameraData()
	CutsceneEditor.SelectedElement.Pos = {x = x, y = y, z = z}
	CutsceneEditor.SelectedElement.PosInTan = nil
	CutsceneEditor.SelectedElement.PosOutTan = nil
	CutsceneEditor.UpdateElement()
end
function CutsceneEditor.ClearCamPos()
	CutsceneEditor.SelectedElement.Pos = nil
	CutsceneEditor.UpdateElement()
end

function CutsceneEditor.SetLookAt()
	local x, y, z, _, yaw, pitch = CppLogic.UI.GetCameraData()
	local distance = 1000
	pitch = math.rad(pitch)
	yaw = math.rad(yaw)
	local dz = -(distance * math.sin(pitch))
	local dxy = (distance * math.cos(pitch))
	local dx = -(dxy * math.sin(yaw))
	local dy = (dxy * math.cos(yaw))
	CutsceneEditor.SelectedElement.LookAt = {x = x + dx, y = y + dy, z = z + dz}
	CutsceneEditor.SelectedElement.LookAtInTan = nil
	CutsceneEditor.SelectedElement.LookAtOutTan = nil
	CutsceneEditor.UpdateElement()
end
function CutsceneEditor.ClearLookAt()
	---@diagnostic disable-next-line: inject-field
	CutsceneEditor.SelectedElement.LookAt = nil
	CutsceneEditor.UpdateElement()
end

function CutsceneEditor.JumpToElement()
	if not CutsceneEditor.SelectedElement.Pos then
		return
	end
	local x = CutsceneEditor.SelectedElement.Pos.x
	local y = CutsceneEditor.SelectedElement.Pos.y
	local z = CutsceneEditor.SelectedElement.Pos.z
	local pitch, yaw, _
	if CutsceneEditor.SelectedElement.LookAt then
		local dx = CutsceneEditor.SelectedElement.LookAt.x - x
		local dy = CutsceneEditor.SelectedElement.LookAt.y - y
		local dz = CutsceneEditor.SelectedElement.LookAt.z - z
		local len = math.sqrt(dx * dx + dy * dy + dz * dz)
		dx = dx / len
		dy = dy / len
		dz = dz / len
		pitch = math.deg(math.asin(-dz))
		yaw = math.deg(math.atan(-dx / dy))
		if dy < 0 then
			yaw = yaw + 180
		end
	else
		_, _, _, _, yaw, pitch = CppLogic.UI.GetCameraData()
	end
	CppLogic.UI.SetCameraData(x, y, z, 0, yaw, pitch)
end

function CutsceneEditor.SetFunc(func)
	if func == "" then
		func = nil
	end
	---@diagnostic disable-next-line: inject-field
	CutsceneEditor.SelectedElement.Func = func
	CppLogic.UI.InputCustomWidgetSetFocus("CutsceneEditor_EditCamControl", true)
end

function CutsceneEditor.SetDuration(txt)
	txt = tonumber(txt)
	CutsceneEditor.SelectedElement.Duration = txt or 0
	CppLogic.UI.InputCustomWidgetSetFocus("CutsceneEditor_EditCamControl", true)
end

function CutsceneEditor.SetDurationFromSpeed(txt)
	txt = tonumber(txt) or 1
	---@type CSElement
	local prevelem
	for i, e in ipairs(CutsceneEditor.SelectedFlight.Elements) do
		if e == CutsceneEditor.SelectedElement then
			prevelem = CutsceneEditor.SelectedFlight.Elements[i + 1]
			break
		end
	end
	if not prevelem then
		CppLogic.UI.InputCustomWidgetSetFocus("CutsceneEditor_EditCamControl", true)
		return
	end
	if not prevelem.Pos or not CutsceneEditor.SelectedElement.Pos then
		return
	end
	CutsceneEditor.SelectedElement.Duration = CutsceneEditor.GetDistance(prevelem.Pos, CutsceneEditor.SelectedElement.Pos) / txt
	CppLogic.UI.TextInputCustomWidgetSetText("CutsceneEditor_Dur", tostring(CutsceneEditor.SelectedElement.Duration or 0))
	CppLogic.UI.InputCustomWidgetSetFocus("CutsceneEditor_EditCamControl", true)
end

---@param p CSPos
---@return Vector
function CutsceneEditor.ToVector(p)
	return Vector.New {p.x, p.y, p.z}
end

---@param v Vector
---@return CSPos
function CutsceneEditor.FromVector(v)
	return {x = v.data[1], y = v.data[2], z = v.data[3]}
end

---@param p1 CSPos
---@param p2 CSPos
---@return number
function CutsceneEditor.GetDistance(p1, p2)
	return (CutsceneEditor.ToVector(p1) - CutsceneEditor.ToVector(p2)):Length()
end

function CutsceneEditor.Preview(flightonly)
	CutsceneEditor.FuncBackup = {}
	local function doback(k, f)
		if CutsceneEditor.FuncBackup[k] then
			return
		end
		CutsceneEditor.FuncBackup[k] = _G[k]
		_G[k] = f
	end
	doback("Cutscene_" .. CutsceneEditor.Name .. "_Finished", CutsceneEditor.PreviewEnded)
	doback("Cutscene_" .. CutsceneEditor.Name .. "_Cancel", CutsceneEditor.PreviewEnded)
	for _, f in ipairs(CutsceneEditor.Editing.Flights) do
		for _, e in ipairs(f.Elements) do
			if e.Func then
				doback("Cutscene_" .. CutsceneEditor.Name .. "_" .. e.Func, function()
				end)
			end
		end
	end

	---@type CutScene
	local cs = CutsceneEditor.Editing
	if flightonly then
		cs = {Flights = {[1] = CutsceneEditor.SelectedFlight}}
	end

	XGUIEng.ShowWidget("CutsceneEditor", 0)
	xpcall(function()
		CutsceneEditor.SaveCutscene(CutsceneEditor.Name, cs)
		Cutscene.Start(CutsceneEditor.Name)
	end, function(msg)
		XGUIEng.SetText("CutsceneEditor_ErrorMsg", msg)
		XGUIEng.ShowWidget("CutsceneEditor", 1)
	end)
end

function CutsceneEditor.PreviewEnded()
	Camera.SetControlMode(1)
	for k, v in pairs(CutsceneEditor.FuncBackup) do
		_G[k] = v
	end
	CutsceneEditor.FuncBackup = {}
	XGUIEng.ShowWidget("CutsceneEditor", 1)
	Camera.StopCameraFlight()
end

function CutsceneEditor.Store()
	xpcall(function()
		CutsceneEditor.SaveCutscene(CutsceneEditor.Name, CutsceneEditor.Editing)
		CppLogic.UI.ExportCutscenes()
	end, function(msg)
		XGUIEng.SetText("CutsceneEditor_ErrorMsg", msg)
	end)
end

AddMapStartCallback("CutsceneEditor.Init")
