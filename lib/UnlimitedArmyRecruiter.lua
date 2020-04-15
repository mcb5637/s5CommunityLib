if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/lib/UnlimitedArmy")
mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
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
-- 		})
-- 	
-- - Recruiter:Remove()									entfernt den spawner.
-- - Recruiter:IsDead()									gibt zurück, ob der spawngenerator tot (und der spawner somit nutzlos) ist.
-- 
-- Benötigt:
-- - CopyTable
-- - UnlimitdArmy
-- - GetDistance
UnlimitedArmyRecruiter = {Army=nil, Buildings=nil, ArmySize=nil, UCats=nil, ResCheat=nil, InRecruitment=nil, AddTrigger=nil,
	TriggerType=nil, TriggerBuild=nil, NumCache={}, Cannons=nil, ReorderAllowed=nil,
}

function UnlimitedArmyRecruiter.New(army, data)
	local self = CopyTable(UnlimitedArmyRecruiter, {[UnlimitedArmyRecruiter.NumCache] = UnlimitedArmyRecruiter.NumCache})
	self.Buildings = data.Buildings
	assert(self.Buildings[1] and IsAlive(self.Buildings[1]))
	self.ArmySize = assert(data.ArmySize)
	self.UCats = {}
	for _,d in ipairs(data.UCats) do
		d.CurrNum = d.SpawnNum
		table.insert(self.UCats, d)
	end
	self.ResCheat = data.ResCheat
	self.InRecruitment = {}
	self.Cannons = {}
	self.ReorderAllowed = data.ReorderAllowed
	self.AddTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, self.CheckAddRecruitment, 1, nil, {self})
	self.Army = army
	army.Spawner = self
	return self
end

function UnlimitedArmyRecruiter:IsDead()
	self:CheckValidSpawner()
	for _,id in ipairs(self.Buildings) do
		if IsAlive(id) then
			return false
		end
	end
	return self.UCats[1] and true or false
end

function UnlimitedArmyRecruiter:CheckValidSpawner()
	assert(self ~= UnlimitedArmyRecruiter)
	assert(self.Army)
end

function UnlimitedArmyRecruiter:Tick()
	self:CheckValidSpawner()
	for i=table.getn(self.Buildings),1,-1 do
		if IsDead(self.Buildings[i]) then
			table.remove(self.Buildings, i)
		elseif self.Cannons[self.Buildings[i]] then
			local c = Logic.GetLeaderTrainingAtBuilding(self.Buildings[i])
			if self.Cannons[self.Buildings[i]] == -1 and IsValid(c) then
				self.Cannons[self.Buildings[i]] = c
			elseif self.Cannons[self.Buildings[i]]~=-1 and c==0 then
				self.Army:AddLeader(self.Cannons[self.Buildings[i]])
				self.Cannons[self.Buildings[i]] = nil
				self.NumCache[self.Buildings[i]] = self.NumCache[self.Buildings[i]] - 1
			end
		end
	end
	for i=table.getn(self.InRecruitment),1,-1 do
		if Logic.LeaderGetBarrack(self.InRecruitment[i].Id)==0 then
			local d = table.remove(self.InRecruitment, i)
			self.Army:AddLeader(d.Id)
			self.NumCache[d.Building] = self.NumCache[d.Building] - 1
		end
	end
	if self:IsDead() then
		if table.getn(self.InRecruitment)<=0 then
			self:Remove()
		end
		return
	end
	if (self.Army:GetSize(true) + table.getn(self.InRecruitment))<self.ArmySize then
		self:ForceSpawn(self.ArmySize - (self.Army:GetSize(true) + table.getn(self.InRecruitment)))
	end
end

function UnlimitedArmyRecruiter:ForceSpawn(num)
	self:CheckValidSpawner()
	for i=1, num do
		if self:SpawnOneLeader() then
			return
		end
	end
end

function UnlimitedArmyRecruiter:IsSpawnPossible()
	self:CheckValidSpawner()
	return not self:IsDead()
end

