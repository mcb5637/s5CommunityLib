if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1.0
-- Kleinere Funktionen, um EntityIterator Predicate zu erstellen.
-- - PredicateHelper.GetETypePredicate(tab)				Erstellt ein Predicate.OfAnyType aus dem array tab (in tab.predicate cached).
-- - PredicateHelper.GetEnemyPlayerPredicate(pl)		Erstellt ein Predicate.OfAnyPlayer aller player die zu pl feindlich sind.
-- - PredicateHelper.GetFriendlyPlayerPredicate(pl)		Erstellt ein Predicate.OfAnyPlayer aller player die zu pl freundlich sind (pl inklusive).
-- 
-- Benötigt:
-- - S5Hook
PredicateHelper = {}
function PredicateHelper.GetETypePredicate(tab)
	if tab.predicate then
		return tab.predicate
	end
	tab.predicate = Predicate.OfAnyType(unpack(tab))
	return tab.predicate
end

function PredicateHelper.GetEnemyPlayerPredicate(pl)
	local p = {}
	for i=1,8 do
		if Logic.GetDiplomacyState(pl, i)==Diplomacy.Hostile then
			table.insert(p, i)
		end
	end
	--LuaDebugger.Break()
	return Predicate.OfAnyPlayer(unpack(p))
end

function PredicateHelper.GetFriendlyPlayerPredicate(pl)
	local p = {pl}
	for i=1,8 do
		if Logic.GetDiplomacyState(pl, i)==Diplomacy.Friendly then
			table.insert(p, i)
		end
	end
	--LuaDebugger.Break()
	return Predicate.OfAnyPlayer(unpack(p))
end
