if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("s5CommunityLib/lib/UnlimitedArmy")
mcbPacker.require("s5CommunityLib/comfort/number/GetRandom")
mcbPacker.require("s5CommunityLib/comfort/pos/IsValidPosition")
mcbPacker.require("s5CommunityLib/comfort/other/UpdatelessTimer")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- spawngenerator für UnlimitedArmy.
-- 
-- Spawner = UnlimitedArmySpawnGenerator:New(army, {
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
-- 			DoNotRemoveIfDeadOrEmpty,
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
-- - IsValidPosition
-- - GetRandom
--- @class UnlimitedArmySpawnGenerator : UnlimitedArmyFiller
--- @field Generator number|string?
--- @field Pos Position|UnlimitedArmySpawnGeneratorSpawnPos[]
--- @field FreeArea number?
--- @field ArmySize number
--- @field Army UnlimitedArmy
--- @field private LeaderDesc UnlimitedArmySpawnGeneratorLT[]
--- @field SpawnCounter number
--- @field SpawnLeaders number
--- @field private CCounter UpdatelessTimer
--- @field RefillSoldiers boolean?
--- @field RandomizeSpawn boolean?
--- @field RandomizeSpawnPoint boolean?
--- @field DoNotRemoveIfDeadOrEmpty boolean?
UnlimitedArmySpawnGenerator = {}

if false then
	---@class UnlimitedArmySpawnGeneratorData
	---@field Position Position|UnlimitedArmySpawnGeneratorSpawnPos[]
	---@field ArmySize number
	---@field SpawnCounter number
	---@field SpawnLeaders number
	---@field Generator number|string|nil
	---@field FreeArea number?
	---@field RefillSoldiers boolean?
	---@field RandomizeSpawn boolean?
	---@field RandomizeSpawnPoint boolean?
	---@field DoNotRemoveIfDeadOrEmpty boolean?
	---@field LeaderDesc UnlimitedArmySpawnGeneratorLT[]
	local UnlimitedArmySpawnGeneratorData = {}

	---@class UnlimitedArmySpawnGeneratorSpawnPos : Position
	---@field Generator number|string|nil
	local UnlimitedArmySpawnGeneratorSpawnPos = {}
end

UnlimitedArmySpawnGenerator = UnlimitedArmyFiller:CreateSubClass("UnlimitedArmySpawnGenerator")

UnlimitedArmySpawnGenerator:AReference()
---@param army UnlimitedArmy
---@param spawndata UnlimitedArmySpawnGeneratorData
---@return UnlimitedArmySpawnGenerator
---@diagnostic disable-next-line: missing-return
function UnlimitedArmySpawnGenerator:New(army, spawndata)end

UnlimitedArmySpawnGenerator:AMethod()
---@private
---@param army UnlimitedArmy
---@param spawndata UnlimitedArmySpawnGeneratorData
function UnlimitedArmySpawnGenerator:Init(army, spawndata)
	self:CallBaseMethod("Init", UnlimitedArmySpawnGenerator)
	self.Pos = assert(spawndata.Position)
	self.ArmySize = assert(spawndata.ArmySize)
	self.SpawnCounter = assert(spawndata.SpawnCounter)
	self.CCounter = UpdatelessTimer:New(UpdatelessTimer.Type.Seconds)
	self.SpawnLeaders = assert(spawndata.SpawnLeaders)
	self.Generator = spawndata.Generator
	self.FreeArea = spawndata.FreeArea
	self.RefillSoldiers = spawndata.RefillSoldiers
	self.RandomizeSpawn = spawndata.RandomizeSpawn
	self.RandomizeSpawnPoint = spawndata.RandomizeSpawnPoint
	self.DoNotRemoveIfDeadOrEmpty = spawndata.DoNotRemoveIfDeadOrEmpty
	self.LeaderDesc = {}
	army.Spawner = self
	self.Army = army
	for _,d in ipairs(spawndata.LeaderDesc) do
		self:AddLeaderType(d.LeaderType, d.SoldierNum, d.SpawnNum, d.Experience, d.Looped)
	end
	assert(IsValidPosition(self:GetSpawnPos()))
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:CheckValidSpawner()
	assert(self ~= UnlimitedArmySpawnGenerator)
	assert(self.Army)
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:Tick(active)
	self:CheckValidSpawner()
	if self:IsDead() then
		if not self.DoNotRemoveIfDeadOrEmpty then
			self:Remove()
		end
		return
	end
	if active and self.CCounter:Check() and self:IsSpawnPossible() then
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

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:ResetCounter()
	self:CheckValidSpawner()
	if type(self.SpawnCounter)=="number" then
		self.CCounter:Set(self.SpawnCounter, true)
	else
		self.CCounter:Set(self:SpawnCounter(), true)
	end
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:GetNeededSpawnAmount()
	self:CheckValidSpawner()
	local l = self.ArmySize-self.Army:GetSize(true, true)
	local s = 0
	if self.RefillSoldiers then
		for id in self.Army:Iterator(true) do
			if UnlimitedArmySpawnGenerator.IsValidForRefill(id) then
				s = s + 1
			end
		end
	end
	return l, s
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:RefillSoldiersOfLeaders(num)
	self:CheckValidSpawner()
	for id in self.Army:Iterator(true) do
		if UnlimitedArmySpawnGenerator.IsValidForRefill(id) then
			UnlimitedArmySpawnGenerator.SpawnSoldiersSafe(id, Logic.LeaderGetMaxNumberOfSoldiers(id)-Logic.LeaderGetNumberOfSoldiers(id))
			num = num - 1
			if num <= 0 then
				break
			end
		end
	end
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:IsSpawnPossible()
	self:CheckValidSpawner()
	if self:IsDead() then
		return false
	end
	if self.FreeArea then
		local id = UnlimitedArmy.GetTargetEnemiesInArea(self.Pos, self.Army.Player, self.FreeArea)
		return IsDead(id)
	end
	return true
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:IsDead()
	assert(self ~= UnlimitedArmySpawnGenerator)
	if not self.Army then
		return true
	end
	if self.Pos[1] then
		for i=table.getn(self.Pos),1,-1 do
			---@type UnlimitedArmySpawnGeneratorSpawnPos
			local p = self.Pos[i]
			if p.Generator and UnlimitedArmy.IsReferenceDead(p.Generator) then
				table.remove(self.Pos, i)
			end
		end
	end
	---@diagnostic disable-next-line: undefined-field
	if not self.Pos[1] and not self.Pos.X then
		return true
	end
	if not self.Generator then
		return false
	end
	return IsDead(self.Generator)
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:ForceSpawn(num)
	self:CheckValidSpawner()
	for i=1, num do
		if self:SpawnOneLeader() then
			return
		end
	end
end

UnlimitedArmySpawnGenerator:AMethod()
---@return Position?
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

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:SpawnOneLeader()
	self:CheckValidSpawner()
	local spawningLeader = 1
	if self.RandomizeSpawn then
		spawningLeader = GetRandom(1, table.getn(self.LeaderDesc))
	end
	if self.LeaderDesc[spawningLeader] then
		local p = self:GetSpawnPos()
		if not p then
			if self.DoNotRemoveIfDeadOrEmpty then
				self:Remove()
			end
			return true
		end
		self.Army:CreateLeaderForArmy(self.LeaderDesc[spawningLeader].LeaderType, self.LeaderDesc[spawningLeader].SoldierNum, p, self.LeaderDesc[spawningLeader].Experience)
		self.LeaderDesc[spawningLeader].CurrNum = self.LeaderDesc[spawningLeader].CurrNum - 1
		if self.LeaderDesc[spawningLeader].CurrNum <= 0 then
			local d = table.remove(self.LeaderDesc, spawningLeader)
			if d.Looped then
				self:ResetLeaderNum(d)
				table.insert(self.LeaderDesc, d)
			end
		end
	end
	if not self.LeaderDesc[1] then
		if self.DoNotRemoveIfDeadOrEmpty then
			self:Remove()
		end
		return true
	end
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:Remove()
	self.Army.Spawner = nil
	self.Army = nil
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:AddLeaderType(ety, solnum, spawnnum, exp, looped)
	self:CheckValidSpawner()
	--- @class UnlimitedArmySpawnGeneratorLT
	local t = {
		LeaderType = assert(ety),
		SoldierNum = assert(solnum),
		SpawnNum = assert(spawnnum),
		Experience = exp,
		Looped = looped,
		CurrNum = nil
	}
	self:ResetLeaderNum(t)
	table.insert(self.LeaderDesc, t)
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:RemoveLeaderType(ety)
	self:CheckValidSpawner()
	for i=table.getn(self.LeaderDesc),1,-1 do
		if self.LeaderDesc[i].LeaderType==ety then
			table.remove(self.LeaderDesc, i)
		end
	end
end

UnlimitedArmySpawnGenerator:AMethod()
function UnlimitedArmySpawnGenerator:ResetLeaderNum(ldesc)
	self:CheckValidSpawner()
	if type(ldesc.SpawnNum)=="number" then
		ldesc.CurrNum = ldesc.SpawnNum
	else
		ldesc.CurrNum = ldesc.SpawnNum(self, ldesc)
	end
end

UnlimitedArmySpawnGenerator:AStatic()
function UnlimitedArmySpawnGenerator.IsValidForRefill(id)
	if Logic.IsLeader(id) == 0 then
		return false
	end
	if Logic.LeaderGetMaxNumberOfSoldiers(id) == 0 then
		return false
	end
	if Logic.LeaderGetNumberOfSoldiers(id)>=Logic.LeaderGetMaxNumberOfSoldiers(id) then
		return false
	end
	if Logic.LeaderGetBarrack(id) ~= 0 then
		return false
	end
	return true
end

UnlimitedArmySpawnGenerator:AStatic()
function UnlimitedArmySpawnGenerator.SpawnSoldiersSafe(id, num)
	if not UnlimitedArmySpawnGenerator.IsValidForRefill(id) then
		return
	end
	local sty = Logic.LeaderGetSoldiersType(id)
	if not CppLogic then
		Logic.GroupDefend(id) -- clear attack status
	end
	local x,y = Logic.GetEntityPosition(id)
	local p = Logic.EntityGetPlayer(id)
	for i=1,num do
		local sol = Logic.CreateEntity(sty, x, y, 0, p)
		if IsDead(sol) then
			return
		end
		if CppLogic then
			CppLogic.Entity.Leader.AttachSoldier(id, sol)
		else
			Logic.LeaderGetOneSoldier(id)
		end
		local s = {Logic.GetSoldiersAttachedToLeader(id)}
		local found = false
		for j=2,s[1]+1 do
			if s[j] == sol then
				found = true
				break
			end
		end
		if not found then
			LuaDebugger.Log("failed to attach soldier")
			Logic.DestroyEntity(sol)
			return
		end
	end
end

UnlimitedArmySpawnGenerator:FinalizeClass()
