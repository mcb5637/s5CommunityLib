--AutoFixArg
if mcbPacker then --mcbPacker.ignore
--mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/comfort/other/PredicateHelper")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/entity/IsEntityOfType")
mcbPacker.require("s5CommunityLib/comfort/entity/GetEntityMovementSpeed")
mcbPacker.require("s5CommunityLib/comfort/pos/GetCirclePosition")
mcbPacker.require("s5CommunityLib/comfort/pos/GetAngleBetween")
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/tables/LeaderFormations")
mcbPacker.require("s5CommunityLib/comfort/entity/EntityIdChangedHelper")
mcbPacker.require("s5CommunityLib/comfort/number/GetRandom")
mcbPacker.require("s5CommunityLib/comfort/other/LuaObject")
mcbPacker.require("s5CommunityLib/comfort/entity/TargetFilter")
mcbPacker.require("s5CommunityLib/comfort/pos/IsValidPosition")
mcbPacker.require("s5CommunityLib/comfort/other/FrameworkWrapperLight")
mcbPacker.require("S5CommunityLib/comfort/entity/SVLib")
if CppLogic then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFixCppLogicExtension")
end --mcbPacker.ignore
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- Neue Armeefunktion, basierend auf OOP.
-- Keine Mengenbegrenzung an Armeen.
-- Steuerung über OOP.
-- Kein "vorbeirennen" an Gegnern.
-- verfolgen von Entities.
-- automatischer einsatz von heldenfähigkeiten.
-- 
-- - Army = UnlimitedArmy:New({					erstellt eine Armee.
-- 			-- benötigt
-- 			Player,
-- 			Area,
-- 			-- optional
-- 			AutoDestroyIfEmpty,
-- 			TransitAttackMove,
-- 			Formation,
-- 			PrepDefense,
-- 			DestroyBridges,
-- 			LeaderFormation,
-- 			AIActive,
-- 			DefendDoNotHelpHeroes,
-- 			AutoRotateRange,
-- 			DoNotNormalizeSpeed,
-- 			IgnoreFleeing,
-- 			HiResJob,
-- 		})
-- 
-- Army.Player
-- Army.Leaders
-- Army.AutoDestroyIfEmpty
-- Army.Area
-- 
-- Army:AddLeader(id)							Fügt id zur army hinzu.
-- Army:RemoveLeader(id)						Entfernt id aus der army.
-- Army:GetSize(addTransit, adddeadhero)		Anzahl der Leader, addTransit gibt an, ob leader die zur armee unterwegs sind mitgezählt werden sollen..
-- Army:Destroy()								Entfernt die Army, alle leader bleiben wo sie sind.
-- Army:KillAllLeaders()						Tötet alle leader.
-- Army:IsDead()								-1-> destroyed, 2->kein leader, aber spawner, 1->kein leader, 3->hatte keinen leader, false->min 1 leader, 4->nur noch tote helden.
-- Army:GetPosition()							aktuelle position der armee, invalidPosition wenn leer.
-- Army:GetFirstEnemyInArmyRange()				erster gegner in reichweite.
-- Army:IsIdle()								tut die armee gerade etwas.
-- Army:ClearCommandQueue()						leert die auftragsliste.
-- Army:AddCommandMove(p, looped)				fügt einen bewegungsbefehl hinzu (beendet sofort).
-- Army:AddCommandFlee(p, looped)				fügt einen bewegungsbefehl ohne kampf hinzu (beendet sofort).
-- Army:AddCommandDefend(pos, defArea, looped, agressiveArea)
-- 												fügt einen verteidigungsbefehl hinzu (beendet wenn keine leader mehr übrig)(pos/area optional).
-- 												sucht nach gegnern in agressiveArea or self.Area, kehrt zur verteidigungsposition zurück, wenn außerhalb von defArea.
-- Army:AddCommandWaitForIdle(looped)			fügt einen befehl hinzu um darauf zu warten bis die armee idle ist.
-- Army:AddCommandLuaFunc(func, looped)			fügt eine lua funktion als command hinzu. diese hat 2 return werte:
-- 													1->weiter zum nächsten command.
-- 													2->temporärer command, der diesen tick ausgeführt wird (kann nil sein).
-- Army:AddCommandAttackNearestTarget(maxrange, looped)
-- 												fügt einen angriffsbefehl auf dan nächste ziel in maxrange hinzu (maxrange kann nil sein für ganze map) (beendet sofort).
-- Army:AddCommandWaitForTroopSize(size, lessthan, looped)
-- 												wartet darauf, das die armee eine anzahl an truppen hat.
-- Army:AddCommandSetSpawnerStatus(status, looped)
-- 												setzt ob ein spawner neue truppen spawnen/rekrutieren darf (default true).
-- Army:AddCommandWaitForSpawnerFull(looped)	wartet darauf, das ein spawner die armee gefüllt hat (size im spawner) (sofort wahr, wenn kein spawner vorhanden).
-- Army:AddCommandTransferTroops(target)		bewegt die armee zum ziel der UA target, und wenn beide nah genug aneinander sind, transferiert alle truppen zu target (und schaltet zum nächsten command).
-- 													transferiert auch alle truppen, wenn target tot ist. AutoDestroyIfEmpty ist empfohlen.
-- 													(wenn target destroyed ist, schaltet zum nächsten command)
-- Army:AddCommandRallypoint(onExpedition, expeditionSize, numberExpeditions, enabled)
-- 													nutzt diese army als sammelpunkt für einen spawner oder recruiter und sendet expeditionen aus.
-- 													immer wenn genug truppen für eine expedition vorhanden sind, erstellt eine neue UA, transferiert truppen und schickt sie los.
-- 													expeditionSize ist die truppen stärke einer expedition.
-- 													numberExpeditions die maximale anzahl an expeditionen, nil für unbegrenzt.
-- 													onExpedition(expeditionUA, command, rallyUA) wird aufgerufen, um die expedition loszuschicken. die expeditionUA hat schon alle truppen.
-- 													enabled bool oder func(rallyUA, command) aktiv (nil wird zu true).
-- 													command.Create(rallyUA, command) kann überschrieben werden, um die erstellte UA zu ersetzen (z.b. mit einer LazyUA).
-- 													command.ArmyCtor wird an UnlimitedArmy:New übergeben (Player und Area werden aus der rallyUA übernommen, wenn nicht gesetzt).
-- 														AutoDestroyIfEmpty ist zu beginn gesetzt.
-- 													command.Cmd wird von der rallyUA ausgeführt, empfehle CreateCommandDefend oder nil.
-- 													expeditionen können mit AddCommandTransferTroops zurück in den cache recycelt werden.
-- Army:AddCommandWaitSeconds(s)				wartet s sekunden
-- Army:CreateLeaderForArmy(ety, sol, pos, experience)
-- 												erstellt einen leader und verbindet ihn mit der army.
-- Army:Iterator(transit)						gibt einen iterator zurück, der über alle leader der armee iteriert, zu verwenden: for id in Army:Iterator() do.
-- 													den zurückgegebenen iterator nicht speichern, enthält upvalues.
-- Army:SetLeaderFormation(form)				setzt die formation die die soldier der leader der armee einnehmen. kann eine function(army, id) sein.
-- Army:IsLeaderPartOfArmy(id)					tested, ob ein leader teil der army ist.
-- Army:SetIgnoreFleeing(b)						setzt, ob fliehende einheiten ignoriert werden.
-- Army:CanPathTo(p)							prüft, ob die ua die position des entities p erreichen kann. Mit CppLogic kann p ein pos-tabe sein.
-- 
-- 
-- Benötigt:
-- - CopyTable
-- - CppLogic (optional, aber ohne eingeschränkte funktionalität (Heldenfähigkeiten und zielfindung))
-- - PredicateHelper (optional, siehe CppLogic)
-- - GetDistance
-- - IsEntityOfType
-- - GetCirclePosition
-- - GetAngleBetween
-- - TriggerFix
-- - EntityIdChangedHelper
-- - LuaObject
-- - TargetFilter
-- - IsValidPosition
--- @class UnlimitedArmy : LuaObject
--- @field Leaders number[]
--- @field Player number
--- @field AutoDestroyIfEmpty boolean?
--- @field HadOneLeader boolean?
--- @field Trigger Trigger
--- @field Area number
--- @field CurrentBattleTarget number?
--- @field Target Position?
--- @field FormationRotation number?
--- @field Formation fun(ua:UnlimitedArmy, p:Position)
--- @field CommandQueue UACommand[]
--- @field ReMove boolean?
--- @field HeroTargetingCache table<number, number>
--- @field PrepDefense boolean?
--- @field FormationResets table
--- @field DestroyBridges boolean?
--- @field CannonCommandCache table
--- @field LeaderTransit number[]
--- @field TransitAttackMove boolean?
--- @field LeaderFormation number|nil|fun(ua:UnlimitedArmy, id:number):number
--- @field AIActive boolean?
--- @field SpawnerActive boolean
--- @field DeadHeroes number[]
--- @field DefendDoNotHelpHeroes boolean?
--- @field AutoRotateRange number?
--- @field DoNotNormalizeSpeed boolean?
--- @field SpeedNormalizationFactors table
--- @field PosCacheTick number
--- @field PosCache Position
--- @field IgnoreFleeing boolean?
--- @field ForceNoHook boolean?
--- @field TroopsPerLine number?
--- @field ChaoticCache table<number,PositionR>
--- @field EntityChangedTriggerId Trigger
--- @field ConversionTrigger Trigger
--- @field WaitForTick number?
--- @field Status UAStatus
UnlimitedArmy = {}

