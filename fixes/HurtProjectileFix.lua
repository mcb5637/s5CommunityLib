if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/mcbTriggerExtHurtEntity")
mcbPacker.require("s5CommunityLib/tables/ArmorClasses")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1.0
-- Fixt die schadensberechnung von kanonen-projektilen.
-- 
-- - HurtProjectileFix.Init()													Aus der FMA aufrufen.
-- - HurtProjectileFix.AddProjectileToFix(effectId, baseDamage, damageClass)	Nach dem erstellen eines Projektiles mit S5Hook.CreateProjectile
-- 																					aufrufen den Schaden für dieses Projektil zu ändern (Hook Projektile normalerweise nicht geändert).
-- 
-- Ich empfehle weiterhin die damageclasses von PV_Cannon2 und PV_Cannon3 zu tauschen, damit die tatsächlichen stärken und schwächen der kanonen wie in den tooltips beschrieben sind.
-- 
-- Benötigt:
-- - mcbTrigger
-- - mcbTriggerExtHurtEntity
-- - S5Hook (neueste version mit hurt-callback)
-- - ArmorClasses
-- - MemoryManipulation
HurtProjectileFix = {projectileMem={}, lastProjectile={}, projectilesToAdd={}}

function HurtProjectileFix.OnEffectCreated(effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId, isHookCreated)
	if creatorType == 7816856 then
		if IsValid(attackerId) and isHookCreated==0 then
			HurtProjectileFix.projectilesToAdd[effectId] = attackerId
		end
	end
end

function HurtProjectileFix.AddOnTick()
	for effectId, attackerId in pairs(HurtProjectileFix.projectilesToAdd) do
		HurtProjectileFix.AddProjectileToFix(effectId,
			Logic.GetEntityDamage(attackerId), -- modified by hero auras and techs
			MemoryManipulation.GetSettlerTypeDamageClass(Logic.GetEntityType(attackerId))
		)
	end
	HurtProjectileFix.projectilesToAdd = {}
end

function HurtProjectileFix.AddOnDestroy()
	local id = Event.GetEntityID()
	local effs = {}
	for effectId, attackerId in pairs(HurtProjectileFix.projectilesToAdd) do
		if id==attackerId then
			HurtProjectileFix.AddProjectileToFix(effectId,
				Logic.GetEntityDamage(attackerId), -- modified by hero auras and techs
				MemoryManipulation.GetSettlerTypeDamageClass(Logic.GetEntityType(attackerId))
			)
		end
		table.insert(effs, effectId)
	end
	for _,eid in ipairs(effs) do
		HurtProjectileFix.projectilesToAdd[eid] = nil
	end
end

function HurtProjectileFix.AddProjectileToFix(effectId, baseDamage, damageClass)
	HurtProjectileFix.projectileMem[effectId] = {
		baseDamage = baseDamage,
		damageClass = damageClass,
	}
end

function HurtProjectileFix.OnProjectileHit(effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	if HurtProjectileFix.projectilesToAdd[effectId] then
		HurtProjectileFix.AddProjectileToFix(effectId,
			Logic.GetEntityDamage(HurtProjectileFix.projectilesToAdd[effectId]), -- modified by hero auras and techs
			MemoryManipulation.GetSettlerTypeDamageClass(Logic.GetEntityType(HurtProjectileFix.projectilesToAdd[effectId]))
		)
		HurtProjectileFix.projectilesToAdd[effectId] = nil
	end
	HurtProjectileFix.lastProjectile = HurtProjectileFix.projectileMem[effectId]
	HurtProjectileFix.projectileMem[effectId] = nil
end

function HurtProjectileFix.OnHit()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	local pinf = mcbTriggerExtHurtEntity.getProjectileInfo()
	if so == S5HookHurtEntitySources.CannonProjectile and pinf and HurtProjectileFix.lastProjectile then
		local at = Event.GetEntityID1()
		local def = Event.GetEntityID2()
		local dmod = HurtProjectileFix.GetDamageMod(MemoryManipulation.GetEntityTypeArmorClass(Logic.GetEntityType(def)), HurtProjectileFix.lastProjectile.damageClass)
		local distmod = (pinf.radius - GetDistance(def, pinf.targetPos)) / pinf.radius
		local dmg = HurtProjectileFix.lastProjectile.baseDamage * dmod * distmod - Logic.GetEntityArmor(def)
		S5Hook.HurtEntityTrigger_SetDamage(math.max(dmg, 1))
	end
end

function HurtProjectileFix.GetDamageMod(ac, dc)
	return MemoryManipulation.GetDamageModifier(dc, ac)
end

function HurtProjectileFix.Init()
	mcbTriggerExtHurtEntity.addEffectCreatedCb(HurtProjectileFix.OnEffectCreated)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, "HurtProjectileFix.AddOnDestroy", 1)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "HurtProjectileFix.AddOnTick", 1)
	mcbTriggerExtHurtEntity.addProjectileHitCb(HurtProjectileFix.OnProjectileHit)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "HurtProjectileFix.OnHit", 1)
end
