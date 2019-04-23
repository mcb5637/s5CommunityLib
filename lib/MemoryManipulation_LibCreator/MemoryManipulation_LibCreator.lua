local MemoryManipulation_LibCreator = {}
MemoryManipulation_LibCreator.LibFuncBase = {Entity=1, EntityType=2}

MemoryManipulation_LibCreator.LibFuncDesc = {
	LeaderExperience = {base=MemoryManipulation_LibCreator.LibFuncBase.Entity, path='"BehaviorList.GGL_CLeaderBehavior.Experience"', check="\tassert(Logic.IsLeader(id)==1)\n"},
	LeaderTroopHealth = {base=MemoryManipulation_LibCreator.LibFuncBase.Entity, path='"BehaviorList.GGL_CLeaderBehavior.TroopHealthCurrent"', check="\tassert(Logic.IsLeader(id)==1)\n"},
	SettlerMovementSpeed = {base=MemoryManipulation_LibCreator.LibFuncBase.Entity, path='{"BehaviorList.GGL_CLeaderMovement.MovementSpeed", "BehaviorList.GGL_CSettlerMovement.MovementSpeed", "BehaviorList.GGL_CSoldierMovement.MovementSpeed"}', check="\tassert(Logic.IsSettler(id)==1)\n"},
	SettlerRotationSpeed = {base=MemoryManipulation_LibCreator.LibFuncBase.Entity, path='{"BehaviorList.GGL_CLeaderMovement.TurningSpeed", "BehaviorList.GGL_CSettlerMovement.TurningSpeed", "BehaviorList.GGL_CSoldierMovement.TurningSpeed"}', check="\tassert(Logic.IsSettler(id)==1)\n"},
	LeaderOfSoldier = {base=MemoryManipulation_LibCreator.LibFuncBase.Entity, path='"LeaderId"', check="\tassert(MemoryManipulation.IsSoldier(id))\n", noSet=true},
	MovementCheckBlockingFlag = {base=MemoryManipulation_LibCreator.LibFuncBase.Entity, path='"BehaviorList.GGL_CSettlerMovement.BlockingFlag"', check="\tassert(Logic.IsSettler(id)==1)\n"},
	BarracksAutoFillActive = {base=MemoryManipulation_LibCreator.LibFuncBase.Entity, path='"BehaviorList.GGL_CBarrackBehavior.AutoFillActive"', check="\tassert(Logic.IsBuilding(id)==1)\n", noSet=true},
	SoldierTypeOfLeaderType = {base=MemoryManipulation_LibCreator.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CLeaderBehaviorProps.SoldierType"'},
}

function MemoryManipulation_LibCreator.CreateLibFuncs()
	local out = io.open("./src/s5CommunityLib/lib/MemoryManipulation_LibCreator/created.lua", "w+")
	out:write("-- do not commit this file, its contents should be pasted into MemoryManipulation\n\n")
	for name, desc in pairs(MemoryManipulation_LibCreator.LibFuncDesc) do
		if desc.base==MemoryManipulation_LibCreator.LibFuncBase.Entity then
			if not desc.noGet then
				out:write("function MemoryManipulation.Get"..name.."(id)\n"..(desc.check or "").."\treturn MemoryManipulation.GetSingleValue(id, "..desc.path..")\nend\n")
			end
			if not desc.noSet then
				out:write("function MemoryManipulation.Set"..name.."(id, val)\n"..(desc.check or "").."\tMemoryManipulation.SetSingleValue(id, "..desc.path..", val)\nend\n")
			end
		elseif desc.base==MemoryManipulation_LibCreator.LibFuncBase.EntityType then
			if not desc.noGet then
				out:write("function MemoryManipulation.Get"..name.."(typ)\n"..(desc.check or "").."\treturn MemoryManipulation.GetSingleValue(MemoryManipulation.GetETypePointer(typ), "..desc.path..")\nend\n")
			end
			if not desc.noSet then
				out:write("function MemoryManipulation.Set"..name.."(typ, val)\n"..(desc.check or "").."\tMemoryManipulation.SetSingleValue(MemoryManipulation.GetETypePointer(typ), "..desc.path..", val)\nend\n")
			end
		end
	end
	out:close()
end

MemoryManipulation_LibCreator.CreateLibFuncs()
