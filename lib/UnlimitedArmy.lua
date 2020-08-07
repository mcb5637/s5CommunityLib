if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/comfort/other/PredicateHelper")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/entity/IsEntityOfType")
mcbPacker.require("s5CommunityLib/comfort/entity/ConvertEntityCallback")
mcbPacker.require("s5CommunityLib/comfort/pos/GetCirclePosition")
mcbPacker.require("s5CommunityLib/comfort/pos/GetAngleBetween")
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/tables/LeaderFormations")
mcbPacker.require("s5CommunityLib/comfort/entity/EntityIdChangedHelper")
mcbPacker.require("s5CommunityLib/comfort/number/GetRandom")
mcbPacker.require("s5CommunityLib/comfort/other/LuaObject")
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
-- Army:AddCommandDefend(pos, area, looped)		fügt einen verteidigungsbefehl hinzu (beendet wenn keine leader mehr übrig)(pos/area optional).
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
-- Army:CreateLeaderForArmy(ety, sol, pos, experience)
-- 												erstellt einen leader und verbindet ihn mit der army.
-- Army:Iterator(transit)						gibt einen iterator zurück, der über alle leader der armee iteriert, zu verwenden: for id in Army:Iterator() do.
-- 													den zurückgegebenen iterator nicht speichern, enthält upvalues.
-- 
-- 
-- Benötigt:
-- - CopyTable
-- - S5Hook (optional, aber ohne eingeschränkte funktionalität (Heldenfähigkeiten und zielfindung))
-- - PredicateHelper (optional, siehe hook)
-- - MemoryManipulation (optional, ignoriert diebe/ari in camo)
-- - GetDistance
-- - IsEntityOfType
-- - GetCirclePosition
-- - GetAngleBetween
-- - TriggerFix
-- - EntityIdChangedHelper
-- - LuaObject
UnlimitedArmy = {Leaders=nil, Player=nil, AutoDestroyIfEmpty=nil, HadOneLeader=nil, Trigger=nil,
	Area=nil, CurrentBattleTarget=nil, Target=nil, Spawner=nil, FormationRotation=nil, Formation=nil,
	CommandQueue=nil, ReMove=nil, HeroTargetingCache=nil, PrepDefense=nil, FormationResets=nil, DestroyBridges=nil,
	CannonCommandCache=nil, LeaderTransit=nil, TransitAttackMove=nil, LeaderFormation=nil, AIActive=nil, SpawnerActive=nil,
	DeadHeroes=nil, DefendDoNotHelpHeroes=nil, AutoRotateRange=nil, LowestSpeed=nil, DoNotNormalizeSpeed=nil, SpeedNormalizationFactors=nil,
}
UnlimitedArmy = LuaObject:CreateSubClass("UnlimitedArmy")

UnlimitedArmy:AStatic()
UnlimitedArmy.Status = {Idle = 1, Moving = 2, Battle = 3, Destroyed = 4, IdleUnformated = 5, MovingNoBattle = 6}

UnlimitedArmy:AReference()
function UnlimitedArmy:New(data) end

