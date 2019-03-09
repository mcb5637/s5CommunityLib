if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/mcbTriggerExtHurtEntity")
mcbPacker.require("s5CommunityLib/tables/ArmorClasses")
mcbPacker.require("comfort/mcbEMan")
end --mcbPacker.ignore


HurtProjectileFix = {projectileMem={}, lastProjectile={}}

function HurtProjectileFix.OnEffectCreated(effectType, playerId, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, radius, creatorType, effectId)
	if creatorType == 7816856 then
		HurtProjectileFix.projectileMem[effectId] = {
			baseDamage = Logic.GetEntityDamage(attackerId), -- modified by hero auras and techs
			damageClass = mcbEMan.GetEntityTypeDamageClass(Logic.GetEntityType(attackerId)),
		}
	end
end

function HurtProjectileFix.OnProjectileHit(effectType, startPosX, startPosY, targetPosX, targetPosY, attackerId, targetId, damage, aoeRange, effectId)
	HurtProjectileFix.lastProjectile = HurtProjectileFix.projectileMem[effectId]
	HurtProjectileFix.projectileMem[effectId] = nil
end

function HurtProjectileFix.OnHit()
	local so = S5Hook.HurtEntityTrigger_GetSource()
	if so == S5HookHurtEntitySources.CannonProjectile then
		local at = Event.GetEntityID1()
		local def = Event.GetEntityID2()
		local pinf = mcbTriggerExtHurtEntity.getProjectileInfo()
		local dmod = HurtProjectileFix.GetDamageMod(mcbEMan.GetEntityTypeArmorClass(Logic.GetEntityType(def)), HurtProjectileFix.lastProjectile.damageClass)
		local dmg = HurtProjectileFix.lastProjectile.baseDamage * dmod - Logic.GetEntityArmor(def)
		S5Hook.HurtEntityTrigger_SetDamage(dmg)
	end
end

function HurtProjectileFix.GetDamageMod(ac, dc) -- TODO read this from memory
	return HurtProjectileFix.DamageModifiers[dc][ac]
end

function HurtProjectileFix.Init()
	mcbTriggerExtHurtEntity.addEffectCreatedCb(HurtProjectileFix.OnEffectCreated)
	mcbTriggerExtHurtEntity.addProjectileHitCb(HurtProjectileFix.OnProjectileHit)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, nil, "HurtProjectileFix.OnHit", 1)
end

HurtProjectileFix.DamageModifiers = {
	[DamageClasses.DC_Strike] = {
		[ArmorClasses.AC_None] = 1,
		[ArmorClasses.AC_Jerkin] = 1.7,
		[ArmorClasses.AC_Leather] = 1.5,
		[ArmorClasses.AC_Iron] = 1,
		[ArmorClasses.AC_Fortification] = 0.4,
		[ArmorClasses.AC_Hero] = 1,
		[ArmorClasses.AC_Fur] = 0.9,
	},
	[DamageClasses.DC_Pierce] = {
		[ArmorClasses.AC_None] = 1.5,
		[ArmorClasses.AC_Jerkin] = 1,
		[ArmorClasses.AC_Leather] = 1,
		[ArmorClasses.AC_Iron] = 1.5,
		[ArmorClasses.AC_Fortification] = 0.3,
		[ArmorClasses.AC_Hero] = 0.9,
		[ArmorClasses.AC_Fur] = 0.9,
	},
	[DamageClasses.DC_Chaos] = {
		[ArmorClasses.AC_None] = 1,
		[ArmorClasses.AC_Jerkin] = 1,
		[ArmorClasses.AC_Leather] = 1.5,
		[ArmorClasses.AC_Iron] = 1.25,
		[ArmorClasses.AC_Fortification] = 0.75,
		[ArmorClasses.AC_Hero] = 1,
		[ArmorClasses.AC_Fur] = 0.7,
	},
	[DamageClasses.DC_Siege] = {
		[ArmorClasses.AC_None] = 0.2,
		[ArmorClasses.AC_Jerkin] = 0.2,
		[ArmorClasses.AC_Leather] = 0.2,
		[ArmorClasses.AC_Iron] = 0.2,
		[ArmorClasses.AC_Fortification] = 1.7,
		[ArmorClasses.AC_Hero] = 0.2,
		[ArmorClasses.AC_Fur] = 0.2,
	},
	[DamageClasses.DC_Hero] = {
		[ArmorClasses.AC_None] = 1,
		[ArmorClasses.AC_Jerkin] = 1,
		[ArmorClasses.AC_Leather] = 1,
		[ArmorClasses.AC_Iron] = 1,
		[ArmorClasses.AC_Fortification] = 0.6,
		[ArmorClasses.AC_Hero] = 1,
		[ArmorClasses.AC_Fur] = 0.6,
	},
	[DamageClasses.DC_Evil] = {
		[ArmorClasses.AC_None] = 1.1,
		[ArmorClasses.AC_Jerkin] = 1.3,
		[ArmorClasses.AC_Leather] = 1.1,
		[ArmorClasses.AC_Iron] = 1,
		[ArmorClasses.AC_Fortification] = 0.8,
		[ArmorClasses.AC_Hero] = 1.1,
		[ArmorClasses.AC_Fur] = 1,
	},
	[DamageClasses.DC_Bullet] = {
		[ArmorClasses.AC_None] = 1,
		[ArmorClasses.AC_Jerkin] = 1.8,
		[ArmorClasses.AC_Leather] = 1,
		[ArmorClasses.AC_Iron] = 1,
		[ArmorClasses.AC_Fortification] = 0.3,
		[ArmorClasses.AC_Hero] = 1.2,
		[ArmorClasses.AC_Fur] = 1.5,
	},
}
