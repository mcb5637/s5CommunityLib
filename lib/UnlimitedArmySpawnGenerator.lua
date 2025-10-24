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
--- @field Generator number|string|nil der spawner ist inaktiv, wenn ~= nil und dieses entity tot ist
--- @field Pos Position|UnlimitedArmySpawnGeneratorSpawnPos[] eine oder mehrere spawn positionen
--- @field FreeArea number? wenn feindliche einheiten näher als diese distanz an der spawn pos sind, pausiert spawnen (aber nicht den counter bis zum nächsten spawn)
--- @field ArmySize number zielgröße (anzahl leader) der army
--- @field Army UnlimitedArmy army die der spawner versorgt
--- @field private LeaderDesc UnlimitedArmySpawnGeneratorLT[]
--- @field SpawnCounter number|fun(self:UnlimitedArmySpawnGenerator):number zeit zwischen den spawns (sekunden, unabhängig von tickrate der ua)
--- @field SpawnLeaders number anzahl der leader die auf ein mal gespawn werden
--- @field private CCounter UpdatelessTimer
--- @field RefillSoldiers boolean? wenn true, nutzt ungenutzte SpawnLeaders um die soldiers von existierenden leadern aufzufüllen
--- @field RandomizeSpawn boolean? wenn true, wählt zufällig aus der spawn queue, anstatt in reihenfolge
--- @field RandomizeSpawnPoint boolean? wenn true, wählt zufällig aus Pos, anstatt in reihenfolge
--- @field DoNotRemoveIfDeadOrEmpty boolean? wenn nicht gesetzt und ein Generator ist gesetzt, entfernt den spawner, sobald Generator tot ist oder LeaderDesc leer ist
UnlimitedArmySpawnGenerator = {}

if false then
	---@class UnlimitedArmySpawnGeneratorData
	---@field Position Position|UnlimitedArmySpawnGeneratorSpawnPos[] eine oder mehrere spawn positionen
	---@field ArmySize number zielgröße (anzahl leader) der army
	---@field SpawnCounter number|fun(self:UnlimitedArmySpawnGenerator):number zeit zwischen den spawns (sekunden, unabhängig von tickrate der ua)
	---@field SpawnLeaders number anzahl der leader die auf ein mal gespawn werden
	---@field Generator number|string|nil der spawner ist inaktiv, wenn ~= nil und dieses entity tot ist
	---@field FreeArea number? wenn feindliche einheiten näher als diese distanz an der spawn pos sind, pausiert spawnen (aber nicht den counter bis zum nächsten spawn)
	---@field RefillSoldiers boolean? wenn true, nutzt ungenutzte SpawnLeaders um die soldiers von existierenden leadern aufzufüllen
	---@field RandomizeSpawn boolean? wenn true, wählt zufällig aus der spawn queue anstatt in reihenfolge
	---@field RandomizeSpawnPoint boolean? wenn true, wählt zufällig aus Pos, anstatt in reihenfolge
	---@field DoNotRemoveIfDeadOrEmpty boolean? wenn nicht gesetzt und ein Generator ist gesetzt, entfernt den spawner, sobald Generator tot ist oder LeaderDesc leer ist
	---@field LeaderDesc UnlimitedArmySpawnGeneratorLT[] spawn queue, wird einer nach dem anderen abgearbeitet
	local UnlimitedArmySpawnGeneratorData = {}

	---@class UnlimitedArmySpawnGeneratorSpawnPos : Position
	---@field Generator number|string|nil diese spawn pos ist inaktiv, wenn ~= nil und dieses entity tot ist (automatisch entfernt, wenn inaktiv)
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
---@param self UnlimitedArmySpawnGenerator
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
---@param self UnlimitedArmySpawnGenerator
function UnlimitedArmySpawnGenerator:CheckValidSpawner()
	assert(self ~= UnlimitedArmySpawnGenerator)
	assert(self.Army)
end

