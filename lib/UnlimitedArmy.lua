if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/comfort/other/PredicateHelper")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/entity/IsEntityOfType")
mcbPacker.require("s5CommunityLib/comfort/pos/GetCirclePosition")
mcbPacker.require("s5CommunityLib/comfort/pos/GetAngleBetween")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- Neue Armeefunktion, basierend auf OOP.
-- Keine Mengenbegrenzung an Armeen.
-- Steuerung über OOP.
-- Kein "vorbeirennen" an Gegnern.
-- verfolgen von Entities.
-- automatischer einsatz von heldenfähigkeiten.
-- 
-- - Army = UnlimitedArmy.New({					erstellt eine Armee.
-- 			-- benötigt
-- 			Player,
-- 			Area,
-- 			-- optional
-- 			AutoDestroyIfEmpty,
-- 			Formation,
-- 		})
-- 
-- Army.Player
-- Army.Leaders
-- Army.AutoDestroyIfEmpty
-- Army.Area
-- 
-- Army:AddLeader(id)							Fügt id zur army hinzu.
-- Army:RemoveLeader(id)						Entfernt id aus der army.
-- Army:GetSize()								Anzahl der Leader.
-- Army:Destroy()								Entfernt die Army, alle leader bleiben wo sie sind.
-- Army:KillAllLeaders()						Tötet alle leader.
-- Army:IsDead()								-1-> destroyed, 2->kein leader, aber spawner, 1->kein leader, 3->hatte keinen leader, false->min 1 leader.
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
-- Army:CreateLeaderForArmy(ety, sol, pos, experience)
-- 												erstellt einen leader und verbindet ihn mit der army.
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
UnlimitedArmy = {Leaders=nil, Player=nil, AutoDestroyIfEmpty=nil, HadOneLeader=nil, Trigger=nil,
	Area=nil, CurrentBattleTarget=nil, Target=nil, Spawner=nil, FormationRotation=nil, Formation=nil,
	CommandQueue=nil, ReMove=nil, HeroTargetingCache=nil,
}

UnlimitedArmy.Status = {Idle = 1, Moving = 2, Battle = 3, Destroyed = 4, IdleUnformated = 5, MovingNoBattle = 6}
UnlimitedArmy.CommandType = {Move = 1, Defend = 2, Flee = 3, WaitForIdle = 5, LuaFunc = 6, AttackNearest = 7}

function UnlimitedArmy.New(data)
	local self = CopyTable(UnlimitedArmy, {[UnlimitedArmy.EntityTypeArray]=UnlimitedArmy.EntityTypeArray,
		[UnlimitedArmy.Formations]=UnlimitedArmy.Formations,
		[UnlimitedArmy.HeroAbilityConfigs]=UnlimitedArmy.HeroAbilityConfigs,
		[UnlimitedArmy.HeroAbilityTargetType]=UnlimitedArmy.HeroAbilityTargetType,
	})
	self.New = nil
	self.EntityTypeArray = nil
	self.Formations = nil
	self.HeroAbilityConfigs = nil
	self.HeroAbilityTargetType = nil
	self.Leaders = {}
	self.Player = assert(data.Player)
	self.Area = assert(data.Area)
	self.FormationRotation = 0
	self.Formation = data.Formation or UnlimitedArmy.Formations.Chaotic
	self.AutoDestroyIfEmpty = data.AutoDestroyIfEmpty
	self.HadOneLeader = false
	self.CommandQueue = {}
	self.HeroTargetingCache = {}
	self.Status = UnlimitedArmy.Status.Idle
	self.Trigger = StartSimpleJob(self.Tick, self)
	return self
end

function UnlimitedArmy:CheckValidArmy()
	assert(self.Status ~= UnlimitedArmy.Status.Destroyed)
	assert(self ~= UnlimitedArmy)
end