--- @type UnlimitedArmyFiller|nil
UnlimitedArmy.Spawner = nil
---@type UACore|nil
UnlimitedArmy.UACore = nil
--- @type UnlimitedArmy
UnlimitedArmy = LuaObject:CreateSubClass("UnlimitedArmy")

UnlimitedArmy:AStatic()
---@enum UAStatus
UnlimitedArmy.Status = {Idle = 1, Moving = 2, Battle = 3, Destroyed = 4, IdleUnformated = 5, MovingNoBattle = 6}

if false then
	---@class UACreator
	---@field Player number
	---@field Area number
	---@field Formation fun(ua:UnlimitedArmy, p:Position)?
	---@field AutoDestroyIfEmpty boolean?
	---@field PrepDefense boolean?
	---@field DestroyBridges boolean?
	---@field AIActive boolean?
	---@field DefendDoNotHelpHeroes boolean?
	---@field AutoRotateRange number?
	---@field DoNotNormalizeSpeed boolean?
	---@field IgnoreFleeing boolean?
	---@field TransitAttackMove boolean?
	---@field HiResJob boolean?
	---@field LeaderFormation number|nil|fun(ua:UnlimitedArmy, id:number):number
	local UACreator = {}

	---@class UACommand
	---@field Command fun(ua:UnlimitedArmy, c:UACommand):boolean,UACommand?
	local UACommand = {}

	---@class UARallypointCommand : UACommand
	---@field Create fun(parent:UnlimitedArmy, cmd:UARallypointCommand) kann überschrieben werden, um die erstellte UA zu ersetzen (z.b. mit einer LazyUA)
	---@field ArmyCtor UACreator|nil wird an UnlimitedArmy:New übergeben (Player und Area werden aus der rallyUA übernommen, wenn nicht gesetzt). AutoDestroyIfEmpty ist zu beginn gesetzt.
	---@field Cmd UACommand|nil wird von der rallyUA ausgeführt, empfehle CreateCommandDefend oder nil
	local UARallypointCommand = {}
end

UnlimitedArmy:AReference()
--- erstellt eine neue UnlimitedArmy.
--- @param data UACreator
--- @return UnlimitedArmy
---@diagnostic disable-next-line: missing-return
function UnlimitedArmy:New(data) end

UnlimitedArmy:AMethod()
---konstruktor (von LuaObject:Init aufgerufen)
---@param data UACreator
function UnlimitedArmy:Init(data)
	self:CallBaseMethod("Init", UnlimitedArmy)
	---@type number[]
	self.Leaders = {}
	self.Player = assert(data.Player)
	self.Area = assert(data.Area)
	self.FormationRotation = 0
	self.Formation = data.Formation or UnlimitedArmy.Formations.Chaotic
	self.AutoDestroyIfEmpty = data.AutoDestroyIfEmpty
	self.HadOneLeader = false
	self.PrepDefense = data.PrepDefense
	self.DestroyBridges = data.DestroyBridges
	self.AIActive = data.AIActive
	self.DefendDoNotHelpHeroes = data.DefendDoNotHelpHeroes
	self.AutoRotateRange = data.AutoRotateRange
	self.DoNotNormalizeSpeed = data.DoNotNormalizeSpeed
	self.IgnoreFleeing = data.IgnoreFleeing
	self.CommandQueue = {}
	self.HeroTargetingCache = {}
	self.FormationResets = {}
	self.CannonCommandCache = {}
	---@type number[]
	self.LeaderTransit = {}
	self.DeadHeroes = {}
	self.SpeedNormalizationFactors = {}
	self.TransitAttackMove = data.TransitAttackMove
	self.SpawnerActive = true
	self.ChaoticCache = {}
	self.Status = UnlimitedArmy.Status.Idle
	if data.HiResJob then
		self.Trigger = StartSimpleHiResJob(":Tick", self)
	else
		self.Trigger = StartSimpleJob(":Tick", self)
	end
	self.EntityChangedTriggerId = Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_ENTITY_ID_CHANGED, nil, ":OnIdChanged", 1, nil, {self})
	if UnlimitedArmy.HasHook() then
		self.ConversionTrigger = Trigger.RequestTrigger(Events.SCRIPT_EVENT_ON_CONVERT_ENTITY, nil, ":OnConversion", 1, nil, {self})
	end
	self:SetLeaderFormation(data.LeaderFormation)
	self:CheckUACore()
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:CheckUACore()
	if UnlimitedArmy.HasHook() and not self.UACore then
		self.UACore = CppLogic.UA.New(self.Player, function(self, r)
			if self.AutoRotateRange then
				self.FormationRotation = r
			end
			local t = self.Target
			if CppLogic.Logic.LandscapeGetSector(t) == 0 then
				t = CppLogic.Logic.LandscapeGetNearestUnblockedPosInSector(t, Logic.GetSector(self:Iterator()()), 1500)
			end
			self:Formation(t)
		end, self.ProcessCommandQueue, function(self)
			if self.Spawner then
				self.Spawner:Tick(self.SpawnerActive)
			end
		end, GetRandom(0, 1073741824))
		self.UACore:SetArea(self.Area)
		self.UACore:SetIgnoreFleeing(self.IgnoreFleeing)
		self.UACore:SetAutoRotateFormation(self.AutoRotateRange or -1)
		self.UACore:SetPrepDefense(self.PrepDefense)
		self.UACore:SetSabotageBridges(self.DestroyBridges)
		self.UACore:SetDoNotNormalizeSpeed(self.DoNotNormalizeSpeed)
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:CheckValidArmy()
	assert(self.Status ~= UnlimitedArmy.Status.Destroyed)
	assert(self ~= UnlimitedArmy)
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:Tick()
	self:CheckValidArmy()
	self:CheckUACore()
	if self.UACore then
		self.UACore:Tick(self)
		if self.AutoDestroyIfEmpty and self.HadOneLeader and not self.Spawner and self.UACore:GetSize(true, true) == 0 then
			self:Destroy()
			return
		end
		return
	end

	self:RemoveAllDestroyedLeaders()
	if self:GetSize() == 0 and self.LeaderTransit[1] then
		table.insert(self.Leaders, table.remove(self.LeaderTransit, 1))
		self.ReMove = true
		self:RequireNewFormat()
	end
	self:HandleTransit()
	if self:GetSize(true, true) == 0 then
		if self.AutoDestroyIfEmpty and self.HadOneLeader and not self.Spawner then
			self:Destroy()
			return
		end
		if self.Spawner then
			self.Spawner:Tick(self.SpawnerActive)
		end
		self:ProcessCommandQueue()
		self:RemoveAllDestroyedLeaders()
		return
	end
	if self.Spawner then
		self.Spawner:Tick(self.SpawnerActive)
	end
	self:RefreshPosCache()
	local pos = self:GetPosition()
	local preventfurthercommands = false
	if not UnlimitedArmy.IsValidTarget(self.CurrentBattleTarget, self.Player, self.AIActive)
		or GetDistance(pos, self.CurrentBattleTarget)>self.Area
		or (self.IgnoreFleeing and UnlimitedArmy.IsEntityFleeingFrom(self.CurrentBattleTarget, pos))then
		if (self.IgnoreFleeing and UnlimitedArmy.IsEntityFleeingFrom(self.CurrentBattleTarget, pos)) then
			self.ReMove = true
		end
		self.CurrentBattleTarget = UnlimitedArmy.GetTargetEnemiesInArea(pos, self.Player, self.Area, self.AIActive, self.IgnoreFleeing, self.CurrentBattleTarget)
		self.CannonCommandCache = {}
	end
	if not preventfurthercommands and self.Status ~= UnlimitedArmy.Status.MovingNoBattle and IsValid(self.CurrentBattleTarget) then
		self:CheckStatus(UnlimitedArmy.Status.Battle)
		preventfurthercommands = true
	end
	if not preventfurthercommands and GetDistance(pos, self.Target) > 1000 then
		if self.Status ~= UnlimitedArmy.Status.MovingNoBattle and self.Status ~= UnlimitedArmy.Status.Moving then
			self:CheckStatus(UnlimitedArmy.Status.Moving)
		end
		preventfurthercommands = true
	end
	if not preventfurthercommands then
		self:CheckStatus(UnlimitedArmy.Status.Idle)
		if self.AutoRotateRange then
			local tid = UnlimitedArmy.GetTargetEnemiesInArea(pos, self.Player, self.AutoRotateRange, self.AIActive, self.IgnoreFleeing)
			if tid and math.abs(GetAngleBetween(pos, GetPosition(tid)) - self.FormationRotation) > 10 then
				self.FormationRotation = GetAngleBetween(pos, GetPosition(tid))
				self.ReMove = true
			end
		end
		preventfurthercommands = true
	end
	self:ProcessCommandQueue()
	self:RemoveAllDestroyedLeaders()
	if self.Status == UnlimitedArmy.Status.Battle then
		self:DoBattleCommands()
	elseif self.Status == UnlimitedArmy.Status.Moving or self.Status == UnlimitedArmy.Status.MovingNoBattle then
		self:DoMoveCommands()
	elseif self.Status == UnlimitedArmy.Status.Idle then
		self:DoFormationCommands()
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:HandleTransit()
	if self.LeaderTransit[1] then
		local p = self:GetPosition()
		for i = table.getn(self.LeaderTransit), 1, -1 do
			if IsDestroyed(self.LeaderTransit[i]) then
				table.remove(self.LeaderTransit, i)
			elseif IsDead(self.LeaderTransit[i]) and Logic.IsHero(self.Leaders[i]) == 1 then
				table.insert(self.DeadHeroes, table.remove(self.LeaderTransit, i))
			elseif GetDistance(p, self.LeaderTransit[i]) < self.Area then
				table.insert(self.Leaders, table.remove(self.LeaderTransit, i))
				self.ReMove = true
				self:RequireNewFormat()
			elseif self.TransitAttackMove then
				if UnlimitedArmy.IsLeaderIdle(self.LeaderTransit[i]) then
					Logic.GroupAttackMove(self.LeaderTransit[i], p.X, p.Y, -1)
				end
			else
				if not UnlimitedArmy.IsLeaderMoving(self.LeaderTransit[i]) then
					Move(self.LeaderTransit[i], p)
				end
			end
		end
	end
	if self.DeadHeroes[1] then
		for i = table.getn(self.DeadHeroes), 1, -1 do
			if IsDestroyed(self.DeadHeroes[i]) then
				table.remove(self.DeadHeroes, i)
			elseif IsAlive(self.DeadHeroes[i]) then
				self:AddLeader(table.remove(self.DeadHeroes, i))
			end
		end
	end
