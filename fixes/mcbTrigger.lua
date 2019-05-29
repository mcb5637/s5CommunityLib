
--- author:mcb		current maintainer:mcb		v2.3b                           Dank an Chromix
-- Funktionen anstelle von Funktionsnamen als Trigger
-- Tableindexierung in Funktionsanamen (sowas wie "foo.bar")
-- tables als Trigger-Argumente
-- Trigger-Argumente bei StarteSimpleJob, StartSimpleHiResJob, StartJob, StartHiResJob
-- error-handling (Trigger werden nicht gelöscht!)
-- Warnung, wenn Trigger / HiRes-Trigger zusammen länger als 0.03 sec brauchen (ab da ruckelts!)
-- Fügt Events.LowPriorityJob hinzu, für Jobs die komplizierte Berechnungen durchführen, länger brauchen oder unwichtig sind
--   condition bestimmt, ob action diesen tick weiter ausgeführt wird
--   return 		Zeitprüfung, fortgesetzt wenn wieder Rechenzeit zur Verfügung steht
--   return -1 		diesen Job erst nächsten Tick weiter ausführen
--   return 0<t<1 	An diesem Job wird dauerhaft vermerkt, dass er ungefähr t Sekunden läuft
--   beenden über return true! / EndJob
--   StartSimpleLowPriorityJob
--   LowPriorityJobs werden sehr unregelmäßig aufgerufen, solange es mehrere von ihnen gibt
--	Fügt Events.OnEntityKillsEntity hinzu, funktioniert nur mit S5Hook.HurtEntityTrigger_GetDamage,
--		Event wie normaler Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, ids stimmen nicht unbedingt bei leader/soldier
--
-- mcbTrigger.protectedCall(func, ...)	Ruft eine Funktion geschützt auf, und leitet Fehler an mcbTrigger.err
-- mcbTrigger.err(txt)					Standard - Fehlerausgabe (über DebugWindow)
--
-- Für Debugger optimiert:
--   Wenn der Debugger aktiv ist, werden Fehler nicht abgefangen, sondern an den Debugger weitergeleitet
--   Im Debugger-Modus werden weitere Trigger nicht aufgerufen, wenn einer einen Fehler wirft
--
-- Benötigt:
-- 	- S5Hook (nur Events.OnEntityKillsEntity)
--
mcbTrigger = {triggers={}, nId=0, idToTrigger={}, currStartTime=0, afterTriggerCB={}, onHackTrigger={}, errtext={}, xpcallTimeMsg=false, currentEvent=nil}
mcbTrigger_mode = mcbTrigger_mode or (LuaDebugger.Log and "Debugger" or "Xpcall")

function mcbTrigger.add(event, con, act, active, acon, aact, comm)
	if not mcbTrigger.triggers[event] then
		mcbTrigger.triggers[event] = {}
	end
	local tid = mcbTrigger.nId
	mcbTrigger.nId = mcbTrigger.nId + 1
	if con == "" then
		con = nil
	end
	if type(con)=="string" then
		con = mcbTrigger.splitString(con)
	end
	if type(act)=="string" then
		act = mcbTrigger.splitString(act)
	end
	local t = {event=event, con=con, act=act, active=active, acon=acon or {}, aact=aact or {}, tid=tid, err=nil, time=0, comm=comm}
	table.insert(mcbTrigger.triggers[event], t)
	mcbTrigger.idToTrigger[tid] = t
	return tid
end

function mcbTrigger.remove(tid)
	local t = mcbTrigger.idToTrigger[tid]
	local ev = mcbTrigger.triggers[t.event]
	for i=table.getn(ev),1,-1 do
		if ev[i]==t then
			table.remove(ev, i)
		end
	end
	mcbTrigger.idToTrigger[tid] = nil
end

function mcbTrigger.fireSingleFunc(t)
	if t.con then
		local ret = mcbTrigger.getFunc(t.con)(unpack(t.acon))
		if not ret or ret==0 then
			return nil, true
		end
	end
	return mcbTrigger.getFunc(t.act)(unpack(t.aact))
end

