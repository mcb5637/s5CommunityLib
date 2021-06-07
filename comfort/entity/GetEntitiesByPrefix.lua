--- author:???		current maintainer:totalwarANGEL		v1
--
-- sucht alle entities mit einem scriptnemen vom muster _Prefix..X, wobei X eine fortlaufende zahl ist.
--
--- @return table ids
function GetEntitiesByPrefix(_Prefix)
    local list = {};
    local i = 1;
    local bFound = true;
    while (bFound) do
        local entity = GetID(_Prefix ..i);
        if entity ~= 0 then
            table.insert(list, entity);
        else
            bFound = false;
        end
        i = i + 1;
    end
    return list;
end