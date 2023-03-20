if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/comfort/other/FrameworkWrapperLight")
mcbPacker.require("s5CommunityLib/tables/ArmorClasses")
mcbPacker.require("s5CommunityLib/comfort/entity/EntityIdChangedHelper")
end --mcbPacker.ignore

if not CppLogic then
    assert(false, "CppLogic is required!")
    -- TODO exit map
    return
end

--- author:mcb		current maintainer:mcb		v1.0
-- trigger support für CppLogic.
-- - definiert Events.SCRIPT_EVENT_ON_CONVERT_ENTITY, aufgerufen wenn helias einen leader bekehrt.
-- - verbessert Events.SCRIPT_EVENT_ON_ENTITY_KILLS_ENTITY, soldier ids stimmen nun in jedem fall.
--
-- setze TriggerFixCppLogicExtension_UseRecommendedFixes = true um einige von mir empfohlene fixes zu verwenden.
--
-- enthaltene comforts:
-- - TriggerFixCppLogicExtension.RemoveArchiveOnLeave                       bool, wenn true werden alle s5x archive in der loadorder entfernt wenn die map verlassen wird.
-- - TriggerFixCppLogicExtension.AddMapArchiveToLoadOrder(path)             fügt path zur loadorder hinzu, wenn noch nicht vorhanden. nur s5x archive. wenn path nil ist, die aktuelle map.
-- - TriggerFixCppLogicExtension.SetGUIStateSelectEntity(onconfirm, mouse, checkentity, oncancel)
--                                                                          gui state um ein entity zu selektieren.
-- - TriggerFixCppLogicExtension.SetGUIStateSelectPos(onconfirm, mouse, checkpos, oncancel)
--                                                                          gui state um eine position zu selektieren.
-- - TriggerFixCppLogicExtension.SetGUIStateSelectPosInSector(onconfirm, mouse, sector, checkpos, oncancel)
--                                                                          gui state um eine position in einem sector zu selektieren.
--
-- Benötigt:
-- - CppLogic
-- - TriggerFix
-- - FrameworkWrapper
-- - ArmorClasses
TriggerFixCppLogicExtension = {Backup = {}, GUIStateCustomMouse=10, RemoveArchiveOnLeave=false}
TriggerFixCppLogicExtension.Backup.TaskListToFix = {
    {TaskLists.TL_BATTLE_RIFLE, 9, 5},
    {TaskLists.TL_BATTLE_BOW, 9, 5},
    {TaskLists.TL_BATTLE_CROSSBOW, 9, 5},
    {TaskLists.TL_BATTLE_HEROBOW, 9, 4},
    {TaskLists.TL_BATTLE_SKIRMISHER, 9, 5},
    --{TaskLists.TL_BATTLE_VEHICLE, 17},
}
TriggerFixCppLogicExtension.Backup.BattleWaitUntil = {
    {Entities.CU_BanditLeaderBow1, 1700},
    {Entities.CU_BanditSoldierBow1, 1700},
    {Entities.CU_Evil_LeaderSkirmisher1, 2100},
    {Entities.CU_Evil_SoldierSkirmisher1, 2100},
    {Entities.PU_Hero5, 1100},
    {Entities.PU_Hero10, 2900},
    {Entities.PU_LeaderBow1, 2100},
    {Entities.PU_LeaderBow2, 2100},
    {Entities.PU_LeaderBow3, 2100},
    {Entities.PU_LeaderBow4, 2100},
    {Entities.PU_SoldierBow1, 2100},
    {Entities.PU_SoldierBow2, 2100},
    {Entities.PU_SoldierBow3, 2100},
    {Entities.PU_SoldierBow4, 2100},
    {Entities.PU_LeaderCavalry1, 1600},
    {Entities.PU_LeaderCavalry2, 1600},
    {Entities.PU_SoldierCavalry1, 1600},
    {Entities.PU_SoldierCavalry2, 1600},
    {Entities.PU_LeaderRifle1, 3200},
    {Entities.PU_LeaderRifle2, 3200},
    {Entities.PU_SoldierRifle1, 3200},
    {Entities.PU_SoldierRifle2, 3200},
    {Entities.PV_Cannon3, 3300},
}

TriggerFix.AddScriptTrigger("SCRIPT_EVENT_ON_CONVERT_ENTITY", Events.CPPLOGIC_EVENT_ON_CONVERT_ENTITY)