UnlimitedArmyRecruiter.UCatBuyTypes = {
	[UpgradeCategories.LeaderSword] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderPoleArm] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderBandit] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderBarbarian] = UpgradeCategories.Barracks,
	[UpgradeCategories.BlackKnightLeaderMace1] = UpgradeCategories.Barracks,
	[UpgradeCategories.Evil_LeaderBearman] = UpgradeCategories.Barracks,
	[UpgradeCategories.LeaderBow] = UpgradeCategories.Archery,
	[UpgradeCategories.LeaderRifle] = UpgradeCategories.Archery,
	[UpgradeCategories.LeaderBanditBow] = UpgradeCategories.Archery,
	[UpgradeCategories.Evil_LeaderSkirmisher] = UpgradeCategories.Archery,
	[UpgradeCategories.LeaderCavalry] = UpgradeCategories.Stable,
	[UpgradeCategories.LeaderHeavyCavalry] = UpgradeCategories.Stable,
	[UpgradeCategories.Thief] = UpgradeCategories.Tavern,
	[UpgradeCategories.Scout] = UpgradeCategories.Tavern,
}

UnlimitedArmyRecruiter.CannonBuyTypes = {
	[UpgradeCategories.Cannon1] = UpgradeCategories.Foundry,
	[UpgradeCategories.Cannon2] = UpgradeCategories.Foundry,
	[UpgradeCategories.Cannon3] = UpgradeCategories.Foundry,
	[UpgradeCategories.Cannon4] = UpgradeCategories.Foundry,
}

function UnlimitedArmyRecruiter:SpawnOneLeader()
	self:CheckValidSpawner()
	if Logic.GetPlayerAttractionUsage(self.Army.Player) >= Logic.GetPlayerAttractionLimit(self.Army.Player) then
		return
	end
	if Logic.GetAverageMotivation(self.Army.Player) < Logic.GetLogicPropertiesMotivationThresholdVCLock() then
		return
	end
	local buyT = UnlimitedArmyRecruiter.UCatBuyTypes[self.UCats[1].UCat]
	local cbuyT = UnlimitedArmyRecruiter.CannonBuyTypes[self.UCats[1].UCat]
	local buyingAt = 0
	if buyT then
		for _,id in ipairs(self.Buildings) do
			if Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(id))==buyT and self:GetNumberTrainingAtBuilding(id)<3 then
				buyingAt = id
				break
			end
		end
	elseif cbuyT then
		for _,id in ipairs(self.Buildings) do
			if Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(id))==cbuyT and self:GetNumberTrainingAtBuilding(id)<1 then
				local num, wid = Logic.GetAttachedWorkersToBuilding(id)
				if num>=1 and Logic.GetCurrentTaskList(wid)=="TL_SMELTER_WORK1_WAIT"
				and not InterfaceTool_IsBuildingDoingSomething(id)
				and Logic.GetCannonProgress(id)==100 then
					buyingAt = id
					break
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
			self.NumCache[buyingAt] = self.NumCache[buyingAt] + 1
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
				d.CurrNum = d.SpawnNum
				table.insert(self.UCats, d)
			end
		end
	elseif self.ReorderAllowed then
		table.insert(self.UCats, table.remove(self.UCats, 1)) -- move ucat to end
	end
end

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

function UnlimitedArmyRecruiter:GetNumberTrainingAtBuilding(id)
	if not self.NumCache[id] then
		self.NumCache[id] = 0
	end
	return self.NumCache[id]
end

function UnlimitedArmyRecruiter:Remove()
	self.Army.Spawner = nil
	self.Army = nil
	EndJob(self.AddTrigger)
end

function UnlimitedArmyRecruiter:AddBuilding(id)
	self:CheckValidSpawner()
	table.insert(self.Buildings, id)
end

UnlimitedArmyRecruiter.SpawnOffset = {
	[Entities.PB_Barracks1] = {X=-800,Y=-300},
	[Entities.PB_Barracks2] = {X=-800,Y=-300},
	[Entities.PB_Archery1] = {X=-670,Y=600},
	[Entities.PB_Archery2] = {X=-670,Y=600},
	[Entities.PB_Stable1] = {X=-350,Y=400},
	[Entities.PB_Stable2] = {X=-350,Y=400},
}

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
