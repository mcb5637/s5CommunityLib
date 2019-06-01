if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
mcbPacker.require("s5CommunityLib/tables/animTable")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v2.0
-- Ermöglicht es eine Animation eines Entitys gezielt per Script abzuspielen.
-- Dabei wird TaskLists.TL_MILITARY_IDLE jeden Tick gesetzt.
-- Am ersten Tick nach dem Aufruf wird die Animation zurückgesetzt, beim nächsten Tick startet die gesetzte Animation.
-- 
-- Parameter:
-- - id: EntityId des zu animierenden Ziels
-- - anim: Animation, animTable.EntityTypeString.Anim (nicht geprüft)
-- - speed: Animationsgeschwindigkeit als Float, 1.0 normal
-- - back: Rückwärtsabspielen der Animation true/false
-- - funcs: table mit "Animationspunkten" t[x] wird x Ticks nach dem Start der Animation aufgerufen (id, tick, unpack(arg)).
-- 				Gibt t[x] true zurück, wird die Animation beendet. (jedes x optional)
-- - dead: Wird aufgerufen, wenn id vor Animationsende stirbt (id, unpack(arg)). Animation wird danach beendet.
-- - escape: Jeden Tick vor dem Setzen der Animation aufgerufen (id, tick, unpack(arg)).
-- 				Wird true zurückgegeben, wird die Animation beendet. (Optional)
-- 
-- Benötigt:
-- - S5Hook
-- - Trigger-Fix
-- - MemoryManipulation
-- - animTable (empfohlen)
function mcbAnim(id, anim, speed, back, funcs, dead, escape, ...)
	assert(IsValid(id))
	local id = GetID(id)
	local sv = S5Hook.GetEntityMem(id)
	assert(type(anim)=="number")
	assert(type(speed)=="number")
	Logic.SetTaskList(id, TaskLists.TL_MILITARY_IDLE)
	local t = {id=id,anim=anim,speed=speed,back=back,funcs=funcs,t=-1,arg=arg,dead=dead,escape=escape}
	StartSimpleHiResJob(function(t)
		t.t = t.t + 1
		if IsDead(t.id) then
			t.dead(t.id, unpack(t.arg))
			return true
		end
		if t.escape then
			local r, r2 = t.escape(t.id, t.t, unpack(t.arg))
			if r then
				if not r2 then
					Logic.SetTaskList(t.id, TaskLists.TL_MILITARY_IDLE)
					Logic.GroupDefend(t.id)
				end
				return true
			end
		end
		if t.funcs[t.t] then
			if t.funcs[t.t](t.id, t.t, unpack(t.arg)) then
				Logic.SetTaskList(t.id, TaskLists.TL_MILITARY_IDLE)
				Logic.GroupDefend(t.id)
				return true
			end
		end
		Logic.SetTaskList(t.id, TaskLists.TL_MILITARY_IDLE)
		if t.t==0 then
			return
		end
		if not t.sTur then
			t.sTur = Logic.GetCurrentTurn()
		end
		local w = {}
		w = MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CGLBehaviorAnimationEx.Animation", t.anim, w)
		w = MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CGLBehaviorAnimationEx.StartTurn", t.sTur, w)
		w = MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CGLBehaviorAnimationEx.PlayBackwards", t.back and 1 or 0, w)
		w = MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CGLBehaviorAnimationEx.Speed", t.speed, w)
		assert(MemoryManipulation.WriteObj(S5Hook.GetEntityMem(id), w))
	end, t)
	return t
end
