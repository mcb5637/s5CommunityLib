if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/MPSyncer")
end --mcbPacker.ignore


--- author:mcb		current maintainer:mcb		v3.2
-- Debugging hilfe, niemals im release verwenden!
-- - MPSyncer_Debug_CreateEval()							fügt die vfunc hinzu
-- - MPSyncer.ExecuteSynced("Eval", "Message('test'")		eval + execute synchron
function MPSyncer_Debug_CreateEval()
	MPSyncer.VirtualFuncs.Create(function(s)
		CppLogic.API.Eval(s)()
	end, "Eval", {pattern = "\"(.*)\"",		-- . is greedy, takes as much as possible.
		serialize = function(s)
			return '"'..s..'"'
		end, deserialize = function(s)
			return s
		end
	})
end
