if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/lib/UnlimitedArmy")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
mcbPacker.require("s5CommunityLib/comfort/entity/EntityIdChangedHelper")
mcbPacker.require("s5CommunityLib/comfort/number/GetRandom")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- truppen rekrutierer für UnlimitedArmy.
-- 
-- Recruiter = UnlimitedArmyRecruiter.New(army, {
-- 			-- benötigt:
-- 			Buildings = {id...},
-- 			ArmySize,
-- 			UCats = {
-- 				{UCat, SpawnNum, Looped},
-- 				--...
-- 			},
-- 			-- optional:
-- 			ResCheat,
-- 			ReorderAllowed,
-- 			RemoveUnavailable,
-- 		})
-- 	
-- - Recruiter:Remove()									entfernt den spawner.
-- - Recruiter:IsDead()									gibt zurück, ob der spawngenerator tot (und der spawner somit nutzlos) ist.
-- - Recruiter:AddBuilding(id)							fügt ein rekrutierungsgebäude hinzu.
-- - Recruiter:RemoveBuilding(id)						entfernt ein rekrutierungsgebäude.
-- - Recruiter:AddUCat(ucat, spawnnum, looped)			fügt einen kaufauftrag hinzu.
-- - Recruiter:RemoveUCat(ucat)							entfernt alle kaufaufträge der ucat.
-- 
-- Benötigt:
-- - CopyTable
-- - UnlimitdArmy
-- - GetDistance
UnlimitedArmyRecruiter = {Army=nil, Buildings=nil, ArmySize=nil, UCats=nil, ResCheat=nil, InRecruitment=nil, AddTrigger=nil,
	TriggerType=nil, TriggerBuild=nil, Cannons=nil, ReorderAllowed=nil, RemoveUnavailable=nil,
}

UnlimitedArmyRecruiter = UnlimitedArmyFiller:CreateSubClass("UnlimitedArmyRecruiter")


UnlimitedArmyRecruiter:AStatic()
UnlimitedArmyRecruiter.NumCache = {}

