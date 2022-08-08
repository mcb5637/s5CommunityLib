---
--- Returns true if the player has enough resources.
---
--- Compatible with the original resource notation.
--- @param _PlayerID number ID of player
--- @param _Costs    table  Costs table
--- @return boolean HasEnough Enough resources
--- @author totalwarANGEL
function HasEnoughResources(_PlayerID, _Costs)
	local Gold   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Gold ) + Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.GoldRaw);
    local Clay   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Clay ) + Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.ClayRaw);
	local Wood   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Wood ) + Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.WoodRaw);
	local Iron   = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Iron ) + Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.IronRaw);
	local Stone  = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Stone ) + Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.StoneRaw);
    local Sulfur = Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.Sulfur ) + Logic.GetPlayersGlobalResource(_PlayerID, ResourceType.SulfurRaw);

	if _Costs[ResourceType.Gold] ~= nil and Gold < _Costs[ResourceType.Gold] then
		return false;
    end
	if _Costs[ResourceType.Clay] ~= nil and Clay < _Costs[ResourceType.Clay]  then
		return false;
	end
	if _Costs[ResourceType.Wood] ~= nil and Wood < _Costs[ResourceType.Wood]  then
		return false;
	end
	if _Costs[ResourceType.Iron] ~= nil and Iron < _Costs[ResourceType.Iron] then
		return false;
	end
	if _Costs[ResourceType.Stone] ~= nil and Stone < _Costs[ResourceType.Stone] then
		return false;
	end
    if _Costs[ResourceType.Sulfur] ~= nil and Sulfur < _Costs[ResourceType.Sulfur] then
		return false;
	end
    return true;
end