UnlimitedArmySpawnGenerator:AMethod()
---@param active boolean?
---@param self UnlimitedArmySpawnGenerator
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
---@param self UnlimitedArmySpawnGenerator
function UnlimitedArmySpawnGenerator:ResetCounter()
	self:CheckValidSpawner()
	if type(self.SpawnCounter) == "number" then
		---@diagnostic disable-next-line: param-type-mismatch
		self.CCounter:Set(self.SpawnCounter, true)
	else
		self.CCounter:Set(self:SpawnCounter(), true)
	end
end

UnlimitedArmySpawnGenerator:AMethod()
---@param self UnlimitedArmySpawnGenerator
---@return number l number of needed leaders
---@return number s number of leaders without full soldiers
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
---@param self UnlimitedArmySpawnGenerator
---@param num number refill this may leaders of the ua
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
---@param self UnlimitedArmySpawnGenerator
---@return boolean
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
---@param self UnlimitedArmySpawnGenerator
---@return boolean
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
	if not self.Pos[1] and not self.Pos.X then
		return true
	end
	if not self.Generator then
		return false
	end
	return IsDead(self.Generator)
end

UnlimitedArmySpawnGenerator:AMethod()
---@param self UnlimitedArmySpawnGenerator
---@param num number of leaders to spawn
function UnlimitedArmySpawnGenerator:ForceSpawn(num)
	self:CheckValidSpawner()
	for i=1, num do
		if self:SpawnOneLeader() then
			return
		end
	end
end

UnlimitedArmySpawnGenerator:AMethod()
---@param self UnlimitedArmySpawnGenerator
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
---@param self UnlimitedArmySpawnGenerator
---@return boolean? error
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
---entfernt den spawner von der UA
---@param self UnlimitedArmySpawnGenerator
function UnlimitedArmySpawnGenerator:Remove()
	self.Army.Spawner = nil
	self.Army = nil
end

UnlimitedArmySpawnGenerator:AMethod()
---fügt einen leader am ende der spawn queue ein
---@see UnlimitedArmySpawnGeneratorLT
---@param self UnlimitedArmySpawnGenerator
---@param ety number
---@param solnum number
---@param spawnnum number|fun(self:UnlimitedArmySpawnGenerator, lt:UnlimitedArmySpawnGeneratorLT):number
---@param exp number?
---@param looped boolean?
function UnlimitedArmySpawnGenerator:AddLeaderType(ety, solnum, spawnnum, exp, looped)
	self:CheckValidSpawner()
	--- @class UnlimitedArmySpawnGeneratorLT
	--- @field LeaderType number entitytyp des leaders
	--- @field SoldierNum number anzahl der soldier
	--- @field SpawnNum number|fun(self:UnlimitedArmySpawnGenerator, lt:UnlimitedArmySpawnGeneratorLT):number anzahl der leader dieses types
	--- @field Experience number? level des leaders [LOW_EXPERIENCE,VERYHIGH_EXPERIENCE]
	--- @field Looped boolean? wenn true, wird nach dem spawnen von SpawnNum leadern wieder hinten in die queue eingefügt
	--- @field package CurrNum number?
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
---entfernt alle einträge in der spawn queue, die diesen entitytyp als leader haben
---@param self UnlimitedArmySpawnGenerator
---@param ety number
function UnlimitedArmySpawnGenerator:RemoveLeaderType(ety)
	self:CheckValidSpawner()
	for i=table.getn(self.LeaderDesc),1,-1 do
		if self.LeaderDesc[i].LeaderType==ety then
			table.remove(self.LeaderDesc, i)
		end
	end
end

UnlimitedArmySpawnGenerator:AMethod()
---@private
---@param self UnlimitedArmySpawnGenerator
---@param ldesc UnlimitedArmySpawnGeneratorLT
function UnlimitedArmySpawnGenerator:ResetLeaderNum(ldesc)
	self:CheckValidSpawner()
	if type(ldesc.SpawnNum)=="number" then
		---@diagnostic disable-next-line: assign-type-mismatch
		ldesc.CurrNum = ldesc.SpawnNum
	else
		ldesc.CurrNum = ldesc.SpawnNum(self, ldesc)
	end
end

UnlimitedArmySpawnGenerator:AStatic()
---prüft, ob ein leader einen solier respawn benötigt
---@param id number
---@return boolean
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
---spawnt soldiers für einen leader
---@param id number
---@param num number
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