function mcbTrigger.getFunc(f)
	local t = type(f)
	if t=="function" then
		return f
	end
	if t=="string" then
		return _G[f]
	end
	if t=="table" then
		local ta = _G
		for _, k in ipairs(f) do
			ta = ta[k]
		end
		return ta
	end
end

function mcbTrigger.fireTriggerDebugger(event, cev)
	mcbTrigger.currStartTime = XGUIEng.GetSystemTime()
	if not cev then
		cev = {}
		for k,v in pairs(mcbTrigger.event) do
			cev[k] = v()
		end
	end
	local ev = mcbTrigger.triggers[event]
	local rem, remi = {}, 1
	for _, t in ipairs(ev) do
		if t.active and t.active~=0 then
			local tim = XGUIEng.GetSystemTime()
			mcbTrigger.currentEvent = cev
			local r = mcbTrigger.fireSingleFunc(t)
			t.time=XGUIEng.GetSystemTime()-tim
			if r and r~=0 then
				rem[remi] = t.tid
				remi = remi + 1
			end
		end
	end
	for _,tid in ipairs(rem) do
		mcbTrigger.remove(tid)
	end
	for _,f in ipairs(mcbTrigger.afterTriggerCB) do
		mcbTrigger.currentEvent = cev
		f(event)
	end
	local rtime = XGUIEng.GetSystemTime()-mcbTrigger.currStartTime
	if rtime > 0.03 and IstDrin then
		Message("@color:255,0,0 Trigger "..IstDrin(event, Events).." runtime too long: "..rtime)
	end
end

function mcbTrigger.fireTriggerXpcall(event, cev)
	mcbTrigger.currStartTime = XGUIEng.GetSystemTime()
	if not cev then
		cev = {}
		for k,v in pairs(mcbTrigger.event) do
			cev[k] = v()
		end
	end
	local ev = mcbTrigger.triggers[event]
	local rem, remi = {}, 1
	for _, t in ipairs(ev) do
		if t.active and t.active~=0 then
			local tim = XGUIEng.GetSystemTime()
			local r = nil
			mcbTrigger.currentEvent = cev
			xpcall(function()
				r = mcbTrigger.fireSingleFunc(t)
			end, mcbTrigger.err)
			t.time=XGUIEng.GetSystemTime()-tim
			if r then
				rem[remi] = t.tid
				remi = remi + 1
			end
		end
	end
	for _,tid in ipairs(rem) do
		mcbTrigger.remove(tid)
	end
	for _,f in ipairs(mcbTrigger.afterTriggerCB) do
		mcbTrigger.currentEvent = cev
		f(event)
	end
	local rtime = XGUIEng.GetSystemTime()-mcbTrigger.currStartTime
	if rtime > 0.03 and mcbTrigger.xpcallTimeMsg and IstDrin then
		Message("@color:255,0,0 Trigger "..IstDrin(event, Events).." runtime too long: "..rtime)
	end
end

function mcbTrigger.err(txt)
	if S5Hook then
		S5Hook.Log("mcbTrigger error catched: "..txt)
	end
	Message("@color:255,0,0 Err:")
	Message(txt)
	table.insert(mcbTrigger.errtext, txt)
	if table.getn(mcbTrigger.errtext) > 15 then
		table.remove(mcbTrigger.errtext)
	end
	XGUIEng.ShowWidget("DebugWindow", 1)
end
GUIUpdate_UpdateDebugInfo = function()
	local txt = ""
	for k,v in ipairs(mcbTrigger.errtext) do
		txt = txt.." @color:255,0,0 "..v.." @cr "
	end
	XGUIEng.SetText("DebugWindow", txt)
end

function mcbTrigger.splitString(s)
	if not string.find(s, ".", nil, true) then
		return s
	end
	local t = {}
	local find, i = true, nil
	while true do
		i, i, find, s = string.find(s, "^([%w_]+)%.([%w_.]+)$")
		table.insert(t, find)
		if not string.find(s, ".", nil, true) then
			table.insert(t, s)
			return t
		end
	end
end


