if mcbPacker then --mcbPacker.ignore
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1.0
-- Kleinere Funktionen, um EntityIterator Predicate zu erstellen.
-- - PredicateHelper.GetETypePredicate(tab)				Erstellt ein Predicate.OfAnyType aus dem array tab (in tab.predicate cached).
-- - PredicateHelper.GetEnemyPlayerPredicate(pl)		Erstellt ein Predicate.OfAnyPlayer aller player die zu pl feindlich sind.
-- - PredicateHelper.GetFriendlyPlayerPredicate(pl)		Erstellt ein Predicate.OfAnyPlayer aller player die zu pl freundlich sind (pl inklusive).
-- 
-- Benötigt:
-- - CppLogic
PredicateHelper = {}
function PredicateHelper.GetETypePredicate(tab)
	if tab.predicate then
		return tab.predicate
	end
	tab.predicate = CppLogic.Entity.Predicates.OfAnyEntityType(unpack(tab))
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
	return CppLogic.Entity.Predicates.OfAnyPlayer(unpack(p))
end

function PredicateHelper.GetFriendlyPlayerPredicate(pl)
	local p = {pl}
	for i=1,8 do
		if Logic.GetDiplomacyState(pl, i)==Diplomacy.Friendly then
			table.insert(p, i)
		end
	end
	--LuaDebugger.Break()
	return CppLogic.Entity.Predicates.OfAnyPlayer(unpack(p))
end