UnlimitedArmyRecruiter:AReference()
function UnlimitedArmyRecruiter:New(army, data) end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:Init(army, data)
	self:CallBaseMethod("Init", UnlimitedArmyRecruiter)
	assert(army:InstanceOf(UnlimitedArmy))
	self.Buildings = data.Buildings
	assert(self.Buildings[1] and IsAlive(self.Buildings[1]))
	self.ArmySize = assert(data.ArmySize)
	self.UCats = {}
	self.ResCheat = data.ResCheat
	self.InRecruitment = {}
	self.Cannons = {}
	self.ReorderAllowed = data.ReorderAllowed
	self.RemoveUnavailable = data.RemoveUnavailable
	self.AddTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, ":CheckAddRecruitment", 1, nil, {self})
	self.Army = army
	army.Spawner = self
	for _,d in ipairs(data.UCats) do
		self:AddUCat(d.UCat, d.SpawnNum, d.Looped)
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:IsDead()
	assert(self ~= UnlimitedArmyRecruiter)
	if not self.Army then
		return true
	end
	for _,id in ipairs(self.Buildings) do
		if IsAlive(id) then
			return false
		end
	end
	return self.UCats[1] and true or false
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:CheckValidSpawner()
	assert(self ~= UnlimitedArmyRecruiter)
	assert(self.Army or self.DetachedFunc)
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:Tick(active)
	self:CheckValidSpawner()
	self:CheckLeaders(self.Army, self.Army.AddLeader)
	if self:IsDead() then
		if (table.getn(self.InRecruitment) + self:GetCannonBuyNum())<=0 then
			self:Remove()
		end
		return
	end
	if active and (self.Army:GetSize(true, true) + table.getn(self.InRecruitment) + self:GetCannonBuyNum())<self.ArmySize then
		self:ForceSpawn(self.ArmySize - (self.Army:GetSize(true, true) + table.getn(self.InRecruitment) + self:GetCannonBuyNum()))
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:TickDetached()
	self:CheckValidSpawner()
	self:CheckLeaders(self.DetachedObject, self.DetachedFunc)
	if table.getn(self.InRecruitment) + self:GetCannonBuyNum() <= 0 then
		self:Remove()
		return true
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:GetCannonBuyNum()
	self:CheckValidSpawner()
	local i=0
	for _,_ in pairs(self.Cannons) do
		i = i + 1
	end
	return i
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:CheckLeaders(obj, f)
	self:CheckValidSpawner()
	for i=table.getn(self.Buildings),1,-1 do
		local alive = true
		if IsDead(self.Buildings[i]) then
			if self.Cannons[self.Buildings[i]] then
				if IsValid(self.Cannons[self.Buildings[i]]) then
					f(obj, self.Cannons[self.Buildings[i]])
				end
				self.Cannons[self.Buildings[i]] = nil
				UnlimitedArmyRecruiter.NumCache[self.Buildings[i]] = UnlimitedArmyRecruiter.NumCache[self.Buildings[i]] - 1
			end
			local nid = EntityIdChangedHelper.GetNewID(self.Buildings[i])
			if IsValid(nid) then
				self.Buildings[i] = nid
			else
				table.remove(self.Buildings, i)
				alive = false
			end
		end
		if alive and self.Cannons[self.Buildings[i]] then
			local c = Logic.GetLeaderTrainingAtBuilding(self.Buildings[i])
			if self.Cannons[self.Buildings[i]] == -1 and IsValid(c) then
				self.Cannons[self.Buildings[i]] = c
			elseif self.Cannons[self.Buildings[i]]~=-1 and c==0 then
				if IsValid(self.Cannons[self.Buildings[i]]) then
					f(obj, self.Cannons[self.Buildings[i]])
				end
				self.Cannons[self.Buildings[i]] = nil
				UnlimitedArmyRecruiter.NumCache[self.Buildings[i]] = UnlimitedArmyRecruiter.NumCache[self.Buildings[i]] - 1
			end
		end
	end
	for i=table.getn(self.InRecruitment),1,-1 do
		if IsDestroyed(self.InRecruitment[i].Id) then
			local nid = EntityIdChangedHelper.GetNewID(self.InRecruitment[i].Id)
			if nid then
				self.InRecruitment[i].Id = nid
			end
		end
		if IsDestroyed(self.InRecruitment[i].Id) then
			local d = table.remove(self.InRecruitment, i)
			UnlimitedArmyRecruiter.NumCache[d.Building] = UnlimitedArmyRecruiter.NumCache[d.Building] - 1
		elseif Logic.LeaderGetBarrack(self.InRecruitment[i].Id)==0 then
			local d = table.remove(self.InRecruitment, i)
			f(obj, d.Id)
			UnlimitedArmyRecruiter.NumCache[d.Building] = UnlimitedArmyRecruiter.NumCache[d.Building] - 1
		end
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:ForceSpawn(num)
	self:CheckValidSpawner()
	for i=1, num do
		if self:SpawnOneLeader() then
			return
		end
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:IsSpawnPossible()
	self:CheckValidSpawner()
	return not self:IsDead()
end

UnlimitedArmyRecruiter:AStatic()
UnlimitedArmyRecruiter.UCatBuyTypes = {
	[UpgradeCategories.LeaderSword] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderPoleArm] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderBandit] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderBarbarian] = UpgradeCategories.Barracks,
	[UpgradeCategories.BlackKnightLeaderMace1] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderBow] = UpgradeCategories.Archery,
	[UpgradeCategories.LeaderCavalry] = UpgradeCategories.Stable,
	[UpgradeCategories.LeaderHeavyCavalry] = UpgradeCategories.Stable,
}
if UpgradeCategories.Thief then
	UnlimitedArmyRecruiter.UCatBuyTypes[UpgradeCategories.Thief] = UpgradeCategories.Tavern
	UnlimitedArmyRecruiter.UCatBuyTypes[UpgradeCategories.Scout] = UpgradeCategories.Tavern
	UnlimitedArmyRecruiter.UCatBuyTypes[UpgradeCategories.Evil_LeaderBearman] = UpgradeCategories.Barracks
	UnlimitedArmyRecruiter.UCatBuyTypes[UpgradeCategories.Evil_LeaderSkirmisher] = UpgradeCategories.Archery
	UnlimitedArmyRecruiter.UCatBuyTypes[UpgradeCategories.LeaderRifle] = UpgradeCategories.Archery
end
if UpgradeCategories.LeaderBanditBow then
	UnlimitedArmyRecruiter.UCatBuyTypes[UpgradeCategories.LeaderBanditBow] = UpgradeCategories.Archery
