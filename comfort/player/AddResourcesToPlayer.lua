---
--- Adds resources to the player by the given resource table.
---
--- Compatible with the original resource notation.
--- @param _PlayerID  number ID of player
--- @param _Resources table  Resource table
--- @author totalwarANGEL
function AddResourcesToPlayer(_PlayerID, _Resources)
    if _Resources[ResourceType.Gold] ~= nil then
		AddGold(_PlayerID, _Resources[ResourceType.Gold] or _Resources[ResourceType.GoldRaw]);
    end
	if _Resources[ResourceType.Clay] ~= nil then
		AddClay(_PlayerID, _Resources[ResourceType.Clay] or _Resources[ResourceType.ClayRaw]);
	end
	if _Resources[ResourceType.Wood] ~= nil then
		AddWood(_PlayerID, _Resources[ResourceType.Wood] or _Resources[ResourceType.WoodRaw]);
	end
	if _Resources[ResourceType.Iron] ~= nil then		
		AddIron(_PlayerID, _Resources[ResourceType.Iron] or _Resources[ResourceType.IronRaw]);
	end
	if _Resources[ResourceType.Stone] ~= nil then		
		AddStone(_PlayerID, _Resources[ResourceType.Stone] or _Resources[ResourceType.StoneRaw]);
	end
    if _Resources[ResourceType.Sulfur] ~= nil then		
		AddSulfur(_PlayerID, _Resources[ResourceType.Sulfur] or _Resources[ResourceType.SulfurRaw]);
	end
end