if mcbPacker then --mcbPacker.ignore
	mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore

EntityCategories.TargetFilter_TargetType = 100
EntityCategories.TargetFilter_TargetTypeLeader = 101
EntityCategories.TargetFilter_CustomRanged = 102
EntityCategories.TargetFilter_NonCombat = 103

--- author:mcb		current maintainer:mcb		v0.1b
-- Filtert entities nach passenden zielen für angriffe.
-- 
-- TargetFilter.EntityTypeArray							Liste aller validen entitytypen, zur nutzung mit PredicateHelper.
-- TargetFilter.IsValidTarget(id, enemypl, aiactive)	Prüft ein entity, enemypl und aiactive werden nur ohne hook verwendet und verbessern unsichtbarkeits erkennung.
-- 
-- Benötigt:
-- - CppLogic (optional, verbessert unsichtbarkeits erkennung)
TargetFilter = {EntityTypeArray={}}
TargetFilter.IgnoreEtypes = {
	[Entities.PU_Hero1_Hawk] = true,
	[Entities.PB_Tower2_Ballista] = true,
	[Entities.PB_Tower3_Cannon] = true,
	[Entities.PB_DarkTower2_Ballista] = true,
	[Entities.PB_DarkTower3_Cannon] = true,
	[Entities.PU_Hero2_Cannon1] = true,
	[Entities.PU_Hero3_Trap] = true,
	[Entities.PU_Hero3_TrapCannon] = true,
}
TargetFilter.LeaderTypeArray = {
	Entities.CU_BlackKnight,
	Entities.CU_Mary_de_Mortfichet,
	Entities.PU_Serf,
	Entities.PU_BattleSerf,
}
TargetFilter.IgnoreELeaderTypes = {
	[Entities.PU_Hero2_Foundation1] = true,
	[Entities.PU_Hero3_Trap] = true,
}

if Entities.CB_Evil_Tower1_ArrowLauncher then
	TargetFilter.IgnoreEtypes[Entities.CB_Evil_Tower1_ArrowLauncher] = true
	table.insert(TargetFilter.LeaderTypeArray, Entities.CU_Evil_Queen)
	table.insert(TargetFilter.LeaderTypeArray, Entities.PU_Thief)
end

AddMapStartCallback(function()
	local skipCpp = false
	if not CppLogic then
		skipCpp = true
	elseif Logic.IsEntityTypeInCategory(Entities.PU_Hero2, EntityCategories.TargetFilter_TargetType)==1 then
		skipCpp = true
	end
	
	for en, e in pairs(Entities) do
		if (string.find(en, "[PC][UBV]") or string.find(en, "XD_[Dark]*Wall.*")) and not TargetFilter.IgnoreEtypes[e] then
			table.insert(TargetFilter.EntityTypeArray, e)
			if not skipCpp then
				CppLogic.EntityType.AddEntityCategory(e, EntityCategories.TargetFilter_TargetType)
			end
		end
		if string.find(en, "[PC][UV]") and (string.find(en, "Leader") or string.find(en, "Hero") or string.find(en, "Cannon"))
		and not TargetFilter.IgnoreEtypes[e] and not TargetFilter.IgnoreELeaderTypes[e] then
			table.insert(TargetFilter.LeaderTypeArray, e)
			if not skipCpp then
				CppLogic.EntityType.AddEntityCategory(e, EntityCategories.TargetFilter_TargetTypeLeader)
			end
		end
	end

	if skipCpp then
		return
	end
	for nam, id in pairs(TaskLists) do
		if (string.sub(nam, -5, -1)=="_IDLE") then
			CppLogic.UA.AddIdleTaskList(id)
		end
	end

	for _, ty in ipairs{Entities.PU_Hero5, Entities.PU_Hero10, Entities.CU_BanditLeaderBow1, Entities.CU_Evil_LeaderSkirmisher1} do
		if ty  then
			CppLogic.EntityType.AddEntityCategory(ty, EntityCategories.TargetFilter_CustomRanged)
		end
	end
	for _, ty in ipairs{Entities.PU_Thief, Entities.PU_Scout} do
		if ty  then
			CppLogic.EntityType.AddEntityCategory(ty, EntityCategories.TargetFilter_NonCombat)
		end
	end
end)

function TargetFilter.IsValidTarget(id, enemypl, aiactive)
	if IsDead(id) then
		return false
	end
	if CppLogic then
		if not CppLogic.Entity.Settler.IsVisible(id) then
			return false
		end
	else
		if TargetFilter.NoHookCheckInvisibility(id, enemypl, aiactive) then
			return false
		end
	end
	if TargetFilter.IgnoreEtypes[Logic.GetEntityType(id)] then
		return false
	end
	if Logic.IsWorker(id)==1 then
		if Logic.IsSettlerAtWork(id)==1 then
			return false, Logic.GetSettlersWorkBuilding(id)
		end
		if Logic.IsSettlerAtFarm(id)==1 then
			return false, Logic.GetSettlersFarm(id)
		end
		if Logic.IsSettlerAtResidence(id)==1 then
			return false, Logic.GetSettlersResidence(id)
		end
	end
	return true
end

function TargetFilter.NoHookCheckInvisibility(id, enemypl, aiactive)
	local ety = Logic.GetEntityType(id)
	if not (ety==Entities.PU_Hero5 or ety==Entities.PU_Thief) then -- assume just ari and thieves are invisible
		return false
	end
	local p = GetPosition(id)
	local eid = AI.Army_SearchClosestEnemy(enemypl, 0, p.X, p.Y, 500)
	if eid==id then
		return false
	end
	if aiactive then
		return true
	end
	if ety==Entities.PU_Hero5 then
		if Logic.HeroGetAbiltityChargeSeconds(id, Abilities.AbilityCamouflage) < Logic.HeroGetAbilityRechargeTime(id, Abilities.AbilityCamouflage)/2 then
			return true -- might be some false positive, but nothing better possible
		end
	elseif ety==Entities.PU_Thief then
		return true -- just assume thieves are invisible
	end
end
