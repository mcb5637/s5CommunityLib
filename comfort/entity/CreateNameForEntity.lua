---
--- Returns the script name of the entity.
---
--- If the entity do not have a name a unique ongoing name is added to the
--- entity and returned.
--- @param _eID number EntityID
--- @return string Name Script name
--- @author totalwarANGEL
function CreateNameForEntity(_eID)
    if type(_eID) == "string" then
        return _eID;
    else
        assert(type(_eID) == "number");
        local name = Logic.GetEntityName(_eID);
        if (type(name) ~= "string" or name == "" ) then
            gvEntityNameCounter = (gvEntityNameCounter or 0) +1;
            name = "eName_"..gvEntityNameCounter;
            Logic.SetEntityName(_eID,name);
        end
        return name;
    end
end