function mcbTrigger.hackTrigger()
	if not unpack{true} then
		unpack = function(t, i)
			i = i or 1
			if i <= table.getn(t) then
				return t[i], unpack(t, i+1)
			end
		end
	end
	mcbTrigger.RequestTrigger = Trigger.RequestTrigger
	Trigger.RequestTrigger = function(typ, con, act, active, acon, aact)
		return mcbTrigger.add(typ, con, act, active, acon, aact)
	end
	mcbTrigger.UnrequestTrigger = Trigger.UnrequestTrigger
	Trigger.UnrequestTrigger = function(tid)
		if mcbTrigger.idToTrigger[tid] then
			return mcbTrigger.remove(tid)
		end
	end
	mcbTrigger.DisableTrigger = Trigger.DisableTrigger
	Trigger.DisableTrigger = function(tid)
		if mcbTrigger.idToTrigger[tid] then
			mcbTrigger.idToTrigger[tid].active = 0
			return true
		end
	end
	mcbTrigger.EnableTrigger = Trigger.EnableTrigger
	Trigger.EnableTrigger = function(tid)
		if mcbTrigger.idToTrigger[tid] then
			mcbTrigger.idToTrigger[tid].active = 1
			return true
		end
	end
	mcbTrigger.IsTriggerEnabled = Trigger.IsTriggerEnabled
	Trigger.IsTriggerEnabled = function(tid)
		if mcbTrigger.idToTrigger[tid] then
			return mcbTrigger.idToTrigger[tid].active
		end
	end
	mcbTrigger.event = {}
	for k,v in pairs(Event) do
		mcbTrigger.event[k] = v
	end
	for k,v in pairs(mcbTrigger.event) do
		local name = k	-- upvalue, muss aber sowieso nach jedem laden neu initialisiert werden
		Event[name] = function()
			return mcbTrigger.currentEvent[name]
		end
	end
	for _,f in ipairs(mcbTrigger.onHackTrigger) do
		f()
	end
end

function mcbTrigger.protectedCall(func, ...)
	if LuaDebugger.Log then
		return func(unpack(arg))
	end
	local r = nil
	xpcall(function()
		r = {func(unpack(arg))}
	end, function(err)
		mcbTrigger.err("protectedCall: "..err)
	end)
	return unpack(r)
end

function mcbTrigger.init()
	mcbTrigger_action = mcbTrigger["fireTrigger"..mcbTrigger_mode]
	mcbTrigger.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
	Mission_OnSaveGameLoaded = function()
		mcbTrigger.hackTrigger()
		mcbTrigger.Mission_OnSaveGameLoaded()
	end
	mcbTrigger.hackTrigger()
	for _,event in ipairs{
		Events.LOGIC_EVENT_DIPLOMACY_CHANGED, Events.LOGIC_EVENT_ENTITY_CREATED, Events.LOGIC_EVENT_ENTITY_DESTROYED,
		Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY,
		Events.LOGIC_EVENT_EVERY_SECOND, Events.LOGIC_EVENT_EVERY_TURN, Events.LOGIC_EVENT_GOODS_TRADED,
		Events.LOGIC_EVENT_RESEARCH_DONE, Events.LOGIC_EVENT_TRIBUTE_PAID, Events.LOGIC_EVENT_WEATHER_STATE_CHANGED,
	} do
		if not mcbTrigger.triggers[event] then
			mcbTrigger.triggers[event] = {}
		end
		mcbTrigger.RequestTrigger(event, nil, "mcbTrigger_action", 1, nil, {event})
	end
	if not mcbTrigger.triggers[Events.LOGIC_EVENT_ENTITY_HURT_ENTITY] then
		mcbTrigger.triggers[Events.LOGIC_EVENT_ENTITY_HURT_ENTITY] = {}
	end
	mcbTrigger.entityHurtEntityBaseTriggerId = mcbTrigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "mcbTrigger_action", 1, nil, {Events.LOGIC_EVENT_ENTITY_HURT_ENTITY})
	StartSimpleJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, f, 1, nil, arg)
	end
	StartSimpleHiResJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, f, 1, nil, arg)
	end
	StartJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "Condition_"..f, "Action_"..f, 1, arg, arg)
	end
	StartHiResJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "Condition_"..f, "Action_"..f, 1, arg, arg)
	end
end
mcbTrigger.init()


