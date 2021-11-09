--AutoFixArg

--- author:mcb		current maintainer:mcb		v3.0b                           Dank an Chromix
-- Funktionen anstelle von Funktionsnamen als Trigger
-- Tableindexierung in Funktionsanamen (sowas wie "foo.bar")
-- tables als Trigger-Argumente
-- OOP methoden als Trigger (1. parameter ist objekt, triggername ist methodenname mit : am start (":foo", obj))
-- Trigger-Argumente bei StarteSimpleJob, StartSimpleHiResJob, StartJob, StartHiResJob
-- error-handling (Trigger werden nicht gelöscht!)
-- Warnung, wenn Trigger / HiRes-Trigger zusammen länger als 0.03 sec brauchen (ab da ruckelts!)
-- Fügt Events.SCRIPT_EVENT_LOW_PRIORITY hinzu, für Jobs die komplizierte Berechnungen durchführen, länger brauchen oder unwichtig sind
--   condition bestimmt, ob action diesen tick weiter ausgeführt wird
--   return 		Zeitprüfung, fortgesetzt wenn wieder Rechenzeit zur Verfügung steht
--   return -1 		diesen Job erst nächsten Tick weiter ausführen
--   return 0<t<1 	An diesem Job wird dauerhaft vermerkt, dass er ungefähr t Sekunden läuft
--   beenden über return true! / EndJob
--   StartSimpleLowPriorityJob
--   LowPriorityJobs werden sehr unregelmäßig aufgerufen, solange es mehrere von ihnen gibt
--	Fügt Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY hinzu, funktioniert nur mit S5Hook.HurtEntityTrigger_GetDamage,
--		Event wie normaler Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, ids der soldiers sind austauschbar (da die sterbereihenfolge nicht unbedingt klar ist)
-- Fügt Events.SCRIPT_EVENT_ON_SAVEGAME_LOADED und Events.SCRIPT_EVENT_ON_DO_INITIALIZATION hinzu.
--
-- TriggerFix.ProtectedCall(func, ...)	Ruft eine Funktion geschützt auf, und leitet Fehler an TriggerFix.ShowErrorMessage
-- TriggerFix.ShowErrorMessage(txt)		Standard - Fehlerausgabe (über DebugWindow)
--
-- TriggerFix.AllScriptsLoaded()		Aus der FMA aufrfen, nachdem alle scripte geladen wurden. Initialisiert alle scripte, die das benötigen über Events.SCRIPT_EVENT_ON_DO_INITIALIZATION.
--
-- Für Debugger optimiert:
--   Wenn der Debugger aktiv ist, werden Fehler nicht abgefangen, sondern an den Debugger weitergeleitet
--   Im Debugger-Modus werden weitere Trigger nicht aufgerufen, wenn einer einen Fehler wirft
--
-- Benötigt:
-- 	- CEntity/CppLogic (nur Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY)
--
TriggerFix = {triggers={}, nId=0, idToTrigger={}, currStartTime=0, afterTriggerCB={}, onHackTrigger={}, ShowErrorMessageText={}, xpcallTimeMsg=false, currentEvent=nil,
	ScriptTriggers={}, TriggersToDelete={},
}
TriggerFix_mode = TriggerFix_mode or (LuaDebugger.Log and "Debugger" or "Xpcall")

function TriggerFix.AddTrigger(event, con, act, active, acon, aact, comm)
	if not TriggerFix.triggers[event] then
		TriggerFix.triggers[event] = {}
	end
	local tid = TriggerFix.nId
	TriggerFix.nId = TriggerFix.nId + 1
	if con == "" then
		con = nil
	end
	if type(con)=="string" then
		con = TriggerFix.SplitTableIndexPath(con)
	end
	if type(act)=="string" then
		act = TriggerFix.SplitTableIndexPath(act)
	end
	local t = {event=event, con=con, act=act, active=active, acon=acon or {}, aact=aact or {}, tid=tid, err=nil, time=0, comm=comm}
	table.insert(TriggerFix.triggers[event], t)
	TriggerFix.idToTrigger[tid] = t
	return tid
end

function TriggerFix.RemoveTrigger(tid)
	local t = TriggerFix.idToTrigger[tid]
	if not t then
		return
	end
	if TriggerFix.TriggersToDelete[t.event] then
		table.insert(TriggerFix.TriggersToDelete[t.event], t)
		t.active = 0
		return
	end
	local ev = TriggerFix.triggers[t.event]
	for i=table.getn(ev),1,-1 do
		if ev[i]==t then
			table.remove(ev, i)
		end
	end
	TriggerFix.idToTrigger[tid] = nil
