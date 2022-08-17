---
--- Checks the area for entities of an enemy player.
--- @param _player   number Player ID
--- @param _position table  Area center
--- @param _range    number Area size
--- @return boolean EnemiesNear Enemies near
--- @author ???
function AreEnemiesInArea( _player, _position, _range)
    return AreEntitiesOfDiplomacyStateInArea(_player, _position, _range, Diplomacy.Hostile);
end

---
--- Checks the area for entities of an allied player.
--- @param _player   number Player ID
--- @param _position table  Area center
--- @param _range    number Area size
--- @return boolean EnemiesNear Allies near
--- @author ???
function AreAlliesInArea( _player, _position, _range)
    return AreEntitiesOfDiplomacyStateInArea(_player, _position, _range, Diplomacy.Friendly);
end

---
--- Checks the area for entities of other parties with a diplomatic state to
--- the player.
--- @param _player   number Player ID
--- @param _Position table  Area center
--- @param _range    number Area size
--- @param _state    number Diplomatic state
--- @return boolean EntitiesNear Entities near
--- @author ???
function AreEntitiesOfDiplomacyStateInArea(_player, _Position, _range, _state)
	local Position = _Position;
    if type(Position) ~= "table" then
        Position = GetPosition(Position);
    end
    for i = 1, 8 do
        if i ~= _player and Logic.GetDiplomacyState(_player, i) == _state then
            if Logic.IsPlayerEntityOfCategoryInArea(i, Position.X, Position.Y, _range, "DefendableBuilding", "Military", "MilitaryBuilding") == 1 then
                return true;
            end
        end
	end
	return false;
end