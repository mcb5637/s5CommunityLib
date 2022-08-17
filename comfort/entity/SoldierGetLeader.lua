if mcbPacker then --mcbPacker.ignore
    mcbPacker.require("s5CommunityLib/comfort/entity/SVLib")
end --mcbPacker.ignore

---
--- Returns the leader entity ID of the soldier.
--- @param _Soldier number Entity ID of soldier
--- @return number Entity ID of leader
--- @within Entities
--- @author totalwarANGEL
function SoldierGetLeader(_Soldier)
    if Logic.IsEntityInCategory(_Soldier, EntityCategories.Soldier) == 1 then
        return SVLib.GetLeaderOfSoldier(GetID(_Soldier));
    end
    return GetID(_Soldier);
end