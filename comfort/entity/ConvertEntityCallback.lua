if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- bietet einen callback bei helias bekehrung.
-- 
-- ConvertEntityCallback(id, tid, cb, ...)			id ist helias, tid das ziel, cb wird mit (nid, unpack(arg)) aufgerufen, wenn es eine gab.
-- 
-- Benötigt:
-- - S5Hook
-- - TriggerFix
function ConvertEntityCallback(id, tid, cb, ...)
	SendEvent.HeroConvertSettler(id, tid)
	local d = {id=id,tid=tid,t=Logic.GetTimeMs(), cb=cb, a=arg}
	d.ctr = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, function(d)
		if Logic.GetTimeMs() <= d.t then
			return
		end
		local e = Event.GetEntityID()
		if IsDestroyed(d.id) or Logic.GetCurrentTaskList(d.id)~="TL_CONVERT_SETTLERS" then
			EndJob(d.dtr)
			EndJob(d.tick)
			return true
		end
		if IsDestroyed(d.tid) then
			EndJob(d.dtr)
			EndJob(d.tick)
			return true
		end
		if Logic.GetEntityType(d.tid)~=Logic.GetEntityType(e) then
			return
		end
		if GetPlayer(e)~=GetPlayer(d.id) then
			return
		end
		local ptid, pe = GetPosition(d.tid), GetPosition(e)
		if GetDistance(ptid, pe)>50 then
			return
		end
		d.sus = e
		d.susTurn = Logic.GetTimeMs()
	end, 1, nil, {d})
	d.dtr = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, function(d)
		if Logic.GetTimeMs() <= d.t then
			return
		end
		local e = Event.GetEntityID()
		if d.sus then
			if e==d.tid and d.susTurn==Logic.GetTimeMs() then
				d.cb(d.sus, unpack(d.a))
				EndJob(d.ctr)
				EndJob(d.tick)
				return true
			end
		end
		if IsDestroyed(d.tid) then
			EndJob(d.ctr)
			EndJob(d.tick)
			return true
		end
	end, 1, nil, {d})
	d.tick = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, function(d)
		if Logic.GetTimeMs() <= d.t then
			return
		end
		if IsDestroyed(d.id) or Logic.GetCurrentTaskList(d.id)~="TL_CONVERT_SETTLERS" then
			EndJob(d.dtr)
			EndJob(d.ctr)
			return true
		end
		if IsDestroyed(d.tid) then
			EndJob(d.dtr)
			EndJob(d.ctr)
			return true
		end
	end, 1, nil, {d})
end
