--- author:mcb		current maintainer:mcb		v1.0
--- häufig benutzte tor funktionen (öffnen, scließen, abfrage ob geschlossen, einfache jobs)

GateOpenToClosed = {
	[Entities.XD_WallStraightGate] = Entities.XD_WallStraightGate_Closed,
	[Entities.XD_DarkWallStraightGate] = Entities.XD_DarkWallStraightGate_Closed,
	[Entities.XD_PalisadeGate2] = Entities.XD_PalisadeGate1,
	[Entities.XD_DrawBridgeOpen1] = Entities.PB_DrawBridgeClosed1,
	[Entities.XD_DrawBridgeOpen2] = Entities.PB_DrawBridgeClosed2,
}

GateClosedToOpen = {}
for op, cl in pairs(GateOpenToClosed) do
	GateClosedToOpen[cl] = op
end

---öffnet oder schließt ein tor
---@param id number|string tor
---@param close boolean tor schließen
function GateSetClosed(id, close)
	id = GetID(id)
	local ty = Logic.GetEntityType(id)
	if close then
		ty = GateOpenToClosed[ty]
	else
		ty = GateClosedToOpen[ty]
	end
	assert(ty)
	ReplaceEntity(id, ty)
end
---gibt zurück, ob ein tor geschlossen ist
---@param id number|string tor
---@return boolean|nil isClosed geschlossen (nil wenn kein tor)
function GateGetClosed(id)
	id = GetID(id)
	local ty = Logic.GetEntityType(id)
	if GateClosedToOpen[ty] then
		return true
	elseif GateOpenToClosed[ty] then
		return false
	end
end

---startet einen kontinuierlichen check, um ein tor zu öffnen/schließen, basierend auf einem zielentity.
---job beendet sich automatisch, wenn das tor zerstört ist.
---@param gate string tor
---@param check string|number entity dessen entfernung geprüft werden soll
---@param range number entfernung
---@param closeIfInRange boolean schließen wenn nah
function GateCheckStatusNearEntity(gate, check, range, closeIfInRange)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "GateStatusJob_Entity", 1, nil, {gate, check, range, closeIfInRange and 1 or 0})
end
function GateStatusJob_Entity(gate, check, range, closeIfInRange)
	if IsDestroyed(gate) then
		return true
	end
	closeIfInRange = closeIfInRange == 1
	if IsNear(gate, check, range) then
		if GateGetClosed(gate) ~= closeIfInRange then
			GateSetClosed(gate, closeIfInRange)
		end
	else
		if GateGetClosed(gate) == closeIfInRange then
			GateSetClosed(gate, not closeIfInRange)
		end
	end
end

---startet einen kontinuierlichen check, um ein tor zu öffnen/schließen, basierend auf allen entities eines players.
---job beendet sich automatisch, wenn das tor zerstört ist.
---@param gate string tor
---@param check number player dessen entities das tor auslösen sollen
---@param range number entfernung
---@param closeIfInRange boolean schließen wenn nah
function GateCheckStatusNearPlayer(gate, check, range, closeIfInRange)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "GateStatusJob_Player", 1, nil, {gate, check, range, closeIfInRange and 1 or 0})
end
function GateStatusJob_Player(gate, check, range, closeIfInRange)
	if IsDestroyed(gate) then
		return true
	end
	closeIfInRange = closeIfInRange == 1
	local p = GetPosition(gate)
	local n = Logic.GetPlayerEntitiesInArea(check, 0, p.X, p.Y, range, 1, nil)
	if n > 0 then
		if GateGetClosed(gate) ~= closeIfInRange then
			GateSetClosed(gate, closeIfInRange)
		end
	else
		if GateGetClosed(gate) == closeIfInRange then
			GateSetClosed(gate, not closeIfInRange)
		end
	end
end
