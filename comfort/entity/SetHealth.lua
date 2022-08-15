---
--- Changes the relative health of an entity.
--- @param _Entity  string|number Skriptname or ID of entity
--- @param _Percent number        Amount of health
--- @author totalwarANGEL
function SetHealth(_Entity, _Percent)
    local ID = GetID(_Entity);
    if Logic.IsBuilding(ID) == 0 and Logic.IsSettler(ID) == 0 then
        return;
    end
    local MaxHealth = Logic.GetEntityMaxHealth(ID);
    local CurrentHealth = Logic.GetEntityHealth(ID);
    local Percentage = math.abs(math.min(math.max(_Percent, 0), 100))/100;
    if (CurrentHealth/MaxHealth) > (Percentage*MaxHealth) then
        if (Percentage*MaxHealth) == 0 and Logic.IsLeader(ID) == 1 then
            local Soldiers = {Logic.GetSoldiersAttachedToLeader(ID)};
            for i= 2, Soldiers[1]+1, 1 do
                SetHealth(Soldiers[i], 0);
            end
        end
        Logic.HurtEntity(ID, (CurrentHealth/MaxHealth) - (Percentage*MaxHealth));
    elseif (CurrentHealth/MaxHealth) < (Percentage*MaxHealth) then
        Logic.HealEntity(ID, (CurrentHealth/MaxHealth) + (Percentage*MaxHealth));
    end
end