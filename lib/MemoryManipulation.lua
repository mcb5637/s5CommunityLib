if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/IstDrin")
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/comfort/entity/IsEntityOfType")
mcbPacker.require("s5CommunityLib/comfort/number/round")
mcbPacker.require("s5CommunityLib/tables/ArmorClasses")
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
end --mcbPacker.ignore

--MemoryManipulation.ReadObj(S5Hook.GetEntityMem(132339))
--MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CLimitedAttachmentBehavior.MaxAttachment", true)
--MemoryManipulation.SetSingleValue(65575, "BehaviorList.GGL_CLimitedAttachmentBehavior.Attachment1.Limit", 6)
--MemoryManipulation.ReadObj(MemoryManipulation.GetETypePointer(Entities.PU_Hero1a))


MemoryManipulation = {}

MemoryManipulation.MemList = {}
function MemoryManipulation.MemList.init(sv, length)
	local s = CopyTable(MemoryManipulation.MemList)
	s.sv = sv
	s.len = length/4
	local ep, bp = sv[1]:GetInt(), sv[0]:GetInt()
	S5Hook.SetPreciseFPU()
	s.num = (ep-bp)/length
	return s
end
function MemoryManipulation.MemList.initFromPointerAndSize(sv, length)
	local s = CopyTable(MemoryManipulation.MemList)
	s.sv = sv
	s.len = length/4
	s.num = sv[1]:GetInt()
	return s
end
function MemoryManipulation.MemList:get(i)
	assert(i>=0 and i<self.num)
	return self.sv[0]:Offset(i*self.len)
end
function MemoryManipulation.MemList:iterator()
	local i, count = -1, self.num
    return function()
        i = i + 1
        if i < count then
            return self:get(i)
        end
    end
end

function MemoryManipulation.ReadObj(sv, objInfo, fieldInfo, readFilter)
	objInfo = objInfo or {}
	if not fieldInfo then
		fieldInfo = MemoryManipulation.ObjFieldInfo[sv[0]:GetInt()]
	end
	if not fieldInfo then
		return "todo"
	end
	assert(fieldInfo.hasNoVTable or fieldInfo.vtable==sv[0]:GetInt())
	for _,fi in ipairs(fieldInfo.fields) do
		if not readFilter or readFilter[fi.name]~=nil then
			S5Hook.Log(fi.name)
			local sv2 = sv
			for _,i in ipairs(fi.index) do
				if sv2~=sv then
					sv2 = sv2[0]
				end
				sv2 = sv2:Offset(i)
			end
			local val = nil
			if fi.datatype==MemoryManipulation.DataType.Int then
				val = sv2[0]:GetInt()
			elseif fi.datatype==MemoryManipulation.DataType.Float then
				val = sv2[0]:GetFloat()
			elseif fi.datatype==MemoryManipulation.DataType.Bit then
				val = MemoryManipulation.ReadSingleBit(sv2, fi.bitOffset)
			elseif fi.datatype==MemoryManipulation.DataType.ObjectPointer then
				if sv2[0]:GetInt()>0 then
					val = MemoryManipulation.ReadObj(sv2[0], objInfo[fi.name], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name])
				end
			elseif fi.datatype==MemoryManipulation.DataType.ObjectPointerList then
				val = objInfo[fi.name] or {}
				objInfo[fi.name] = val
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					if sv3[0]:GetInt()>0 then
						local vt = sv3[0][0]:GetInt()
						local vtn = MemoryManipulation.VTableNames[vt]
						--LuaDebugger.Log(vt..(IstDrin(vt, MemoryManipulation.ClassVTable) or "nil"))
						if (not readFilter or readFilter[fi.name][vtn]~=nil) and MemoryManipulation.ObjFieldInfo[vt] then
							S5Hook.Log(vtn)
							val[vtn] = MemoryManipulation.ReadObj(sv3[0], val[vtn], nil, readFilter and readFilter[fi.name][vtn])
						end
					end
				end
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObject then
				val = MemoryManipulation.ReadObj(sv2, objInfo[fi.name], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name])
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObjectList then
				val = objInfo[fi.name] or {}
				objInfo[fi.name] = val
				local i=1
				local li = MemoryManipulation.MemList.init(sv2, 4*fi.objectSize)
				for sv3 in li:iterator() do
					val[i] = MemoryManipulation.ReadObj(sv3, val[i], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name])
					i=i+1
				end
			elseif fi.datatype==MemoryManipulation.DataType.ListOfInt then
				val = objInfo[fi.name] or {}
				objInfo[fi.name] = val
				local i=1
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					val[i] = sv3[0]:GetInt()
					i=i+1
				end
			elseif fi.datatype==MemoryManipulation.DataType.String then
				if sv2[0]:GetInt()>0 then
					val = sv2[0]:GetString()
				end
			elseif fi.datatype==MemoryManipulation.DataType.DataPointerListSize then
				val = objInfo[fi.name] or {}
				objInfo[fi.name] = val
				local i=1
				local li = MemoryManipulation.MemList.initFromPointerAndSize(sv2, 4)
				for sv3 in li:iterator() do
					if sv3[0]:GetInt()>0 then
						val[i] = MemoryManipulation.ReadObj(sv3[0], val[i], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name])
					end
					i=i+1
				end
			elseif fi.datatype==nil then
				val = sv2
			end
			if fi.readConv then
				val = fi.readConv(val)
			end
			objInfo[fi.name] = val
		end
	end
	return objInfo
