--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Building
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Entity")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Technology")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Entity", "Technology")
end
--------------------------------------------------------------------------------
MemLib.Building = {}
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@return userdata|table
function MemLib.Building.GetMemory(_BuildingId)
    assert(MemLib.Building.IsValid(_BuildingId), "MemLib.Building.GetMemory: _BuildingId invalid")
    return MemLib.Entity.GetMemory(_BuildingId)
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@return boolean
function MemLib.Building.IsValid(_BuildingId)
    return MemLib.Entity.IsValid(_BuildingId) and Logic.IsBuilding(_BuildingId) == 1
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@return integer
function MemLib.Building.GetMaxNumWorkers(_BuildingId)
	return MemLib.Building.GetMemory(_BuildingId)[72]:GetInt()
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@param _Amount integer
function MemLib.Building.SetMaxNumWorkers(_BuildingId, _Amount)
    assert(type(_Amount) == "number" and _Amount >= 0, "MemLib.Building.SetMaxNumWorkers: _Amount invalid")
	MemLib.Building.GetMemory(_BuildingId)[72]:SetInt(_Amount)
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@return number
function MemLib.Building.GetConstructionProgress(_BuildingId)
    return MemLib.Building.GetMemory(_BuildingId)[76]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@param _Progress number
function MemLib.Building.SetConstructionProgress(_BuildingId, _Progress)
    assert(type(_Progress) == "number" and _Progress >= 0 and _Progress <= 1, "MemLib.Building.SetConstructionProgress: _Progress must be >= 0 and <= 1")
    MemLib.Building.GetMemory(_BuildingId)[76]:SetFloat(_Progress)
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@param _Progress number
function MemLib.Building.AddConstructionProgress(_BuildingId, _Progress)
    MemLib.Building.SetConstructionProgress(_BuildingId, MemLib.Building.GetConstructionProgress(_BuildingId) + _Progress)
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@return number
function MemLib.Building.GetRepairProgress(_BuildingId)
    return MemLib.Building.GetMemory(_BuildingId)[77]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@param _Progress number
function MemLib.Building.SetRepairProgress(_BuildingId, _Progress)
    assert(type(_Progress) == "number" and _Progress >= 0 and _Progress <= 1, "MemLib.Building.SetRepairProgress: _Progress must be >= 0 and <= 1")
    MemLib.Building.GetMemory(_BuildingId)[77]:SetFloat(_Progress)
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@param _Progress number
function MemLib.Building.AddRepairProgress(_BuildingId, _Progress)
    MemLib.Building.SetRepairProgress(_BuildingId, MemLib.Building.GetRepairProgress(_BuildingId) + _Progress)
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@return number
function MemLib.Building.GetUpgradeProgress(_BuildingId)
	return MemLib.Building.GetMemory(_BuildingId)[78]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@param _Progress number
function MemLib.Building.SetUpgradeProgress(_BuildingId, _Progress)
    assert(type(_Progress) == "number" and _Progress >= 0 and _Progress <= 1, "MemLib.Building.SetUpgradeProgress: _Progress must be >= 0 and <= 1")
    MemLib.Building.GetMemory(_BuildingId)[78]:SetFloat(_Progress)
end
--------------------------------------------------------------------------------
---@param _BuildingId integer
---@param _Progress number
function MemLib.Building.AddUpgradeProgress(_BuildingId, _Progress)
    MemLib.Building.SetUpgradeProgress(_BuildingId, MemLib.Building.GetUpgradeProgress(_BuildingId) + _Progress)
end
--------------------------------------------------------------------------------
if CEntity then

    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@return integer
    function MemLib.Building.GetTechnologyInResearch(_BuildingId)
        assert(MemLib.Building.IsValid(_BuildingId))
        return CEntity.GetTechnologyInResearch(_BuildingId)
    end
    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@param _Technology integer
    function MemLib.Building.SetTechnologyInResearch(_BuildingId, _Technology)
        assert(MemLib.Building.IsValid(_BuildingId))
        assert(MemLib.Technology.IsValid(_Technology))
        CEntity.SetTechnologyInResearch(_BuildingId, _Technology)
    end
    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@return integer BuyResourceType
    ---@return integer BuyResourceAmount
    ---@return integer SellResourceType
    ---@return integer SellResourceAmount
    function MemLib.Building.MarketGetCurrentTradeInfo(_BuildingId)
        assert(MemLib.Building.IsValid(_BuildingId))
        return CEntity.GetMarketInformation(_BuildingId)
    end

