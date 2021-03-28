if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
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
		local _,_,_, tdata = CppLogic.Technology.GetRequirements(t)
		for _,tre in ipairs(tdata.TecConditions) do
			if not TechStatusHelper.reverseRequirementCache[tre] then
				TechStatusHelper.reverseRequirementCache[tre] = {}
			end
			table.insert(TechStatusHelper.reverseRequirementCache[tre], t)
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

function TechStatusHelper.GetColoredUpgradeCategoryTypeName(ucat, am, pl)
	local num = CppLogic.Entity.EntityIteratorCount(CppLogic.Entity.OfPlayer(pl), CppLogic.Entity.Predicates.OfUpgradeCategory(ucat))
	local r = " @color:gruen "
	if num<am then
		r = " @color:gelb "
	end
	r = r..am.." @stt:names/"..Logic.GetEntityTypeName(Logic.GetBuildingTypeByUpgradeCategory(ucat, pl)).." "
	return r
end

function TechStatusHelper.GetTechnologyDescStrings(t, p)
	local title = " @color:tit "..TechStatusHelper.GetTechName(t).." @color:weis "
	local requires = " @color:req benötigt: @color:weis "
	local requiredfor = " @color:req ermöglicht: @color:weis "
	local nent, ent, ntech, tech, nucat, ucat = CppLogic.Technology.GetRequirements(t)
	if ntech > 0 then
		requires = requires..ntech.." von ( "
	end
	for _,tre in ipairs(tech) do
		requires = requires..TechStatusHelper.GetColoredTechName(tre, p)
	end
	if ntech > 0 then
		requires = requires.." @color:weis ) "
	end
	if nent > 0 then
		requires = requires.." @color:weis "..nent.." von ( "
	end
	for et,am in pairs(ent) do
		requires = requires..TechStatusHelper.GetColoredEntityTypeName(et, am, p)
	end
	if nent > 0 then
		requires = requires.." @color:weis ) "
	end
	if nucat > 0 then
		requires = requires.." @color:weis "..nucat.." von ( "
	end
	for uc,am in pairs(ucat) do
		requires = requires..TechStatusHelper.GetColoredUpgradeCategoryTypeName(uc, am, p)
	end
	if nucat > 0 then
		requires = requires.." @color:weis ) "
	end
	if not TechStatusHelper.reverseRequirementCache then
		TechStatusHelper.RebuildRequirementCache()
	end
	local tdata = TechStatusHelper.reverseRequirementCache[t] or {}
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
--TechStatusHelper.GetEntityTypeTechBoni(Entities.PU_LeaderBow1, 1, "ModifyDamage", "DamageModifier")
function TechStatusHelper.GetEntityTypeTechBoni(ety, player, techList, bonus)
	local s = ""
	for _,t in pairs(techList) do
		local op, val = bonus(t)
		s = s..TechStatusHelper.GetColoredTechName(t, player).." @color:255,255,255 "..string.char(op).." "..val.." @cr "
	end
	return s
end

function TechStatusHelper.GetEntityTypeDamageTechBoni(ety, player)
	return TechStatusHelper.GetEntityTypeTechBoni(ety, player, CppLogic.EntityType.Settler.GetDamageModifierTechs(ety), CppLogic.Technology.GetDamageModifier)
end

function TechStatusHelper.GetEntityTypeArmorTechBoni(ety, player)
	return TechStatusHelper.GetEntityTypeTechBoni(ety, player, CppLogic.EntityType.GetArmorModifierTechs(ety), CppLogic.Technology.GetArmorModifier)
end

function TechStatusHelper.GetEntityTypeRangeTechBoni(ety, player)
	return TechStatusHelper.GetEntityTypeTechBoni(ety, player, CppLogic.EntityType.Settler.GetMaxRangeModifierTechs(ety), CppLogic.Technology.GetRangeModifier)
end

function TechStatusHelper.GetEntityTypeExplorationTechBoni(ety, player)
	return TechStatusHelper.GetEntityTypeTechBoni(ety, player, CppLogic.EntityType.GetExplorationModifierTechs(ety), CppLogic.Technology.GetExplorationModifier)
end

function TechStatusHelper.GetEntityTypeSpeedTechBoni(ety, player)
	return TechStatusHelper.GetEntityTypeTechBoni(ety, player, CppLogic.EntityType.Settler.GetSpeedModifierTechs(ety), CppLogic.Technology.GetSpeedModifier)
end