end

UnlimitedArmyRecruiter:AStatic()
UnlimitedArmyRecruiter.CannonBuyTypes = {
	[UpgradeCategories.Cannon1] = UpgradeCategories.Foundry,
	[UpgradeCategories.Cannon2] = UpgradeCategories.Foundry,
	[UpgradeCategories.Cannon3] = UpgradeCategories.Foundry,
	[UpgradeCategories.Cannon4] = UpgradeCategories.Foundry,
}

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:SpawnOneLeader()
	self:CheckValidSpawner()
	if Logic.GetPlayerAttractionUsage(self.Army.Player) >= Logic.GetPlayerAttractionLimit(self.Army.Player) then
		return
	end
	if Logic.GetAverageMotivation(self.Army.Player) < Logic.GetLogicPropertiesMotivationThresholdVCLock() then
		return
	end
	if not self.UCats[1] then
		return
	end
	local buyT = UnlimitedArmyRecruiter.UCatBuyTypes[self.UCats[1].UCat]
	local cbuyT = UnlimitedArmyRecruiter.CannonBuyTypes[self.UCats[1].UCat]
	local buyingAt = 0
	local hasOneBuilding = false
	if buyT then
		for _,id in ipairs(self.Buildings) do
			if Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(id))==buyT then
				hasOneBuilding = true
				if self:GetNumberTrainingAtBuilding(id)<3 and Logic.GetEntityHealth(id)/Logic.GetEntityMaxHealth(id)>0.2 then
					buyingAt = id
					break
				end
			end
		end
	elseif cbuyT then
		for _,id in ipairs(self.Buildings) do
			if Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(id))==cbuyT then
				hasOneBuilding = true
				if self:GetNumberTrainingAtBuilding(id)<1 and Logic.GetEntityHealth(id)/Logic.GetEntityMaxHealth(id)>0.2 then
					local num, wid = Logic.GetAttachedWorkersToBuilding(id)
					if num>=1 and Logic.GetCurrentTaskList(wid)=="TL_SMELTER_WORK1_WAIT"
					and not InterfaceTool_IsBuildingDoingSomething(id)
					and Logic.GetCannonProgress(id)==100 then
						buyingAt = id
						break
					end
				end
			end
		end
	else
		assert(false)
	end
	if buyingAt ~= 0 then
		local c = {}
		Logic.FillLeaderCostsTable(self.Army.Player, self.UCats[1].UCat, c)
		if self:CheckResources(c, true) then
			UnlimitedArmyRecruiter.NumCache[buyingAt] = UnlimitedArmyRecruiter.NumCache[buyingAt] + 1
			if buyT then
				self.TriggerType = Logic.GetSettlerTypeByUpgradeCategory(self.UCats[1].UCat, self.Army.Player)
				self.TriggerBuild = buyingAt
				Logic.BarracksBuyLeader(buyingAt, self.UCats[1].UCat)
			else
				local ty = Logic.GetSettlerTypeByUpgradeCategory(self.UCats[1].UCat, self.Army.Player)
				if S5Hook then
					PostEvent.FoundryConstructCannon(buyingAt, ty)
				else
					local playerId = GUI.GetPlayerID()
					local selected = {GUI.GetSelectedEntities()}
					GUI.SetControlledPlayer(self.Army.Player)
					GUI.BuyCannon(buyingAt, ty)
					GUI.SetControlledPlayer(playerId)
					Logic.PlayerSetGameStateToPlaying(playerId)
					Logic.ForceFullExplorationUpdate()
					for i = 1, table.getn(selected), 1 do
						GUI.SelectEntity(selected[i])
					end
				end
				self.Cannons[buyingAt] = -1
			end
		end
		self.UCats[1].CurrNum = self.UCats[1].CurrNum - 1
		if self.UCats[1].CurrNum <= 0 then
			local d = table.remove(self.UCats, 1)
			if d.Looped then
				self:ResetUCatNum(d)
				table.insert(self.UCats, d)
			end
		end
	elseif not hasOneBuilding and self.RemoveUnavailable then
		table.remove(self.UCats, 1)
	elseif self.ReorderAllowed then
		table.insert(self.UCats, table.remove(self.UCats, 1)) -- move ucat to end
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:CheckResources(c, addIfCheat)
	self:CheckValidSpawner()
	if self.ResCheat then
		if addIfCheat then
			for r,a in pairs(c) do
				Logic.AddToPlayersGlobalResource(self.Army.Player, r, a)
			end
		end
		return true
	else
		for r,a in pairs(c) do
			local am = Logic.GetPlayersGlobalResource(self.Army.Player, r) + Logic.GetPlayersGlobalResource(self.Army.Player, Logic.GetRawResourceType(r))
			if am < a then
				return false
			end
		end
		return true
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:GetNumberTrainingAtBuilding(id)
	if not UnlimitedArmyRecruiter.NumCache[id] then
		UnlimitedArmyRecruiter.NumCache[id] = 0
	end
	return UnlimitedArmyRecruiter.NumCache[id]
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:Remove(detachedFunc, detachedObj)
	self:CheckValidSpawner()
	if table.getn(self.InRecruitment) + self:GetCannonBuyNum() > 0 then
		if not self.DetachedFunc then
			StartSimpleJob(":TickDetached", self)
		end
		self.DetachedFunc = detachedFunc or self.DetachedFunc or function(_,id) DestroyEntity(id) end
		self.DetachedObject = detachedObj or self.DetachedObject
		return
	end
	if self.Army then
		self.Army.Spawner = nil
		self.Army = nil
	end
	EndJob(self.AddTrigger)
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:AddBuilding(id)
	self:CheckValidSpawner()
	table.insert(self.Buildings, id)
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:RemoveBuilding(id)
	self:CheckValidSpawner()
	for i=table.getn(self.Buildings),1,-1 do
		if self.Buildings[i]==id then
			table.remove(self.Buildings, i)
		end
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:AddUCat(ucat, spawnnum, looped)
	self:CheckValidSpawner()
	local t = {
		UCat = assert(ucat),
		SpawnNum = assert(spawnnum),
		Looped = looped,
	}
	self:ResetUCatNum(t)
	table.insert(self.UCats, t)
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:RemoveUCat(ucat)
	self:CheckValidSpawner()
	for i=table.getn(self.UCats),1,-1 do
		if self.UCats[i].UCat==ucat then
			table.remove(self.UCats, i)
		end
	end