end

function TriggerFix.ExecuteSingleTrigger(t)
	if t.con then
		local ret = TriggerFix.GetTriggerFunc(t.con, t.acon[1])(unpack(t.acon))
		if not ret or ret==0 then
			return nil, true
		end
	end
	return TriggerFix.GetTriggerFunc(t.act, t.aact[1])(unpack(t.aact))
end

function TriggerFix.GetTriggerFunc(f, obj)
	local t = type(f)
	if t=="function" then
		return f
	end
	if t=="string" then
		return _G[f]
	end
	if t=="table" then
		local ta = _G
		if f.object then
			ta = obj
		end
		for _, k in ipairs(f) do
			ta = ta[k]
		end
		return ta
	end
end

function TriggerFix.ExecuteAllTriggersOfEventDebugger(event, cev)
	TriggerFix.currStartTime = XGUIEng.GetSystemTime()
	if not cev then
		cev = TriggerFix.CreateCopyEvent()
		if event==Events.LOGIC_EVENT_ENTITY_HURT_ENTITY then
			TriggerFix.CreateEventHurtIn(cev)
		end
	end
	local prevevent = TriggerFix.currentEvent
	local deleteBack = TriggerFix.TriggersToDelete[event]
	TriggerFix.TriggersToDelete[event] = {}
	local ev = TriggerFix.triggers[event]
	local rem, remi = {}, 1
	for _, t in ipairs(ev) do
		if t.active and t.active~=0 then
			local tim = XGUIEng.GetSystemTime()
			TriggerFix.currentEvent = cev
			local r = TriggerFix.ExecuteSingleTrigger(t)
			t.time=XGUIEng.GetSystemTime()-tim
			if r and r~=0 then
				rem[remi] = t.tid
				remi = remi + 1
			end
		end
	end
	if event==Events.LOGIC_EVENT_ENTITY_HURT_ENTITY then
		TriggerFix.CreateEventHurtOut(cev)
	end
	TriggerFix.TriggersToDelete[event], deleteBack = deleteBack, TriggerFix.TriggersToDelete[event]
	for _,t in ipairs(deleteBack) do
		TriggerFix.RemoveTrigger(t.tid)
	end
	for _,tid in ipairs(rem) do
		TriggerFix.RemoveTrigger(tid)
	end
	for _,f in ipairs(TriggerFix.afterTriggerCB) do
		TriggerFix.currentEvent = cev
		f(event)
	end
	local rtime = XGUIEng.GetSystemTime()-TriggerFix.currStartTime
	if rtime > 0.03 and KeyOf then
		Message("@color:255,0,0 Trigger "..KeyOf(event, Events).." runtime too long: "..rtime)
		if TriggerFix.breakOnRuntimeAlert then
			LuaDebugger.Break()
		end
	end
	TriggerFix.currentEvent = prevevent
end

function TriggerFix.ExecuteAllTriggersOfEventXpcall(event, cev)
	TriggerFix.currStartTime = XGUIEng.GetSystemTime()
	if not cev then
		cev = TriggerFix.CreateCopyEvent()
		if event==Events.LOGIC_EVENT_ENTITY_HURT_ENTITY then
			TriggerFix.CreateEventHurtIn(cev)
		end
	end
	local prevevent = TriggerFix.currentEvent
	local deleteBack = TriggerFix.TriggersToDelete[event]
	TriggerFix.TriggersToDelete[event] = {}
	local ev = TriggerFix.triggers[event]
	local rem, remi = {}, 1
	for _, t in ipairs(ev) do
		if t.active and t.active~=0 then
			local tim = XGUIEng.GetSystemTime()
			local r = nil
			TriggerFix.currentEvent = cev
			xpcall(function()
				r = TriggerFix.ExecuteSingleTrigger(t)
			end, TriggerFix.ShowErrorMessage)
			t.time=XGUIEng.GetSystemTime()-tim
			if r then
				rem[remi] = t.tid
				remi = remi + 1
			end
		end
	end
	if event==Events.LOGIC_EVENT_ENTITY_HURT_ENTITY then
		TriggerFix.CreateEventHurtOut(cev)
	end
	TriggerFix.TriggersToDelete[event], deleteBack = deleteBack, TriggerFix.TriggersToDelete[event]
	for _,t in ipairs(deleteBack) do
		TriggerFix.RemoveTrigger(t.tid)
	end
	for _,tid in ipairs(rem) do
		TriggerFix.RemoveTrigger(tid)
	end
	for _,f in ipairs(TriggerFix.afterTriggerCB) do
		TriggerFix.currentEvent = cev
		f(event)
	end
	local rtime = XGUIEng.GetSystemTime()-TriggerFix.currStartTime
	if rtime > 0.03 and TriggerFix.xpcallTimeMsg and KeyOf then
		Message("@color:255,0,0 Trigger "..KeyOf(event, Events).." runtime too long: "..rtime)
	end
	TriggerFix.currentEvent = prevevent