function UnlimitedArmy:Tick()
	self:CheckValidArmy()
	self:RemoveAllDestroyedLeaders()
	if self:GetSize() == 0 then
		if self.AutoDestroyIfEmpty and self.HadOneLeader and not self.Spawner then
			self:Destroy()
		end
		if self.Spawner then
			self.Spawner:Tick()
		end
		return
	end
	if self.Spawner then
		self.Spawner:Tick()
	end
	local preventfurthercommands = false
	self:CheckBattle()
	if not preventfurthercommands and self.Status ~= UnlimitedArmy.Status.MovingNoBattle and IsValid(self.CurrentBattleTarget) then
		self.Status = UnlimitedArmy.Status.Battle
		self:DoBattleCommands()
		preventfurthercommands = true
	end
	if not preventfurthercommands and GetDistance(self:GetPosition(), self.Target)>1000 then
		if self.Status ~= UnlimitedArmy.Status.MovingNoBattle and self.Status ~= UnlimitedArmy.Status.Moving then
			self.Status = UnlimitedArmy.Status.Moving
		end
		self:DoMoveCommands()
		preventfurthercommands = true
	end
	if not preventfurthercommands and self.Status ~= UnlimitedArmy.Status.Idle then
		self.Status = UnlimitedArmy.Status.Idle
		self:DoFormationCommands()
		preventfurthercommands = true
	end
	self:ProcessCommandQueue()
end

function UnlimitedArmy:AddLeader(id)
	self:CheckValidArmy()
	id = GetID(id)
	table.insert(self.Leaders, id)
	if not self.Target then
		self.Target = GetPosition(id)
	end
	self.HadOneLeader = true
	self:RequireNewFormat()
end

function UnlimitedArmy:RemoveLeader(id)
	self:CheckValidArmy()
	id = GetID(id)
	for i=table.getn(self.Leaders),1,-1 do
		if self.Leaders[i] == id then
			table.remove(self.Leaders, i)
		end
	end
	self:RequireNewFormat()
end

function UnlimitedArmy:CreateLeaderForArmy(ety, sol, pos, experience)
	self:CheckValidArmy()
	self:AddLeader(AI.Entity_CreateFormation(self.Player, ety, nil, sol, pos.X, pos.Y, nil, nil, experience or 0, 0))
end

function UnlimitedArmy:RequireNewFormat()
	self:CheckValidArmy()
	if self.Status == UnlimitedArmy.Status.Idle then
		self.Status = UnlimitedArmy.Status.IdleUnformated
	end
end

function UnlimitedArmy:RemoveAllDestroyedLeaders()
	self:CheckValidArmy()
	for i=table.getn(self.Leaders),1,-1 do
		if IsDestroyed(self.Leaders[i]) then
			table.remove(self.Leaders, i)
			self:RequireNewFormat()
		end
	end
end

function UnlimitedArmy:GetSize()
	self:CheckValidArmy()
	return table.getn(self.Leaders)
end

function UnlimitedArmy:Destroy()
	self.Status = UnlimitedArmy.Status.Destroyed
	EndJob(self.Trigger)
end

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

function UnlimitedArmy:DoHeroAbilities(id, nume)
	self:CheckValidArmy()
	if Logic.IsHero(id)==0 and not UnlimitedArmy.IsNonCombatEntity(id) then
		return false
	end
	local noninstant = false
	for ab, acf in pairs(UnlimitedArmy.HeroAbilityConfigs) do
		if not (noninstant and acf.IsInstant) then
			if Logic.HeroIsAbilitySupported(id, ab)==1 and Logic.HeroGetAbiltityChargeSeconds(id, ab)==Logic.HeroGetAbilityRechargeTime(id, ab) then
				local executeAbility = true
				if acf.RequiredEnemiesInArea then
					if acf.RequiredRange then
						if UnlimitedArmy.GetNumberOfEnemiesInArea(GetPosition(id), self.Player, acf.RequiredRange) < acf.RequiredEnemiesInArea then
							executeAbility = false
						end
					else
						if nume < acf.RequiredEnemiesInArea then
							executeAbility = false
						end
					end
				end
				if acf.PreventUse and acf.PreventUse(self, id) then
					executeAbility = false
				end
				if acf.RequiresHook and not S5Hook then
					executeAbility = false
				end
				if executeAbility then
					if acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.Self then
						acf.Use(self, id)
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.Pos then
						local p = GetPosition(id)
						acf.Use(self, id, p.X, p.Y)
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.FreePos then
						local p = GetPosition(id)
						acf.Use(self, id, p.X+GetRandom(-500,500), p.Y+GetRandom(-500,500)) -- command should be ignored with invalid position
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.EnemyEntity then
						if acf.PrefersBackline then
							local tid = UnlimitedArmy.GetFurthestEnemyInArea(GetPosition(id), self.Player, acf.Range, true)
							if IsValid(tid) and self:CheckHeroTargetingCache(tid, acf.TargetCooldown) then
								acf.Use(self, id, tid)
							end
						else
							local tid = UnlimitedArmy.GetNearestEnemyInArea(GetPosition(id), self.Player, acf.Range, true)
							if IsValid(tid) and self:CheckHeroTargetingCache(tid, acf.TargetCooldown) then
								acf.Use(self, id, tid)
							end
						end
					elseif acf.TargetType == UnlimitedArmy.HeroAbilityTargetType.EnemyBuilding then
						local tid = UnlimitedArmy.GetNearestEnemyInArea(GetPosition(id), self.Player, acf.Range, nil, true)
						if IsValid(tid) and self:CheckHeroTargetingCache(tid, acf.TargetCooldown) then
							acf.Use(self, id, tid)
						end
					end
					noninstant = acf.IsInstant
				end
			end
		end
	end
	return noninstant
