--- author:???		current maintainer:mcb		v1
--
-- gibt die aktuelle gesundheit als prozentwert zurück.
--
--- @return number health
function GetHealth( _entity )
	local entityID = GetEntityId( _entity );
	if not Tools.IsEntityAlive( entityID ) then
		return 0;
	end
	local MaxHealth = Logic.GetEntityMaxHealth( entityID );
	local Health = Logic.GetEntityHealth( entityID );
	return ( Health / MaxHealth ) * 100;
end
