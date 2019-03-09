if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
end --mcbPacker.ignore

--- author:mcb		currentMaintainer:mcb		v1.0
-- Fixt das problem, das der LOGIC_EVENT_ENTITY_HURT_ENTITY trigger nicht aufgerufen wird, wenn der angreifer nicht mehr valid ist
-- und stellt informationen über das schaden verursachende projekil zur verfügung.
-- Ermöglicht außerdem, mehrere effectCreated/ProjectileHit callbacks zu verwenden.
-- 
-- mcbTriggerExtHurtEntity.addEffectCreatedCb(func)		Fügt einen effectCreated callback hinzu.
-- mcbTriggerExtHurtEntity.removeEffectCreatedCb(func)	Entfernt einen effectCreated callback.
-- 
-- mcbTriggerExtHurtEntity.addProjectileHitCb(func)		Fügt einen ProjectileHit callback hinzu.
-- mcbTriggerExtHurtEntity.removeProjectileHitCb(func)	Entfernt einen ProjectileHit callback.
-- 
-- mcbTriggerExtHurtEntity.getProjectileInfo()			Nur aus dem LOGIC_EVENT_ENTITY_HURT_ENTITY trigger aufrufen!
-- 														Gibt informationen über das verwendete projektil zurück.
-- 														{
-- 															effectType,
-- 															playerId,
-- 															startPos,
-- 															targetPos,
-- 															attackerId,
-- 															targetId,
-- 															damage,
-- 															radius,
-- 															effectId,
-- 														}
-- 
-- Benötigt:
-- - s5HookLoader
-- - mcbTrigger
-- 
mcbTriggerExtHurtEntity = {projectiles={}, currentProjectile={}, createdCbs={}, hitCbs={}}

function mcbTriggerExtHurtEntity.projectileCreated(effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId)
	if creatorType == 7816856 then
		mcbTriggerExtHurtEntity.projectiles[effectId] = {
			effectType = effectType,
			playerId = playerId,
			startPos = {X=startPosX, Y=startPosY},
			targetPos = {X=targetPosX,Y=targetPosY},
			attackerId = attackerId,
			targetId = targetId,
			damage = damage,
			radius = radius,
			effectId = effectId,
		}
	elseif creatorType ~= 7790912 then
		LuaDebugger.Log("unknown effect created: "..creatorType)
	end
	for _,f in ipairs(mcbTriggerExtHurtEntity.createdCbs) do
		mcbTrigger.protectedCall(f, effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId)
	end
end

function mcbTriggerExtHurtEntity.addEffectCreatedCb(func)
	table.insert(mcbTriggerExtHurtEntity.createdCbs, func)
end

function mcbTriggerExtHurtEntity.removeEffectCreatedCb(func)
	for i=table.getn(mcbTriggerExtHurtEntity.createdCbs),1,-1 do
		if mcbTriggerExtHurtEntity.createdCbs[i]==func then
			table.remove(mcbTriggerExtHurtEntity.createdCbs, i)
		end
	end
end

function mcbTriggerExtHurtEntity.projectileHit(effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	mcbTriggerExtHurtEntity.currentProjectile = mcbTriggerExtHurtEntity.projectiles[effectId]
	mcbTriggerExtHurtEntity.projectiles[effectId] = nil
	mcbTriggerExtHurtEntity.currentProjectile.tick = Logic.GetTimeMs()
	for _,f in ipairs(mcbTriggerExtHurtEntity.hitCbs) do
		mcbTrigger.protectedCall(f, effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	end
end

function mcbTriggerExtHurtEntity.addProjectileHitCb(func)
	table.insert(mcbTriggerExtHurtEntity.hitCbs, func)
end

function mcbTriggerExtHurtEntity.removeProjectileHitCb(func)
	for i=table.getn(mcbTriggerExtHurtEntity.hitCbs),1,-1 do
		if mcbTriggerExtHurtEntity.hitCbs[i]==func then
			table.remove(mcbTriggerExtHurtEntity.hitCbs, i)
		end
	end
end

function mcbTriggerExtHurtEntity.getProjectileInfo()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	if so == S5HookHurtEntitySources.ArrowProjectile or so == S5HookHurtEntitySources.CannonProjectile or so == S5HookHurtEntitySources.SniperAttackAbility then
		assert(mcbTriggerExtHurtEntity.currentProjectile.tick==Logic.GetTimeMs())
		return mcbTriggerExtHurtEntity.currentProjectile
	end
end

function mcbTriggerExtHurtEntity.hurtEntity(attackerId, targetId)
	if attackerId==0 then
		local pinf = mcbTriggerExtHurtEntity.getProjectileInfo()
		attackerId = pinf.attackerId
	end
	local t = {}
	for k,v in pairs(mcbTrigger.event) do
		t[k] = 0
	end
	t.GetEntityID1 = attackerId
	t.GetEntityID2 = targetId
	mcbTrigger_action(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, t)
end

function mcbTriggerExtHurtEntity.init()
	mcbTrigger.UnrequestTrigger(mcbTrigger.entityHurtEntityBaseTriggerId)
	S5Hook.SetEffectCreatedCallback(mcbTriggerExtHurtEntity.projectileCreated)
	S5Hook.SetGlobalProjectileHitCallback(mcbTriggerExtHurtEntity.projectileHit)
	S5Hook.SetHurtEntityCallback(mcbTriggerExtHurtEntity.hurtEntity)
end

table.insert(s5HookLoader.cb, mcbTriggerExtHurtEntity.init)