function TriggerFixCppLogicExtension.Init()
    CppLogic.Entity.Settler.EnableConversionHook()
    if not CEntity then
        CppLogic.Logic.SetPaydayCallback()
    end
    if TriggerFixCppLogicExtension_UseRecommendedFixes then
        CppLogic.Combat.EnableAoEProjectileFix() -- aoe projektile beachten damage/armorclass und schadensboni durch techs/helden
        CppLogic.Logic.EnableAllHurtEntityTrigger(true)
        CppLogic.Combat.EnableCamoFix() -- camo wird nicht beendet, wenn projektile treffen
        --CppLogic.Logic.EnableAllHurtEntityTrigger() -- hurtentity trigger auch ausführen, wenn der angreifer tot ist
        TriggerFixCppLogicExtension.InitKillCb()
        CppLogic.Logic.EnableExperienceClassFix(true) -- level 1 gibt boni, misschance boni funktionieren
        CppLogic.Logic.EnableBuildOnMovementFix(true) -- auf siedlern bauen bricht bewegung nicht mehr ab
        CppLogic.Effect.EnableEffectTriggers(true) -- effect created
        if not CEntity then
            CppLogic.Logic.SetLeadersRegenerateTroopHealth(true) -- truppen hp regenerieren
            CppLogic.Entity.Settler.EnableRangedEffectSoldierHeal(true) -- truppen hp von salim geheilt
            CppLogic.Logic.FixSnipeDamage(nil)
            CppLogic.Logic.TaskListSetChangeTaskListCheckUncancelable(true)
            TriggerFix.CreateEventHurtIn = TriggerFix.CreateEventHurtInCppLogic
            TriggerFix.CreateEventHurtOut = TriggerFix.CreateEventHurtOutCppLogic
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
            TriggerFixCppLogicExtension.Backup.FurAC[dc] = CppLogic.Logic.GetDamageFactor(dc, ArmorClasses.ArmorClassFur)
        end
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Strike, ArmorClasses.ArmorClassFur, 0.9)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Pierce, ArmorClasses.ArmorClassFur, 0.9)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Chaos, ArmorClasses.ArmorClassFur, 0.7)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Siege, ArmorClasses.ArmorClassFur, 0.2)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Hero, ArmorClasses.ArmorClassFur, 0.8)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Evil, ArmorClasses.ArmorClassFur, 1)
        CppLogic.Logic.SetDamageFactor(DamageClasses.DC_Bullet, ArmorClasses.ArmorClassFur, 1.5)
        if not CEntity then
            for _,tl in ipairs(TriggerFixCppLogicExtension.Backup.TaskListToFix) do -- insert wait tasks into battle tasklists
                CppLogic.Logic.TaskListInsertSetLatestAttack(tl[1], tl[2])
                CppLogic.Logic.TaskListInsertWaitForLatestAttack(tl[1], tl[3])
            end
            for _,et in ipairs(TriggerFixCppLogicExtension.Backup.BattleWaitUntil) do
                et[3] = CppLogic.EntityType.GetBattleWaitUntil(et[1])
                CppLogic.EntityType.SetBattleWaitUntil(et[1], et[2])
            end
        end
        CppLogic.EntityType.SetDeleteWhenBuildOn(Entities.XD_BuildBlockScriptEntity, false)
        TriggerFixCppLogicExtension.Backup.AC = {}
        for _,et in pairs(Entities) do -- set soldier armor and armorclass to leaders values
            if CppLogic.EntityType.IsLeaderType(et) then
                local st = CppLogic.EntityType.Settler.LeaderTypeGetSoldierType(et)
                if st ~= 0 then
                    local larm, lac = CppLogic.EntityType.GetArmor(et)
                    local sarm, sac = CppLogic.EntityType.GetArmor(st)
                    TriggerFixCppLogicExtension.Backup.AC[st] = {sarm, sac}
                    CppLogic.EntityType.SetArmor(st, larm, lac)
                end
            end
        end
        Score.Player[0] = {all = 0, resources = 0, buildings = 0, technology = 0, settlers = 0, battle = 0}
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
            CppLogic.Logic.SetDamageFactor(dc, ArmorClasses.ArmorClassFur, f)
        end
        if not CEntity then
            for _,tl in ipairs(TriggerFixCppLogicExtension.Backup.TaskListToFix) do
                CppLogic.Logic.TaskListRemoveLatestAttack(tl[1])
            end
            for _,et in ipairs(TriggerFixCppLogicExtension.Backup.BattleWaitUntil) do
                CppLogic.EntityType.SetBattleWaitUntil(et[1], et[3])
            end
        end
        CppLogic.EntityType.SetDeleteWhenBuildOn(Entities.XD_BuildBlockScriptEntity, true)
        for st, t in pairs(TriggerFixCppLogicExtension.Backup.AC) do
            CppLogic.EntityType.SetArmor(st, t[1], t[2])
        end
    end
    if TriggerFixCppLogicExtension.RemoveArchiveOnLeave then
        while string.find(CppLogic.Logic.GetLoadOrder()[1], ".s5x") do
            CppLogic.Logic.RemoveTopArchive()
        end
    end
end

function TriggerFixCppLogicExtension.OnMapStart()
    Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_LEAVE_MAP, nil, "TriggerFixCppLogicExtension.OnLeaveMap", 1)
    Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_ENTITY_ID_CHANGED, nil, "TriggerFixCppLogicExtension.OnIdChanged", 1)
    TriggerFixCppLogicExtension.GameCallback_GUI_StateChanged = GameCallback_GUI_StateChanged
    function GameCallback_GUI_StateChanged(stateid, armed)
        TriggerFixCppLogicExtension.GameCallback_GUI_StateChanged(stateid, armed)
        if stateid == 27 then
            Mouse.CursorSet(TriggerFixCppLogicExtension.GUIStateCustomMouse)
        end
    end
    return true
