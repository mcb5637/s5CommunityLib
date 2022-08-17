---
--- Returns true, if the entity has one of the passed entity types.
---
--- @param _Entity string|number Scriptname or ID
--- @param ...     number        List of types
--- @return boolean HasType Has one type
--- @author totalwarANGEL
function HasOneOfTypes(_Entity, ...)
    for k, v in pairs(arg) do
        if Logic.GetEntityType(GetID(_Entity)) == v then
            return true;
        end
    end
    return false;
end