end

function TriggerFix.ShowErrorMessage(txt)
	if CppLogic then
		CppLogic.API.Log("TriggerFix error catched: "..txt)
	end
	Message("@color:255,0,0 Err:")
	Message(txt)
	table.insert(TriggerFix.ShowErrorMessageText, txt)
	if table.getn(TriggerFix.ShowErrorMessageText) > 15 then
		table.remove(TriggerFix.ShowErrorMessageText)
	end
	XGUIEng.ShowWidget("DebugWindow", 1)
end
GUIUpdate_UpdateDebugInfo = function()
	local txt = ""
	for k,v in ipairs(TriggerFix.ShowErrorMessageText) do
		txt = txt.." @color:255,0,0 "..v.." @cr "
	end
	XGUIEng.SetText("DebugWindow", txt)
end

function TriggerFix.SplitTableIndexPath(s)
	if string.sub(s, 1, 1)==":" then
		local r = TriggerFix.SplitTableIndexPath(string.sub(s, 2))
		if type(r)=="string" then
			r = {r}
		end
		r.object = true
		return r
	end
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


function TriggerFix.HackTrigger()
	if not unpack{true} then
		unpack = function(t, i)
			i = i or 1
			if i <= table.getn(t) then
				return t[i], unpack(t, i+1)
			end
		end
	end
	TriggerFix.RequestTrigger = Trigger.RequestTrigger
	Trigger.RequestTrigger = function(typ, con, act, active, acon, aact)
		return TriggerFix.AddTrigger(typ, con, act, active, acon, aact)
	end
	TriggerFix.UnrequestTrigger = Trigger.UnrequestTrigger
	Trigger.UnrequestTrigger = function(tid)
		if TriggerFix.idToTrigger[tid] then
			return TriggerFix.RemoveTrigger(tid)
		end
	end
	TriggerFix.DisableTrigger = Trigger.DisableTrigger
	Trigger.DisableTrigger = function(tid)
		if TriggerFix.idToTrigger[tid] then
			TriggerFix.idToTrigger[tid].active = 0
			return true
		end
	end
	TriggerFix.EnableTrigger = Trigger.EnableTrigger
	Trigger.EnableTrigger = function(tid)
		if TriggerFix.idToTrigger[tid] then
			TriggerFix.idToTrigger[tid].active = 1
			return true
		end
	end
	TriggerFix.IsTriggerEnabled = Trigger.IsTriggerEnabled
	Trigger.IsTriggerEnabled = function(tid)
		if TriggerFix.idToTrigger[tid] then
			return TriggerFix.idToTrigger[tid].active
		end
	end
	TriggerFix.event = {}
	for k,v in pairs(Event) do
		TriggerFix.event[k] = v
	end
	for k,v in pairs(TriggerFix.event) do
		local name = k	-- upvalue, muss aber sowieso nach jedem laden neu initialisiert werden
		Event[name] = function()
			if TriggerFix.currentEvent and TriggerFix.currentEvent[name] then
				if TriggerFix.currentEvent.light  then
					local ori = TriggerFix.event[name]()
					if ori ~= 0 then
						return ori
					end
				end
				return TriggerFix.currentEvent[name]
			end
			return TriggerFix.event[name]()
		end
	end
	setmetatable(Event, {
		__index = function(_, name)
			if TriggerFix.currentEvent then
				return TriggerFix.currentEvent[name]
			end
		end,
		__newindex = function(_, name, val)
			assert(not TriggerFix.event[name])
			TriggerFix.currentEvent[name] = val
		end
	})
	for ev,id in pairs(TriggerFix.ScriptTriggers) do
		Events[ev] = id
	end
	for _,f in ipairs(TriggerFix.onHackTrigger) do
		f()
	end
end

function TriggerFix.AddScriptTrigger(name)
	assert(not Events[name])
	TriggerFix.ScriptTriggers[name] = name
	Events[name] = name
	if not TriggerFix.triggers[name] then
		TriggerFix.triggers[name] = {}
	end
end