end

UnlimitedArmyRecruiter:AStatic()
UnlimitedArmyRecruiter.SpawnOffset = {
	[Entities.PB_Barracks1] = {X=-800,Y=-300},
	[Entities.PB_Barracks2] = {X=-800,Y=-300},
	[Entities.PB_Archery1] = {X=-670,Y=600},
	[Entities.PB_Archery2] = {X=-670,Y=600},
	[Entities.PB_Stable1] = {X=-350,Y=400},
	[Entities.PB_Stable2] = {X=-350,Y=400},
}

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:CheckAddRecruitment()
	self:CheckValidSpawner()
	local id = Event.GetEntityID()
	if Logic.GetEntityType(id)~=self.TriggerType then
		return
	end
	local ep = GetPosition(id)
	local tp = GetPosition(self.TriggerBuild)
	local off = UnlimitedArmyRecruiter.SpawnOffset[Logic.GetEntityType(self.TriggerBuild)]
	if GetDistance(ep, {X=tp.X+off.X, Y=tp.Y+off.Y}) <= 200 then
		table.insert(self.InRecruitment, {Id=id, Building=self.TriggerBuild})
		if self.ResCheat then
			local c = {}
			Logic.FillSoldierCostsTable(self.Army.Player, Logic.LeaderGetSoldierUpgradeCategory(id), c)
			local snum = Logic.LeaderGetMaxNumberOfSoldiers(id)
			for r,a in pairs(c) do
				Logic.AddToPlayersGlobalResource(self.Army.Player, r, a*snum)
			end
		end
		self.TriggerBuild = nil
		self.TriggerType = nil
		return
	end
end

UnlimitedArmyRecruiter:AMethod()
function UnlimitedArmyRecruiter:ResetUCatNum(ldesc)
	self:CheckValidSpawner()
	if type(ldesc.SpawnNum)=="number" then
		ldesc.CurrNum = ldesc.SpawnNum
	else
		ldesc.CurrNum = ldesc.SpawnNum(self, ldesc)
	end
end

UnlimitedArmyRecruiter:FinalizeClass()
