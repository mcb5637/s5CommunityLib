if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/fixes/TriggerFixCppLogicExtension")
mcbPacker.require("s5CommunityLib/comfort/other/MPSyncer")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/player/SubFromPlayersResources")
mcbPacker.require("s5CommunityLib/lib/CNetEventCallbacks")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1.0
-- 
-- ermöglicht das speichern und nacheinander ausführen der meisten einheiten befehle, wenn der spieler STRG drückt während er den befehl gibt.
-- 
-- Benötigt:
-- - TriggerFix
-- - TriggerFixCppLogicExtension
-- - CppLogic
-- - MPSyncer
-- - GetDistance
-- - SubFromPlayersResources
-- - CNetEventCallbacks
CommandQueue = {SerfAutoBuild = true}

CommandQueue.Queue = {}

function CommandQueue.Init()
    if XGUIEng.GetWidgetID("AutoAddSerfJobs")==0 then
        CppLogic.UI.ContainerWidgetCreateGFXButtonWidgetChild("SerfConstructionMenu", "AutoAddSerfJobs", nil)
        CppLogic.UI.WidgetSetPositionAndSize("AutoAddSerfJobs", 325, 76, 32, 32)
        XGUIEng.ShowWidget("AutoAddSerfJobs", 1)
        CppLogic.UI.WidgetSetBaseData("AutoAddSerfJobs", 0, false, false)
        XGUIEng.DisableButton("AutoAddSerfJobs", 0)
        XGUIEng.HighLightButton("AutoAddSerfJobs", 0)
        CppLogic.UI.ButtonOverrideActionFunc("AutoAddSerfJobs", function() CommandQueue.AutoAddSerfCommandsAction() end)
        CppLogic.UI.WidgetMaterialSetTextureCoordinates("AutoAddSerfJobs", 0, 0, 0.25, 0.25, 0.125)
        XGUIEng.SetMaterialTexture("AutoAddSerfJobs", 0, "data\\graphics\\textures\\gui\\b_generic_settler.png")
        XGUIEng.SetMaterialColor("AutoAddSerfJobs", 0, 255, 255, 255, 255)
        CppLogic.UI.WidgetMaterialSetTextureCoordinates("AutoAddSerfJobs", 1, 0.25, 0.25, 0.25, 0.125)
        XGUIEng.SetMaterialTexture("AutoAddSerfJobs", 1, "data\\graphics\\textures\\gui\\b_generic_settler.png")
        XGUIEng.SetMaterialColor("AutoAddSerfJobs", 1, 255, 255, 255, 255)
        CppLogic.UI.WidgetMaterialSetTextureCoordinates("AutoAddSerfJobs", 2, 0.5, 0.25, 0.25, 0.125)
        XGUIEng.SetMaterialTexture("AutoAddSerfJobs", 2, "data\\graphics\\textures\\gui\\b_generic_settler.png")
        XGUIEng.SetMaterialColor("AutoAddSerfJobs", 2, 255, 255, 255, 255)
        CppLogic.UI.WidgetMaterialSetTextureCoordinates("AutoAddSerfJobs", 3, 0, 0.25, 0.25, 0.125)
        XGUIEng.SetMaterialTexture("AutoAddSerfJobs", 3, "data\\graphics\\textures\\gui\\b_generic_settler.png")
        XGUIEng.SetMaterialColor("AutoAddSerfJobs", 3, 128, 128, 128, 128)
        CppLogic.UI.WidgetMaterialSetTextureCoordinates("AutoAddSerfJobs", 4, 0.75, 0.25, 0.25, 0.125)
        XGUIEng.SetMaterialTexture("AutoAddSerfJobs", 4, "data\\graphics\\textures\\gui\\b_generic_settler.png")
        XGUIEng.SetMaterialColor("AutoAddSerfJobs", 4, 255, 255, 255, 255)
        CppLogic.UI.WidgetSetTooltipData("AutoAddSerfJobs", "TooltipBottom", true, true)
        CppLogic.UI.WidgetOverrideTooltipFunc("AutoAddSerfJobs", function() CommandQueue.AutoAddSerfCommandsTT() end)
    end
