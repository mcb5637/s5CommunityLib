if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
end --mcbPacker.ignore

--- author:mcb		currentMaintainer:mcb		v1.1
-- Fixt das problem, das der LOGIC_EVENT_ENTITY_HURT_ENTITY trigger nicht aufgerufen wird, wenn der angreifer nicht mehr valid ist
-- und stellt informationen über das schaden verursachende projekil zur verfügung.
-- Ermöglicht außerdem, mehrere effectCreated/ProjectileHit callbacks zu verwenden.
-- 
-- TriggerFixExtHurtEntity.AddEffectCreatedCallback(func)		Fügt einen effectCreated callback hinzu.
-- TriggerFixExtHurtEntity.RemoveEffectCreatedCb(func)	Entfernt einen effectCreated callback.
-- 
-- TriggerFixExtHurtEntity.AddProjectileHitCb(func)		Fügt einen ProjectileHit callback hinzu.
-- TriggerFixExtHurtEntity.RemoveProjectileHitCb(func)	Entfernt einen ProjectileHit callback.
-- 
-- TriggerFixExtHurtEntity.HurtTrigger_GetProjectileInfo()			Nur aus dem LOGIC_EVENT_ENTITY_HURT_ENTITY trigger aufrufen!
-- 														Gibt informationen über das verwendete projektil zurück.
-- 														{
-- 															effectType,
-- 															playerId,
-- 															attackerPlayer,
-- 															startPos,
-- 															targetPos,
-- 															attackerId,
-- 															targetId,
-- 															damage,
-- 															radius,
-- 															effectId,
-- 															isHookCreated,
-- 														}
-- 
-- TriggerFixExtHurtEntity.HurtTrigger_GetEntityInfo()				Nur aus dem LOGIC_EVENT_ENTITY_HURT_ENTITY trigger aufrufen!
-- 														Gibt informationen über das bomben-entity zurück.
-- 														{
--															tick,
--															attackerId,
--															attackerPlayer,
--															attackerType,
--														}
-- 														
-- 
-- Benötigt:
-- - S5Hook (neuester, mit hurt callback)
-- - S5HookLoader
-- - TriggerFix
-- 
TriggerFixExtHurtEntity = {projectiles={}, currentProjectile={}, createdCbs={}, hitCbs={}, currentEntity={}}

function TriggerFixExtHurtEntity.InternalEffectCreatedCallback(effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId, isHookCreated)
	if creatorType == 7816856 then
		TriggerFixExtHurtEntity.projectiles[effectId] = {
			effectType = effectType,
			playerId = playerId,
			attackerPlayer = GetPlayer(attackerId),
			startPos = {X=startPosX, Y=startPosY},
			targetPos = {X=targetPosX,Y=targetPosY},
			attackerId = attackerId,
			targetId = targetId,
			damage = damage,
			radius = radius,
			effectId = effectId,
			isHookCreated = isHookCreated,
		}
	elseif creatorType ~= 7790912 then
		LuaDebugger.Log("unknown effect created: "..creatorType)
	end
	for _,f in ipairs(TriggerFixExtHurtEntity.createdCbs) do
		TriggerFix.ProtectedCall(f, effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId, isHookCreated)
	end
end

function TriggerFixExtHurtEntity.AddEffectCreatedCallback(func)
	table.insert(TriggerFixExtHurtEntity.createdCbs, func)
end

function TriggerFixExtHurtEntity.RemoveEffectCreatedCb(func)
	for i=table.getn(TriggerFixExtHurtEntity.createdCbs),1,-1 do
		if TriggerFixExtHurtEntity.createdCbs[i]==func then
			table.remove(TriggerFixExtHurtEntity.createdCbs, i)
		end
	end
end