end

function MemoryManipulation.WriteObj(sv, objInfo, fieldInfo)
	if not fieldInfo then
		fieldInfo = MemoryManipulation.ObjFieldInfo[sv[0]:GetInt()]
	end
	assert(fieldInfo.hasNoVTable or fieldInfo.vtable==sv[0]:GetInt())
	for _,fi in ipairs(fieldInfo.fields) do
		if objInfo[fi.name] then
			local sv2 = sv
			for _,i in ipairs(fi.index) do
				if sv2~=sv then
					sv2 = sv2[0]
				end
				sv2 = sv2:Offset(i)
			end
			if type(fi.check)=="function" then
				assert(fi.check(objInfo[fi.name]), sv)
			end
			if type(fi.check)=="table" then
				assert(IstDrin(objInfo[fi.name], fi.check))
			end
			local val = objInfo[fi.name]
			if fi.writeConv then
				val = fi.writeConv(val)
			end
			if fi.datatype==MemoryManipulation.DataType.Int then
				sv2[0]:SetInt(val)
			elseif fi.datatype==MemoryManipulation.DataType.Float then
				sv2[0]:SetFloat(val)
			elseif fi.datatype==MemoryManipulation.DataType.Bit then
				MemoryManipulation.WriteSingleBit(sv2, fi.bitOffset, val)
			elseif fi.datatype==MemoryManipulation.DataType.ObjectPointer then
				if sv2[0]:GetInt()>0 then
					MemoryManipulation.WriteObj(sv2[0], val, MemoryManipulation.ObjFieldInfo[fi.vtableOverride])
				end
			elseif fi.datatype==MemoryManipulation.DataType.ObjectPointerList then
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					local vt = sv3[0][0]:GetInt()
					local vtn = MemoryManipulation.VTableNames[vt]
					if val[vtn] then
						MemoryManipulation.WriteObj(sv3[0], val[vtn])
					end
				end
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObject then
				MemoryManipulation.WriteObj(sv2, val, MemoryManipulation.ObjFieldInfo[fi.vtableOverride])
			end
		end
	end
end

function MemoryManipulation.ConvertToObjInfo(adr, val, objInfo)
	objInfo = objInfo or {}
	local t = objInfo
	local find, i = true, nil
	while true do
		if not string.find(adr, ".", nil, true) then
			t[adr] = val
			return objInfo, t, adr
		else
			i, i, find, adr = string.find(adr, "^([%w_]+)%.([%w_.]+)$")
			t[find] = t[find] or {}
			t = t[find]
		end
	end
end

function MemoryManipulation.GetSingleValue(sv, adr)
	if type(sv)=="string" then
		sv = GetID(sv)
	end
	if type(sv)=="number" then
		sv = S5Hook.GetEntityMem(sv)
	end
	local objInfo, t, adr = MemoryManipulation.ConvertToObjInfo(adr, true)
	MemoryManipulation.ReadObj(sv, objInfo, nil, objInfo)
	return t[adr]
end

function MemoryManipulation.SetSingleValue(sv, adr, val)
	if type(sv)=="string" then
		sv = GetID(sv)
	end
	if type(sv)=="number" then
		sv = S5Hook.GetEntityMem(sv)
	end
	local objInfo = MemoryManipulation.ConvertToObjInfo(adr, val)
	MemoryManipulation.WriteObj(sv, objInfo)
end

function MemoryManipulation.ReadSingleBit(sv, off)
	local v = sv[0]:GetInt()
	v = bit32.band(1, bit32.rshift(v, off))
	return v
end

function MemoryManipulation.WriteSingleBit(sv, off, b)
	local v = sv[0]:GetInt()
	assert(b==1 or b==0)
	if MemoryManipulation.ReadSingleBit(sv, off)~=b then
		v = bit32.bxor(v, bit32.lshift(1, off)) -- swap it
	end
	sv[0]:SetInt(v)
end

function MemoryManipulation.HasEntityBehavior(id, beh)
	local vtn = MemoryManipulation.VTableNames[beh]
	assert(vtn)
	return MemoryManipulation.GetSingleValue(id, "BehaviorList."..vtn..".BehaviorIndex")~=true
end

function MemoryManipulation.HasEntityTypeBehavior(ety, beh)
	local vtn = MemoryManipulation.VTableNames[beh]
	assert(vtn)
	return MemoryManipulation.GetSingleValue(MemoryManipulation.GetETypePointer(ety), "BehaviorProps."..vtn..".BehaviorIndex")~=true
end

function MemoryManipulation.GetETypePointer(ety)
	return S5Hook.GetRawMem(9002416)[0][16]:Offset(ety*8)
end