end
function CommandQueue.AddTriggers()
    CNetEventCallbacks.Add("all", CommandQueue.OnAddCommand)
    StartSimpleJob("CommandQueue.OnTick")
    Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_ENTITY_ID_CHANGED, nil, CommandQueue.OnIdChanged, 1)
    MPSyncer.VirtualFuncs.Create(CommandQueue.AddToEntitySynced, "CommandQueueAdd",
        MPSyncer.VirtualFuncs.ArgumentTypeCheckedEntity(), MPSyncer.VirtualFuncs.ArgumentTypeSimpleTable()
    )
    MPSyncer.VirtualFuncs.Create(CommandQueue.ClearEntitySynced, "CommandQueueClear", MPSyncer.VirtualFuncs.ArgumentTypeCheckedEntity())
    MPSyncer.VirtualFuncs.Create(CommandQueue.PlaceBuildingSynced, "CommandQueuePlaceBuilding",
        MPSyncer.VirtualFuncs.ArgumentTypeInt(), MPSyncer.VirtualFuncs.ArgumentTypeInt(), MPSyncer.VirtualFuncs.ArgumentTypeInt(), MPSyncer.VirtualFuncs.ArgumentTypeInt(),
        MPSyncer.VirtualFuncs.ArgumentTypeCheckedPlayer(), MPSyncer.VirtualFuncs.ArgumentTypeSimpleTable(), MPSyncer.VirtualFuncs.ArgumentTypeInt()
    )
end

function CommandQueue.AutoAddSerfCommandsAction()
    local s = {GUI.GetSelectedEntities()}
    local p = GetPosition(s[1])
    local pl = GUI.GetPlayerID()
    for id in CppLogic.Entity.EntityIterator(CppLogic.Entity.Predicates.IsBuilding(), CppLogic.Entity.Predicates.OfPlayer(pl),
        CppLogic.Entity.Predicates.IsAlive(), CppLogic.Entity.Predicates.InCircle(p.X, p.Y, 2000)
    ) do
        if Logic.IsConstructionComplete(id)==0 then
            for _,se in ipairs(s) do
                local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfConstructBuilding}
                c.Target = id
                CommandQueue.AddToEntity(se, c)
            end
        elseif Logic.GetEntityHealth(id)<Logic.GetEntityMaxHealth(id) then
            for _,se in ipairs(s) do
                local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfRepairBuilding}
                c.Target = id
                CommandQueue.AddToEntity(se, c)
            end
        end
    end
end

function CommandQueue.AutoAddSerfCommandsTT()
    XGUIEng.SetText("TooltipBottomText", "@color:180,180,180 Alles Bauen/Reparieren @cr @color:255,255,255 Schickt diese Leibeigenen nacheinander zu allen Baustellen und Reparaturen in Reichweite.")
    XGUIEng.SetText("TooltipBottomCosts", "")
    XGUIEng.SetText("TooltipBottomShortCut", "")
end

function CommandQueue.OnAddCommand(id, ev)
    if CommandQueue.CommandTypes[id] and CommandQueue.CommandTypes[id]:Add(ev, XGUIEng.IsModifierPressed(Keys.ModifierControl)==1) then
        return false, true
    end
end

function CommandQueue.OnIdChanged()
    local old, new = Event.GetEntityID1(), Event.GetEntityID2()
    if CommandQueue.Queue[old] then
        CommandQueue.Queue[new] = CommandQueue.Queue[old]
        CommandQueue.Queue[old] = nil
    end
end

function CommandQueue.OnTick()
    for id, cs in pairs(CommandQueue.Queue) do
        if IsDead(id) then
            CommandQueue.Queue[id] = nil
        elseif CppLogic.Entity.Settler.IsIdle(id) then
            if CommandQueue.CheckEntity(id, cs) then
                CommandQueue.Queue[id] = nil
            end
        end
    end
end

function CommandQueue.CheckEntity(id, cs)
    if not cs[1] then
        return true
    end
    while CommandQueue.CommandTypes[cs[1].Cmd].IsDone(cs[1], id) do
        local lastcmd = table.remove(cs, 1)
        if not cs[1] then
            if CommandQueue.CommandTypes[lastcmd.Cmd].SerfAutoBuild and CommandQueue.CheckSerfAutoBuild(id) then
                break
            else
                return true
            end
        end
    end
    CommandQueue.CommandTypes[cs[1].Cmd].Execute(cs[1], id)