function TriggerFixExtHurtEntity.InternalProjectileHitCallback(effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	TriggerFixExtHurtEntity.currentProjectile = TriggerFixExtHurtEntity.projectiles[effectId]
	TriggerFixExtHurtEntity.projectiles[effectId] = nil
	TriggerFixExtHurtEntity.currentProjectile.tick = Logic.GetTimeMs()
	if TriggerFixExtHurtEntity.currentEntity.tick==TriggerFixExtHurtEntity.currentProjectile.tick then
		TriggerFixExtHurtEntity.currentEntity = {}
	end
	for _,f in ipairs(TriggerFixExtHurtEntity.hitCbs) do
		TriggerFix.ProtectedCall(f, effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	end
end

function TriggerFixExtHurtEntity.AddProjectileHitCb(func)
	table.insert(TriggerFixExtHurtEntity.hitCbs, func)
end

function TriggerFixExtHurtEntity.RemoveProjectileHitCb(func)
	for i=table.getn(TriggerFixExtHurtEntity.hitCbs),1,-1 do
		if TriggerFixExtHurtEntity.hitCbs[i]==func then
			table.remove(TriggerFixExtHurtEntity.hitCbs, i)
		end
	end
end

function TriggerFixExtHurtEntity.HurtTrigger_GetProjectileInfo()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	if (so == S5HookHurtEntitySources.ArrowProjectile or so == S5HookHurtEntitySources.CannonProjectile
	or so == S5HookHurtEntitySources.SniperAttackAbility) and TriggerFixExtHurtEntity.currentProjectile.tick==Logic.GetTimeMs() then
		return TriggerFixExtHurtEntity.currentProjectile
	end
end

function TriggerFixExtHurtEntity.HurtTrigger_GetEntityInfo()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	if (so == S5HookHurtEntitySources.ArrowProjectile or so == S5HookHurtEntitySources.CannonProjectile
	or so == S5HookHurtEntitySources.SniperAttackAbility) and TriggerFixExtHurtEntity.currentEntity.tick==Logic.GetTimeMs() then
		return TriggerFixExtHurtEntity.currentEntity
	end
end

function TriggerFixExtHurtEntity.InternalHurtEntityCallback(attackerId, targetId)
	if attackerId==0 then
		local pinf = TriggerFixExtHurtEntity.HurtTrigger_GetProjectileInfo()
		local einf = TriggerFixExtHurtEntity.HurtTrigger_GetEntityInfo()
		if pinf then
			attackerId = pinf.attackerId
		elseif einf then
			attackerId = einf.attackerId
		end
	end
	local t = {}
	for k,v in pairs(TriggerFix.event) do
		t[k] = 0
	end
	t.GetEntityID1 = attackerId
	t.GetEntityID2 = targetId
	TriggerFix_action(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, t)
end

function TriggerFixExtHurtEntity.InternalDestroyedTrigger()
	local id = Event.GetEntityID()
	local ty = Logic.GetEntityType(id)
	if MemoryManipulation.HasEntityBehavior(id, MemoryManipulation.ClassVTable.GGL_CBombBehavior)
	or MemoryManipulation.HasEntityBehavior(id, MemoryManipulation.ClassVTable.GGL_CKegBehavior) then
		TriggerFixExtHurtEntity.currentEntity = {
			tick = Logic.GetTimeMs(),
			attackerId = id,
			attackerPlayer = GetPlayer(id),
			attackerType = ty,
		}
		if TriggerFixExtHurtEntity.currentEntity.tick==TriggerFixExtHurtEntity.currentProjectile.tick then
			TriggerFixExtHurtEntity.currentProjectile = {}
		end
	end
end

function TriggerFixExtHurtEntity.Init()
	TriggerFix.UnrequestTrigger(TriggerFix.entityHurtEntityBaseTriggerId)
	S5Hook.SetEffectCreatedCallback(TriggerFixExtHurtEntity.InternalEffectCreatedCallback)
	S5Hook.SetGlobalProjectileHitCallback(TriggerFixExtHurtEntity.InternalProjectileHitCallback)
	S5Hook.SetHurtEntityCallback(TriggerFixExtHurtEntity.InternalHurtEntityCallback)
	if not TriggerFixExtHurtEntity.InternalDestroyedTriggerId then
		TriggerFixExtHurtEntity.InternalDestroyedTriggerId = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, "TriggerFixExtHurtEntity.InternalDestroyedTrigger", 1)
	end
end

table.insert(S5HookLoader.cb, TriggerFixExtHurtEntity.Init)