mcbTrigger.lpj = {next = 1}
function mcbTrigger.lpj.runTrigger(t)
	while true do
		if XGUIEng.GetSystemTime()-mcbTrigger.currStartTime >= (0.03 - (t.needTime or 0.005)) then
			return true
		end
		local r, c = mcbTrigger.fireSingleFunc(t)
		if not r and c then
			return
		end
		if r then
			return nil, r
		end
	end
end

function mcbTrigger.lpj.run()
	local ev = mcbTrigger.triggers[Events.LowPriorityJob]
	while true do
		local t = ev[mcbTrigger.lpj.next]
		if not t then
			mcbTrigger.lpj.next = 1
			return
		end
		local nt, r = mcbTrigger.lpj.runTrigger(t)
		if r==-1 then
			mcbTrigger.lpj.next = mcbTrigger.lpj.next + 1
			r = nil
		end
		if type(r)=="number" then
			t.needTime = r
			r = nil
		end
		if r then
			mcbTrigger.remove(t.tid)
		end
		if nt then
			mcbTrigger.lpj.next = 1
			return
		end
	end
end

function mcbTrigger.lpj.init()
	Events.LowPriorityJob = "mcb_lpj"
	if not mcbTrigger.triggers[Events.LowPriorityJob] then
		mcbTrigger.triggers[Events.LowPriorityJob] = {}
	end
	table.insert(mcbTrigger.afterTriggerCB, function(event)
		if event ~= Events.LOGIC_EVENT_EVERY_TURN then
			return
		end
		if not mcbTrigger.triggers[Events.LowPriorityJob][1] then
			return
		end
		mcbTrigger.lpj.run()
	end)
	table.insert(mcbTrigger.onHackTrigger, function()
		Events.LowPriorityJob = "mcb_lpj"
	end)
	StartSimpleLowPriorityJob = function(f, ...)
		return Trigger.RequestTrigger(Events.LowPriorityJob, nil, f, 1, nil, arg)
	end
end
mcbTrigger.lpj.init()

mcbTrigger.ktr = {}

function mcbTrigger.ktr.init()
	Events.OnEntityKillsEntity = "mcb_kill"
	if not mcbTrigger.triggers[Events.OnEntityKillsEntity] then
		mcbTrigger.triggers[Events.OnEntityKillsEntity] = {}
	end
	table.insert(mcbTrigger.afterTriggerCB, function(event)
		if event ~= Events.LOGIC_EVENT_ENTITY_HURT_ENTITY then
			return
		end
		if not S5Hook or not S5Hook.HurtEntityTrigger_GetDamage then
			return
		end
		if not mcbTrigger.triggers[Events.OnEntityKillsEntity][1] then
			S5Hook.HurtEntityTrigger_Reset()
			return
		end
		mcbTrigger.ktr.run()
		S5Hook.HurtEntityTrigger_Reset()
	end)
	table.insert(mcbTrigger.onHackTrigger, function()
		Events.OnEntityKillsEntity = "mcb_kill"
	end)
end

function mcbTrigger.ktr.run()
	local id = Event.GetEntityID2()
	local dmg = S5Hook.HurtEntityTrigger_GetDamage()
	if MemoryManipulation.IsSoldier(id) then
		id = MemoryManipulation.GetLeaderOfSoldier(id)
	end
	if Logic.IsLeader(id)==1 and Logic.LeaderGetNumberOfSoldiers(id)>=1 then
		local solth = MemoryManipulation.GetLeaderTroopHealth(id)
		local solph = MemoryManipulation.GetEntityTypeMaxHealth(Logic.LeaderGetSoldiersType(id))
		local currSolHealth = solth - ((Logic.LeaderGetNumberOfSoldiers(id)-1) * solph)
		if currSolHealth <= dmg then
			mcbTrigger["fireTrigger"..mcbTrigger_mode](Events.OnEntityKillsEntity, mcbTrigger.currentEvent)
		end
		return
	end
	if Logic.GetEntityHealth(id) <= dmg then
		mcbTrigger["fireTrigger"..mcbTrigger_mode](Events.OnEntityKillsEntity, mcbTrigger.currentEvent)
	end
end
mcbTrigger.ktr.init()