else

    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@return integer
    function MemLib.Building.GetTechnologyInResearch(_BuildingId)
        return MemLib.Building.GetMemory(_BuildingId)[73]:GetInt()
    end
    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@param _Technology integer
    function MemLib.Building.SetTechnologyInResearch(_BuildingId, _Technology)
        assert(MemLib.Technology.IsValid(_Technology))
        MemLib.Building.GetMemory(_BuildingId)[73]:SetInt(_Technology)
    end
    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@return integer BuyResourceType
    ---@return integer BuyResourceAmount
    ---@return integer SellResourceType
    ---@return integer SellResourceAmount
    function MemLib.Building.MarketGetCurrentTradeInfo(_BuildingId)
        local marketBehaviorMemory = MemLib.Entity.BehaviorGetMemory(_BuildingId, Behaviors.CMarketBehavior)
        if marketBehaviorMemory then
            return marketBehaviorMemory[6]:GetInt(), marketBehaviorMemory[7]:GetFloat(), marketBehaviorMemory[5]:GetInt(), marketBehaviorMemory[8]:GetFloat()
        end
        return 0, 0, 0, 0
    end

end
--------------------------------------------------------------------------------
if CppLogic then

    --------------------------------------------------------------------------------
    ---@param _ConstructionSiteId integer
    ---@return integer
    function MemLib.Building.ConstructionSiteGetBuilding(_ConstructionSiteId)
        return CppLogic.Entity.Building.ConstructionSiteGetBuilding(_ConstructionSiteId)
    end
    --------------------------------------------------------------------------------
    ---@param _ConstructionSiteId integer
    ---@return integer
    function MemLib.Building.GetConstructionSite(_ConstructionSiteId)
        return CppLogic.Entity.Building.GetConstructionSite(_ConstructionSiteId)
    end
    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@return number AproachX
    ---@return number AproachY
    ---@return number DoorX
    ---@return number DoorY
    ---@return number LeaveX
    ---@return number LeaveY
    function MemLib.Building.GetAproachAndDoorPosition(_BuildingId)
        local a, l, d = CppLogic.Entity.Building.GetRelativePositions(_BuildingId)
        return a.X, a.Y, d.X, d.Y, l.X, l.Y
    end
else

    --------------------------------------------------------------------------------
    ---@param _ConstructionSiteId integer
    ---@return integer
    function MemLib.Building.ConstructionSiteGetBuilding(_ConstructionSiteId)
        assert(MemLib.Entity.GetClass(_ConstructionSiteId) == EntityClasses.CConstructionSite, "MemLib.Building.ConstructionSiteGetBuilding: _ConstructionSiteId invalid")
        -- if this line raises an error, something is REALLY WRONG!
        return MemLib.Entity.GetReversedAttachedEntities(_ConstructionSiteId)[20][1]
    end
    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@return integer
    function MemLib.Building.GetConstructionSite(_BuildingId)
        assert(MemLib.Entity.GetClass(_BuildingId) == EntityClasses.CConstructionSite, "MemLib.Building.ConstructionSiteGetBuilding: _ConstructionSiteId invalid")
        if MemLib.Building.GetConstructionProgress(_BuildingId) then
            return MemLib.Entity.GetAttachedEntities(_BuildingId)[20][1]
        end
        return 0
    end
    --------------------------------------------------------------------------------
    ---@param _BuildingId integer
    ---@return number AproachX
    ---@return number AproachY
    ---@return number DoorX
    ---@return number DoorY
    ---@return number LeaveX
    ---@return number LeaveY
    function MemLib.Building.GetAproachAndDoorPosition(_BuildingId)
        local x, y = Logic.GetEntityPosition(_BuildingId)
        local xa, ya, xd, yd, lx, ly = MemLib.BuildingType.GetAproachDoorAndLeavePosition(Logic.GetEntityType(_BuildingId))
        return x + xa, y + ya, x + xd, y + yd, x + lx, y + ly
    end

end