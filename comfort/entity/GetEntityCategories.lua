--- author:totalwarANGEL		current maintainer:totalwarANGEL		v1
--
-- gibt alle EntityCategories eines entitys zurück.
--
--- @return table categories
function GetEntityCategories(_Entity)
    local Categories = {};
    for k, v in pairs(EntityCategories) do
        if Logic.IsEntityInCategory(GetID(_Entity), v) == 1 then
            table.insert(Categories, v);
        end
    end
    return Categories;
end