end

function UnlimitedArmy:CheckBattle()
	self:CheckValidArmy()
	if IsDead(self.CurrentBattleTarget) or GetDistance(self:GetPosition(), self.CurrentBattleTarget)>self.Area then
		self.CurrentBattleTarget = self:GetFirstEnemyInArmyRange()
	end
end

function UnlimitedArmy:DoBattleCommands()
	self:CheckValidArmy()
	local tpos = GetPosition(self.CurrentBattleTarget)
	local nume = UnlimitedArmy.GetNumberOfEnemiesInArea(self:GetPosition(), self.Player, self.Area)
	for _,id in ipairs(self.Leaders) do
		local DoCommands = not self:DoHeroAbilities(id, nume)
		if UnlimitedArmy.IsLeaderIdleOrMoving(id) and not UnlimitedArmy.IsNonCombatEntity(id) then
			if DoCommands and UnlimitedArmy.IsRangedEntity(id) then
				Logic.GroupAttack(id, self.CurrentBattleTarget)
			elseif DoCommands then
				Logic.GroupAttackMove(id, tpos.X, tpos.Y, -1)
			end
		end
	end
end

function UnlimitedArmy:DoMoveCommands()
	self:CheckValidArmy()
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

function UnlimitedArmy:DoFormationCommands()
	self:CheckValidArmy()
	self:Formation(self.Target)
end

function UnlimitedArmy:ProcessCommandQueue()
	self:CheckValidArmy()
	local com = self.CommandQueue[1]
	if com then
		if com.c == UnlimitedArmy.CommandType.LuaFunc then
			local adv, tmpcmd = com.func(self, com)
			if adv and com == self.CommandQueue[1] then
				self:AdvanceCommand()
			end
			if tmpcmd then
				com = tmpcmd
			end
		end
		if com.c == UnlimitedArmy.CommandType.Move then
			self.Target = com.pos
			self.ReMove = true
			if com == self.CommandQueue[1] then
				self:AdvanceCommand()
			end
		elseif com.c == UnlimitedArmy.CommandType.Flee then
			self.Target = com.pos
			self.Status = UnlimitedArmy.Status.MovingNoBattle
			self.ReMove = true
			if com == self.CommandQueue[1] then
				self:AdvanceCommand()
			end
		elseif com.c == UnlimitedArmy.CommandType.Defend then
			if com.pos == nil then
				com.pos = self:GetPosition()
			end
			if self:GetSize()==0 then
				if com == self.CommandQueue[1] then
					self:AdvanceCommand()
				end
				self.Target = com.area
				self.ReMove = true
			elseif GetDistance(self:GetPosition(), com.pos) > com.distArea then
				self.Status = UnlimitedArmy.Status.MovingNoBattle
				self.Target = com.pos
				self.ReMove = true
			elseif self:IsIdle() then
				local tid = UnlimitedArmy.GetFirstEnemyInArea(com.pos, self.Player, com.distArea)
				if IsValid(tid) then
					self.Target = GetPosition(tid)
					self.ReMove = true
				else
					self.Target = com.pos
					self.ReMove = true
				end
			end
		elseif com.c == UnlimitedArmy.CommandType.WaitForIdle then
			if self:IsIdle() then
				if com == self.CommandQueue[1] then
					self:AdvanceCommand()
				end
			end
		elseif com.c == UnlimitedArmy.CommandType.AttackNearest then
			local tid = UnlimitedArmy.GetNearestEnemyInArea(self:GetPosition(), self.Player, com.maxrange)
			if IsValid(tid) then
				self.Target = GetPosition(tid)
				self.ReMove = true
				if com == self.CommandQueue[1] then
					self:AdvanceCommand()
				end
			end
		end
	end