UnlimitedArmy:AMethod()
function UnlimitedArmy:Init(data)
	self:CallBaseMethod("Init", UnlimitedArmy)
	self.Leaders = {}
	self.Player = assert(data.Player)
	self.Area = assert(data.Area)
	self.FormationRotation = 0
	self.Formation = data.Formation or UnlimitedArmy.Formations.Chaotic
	self.AutoDestroyIfEmpty = data.AutoDestroyIfEmpty
	self.HadOneLeader = false
	self.PrepDefense = data.PrepDefense
	self.DestroyBridges = data.DestroyBridges
	self:SetLeaderFormation(data.LeaderFormation)
	self.AIActive = data.AIActive
	self.DefendDoNotHelpHeroes = data.DefendDoNotHelpHeroes
	self.AutoRotateRange = data.AutoRotateRange
	self.DoNotNormalizeSpeed = data.DoNotNormalizeSpeed
	self.CommandQueue = {}
	self.HeroTargetingCache = {}
	self.FormationResets = {}
	self.CannonCommandCache = {}
	self.LeaderTransit = {}
	self.DeadHeroes={}
	self.SpeedNormalizationFactors={}
	self.TransitAttackMove = data.TransitAttackMove
	self.SpawnerActive = true
	self.Status = UnlimitedArmy.Status.Idle
	self.Trigger = StartSimpleJob(":Tick", self)
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:CheckValidArmy()
	assert(self.Status ~= UnlimitedArmy.Status.Destroyed)
	assert(self ~= UnlimitedArmy)
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:Tick()
	self:CheckValidArmy()
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
		return
	end
	if self.Spawner then
		self.Spawner:Tick(self.SpawnerActive)
	end
	local pos = self:GetPosition()
	local preventfurthercommands = false
	if IsDead(self.CurrentBattleTarget) or not UnlimitedArmy.IsValidTarget(self.CurrentBattleTarget, self.Player, self.AIActive) or GetDistance(pos, self.CurrentBattleTarget)>self.Area then
		self.CurrentBattleTarget = UnlimitedArmy.GetNearestEnemyInArea(pos, self.Player, self.Area, true, false, self.AIActive)
		if IsDestroyed(self.CurrentBattleTarget) then
			self.CurrentBattleTarget = UnlimitedArmy.GetNearestEnemyInArea(pos, self.Player, self.Area, false, true, self.AIActive)
			if IsDestroyed(self.CurrentBattleTarget) then
				self.CurrentBattleTarget = UnlimitedArmy.GetNearestEnemyInArea(pos, self.Player, self.Area, false, false, self.AIActive)
			end
		end
		self.CannonCommandCache = {}
	end
	if not preventfurthercommands and self.Status ~= UnlimitedArmy.Status.MovingNoBattle and IsValid(self.CurrentBattleTarget) then
		self:CheckStatus(UnlimitedArmy.Status.Battle)
		preventfurthercommands = true
	end
	if not preventfurthercommands and GetDistance(pos, self.Target)>1000 then
		if self.Status ~= UnlimitedArmy.Status.MovingNoBattle and self.Status ~= UnlimitedArmy.Status.Moving then
			self:CheckStatus(UnlimitedArmy.Status.Moving)
		end
		preventfurthercommands = true
	end
	if not preventfurthercommands then
		self:CheckStatus(UnlimitedArmy.Status.Idle)
		if self.AutoRotateRange then
			local tid = UnlimitedArmy.GetNearestEnemyInArea(pos, self.Player, self.AutoRotateRange, false, false, self.AIActive)
			if tid and math.abs(GetAngleBetween(pos, GetPosition(tid))-self.FormationRotation)>10 then
				self.FormationRotation = GetAngleBetween(pos, GetPosition(tid))
				self.ReMove = true
			end
		end
		preventfurthercommands = true
	end
	self:ProcessCommandQueue()
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
		for i=table.getn(self.LeaderTransit),1,-1 do
			if IsDestroyed(self.LeaderTransit[i]) then
				local nid = EntityIdChangedHelper.GetNewID(self.LeaderTransit[i])
				if nid then
					self.LeaderTransit[i] = nid
				end
			end
			if IsDestroyed(self.LeaderTransit[i]) then
				table.remove(self.LeaderTransit, i)
			elseif IsDead(self.LeaderTransit[i]) and Logic.IsHero(self.Leaders[i])==1 then
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
		for i=table.getn(self.DeadHeroes),1,-1 do
			if IsDestroyed(self.DeadHeroes[i]) then
				local nid = EntityIdChangedHelper.GetNewID(self.DeadHeroes[i])
				if nid then
					self.DeadHeroes[i] = nid
				end
			end
			if IsDestroyed(self.DeadHeroes[i]) then
				table.remove(self.DeadHeroes, i)
			elseif IsAlive(self.DeadHeroes[i]) then
				self:AddLeader(table.remove(self.DeadHeroes, i))
			end
		end
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:CheckStatus(st)
	self:CheckValidArmy()
	if self.Status ~= st then
		self.Status = st
		self.ReMove = true
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddLeader(id)
	self:CheckValidArmy()
	id = GetID(id)
	local p = self:GetPosition()
	if p==invalidPosition or GetDistance(p, id)<self.Area then
		table.insert(self.Leaders, id)
		if not self.Target then
			self.Target = GetPosition(id)
		end
		self:RequireNewFormat()
	else
		table.insert(self.LeaderTransit, id)
	end
	if self.LeaderFormation then
		Logic.LeaderChangeFormationType(id, self.LeaderFormation)
	end
	self.HadOneLeader = true
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:RemoveLeader(id)
	self:CheckValidArmy()
	id = GetID(id)
	for i=table.getn(self.Leaders),1,-1 do
		if self.Leaders[i] == id then
			table.remove(self.Leaders, i)
		end
	end
	for i=table.getn(self.LeaderTransit),1,-1 do
		if self.LeaderTransit[i] == id then
			table.remove(self.LeaderTransit, i)
		end
	end
	self:RequireNewFormat()
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:CreateLeaderForArmy(ety, sol, pos, experience)
	self:CheckValidArmy()
	self:AddLeader(AI.Entity_CreateFormation(self.Player, ety, nil, sol, pos.X, pos.Y, nil, nil, experience or 0, 0))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:RequireNewFormat()
	self:CheckValidArmy()
	if self.Status == UnlimitedArmy.Status.Idle then
		self.Status = UnlimitedArmy.Status.IdleUnformated
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:RemoveAllDestroyedLeaders()
	self:CheckValidArmy()
	for i=table.getn(self.Leaders),1,-1 do
		if IsDestroyed(self.Leaders[i]) then
			local nid = EntityIdChangedHelper.GetNewID(self.Leaders[i])
			if nid then
				self.Leaders[i] = nid
			else
				table.remove(self.Leaders, i)
				self:RequireNewFormat()
			end
		elseif IsDead(self.Leaders[i]) and Logic.IsHero(self.Leaders[i])==1 then
			table.insert(self.DeadHeroes, table.remove(self.Leaders, i))
			self:RequireNewFormat()
		end
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:GetSize(addTransit, adddeadhero)
	self:CheckValidArmy()
	local r = table.getn(self.Leaders)
	if addTransit then
		r = r + table.getn(self.LeaderTransit)
	end
	if adddeadhero then
		r = r + table.getn(self.DeadHeroes)
	end
	return r
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:Destroy()
	self.Status = UnlimitedArmy.Status.Destroyed
	EndJob(self.Trigger)
	if self.Spawner then
		self.Spawner:Remove()
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:KillAllLeaders()
	self:CheckValidArmy()
	for _,id in ipairs(self.Leaders) do
		if Logic.IsLeader(id) == 1 then
			local soldiers = {Logic.GetSoldiersAttachedToLeader(id)}
			table.remove(soldiers, 1)
			for _,v in ipairs(soldiers) do
				SetHealth(v, 0)
			end
		end
		SetHealth(id, 0)
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:GetPosition()
	self:CheckValidArmy()
	self:RemoveAllDestroyedLeaders()
	local num = table.getn(self.Leaders)
	if num == 0 then
		return invalidPosition
	end
	local x,y = 0,0
	for _,id in ipairs(self.Leaders) do
		local p = GetPosition(id)
		x = x + p.X
		y = y + p.Y
	end
	return {X=x/num, Y=y/num}
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:CheckHeroTargetingCache(tid, d)
	self:CheckValidArmy()
	if not d then
		return true
	end
	if not self.HeroTargetingCache[tid] or self.HeroTargetingCache[tid] < Logic.GetTime() then
		self.HeroTargetingCache[tid] = Logic.GetTime() + d
		return true
	end
	return false
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:DoHeroAbilities(id, nume, combat, prepdefense)
	self:CheckValidArmy()
	if Logic.IsHero(id)==0 and not UnlimitedArmy.IsNonCombatEntity(id) then
		return false
	end
	local noninstant = false
	for ab, acf in pairs(UnlimitedArmy.HeroAbilityConfigs) do
		if not (noninstant and acf.IsInstant) then
			if Logic.HeroIsAbilitySupported(id, ab)==1 and Logic.HeroGetAbiltityChargeSeconds(id, ab)==Logic.HeroGetAbilityRechargeTime(id, ab) then
				local executeAbility = true
				if combat and acf.Combat then
					if acf.RequiredEnemiesInArea then
						if acf.RequiredRange then
							if UnlimitedArmy.GetNumberOfEnemiesInArea(GetPosition(id), self.Player, acf.RequiredRange, self.AIActive, acf.AreaCondition) < acf.RequiredEnemiesInArea then
								executeAbility = false
							end
						else
							if nume < acf.RequiredEnemiesInArea then
								executeAbility = false
							end
						end
					end
				elseif prepdefense and acf.PrepDefense then
					executeAbility = true
				else
					executeAbility = false
				end
				if acf.PreventUse and acf.PreventUse(self, id, combat, prepdefense) then
					executeAbility = false
				end
				if acf.RequiresHook and not S5Hook then
					executeAbility = false
				end
				if executeAbility then
					if acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.Self then
						acf.Use(self, id)
						noninstant = not acf.IsInstant
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.Pos then
						local p = GetPosition(id)
						acf.Use(self, id, p.X, p.Y)
						noninstant = not acf.IsInstant
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.FreePos then
						local p = GetPosition(id)
						local a = math.floor(self.Area / 1000)
						acf.Use(self, id, p.X+(GetRandom(a,a)*100), p.Y+(GetRandom(a,a)*100)) -- command should be ignored with invalid position
						noninstant = not acf.IsInstant
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.EnemyEntity then
						local tid = nil
						if acf.PrefersBackline then
							tid = UnlimitedArmy.GetFurthestEnemyInArea(GetPosition(id), self.Player, acf.Range, true, nil, self.AIActive, acf.TargetCondition)
						else
							tid = UnlimitedArmy.GetNearestEnemyInArea(GetPosition(id), self.Player, acf.Range, true, nil, self.AIActive, acf.TargetCondition)
						end
						if IsValid(tid) and self:CheckHeroTargetingCache(tid, acf.TargetCooldown) then
							acf.Use(self, id, tid)
							noninstant = not acf.IsInstant
						end
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.EnemyBuilding then
						local tid = UnlimitedArmy.GetNearestEnemyInArea(GetPosition(id), self.Player, acf.Range, nil, true, self.AIActive, acf.TargetCondition)
						if IsDestroyed(tid) and acf.TargetBridgesAsSecondaryTargetIfAllowed and self.DestroyBridges then
							tid = UnlimitedArmy.GetNearestBridgeInArea(GetPosition(id), self.Player, acf.Range, UnlimitedArmy.BridgeEntityTypes, self.AIActive)
						end
						if IsValid(tid) and self:CheckHeroTargetingCache(tid, acf.TargetCooldown) then
							acf.Use(self, id, tid)
							noninstant = not acf.IsInstant
						end
					end
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
	local nume = UnlimitedArmy.GetNumberOfEnemiesInArea(self:GetPosition(), self.Player, self.Area, self.AIActive)
	for num,id in ipairs(self.Leaders) do
		local DoCommands = not self:DoHeroAbilities(id, nume, true, false)
		if (self.ReMove or not UnlimitedArmy.IsLeaderInBattle(id) or self.CannonCommandCache[id]==-1) and not UnlimitedArmy.IsNonCombatEntity(id) then
			if DoCommands and Logic.IsEntityInCategory(id, EntityCategories.Cannon) then
				if not self.CannonCommandCache[id] or self.CannonCommandCache[id]==-1 or self.CannonCommandCache[id]<Logic.GetTime() then
					self.CannonCommandCache[id] = Logic.GetTime()+1
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
		for _,id in ipairs(self.Leaders) do
			if self.ReMove or not UnlimitedArmy.IsLeaderMoving(id) then
				Move(id, self.Target)
			end
		end
	else
		for _,id in ipairs(self.Leaders) do
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
	elseif self.PrepDefense and self:IsIdle() then
		for _,id in ipairs(self.Leaders) do
			if Logic.LeaderGetCurrentCommand(id)~=10 then
				local p = GetPosition(id)
				p.r = Logic.GetEntityOrientation(id)
				local reset = self:DoHeroAbilities(id, 0, false, true)
				if reset then
					self.FormationResets[id] = p
				elseif self.FormationResets[id] then
					UnlimitedArmy.MoveAndSetTargetRotation(id, self.FormationResets[id], self.FormationResets[id].r)
					self.FormationResets[id] = nil
				end
			end
		end
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
function UnlimitedArmy:ProcessCommand(com, ind)
	local adv, rep = com.Command(self, com)
	if adv and com == self.CommandQueue[1] then
		self:AdvanceCommand()
	end
	if rep and ind>0 then
		self:ProcessCommand(rep, ind-1)
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
function UnlimitedArmy:GetFirstEnemyInArmyRange()
	self:CheckValidArmy()
	return UnlimitedArmy.GetFirstEnemyInArea(self:GetPosition(), self.Player, self.Area, nil, nil, self.AIActive)
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:IsIdle()
	self:CheckValidArmy()
	if self:GetSize(true, false)<=0 then
		return true
	end
	if self.Status ~= UnlimitedArmy.Status.Idle then
		return false
	end
	if self.LeaderTransit[1] then
		return false
	end
	if GetDistance(self:GetPosition(), self.Target)>1000 then
		return false
	end
	for _,id in ipairs(self.Leaders) do
		if not UnlimitedArmy.IsLeaderIdle(id) then
			return false
		end
	end
	return true
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:IsDead()
	if self.Status == UnlimitedArmy.Status.Destroyed then
		return -1
	end
	if self:GetSize(true, false)==0 then
		if self.Spawner then
			return 2
		end
		if not self.HadOneLeader then
			return 3
		end
		if self.DeadHeroes[1] then
			return 4
		end
		return 1
	end
	return false
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:GetRangedAndMelee()
	self:CheckValidArmy()
	local r, m, n = {}, {}, {}
	for _,id in ipairs(self.Leaders) do
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

