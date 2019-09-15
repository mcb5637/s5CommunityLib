if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
mcbPacker.require("lib/mcbBrief")
mcbPacker.require("s5CommunityLib/tables/TechState")
end --mcbPacker.ignore



TechStatusHelper = {}

TechStatusHelper.techStatusToColorTable = {
	[TechState.allowed] = " @color:blau ",
	[TechState.forbidden] = " @color:rot ",
	[TechState.future] = " @color:gelb ",
	[TechState.inProgress] = " @color:blau ",
	[TechState.researched] = " @color:gruen ",
	[TechState.waiting] = " @color:gelb ",
}

TechStatusHelper.reverseRequirementCache = nil

function TechStatusHelper.RebuildRequirementCache()
	TechStatusHelper.reverseRequirementCache = {}
	for _, t in pairs(Technologies) do
		local tdata = MemoryManipulation.ReadObj(MemoryManipulation.GetTechnologyPointer(t), nil, MemoryManipulation.ObjFieldInfo.Technology, {
			TecConditions = true,
		})
		for _,tre in ipairs(tdata.TecConditions) do
			if not TechStatusHelper.reverseRequirementCache[tre.TecType] then
				TechStatusHelper.reverseRequirementCache[tre.TecType] = {}
			end
			table.insert(TechStatusHelper.reverseRequirementCache[tre.TecType], t)
		end
	end
end

function TechStatusHelper.GetTechName(t)
	return " @stt:names/"..KeyOf(t, Technologies).." "
end

function TechStatusHelper.GetColoredTechName(t, p)
	local state = Logic.GetTechnologyState(p, t)
	return TechStatusHelper.techStatusToColorTable[state]..TechStatusHelper.GetTechName(t)
end

function TechStatusHelper.GetColoredEntityTypeName(ety, am, pl)
	local num = Logic.GetNumberOfEntitiesOfTypeOfPlayer(pl, ety)
	local r = " @color:gruen "
	if num<am then
		r = " @color:gelb "
	end
	r = r..am.." @stt:names/"..Logic.GetEntityTypeName(ety).." "
	return r
end

function TechStatusHelper.GetTechnologyDescStrings(t, p)
	local title = " @color:tit "..TechStatusHelper.GetTechName(t).." @color:weis "
	local requires = " @color:req benötigt: @color:weis "
	local requiredfor = " @color:req ermöglicht: @color:weis "
	local tdata = MemoryManipulation.ReadObj(MemoryManipulation.GetTechnologyPointer(t), nil, MemoryManipulation.ObjFieldInfo.Technology, {
		RequiredTecConditions = true,
		TecConditions = true,
		RequiredEntityConditions = true,
		EntityConditions = true,
	})
	if tdata.RequiredTecConditions > 0 then
		requires = requires..tdata.RequiredTecConditions.." von ( "
	end
	for _,tre in ipairs(tdata.TecConditions) do
		requires = requires..TechStatusHelper.GetColoredTechName(tre.TecType, p)
	end
	if tdata.RequiredTecConditions > 0 then
		requires = requires.." @color:weis ) "
	end
	if tdata.RequiredEntityConditions > 0 then
		requires = requires.." @color:weis "..tdata.RequiredEntityConditions.." von ( "
	end
	for _,tre in ipairs(tdata.EntityConditions) do
		requires = requires..TechStatusHelper.GetColoredEntityTypeName(tre.EntityType, tre.Amount, p)
	end
	if tdata.RequiredEntityConditions > 0 then
		requires = requires.." @color:weis ) "
	end
	if not TechStatusHelper.reverseRequirementCache then
		TechStatusHelper.RebuildRequirementCache()
	end
	tdata = TechStatusHelper.reverseRequirementCache[t] or {}
	for _,tre in ipairs(tdata) do
		requiredfor = requiredfor..TechStatusHelper.GetColoredTechName(tre, p)
	end
	return title, requires, requiredfor
end

function TechStatusHelper.GetTechTooltip(t, p)
	local title, requires, requiredfor = TechStatusHelper.GetTechnologyDescStrings(t, p or GUI.GetPlayerID())
	local s = title.." @cr "..requires.." @cr "..requiredfor
	return s
end
--TechStatusHelper.GetEntityTypeTechBoni(Entities.PU_LeaderBow1, "ModifyDamage", bonusKey)
function TechStatusHelper.GetEntityTypeTechBoni(ety, techListKey, bonusKey)
	
end
