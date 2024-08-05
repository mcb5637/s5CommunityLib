if mcbPacker then -- mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/comfort/entity/IsEntityOfType")
mcbPacker.require("s5CommunityLib/comfort/pos/IsValidPosition")
end -- mcbPacker.ignore

--mcbPacker.deprecated

---author:mcb		current maintainer:mcb		v0.1
---@diagnostic disable: deprecated
---@deprecated
SnipeSelection = {
	---@type nil|fun():boolean ->endstate
	OnClick = nil,
	---@type nil|fun()
	OnCancel = nil,
	---@type fun()
	ActivateCommand = nil,
	Command = "SnipeCommand"
}

---select a position
---@param onconfirm fun(p:Position)
---@param checkpos nil|fun(p:Position):boolean -> accept
---@param oncancel fun()
function SnipeSelection.SelectPos(onconfirm, checkpos, oncancel)
	SnipeSelection.Start(function()
		local x, y = GUI.Debug_GetMapPositionUnderMouse()
		local p = {X = x, Y = y}
		if not IsValidPosition(p) then
			return false
		end
		if checkpos and not checkpos(p) then
			return false
		end
		onconfirm(p)
		return true
	end, oncancel)
end

---select a entity
---@param onconfirm fun(eid:number)
---@param checkentity nil|fun(eid:number):boolean -> accept
---@param oncancel fun()
function SnipeSelection.SelectEntity(onconfirm, checkentity, oncancel)
	SnipeSelection.Start(function()
		local id = GUI.GetEntityAtPosition(GUI.GetMousePosition())
		if IsDestroyed(id) then
			return false
		end
		if checkentity and not checkentity(id) then
			return false
		end
		onconfirm(id)
		return true
	end, oncancel)
end

---do it yourself selection
---@param onclick fun():boolean ->endstate
---@param oncancel fun()
function SnipeSelection.Start(onclick, oncancel)
	SnipeSelection.OnClick = onclick
	SnipeSelection.OnCancel = oncancel
	SnipeSelection.Command = "SnipeCommand"
	SnipeSelection.ActivateCommand = GUI.ActivateSnipeCommandState
	if IsEntityOfType(GUI.GetSelectedEntity(), Entities.PU_Hero10) then
		SnipeSelection.ActivateCommand = GUI.ActivateShurikenCommandState
		SnipeSelection.Command = "ShurikenCommand"
	end
	SnipeSelection.ActivateCommand()
end

---cancels active selection
function SnipeSelection.Stop()
	if SnipeSelection.OnCancel then
		SnipeSelection.OnCancel()
	end
	SnipeSelection.OnClick = nil
	SnipeSelection.OnCancel = nil
	GUI.CancelState()
end

function SnipeSelection.Tick()
	if SnipeSelection.OnClick then
		if GUI.GetCurrentStateName() ~= SnipeSelection.Command then
			if SnipeSelection.OnClick() then
				SnipeSelection.OnCancel = nil
				SnipeSelection.Stop()
			else
				SnipeSelection.ActivateCommand()
			end
		end
	end
end

function SnipeSelection.Init()
	SnipeSelection.GameCallback_Escape = GameCallback_Escape
	GameCallback_Escape = function()
		SnipeSelection.GameCallback_Escape()
		SnipeSelection.Stop()
	end
	StartSimpleHiResJob("SnipeSelection.Tick")
	AddSaveLoadedCallback("SnipeSelection.Stop")
end

AddMapStartCallback("SnipeSelection.Init")
