if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v0.1b
-- Filtert entities nach passenden zielen für angriffe.
-- 
-- TargetFilter.EntityTypeArray							Liste aller validen entitytypen, zur nutzung mit PredicateHelper.
-- TargetFilter.IsValidTarget(id, enemypl, aiactive)	Prüft ein entity, enemypl und aiactive werden nur ohne hook verwendet und verbessern unsichtbarkeits erkennung.
-- 
-- Benötigt:
-- - S5Hook / MemoryManipulation (optional, verbessert unsichtbarkeits erkennung)
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
if Entities.CB_Evil_Tower1_ArrowLauncher then
	TargetFilter.IgnoreEtypes[Entities.CB_Evil_Tower1_ArrowLauncher] = true
end


for en, e in pairs(Entities) do
	if string.find(en, "[PC][UBV]") and not TargetFilter.IgnoreEtypes[e] then
		table.insert(TargetFilter.EntityTypeArray, e)
	end
end

function TargetFilter.IsValidTarget(id, enemypl, aiactive)
	if IsDead(id) then
		return false
	end
	if MemoryManipulation then
		if MemoryManipulation.IsEntityInvisible(id) then
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