end

function UnlimitedArmy:AdvanceCommand()
	self:CheckValidArmy()
	if self.CommandQueue[1] then
		local c = self.CommandQueue[1]
		table.remove(self.CommandQueue, 1)
		if c.looped then
			table.insert(self.CommandQueue, c)
		end
	end
end

function UnlimitedArmy:GetFirstEnemyInArmyRange()
	self:CheckValidArmy()
	return UnlimitedArmy.GetFirstEnemyInArea(self:GetPosition(), self.Player, self.Area)
end

function UnlimitedArmy:IsIdle()
	self:CheckValidArmy()
	if self.Status ~= UnlimitedArmy.Status.Idle then
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

function UnlimitedArmy:IsDead()
	if self.Status == UnlimitedArmy.Status.Destroyed then
		return -1
	end
	if self:GetSize()==0 then
		if self.Spawner then
			return 2
		end
		if not self.HadOneLeader then
			return 3
		end
		return 1
	end
	return false
end

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

function UnlimitedArmy:ClearCommandQueue()
	self:CheckValidArmy()
	self.CommandQueue = {}
end

function UnlimitedArmy:AddCommandMove(p, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, {
		c = UnlimitedArmy.CommandType.Move,
		pos = p,
		looped = looped,
	})
end

function UnlimitedArmy:AddCommandFlee(p, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, {
		c = UnlimitedArmy.CommandType.Flee,
		pos = p,
		looped = looped,
	})
end

function UnlimitedArmy:AddCommandDefend(defendPos, defendArea, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, {
		c = UnlimitedArmy.CommandType.Defend,
		looped = looped,
		distArea = defendArea or self.Area,
		pos = defendPos,
	})
end

function UnlimitedArmy:AddCommandWaitForIdle(looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, {
		c = UnlimitedArmy.CommandType.WaitForIdle,
		looped = looped,
	})
end

function UnlimitedArmy:AddCommandLuaFunc(func, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, {
		c = UnlimitedArmy.CommandType.LuaFunc,
		looped = looped,
		func = func,
	})
end

function UnlimitedArmy:AddCommandAttackNearestTarget(maxrange, looped)
	self:CheckValidArmy()
	table.insert(self.CommandQueue, {
		c = UnlimitedArmy.CommandType.AttackNearest,
		looped = looped,
		maxrange = maxrange,
	})
end

function UnlimitedArmy.GetFirstEnemyInArea(p, player, area, leader, building)
	if p == invalidPosition then
		return nil
	end
	if not S5Hook then
		return UnlimitedArmy.NoHookGetEntitiesInArea(p, player, area, leader, building)
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
		if not MemoryManipulation or not MemoryManipulation.IsEntityInvisible(id) then
			return id
		end
	end
end

function UnlimitedArmy.GetNearestEnemyInArea(p, player, area, leader, building)
	if p == invalidPosition then
		return nil
	end
	if not S5Hook then
		return UnlimitedArmy.NoHookGetEntitiesInArea(p, player, area, leader, building)
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
		if not MemoryManipulation or not MemoryManipulation.IsEntityInvisible(id) then
			local cd = GetDistance(id, p)
			if not d or cd < d then
				r, d = id, cd
			end
		end
	end
	return r
end

function UnlimitedArmy.GetFurthestEnemyInArea(p, player, area, leader, building)
	if p == invalidPosition then
		return nil
	end
	if not S5Hook then
		return UnlimitedArmy.NoHookGetEntitiesInArea(p, player, area, leader, building)
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
		if not MemoryManipulation or not MemoryManipulation.IsEntityInvisible(id) then
			local cd = GetDistance(id, p)
			if not d or cd > d then
				r, d = id, cd
			end
		end
	end
	return r
end

function UnlimitedArmy.GetNumberOfEnemiesInArea(p, player, area)
	if p == invalidPosition then
		return 0
	end
	local num = 0
	for id in S5Hook.EntityIterator(PredicateHelper.GetEnemyPlayerPredicate(player),
		PredicateHelper.GetETypePredicate(UnlimitedArmy.EntityTypeArray),
		Predicate.InCircle(p.X, p.Y, area)
	) do
		if not MemoryManipulation or not MemoryManipulation.IsEntityInvisible(id) then
			num = num + 1
		end
	end
	return num
