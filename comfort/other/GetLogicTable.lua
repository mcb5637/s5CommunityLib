--- author:totalwarANGEL		current maintainer:totalwarANGEL		v1
--
--- @return table cost
function GetBuildingCostsTable(_EntityType)
    local BuildingCosts = {};
    Logic.FillBuildingCostsTable(_EntityType, BuildingCosts);
    return BuildingCosts;
end

--- author:totalwarANGEL		current maintainer:totalwarANGEL		v1
--
--- @return table cost
function GetBuildingUpgradeCostsTable(_EntityType)
    local BuildingUpgradeCosts = {};
    Logic.FillBuildingUpgradeCostsTable(_EntityType, BuildingUpgradeCosts);
    return BuildingUpgradeCosts;
end

--- author:totalwarANGEL		current maintainer:totalwarANGEL		v1
--
--- @return table cost
function GetTechnologyCostsTable(_Technology)
    local TechnologyCosts = {};
    Logic.FillTechnologyCostsTable(_Technology, TechnologyCosts);
    return TechnologyCosts;
end

--- author:totalwarANGEL		current maintainer:totalwarANGEL		v1
--
--- @return table cost
function GetSoldierCostsTable(_PlayerID, _SoldierUpCat)
    local SoldierCosts = {};
    Logic.FillSoldierCostsTable(_PlayerID, _SoldierUpCat, SoldierCosts);
    return SoldierCosts;
end

--- author:totalwarANGEL		current maintainer:totalwarANGEL		v1
--
--- @return table cost
function GetMilitaryCostsTable(_PlayerID, _LeaderUpCat)
    local MilitaryCosts = {};
    Logic.FillLeaderCostsTable(_PlayerID, _LeaderUpCat, MilitaryCosts);
    return MilitaryCosts;
end