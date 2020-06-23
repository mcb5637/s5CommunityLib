if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/lib/UnlimitedArmy")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- spawngenerator für UnlimitedArmy.
-- 
-- Spawner = UnlimitedArmySpawnGenerator.New(army, {
-- 			-- benötigt:
-- 			Position,
-- 			ArmySize,
-- 			SpawnCounter,
-- 			SpawnLeaders,
-- 			LeaderDesc = {
-- 				{LeaderType, SoldierNum, SpawnNum, Looped, Experience},
-- 				--...
-- 			},
-- 			-- optional:
-- 			Generator,
-- 			FreeArea,
-- 			RefillSoldiers,
-- 			RandomizeSpawn,
-- 			RandomizeSpawnPoint,
-- 		})
-- 	
-- - Spawner:Remove()									entfernt den spawner.
-- - Spawner:IsDead()									gibt zurück, ob der spawngenerator tot (und der spawner somit nutzlos) ist.
-- - Spawner:AddLeaderType(ety, solnum, spawnnum, exp, looped)
-- 														fügt eine leaderdesc hinzu.
-- - Spawner:RemoveLeaderType(ety)						entfernt alle leaderdescs die den entitytyp haben.
-- 
-- Benötigt:
-- - CopyTable
-- - UnlimitdArmy
UnlimitedArmySpawnGenerator = {Generator=nil, Pos=nil, FreeArea=nil, ArmySize=nil, Army=nil, LeaderDesc=nil, SpawnCounter=nil, SpawnLeaders=nil, CCounter=nil,
	RefillSoldiers=nil, RandomizeSpawn=nil, RandomizeSpawnPoint=nil,
}

function UnlimitedArmySpawnGenerator.New(army, spawndata)
	local self = CopyTable(UnlimitedArmySpawnGenerator)
	self.Pos = assert(spawndata.Position)
	self.ArmySize = assert(spawndata.ArmySize)
	self.SpawnCounter = assert(spawndata.SpawnCounter)
	self.CCounter = 0
	self.SpawnLeaders = assert(spawndata.SpawnLeaders)
	self.Generator = spawndata.Generator
	self.FreeArea = spawndata.FreeArea
	self.RefillSoldiers = spawndata.RefillSoldiers
	self.RandomizeSpawn = spawndata.RandomizeSpawn
	self.RandomizeSpawnPoint = spawndata.RandomizeSpawnPoint
	self.LeaderDesc = {}
	army.Spawner = self
	self.Army = army
	for _,d in ipairs(spawndata.LeaderDesc) do
		self:AddLeaderType(d.LeaderType, d.SoldierNum, d.SpawnNum, d.Experience, d.Looped)
	end
	return self
end

function UnlimitedArmySpawnGenerator:CheckValidSpawner()
	assert(self ~= UnlimitedArmySpawnGenerator)
	assert(self.Army)
end

function UnlimitedArmySpawnGenerator:Tick(active)
	self:CheckValidSpawner()
	if self:IsDead() then
		self:Remove()
		return
	end
	self.CCounter = self.CCounter - 1
	if active and self.CCounter <= 0 and self:IsSpawnPossible() then
		local l, s = self:GetNeededSpawnAmount()
		if l>0 or s>0 then
			self:ResetCounter()
			if l > 0 then
				self:ForceSpawn(math.min(self.SpawnLeaders, l))
			end
			if s>0 and self.SpawnLeaders>l then
				self:RefillSoldiersOfLeaders(self.SpawnLeaders-l)
			end
		end
	end
end

function UnlimitedArmySpawnGenerator:ResetCounter()
	self:CheckValidSpawner()
	if type(self.SpawnCounter)=="number" then
		self.CCounter = self.SpawnCounter
	else
		self.CCounter = self:SpawnCounter()
	end
end

function UnlimitedArmySpawnGenerator:GetNeededSpawnAmount()
	self:CheckValidSpawner()
	local l = self.ArmySize-self.Army:GetSize(true, true)
	local s = 0
	if self.RefillSoldiers then
		for id in self.Army:Iterator(true) do
			if Logic.IsLeader(id)==1 and Logic.LeaderGetMaxNumberOfSoldiers(id)>0
			and Logic.LeaderGetNumberOfSoldiers(id)<Logic.LeaderGetMaxNumberOfSoldiers(id) then
				s = s + 1
			end
		end
	end
	return l, s
