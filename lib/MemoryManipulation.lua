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
--MemoryManipulation.GetSingleValue(132339, "BehaviorList.GGL_CLimitedAttachmentBehavior.MaxAttachment")
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
				val = MemoryManipulation.ReadObj(sv2[0], objInfo[fi.name], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name])
			elseif fi.datatype==MemoryManipulation.DataType.ObjectList then
				val = objInfo[fi.name] or {}
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					if sv3[0]:GetInt()>0 then
						local vt = sv3[0][0]:GetInt()
						local vtn = MemoryManipulation.VTableNames[vt]
						--LuaDebugger.Log(vt..(IstDrin(vt, MemoryManipulation.ClassVTable) or "nil"))
						if (not readFilter or readFilter[fi.name][vtn]~=nil) and MemoryManipulation.ObjFieldInfo[vt] then
							val[vtn] = MemoryManipulation.ReadObj(sv3[0], val[vtn], nil, readFilter and readFilter[fi.name][vtn])
							objInfo[fi.name] = val
						end
					end
				end
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObject then
				val = MemoryManipulation.ReadObj(sv2, objInfo[fi.name], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name])
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
				MemoryManipulation.WriteObj(sv2[0], val, MemoryManipulation.ObjFieldInfo[fi.vtableOverride])
			elseif fi.datatype==MemoryManipulation.DataType.ObjectList then
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

function MemoryManipulation.GetETypePointer(ety)
	return S5Hook.GetRawMem(9002416)[0][16]:Offset(ety*8)
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
	
	EGL_CGLEEntityProps = tonumber("76E47C", 16),
	GGL_CEntityProperties = tonumber("776FEC", 16),
	GGL_CGLAnimalProps = tonumber("779074", 16),
	GGL_CBuildBlockProperties = tonumber("76EB38", 16),
	GGL_CResourceDoodadProperties = tonumber("76FF68", 16),
	
	GGlue_CGlueEntityProps = tonumber("788824", 16),
}
MemoryManipulation.VTableNames = {}
for k,v in pairs(MemoryManipulation.ClassVTable) do
	MemoryManipulation.VTableNames[v] = k
end
MemoryManipulation.DataType= {Int=1, Float=2, ObjectPointer=3, ObjectList=4, Bit=5, List=6, EmbeddedObject=7}
MemoryManipulation.ObjFieldInfo = {
	Position = {
		hasNoVTable = true,
		fields = {
			{name="X", index={0}, datatype=MemoryManipulation.DataType.Float},
			{name="Y", index={1}, datatype=MemoryManipulation.DataType.Float},
		}
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderBehavior,
		fields = {
			{name="TroopHealthCurrent", index={27}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TroopHealthPerSoldier", index={28}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Experience", index={32}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettler] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettler,
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="Scale", index={25}, datatype=MemoryManipulation.DataType.Float},
			{name="BehaviorList", index={31}, datatype=MemoryManipulation.DataType.ObjectList},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior,
		fields = {
			{name="MaxAttachment", index={6,0,4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement,
		fields = {
			{name="MovementSpeed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TurningSpeed", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end, readConv=math.deg, writeConv=math.rad},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettlerMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettlerMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
			{name="BlockingFlag", index={15}, datatype=MemoryManipulation.DataType.Int, check={1,0}},
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
			{name="AbilitySecondsCharged", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end}, -- TODO max
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="InvisibilityRemaining", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end}, -- TODO max
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CGLEEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEEntityProps,
		fields = {
			{name="Class", index={2}, datatype=nil},
			{name="Categories", index={3}, datatype=MemoryManipulation.DataType.List},
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
			{name="Models", index={14}, datatype=nil},
			{name="Exploration", index={19}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ExperiencePoints", index={20}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AccessCategory", index={21}, datatype=nil},
			{name="NumBlockedPoints", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SnapTolerance", index={23}, datatype=MemoryManipulation.DataType.Float},
			{name="DeleteWhenBuiltOn", index={24}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="NeedsPlayer", index={24}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="BlockingArea", index={34}, datatype=nil},
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
			{name="ModifyExploration", index={86}, datatype=nil},
			{name="ModifyHitpoints", index={91}, datatype=nil},
			{name="ModifySpeed", index={96}, datatype=nil},
			{name="ModifyDamage", index={101}, datatype=nil},
			{name="ModifyArmor", index={106}, datatype=nil},
			{name="ModifyDodge", index={111}, datatype=nil},
			{name="ModifyMaxRange", index={116}, datatype=nil},
			{name="ModifyMinRange", index={121}, datatype=nil},
			{name="ModifyDamageBonus", index={126}, datatype=nil},
			{name="ModifyGroupLimit", index={131}, datatype=nil},
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
	[MemoryManipulation.ClassVTable.GGlue_CGlueEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGlue_CGlueEntityProps,
		fields = {
			{name="LogicProbs", index={2}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="DisplayProbs", index={3}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="BehaviorProbs", index={5}, datatype=MemoryManipulation.DataType.ObjectList},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceDoodadProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceDoodadProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties},
		fields = {
			{name="Radius", index={42}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Center", index={43}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="Model1", index={50}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model2", index={51}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="LineStart", index={45}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LineEnd", index={47}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ExtractTaskList", index={49}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBuildingProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBuildingProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties},
		fields = {
			{name="CanBeSold", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="HideBase", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="IsWall", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="Convertible", index={113}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="UpgradeSite", index={101}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="Upgrade", index={80}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="upgradeInfo"},
			{name="ArmorClass", index={102}, datatype=MemoryManipulation.DataType.Int, check=ArmorClasses},
			{name="ConstructionInfo", index={50}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="constructionInfo"},
			{name="LeavePos", index={48}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="DoorPos", index={46}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ModifyArmor", index={118}, datatype=nil},
			{name="ModifyExploration", index={114}, datatype=nil},
			{name="BuildOn", index={75}, datatype=nil},
			{name="MilitaryInfo", index={108}, datatype=nil},
			{name="WorkTaskList", index={104}, datatype=nil},
			{name="NumberOfAttractableSettlers", index={44}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ArmorAmount", index={103}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Worker", index={45}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="KegEffectFactor", index={124}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="CollapseTime", index={112}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MaxWorkers", index={42}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="InitialMaxWorkers", index={43}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBridgeProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBridgeProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CGLBuildingProps},
		fields = {
			{name="BridgeArea", index={125}, datatype=nil},
			{name="Height", index={129}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ConstructionModel0", index={130}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="ConstructionModel1", index={131}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="ConstructionModel2", index={132}, datatype=MemoryManipulation.DataType.Int, check=Models},
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
			{name="BuilderSlot", index={1}, datatype=nil},
			{name="Time", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Cost", index={6}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="ConstructionSite", index={24}, datatype=MemoryManipulation.DataType.Int, check=Entities},
		}
	},
}

do
	local function applyInheritance(of)
		if of.inheritsFrom and not of.inheritanceDone then
			for _,c in ipairs(of.inheritsFrom) do
				applyInheritance(MemoryManipulation.ObjFieldInfo[c].fields)
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
