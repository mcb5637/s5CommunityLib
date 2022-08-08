---
--- Returns true, if the entity has one of the passed entity types.
---
--- @param _Entity string|number Scriptname or ID
--- @param ...     number        List of categories
--- @return boolean HasType Has one category
--- @author totalwarANGEL
function HasOneOfCategories(_Entity, ...)
    for k, v in pairs(arg) do
        if Logic.IsEntityInCategory(GetID(_Entity), v) == 1 then
            return true;
        end
    end
    return false;
end