end

function UnlimitedArmySpawnGenerator:RefillSoldiersOfLeaders(num)
	self:CheckValidSpawner()
	for id in self.Army:Iterator(true) do
		if Logic.IsLeader(id)==1 and Logic.LeaderGetMaxNumberOfSoldiers(id)>0
			and Logic.LeaderGetNumberOfSoldiers(id)<Logic.LeaderGetMaxNumberOfSoldiers(id) then
			Tools.CreateSoldiersForLeader(id, Logic.LeaderGetMaxNumberOfSoldiers(id)-Logic.LeaderGetNumberOfSoldiers(id))
			num = num - 1
			if num <= 0 then
				break
			end
		end
	end
end

function UnlimitedArmySpawnGenerator:IsSpawnPossible()
	self:CheckValidSpawner()
	if self:IsDead() then
		return false
	end
	if self.FreeArea then
		local id = UnlimitedArmy.GetFirstEnemyInArea(self.Pos, self.Army.Player, self.FreeArea)
		return IsDead(id)
	end
	return true
end

function UnlimitedArmySpawnGenerator:IsDead()
	self:CheckValidSpawner()
	if self.Pos[1] then
		for i=table.getn(self.Pos),1,-1 do
			if self.Pos[i].Generator and UnlimitedArmy.IsReferenceDead(self.Pos[i].Generator) then
				table.remove(self.Pos, i)
			end
		end
	end
	if not self.Pos[1] and not self.Pos.X then
		return true
	end
	if not self.Generator then
		return false
	end
	return IsDead(self.Generator)
end

function UnlimitedArmySpawnGenerator:ForceSpawn(num)
	self:CheckValidSpawner()
	for i=1, num do
		if self:SpawnOneLeader() then
			return
		end
	end
end

function UnlimitedArmySpawnGenerator:GetSpawnPos()
	if self:IsDead() then
		return nil
	end
	if self.Pos[1] then
		if self.RandomizeSpawnPoint then
			return self.Pos[GetRandom(1, table.getn(self.Pos))]
		end
		return self.Pos[1]
	end
	return self.Pos
end

function UnlimitedArmySpawnGenerator:SpawnOneLeader()
	self:CheckValidSpawner()
	local spawningLeader = 1
	if self.RandomizeSpawn then
		spawningLeader = GetRandom(1, table.getn(self.LeaderDesc))
	end
	local p = self:GetSpawnPos()
	self.Army:CreateLeaderForArmy(self.LeaderDesc[spawningLeader].LeaderType, self.LeaderDesc[spawningLeader].SoldierNum, p, self.LeaderDesc[spawningLeader].Experience)
	self.LeaderDesc[spawningLeader].CurrNum = self.LeaderDesc[spawningLeader].CurrNum - 1
	if self.LeaderDesc[spawningLeader].CurrNum <= 0 then
		local d = table.remove(self.LeaderDesc, spawningLeader)
		if d.Looped then
			d.CurrNum = d.SpawnNum
			table.insert(self.LeaderDesc, d)
		end
	end
	if not self.LeaderDesc[1] then
		self:Remove()
		return true
	end
end

function UnlimitedArmySpawnGenerator:Remove()
	self.Army.Spawner = nil
	self.Army = nil
end

function UnlimitedArmySpawnGenerator:AddLeaderType(ety, solnum, spawnnum, exp, looped)
	self:CheckValidSpawner()
	table.insert(self.LeaderDesc, {
		LeaderType = assert(ety),
		SoldierNum = assert(solnum),
		SpawnNum = assert(spawnnum),
		CurrNum = spawnnum,
		Experience = exp,
		Looped = looped,
	})
end

function UnlimitedArmySpawnGenerator:RemoveLeaderType(ety)
	self:CheckValidSpawner()
	for i=table.getn(self.LeaderDesc),1,-1 do
		if self.LeaderDesc[i].LeaderType==ety then
			table.remove(self.LeaderDesc, i)
		end
	end
end