MemoryManipulation.ClassVTable = {
	-- main entities
	EGL_CGLEEntityProps = tonumber("76E47C", 16),
	EGL_CGLEEntity = tonumber("783E74", 16),
	
	GGL_CEntityProperties = tonumber("776FEC", 16),
	EGL_CMovingEntity = tonumber("783F84", 16),
	GGL_CEvadingEntity = tonumber("770A7C", 16),
	
	GGL_CGLSettlerProps = tonumber("76E498", 16),
	GGL_CSettler = tonumber("76E3CC", 16),
	
	GGL_CGLAnimalProps = tonumber("779074", 16),
	GGL_CAnimal = tonumber("778F7C", 16),
	
	EGL_CAmbientSoundEntity = tonumber("78568C", 16),
	
	GGL_CBuildBlockProperties = tonumber("76EB38", 16),
	
	GGL_CGLBuildingProps = tonumber("76EC78", 16),
	GGL_CBuilding = tonumber("76EB94", 16),
	
	GGL_CBridgeProperties = tonumber("778148", 16),
	GGL_CBridgeEntity = tonumber("77805C", 16),
	
	GGL_CResourceDoodadProperties = tonumber("76FF68", 16),
	GGL_CResourceDoodad = tonumber("76FEA4", 16),
	
	-- display
	ED_CDisplayEntityProps = tonumber("788840", 16),
	
	-- behaviors
	EGL_CGLEBehaviorProps = tonumber("772A2C", 16),
	GGL_CBehaviorWalkCommand = tonumber("7736A4", 16),
	
	GGL_CHeroBehaviorProps = tonumber("7767F4", 16),
	GGL_CHeroBehavior = tonumber("77677C", 16),
	
	GGL_CBattleBehaviorProps = tonumber("7731C0", 16),
	GGL_CBattleBehavior = tonumber("77313C", 16),
	GGL_CLeaderBehaviorProps = tonumber("775FA4", 16),
	GGL_CLeaderBehavior = tonumber("7761E0", 16),
	GGL_CSoldierBehaviorProps = tonumber("773D10", 16),
	GGL_CSoldierBehavior = tonumber("773CC8", 16),
	GGL_CSerfBattleBehaviorProps = tonumber("774B50", 16),
	GGL_CSerfBattleBehavior = tonumber("774A98", 16),
	GGL_CBattleSerfBehaviorProps = tonumber("77889C", 16),
	GGL_CBattleSerfBehavior = tonumber("7788C4", 16),
	
	GGL_CLimitedAttachmentBehaviorProperties = tonumber("775EB4", 16),
	GGL_CLimitedAttachmentBehavior = tonumber("775E84", 16),
	
	GGL_CGLAnimationBehaviorExProps = tonumber("776C48", 16),
	GGL_CGLBehaviorAnimationEx = tonumber("776B64", 16),
	
	GGL_CHeroAbilityProps = tonumber("773774", 16),
	GGL_CBombPlacerBehavior = tonumber("7783D8", 16),
	
	GGL_CCamouflageBehaviorProps = tonumber("7778D8", 16),
	GGL_CCamouflageBehavior = tonumber("7738F4", 16),
	GGL_CThiefCamouflageBehavior = tonumber("773934", 16),
	GD_CCamouflageBehaviorProps = tonumber("76AEA0", 16),
	
	GGL_CHeroHawkBehaviorProps = tonumber("77672C", 16),
	GGL_CHeroHawkBehavior = tonumber("7766F0", 16),
	
	GGL_CInflictFearAbilityProps = tonumber("776674", 16),
	GGL_CInflictFearAbility = tonumber("776638", 16),
	
	GGL_CCannonBuilderBehaviorProps = tonumber("777510", 16),
	GGL_CCannonBuilderBehavior = tonumber("7774D4", 16),
	
	GGL_CRangedEffectAbilityProps = tonumber("774E9C", 16),
	GGL_CRangedEffectAbility = tonumber("774E54", 16),
	
	GGL_CCircularAttackProps = tonumber("7774A0", 16),
	GGL_CCircularAttack = tonumber("777464", 16),
	
	GGL_CSummonBehaviorProps = tonumber("773C50", 16),
	GGL_CSummonBehavior = tonumber("773C10", 16),
	
	GGL_CConvertSettlerAbilityProps = tonumber("7772D0", 16),
	GGL_CConvertSettlerAbility = tonumber("777294", 16),
	
	GGL_CSniperAbilityProps = tonumber("7745E8", 16),
	GGL_CSniperAbility = tonumber("7745AC", 16),
	
	GGL_CMotivateWorkersAbilityProps = tonumber("775788", 16),
	GGL_CMotivateWorkersAbility = tonumber("77574C", 16),
	
	GGL_CShurikenAbilityProps = tonumber("7746B4", 16),
	GGL_CShurikenAbility = tonumber("774658", 16),
	
	EGL_CMovementBehaviorProps = tonumber("784938", 16),
	GGL_CBehaviorDefaultMovement = tonumber("7786AC", 16),
	GGL_CSettlerMovement = tonumber("77471C", 16),
	GGL_CLeaderMovement = tonumber("775ED4", 16),
	GGL_CSoldierMovement = tonumber("77438C", 16),
	
	GGL_CSentinelBehaviorProps = tonumber("774BAC", 16),
	GGL_CSentinelBehavior = tonumber("774B6C", 16),
	
	GGL_CWorkerBehaviorProps = tonumber("772B90", 16),
	GGL_CWorkerBehavior = tonumber("772B30", 16),
	
	GGL_CSerfBehaviorProps = tonumber("774A14", 16),
	GGL_CSerfBehavior = tonumber("774874", 16),
	
	GGL_CFormationBehaviorProperties = tonumber("776DE4", 16),
	GGL_CFormationBehavior = tonumber("776D60", 16),
	
	GGL_CCamperBehaviorProperties = tonumber("7777D4", 16),
	GGL_CCamperBehavior = tonumber("77777C", 16),
	
	GGL_CGLBehaviorPropsDying = tonumber("778634", 16),
	GGL_CGLBehaviorDying = tonumber("7785E4", 16),
	
	GGL_CBombBehaviorProperties = tonumber("7784A0", 16),
	GGL_CBombBehavior = tonumber("778468", 16),
	
	GGL_CKegBehaviorProperties = tonumber("776558", 16),
	GGL_CKegBehavior = tonumber("7764D8", 16),
	
	GGL_CThiefBehaviorProperties = tonumber("7739E0", 16),
	GGL_CThiefBehavior = tonumber("7739B0", 16),
	
	GGL_CAutoCannonBehaviorProps = tonumber("778CD4", 16),
	GGL_CAutoCannonBehavior = tonumber("778CF0", 16),
	
	GGL_CResourceRefinerBehaviorProperties = tonumber("774C24", 16),
	GGL_CResourceRefinerBehavior = tonumber("774BCC", 16),
	
	GGL_CAffectMotivationBehaviorProps = tonumber("7791D4", 16),
	GGL_CAffectMotivationBehavior = tonumber("77918C", 16),
	
	GGL_CLimitedLifespanBehaviorProps = tonumber("775DE4", 16),
	GGL_CLimitedLifespanBehavior = tonumber("775D9C", 16),
	
	-- other stuff
	GGlue_CGlueEntityProps = tonumber("788824", 16),
	EGL_CGLEModelSet = tonumber("76E380", 16),
	
}
MemoryManipulation.VTableNames = {}
for k,v in pairs(MemoryManipulation.ClassVTable) do
	MemoryManipulation.VTableNames[v] = k