end

function UnlimitedArmy.NoHookGetEnemyInArea(p, player, area, leader, buildings)
	for i=1, 8 do
		if Logic.GetDiplomacyState(i, player)==Diplomacy.Hostile then
			local _, id = Logic.GetPlayerEntitiesInArea(i, 0, p.X, p.Y, area or 999999999, 1)
			if IsValid(id) then
				return id
			end
		end
	end
end

function UnlimitedArmy.IsLeaderIdleOrMoving(id)
	if IsDead(id) then
		return false
	end
	local tl = Logic.GetCurrentTaskList(id)
	if not tl then
		return false
	end
	if (string.find(tl, "WALK") or string.find(tl, "IDLE")) and not string.find(tl, "BATTLE") then
		return true
	end
	return false
end

function UnlimitedArmy.IsLeaderIdle(id)
	if IsDead(id) then
		return false
	end
	local tl = Logic.GetCurrentTaskList(id)
	if not tl then
		return false
	end
	if string.find(tl, "IDLE") then
		return true
	end
	return false
end

function UnlimitedArmy.IsLeaderMoving(id)
	if IsDead(id) then
		return false
	end
	local tl = Logic.GetCurrentTaskList(id)
	if not tl then
		return false
	end
	if string.find(tl, "WALK") then
		return true
	end
	return false
end

function UnlimitedArmy.IsRangedEntity(id)
	return Logic.IsEntityInCategory(id, EntityCategories.LongRange)==1 or Logic.IsEntityInCategory(id, EntityCategories.Cannon)==1
	or IsEntityOfType(id, "PU_Hero5", "PU_Hero10", "CU_BanditLeaderBow1")
end

function UnlimitedArmy.IsNonCombatEntity(id)
	return IsEntityOfType(id, Entities.PU_Thief, Entities.PU_Scout)
end

function UnlimitedArmy.MoveAndSetTargetRotation(id, pos, r)
	Logic.GroupAttackMove(id, pos.X, pos.Y, r)
end

UnlimitedArmy.Formations = {}
function UnlimitedArmy.Formations.Chaotic(army, pos)
	army.ChaotocCache = army.ChaotocCache or {}
	local l = table.getn(army.Leaders)*100
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

UnlimitedArmy.HeroAbilityConfigs = {}
UnlimitedArmy.HeroAbilityTargetType = {FreePos=1,Self=2,EnemyEntity=3,Pos=4,EnemyBuilding=5}
UnlimitedArmy.HeroAbilityConfigs[Abilities.AbilityBuildCannon] = {
	RequiresHook = true,
	Combat = true,
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
		PostEvent.HeroConvertSettlerAbility(id, tid) -- TODO get id of converted and add to army
		--[[StartSimpleJob(function(id, tid, army, t)
			t.t = t.t - 1
			if Logic.GetCurrentTaskList(id)~="TL_CONVERT_SETTLERS" and t.t<0 then
				if IsDestroyed(tid) then
					tid = entityIdChangedHelper.getNewID(id)
				end
				if IsAlive(tid) and GetPlayer(tid)==army.Player then
					army:AddLeader(tid)
					Message("found")
				end
				Message("end")
				return true
			end
		end, id, tid, army, {t=2})]]
	end,
	Range = 1400,
	IsInstant = false,
	RequiredEnemiesInArea = 5,
	TargetCooldown = 30,
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
	TargetType = UnlimitedArmy.HeroAbilityTargetType.EnemyBuilding,
	Use = function(army, id, tid)
		PostEvent.ThiefSabotage(id, tid)
	end,
	Range = 5000,
	PreventUse = function(army, id)
		return Logic.IsTechnologyResearched(army.Player, Technologies.T_ThiefSabotage)==0
	end,
	IsInstant = false,
	RequiredEnemiesInArea = 1,
	TargetCooldown = 30,
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
		return false
	end,
	IsInstant = true,
	RequiredEnemiesInArea = 5,
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
	RequiredEnemiesInArea = 5,
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


local IgnoreEtypes = {
	[Entities.PU_Hero1_Hawk] = true,
}

UnlimitedArmy.EntityTypeArray = {}

for en, e in pairs(Entities) do
	if string.find(en, "[PC][UBV]") and not IgnoreEtypes[e] then
		table.insert(UnlimitedArmy.EntityTypeArray, e)
	end
end