end

UnlimitedArmy:AMethod()
---@param st UAStatus
function UnlimitedArmy:CheckStatus(st)
	self:CheckValidArmy()
	if self.Status ~= st then
		self.Status = st
		self.ReMove = true
	end
end

UnlimitedArmy:AMethod()
---fügt einen leader der UA hinzu
---@param id number|string
function UnlimitedArmy:AddLeader(id)
	self:CheckValidArmy()
	self:CheckUACore()
	id = GetID(id)
	if self.UACore then
		self.UACore:AddLeader(id)
		if not self.Target then
			self.Target = GetPosition(id)
		end
	else
		local p = self:GetPosition()
		if p == invalidPosition or GetDistance(p, id) < self.Area then
			table.insert(self.Leaders, id)
			if not self.Target then
				self.Target = GetPosition(id)
			end
			self:RequireNewFormat()
			self.PosCacheTick = -1
			if self.Status == UnlimitedArmy.Status.Moving or self.Status == UnlimitedArmy.Status.MovingNoBattle then
				self:SetReMove(true)
			end
		else
			table.insert(self.LeaderTransit, id)
		end
	end
	if self.LeaderFormation then
		self:SetLeaderFormationForLeader(id)
	end
	self.HadOneLeader = true
end

UnlimitedArmy:AMethod()
---entfernt einen leader
---@param id number|string
function UnlimitedArmy:RemoveLeader(id)
	self:CheckValidArmy()
	self:CheckUACore()
	id = GetID(id)
	if self.UACore then
		self.UACore:RemoveLeader(id)
	else
		for i = table.getn(self.Leaders), 1, -1 do
			if self.Leaders[i] == id then
				table.remove(self.Leaders, i)
			end
		end
		for i = table.getn(self.LeaderTransit), 1, -1 do
			if self.LeaderTransit[i] == id then
				table.remove(self.LeaderTransit, i)
			end
		end
		for i = table.getn(self.DeadHeroes), 1, -1 do
			if self.DeadHeroes[i] == id then
				table.remove(self.DeadHeroes, i)
			end
		end
		self:RequireNewFormat()
		if self.Status == UnlimitedArmy.Status.Moving or self.Status == UnlimitedArmy.Status.MovingNoBattle then
			self:SetReMove(true)
		end
	end
end

UnlimitedArmy:AMethod()
---spawn einen leader + soldiers für die UACommand
---@param ety number
---@param sol number
---@param pos Position
---@param experience number
function UnlimitedArmy:CreateLeaderForArmy(ety, sol, pos, experience)
	self:CheckValidArmy()
	assert(Logic.GetEntityTypeName(ety))
	assert(IsValidPosition(pos))
	assert(sol >= 0)
	self:AddLeader(AI.Entity_CreateFormation(self.Player, ety, nil, sol, pos.X, pos.Y, nil, nil, experience or 0, 0))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:RequireNewFormat()
	self:CheckValidArmy()
	self:CheckUACore()
	if self.UACore then
		if self.UACore:GetStatus() == UnlimitedArmy.Status.Idle then
			self.UACore:SetStatus(UnlimitedArmy.Status.IdleUnformated)
		end
	else
		if self.Status == UnlimitedArmy.Status.Idle then
			self.Status = UnlimitedArmy.Status.IdleUnformated
		end
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:RemoveAllDestroyedLeaders()
	self:CheckValidArmy()
	for i = table.getn(self.Leaders), 1, -1 do
		if IsDestroyed(self.Leaders[i]) then
			table.remove(self.Leaders, i)
			self:RequireNewFormat()
		elseif IsDead(self.Leaders[i]) and Logic.IsHero(self.Leaders[i]) == 1 then
			table.insert(self.DeadHeroes, table.remove(self.Leaders, i))
			self:RequireNewFormat()
		end
	end
end

UnlimitedArmy:AMethod()
---ermittelt die anzahl der leasder in der UACommand
---@param addTransit boolean?
---@param adddeadhero boolean?
---@return number
function UnlimitedArmy:GetSize(addTransit, adddeadhero)
	self:CheckValidArmy()
	self:CheckUACore()
	if self.UACore then
		return self.UACore:GetSize(addTransit, adddeadhero)
	else
		local r = table.getn(self.Leaders)
		if addTransit then
			r = r + table.getn(self.LeaderTransit)
		end
		if adddeadhero then
			r = r + table.getn(self.DeadHeroes)
		end
		return r
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:Destroy()
	self:SetStatus(UnlimitedArmy.Status.Destroyed)
	self.Status = UnlimitedArmy.Status.Destroyed
	EndJob(self.Trigger)
	EndJob(self.EntityChangedTriggerId)
	EndJob(self.ConversionTrigger)
	if self.Spawner then
		self.Spawner:Remove()
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:KillAllLeaders()
	self:CheckValidArmy()
	for id in self:Iterator(true) do
		if Logic.IsLeader(id) == 1 then
			local soldiers = {Logic.GetSoldiersAttachedToLeader(id)}
			table.remove(soldiers, 1)
			for _, v in ipairs(soldiers) do
				SetHealth(v, 0)
			end
		end
		SetHealth(id, 0)
	end
end

UnlimitedArmy:AMethod()
--- ermittelt die Position der UA.
--- @return Position
function UnlimitedArmy:GetPosition()
	self:CheckValidArmy()
	self:CheckUACore()
	if self.UACore then
		return self.UACore:GetPos()
	else
		self:RemoveAllDestroyedLeaders()
		if self:GetSize() <= 0 then
			return invalidPosition
		end
		if self.PosCacheTick ~= Logic.GetCurrentTurn() then
			self:RefreshPosCache()
		end
		return self.PosCache
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:RefreshPosCache()
	self:CheckValidArmy()
	local num = table.getn(self.Leaders)
	if num == 0 then
		self.PosCache = invalidPosition
		self.PosCacheTick = Logic.GetCurrentTurn()
	end
	local x, y = 0, 0
	for _, id in ipairs(self.Leaders) do
		local p = GetPosition(id)
		x = x + p.X
		y = y + p.Y
	end
	self.PosCache = {X = x / num, Y = y / num}
	self.PosCacheTick = Logic.GetCurrentTurn()
end

UnlimitedArmy:AMethod()
--- @deprecated
function UnlimitedArmy:CheckHeroTargetingCache(tid, d)
	self:CheckValidArmy()
	if not d then
		return true
	end
	if not self.HeroTargetingCache[tid] or self.HeroTargetingCache[tid] < Logic.GetCurrentTurn() then
		self.HeroTargetingCache[tid] = Logic.GetCurrentTurn() + d
		return true
	end
	return false
end