UnlimitedArmy:AMethod()
function UnlimitedArmy:ClearCommandQueue()
	self:CheckValidArmy()
	self.CommandQueue = {}
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandMove(p, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandMove(p, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandFlee(p, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandFlee(p, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandDefend(defendPos, defendArea, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandDefend(defendPos, defendArea or self.Area, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandWaitForIdle(looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandWaitForIdle(looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandWaitForTroopSize(size, lessthan, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandWaitForTroopSize(size, lessthan, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandLuaFunc(func, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandLuaFunc(func, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandAttackNearestTarget(maxrange, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandAttackNearestTarget(maxrange, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandSetSpawnerStatus(status, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandSetSpawnerStatus(status, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandWaitForSpawnerFull(looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandWaitForSpawnerFull(looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:AddCommandGuardEntity(target, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, UnlimitedArmy.CreateCommandGuardEntity(target, looped))
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:Iterator(transit)
	self:CheckValidArmy()
	local k = table.getn(self.Leaders)+1
	local t = self.Leaders
	return function()
		k = k - 1
		if t[k] then
			return t[k]
		end
		if t==self.Leaders and transit then
			t = self.LeaderTransit
			k = table.getn(self.LeaderTransit)
			return t[k]
		end
		return nil
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:NormalizeSpeed(normalize, forcerefresh)
	self:CheckValidArmy()
	if self.DoNotNormalizeSpeed and not forcerefresh then
		return
	end
	if normalize and not self.DoNotNormalizeSpeed then
		local lowest = nil
		for id in self:Iterator() do
			local s = UnlimitedArmy.GetEntitySpeed(id)
			if not lowest or lowest>s then
				lowest = s
			end
		end
		for id in self:Iterator() do
			local f = lowest/UnlimitedArmy.GetEntitySpeed(id)
			Logic.SetSpeedFactor(id, f)
			if Logic.IsLeader(id)==1 and Logic.LeaderGetMaxNumberOfSoldiers(id)>0 and Logic.LeaderGetNumberOfSoldiers(id)>0 then
				local d = {Logic.GetSoldiersAttachedToLeader(id)}
				table.remove(d, 1)
				for _,ids in ipairs(d) do
					Logic.SetSpeedFactor(ids, f)
				end
			end
		end
	else
		for id in self:Iterator() do
			Logic.SetSpeedFactor(id, 1)
			if Logic.IsLeader(id)==1 and Logic.LeaderGetMaxNumberOfSoldiers(id)>0 and Logic.LeaderGetNumberOfSoldiers(id)>0 then
				local d = {Logic.GetSoldiersAttachedToLeader(id)}
				table.remove(d, 1)
				for _,ids in ipairs(d) do
					Logic.SetSpeedFactor(ids, 1)
				end
			end
		end
	end
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:SetDoNotNormalizeSpeed(val)
	self:CheckValidArmy()
	self.DoNotNormalizeSpeed = val
	self:NormalizeSpeed(self.Status==UnlimitedArmy.Status.Moving or self.Status==UnlimitedArmy.Status.MovingNoBattle, true)
end

UnlimitedArmy:AMethod()
function UnlimitedArmy:SetLeaderFormation(form)
	self:CheckValidArmy()
	self.LeaderFormation = form
	if form then
		for id in self:Iterator(true) do
			Logic.LeaderChangeFormationType(id, form)
		end
	end
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandMove(p, looped)
	return {
		Pos = p,
		Looped = looped,
		Command = function(self, com)
			self.Target = com.Pos
			if self.Status ~= UnlimitedArmy.Status.Battle then
				self.Status = UnlimitedArmy.Status.Moving
			end
			if self.Status == UnlimitedArmy.Status.Moving then
				self.ReMove = true
			end
			return true
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandFlee(p, looped)
	return {
		Pos = p,
		Looped = looped,
		Command = function(self, com)
			self.Target = com.Pos
			self.Status = UnlimitedArmy.Status.MovingNoBattle
			self.ReMove = true
			return true
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandDefend(defendPos, defendArea, looped)
	return {
		Looped = looped,
		DistArea = defendArea,
		Pos = defendPos,
		Command = function(self, com)
			if com.Pos == nil then
				com.Pos = self:GetPosition()
			end
			if self:GetSize(true, false)<=0 then
				self.Target = com.Pos
				return true
			elseif GetDistance(self:GetPosition(), com.Pos) > com.DistArea then
				self.Status = UnlimitedArmy.Status.MovingNoBattle
				self.Target = com.Pos
				self.ReMove = true
			elseif self.Status ~= UnlimitedArmy.Status.Battle then
				local tid = UnlimitedArmy.GetFirstEnemyInArea(com.Pos, self.Player, com.DistArea, nil, nil, self.AIActive)
				if IsValid(tid) then
					self.Target = GetPosition(tid)
					self.ReMove = true
					self.Status = UnlimitedArmy.Status.Moving
				elseif self.DeadHeroes[1] and not self.DefendDoNotHelpHeroes then
					if GetDistance(self.Target, self.DeadHeroes[1])>100 then
						self.Target = GetPosition(self.DeadHeroes[1])
						self.ReMove = true
						self.Status = UnlimitedArmy.Status.Moving
					end
				elseif GetDistance(self.Target, com.Pos)>100 then
					self.Target = com.Pos
					self.ReMove = true
					self.Status = UnlimitedArmy.Status.Moving
				end
			end
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandWaitForIdle(looped)
	return {
		Looped = looped,
		Command = function(self, com)
			if self:IsIdle() then
				return true
			end
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandWaitForTroopSize(size, lessthan, looped)
	return {
		Size = size,
		LessThan = lessthan,
		Looped = looped,
		Command = function(self, com)
			local s = self:GetSize()
			if (s >= com.Size and not com.LessThan) or (s < com.Size and com.LessThan) then
				return true
			end
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandLuaFunc(func, looped)
	return {
		Looped = looped,
		Command = func,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandAttackNearestTarget(maxrange, looped)
	return {
		MaxRange = maxrange,
		Looped = looped,
		Command = function(self, com)
			if self:GetSize(true, false)<=0 then
				return true
			else
				local tid = UnlimitedArmy.GetNearestEnemyInArea(self:GetPosition(), self.Player, com.MaxRange, nil, nil, self.AIActive)
				if IsValid(tid) then
					self.Target = GetPosition(tid)
					if self.Status == UnlimitedArmy.Status.Moving or self.Status == UnlimitedArmy.Status.Idle then
						self.ReMove = true
						self.Status = UnlimitedArmy.Status.Moving
					end
					return true
				end
			end
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandSetSpawnerStatus(status, looped)
	return {
		Status = status,
		Looped = looped,
		Command = function(self, com)
			self.SpawnerActive = com.Status
			return true
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandWaitForSpawnerFull(looped)
	return {
		Looped = looped,
		Command = function(self, com)
			local s = self:GetSize()
			if not self.Spawner or s >= self.Spawner.ArmySize then
				return true
			end
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.CreateCommandGuardEntity(target, looped)
	return {
		Looped = looped,
		Target = target,
		Command = function(self, com)
			if IsDestroyed(com.Target) or self:GetSize(true, false)<=0 then
				return true
			end
			local tp = GetPosition(com.Target)
			if not self.Target or GetDistance(tp, self.Target)>250 then
				self.Target = tp
				if self.Status ~= UnlimitedArmy.Status.Battle then
					self.Status = UnlimitedArmy.Status.Moving
				end
				if self.Status == UnlimitedArmy.Status.Moving then
					self.ReMove = true
				end
			end
		end,
	}
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsValidTarget(id, enemypl, aiactive)
	if IsDead(id) then
		return false
	end
	if MemoryManipulation then
		if MemoryManipulation.IsEntityInvisible(id) then
			return false
		end
	else
		if UnlimitedArmy.NoHookCheckInvisibility(id, enemypl, aiactive) then
			return false
		end
	end
	if UnlimitedArmy.IgnoreEtypes[Logic.GetEntityType(id)] then
		return false
	end
	if Logic.IsWorker(id)==1 then
		if Logic.IsSettlerAtWork(id)==1 then
			return false, Logic.GetSettlersWorkBuilding(id)
		end
		if Logic.IsSettlerAtFarm(id)==1 then
			return false, Logic.GetSettlersFarm(id)
		end
		if Logic.IsSettlerAtResidence(id)==1 then
			return false, Logic.GetSettlersResidence(id)
		end
	end
	return true
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.GetFirstEnemyInArea(p, player, area, leader, building, aiactive, addCond)
	if p == invalidPosition then
		return nil
	end
	addCond = addCond or function() return true end
	if not S5Hook then
		return UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, leader, building, aiactive, addCond)
	end
	local pred = {PredicateHelper.GetEnemyPlayerPredicate(player),
		PredicateHelper.GetETypePredicate(UnlimitedArmy.EntityTypeArray),
		Predicate.InCircle(p.X, p.Y, area)
	}
	if leader then
		table.insert(pred, Predicate.OfCategory(EntityCategories.Leader))
	end
	if building then
		table.insert(pred, Predicate.IsBuilding())
	end
	for id in S5Hook.EntityIterator(unpack(pred)) do
		if UnlimitedArmy.IsValidTarget(id, player, aiactive) and addCond(id) then
			return id
		end
	end
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.GetNearestEnemyInArea(p, player, area, leader, building, aiactive, addCond)
	if p == invalidPosition then
		return nil
	end
	addCond = addCond or function() return true end
	if not S5Hook then
		return UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, leader, building, aiactive, addCond)
	end
	local r, d = nil, nil
	local pred = {PredicateHelper.GetEnemyPlayerPredicate(player),
		PredicateHelper.GetETypePredicate(UnlimitedArmy.EntityTypeArray)
	}
	if area then
		table.insert(pred, Predicate.InCircle(p.X, p.Y, area))
	end
	if leader then
		table.insert(pred, Predicate.OfCategory(EntityCategories.Leader))
	end
	if building then
		table.insert(pred, Predicate.IsBuilding())
	end
	for id in S5Hook.EntityIterator(unpack(pred)) do
		if UnlimitedArmy.IsValidTarget(id, player, aiactive) and addCond(id) then
			local cd = GetDistance(id, p)
			if not d or cd < d then
				r, d = id, cd
			end
		end
	end
	return r
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.GetFurthestEnemyInArea(p, player, area, leader, building, aiactive, addCond)
	if p == invalidPosition then
		return nil
	end
	addCond = addCond or function() return true end
	if not S5Hook then
		return UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, leader, building, aiactive, addCond)
	end
	local r, d = nil, nil
	local pred = {PredicateHelper.GetEnemyPlayerPredicate(player),
		PredicateHelper.GetETypePredicate(UnlimitedArmy.EntityTypeArray)
	}
	if area then
		table.insert(pred, Predicate.InCircle(p.X, p.Y, area))
	end
	if leader then
		table.insert(pred, Predicate.OfCategory(EntityCategories.Leader))
	end
	if building then
		table.insert(pred, Predicate.IsBuilding())
	end
	for id in S5Hook.EntityIterator(unpack(pred)) do
		if UnlimitedArmy.IsValidTarget(id, player, aiactive) and addCond(id) then
			local cd = GetDistance(id, p)
			if not d or cd > d then
				r, d = id, cd
			end
		end
	end
	return r
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.GetNumberOfEnemiesInArea(p, player, area, aiactive, addCond)
	if p == invalidPosition then
		return 0
	end
	addCond = addCond or function() return true end
	if not S5Hook then
		local num = 0
		for p2=1,8 do
			if Logic.GetDiplomacyState(player, p2)==Diplomacy.Hostile then
				local d = {Logic.GetPlayerEntitiesInArea(p2, 0, p.X, p.Y, area, 16)}
				table.remove(d, 1)
				for _,id in ipairs(d) do
					if (Logic.IsSettler(id)==1 or Logic.IsBuilding(id)==1) and addCond(id) then
						num = num + 1
					end
				end
			end
		end
		return num
	end
	local num = 0
	for id in S5Hook.EntityIterator(PredicateHelper.GetEnemyPlayerPredicate(player),
		PredicateHelper.GetETypePredicate(UnlimitedArmy.EntityTypeArray),
		Predicate.InCircle(p.X, p.Y, area)
	) do
		if UnlimitedArmy.IsValidTarget(id, player, aiactive) and addCond(id) then
			num = num + 1
		end
	end
	return num
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.GetNearestBridgeInArea(p, player, area, etypes, aiactive)
	if p == invalidPosition then
		return nil
	end
	if not S5Hook then
		return UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, false, false, aiactive)
	end
	local r, d = nil, nil
	local pred = {
		PredicateHelper.GetETypePredicate(etypes)
	}
	if area then
		table.insert(pred, Predicate.InCircle(p.X, p.Y, area))
	end
	for id in S5Hook.EntityIterator(unpack(pred)) do
		if UnlimitedArmy.IsValidTarget(id, player, aiactive) then
			local cd = GetDistance(id, p)
			if not d or cd < d then
				r, d = id, cd
			end
		end
	end
	return r
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, leader, buildings, aiactive, addCond)
	local repid = nil
	addCond = addCond or function() return true end
	for i=1, 8 do
		if Logic.GetDiplomacyState(i, player)==Diplomacy.Hostile then
			local d = {Logic.GetPlayerEntitiesInArea(i, 0, p.X, p.Y, area or 999999999, 16)}
			table.remove(d, 1)
			for _,id in ipairs(d) do
				local b, rid = UnlimitedArmy.IsValidTarget(id, player, aiactive)
				if b and addCond(id) then
					return id
				end
				repid = repid or rid
			end
		end
	end
	return repid
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.NoHookCheckInvisibility(id, enemypl, aiactive)
	local ety = Logic.GetEntityType(id)
	if not (ety==Entities.PU_Hero5 or ety==Entities.PU_Thief) then -- assume just ari and thieves are invisible
		return false
	end
	local p = GetPosition(id)
	local eid = AI.Army_SearchClosestEnemy(enemypl, 0, p.X, p.Y, 500)
	if eid==id then
		return false
	end
	if aiactive then
		return true
	end
	if ety==Entities.PU_Hero5 then
		if Logic.HeroGetAbiltityChargeSeconds(id, Abilities.AbilityCamouflage) < Logic.HeroGetAbilityRechargeTime(id, Abilities.AbilityCamouflage)/2 then
			return true -- might be some false positive, but nothing better possible
		end
	elseif ety==Entities.PU_Thief then
		return true -- just assume thieves are invisible
	end
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.GetEntitySpeed(id)
	if S5Hook and MemoryManipulation then
		local s = MemoryManipulation.GetSettlerModifiedMovementSpeed(id) -- this does not include logic modifier
		if s < 0 then -- seems some entities have speed of -1 when spawned, fallback to base speed in this case
			return MemoryManipulation.GetSettlerMovementSpeed(id)
		end
		return s
	end
	if Logic.IsEntityInCategory(id, EntityCategories.Cannon)==1 then
		local ety = Logic.GetEntityType(id)
		if ety==Entities.PV_Cannon1 then
			return 240
		elseif ety==Entities.PV_Cannon2 then
			return 260
		elseif ety==Entities.PV_Cannon3 then
			return 220
		else
			return 180
		end
	end
	if Logic.IsEntityInCategory(id, EntityCategories.Hero)==1 then
		return 400
	end
	if Logic.IsEntityInCategory(id, EntityCategories.CavalryLight)==1 or Logic.IsEntityInCategory(id, EntityCategories.CavalryHeavy)==1 then
		return 500
	end
	if Logic.IsEntityInCategory(id, EntityCategories.Bow)==1 or Logic.IsEntityInCategory(id, EntityCategories.Rifle)==1 then
		return 320
	end
	return 360
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsLeaderInBattle(id)
	if IsDead(id) then
		return false
	end
	local com = Logic.LeaderGetCurrentCommand(id)
	return (com==0 or com==5 or com==10) and not (string.sub(Logic.GetCurrentTaskList(id) or "", -5, -1)=="_IDLE")
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsLeaderIdle(id)
	if IsDead(id) then
		return false
	end
	local com = Logic.LeaderGetCurrentCommand(id)
	return com==3 or com==7 or (string.sub(Logic.GetCurrentTaskList(id) or "", -5, -1)=="_IDLE")
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsLeaderMoving(id)
	if IsDead(id) then
		return false
	end
	local com = Logic.LeaderGetCurrentCommand(id)
	return (com==8 or com==5 or com==4) and not (string.sub(Logic.GetCurrentTaskList(id) or "", -5, -1)=="_IDLE")
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsRangedEntity(id)
	return Logic.IsEntityInCategory(id, EntityCategories.LongRange)==1 or Logic.IsEntityInCategory(id, EntityCategories.Cannon)==1
	or IsEntityOfType(id, "PU_Hero5", "PU_Hero10", "CU_BanditLeaderBow1")
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsNonCombatEntity(id)
	return IsEntityOfType(id, Entities.PU_Thief, Entities.PU_Scout)
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsFearAffectableAndConvertable(id)
	if S5Hook and MemoryManipulation then
		return MemoryManipulation.GetSingleValue(MemoryManipulation.GetETypePointer(Logic.GetEntityType(id)), "LogicProps.Fearless")==0
	end
	if Logic.IsHero(id)==1 then
		return false
	end
	local ty = Logic.GetEntityType(id)
	return not (ty==Entities.CU_Evil_LeaderBearman1 or ty==Entities.CU_Evil_LeaderSkirmisher1)
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.MoveAndSetTargetRotation(id, pos, r)
	Logic.GroupAttackMove(id, pos.X, pos.Y, r)
end

UnlimitedArmy:AStatic()
function UnlimitedArmy.IsReferenceDead(r)
	if type(r)=="table" then
		if r.IsDead then
			return r.IsDead()
		end
		if r[1] then
			for _,id in ipairs(r) do
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
UnlimitedArmy.Formations = {}
function UnlimitedArmy.Formations.Chaotic(army, pos)
	army.ChaotocCache = army.ChaotocCache or {}
	local l = math.sqrt(table.getn(army.Leaders))*150
	for _,id in ipairs(army.Leaders) do
		if not army.ChaotocCache[id] then
			army.ChaotocCache[id] = {X=GetRandom(-l, l), Y=GetRandom(-l, l), r=GetRandom(0,360)}
		end
		UnlimitedArmy.MoveAndSetTargetRotation(id, {X=pos.X+army.ChaotocCache[id].X, Y=pos.Y+army.ChaotocCache[id].Y}, army.ChaotocCache[id].r+army.FormationRotation)
	end
end
function UnlimitedArmy.Formations.Circle(army, pos)
	local ranged, melee, nocombat = army:GetRangedAndMelee()
	if table.getn(nocombat)==1 then
		UnlimitedArmy.MoveAndSetTargetRotation(nocombat[1], pos, 0 + army.FormationRotation)
	else
		for i=1,table.getn(nocombat) do
			local r = (i*360/table.getn(nocombat)) + army.FormationRotation
			UnlimitedArmy.MoveAndSetTargetRotation(nocombat[i], GetCirclePosition(pos, table.getn(nocombat)*70, r), r)
		end
	end
	if table.getn(ranged)==1 then
		UnlimitedArmy.MoveAndSetTargetRotation(ranged[1], pos, 0 + army.FormationRotation)
	else
		for i=1,table.getn(ranged) do
			local r = (i*360/table.getn(ranged)) + army.FormationRotation
			UnlimitedArmy.MoveAndSetTargetRotation(ranged[i], GetCirclePosition(pos, 250+table.getn(nocombat)+table.getn(ranged)*70, r), r)
		end
	end
	if table.getn(melee)==1 and table.getn(army.Leaders)==1 then
		UnlimitedArmy.MoveAndSetTargetRotation(melee[1], pos, 0 + army.FormationRotation)
	else
		for i=1,table.getn(melee) do
			local r = (i*360/table.getn(melee)) + army.FormationRotation
			UnlimitedArmy.MoveAndSetTargetRotation(melee[i], GetCirclePosition(pos, 500 +table.getn(nocombat)+table.getn(ranged)*70, r), r)
		end
	end
end
function UnlimitedArmy.Formations.Lines(army, pos)
	local pl = army.TroopsPerLine or 3
	local abst = 500
	if table.getn(army.Leaders)==1 then
		UnlimitedArmy.MoveAndSetTargetRotation(army.Leaders[1], pos, 0 + army.FormationRotation)
	else
		local numOfLi = math.ceil(table.getn(army.Leaders)/pl)
		local getModLi=function(i)
			i=i-1
			local d = -(math.floor(i/pl)-math.floor(numOfLi/2))*abst
			--Message(d)
			return d
		end
		local getModRei=function(i)
			i=i-1
			local d = (math.mod(i,pl)-math.floor(pl/2))*abst
			--Message(d)
			return d
		end
		local r = 0 + army.FormationRotation
		local ranged, melee, nocombat = army:GetRangedAndMelee()
		local en = {}
		for _,id in ipairs(ranged) do
			table.insert(en, 1, id)
		end
		for _,id in ipairs(melee) do
			table.insert(en, 1, id)
		end
		for _,id in ipairs(nocombat) do
			table.insert(en, 1, id)
		end
		local n = table.getn(en)
		for i=1, n do
			local p = GetCirclePosition(pos, getModLi(i), r)
			p = GetCirclePosition(p, getModRei(i), r + 270)
			UnlimitedArmy.MoveAndSetTargetRotation(en[i], p, r)
		end
	end
end
function UnlimitedArmy.Formations.Spear(army, pos)
	local edgepositions, inpositions, line, dist = {}, {}, 0, 300
	local rot = army.FormationRotation
	local function getP(r, off)
		return GetCirclePosition(GetCirclePosition(pos, r*dist, rot+180), off*dist, rot+270)
	end
	while true do
		for p1 = -(line-1), (line-1) do
			table.insert(inpositions, getP(line, p1))
		end
		table.insert(edgepositions, getP(line, line))
		if line ~= 0 then table.insert(edgepositions, getP(line, -line)) end
		if table.getn(edgepositions)+table.getn(inpositions) >= table.getn(army.Leaders) then
			break
		end
		line = line + 1
	end
	for i=1, table.getn(edgepositions) do
		table.insert(inpositions, 1, 0)
	end
	for i2, id in ipairs(army.Leaders) do
		local i = table.getn(army.Leaders)-i2+1
		local p = edgepositions[i] and edgepositions[i] or inpositions[i]
		UnlimitedArmy.MoveAndSetTargetRotation(id, p, rot)
	end
end

UnlimitedArmy:AStatic()
UnlimitedArmy.HeroAbilityConfigs = {}
UnlimitedArmy:AStatic()
UnlimitedArmy.HeroAbilityTargetType = {FreePos=1,Self=2,EnemyEntity=3,Pos=4,EnemyBuilding=5}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityBuildCannon] = {
	RequiresHook = true,
	Combat = true,
	PrepDefense = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.FreePos,
	Use = function(army, id, x, y)
		local bt, tt = nil, nil
		if Logic.GetEntityType(id)==Entities.PU_Hero2 then
			bt, tt = Entities.PU_Hero2_Foundation1, Entities.PU_Hero2_Cannon1
		elseif Logic.GetEntityType(id)==Entities.PU_Hero3 then
			bt, tt = Entities.PU_Hero3_Trap, Entities.PU_Hero3_TrapCannon
		end
		assert(bt)
		PostEvent.HeroPlaceCannonAbility(id, bt, tt, x, y)
	end,
	Range = 2000,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityCircularAttack] = {
	RequiresHook = false,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.Self,
	Use = function(army, id)
		GUI.SettlerCircularAttack(id)
	end,
	Range = 0,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
	RequiredRange = 500,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityConvertSettlers] = {
	RequiresHook = true,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.EnemyEntity,
	PrefersBackline = true,
	Use = function(army, id, tid)
		--PostEvent.HeroConvertSettlerAbility(id, tid)
		ConvertEntityCallback(id, tid, function(nid, army)
			army:AddLeader(nid)
		end, army)
	end,
	Range = 1400,
	IsInstant = false,
	RequiredEnemiesInArea = 3,
	TargetCooldown = 30,
	TargetCondition = UnlimitedArmy.IsFearAffectableAndConvertable,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityInflictFear] = {
	RequiresHook = false,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.Self,
	Use = function(army, id)
		GUI.SettlerInflictFear(id)
	end,
	Range = 0,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
	RequiredRange = 1000,
	AreaCondition = UnlimitedArmy.IsFearAffectableAndConvertable,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityPlaceBomb] = {
	RequiresHook = true,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.Pos,
	Use = function(army, id, x, y)
		PostEvent.HeroPlaceBombAbility(id, x, y)
	end,
	Range = 500,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
	RequiredRange = 500,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityPlaceKeg] = {
	RequiresHook = true,
	Combat = true,
	PrepDefense = true, -- with this, thieves can target bridges in idle
	TargetType = UnlimitedArmy.HeroAbilityTargetType.EnemyBuilding,
	Use = function(army, id, tid)
		PostEvent.ThiefSabotage(id, tid)
	end,
	Range = 10000,
	PreventUse = function(army, id)
		return Logic.IsTechnologyResearched(army.Player, Technologies.T_ThiefSabotage)==0
	end,
	IsInstant = false,
	TargetCooldown = 30,
	TargetBridgesAsSecondaryTargetIfAllowed = true,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityRangedEffect] = {
	RequiresHook = false,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.Self,
	Use = function(army, id)
		GUI.SettlerAffectUnitsInArea(id)
	end,
	Range = 0,
	PreventUse = function(army, id)
		if Logic.GetEntityType(id)==Entities.PU_Hero3 then
			for _,l in ipairs(army.Leaders) do
				local hp = Logic.GetEntityHealth(l)
				if hp > 0 and hp < Logic.GetEntityMaxHealth(l)/2 then
					return false
				end
			end
			return true
		end
		local r = Logic.GetEntityType(id)==Entities.PU_Hero10 and 2500 or 1000
		return UnlimitedArmy.GetNumberOfEnemiesInArea(GetPosition(id), army.Player, r, army.AIActive, nil) < 5
	end,
	IsInstant = true,
	--RequiredEnemiesInArea = 5,
	--RequiredRange = 1000,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityShuriken] = {
	RequiresHook = true,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.EnemyEntity,
	Use = function(army, id, tid)
		PostEvent.HeroShurikenAbility(id, tid)
	end,
	Range = 3000,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilitySniper] = {
	RequiresHook = true,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.EnemyEntity,
	PrefersHighHP = true,
	Use = function(army, id, tid)
		PostEvent.HeroSniperAbility(id, tid)
	end,
	Range = 5500,
	IsInstant = false,
	--RequiredEnemiesInArea = 5,
	TargetCooldown = 30,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilitySummon] = {
	RequiresHook = false,
	Combat = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.Self,
	Use = function(army, id)
		GUI.SettlerSummon(id) -- TODO add summons to army
	end,
	Range = 0,
	IsInstant = true,
	RequiredEnemiesInArea = 5,
}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityMotivateWorkers] = {
	RequiresHook = true,
	Combat = false,
	PrepDefense = true,
	TargetType = UnlimitedArmy.HeroAbilityTargetType.Self,
	Use = function(army, id)
		GUI.SettlerMotivateWorkers(id)
	end,
	IsInstant = false,
}

UnlimitedArmy:AStatic()
UnlimitedArmy.BridgeEntityTypes = {
	Entities.PB_Bridge1,
	Entities.PB_Bridge2,
	Entities.PB_Bridge3,
	Entities.PB_Bridge4,
	Entities.XD_DrawBridgeOpen1,
	Entities.XD_DrawBridgeOpen2,
}

UnlimitedArmy:AStatic()
UnlimitedArmy.IgnoreEtypes = {
	[Entities.PU_Hero1_Hawk] = true,
	[Entities.PB_Tower2_Ballista] = true,
	[Entities.PB_Tower3_Cannon] = true,
	[Entities.PB_DarkTower2_Ballista] = true,
	[Entities.PB_DarkTower3_Cannon] = true,
	[Entities.PU_Hero2_Cannon1] = true,
	[Entities.PU_Hero3_Trap] = true,
	[Entities.PU_Hero3_TrapCannon] = true,
}
if Entities.CB_Evil_Tower1_ArrowLauncher then
	UnlimitedArmy.IgnoreEtypes[Entities.CB_Evil_Tower1_ArrowLauncher] = true
end

UnlimitedArmy:AStatic()
UnlimitedArmy.EntityTypeArray = {}

UnlimitedArmy:FinalizeClass()

for en, e in pairs(Entities) do
	if string.find(en, "[PC][UBV]") and not UnlimitedArmy.IgnoreEtypes[e] then
		table.insert(UnlimitedArmy.EntityTypeArray, e)
	end
end

UnlimitedArmyFiller = {}
UnlimitedArmyFiller = LuaObject:CreateSubClass("UnlimitedArmyFiller")

UnlimitedArmyFiller:AMethod()
UnlimitedArmyFiller.Tick = LuaObject_AbstractMethod

UnlimitedArmyFiller:AMethod()
UnlimitedArmyFiller.IsDead = LuaObject_AbstractMethod

UnlimitedArmyFiller:AMethod()
UnlimitedArmyFiller.Remove = LuaObject_AbstractMethod

UnlimitedArmyFiller:FinalizeClass()
