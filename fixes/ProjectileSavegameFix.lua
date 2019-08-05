if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
mcbPacker.require("s5CommunityLib/fixes/mcbTriggerExtHurtEntity")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
end --mcbPacker.ignore



ProjectileSavegameFix = {idToSaveData={}, data2={}}

function ProjectileSavegameFix.PreSavegameCreated()
	ProjectileSavegameFix.idToSaveData = {}
	for id,_ in pairs(mcbTriggerExtHurtEntity.projectiles) do
		local t = {
			TargetPosition = true,
			NextPosition = true,
			StrangeFloat = true,
			--SourcePlayer = true,
		}
		MemoryManipulation.ReadObj(S5Hook.GetEffectMem(id), t, nil, t)
		ProjectileSavegameFix.idToSaveData[id] = t
		ProjectileSavegameFix.data2[id] = {}
		local sv = S5Hook.GetEffectMem(id)
		for i=1,53 do
			ProjectileSavegameFix.data2[id][i] = sv[i]:GetInt()
		end
	end
end

function ProjectileSavegameFix.AfterSavegameLoaded()
	local analyzeEffectResult = ""
	for id,t in pairs(ProjectileSavegameFix.idToSaveData) do
		MemoryManipulation.WriteObj(S5Hook.GetEffectMem(id), t, nil, false)
		local sv = S5Hook.GetEffectMem(id)
		for i=1,53 do
			if ProjectileSavegameFix.data2[id][i] ~= sv[i]:GetInt() then
				analyzeEffectResult = analyzeEffectResult..("at: "..i.." "..ProjectileSavegameFix.data2[id][i].." -> "..sv[i]:GetInt()).."\n"
			end
		end
	end
	S5Hook.Log(analyzeEffectResult)
	--ProjectileSavegameFix.idToSaveData = {}
end

function ProjectileSavegameFix.Init()
	table.insert(framework2.save.preSaveCallback, ProjectileSavegameFix.PreSavegameCreated)
	ProjectileSavegameFix.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
	function Mission_OnSaveGameLoaded()
		ProjectileSavegameFix.Mission_OnSaveGameLoaded()
		ProjectileSavegameFix.AfterSavegameLoaded()
	end
end
