if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/entity/TargetFilter")
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/pos/IsInCone")
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/comfort/other/PredicateHelper")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
mcbPacker.require("s5CommunityLib/comfort/entity/SightLine")
end --mcbPacker.ignore


--- author:mcb		current maintainer:mcb		v0.1b
-- Einfache möglichkeit um wachposten zu realisieren.
-- 
-- - GuardPost.AddGuard(ids, range, cone, targets, checkSightLine, callback, deadcallback, ...)			erzeugt einen/mehrere wachen.
-- - ids			eine id/scriptname oder ein table von mehreren, die wachen.
-- - range			sichtreichweite der wachen.
-- - cone			der winkel von der richtung der wache in dem bemerkt wird (2 seitig).
-- - targets		ein table mit zielen, oder playern (mit targets.player gesetzt), oder nil für alle feinde der ersten wache (zum zeitpunkt des aufrufes).
-- - checkSightLine	true oder ein table mit entities, prüft sichtlinien (true benötigt hook).
-- - callback		func(id, tid, unpack(arg))		wird aufgerufen, wenn die wache etwas bemerkt, id ist die wache, tid das bemerkte ziel.
-- - deadcallback	func(unpack(arg)) oder nil		wird aufgerufen, wenn alle wachen tot sind (optional).
-- gibt der callback true zurück, wird der job beendet.
-- 
-- Benötigt:
-- - TargetFilter (Zielprüfung)
-- - GetDistance
-- - IsInCone
-- - TriggerFix
-- - S5Hook (optional, verbessert erkennung)
-- - PredicateHelper (nur bei Hook)
-- - MemoryManipulation (nur bei Hook)
GuardPost = {}

function GuardPost.AddGuard(ids, range, cone, targets, checkSightLine, callback, deadcallback, ...)
	if type(ids)~="table" then
		ids = {ids}
	end
	for i=table.getn(ids),1,-1 do
		if IsDead(ids[i]) then
			table.remove(ids, i)
		end
	end
	assert(IsAlive(ids[1]), "no valid guard")
	assert(range > 0)
	if not targets then
		targets = {player=true}
		local l = GetPlayer(ids[1])
		for i=1,8 do
			if Logic.GetDiplomacyState(l, i)==Diplomacy.Hostile then
				table.insert(targets, i)
			end
		end
	end
	local t = {
		ids = ids,
		range = range,
		cone = cone,
		targets = targets,
		callback = callback,
		deadcallback = deadcallback,
		checkSightLine = checkSightLine,
		arg = arg,
	}
	if S5Hook then
		t.CheckArea = GuardPost.CheckAreaHook
	else
		t.CheckArea = GuardPost.CheckAreaNoHook
	end
	return StartSimpleHiResJob("GuardPost.Job", t), t
end

function GuardPost.Job(t)
	for i=table.getn(t.ids),1,-1 do
		local id = GetID(t.ids[i])
		if IsDead(id) then
			table.remove(t.ids, i)
		else
			local r = Logic.GetEntityOrientation(id)
			if t.targets.player then
				if t.CheckArea(t, id, r) then
					return true
				end
			else
				for j=table.getn(t.targets),1,-1 do
					local tid = GetID(t.targets[j])
					if IsDead(tid) then
						table.remove(t.targets, j)
					elseif GetDistance(id, tid)<= t.range and GuardPost.CheckEntity(t, id, r, GetPosition(id), tid) then
						return true
					end
				end
			end
		end
	end
	if not t.ids[1] then
		if t.deadcallback then
			t.deadcallback(unpack(t.arg))
		end
		return true
	end
end

function GuardPost.CheckAreaHook(t, id, r)
	local p = GetPosition(id)
	for tid in S5Hook.EntityIterator(Predicate.OfAnyPlayer(unpack(t.targets)), PredicateHelper.GetETypePredicate(TargetFilter.EntityTypeArray), Predicate.InCircle(p.X, p.Y, t.range)) do
		if GuardPost.CheckEntity(t, id, r, p, tid) then
			return true
		end
	end
end

function GuardPost.CheckAreaNoHook(t, id, r)
	local p = GetPosition(id)
	for _,pl in ipairs(t.targets) do
		local data = {Logic.GetPlayerEntitiesInArea(pl, 0, p.X, p.Y, t.range, 16)}
		table.remove(data, 1)
		for _,tid in ipairs(data) do
			if GuardPost.CheckEntity(t, id, r, p, tid) then
				return true
			end
		end
	end
end

function GuardPost.CheckEntity(t, id, r, p, tid)
	if IsInCone(tid, p, r, t.cone) and GuardPost.IsValidTarget(tid) then
		if not t.checkSightLine or SightLine.CheckVisibility(p, GetPosition(tid), type(t.checkSightLine)=="table" and t.checkSightLine) then
			if t.callback(id, tid, unpack(t.arg)) then
				return true
			end
		end
	end
end

function GuardPost.IsValidTarget(id)
	return TargetFilter.IsValidTarget(id, nil, nil)
end