function TriggerFix.CreateCopyEvent()
	local cev = {light=true}
	for k,v in pairs(TriggerFix.event) do
		local a = v()
		if a ~= 0 then
			cev[k] = a
		end
	end
	return cev
end

function TriggerFix.CreateEmptyEvent()
	local cev = {}
	for k,v in pairs(TriggerFix.event) do
		cev[k] = 0
	end
	return cev
end

function TriggerFix.CreateEventHurtIn(cev)

end
function TriggerFix.CreateEventHurtInCppLogic(cev)
	cev.Damage, cev.AttackSource, cev.GetPlayerID = CppLogic.Logic.HurtEntityGetDamage()
end
function TriggerFix.CreateEventHurtInCEntity(cev)
	cev.Damage = CEntity.TriggerGetDamage()
end

function TriggerFix.CreateEventHurtOut(cev)

end
function TriggerFix.CreateEventHurtOutCppLogic(cev)
	CppLogic.Logic.HurtEntitySetDamage(cev.Damage)
end
function TriggerFix.CreateEventHurtOutCEntity(cev)
	CEntity.TriggerSetDamage(cev.Damage)
end

function TriggerFix.ProtectedCall(func, ...)
	if LuaDebugger.Log then
		return func(unpack(arg))
	end
	local r = nil
	xpcall(function()
		r = {func(unpack(arg))}
	end, function(err)
		TriggerFix.ShowErrorMessage("protectedCall: "..err)
	end)
	return unpack(r)
end

function TriggerFix.CheckTriggerRuntime()
	local ct = nil
	for _,t in pairs(TriggerFix.idToTrigger) do
		if not ct or ct.time < t.time then
			ct = t
		end
	end
	return ct
end

function TriggerFix.AllScriptsLoaded()
	TriggerFix_action(Events.SCRIPT_EVENT_ON_DO_INITIALIZATION, TriggerFix.CreateEmptyEvent())
end

function TriggerFix.Init()
	TriggerFix_action = TriggerFix["ExecuteAllTriggersOfEvent"..TriggerFix_mode]
	TriggerFix.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
	Mission_OnSaveGameLoaded = function()
		TriggerFix.HackTrigger()
		if TriggerFix.Mission_OnSaveGameLoaded then
			TriggerFix.Mission_OnSaveGameLoaded()
		end
		TriggerFix_action(Events.SCRIPT_EVENT_ON_SAVEGAME_LOADED, TriggerFix.CreateEmptyEvent())
	end
	TriggerFix.HackTrigger()
	for _,event in ipairs{
		Events.LOGIC_EVENT_DIPLOMACY_CHANGED, Events.LOGIC_EVENT_ENTITY_CREATED, Events.LOGIC_EVENT_ENTITY_DESTROYED,
		Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY,
		Events.LOGIC_EVENT_EVERY_SECOND, Events.LOGIC_EVENT_EVERY_TURN, Events.LOGIC_EVENT_GOODS_TRADED,
		Events.LOGIC_EVENT_RESEARCH_DONE, Events.LOGIC_EVENT_TRIBUTE_PAID, Events.LOGIC_EVENT_WEATHER_STATE_CHANGED,
	} do
		if not TriggerFix.triggers[event] then
			TriggerFix.triggers[event] = {}
		end
		TriggerFix.RequestTrigger(event, nil, "TriggerFix_action", 1, nil, {event})
	end
	if not TriggerFix.triggers[Events.LOGIC_EVENT_ENTITY_HURT_ENTITY] then
		TriggerFix.triggers[Events.LOGIC_EVENT_ENTITY_HURT_ENTITY] = {}
	end
	TriggerFix.entityHurtEntityBaseTriggerId = TriggerFix.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "TriggerFix_action", 1, nil, {Events.LOGIC_EVENT_ENTITY_HURT_ENTITY})
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
	TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_SAVEGAME_LOADED")
	TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_DO_INITIALIZATION")
	if CEntity then
		TriggerFix.CreateEventHurtIn = TriggerFix.CreateEventHurtInCEntity
		TriggerFix.CreateEventHurtOut = TriggerFix.CreateEventHurtOutCEntity
	end
end
TriggerFix.Init()


TriggerFix.LowPriorityJob = {next = 1}
function TriggerFix.LowPriorityJob.RunTrigger(t)
	while true do
		if XGUIEng.GetSystemTime()-TriggerFix.currStartTime >= (0.03 - (t.needTime or 0.005)) then
			return true
		end
		local r, c = TriggerFix.ExecuteSingleTrigger(t)
		if not r and c then
			return
		end
		if r then
			return nil, r
		end
	end