end

function CommandQueue.CheckSerfAutoBuild(id)
    local p = GetPosition(id)
    local pl = GUI.GetPlayerID()
    local r = nil
    local c = nil
    for b, rsq in CppLogic.Entity.EntityIterator(CppLogic.Entity.Predicates.IsBuilding(), CppLogic.Entity.Predicates.OfPlayer(pl),
        CppLogic.Entity.Predicates.IsAlive(), CppLogic.Entity.Predicates.InCircle(p.X, p.Y, 2000)
    ) do
        if Logic.IsConstructionComplete(b)==0 and (not r or rsq < r) then
            c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfConstructBuilding}
            c.Target = b
            r = rsq
        elseif Logic.GetEntityHealth(b)<Logic.GetEntityMaxHealth(b) and (not r or rsq < r) then
            c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfRepairBuilding}
            c.Target = b
            r = rsq
        end
    end
    if c then
        CommandQueue.AddToEntitySynced(id, c)
        return true
    end
end

function CommandQueue.AddToEntity(id, c)
    MPSyncer.ExecuteSynced("CommandQueueAdd", id, c)
end

function CommandQueue.AddToEntitySynced(id, c)
    if not CommandQueue.Queue[id] then
        CommandQueue.Queue[id] = {}
    end
    table.insert(CommandQueue.Queue[id], c)
end

function CommandQueue.ClearEntity(id)
    MPSyncer.ExecuteSynced("CommandQueueClear", id)
end

function CommandQueue.ClearEntitySynced(id)
    CommandQueue.Queue[id] = nil
end

function CommandQueue.PlaceBuildingSynced(ty, x, y, r, pl, serfs, queue)
    queue = queue == 1
    if not CppLogic.Logic.CanPlaceBuildingAt(ty, pl, {X=x,Y=y}, r) then
        Message("err cannot place!")
        return true
    end
    if not SubFromPlayersResources(CppLogic.EntityType.Building.GetConstructionCost(ty), true, false, pl) then
        return true
    end
    local csite = Logic.CreateConstructionSite(x, y, r, ty, pl)
    --LuaDebugger.Log(csite)
    local bid = CppLogic.Entity.Building.ConstructionSiteGetBuilding(csite)
    --LuaDebugger.Log(bid)
    for _,id in ipairs(serfs) do
        local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfConstructBuilding}
        c.Target = bid
        CommandQueue.AddToEntitySynced(id, c)
        if CppLogic.Entity.Settler.IsIdle(id) or not queue then
            CommandQueue.CheckEntity(id, CommandQueue.Queue[id])
        end
    end
end

function CommandQueue.IsAbilityReady(id, ab)
    return Logic.HeroGetAbiltityChargeSeconds(id, ab)==Logic.HeroGetAbilityRechargeTime(id, ab)
end