UnlimitedArmy:AMethod()
---@param id number
---@param numEnemiesNearby number
---@return boolean noCommands
function UnlimitedArmy:DoHeroAbilities(id, numEnemiesNearby)
	self:CheckValidArmy()
	if Logic.IsHero(id) == 0 and not UnlimitedArmy.IsNonCombatEntity(id) then
		return false
	end
	local noninstant = false
	for ab, acf in pairs(UnlimitedArmy.HeroAbilityConfigs) do
		if not (noninstant and acf.IsInstant) then
			if Logic.HeroIsAbilitySupported(id, ab) == 1 and Logic.HeroGetAbiltityChargeSeconds(id, ab) == Logic.HeroGetAbilityRechargeTime(id, ab) then
				local executeAbility = true
				if acf.RequiredEnemiesInArea then
					if acf.RequiredRange then
						if UnlimitedArmy.GetNumberOfEnemiesInArea(GetPosition(id), self.Player, acf.RequiredRange, self.IgnoreFleeing) < acf.RequiredEnemiesInArea then
							executeAbility = false
						end
					else
						if numEnemiesNearby < acf.RequiredEnemiesInArea then
							executeAbility = false
						end
					end
				end
				if acf.PreventUse and acf.PreventUse(self, id) then
					executeAbility = false
				end
				if executeAbility then
					acf.Use(self, id)
					noninstant = not acf.IsInstant
				end
			end
		end
	end
	return noninstant
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:DoBattleCommands()
	self:CheckValidArmy()
	if self.ReMove then
		self:NormalizeSpeed(false)
	end
	local tpos = GetPosition(self.CurrentBattleTarget)
	-- Logic.CreateEffect(GGL_Effects.FXSalimHeal, tpos.X, tpos.Y, 0)
	local nume = UnlimitedArmy.GetNumberOfEnemiesInArea(self:GetPosition(), self.Player, self.Area, self.IgnoreFleeing)
	for num, id in ipairs(self.Leaders) do
		local DoCommands = not self:DoHeroAbilities(id, nume)
		if (self.ReMove or not UnlimitedArmy.IsLeaderInBattle(id) or self.CannonCommandCache[id] == -1) and not UnlimitedArmy.IsNonCombatEntity(id) then
			if DoCommands and Logic.IsEntityInCategory(id, EntityCategories.Cannon) == 1 then
				if not self.CannonCommandCache[id] or self.CannonCommandCache[id] == -1 or self.CannonCommandCache[id] < Logic.GetCurrentTurn() then
					self.CannonCommandCache[id] = Logic.GetCurrentTurn() + 1
					Logic.GroupAttack(id, self.CurrentBattleTarget)
				else
					Logic.GroupAttackMove(id, tpos.X, tpos.Y, -1)
					self.CannonCommandCache[id] = -1
				end
			elseif DoCommands and UnlimitedArmy.IsRangedEntity(id) then
				Logic.GroupAttack(id, self.CurrentBattleTarget)
			elseif DoCommands then
				Logic.GroupAttackMove(id, tpos.X, tpos.Y, -1)
			end
		end
	end
	self.ReMove = false
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:DoMoveCommands()
	self:CheckValidArmy()
	if self.ReMove then
		self:NormalizeSpeed(true)
	end
	if self.Status == UnlimitedArmy.Status.MovingNoBattle then
		for _, id in ipairs(self.Leaders) do
			if self.ReMove or not UnlimitedArmy.IsLeaderMoving(id) then
				Move(id, self.Target)
			end
		end
	else
		for _, id in ipairs(self.Leaders) do
			if self.ReMove or UnlimitedArmy.IsLeaderIdle(id) then
				Move(id, self.Target)
			end
		end
	end
	self.ReMove = false
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:DoFormationCommands()
	self:CheckValidArmy()
	if self.ReMove then
		self:NormalizeSpeed(false)
		self:Formation(self.Target)
	end
	self.ReMove = false
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:ProcessCommandQueue()
	self:CheckValidArmy()
	local com = self.CommandQueue[1]
	if com then
		self:ProcessCommand(com, table.getn(self.CommandQueue))
	end
end

UnlimitedArmy:AMethod()
---@param com UACommand
---@param ind number
function UnlimitedArmy:ProcessCommand(com, ind)
	local adv, rep = com.Command(self, com)
	if adv and com == self.CommandQueue[1] then
		self:AdvanceCommand()
	end
	if rep and ind > 0 then
		self:ProcessCommand(rep, ind - 1)
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AdvanceCommand()
	self:CheckValidArmy()
	if self.CommandQueue[1] then
		local c = table.remove(self.CommandQueue, 1)
		if c.Looped then
			table.insert(self.CommandQueue, c)
		end
	end
end

UnlimitedArmy:AMethod()
---@return number|nil
function UnlimitedArmy:GetFirstEnemyInArmyRange()
	self:CheckValidArmy()
	self:CheckUACore()
	return UnlimitedArmy.GetTargetEnemiesInArea(self:GetPosition(), self.Player, self.Area, self.AIActive, self.IgnoreFleeing)
end

UnlimitedArmy:AMethod()
---@return boolean
function UnlimitedArmy:IsIdle()
	self:CheckValidArmy()
	self:CheckUACore()
	if self.UACore then
		return self.UACore:IsIdle()
	else
		if self:GetSize(true, false) <= 0 then
			return true
		end
		if self.Status ~= UnlimitedArmy.Status.Idle then
			return false
		end
		if self.LeaderTransit[1] then
			return false
		end
		if GetDistance(self:GetPosition(), self.Target) > 1000 then
			return false
		end
		for _, id in ipairs(self.Leaders) do
			if not UnlimitedArmy.IsLeaderIdle(id) then
				return false
			end
		end
		return true
	end
end

UnlimitedArmy:AMethod()
--- false->alive, -1->destroyed, 2->kein leader, aber spawner, 1->kein leader, 3->hatte keinen leader, false->min 1 leader, 4->nur noch tote helden.
---@return boolean|number
function UnlimitedArmy:IsDead()
	if self.Status == UnlimitedArmy.Status.Destroyed then
		return -1
	end
	if self:GetSize(true, false) == 0 then
		if self.Spawner then
			return 2
		end
		if not self.HadOneLeader then
			return 3
		end
		if self.UACore and self.UACore:GetFirstDeadHero() or self.DeadHeroes[1] then
			return 4
		end
		return 1
	end
	return false
end

UnlimitedArmy:AMethod()
---@return number[]
---@return number[]
---@return number[]
function UnlimitedArmy:GetRangedAndMelee()
	self:CheckValidArmy()
	self:CheckUACore()
	if self.UACore then
		return self.UACore:GetRangedMelee()
	else
		local r, m, n = {}, {}, {}
		for _, id in ipairs(self.Leaders) do
			if UnlimitedArmy.IsRangedEntity(id) then
				table.insert(r, id)
			elseif UnlimitedArmy.IsNonCombatEntity(id) then
				table.insert(n, id)
			else
				table.insert(m, id)
			end
		end
		return r, m, n
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:ClearCommandQueue()
	self:CheckValidArmy()
	self.CommandQueue = {}
end