end
MemoryManipulation.DataType= {Int=1, Float=2, ObjectPointer=3, ObjectPointerList=4, Bit=5, EmbeddedObjectList=6, EmbeddedObject=7, ListOfInt=8, String=9, DataPointerListSize=10}
MemoryManipulation.ObjFieldInfo = {
	-- entities
	markerEntities=nil,
	[MemoryManipulation.ClassVTable.EGL_CGLEEntity] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEEntity,
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="EntityType", index={4}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ModelOverride", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a==0 or IstDrin(a, Models) end}, -- 0 for use entitytype model
			{name="PlayerId", index={6}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="Position", index={22}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="Scale", index={25}, datatype=MemoryManipulation.DataType.Float},
			{name="DefaultBehavourFlag", index={27}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}}, -- ?
			{name="UserControlFlag", index={27}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}}, -- ?
			{name="UnattackableFlag", index={27}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}}, -- ?
			{name="SelectableFlag", index={28}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="UserControlFlag", index={28}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}}, -- ?
			{name="VisibleFlag", index={28}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="BehaviorList", index={31}, datatype=MemoryManipulation.DataType.ObjectPointerList},
			{name="CurrentState", index={34}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="EntityStateBehaviors", index={35}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="TaskListId", index={36}, datatype=MemoryManipulation.DataType.Int, check={}}, -- use logic to set
			{name="TaskIndex", index={37}, datatype=MemoryManipulation.DataType.Int, check={}}, -- where in the task list is the entity
			{name="CurrentHealth", index={50}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ScriptName", index={51}, datatype=MemoryManipulation.DataType.String},
			{name="ScriptCommandLine", index={52}, datatype=MemoryManipulation.DataType.String}, -- i think this is script executed when the entity is created, used by mapeditor
			{name="Exploration", index={53}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="TaskListStart", index={54}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="InvulnerabilityAndSuspended", index={57}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="SuspensionTurn", index={58}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ScriptingValue", index={59}, datatype=MemoryManipulation.DataType.Int, check={}}, -- no idea for what this is
			{name="StateChangeCounter", index={63}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="TaskListChangeCounter", index={64}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NumberOfAuraEffects", index={65}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CMovingEntity] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CMovingEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="TargetPosition", index={66}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TargetRotationValid", index={68}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="TargetRotation", index={69}, datatype=MemoryManipulation.DataType.Float, readConv=math.deg, writeConv=math.rad},
			{name="MovementState", index={70}, datatype=MemoryManipulation.DataType.Int, check={}}, -- ?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CEvadingEntity] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CEvadingEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CMovingEntity},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettler] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettler,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CEvadingEntity},
		fields = {
			{name="TimeToWait", index={75}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="HeadIndex", index={76}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="HeadParams", index={77}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ExperiencePoints", index={85}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="ExperienceLevel", index={85}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="MovingSpeed", index={89}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Damage", index={91}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Dodge", index={93}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Motivation", index={95}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Armor", index={97}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="CurrentAmountSoldiers", index={99}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="MaxAmountSoldiers", index={101}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="DamageBonus", index={103}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="ExplorationCache", index={105}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="MaxAttackRange", index={107}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="AutoAttackRange", index={109}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="HealingPoints", index={111}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="MissChance", index={113}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Healthbar", index={115}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="SomeIntRegardingTaskLists", index={123}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LeaderId", index={127}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="OverheadWidget", index={130}, datatype=MemoryManipulation.DataType.Int, check={0,1,2,3,4}},
			{name="ExperienceClass", index={131}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BlessBuff", index={134}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NPCMarker", index={135}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LeaveBuildingTurn", index={136}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBuilding] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBuilding,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="ApproachPosition", index={66}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LeavePosition", index={68}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="IsActive", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}}, -- ?
			{name="IsRegistered", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}}, -- ?
			{name="IsUpgrading", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}}, -- ?
			{name="IsOvertimeActive", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}}, -- ?
			{name="HQAlarmActive", index={71}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}}, -- ?
			{name="MaxNumWorkers", index={72}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="CurrentTechnology", index={73}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LatestAttackTurn", index={74}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="MostRecentDepartureTurn", index={75}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BuildingHeight", index={76}, datatype=MemoryManipulation.DataType.Float}, -- also construction progress
			{name="Helathbar", index={77}, datatype=MemoryManipulation.DataType.Float}, -- also repair progress
			{name="UpgradeProgress", index={78}, datatype=MemoryManipulation.DataType.Float},
			{name="NumberOfRepairingSerfs", index={81}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ConstructionSiteType", index={83}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBridgeEntity] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBridgeEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuilding},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceDoodad] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceDoodad,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="ResourceType", index={66}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="ResourceAmount", index={67}, datatype=MemoryManipulation.DataType.Int},
			{name="ResourceAmountAdd", index={68}, datatype=MemoryManipulation.DataType.Int},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CAmbientSoundEntity] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CAmbientSoundEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="AmbientSoundType", index={67}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>0 and a <=22 end},
		},
	},
	-- entity props
	markerEntityProps=nil,
	[MemoryManipulation.ClassVTable.EGL_CGLEEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEEntityProps,
		fields = {
			{name="Class", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="Categories", index={4}, datatype=MemoryManipulation.DataType.ListOfInt},
			{name="ApproachPos", index={7}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ApproachR", index={9}, datatype=MemoryManipulation.DataType.Float},
			{name="Race", index={10}, datatype=nil},
			{name="CanFloat", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="CanDrown", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="MapFileDontSave", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="DividesTwoSectors", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="ForceNoPlayer", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="AdjustWalkAnimSpeed", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Visible", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="DoNotExecute", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="MaxHealth", index={13}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Models", index={14}, datatype=MemoryManipulation.DataType.EmbeddedObject},
			{name="Exploration", index={19}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ExperiencePoints", index={20}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AccessCategory", index={21}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NumBlockedPoints", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SnapTolerance", index={23}, datatype=MemoryManipulation.DataType.Float},
			{name="DeleteWhenBuiltOn", index={24}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="NeedsPlayer", index={24}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="BlockingArea", index={35}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="AARectangle", objectSize=4},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CEntityProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CEntityProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="ResourceEntity", index={38}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="ResourceAmount", index={39}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SummerEffect", index={40}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="WinterEffect", index={41}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLSettlerProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLSettlerProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="HeadSet", index={38}, datatype=nil},
			{name="Hat", index={39}, datatype=nil},
			{name="Cost", index={40}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="BuildFactor", index={58}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="RepairFactor", index={59}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ArmorAmount", index={61}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="IdleTaskList", index={63}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="ArmorClass", index={60}, datatype=MemoryManipulation.DataType.Int, check=ArmorClasses},
			{name="DodgeChance", index={62}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Upgrade", index={64}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="upgradeInfo"},
			{name="Convertible", index={85}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Fearless", index={85}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="ModifyExploration", index={86}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyHitpoints", index={91}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifySpeed", index={96}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyDamage", index={101}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyArmor", index={106}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyDodge", index={111}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyMaxRange", index={116}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyMinRange", index={121}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyDamageBonus", index={126}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyGroupLimit", index={131}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="AttractionSlots", index={136}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLAnimalProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLAnimalProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="DefaultTaskList", index={38}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="TerritoryRadius", index={39}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WanderRangeMin", index={40}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WanderRangeMax", index={41}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ShyRange", index={42}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MaxBuildingPollution", index={43}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="FleeTaskList", index={44}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="TerrainPos1", index={38}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TerrainPos2", index={40}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceDoodadProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceDoodadProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties},
		fields = {
			{name="Radius", index={42}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Center", index={43}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LineStart", index={45}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LineEnd", index={47}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ExtractTaskList", index={49}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Model1", index={50}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model2", index={51}, datatype=MemoryManipulation.DataType.Int, check=Models},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBuildingProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBuildingProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties},
		fields = {
			{name="MaxWorkers", index={42}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="InitialMaxWorkers", index={43}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="NumberOfAttractableSettlers", index={44}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Worker", index={45}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="DoorPos", index={46}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LeavePos", index={48}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ConstructionInfo", index={50}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="constructionInfo"},
			{name="BuildOn", index={76}, datatype=MemoryManipulation.DataType.ListOfInt},
			{name="HideBase", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="CanBeSold", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="IsWall", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="Upgrade", index={80}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="upgradeInfo"},
			{name="UpgradeSite", index={101}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="ArmorClass", index={102}, datatype=MemoryManipulation.DataType.Int, check=ArmorClasses},
			{name="ArmorAmount", index={103}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="WorkTaskList", index={105}, datatype=MemoryManipulation.DataType.ListOfInt},
			{name="MilitaryInfo", index={108}, datatype=nil},
			{name="CollapseTime", index={112}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Convertible", index={113}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="ModifyExploration", index={114}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyArmor", index={119}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="KegEffectFactor", index={124}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBridgeProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBridgeProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CGLBuildingProps},
		fields = {
			{name="BridgeArea", index={126}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="AARectangle", objectSize=4},
			{name="Height", index={129}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ConstructionModel0", index={130}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="ConstructionModel1", index={131}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="ConstructionModel2", index={132}, datatype=MemoryManipulation.DataType.Int, check=Models},
		},
	},
	-- entitytyp
	markerEntityType=nil,
	[MemoryManipulation.ClassVTable.GGlue_CGlueEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGlue_CGlueEntityProps,
		fields = {
			{name="LogicProps", index={2}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="DisplayProps", index={3}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="BehaviorProps", index={5}, datatype=MemoryManipulation.DataType.ObjectPointerList},
		},
	},
	-- behavior props
	markerBehaviorProps=nil,
	[MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps,
		fields = {
			{name="BehaviorIndex", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BehaviorClass", index={3}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CMovementBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CMovementBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="MovementSpeed", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TurningSpeed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end, readConv=math.deg, writeConv=math.rad},
			{name="MoveTaskList", index={6}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="MoveIdleAnim", index={7}, datatype=MemoryManipulation.DataType.Int, check=nil}, -- TODO needs check for valid animation
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="RechargeTimeSeconds", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamouflageBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamouflageBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="DurationSeconds", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DiscoveryRange", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroHawkBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroHawkBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="HawkType", index={5}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="HawkMaxRange", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CInflictFearAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CInflictFearAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="FlightDuration", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Range", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="FlightRange", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CRangedEffectAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CRangedEffectAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="AffectsOwn", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="AffectsFriends", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="AffectsNeutrals", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="AffectsHostiles", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="AffectsMilitaryOnly", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="AffectsLongRangeOnly", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="DurationSeconds", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DamageFactor", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ArmorFactor", index={10}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="HealthRecoveryFactor", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Effect", index={12}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="HealEffect", index={13}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCircularAttackProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCircularAttackProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="DamageClass", index={7}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="Damage", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Range", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			-- 10 effect?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSummonBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSummonBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="SummonedEntityType", index={5}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="NumberOfSummonedEntities", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SummonTaskList", index={7}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="ConversionTaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="HPToMSFactor", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ConversionStartRange", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ConversionMaxRange", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSniperAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSniperAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="DamageFactor", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeBonus", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Effect", index={9}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CShurikenAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CShurikenAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MaxArcDegree", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="NumberShuriken", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ProjectileType", index={10}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="ProjectileOffsetHeight", index={11}, datatype=MemoryManipulation.DataType.Float, check=nil},
			{name="ProjectileOffsetFront", index={12}, datatype=MemoryManipulation.DataType.Float, check=nil},
			{name="ProjectileOffsetRight", index={13}, datatype=MemoryManipulation.DataType.Float, check=nil},
			{name="DamageClass", index={14}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="DamageAmount", index={15}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSentinelBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSentinelBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Range", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLAnimationBehaviorExProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLAnimationBehaviorExProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="SuspensionAnimation", index={4}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="AnimSet", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CWorkerBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CWorkerBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="WorkTaskList", index={4}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="WorkIdleTaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="WorkWaitUntil", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="EatTaskList", index={8}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="EatIdleTaskList", index={9}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="EatWait", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="RestTaskList", index={11}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="RestIdleTaskList", index={12}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="RestWait", index={13}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="LeaveTaskList", index={15}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="AmountResearched", index={16}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeChangeFarm", index={18}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeChangeResidence", index={19}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeChangeCamp", index={20}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeMaxCangeFarm", index={21}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="WorkTimeMaxChangeResidence", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ExhaustedWorkMotivationMalus", index={23}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TransportAmount", index={24}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TransportModel", index={25}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="TransportAnim", index={26}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="ResourceToRefine", index={27}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="WorkTimeChangeWork", index={28}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="BattleTaskList", index={4}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="NormalAttackAnim1", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="NormalAttackAnim2", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="CounterAttackAnim", index={7}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="FinishingMoveAnim", index={8}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="MissAttackAnim", index={9}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="BattleIdleAnim", index={10}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="BattleWalkAnim", index={11}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="HitAnim", index={12}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="DamageClass", index={13}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="DamageAmount", index={14}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaxDamageRandomBonus", index={15}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DamageRange", index={16}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ProjectileEffectID", index={17}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="ProjectileOffsetFront", index={18}, datatype=MemoryManipulation.DataType.Float},
			{name="ProjectileOffsetRight", index={19}, datatype=MemoryManipulation.DataType.Float},
			{name="ProjectileOffsetHeight", index={20}, datatype=MemoryManipulation.DataType.Float},
			{name="BattleWaitUntil", index={21}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MissChance", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaxRange", index={23}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MinRange", index={24}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps},
		fields = {
			{name="SoldierType", index={25}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="BarrackUpgradeCategory", index={26}, datatype=MemoryManipulation.DataType.Int, check=UpgradeCategories},
			{name="HomeRadius", index={27}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="HealingPoints", index={28}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="HealingSeconds", index={29}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AutoAttackRange", index={30}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="UpkeepCosts", index={31}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSoldierBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSoldierBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBattleBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBattleBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleSerfBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleSerfBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CLeaderBehaviorProps},
		fields = {
			--{name="TurnIntoSerfTaskList", index={32}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="ResourceSearchRadius", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ApproachConbstructionSiteTaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="TurnIntoBattleSerfTaskList", index={6}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="ExtractionInfo", index={8}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="ExtractionInfo", objectSize=3},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Attachments", index={5}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="LimitedAttachmentProps", objectSize=9},
			--{name="Attachments", index={5}, datatype=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CFormationBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CFormationBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="IdleAnims", index={5}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="IdleAnimProps", objectSize=2},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamperBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamperBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Range", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBehaviorPropsDying] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBehaviorPropsDying,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="DyingTaskList", index={4}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBombBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBombBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Radius", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Delay", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Damage", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ExplosionEffectID", index={7}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="AffectedEntityTypes", index={9}, datatype=MemoryManipulation.DataType.ListOfInt},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CKegBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CKegBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Radius", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Damage", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Delay", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="DamagePercent", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ExplosionEffectID", index={8}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CThiefBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CThiefBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="SecondsNeededToSteal", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MinimumAmountToSteal", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaximumAmountToSteal", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="CarryingModelID", index={7}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="StealGoodsTaskList", index={8}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="SecureGoodsTaskList", index={9}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAutoCannonBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAutoCannonBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="NumberOfShots", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=-1 end},
			{name="RotationSpeed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end, readConv=math.deg, writeConv=math.rad},
			{name="CannonBallEffectType", index={6}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="ReloadTime", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaxAttackRange", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end}, -- check autoattackrange and this
			{name="DamageClass", index={13}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="DamageAmount", index={14}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DamageRange", index={15}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="BattleTaskList", index={16}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="ResourceType", index={4}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="InitialFactor", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="SupplierCategory", index={10}, datatype=MemoryManipulation.DataType.Int, check=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="MotivationEffect", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="LifespanSeconds", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	-- behaviors
	markerBehaviors=nil,
	["EGL_CGLEBehavior"] = {-- no vtable known
		fields = {
			{name="BehaviorIndex", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BehaviorProps", index={3}, datatype=MemoryManipulation.DataType.ObjectPointer},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			--{name="Counter", index={4}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="MovementSpeed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TurningSpeed", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end, readConv=math.deg, writeConv=math.rad},
			{name="SpeedFactor", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettlerMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettlerMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
			{name="PositionHiRes", index={9}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="Position", index={12}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="BlockingFlag", index={15}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
			{name="MoveTaskList", index={8}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="NextWayPoint", index={9}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="LastTurnPos", index={12}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="IsPathingUsed", index={15}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="IsMoveFinished", index={15}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSoldierMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSoldierMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
		},
	},
	["GGL_CHeroAbility"] = {-- no vtable known
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="AbilitySecondsCharged", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="InvisibilityRemaining", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CThiefCamouflageBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CThiefCamouflageBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior},
		fields = {
			{name="TimeToInvisibility", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroHawkBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroHawkBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CInflictFearAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CInflictFearAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBombPlacerBehavior] = { -- bomb entity hardcoded?
		vtable = MemoryManipulation.ClassVTable.GGL_CBombPlacerBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="StartPosition", index={6}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TargetPosition", index={8}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="PlacedBomb", index={10}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			-- 11 remaining turns?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="StartPosition", index={7}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="CannonType", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="FoundationType", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PlacedCannon", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CRangedEffectAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CRangedEffectAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="SecondsRemaining", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCircularAttack] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCircularAttack,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSummonBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSummonBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="TimeToConvert", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSniperAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSniperAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="TargetId", index={7}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CShurikenAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CShurikenAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="TargetId", index={7}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSentinelBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSentinelBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBehaviorAnimationEx] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBehaviorAnimationEx,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="Animation", index={4}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="AnimCategory", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="SuspendedAnimation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="StartTurn", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Duration", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PlayBackwards", index={9}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="TurnToWaitFor", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Speed", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			-- 19 animset?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBehaviorWalkCommand] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBehaviorWalkCommand,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="TargetPosition", index={4}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CWorkerBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CWorkerBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="WorkTimeRemaining", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TargetWorkTime", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Motivation", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="BehaviorProps2", index={7}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="CycleIndex", index={8}, datatype=MemoryManipulation.DataType.Int, check={0,1,2}},
			{name="TimesWorked", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoWork", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoFood", index={11}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoRest", index={12}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoPay", index={13}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="JoblessSinceTurn", index={14}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="CouldConsumeResource", index={15}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="IsLeaving", index={16}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TransportAmount", index={17}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="SuccessDistance", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="FailureDistance", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TimeOutTime", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="StartTurn", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TargetPosition", index={8}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="StartFollowing", index={10}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="StopFollowing", index={10}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="FollowStatus", index={11}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LatestHitTurn", index={12}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="LatestAttackerID", index={14}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
			{name="BattleStatus", index={15}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NoMoveNecessary", index={16}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="NormalRangeCheckNecessary", index={16}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Command", index={17}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="AttackMoveTarget", index={18}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="MilliSecondsToWait", index={21}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MSToPlayHitAnimation", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="HitPlayed", index={23}, datatype=MemoryManipulation.DataType.Int, check=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehavior},
		fields = {
			{name="TroopHealthCurrent", index={27}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TroopHealthPerSoldier", index={28}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TerritoryCenter", index={29}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TerritoryCenterRange", index={31}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Experience", index={32}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PatrolPoints", index={34}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="Position", objectSize=2},
			{name="DefendOrientation", index={38}, datatype=MemoryManipulation.DataType.Float, readConv=math.deg, writeConv=math.rad},
			{name="TrainingStartTurn", index={39}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SecondsSinceHPRefresh", index={41}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="NudgeCount", index={42}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="FormationType", index={43}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="StartBattlePosition", index={44}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSoldierBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSoldierBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehavior},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBattleBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBattleBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehavior},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleSerfBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleSerfBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CLeaderBehavior},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="Attachment1", index={6,0}, datatype=MemoryManipulation.DataType.ObjectPointer, vtableOverride="LimitedAttachment"},
			--{name="test", index={0}, datatype=nil},
			-- TODO figure out, how more than 1 attachment type works
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CFormationBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CFormationBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="AnimStartTurn", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AnimDuration", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamperBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamperBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {-- TODO fields, inheritance not working again
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBehaviorDying] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBehaviorDying,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="ResurrectionTimePassed", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SpawnTurn", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="FriendNear", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="EnemyNear", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBombBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBombBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="TimeToExplode", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end, readConv=function(a) return a/10 end, writeConv=function(a) return a*10 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CKegBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CKegBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="TimeToExplode", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end, readConv=function(a) return a/10 end, writeConv=function(a) return a*10 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CThiefBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CThiefBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="Amount", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ResourceType", index={5}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="StolenFromPlayer", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 and a<9 end},
			{name="TimeToSteal", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end, readConv=function(a) return a/10 end, writeConv=function(a) return a*10 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAutoCannonBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAutoCannonBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="ShotsLeft", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=-1 end},
			-- there are a lot of 0s and stuff i can't make sense of, but shotsleft is probably the most imprortant anyway
			-- 8 seems to be some sort of attack time counter
			-- 9 is 275 at least on pilgrims cannon
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			-- 5 player?
			-- 6 building finished?
			-- 7 random value?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="RemainingLifespanSeconds", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	-- display props
	markerDisplayProps=nil,
	[MemoryManipulation.ClassVTable.ED_CDisplayEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.ED_CDisplayEntityProps,
		fields = {
			{name="DisplayClass", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="Model", index={2}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model2", index={3}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model3", index={4}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model4", index={5}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="DrawPlayerColor", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="CastShadow", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="RenderInFoW", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="HighQualityOnly", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="MapEditor_Rotateable", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="MapEditor_Placeable", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="AnimList", index={9}, datatype=MemoryManipulation.DataType.ListOfInt},
		},
	},
	-- misc stuff (embedded objects, helper tables...)
	markerMiscStuff=nil,
	[MemoryManipulation.ClassVTable.EGL_CGLEModelSet] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEModelSet,
		fields = {
			{name="ModelList", index={2}, datatype=MemoryManipulation.DataType.ListOfInt},
		},
	},
	costInfo = {
		hasNoVTable = true,
		fields = {
			{name="Gold", index={1}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="GoldRaw", index={2}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Silver", index={3}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="SilverRaw", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Stone", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="StoneRaw", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Iron", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="IronRaw", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Sulfur", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="SulfurRaw", index={10}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Clay", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ClayRaw", index={12}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Wood", index={13}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WoodRaw", index={14}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WeatherEnergy", index={15}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Knowledge", index={16}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Faith", index={17}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		}
	},
	upgradeInfo = {
		hasNoVTable = true,
		fields = {
			{name="Time", index={0}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Cost", index={1}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="Type", index={19}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="Category", index={20}, datatype=MemoryManipulation.DataType.Int, check=UpgradeCategories},
		}
	},
	constructionInfo = {
		hasNoVTable = true,
		fields = {
			{name="BuilderSlot", index={2}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="PositionWithRotation", objectSize=3},
			{name="Time", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Cost", index={6}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="ConstructionSite", index={24}, datatype=MemoryManipulation.DataType.Int, check=Entities},
		}
	},
	AARectangle = {
		hasNoVTable = true,
		fields = {
			{name=1, index={0}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name=2, index={2}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		}
	},
	modifyEntityProps = {
		hasNoVTable = true,
		fields = {
			{name="MysteriousInt", index={0}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="TechList", index={2}, datatype=MemoryManipulation.DataType.ListOfInt},
		},
	},
	Position = {
		hasNoVTable = true,
		fields = {
			{name="X", index={0}, datatype=MemoryManipulation.DataType.Float},
			{name="Y", index={1}, datatype=MemoryManipulation.DataType.Float},
		}
	},
	PositionWithRotation = {
		hasNoVTable = true,
		fields = {
			{name="X", index={0}, datatype=MemoryManipulation.DataType.Float},
			{name="Y", index={1}, datatype=MemoryManipulation.DataType.Float},
			{name="r", index={2}, datatype=MemoryManipulation.DataType.Float, readConv=math.deg, writeConv=math.rad},
		}
	},
	ExtractionInfo = {
		hasNoVTable = true,
		fields = {
			{name="ResourceEntityType", index={0}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="Delay", index={1}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Amount", index={2}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		}
	},
	LimitedAttachmentProps = {
		hasNoVTable = true,
		fields = {
			{name="Type", index={1}, datatype=MemoryManipulation.DataType.String},
			--{name="AttachmentType", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Limit", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		}
	},
	LimitedAttachment = {
		hasNoVTable = true,
		fields = {
			{name="AttachmentType", index={3}, datatype=MemoryManipulation.DataType.Int},
			{name="Limit", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="IsActive", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="AttachmentInfo", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
		}
	},
	IdleAnimProps = {
		hasNoVTable = true,
		fields = {
			{name="AnimID", index={0}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Frequency", index={1}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		}
	},
}

do
	local function applyInheritance(of)
		if of.inheritsFrom and not of.inheritanceDone then
			for _,c in ipairs(of.inheritsFrom) do
				applyInheritance(MemoryManipulation.ObjFieldInfo[c])
				for _,f in ipairs(MemoryManipulation.ObjFieldInfo[c].fields) do
					table.insert(of.fields, f)
				end
			end
		end
		of.inheritanceDone=true
	end
	for _,o in pairs(MemoryManipulation.ObjFieldInfo) do
		applyInheritance(o)
	end
end
