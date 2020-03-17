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
-- 		})
-- 	
-- - Spawner:Remove()									entfernt den spawner.
-- - Spawner:IsDead()									gibt zurück, ob der spawngenerator tot (und der spawner somit nutzlos) ist.
-- 
-- Benötigt:
-- - CopyTable
-- - UnlimitdArmy
UnlimitedArmySpawnGenerator = {Generator=nil, Pos=nil, FreeArea=nil, ArmySize=nil, Army=nil, LeaderDesc=nil, SpawnCounter=nil, SpawnLeaders=nil, CCounter=nil}

function UnlimitedArmySpawnGenerator.New(army, spawndata)
	local self = CopyTable(UnlimitedArmySpawnGenerator)
	self.Pos = assert(spawndata.Position)
	self.ArmySize = assert(spawndata.ArmySize)
	self.SpawnCounter = assert(spawndata.SpawnCounter)
	self.CCounter = 0
	self.SpawnLeaders = assert(spawndata.SpawnLeaders)
	self.Generator = spawndata.Generator
	self.FreeArea = spawndata.FreeArea
	self.LeaderDesc = {}
	for _,d in ipairs(spawndata.LeaderDesc) do
		table.insert(self.LeaderDesc, d)
		d.CurrNum = d.SpawnNum
	end
	army.Spawner = self
	self.Army = army
	return self
end

function UnlimitedArmySpawnGenerator:CheckValidSpawner()
	assert(self ~= UnlimitedArmySpawnGenerator)
	assert(self.Army)
end

function UnlimitedArmySpawnGenerator:Tick()
	self:CheckValidSpawner()
	if self:IsDead() then
		self:Remove()
		return
	end
	self.CCounter = self.CCounter - 1
	if self.CCounter <= 0 and self.Army:GetSize()<self.ArmySize and self:IsSpawnPossible() then
		self.CCounter = self.SpawnCounter
		self:ForceSpawn(math.min(self.SpawnLeaders, self.ArmySize-self.Army:GetSize()))
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

function UnlimitedArmySpawnGenerator:SpawnOneLeader()
	self:CheckValidSpawner()
	self.Army:CreateLeaderForArmy(self.LeaderDesc[1].LeaderType, self.LeaderDesc[1].SoldierNum, self.Pos, self.LeaderDesc[1].Experience)
	self.LeaderDesc[1].CurrNum = self.LeaderDesc[1].CurrNum - 1
	if self.LeaderDesc[1].CurrNum <= 0 then
		local d = table.remove(self.LeaderDesc, 1)
		if d.Looped then
			d.CurrNum = d.SpawnNum
			table.insert(self.LeaderDesc, d)
		end
	end
	if not self.LeaderDesc then
		self:Remove()
		return true
	end
end

function UnlimitedArmySpawnGenerator:Remove()
	self.Army.Spawner = nil
	self.Army = nil
end
