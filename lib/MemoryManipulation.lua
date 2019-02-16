if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/IstDrin")
mcbPacker.require("comfort/s5HookLoader")
mcbPacker.require("comfort/MemList")
mcbPacker.require("comfort/entity/IsEntityOfType")
mcbPacker.require("comfort/round")
mcbPacker.require("comfort/ArmorClasses")
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
end --mcbPacker.ignore

--MemoryManipulation.ReadObj(S5Hook.GetEntityMem(132339))
--MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CLimitedAttachmentBehavior.MaxAttachment", true)
--MemoryManipulation.GetSingleValue(132339, "BehaviorList.GGL_CLimitedAttachmentBehavior.MaxAttachment")


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
	assert(fieldInfo.vtable==sv[0]:GetInt())
	for _,fi in ipairs(fieldInfo.fields) do
		if not readFilter or readFilter[fi[1]]~=nil then
			local sv2 = sv
			for _,i in ipairs(fi[2]) do
				if sv2~=sv then
					sv2 = sv2[0]
				end
				sv2 = sv2:Offset(i)
			end
			local val = nil
			if fi[3]==MemoryManipulation.DataType.Int then
				val = sv2[0]:GetInt()
			elseif fi[3]==MemoryManipulation.DataType.Float then
				val = sv2[0]:GetFloat()
			elseif fi[3]==MemoryManipulation.DataType.ObjectPointer then
				val = MemoryManipulation.ReadObj(sv2[0], objInfo[fi[1]], nil, readFilter and readFilter[fi[1]])
			elseif fi[3]==MemoryManipulation.DataType.ObjectList then
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					local vt = sv3[0][0]:GetInt()
					local vtn = MemoryManipulation.VTableNames[vt]
					--LuaDebugger.Log(vt..(IstDrin(vt, MemoryManipulation.ClassVTable) or "nil"))
					if (not readFilter or readFilter[fi[1]][vtn]~=nil) and MemoryManipulation.ObjFieldInfo[vt] then
						val = objInfo[fi[1]] or {}
						val[vtn] = MemoryManipulation.ReadObj(sv3[0], val[vtn], nil, readFilter and readFilter[fi[1]][vtn])
						objInfo[fi[1]] = val
					end
				end
			end
			if fi[5] then
				val = fi[5](val)
			end
			objInfo[fi[1]] = val
		end
	end
	return objInfo
end

function MemoryManipulation.WriteObj(sv, objInfo, fieldInfo)
	if not fieldInfo then
		fieldInfo = MemoryManipulation.ObjFieldInfo[sv[0]:GetInt()]
	end
	assert(fieldInfo.vtable==sv[0]:GetInt())
	for _,fi in ipairs(fieldInfo.fields) do
		if objInfo[fi[1]] then
			local sv2 = sv
			for _,i in ipairs(fi[2]) do
				if sv2~=sv then
					sv2 = sv2[0]
				end
				sv2 = sv2:Offset(i)
			end
			if type(fi[4])=="function" then
				assert(fi[4](objInfo[fi[1]]), sv)
			end
			if type(fi[4])=="table" then
				assert(IstDrin(objInfo[fi[1]], fi[4]))
			end
			local val = objInfo[fi[1]]
			if fi[6] then
				val = fi[6](val)
			end
			if fi[3]==MemoryManipulation.DataType.Int then
				sv2[0]:SetInt(val)
			elseif fi[3]==MemoryManipulation.DataType.Float then
				sv2[0]:SetFloat(val)
			elseif fi[3]==MemoryManipulation.DataType.ObjectPointer then
				MemoryManipulation.WriteObj(sv2[0], val)
			elseif fi[3]==MemoryManipulation.DataType.ObjectList then
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					local vt = sv3[0][0]:GetInt()
					local vtn = MemoryManipulation.VTableNames[vt]
					if val[vtn] then
						MemoryManipulation.WriteObj(sv3[0], val[vtn])
					end
				end
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

