--- author:totalwarANGEL		current maintainer:totalwarANGEL		v1
--
-- testet, ob ein gebäude gerade ausgebaut wird.
--
--- @return boolean
function IsBuildingBeingUpgraded(_Entity)
    local BuildingID = GetID(_Entity);
    if Logic.IsBuilding(BuildingID) == 0 then
        return false;
    end
    local Value = Logic.GetRemainingUpgradeTimeForBuilding(BuildingID);
    local Limit = Logic.GetTotalUpgradeTimeForBuilding(BuildingID);
    return Limit - Value > 0;
end