end

function TriggerFix.LowPriorityJob.Run()
	local ev = TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY]
	while true do
		local t = ev[TriggerFix.LowPriorityJob.next]
		if not t then
			TriggerFix.LowPriorityJob.next = 1
			return
		end
		local nt, r = TriggerFix.LowPriorityJob.RunTrigger(t)
		if r==-1 then
			TriggerFix.LowPriorityJob.next = TriggerFix.LowPriorityJob.next + 1
			r = nil
		end
		if type(r)=="number" then
			t.needTime = r
			r = nil
		end
		if r then
			TriggerFix.RemoveTrigger(t.tid)
		end
		if nt then
			TriggerFix.LowPriorityJob.next = 1
			return
		end
	end
end

function TriggerFix.LowPriorityJob.Init()
	TriggerFix.AddScriptTrigger("SCRIPT_EVENT_LOW_PRIORITY")
	if not TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY] then
		TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY] = {}
	end
	table.insert(TriggerFix.afterTriggerCB, function(event)
		if event ~= Events.LOGIC_EVENT_EVERY_TURN then
			return
		end
		if not TriggerFix.triggers[Events.SCRIPT_EVENT_LOW_PRIORITY][1] then
			return
		end
		TriggerFix.LowPriorityJob.Run()
	end)
	StartSimpleLowPriorityJob = function(f, ...)
		return Trigger.RequestTrigger(Events.SCRIPT_EVENT_LOW_PRIORITY, nil, f, 1, nil, arg)
	end
end
TriggerFix.LowPriorityJob.Init()

TriggerFix.KillTrigger = {}

function TriggerFix.KillTrigger.Init()
	TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY")
	--table.insert(TriggerFix.afterTriggerCB, TriggerFix.KillTrigger.AfterTriggerCB)
end
function TriggerFix.KillTrigger.AfterTriggerCB(event)
	if event ~= Events.LOGIC_EVENT_ENTITY_HURT_ENTITY then
		return
	end
	if not CppLogic or CEntity then
		return
	end
	TriggerFix.KillTrigger.Run()
end

function TriggerFix.KillTrigger.Run()
	local id = Event.GetEntityID2()
	if IsDead(id) then
		return
	end
	local dmg = CppLogic.Logic.HurtEntityGetDamage()
	local attackedsol = nil
	if CppLogic.Entity.IsSoldier(id) then
		attackedsol = id
		id = CppLogic.Entity.Settler.GetLeaderOfSoldier(id)
	end
	if Logic.IsLeader(id)==1 and Logic.LeaderGetNumberOfSoldiers(id)>=1 then
		local solth = CppLogic.Entity.Leader.GetTroopHealth(id)
		local solph = CppLogic.EntityType.GetMaxHealth(Logic.LeaderGetSoldiersType(id))
		if solth == -1 then
			solth = (Logic.LeaderGetNumberOfSoldiers(id)) * solph
		end
		local sols = {Logic.GetSoldiersAttachedToLeader(id)}
		table.remove(sols, 1)
		for i=table.getn(sols),2,-1 do -- move attacked soldier to first
			if (sols[i]==attackedsol) then
				table.remove(sols, i)
				table.insert(sols, 1, attackedsol)
			end
		end
		local newsolh = solth - dmg
		for i,sol in ipairs(sols) do
			if ((Logic.LeaderGetNumberOfSoldiers(id)-i) * solph) > newsolh then
				local t = TriggerFix.CreateEmptyEvent()
				t.GetEntityID1 = Event.GetEntityID1()
				t.GetEntityID2 = sol
				TriggerFix_action(Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY, t)
			else
				break
			end
		end
		dmg = math.max(0, -newsolh)
	end
	if Logic.GetEntityHealth(id) <= dmg then
		local t = TriggerFix.CreateEmptyEvent()
		t.GetEntityID1 = Event.GetEntityID1()
		t.GetEntityID2 = id
		TriggerFix_action(Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY, t)
	end
end
TriggerFix.KillTrigger.Init()

function AddMapStartCallback(f, ...)
	Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_DO_INITIALIZATION, nil, f, 1, nil, arg)
end

function AddMapStartAndSaveLoadedCallback(f, ...)
	Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_DO_INITIALIZATION, nil, f, 1, nil, arg)
	Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_SAVEGAME_LOADED, nil, f, 1, nil, arg)
end

function AddSaveLoadedCallback(f, ...)
	Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_SAVEGAME_LOADED, nil, f, 1, nil, arg)
end