MemoryManipulation.ClassVTable = {
	GGL_CLeaderBehaviorProps = tonumber("775FA4", 16),
	GGL_CLeaderBehavior = tonumber("7761E0", 16),
	
	GGL_CSoldierBehaviorProps = tonumber("773D10", 16),
	
	GGL_CLimitedAttachmentBehavior = tonumber("775E84", 16),
	GGL_CLimitedAttachmentBehaviorProperties = tonumber("775EB4", 16),
	
	GGL_CGLBehaviorAnimationEx = tonumber("776B64", 16),
	GGL_CGLAnimationBehaviorExProps = tonumber("776C48", 16),
	
	GGL_CThiefCamouflageBehavior = tonumber("00773934", 16),
	
	GGL_CHeroBehavior = tonumber("0077677C", 16),
	
	GGL_CCamouflageBehaviorProps = tonumber("7778D8", 16),
	GGL_CCamouflageBehavior = tonumber("007738F4", 16),
	GD_CCamouflageBehaviorProps = tonumber("76AEA0", 16),
	
	GGL_CGLBuildingProps = tonumber("76EC78", 16),
	
	GGL_CGLSettlerProps = tonumber("76E498", 16),
	GGL_CSettler = tonumber("76E3CC", 16),
	
	GGL_CBehaviorDefaultMovement = tonumber("7786AC", 16),
	GGL_CSettlerMovement = tonumber("77471C", 16),
	GGL_CLeaderMovement = tonumber("775ED4", 16),
	
	GGL_CLimitedLifespanBehaviorProps = tonumber("775DE4", 16),
	GGL_CLimitedLifespanBehavior = tonumber("775D9C", 16),
	
	GGL_CBridgeProperties = tonumber("778148", 16),
	
	GGL_CAffectMotivationBehaviorProps = tonumber("7791D4", 16),
	
	GGL_CThiefBehaviorProperties = tonumber("7739E0", 16),
	GGL_CThiefBehavior = tonumber("7739B0", 16),
	
	GGL_CWorkerBehaviorProps = tonumber("772B90", 16),
	
	GGL_CResourceRefinerBehaviorProperties = tonumber("774C24", 16),
	
	GGL_CAutoCannonBehaviorProps = tonumber("778CD4", 16),
	
	GGL_CSerfBattleBehaviorProps = tonumber("774B50", 16),
	
	GGL_CBattleSerfBehavior = tonumber("7788C4", 16),
	GGL_CBattleSerfBehaviorProps = tonumber("77889C", 16),
}
MemoryManipulation.VTableNames = {}
for k,v in pairs(MemoryManipulation.ClassVTable) do
	MemoryManipulation.VTableNames[v] = k
end
MemoryManipulation.DataType= {Int=1, Float=2, ObjectPointer=3, ObjectList=4}
MemoryManipulation.ObjFieldInfo = {
	[MemoryManipulation.ClassVTable.GGL_CLeaderBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderBehavior,
		fields = {
			{"TroopHealthCurrent", {27}, MemoryManipulation.DataType.Int, function(a) return a>=0 end},
			{"TroopHealthPerSoldier", {28}, MemoryManipulation.DataType.Int, function(a) return a>=0 end},
			{"Experience", {32}, MemoryManipulation.DataType.Int, function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettler] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettler,
		fields = {
			{"EntityId", {2}, MemoryManipulation.DataType.Int, {}},
			{"Scale", {25}, MemoryManipulation.DataType.Float},
			{"BehaviorList", {31}, MemoryManipulation.DataType.ObjectList},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior,
		fields = {
			{"MaxAttachment", {6,0,4}, MemoryManipulation.DataType.Int, function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement,
		fields = {
			{"MovementSpeed", {5}, MemoryManipulation.DataType.Float, function(a) return a>=0 end},
			{"TurningSpeed", {6}, MemoryManipulation.DataType.Float, function(a) return a>=0 end, math.deg, math.rad},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettlerMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettlerMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
			{"BlockingFlag", {15}, MemoryManipulation.DataType.Int, {1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
		},
	},
	["GGL_CHeroAbility"] = {-- no vtable known
		fields = {
			{"AbilitySecondsCharged", {5}, MemoryManipulation.DataType.Int, function(a) return a>=0 end}, -- TODO max
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{"InvisibilityRemaining", {8}, MemoryManipulation.DataType.Int, function(a) return a>=0 end}, -- TODO max
		},
	},
}

for _,of in pairs(MemoryManipulation.ObjFieldInfo) do
	if of.inheritsFrom then
		for _,c in ipairs(of.inheritsFrom) do
			for _,f in ipairs(MemoryManipulation.ObjFieldInfo[c].fields) do
				table.insert(of.fields, f)
			end
		end
	end
end