end

function TriggerFixCppLogicExtension.StaticInit()
    for _,event in ipairs{Events.CPPLOGIC_EVENT_ON_ENTITY_KILLS_ENTITY, Events.CPPLOGIC_EVENT_ON_PAYDAY
            , Events.CPPLOGIC_EVENT_ON_CONVERT_ENTITY, Events.CPPLOGIC_EVENT_ON_EFFECT_CREATED, Events.CPPLOGIC_EVENT_ON_FLYINGEFFECT_HIT
            , Events.CPPLOGIC_EVENT_ON_EFFECT_DESTROYED} do
        if not TriggerFix.triggers[event] then
			TriggerFix.triggers[event] = {}
		end
		TriggerFix.RequestTrigger(event, nil, "TriggerFix_action", 1, nil, {event})
    end
    TriggerFix.HurtTriggers[Events.CPPLOGIC_EVENT_ON_ENTITY_KILLS_ENTITY]=true
end

function TriggerFixCppLogicExtension.OnIdChanged()
    CppLogic.Entity.CloneOverrideData(Event.GetEntityID1(), Event.GetEntityID2())
end

function TriggerFixCppLogicExtension.InitKillCb()
    for i = table.getn(TriggerFix.afterTriggerCB),  1, -1 do
        if TriggerFix.afterTriggerCB[i]==TriggerFix.KillTrigger.AfterTriggerCB then
            table.remove(TriggerFix.afterTriggerCB, i)
        end
    end
end

function TriggerFixCppLogicExtension.SetGUIStateSelectEntity(onconfirm, mouse, checkentity, oncancel)
    TriggerFixCppLogicExtension.GUIStateCustomMouse = mouse
    CppLogic.UI.SetGUIStateLuaSelection(function(x, y)
        local id = GUI.GetEntityAtPosition(x, y)
        if IsDestroyed(id) then
            return false
        end
        if checkentity and not checkentity(id) then
            return false
        end
        onconfirm(id)
        return true
    end, oncancel)
end
function TriggerFixCppLogicExtension.SetGUIStateSelectPos(onconfirm, mouse, checkpos, oncancel)
    TriggerFixCppLogicExtension.GUIStateCustomMouse = mouse
    CppLogic.UI.SetGUIStateLuaSelection(function(x, y)
        local p = CppLogic.UI.GetLandscapePosAtScreenPos(x, y)
        if not IsValidPosition(p) then
            return false
        end
        if checkpos and not checkpos(p) then
            return false
        end
        onconfirm(p)
        return true
    end, oncancel)
end
function TriggerFixCppLogicExtension.SetGUIStateSelectPosInSector(onconfirm, mouse, sector, checkpos, oncancel)
    TriggerFixCppLogicExtension.GUIStateCustomMouse = mouse
    CppLogic.UI.SetGUIStateLuaSelection(function(x, y)
        local p = CppLogic.UI.GetLandscapePosAtScreenPos(x, y)
        if not IsValidPosition(p) then
            return false
        end
        if CppLogic.Logic.LandscapeGetSector(p) ~= sector then
            local p2 = CppLogic.Logic.LandscapeGetNearestUnblockedPosInSector(p, sector, 2000)
            if p2 == nil then
                return false
            end
            p = p2
        end
        if not IsValidPosition(p) or CppLogic.Logic.LandscapeGetSector(p) ~= sector then
            return false
        end
        if checkpos and not checkpos(p) then
            return false
        end
        onconfirm(p)
        return true
    end, oncancel)
end

function TriggerFixCppLogicExtension.AddMapArchiveToLoadOrder(path)
    TriggerFixCppLogicExtension.RemoveArchiveOnLeave = true
    if not path then
        path = CppLogic.API.MapGetDataPath(Framework.GetCurrentMapName(), Framework.GetCurrentMapTypeAndCampaignName())
    end
    assert(string.find(path, ".s5x"))
    local lo = CppLogic.Logic.GetLoadOrder()
    for _,p in ipairs(lo) do
        if p==path then
            return
        end
    end
    CppLogic.Logic.AddArchive(path)
end

AddMapStartAndSaveLoadedCallback("TriggerFixCppLogicExtension.Init")
AddMapStartCallback("TriggerFixCppLogicExtension.OnMapStart")
TriggerFixCppLogicExtension.StaticInit()

AdvancedDealDamageSource = {
	Unknown = 0,
	Melee = 1,
	Arrow = 2,
	Cannonball = 3,

	AbilitySnipe = 10,
	AbilityCircularAttack = 11,
	AbilityBomb = 12,
	AbilitySabotageSingleTarget = 13,
	AbilitySabotageBlast = 14,
	AbilityShuriken = 15,

	Script = 25,
};