UnlimitedArmy:AMethod()
--- fügt einen bewegungsbefehl hinzu.
--- Befehl ist sofort beendet, eventuell einen WaitForIdle danach ausführen.
--- @param p Position
--- @param looped boolean?
--- @return UACommand
function UnlimitedArmy:AddCommandMove(p, looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandMove(p, looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
--- fügt einen bewegungsbefehl hinzu, während dem die UA nicht anhält um zu kämpfen.
--- Befehl ist sofort beendet, eventuell einen WaitForIdle danach ausführen.
--- @param p Position
--- @param looped boolean?
--- @return UACommand
function UnlimitedArmy:AddCommandFlee(p, looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandFlee(p, looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen verteidigungsbefehl hinzu.
---(beendet wenn keine leader mehr übrig)(pos/area optional).
---sucht nach gegnern in agressiveArea or self.Area, kehrt zu defendPos zurück, wenn außerhalb von defendArea.
---@param defendPos Position|nil
---@param defendArea any
---@param looped any
---@param agressiveArea any
---@return table
function UnlimitedArmy:AddCommandDefend(defendPos, defendArea, looped, agressiveArea)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandDefend(defendPos, defendArea or self.Area, looped, agressiveArea)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen wartebefehl hinzu. beendet, wenn die UA idle ist.
---@param looped boolean?
---@return UACommand
function UnlimitedArmy:AddCommandWaitForIdle(looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandWaitForIdle(looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen wartebefehl hinzu. beendet, wenn die UA die entsprechende anzahl an leadern hat.
---@param size number
---@param lessthan boolean?
---@param looped boolean?
---@return UACommand
function UnlimitedArmy:AddCommandWaitForTroopSize(size, lessthan, looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandWaitForTroopSize(size, lessthan, looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen benutzerdefinierten befehl hinzu.
---@param func fun(ua:UnlimitedArmy, c:UACommand):boolean,UACommand?
---@param looped boolean?
---@return UACommand
function UnlimitedArmy:AddCommandLuaFunc(func, looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandLuaFunc(func, looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen angriffsbefehl hinzu.
---beendet, wenn die UA tot ist, oder ein angriffsziel gefunden wurde.
---ist maxrange nil, wird die ganze map abgesucht.
---@param maxrange number?
---@param looped boolean?
---@return UACommand
function UnlimitedArmy:AddCommandAttackNearestTarget(maxrange, looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandAttackNearestTarget(maxrange, looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen spawnerbefehl hinzu um den spawner an/aus zu schalten.
---beendet sofort.
---@param spawnerActive boolean
---@param looped boolean?
---@return UACommand
function UnlimitedArmy:AddCommandSetSpawnerStatus(spawnerActive, looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandSetSpawnerStatus(spawnerActive, looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen wartebefehl hinzu, der beendet wird, wenn der spawner die UA auf volle stärke gebracht hat.
---@param looped boolean?
---@return UACommand
function UnlimitedArmy:AddCommandWaitForSpawnerFull(looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandWaitForSpawnerFull(looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen bewachen befehl hinzu.
---beendet, wenn ziel oder UA tot.
---@param target number|string
---@param looped boolean?
---@return UACommand
function UnlimitedArmy:AddCommandGuardEntity(target, looped)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandGuardEntity(target, looped)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
--- nutzt diese army als sammelpunkt für einen spawner oder recruiter und sendet expeditionen aus.
--- immer wenn genug truppen für eine expedition vorhanden sind, erstellt eine neue UA, transferiert truppen und schickt sie los.
--- expeditionen können mit AddCommandTransferTroops zurück in den cache recycelt werden.
--- beendet nicht.
---@param onExpedition fun(exped:UnlimitedArmy, c:UACommand, parent:UnlimitedArmy) wird aufgerufen, um die expedition loszuschicken. die expeditionUA hat schon alle truppen.
---@param expeditionSize number anzahl der leader pro expedition
---@param numberExpeditions number? maximalzahl der expeditionen, nil->kein limit
---@param enabled boolean|nil|fun(ua:UnlimitedArmy, c:UACommand) aktiv (nil wird zu true)
---@return UARallypointCommand
function UnlimitedArmy:AddCommandRallypoint(onExpedition, expeditionSize, numberExpeditions, enabled)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandRallypoint(onExpedition, expeditionSize, numberExpeditions, enabled)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt einen command hinzu, der alle truppen der UA an eine andere UA transferiert.
---beendet sofort.
---@param target UnlimitedArmy
---@return UACommand
function UnlimitedArmy:AddCommandTransferTroops(target)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandTransferTroops(target)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
---fügt ein command hinzu, der nach s sekunden beendet.
---@param s number
---@return UACommand
function UnlimitedArmy:AddCommandWaitSeconds(s)
	self:CheckValidArmy()
	local t = UnlimitedArmy.CreateCommandWaitSeconds(s)
	table.insert(self.CommandQueue, t)
	return t
end

UnlimitedArmy:AMethod()
--- iteriert über alle leader in der UA.
--- (die iterator func nutzt upvalues)
--- @return fun():number?
function UnlimitedArmy:Iterator(transit)
	self:CheckValidArmy()
	self:CheckUACore()
	if self.UACore then
		local func, ud, index = self.UACore:Iterate()
		local changed = false
		return function()
			local id = nil
			index, id = func(ud, index)
			if not id and transit and not changed then
				func, ud, index = self.UACore:IterateTransit()
				index, id = func(ud, index)
				changed = true
			end
			return id
		end
	else
		local k = table.getn(self.Leaders) + 1
		local t = self.Leaders
		return function()
			k = k - 1
			if t[k] then
				return t[k]
			end
			if t == self.Leaders and transit then
				t = self.LeaderTransit
				k = table.getn(self.LeaderTransit)
				return t[k]
			end
			return nil
		end
	end
end

UnlimitedArmy:AMethod()
---@param normalize boolean
---@param forcerefresh boolean?
function UnlimitedArmy:NormalizeSpeed(normalize, forcerefresh)
	self:CheckValidArmy()
	if self.DoNotNormalizeSpeed and not forcerefresh then
		return
	end
	if normalize and not self.DoNotNormalizeSpeed then
		local lowest = nil
		for id in self:Iterator() do
			local s = GetEntityMovementSpeed(id)
			if not lowest or lowest > s then
				lowest = s
			end
		end
		for id in self:Iterator() do
			local f = lowest / GetEntityMovementSpeed(id)
			Logic.SetSpeedFactor(id, f)
			if Logic.IsLeader(id) == 1 and Logic.LeaderGetMaxNumberOfSoldiers(id) > 0 and Logic.LeaderGetNumberOfSoldiers(id) > 0 then
				local d = {Logic.GetSoldiersAttachedToLeader(id)}
				table.remove(d, 1)
				for _, ids in ipairs(d) do
					Logic.SetSpeedFactor(ids, f)
				end
			end
		end
	else
		for id in self:Iterator() do
			Logic.SetSpeedFactor(id, 1)
			if Logic.IsLeader(id) == 1 and Logic.LeaderGetMaxNumberOfSoldiers(id) > 0 and Logic.LeaderGetNumberOfSoldiers(id) > 0 then
				local d = {Logic.GetSoldiersAttachedToLeader(id)}
				table.remove(d, 1)
				for _, ids in ipairs(d) do
					Logic.SetSpeedFactor(ids, 1)
				end
			end
		end
	end
end

UnlimitedArmy:AMethod()
---setzt, ob die geschwindigkeit der leader normalisiert werden sollen
---@param val boolean
function UnlimitedArmy:SetDoNotNormalizeSpeed(val)
	self:CheckValidArmy()
	if self.UACore then
		self.UACore:SetDoNotNormalizeSpeed(val)
	else
		self.DoNotNormalizeSpeed = val
		self:NormalizeSpeed(self.Status == UnlimitedArmy.Status.Moving or self.Status == UnlimitedArmy.Status.MovingNoBattle, true)
	end
end

UnlimitedArmy:AMethod()
---setzt die leader formation der leader. (formation der soldier um den leader)
---@param form number|nil|fun(ua:UnlimitedArmy, id:number):number
function UnlimitedArmy:SetLeaderFormation(form)
	self:CheckValidArmy()
	self.LeaderFormation = form
	if form then
		for id in self:Iterator(true) do
			self:SetLeaderFormationForLeader(id)
		end
	end
end

UnlimitedArmy:AMethod()
---prüft, ob ein leader in der UA ist
---@param id number|string
---@return boolean
function UnlimitedArmy:IsLeaderPartOfArmy(id)
	self:CheckValidArmy()
	id = GetID(id)
	for i in self:Iterator(true) do
		if i == id then
			return true
		end
	end
	return false
end

UnlimitedArmy:AMethod()
---@param id number
function UnlimitedArmy:SetLeaderFormationForLeader(id)
	self:CheckValidArmy()
	local f = self.LeaderFormation
	if not f then
		return
	end
	if type(f) ~= "number" then
		f = f(self, id)
	end
	Logic.LeaderChangeFormationType(id, f)
end

UnlimitedArmy:AMethod()
---setzt die zielposition der UA.
---@param p Position
---@return nil
function UnlimitedArmy:SetTarget(p)
	self:CheckUACore()
	self.Target = p
	if self.UACore then
		return self.UACore:SetTarget(p)
	end
end

UnlimitedArmy:AMethod()
---gibt den status der UA zurück
---@return UAStatus
function UnlimitedArmy:GetStatus()
	self:CheckUACore()
	if self.UACore then
		return self.UACore:GetStatus()
	else
		return self.Status
	end
end

UnlimitedArmy:AMethod()
---@param s UAStatus
function UnlimitedArmy:SetStatus(s)
	self:CheckUACore()
	if self.UACore then
		self.UACore:SetStatus(s)
	else
		self.Status = s
	end
end

UnlimitedArmy:AMethod()
---@param s boolean
function UnlimitedArmy:SetReMove(s)
	self:CheckUACore()
	if self.UACore then
		self.UACore:SetReMove(s)
	else
		self.ReMove = s
	end
end

UnlimitedArmy:AMethod()
---@param id number
function UnlimitedArmy:SetCurrentBattleTarget(id)
	self:CheckUACore()
	if self.UACore then
		self.UACore:SetCurrentBattleTarget(id)
	else
		self.CurrentBattleTarget = id
	end
end

UnlimitedArmy:AMethod()
---setzt, ob die UA fliehende gegner ignoriert
---@param b boolean
function UnlimitedArmy:SetIgnoreFleeing(b)
	self:CheckUACore()
	self.IgnoreFleeing = b
	if self.UACore then
		self.UACore:SetIgnoreFleeing(b)
	end
end

UnlimitedArmy:AMethod()
---setzt die reichweite, in der die UA ihre formation zum nächsten gegner rotiert.
---@param r number?
function UnlimitedArmy:SetAutoRotateRange(r)
	self:CheckUACore()
	if self.UACore then
		self.UACore:SetAutoRotateFormation(r or -1)
	end
	self.AutoRotateRange = r
end

UnlimitedArmy:AMethod()
---setzt, ob die UA sich auf verteidigung vorbereitet. (etwa durch das aufstellen von pilgrims kanonen).
---@param r boolean
function UnlimitedArmy:SetPrepDefense(r)
	self:CheckUACore()
	if self.UACore then
		self.UACore:SetPrepDefense(r)
	else
		self.PrepDefense = r
	end
end

UnlimitedArmy:AMethod()
---setzt, ob die UA brücken in reichweite sprengt.
---@param r boolean
function UnlimitedArmy:SetSabotageBridges(r)
	self:CheckUACore()
	if self.UACore then
		self.UACore:SetSabotageBridges(r)
	else
		self.DestroyBridges = r
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:OnIdChanged()
	self:CheckValidArmy()
	local ol, ne = Event.GetEntityID1(), Event.GetEntityID2()
	self:CheckUACore()
	if self.UACore then
		self.UACore:OnIdChanged(ol, ne)
	else
		for i, id in ipairs(self.Leaders) do
			if id == ol then
				self.Leaders[i] = ne
			end
		end
		for i, id in ipairs(self.LeaderTransit) do
			if id == ol then
				self.LeaderTransit[i] = ne
			end
		end
		for i, id in ipairs(self.DeadHeroes) do
			if id == ol then
				self.DeadHeroes[i] = ne
			end
		end
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:OnConversion()
	self:CheckValidArmy()
	if self.Player ~= Event.GetPlayerID() then
		return
	end
	local helias = Event.GetEntityID()
	local conv = Event.GetEntityID2()
	if self:IsLeaderPartOfArmy(helias) then
		self:AddLeader(conv)
	end
end

UnlimitedArmy:AMethod()
---prüft, ob die UA sich zu einem ziel bewegen kann.
---@param p Position|number|string
---@return boolean
function UnlimitedArmy:CanPathTo(p)
	local targetSector = 0
	if IsAlive(p) then
		targetSector = Logic.GetSector(GetID(p))
	elseif UnlimitedArmy.HasHook() then
		---@diagnostic disable-next-line: param-type-mismatch
		targetSector = CppLogic.Logic.LandscapeGetSector(p)
	else
		assert(false, "cannot get target sector")
	end
	if targetSector == 0 then
		return false
	end
	local firstid = self:Iterator()()
	if not firstid or IsDead(firstid) then
		return false
	end
	return Logic.GetSector(firstid) == targetSector
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.HasHook()
	if UnlimitedArmy.ForceNoHook then
		return false
	end
	return CppLogic and TriggerFixCppLogicExtension and FrameworkWrapper
end

UnlimitedArmy:AStatic()
---@param p Position
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandMove(p, looped)
	assert(IsValidPosition(p))
	return {
		Pos = p,
		Looped = looped,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			self:SetTarget(com.Pos)
			if self:GetStatus() ~= UnlimitedArmy.Status.Battle then
				self:SetStatus(UnlimitedArmy.Status.Moving)
			end
			if self:GetStatus() == UnlimitedArmy.Status.Moving then
				self:SetReMove(true)
			end
			return true
		end
	}
end

UnlimitedArmy:AStatic()
---@param p Position
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandFlee(p, looped)
	assert(IsValidPosition(p))
	return {
		Pos = p,
		Looped = looped,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			self:SetTarget(com.Pos)
			self:SetStatus(UnlimitedArmy.Status.MovingNoBattle)
			self:SetReMove(true)
			return true
		end
	}
end

UnlimitedArmy:AStatic()
---@param defendPos Position|nil
---@param defendArea number
---@param looped boolean?
---@param agressiveArea number?
---@return UACommand
function UnlimitedArmy.CreateCommandDefend(defendPos, defendArea, looped, agressiveArea)
	assert(defendPos == nil or IsValidPosition(defendPos))
	return {
		Looped = looped,
		DistArea = defendArea,
		Pos = defendPos,
		AgressiveArea = agressiveArea,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			if com.Pos == nil then
				com.Pos = self:GetPosition()
			end
			local dhid = nil
			if self.UACore then
				dhid = self.UACore:GetFirstDeadHero()
			else
				dhid = self.DeadHeroes[1]
			end
			if self:GetSize(true, false) <= 0 then
				self:SetTarget(com.Pos)
				return true
			elseif not dhid and GetDistance(self:GetPosition(), com.Pos) > com.DistArea then
				self:SetStatus(UnlimitedArmy.Status.MovingNoBattle)
				self:SetTarget(com.Pos)
				self:SetReMove(true)
			elseif self:GetStatus() ~= UnlimitedArmy.Status.Battle then
				local tid = UnlimitedArmy.GetTargetEnemiesInArea(com.Pos, self.Player, com.AgressiveArea or self.Area, self.AIActive, self.IgnoreFleeing)
				if IsValid(tid) then
					self:SetTarget(GetPosition(tid))
					self:SetReMove(true)
					self:SetStatus(UnlimitedArmy.Status.Moving)
				elseif dhid and not self.DefendDoNotHelpHeroes then
					if GetDistance(self.Target, dhid) > 100 then
						self:SetTarget(GetPosition(dhid))
						self:SetReMove(true)
						self:SetStatus(UnlimitedArmy.Status.Moving)
					end
				elseif GetDistance(self.Target, com.Pos) > 100 then
					self:SetTarget(com.Pos)
					self:SetReMove(true)
					self:SetStatus(UnlimitedArmy.Status.Moving)
				end
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandWaitForIdle(looped)
	return {
		Looped = looped,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			if self:IsIdle() then
				return true
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param size number
---@param lessthan boolean?
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandWaitForTroopSize(size, lessthan, looped)
	return {
		Size = size,
		LessThan = lessthan,
		Looped = looped,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			local s = self:GetSize()
			if (s >= com.Size and not com.LessThan) or (s < com.Size and com.LessThan) then
				return true
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param func fun(ua:UnlimitedArmy, c:UACommand):boolean,UACommand?
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandLuaFunc(func, looped)
	return {Looped = looped, Command = func}
end

UnlimitedArmy:AStatic()
---@param maxrange number?
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandAttackNearestTarget(maxrange, looped)
	return {
		MaxRange = maxrange or Logic.WorldGetSize() * 100,
		Looped = looped,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			if self:GetSize(true, false) <= 0 then
				return true
			else
				local tid = UnlimitedArmy.GetTargetEnemiesInArea(self:GetPosition(), self.Player, com.MaxRange, self.AIActive, self.IgnoreFleeing)
				if IsValid(tid) then
					self:SetTarget(GetPosition(tid))
					if self:GetStatus() == UnlimitedArmy.Status.Moving or self:GetStatus() == UnlimitedArmy.Status.Idle then
						self:SetReMove(true)
						self:SetStatus(UnlimitedArmy.Status.Moving)
					end
					return true
				end
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param status boolean
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandSetSpawnerStatus(status, looped)
	return {
		Status = status,
		Looped = looped,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			self.SpawnerActive = com.Status
			return true
		end
	}
end

UnlimitedArmy:AStatic()
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandWaitForSpawnerFull(looped)
	return {
		Looped = looped,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			local s = self:GetSize()
			if not self.Spawner or s >= self.Spawner.ArmySize then
				return true
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param target number|string
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandDirectAttack(target, looped)
	return {
		Looped = looped,
		Target = target,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			if IsDestroyed(com.Target) or self:GetSize(true, false) <= 0 then
				return true
			end
			self:SetCurrentBattleTarget(GetID(com.Target))
			if self:GetStatus() ~= UnlimitedArmy.Status.Battle then
				self:SetStatus(UnlimitedArmy.Status.Battle)
				self:SetReMove(true)
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param target number|string
---@param looped boolean?
---@return UACommand
function UnlimitedArmy.CreateCommandGuardEntity(target, looped)
	return {
		Looped = looped,
		Target = target,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			if IsDestroyed(com.Target) or self:GetSize(true, false) <= 0 then
				return true
			end
			local tp = GetPosition(com.Target)
			if not self.Target or GetDistance(tp, self.Target) > 250 then
				self:SetTarget(tp)
				if self:GetStatus() ~= UnlimitedArmy.Status.Battle then
					self:SetStatus(UnlimitedArmy.Status.Moving)
				end
				if self:GetStatus() == UnlimitedArmy.Status.Moving then
					self:SetReMove(true)
				end
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param onExpedition fun(exped:UnlimitedArmy, c:UACommand, parent:UnlimitedArmy)
---@param expeditionSize number
---@param numberExpeditions number?
---@param enabled boolean|nil|fun(ua:UnlimitedArmy, c:UACommand)
---@return UARallypointCommand
function UnlimitedArmy.CreateCommandRallypoint(onExpedition, expeditionSize, numberExpeditions, enabled)
	if enabled == nil then
		enabled = true
	end
	return {
		OnExpedition = onExpedition,
		ExpeditionSize = expeditionSize,
		Enabled = enabled,
		NumberExpeditions = numberExpeditions,
		ArmyCtor = {AutoDestroyIfEmpty = true},
		Children = {},
		--- @param self UnlimitedArmy
		Command = function(self, com)
			for i = table.getn(com.Children), 1, -1 do
				if com.Children[i]:IsDead() == -1 then
					table.remove(com.Children, i)
				end
			end
			if self:GetSize() >= com.ExpeditionSize and (not com.NumberExpeditions or table.getn(com.Children) < com.NumberExpeditions) then
				local e = com.Enabled
				if type(e) == "function" then
					e = e(self, com)
				end
				if e then
					local ua = com.CreateAndFill(self, com)
					if ua then
						table.insert(com.Children, ua)
						com.OnExpedition(ua, com, self)
					end
				end
			end
			return false, com.Cmd
		end,
		--- @param self UnlimitedArmy
		Create = function(self, com)
			if not com.ArmyCtor.Player then
				com.ArmyCtor.Player = self.Player
			end
			if not com.ArmyCtor.Area then
				com.ArmyCtor.Area = self.Area
			end
			return UnlimitedArmy:New(com.ArmyCtor)
		end,
		--- @param self UnlimitedArmy
		CreateAndFill = function(self, com)
			local num = com.ExpeditionSize
			local t = {}
			for id in self:Iterator() do
				if num <= 0 then
					break
				end
				table.insert(t, id)
				num = num - 1
			end
			local ua = com.Create(self, com)
			for _, id in ipairs(t) do
				self:RemoveLeader(id)
				ua:AddLeader(id)
			end
			return ua
		end
	}
end

UnlimitedArmy:AStatic()
---@param target UnlimitedArmy
---@return UACommand
function UnlimitedArmy.CreateCommandTransferTroops(target)
	return {
		Target = target,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			if com.Target:IsDead() == -1 then
				return true
			end
			local tpos = com.Target:GetPosition()
			if com.Target:IsDead() or GetDistance(self:GetPosition(), tpos) <= 2000 then
				local t = {}
				for id in self:Iterator() do
					table.insert(t, id)
				end
				for _, id in ipairs(t) do
					self:RemoveLeader(id)
					com.Target:AddLeader(id)
				end
				return true
			end
			if not self.Target or GetDistance(self.Target, com.Target.Target) >= 1000 then
				return false, UnlimitedArmy.CreateCommandMove(com.Target.Target)
			end
		end
	}
end

UnlimitedArmy:AStatic()
---@param s number
---@return UACommand
function UnlimitedArmy.CreateCommandWaitSeconds(s)
	return {
		Seconds = s,
		--- @param self UnlimitedArmy
		Command = function(self, com)
			if not self.WaitForTick then
				self.WaitForTick = Logic.GetCurrentTurn() + com.Seconds * 10
			end
			if Logic.GetCurrentTurn() > self.WaitForTick then
				self.WaitForTick = nil
				return true
			end
			return false
		end
	}
end

UnlimitedArmy:AStatic()
---@param id number
---@param enemypl number
---@param aiactive boolean?
---@return boolean
function UnlimitedArmy.IsValidTarget(id, enemypl, aiactive)
	return TargetFilter.IsValidTarget(id, enemypl, aiactive)
end

UnlimitedArmy:AStatic()
---@param p Position
---@param player number
---@param area number
---@param aiactive boolean?
---@param excludeFleeing boolean?
---@param currentTarget number?
---@return nil|number
function UnlimitedArmy.GetTargetEnemiesInArea(p, player, area, aiactive, excludeFleeing, currentTarget)
	if p == invalidPosition then
		return nil
	end
	if not UnlimitedArmy.HasHook() then
		return UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, aiactive, excludeFleeing, currentTarget)
	end
	return CppLogic.UA.GetNearestEnemyInArea(player, p, area, excludeFleeing)
end

UnlimitedArmy:AStatic()
---@param p Position
---@param player number
---@param area number
---@param excludeFleeing boolean?
---@return number
function UnlimitedArmy.GetNumberOfEnemiesInArea(p, player, area, excludeFleeing)
	if p == invalidPosition then
		return 0
	end
	if not UnlimitedArmy.HasHook() then
		local num = 0
		for p2=1, (CUtil and 16) or 8 do
			if Logic.GetDiplomacyState(player, p2)==Diplomacy.Hostile then
				local d = {Logic.GetPlayerEntitiesInArea(p2, 0, p.X, p.Y, area, 16)}
				table.remove(d, 1)
				for _, id in ipairs(d) do
					if (Logic.IsSettler(id) == 1 or Logic.IsBuilding(id) == 1) then
						num = num + 1
					end
				end
			end
		end
		return num
	end
	return CppLogic.UA.CountTargetEntitiesInArea(player, p, area, excludeFleeing)
end

UnlimitedArmy:AStatic()
---@param p Position
---@param player number
---@param area number
---@param aiactive boolean?
---@param excludeFleeing boolean?
---@param currentTarget number?
---@return number|nil
function UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, aiactive, excludeFleeing, currentTarget)
	local repid = nil
	for i=1, (CUtil and 16) or 8 do
		if i ~= player and Logic.GetDiplomacyState(i, player)==Diplomacy.Hostile then
			local d = {Logic.GetPlayerEntitiesInArea(i, 0, p.X, p.Y, area or 999999999, 16)}
			table.remove(d, 1)
			for _,id in ipairs(d) do
				local valid = true
				if excludeFleeing then
					if id == currentTarget then
						valid = false
					elseif UnlimitedArmy.IsEntityFleeingFrom(id, p) then 
						valid = false
					end
				end
				if valid then
					local b, rid = UnlimitedArmy.IsValidTarget(id, player, aiactive)
					if b then
						return id
					end
					repid = repid or rid
				end
			end
		end
	end
	return repid
end

UnlimitedArmy:AStatic()
---prüft, ob ein leader gerade kämpft
---@param id number
---@return boolean
function UnlimitedArmy.IsLeaderInBattle(id)
	if IsDead(id) then
		return false
	end
	local com = Logic.LeaderGetCurrentCommand(id)
	return (com == 0 or com == 5 or com == 10) and not (string.sub(Logic.GetCurrentTaskList(id) or "", -5, -1) == "_IDLE")
end

UnlimitedArmy:AStatic()
---prüft, ob ein leader gerade nichts tut
---@param id number
---@return boolean
function UnlimitedArmy.IsLeaderIdle(id)
	if IsDead(id) then
		return false
	end
	local com = Logic.LeaderGetCurrentCommand(id)
	return com == 3 or com == 7 or (string.sub(Logic.GetCurrentTaskList(id) or "", -5, -1) == "_IDLE")
end

UnlimitedArmy:AStatic()
---prüft, ob ein leader sich gerade bewegt
---@param id number
---@return boolean
function UnlimitedArmy.IsLeaderMoving(id)
	if IsDead(id) then
		return false
	end
	local com = Logic.LeaderGetCurrentCommand(id)
	return (com == 8 or com == 5 or com == 4) and not (string.sub(Logic.GetCurrentTaskList(id) or "", -5, -1) == "_IDLE")
end

UnlimitedArmy:AStatic()
---@param id number
---@return boolean
function UnlimitedArmy.IsRangedEntity(id)
	return Logic.IsEntityInCategory(id, EntityCategories.LongRange) == 1 or Logic.IsEntityInCategory(id, EntityCategories.Cannon) == 1 or IsEntityOfType(id, Entities.PU_Hero5, Entities.PU_Hero10, Entities.CU_BanditLeaderBow1, Entities.CU_Evil_LeaderSkirmisher1)
end

UnlimitedArmy:AStatic()
---@param id number
---@return boolean
function UnlimitedArmy.IsNonCombatEntity(id)
	return IsEntityOfType(id, Entities.PU_Thief, Entities.PU_Scout)
end

UnlimitedArmy:AStatic()
---@param id number
---@return boolean
function UnlimitedArmy.IsFearAffectableAndConvertable(id)
	if Logic.IsSettler(id) == 0 then
		return false
	end
	if UnlimitedArmy.HasHook() then
		return CppLogic.EntityType.IsFearAffectableAndConvertable(Logic.GetEntityType(id))
	end
	if Logic.IsHero(id) == 1 then
		return false
	end
	local ty = Logic.GetEntityType(id)
	return not (ty == Entities.CU_Evil_LeaderBearman1 or ty == Entities.CU_Evil_LeaderSkirmisher1)
end

UnlimitedArmy:AStatic()
---@param id number
---@param pos Position
---@param r number?
function UnlimitedArmy.MoveAndSetTargetRotation(id, pos, r)
	if UnlimitedArmy.HasHook() then
		CppLogic.Entity.Settler.CommandMove(id, pos, r)
	else
		Logic.GroupAttackMove(id, pos.X, pos.Y, r)
	end
end

UnlimitedArmy:AStatic()
---@param id number
---@param pos Position
---@param r number?
function UnlimitedArmy.MoveAndSetTargetRotationClamp(id, pos, r)
	local x, y = Logic.WorldGetSize()
	if pos.X > x + 100 then
		pos.X = x + 100
	end
	if pos.X < 0 then
		pos.X = 0
	end
	if pos.Y > y + 100 then
		pos.Y = y + 100
	end
	if pos.Y < 0 then
		pos.Y = 0
	end
	UnlimitedArmy.MoveAndSetTargetRotation(id, pos, r)
end

UnlimitedArmy:AStatic()
---@param r number|string|table
---@return boolean
function UnlimitedArmy.IsReferenceDead(r)
	if type(r) == "table" then
		if r.IsDead then
			return r:IsDead()
		end
		if r[1] then
			for _, id in ipairs(r) do
				if not UnlimitedArmy.IsReferenceDead(id) then
					return false
				end
			end
			return true
		end
	end
	return IsDead(r)
end

UnlimitedArmy:AStatic()
---@param id number
---@param pos Position
---@return boolean
function UnlimitedArmy.IsEntityFleeingFrom(id, pos)
	if Logic.IsSettler(id) == 0 then
		return false
	end
	--new
	if Logic.IsEntityInCategory(id, EntityCategories.Soldier) == 1 then
		id = SVLib.GetLeaderOfSoldier(id)
	end
	--new end
	--[[
	if CppLogic.Entity.IsSoldier(id) then
		id = CppLogic.Entity.GetLeaderOfSoldier(id)
	end
	]]
	local p = GetPosition(id)
	local p2 = {}
	p2.X = SVLib.GetXTarget(id)
	p2.Y = SVLib.GetYTarget(id)
	--local p2 = CppLogic.Entity.MovingEntityGetTargetPos(id)
	return GetDistance(pos, p) + 800 < GetDistance(pos, p2)
end

UnlimitedArmy:AStatic()
UnlimitedArmy.Formations = {}

--- chaotische formation, leader bekommen zufällige position zugewiesen.
--- @param army UnlimitedArmy
--- @param pos Position
function UnlimitedArmy.Formations.Chaotic(army, pos)
	local l = math.sqrt(army:GetSize(false, false)) * 150
	for id in army:Iterator(false) do
		if not army.ChaoticCache[id] then
			army.ChaoticCache[id] = {X = GetRandom(-l, l), Y = GetRandom(-l, l), r = GetRandom(0, 360)}
		end
		UnlimitedArmy.MoveAndSetTargetRotationClamp(id, {X = pos.X + army.ChaoticCache[id].X, Y = pos.Y + army.ChaoticCache[id].Y},
		                                            army.ChaoticCache[id].r + army.FormationRotation)
	end
end

--- kreisformation (3 kreise, nahkämpfer, fernkämpfer und diebe/kundschafter)
--- @param army UnlimitedArmy
--- @param pos Position
function UnlimitedArmy.Formations.Circle(army, pos)
	local ranged, melee, nocombat = army:GetRangedAndMelee()
	if table.getn(nocombat) == 1 then
		UnlimitedArmy.MoveAndSetTargetRotationClamp(nocombat[1], pos, 0 + army.FormationRotation)
	else
		for i = 1, table.getn(nocombat) do
			local r = (i * 360 / table.getn(nocombat)) + army.FormationRotation
			UnlimitedArmy.MoveAndSetTargetRotationClamp(nocombat[i], GetCirclePosition(pos, table.getn(nocombat) * 70, r), r)
		end
	end
	if table.getn(ranged) == 1 then
		UnlimitedArmy.MoveAndSetTargetRotationClamp(ranged[1], pos, 0 + army.FormationRotation)
	else
		for i = 1, table.getn(ranged) do
			local r = (i * 360 / table.getn(ranged)) + army.FormationRotation
			UnlimitedArmy.MoveAndSetTargetRotationClamp(ranged[i], GetCirclePosition(pos, 250 + table.getn(nocombat) + table.getn(ranged) * 70, r), r)
		end
	end
	if table.getn(melee) == 1 and table.getn(army.Leaders) == 1 then
		UnlimitedArmy.MoveAndSetTargetRotationClamp(melee[1], pos, 0 + army.FormationRotation)
	else
		for i = 1, table.getn(melee) do
			local r = (i * 360 / table.getn(melee)) + army.FormationRotation
			UnlimitedArmy.MoveAndSetTargetRotationClamp(melee[i], GetCirclePosition(pos, 500 + table.getn(nocombat) + table.getn(ranged) * 70, r), r)
		end
	end
end

--- linienformation (ähnlich wie move command aus der UI)
--- @param army UnlimitedArmy
--- @param pos Position
function UnlimitedArmy.Formations.Lines(army, pos)
	local pl = army.TroopsPerLine or 3
	local abst = 500
	if army:GetSize(false, false) == 1 then
		for id in army:Iterator(false) do
			UnlimitedArmy.MoveAndSetTargetRotationClamp(id, pos, 0 + army.FormationRotation)
		end
	else
		local numOfLi = math.ceil(army:GetSize(false, false) / pl)
		local getModLi = function(i)
			i = i - 1
			local d = -(math.floor(i / pl) - math.floor(numOfLi / 2)) * abst
			-- Message(d)
			return d
		end
		local getModRei = function(i)
			i = i - 1
			local d = (math.mod(i, pl) - math.floor(pl / 2)) * abst
			-- Message(d)
			return d
		end
		local r = 0 + army.FormationRotation
		local ranged, melee, nocombat = army:GetRangedAndMelee()
		local en = {}
		for _, id in ipairs(ranged) do
			table.insert(en, 1, id)
		end
		for _, id in ipairs(melee) do
			table.insert(en, 1, id)
		end
		for _, id in ipairs(nocombat) do
			table.insert(en, 1, id)
		end
		local n = table.getn(en)
		for i = 1, n do
			local p = GetCirclePosition(pos, getModLi(i), r)
			p = GetCirclePosition(p, getModRei(i), r + 270)
			UnlimitedArmy.MoveAndSetTargetRotationClamp(en[i], p, r)
		end
	end
end

--- speerspitzenformation
--- @param army UnlimitedArmy
--- @param pos Position
function UnlimitedArmy.Formations.Spear(army, pos)
	local edgepositions, inpositions, line, dist = {}, {}, 0, 300
	local rot = army.FormationRotation
	local function getP(r, off)
		return GetCirclePosition(GetCirclePosition(pos, r * dist, rot + 180), off * dist, rot + 270)
	end
	while true do
		for p1 = -(line - 1), (line - 1) do
			table.insert(inpositions, getP(line, p1))
		end
		table.insert(edgepositions, getP(line, line))
		if line ~= 0 then
			table.insert(edgepositions, getP(line, -line))
		end
		if table.getn(edgepositions) + table.getn(inpositions) >= army:GetSize(false, false) then
			break
		end
		line = line + 1
	end
	for i = 1, table.getn(edgepositions) do
		table.insert(inpositions, 1, 0)
	end
	local i2 = 1
	for id in army:Iterator(false) do
		local i = army:GetSize(false, false) - i2 + 1
		local p = edgepositions[i] and edgepositions[i] or inpositions[i]
		UnlimitedArmy.MoveAndSetTargetRotationClamp(id, p, rot)
		i2 = i2 + 1
	end
end

UnlimitedArmy:AStatic()
UnlimitedArmy.HeroAbilityConfigs = {}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityCircularAttack] = {
	Use = function(army, id)
		if CNetwork then
			SendEvent.HeroCircularAttack(id)
		else
			GUI.SettlerCircularAttack(id)
		end
	end,
	Range = 0,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
	RequiredRange = 500
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityInflictFear] = {
	Use = function(army, id)
		if CNetwork then
			SendEvent.HeroInflictFear(id)
		else
			GUI.SettlerInflictFear(id)
		end
	end,
	Range = 0,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
	RequiredRange = 1000
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityRangedEffect] = {
	Use = function(army, id)
		if CNetwork then
			SendEvent.HeroActivateAura(id)
		else
			GUI.SettlerAffectUnitsInArea(id)
		end
	end,
	Range = 0,
	PreventUse = function(army, id)
		if Logic.GetEntityType(id) == Entities.PU_Hero3 then
			for _, l in ipairs(army.Leaders) do
				local hp = Logic.GetEntityHealth(l)
				if hp > 0 and hp < Logic.GetEntityMaxHealth(l) / 2 then
					return false
				end
			end
			return true
		end
		local r = Logic.GetEntityType(id) == Entities.PU_Hero10 and 2500 or 1000
		return UnlimitedArmy.GetNumberOfEnemiesInArea(GetPosition(id), army.Player, r, army.IgnoreFleeing) < 5
	end,
	IsInstant = true
	-- RequiredEnemiesInArea = 5,
	-- RequiredRange = 1000,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilitySummon] = {
	Use = function(army, id)
		if CNetwork then
			SendEvent.HeroSummon(id)
		else
			GUI.SettlerSummon(id)
		end
	end,
	Range = 0,
	IsInstant = true,
	RequiredEnemiesInArea = 5
}

UnlimitedArmy:FinalizeClass()

--- @class UnlimitedArmyFiller : LuaObject
UnlimitedArmyFiller = {}
--- @type UnlimitedArmy
UnlimitedArmyFiller.Army = nil
UnlimitedArmyFiller = LuaObject:CreateSubClass("UnlimitedArmyFiller")

UnlimitedArmyFiller:AMethod()
function UnlimitedArmyFiller:Tick(active)
	LuaObject_AbstractMethod()
end

UnlimitedArmyFiller:AMethod()
function UnlimitedArmyFiller:IsDead()
	LuaObject_AbstractMethod()
end

UnlimitedArmyFiller:AMethod()
function UnlimitedArmyFiller:Remove()
	LuaObject_AbstractMethod()
end

UnlimitedArmyFiller:AMethod()
UnlimitedArmyFiller.ArmySize = 0

UnlimitedArmyFiller:FinalizeClass()

--- @class LazyUnlimitedArmy : UnlimitedArmy
LazyUnlimitedArmy = UnlimitedArmy:CreateSubClass("LazyUnlimitedArmy")

LazyUnlimitedArmy:AMethod()
function LazyUnlimitedArmy:Init(data, tickdelta, tickfrequency)
	self:CallBaseMethod("Init", LazyUnlimitedArmy, data)
	self.tickdelta = tickdelta
	self.tickfrequency = tickfrequency
	-- dirty hack to save call base method
	self.TickO = self.Tick
	if data.HiResJob then
		function self:Tick()
			if math.mod(Logic.GetCurrentTurn(), self.tickfrequency) == self.tickdelta then
				self:TickO()
			end
		end
	else
		function self:Tick()
			if math.mod(Logic.GetCurrentTurn() / 10, self.tickfrequency) == self.tickdelta then
				self:TickO()
			end
		end
	end
end

LazyUnlimitedArmy:FinalizeClass()
