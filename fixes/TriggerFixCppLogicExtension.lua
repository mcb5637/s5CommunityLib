if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/comfort/other/FrameworkWrapperLight")
mcbPacker.require("s5CommunityLib/tables/ArmorClasses")
end --mcbPacker.ignore

if not CppLogic then
    assert(false, "CppLogic is required!")
    -- TODO exit map
    return
end

--- author:mcb		current maintainer:mcb		v1.0
-- trigger support für CppLogic.
-- - definiert Events.SCRIPT_EVENT_ON_CONVERT_ENTITY, aufgerufen wenn helias einen leader bekehrt.
--
-- setze TriggerFixCppLogicExtension_UseRecommendedFixes = true um einige von mir empfohlene fixes zu verwenden.
--
-- Benötigt:
-- - CppLogic
-- - TriggerFix
-- - FrameworkWrapper
-- - ArmorClasses
TriggerFixCppLogicExtension = {Backup = {}}
TriggerFixCppLogicExtension.Backup.TaskListToFix = {
    {TaskLists.TL_BATTLE_RIFLE, 10},
    {TaskLists.TL_BATTLE_BOW, 10},
    {TaskLists.TL_BATTLE_CROSSBOW, 10},
    {TaskLists.TL_BATTLE_HEROBOW, 9},
    {TaskLists.TL_BATTLE_SKIRMISHER, 10},
    {TaskLists.TL_BATTLE_VEHICLE, 17},
}

TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_CONVERT_ENTITY")

function TriggerFixCppLogicExtension.Init()
    CppLogic.Entity.Settler.EnableConversionHook(TriggerFixCppLogicExtension.Hook)
    if TriggerFixCppLogicExtension_UseRecommendedFixes then
        CppLogic.Combat.EnableAoEProjectileFix() -- aoe projektile beachten damage/armorclass und schadensboni durch techs/helden
        CppLogic.Combat.EnableCamoFix() -- camo wird nicht beendet, wenn projektile treffen
        CppLogic.Logic.EnableAllHurtEntityTrigger() -- hurtentity trigger auch ausführen, wenn der angreifer tot ist
        CppLogic.Logic.EnableBuildOnMovementFix(true) -- auf siedlern bauen bricht bewegung nicht mehr ab
        if not CEntity then
            CppLogic.Logic.SetLeadersRegenerateTroopHealth(true) -- truppen hp regenerieren
            CppLogic.Entity.Settler.EnableRangedEffectSoldierHeal(true) -- truppen hp von salim geheilt
        end
        -- kanonen damageclasses fixen
        TriggerFixCppLogicExtension.Backup.Cannons = {}
        local function docannon(ty, dc)
            local d, c = CppLogic.EntityType.GetAutoAttackDamage(ty)
            TriggerFixCppLogicExtension.Backup.Cannons[ty] = c
            CppLogic.EntityType.SetAutoAttackDamage(ty, d, dc)
        end
        docannon(Entities.PV_Cannon2, DamageClasses.DC_Siege)
        docannon(Entities.PV_Cannon3, DamageClasses.DC_Chaos)
        -- damageclasses faktor gegen fur fixen
        TriggerFixCppLogicExtension.Backup.FurAC = {}
        for _,dc in pairs(DamageClasses) do
            TriggerFixCppLogicExtension.Backup.FurAC[dc] = CppLogic.Logic.GetDamageFactor(dc, ArmorClasses.AC_Fur)
        end
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Strike, ArmorClasses.AC_Fur, 0.9)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Pierce, ArmorClasses.AC_Fur, 0.9)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Chaos, ArmorClasses.AC_Fur, 0.7)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Siege, ArmorClasses.AC_Fur, 0.2)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Hero, ArmorClasses.AC_Fur, 0.8)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Evil, ArmorClasses.AC_Fur, 1)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Bullet, ArmorClasses.AC_Fur, 1.5)
        if not CEntity then
            for _,tl in ipairs(TriggerFixCppLogicExtension.Backup.TaskListToFix) do -- make battle task lists wait for anim uncancleable after firing projectile
                CppLogic.Logic.TaskListMakeWaitForAnimsUnCancelable(tl[1], tl[2])
            end
        end
    end
end

function TriggerFixCppLogicExtension.OnLeaveMap()
    CppLogic.OnLeaveMap()
    -- CppLogic automatically deactivates all mods, just have to reset data
    if TriggerFixCppLogicExtension_UseRecommendedFixes then
        for ty, dc in pairs(TriggerFixCppLogicExtension.Backup.Cannons) do
            CppLogic.EntityType.SetAutoAttackDamage(ty, CppLogic.EntityType.GetAutoAttackDamage(ty), dc)
        end
        for dc, f in pairs(TriggerFixCppLogicExtension.Backup.FurAC) do
            CppLogic.Logic.SetDamageFactor(dc, ArmorClasses.AC_Fur, f)
        end
        if not CEntity then
            for _,tl in ipairs(TriggerFixCppLogicExtension.Backup.TaskListToFix) do
                CppLogic.Logic.TaskListMakeWaitForAnimsCancelable(tl[1], tl[2])
            end
        end
    end
end

function TriggerFixCppLogicExtension.AddLeaveTrigger()
    Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_LEAVE_MAP, nil, "TriggerFixCppLogicExtension.OnLeaveMap", 1)
    Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_ENTITY_ID_CHANGED, nil, "TriggerFixCppLogicExtension.OnIdChanged", 1)
    return true
end

function TriggerFixCppLogicExtension.OnIdChanged()
    CppLogic.Entity.CloneOverrideData(Event.GetEntityID1(), Event.GetEntityID2())
end

function TriggerFixCppLogicExtension.Hook(targetId, player, newid, converterId)
    local ev = TriggerFix.CreateEmptyEvent()
    ev.GetEntityID1 = targetId
    ev.GetEntityID2 = newid
    ev.GetEntityID = converterId
    ev.GetPlayerID = player
    TriggerFix_action(Events.SCRIPT_EVENT_ON_CONVERT_ENTITY, ev)
end

AddMapStartAndSaveLoadedCallback("TriggerFixCppLogicExtension.Init")
AddMapStartCallback("TriggerFixCppLogicExtension.AddLeaveTrigger")