CommandQueue.CommandTypes = {
    [CNetEventCallbacks.CNetEvents.CommandEntityAttackEntity] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandEntityAttackEntity}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or Logic.GetDiplomacyState(GetPlayer(id), GetPlayer(self.Target))~=Diplomacy.Hostile
        end,
        Execute = function(self, id)
            Logic.GroupAttack(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandSerfConstructBuilding] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfConstructBuilding}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) or not queue then
                return
            end
            return true
        end,
        IsDone = function(self, id)
            return IsDestroyed(self.Target) or Logic.GetEntityHealth(self.Target)==0 or Logic.IsConstructionComplete(self.Target)==1 -- isdead doesnt work for bridges
                or CppLogic.Entity.Building.GetNearestFreeConstructionSlotFor(self.Target, GetPosition(id))==-1
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandSerfConstructBuilding(id, self.Target)
        end,
        SerfAutoBuild = true,
    },
    [CNetEventCallbacks.CNetEvents.CommandSerfRepairBuilding] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfRepairBuilding}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) or not queue then
                return
            end
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or Logic.GetEntityHealth(self.Target)==Logic.GetEntityMaxHealth(self.Target)
                or CppLogic.Entity.Building.GetNearestFreeRepairSlotFor(self.Target, GetPosition(id))==-1
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandSerfRepairBuilding(id, self.Target)
        end,
        SerfAutoBuild = true,
    },
    [CNetEventCallbacks.CNetEvents.CommandEntityGuardEntity] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandEntityGuardEntity}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target)
        end,
        Execute = function(self, id)
            Logic.GroupGuard(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroConvertSettler] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroConvertSettler}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or not CommandQueue.IsAbilityReady(id, Abilities.AbilityConvertSettlers)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandConvert(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandThiefStealFrom] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandThiefStealFrom}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or self.Done
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandStealFrom(id, self.Target)
            self.Done = true
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandThiefCarryStolenStuffToHQ] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandThiefCarryStolenStuffToHQ}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or Logic.GetStolenResourceInfo(id)==0
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandSecureGoods(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandThiefSabotageBuilding] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandThiefSabotageBuilding}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or not CommandQueue.IsAbilityReady(id, Abilities.AbilityPlaceKeg)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandSabotage(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandThiefDefuseKeg] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandThiefDefuseKeg}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandDefuse(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroSnipeSettler] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroSnipeSettler}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or not CommandQueue.IsAbilityReady(id, Abilities.AbilitySniper)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandSnipe(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroThrowShurikenAt] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID1)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID1) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroThrowShurikenAt}
            c.Target = ev.EntityID2
            CommandQueue.AddToEntity(ev.EntityID1, c)
            return true
        end,
        IsDone = function(self, id)
            return IsDead(self.Target) or not CommandQueue.IsAbilityReady(id, Abilities.AbilityShuriken)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandShuriken(id, self.Target)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroPlaceCannonAt] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroPlaceCannonAt}
            c.Bottom = ev.FoundationType
            c.Top = ev.CannonType
            c.X = ev.Position.X
            c.Y = ev.Position.Y
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityBuildCannon) or not CppLogic.Logic.CanPlaceBuildingAt(self.Bottom, GetPlayer(id), self, 0, 0)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandPlaceCannon(id, self, self.Bottom, self.Top)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroPlaceBombAt] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroPlaceBombAt}
            c.X = ev.X
            c.Y = ev.Y
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityPlaceBomb)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandPlaceBomb(id, self)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandEntityAttackPos] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandEntityAttackPos}
            c.X = ev.X
            c.Y = ev.Y
            CommandQueue.AddToEntity(ev.EntityID, c)
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then -- always add to queue, cause sometimes this gets cancelled
                return
            end
            return true
        end,
        IsDone = function(self, id)
            return GetDistance(id, self) <= 500
        end,
        Execute = function(self, id)
            Logic.GroupAttackMove(id, self.X, self.Y, -1)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroSendHawkToPos] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroSendHawkToPos}
            c.X = ev.X
            c.Y = ev.Y
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilitySendHawk)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandSendHawk(id, self)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandScoutUseBinocularsAt] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandScoutUseBinocularsAt}
            c.X = ev.X
            c.Y = ev.Y
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return self.Cancel
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandBinocular(id, self)
            self.Cancel = true
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandScoutPlaceTorchAtPos] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandScoutPlaceTorchAtPos}
            c.X = ev.X
            c.Y = ev.Y
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityScoutTorches)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandPlaceTorch(id, self)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandEntityMove] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandEntityMove}
            c.X = ev.Position[1].X
            c.Y = ev.Position[1].Y
            if ev.Orientation~=-1 then
                c.Rot = math.deg(ev.Orientation)
            end
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return GetDistance(id, self) <= 500
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandMove(id, self, self.Rot)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandEntityPatrol] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandEntityPatrol}
            for i,p in ipairs(ev.Position) do
                c["X"..i] = p.X
                c["Y"..i] = p.Y
            end
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return self.Cancel
        end,
        Execute = function(self, id)
            Logic.GroupPatrol(id, self.X1, self.Y1)
            local i = 2
            while self["X"..i] do
                Logic.GroupAddPatrolPoint(id, self["X"..i], self["Y"..i])
                i = i + 1
            end
            self.Cancel = true
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandLeaderHoldPosition] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandLeaderHoldPosition}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return self.Cancel
        end,
        Execute = function(self, id)
            Logic.GroupStand(id)
            self.Cancel = true
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandLeaderDefend] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandLeaderDefend}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return self.Cancel
        end,
        Execute = function(self, id)
            Logic.GroupDefend(id)
            self.Cancel = true
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroActivateCamouflage] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroActivateCamouflage}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityCamouflage)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandActivateCamoflage(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroActivateSummon] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroActivateSummon}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilitySummon)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandSummon(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroAffectEntities] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroAffectEntities}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityRangedEffect)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandRangedEffect(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroCircularAttack] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroCircularAttack}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityCircularAttack)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandCircularAttack(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroInflictFear] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroInflictFear}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityInflictFear)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandInflictFear(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandHeroMotivateWorkers] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandHeroMotivateWorkers}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityMotivateWorkers)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandMotivateWorkers(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandScoutFindResources] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandScoutFindResources}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return not CommandQueue.IsAbilityReady(id, Abilities.AbilityScoutFindResources)
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandScoutFindResources(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandSerfTurnToBattleSerf] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfTurnToBattleSerf}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return Logic.GetEntityType(id)==Entities.PU_BattleSerf
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandTurnSerfToBattleSerf(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandBattleSerfTurnToSerf] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.EntityID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.EntityID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandBattleSerfTurnToSerf}
            CommandQueue.AddToEntity(ev.EntityID, c)
            return true
        end,
        IsDone = function(self, id)
            return Logic.GetEntityType(id)==Entities.PU_Serf
        end,
        Execute = function(self, id)
            CppLogic.Entity.Settler.CommandTurnBattleSerfToSerf(id)
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandPlaceBuilding] = {
        Add = function(self, ev, queue)
            local ty = Logic.GetBuildingTypeByUpgradeCategory(ev.EntityType, ev.PlayerID)
            local bon = 0
            local bty = CppLogic.EntityType.Building.GetBuildOnTypes(ty)
            if bty[1] then
                bon = Logic.GetEntityAtPosition(ev.Position.X, ev.Position.Y)
            end
            if not CppLogic.Logic.CanPlaceBuildingAt(ty, ev.PlayerID, ev.Position, math.deg(ev.Orientation), bon) then
                Message("err cannot place!")
                return true
            end
            if not SubFromPlayersResources(CppLogic.EntityType.Building.GetConstructionCost(ty), true, true, ev.PlayerID) then
                return true
            end
            MPSyncer.ExecuteSynced("CommandQueuePlaceBuilding", ty, ev.Position.X, ev.Position.Y, math.deg(ev.Orientation), ev.PlayerID, ev.Serf, queue and 1 or 0)
            return true
        end
    },
    [CNetEventCallbacks.CNetEvents.CommandSerfExtractResource] = {
        Add = function(self, ev, queue)
            if not queue then
                CommandQueue.ClearEntity(ev.SerfID)
                return
            end
            if CppLogic.Entity.Settler.IsIdle(ev.SerfID) then
                return
            end
            local c = {Cmd = CNetEventCallbacks.CNetEvents.CommandSerfExtractResource}
            c.Res = ev.ResourceType
            c.X = ev.Position.X
            c.Y = ev.Position.Y
            CommandQueue.AddToEntity(ev.SerfID, c)
            return true
        end,
        IsDone = function(self, id)
            return not IsValid(CppLogic.Entity.EntityIteratorGetNearest(CppLogic.Entity.Predicates.ProvidesResource(self.Res),
                CppLogic.Entity.Predicates.InCircle(self.X, self.Y, 1000)
            ))
        end,
        Execute = function(self, id)
            local tid = CppLogic.Entity.EntityIteratorGetNearest(CppLogic.Entity.Predicates.ProvidesResource(self.Res),
                CppLogic.Entity.Predicates.InCircle(self.X, self.Y, 1000)
            )
            CppLogic.Entity.Settler.CommandSerfExtract(id, tid)
        end
    },
}

AddMapStartAndSaveLoadedCallback("CommandQueue.Init")
AddMapStartCallback("CommandQueue.AddTriggers")
