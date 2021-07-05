
--- author:fritz_98		current maintainer:fritz_98		v1.0
-- gibt einen iterator zurück, der über ein table der form {anzahl, id1, id2...} iteriert.
-- nutzt upvalues intern, iterator func nicht speichern
EntityList = function (_Table)
    local Index = 1
    local Count = _Table[1] + 1

    return function()
        Index = Index + 1
        if Index <= Count then
            return _Table[Index]
        end
    end
end
