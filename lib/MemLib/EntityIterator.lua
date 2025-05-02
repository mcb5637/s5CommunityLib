--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.EntityIterator
-- author: RobbiTheFox, Fritz98, Kimichura
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
end
--------------------------------------------------------------------------------
MemLib.EntityIterator = {}
--------------------------------------------------------------------------------
---@param ... function|userdata
---@return table|function
function MemLib.EntityIterator.Iterator(...)

    local Logic_GetEntityScriptingValue = Logic.GetEntityScriptingValue
    local Logic_IsEntityDestroyed = Logic.IsEntityDestroyed
    local math_mod = math.mod
    local args = table.getn(arg)
    local MemLib_SV_AddressEntity = MemLib.SV.AddressEntity

    local address = MemLib.GetMemory(9008472)[0]:GetInt()

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()

    local offset = (address - MemLib.SV.AddressOffset + 24) / 4 + 2
    local entities = {}
    local bitMask = 2 ^ 30

    local offsets = {};
    table.setn(offsets, 65535)
    for i = 1, 65535 do
        offset = offset + 2
        offsets[i] = offset
    end

    MemLib.DisarmPreciseFPU()

    for i = 1, 65535 do
        local sv = Logic_GetEntityScriptingValue(MemLib_SV_AddressEntity, offsets[i])
        local entityId = math_mod(sv, bitMask)
        if entityId < 0 then
            entityId = entityId + bitMask
        end
        if not Logic_IsEntityDestroyed(entityId) then
            local meetsCriteria = true
            for j = 1, args do
                local filter = arg[j]
                if not filter(entityId) then
                    meetsCriteria = false
                    break
                end
            end
            if meetsCriteria then
                entities[entityId] = true
            end
        end
    end
    return entities
end
--------------------------------------------------------------------------------
-- true if distance <= range
--
-- use only with MemLib.EntityIterator.Iterator
---@param _X1 number
---@param _Y1 number
---@param _X2 number
---@param _Y2 number
---@return function|userdata
function MemLib.EntityIterator.InArea(_X1, _Y1, _X2, _Y2)
    _X1, _X2 = math.min(_X1, _X2), math.max(_X1, _X2)
    _Y1, _Y2 = math.min(_Y1, _Y2), math.max(_Y1, _Y2)
	return function(_EntityId)
		local x, y = Logic.EntityGetPos(_EntityId)
		return x >= _X1 and x <= _X2 and y >= _Y1 and y <= _Y2
	end
end
--------------------------------------------------------------------------------
-- true if distance < range
--
-- use only with MemLib.EntityIterator.Iterator
---@param _X number
---@param _Y number
---@param _R number
---@return function|userdata
function MemLib.EntityIterator.InCircle(_X, _Y, _R)
    return function(_EntityId)
        local x, y = Logic.GetEntityPosition(_EntityId)
        return (x - _X) ^ 2 + (y - _Y) ^ 2 < _R ^ 2
    end
end
--------------------------------------------------------------------------------
-- true if distance <= range
--
-- use only with MemLib.EntityIterator.Iterator
---@param _X number
---@param _Y number
---@param _R number
---@return function|userdata
function MemLib.EntityIterator.InRange(_X, _Y, _R)
    return function(_EntityId)
        local x, y = Logic.GetEntityPosition(_EntityId)
        return (x - _X) ^ 2 + (y - _Y) ^ 2 <= _R ^ 2
    end
end
--------------------------------------------------------------------------------
-- true if distance < range
--
-- use only with MemLib.EntityIterator.Iterator
---@param _X1 number
---@param _Y1 number
---@param _X2 number
---@param _Y2 number
---@return function|userdata
function MemLib.EntityIterator.InRectangle(_X1, _Y1, _X2, _Y2)
    _X1, _X2 = math.min(_X1, _X2), math.max(_X1, _X2)
    _Y1, _Y2 = math.min(_Y1, _Y2), math.max(_Y1, _Y2)
	return function(_EntityId)
		local x, y = Logic.EntityGetPos(_EntityId)
		return x > _X1 and x < _X2 and y > _Y1 and y < _Y2
	end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _Sector integer
---@return function|userdata
function MemLib.EntityIterator.InSector(_Sector)
    return function(_EntityId)
        return Logic.GetSector(_EntityId) == _Sector
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@return function|userdata
function MemLib.EntityIterator.IsBuilding()
    return function(_EntityId)
        return Logic.IsBuilding(_EntityId) == 1
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@return function|userdata
function MemLib.EntityIterator.IsNotSoldier()
    return function(_EntityId)
        return Logic.IsEntityInCategory(_EntityId, EntityCategories.Soldier) ~= 1
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@return function|userdata
function MemLib.EntityIterator.IsSettler()
    return function(_EntityId)
        return Logic.IsSettler(_EntityId) == 1
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@return function|userdata
function MemLib.EntityIterator.IsSettlerOrBuilding()
    return function(_EntityId)
        return Logic.IsSettler(_EntityId) == 1 or Logic.IsBuilding(_EntityId) == 1
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _Player integer
---@return function|userdata
function MemLib.EntityIterator.NotOfPlayer(_Player)
    return function(_EntityId)
        return Logic.EntityGetPlayer(_EntityId) ~= _Player
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@return function|userdata
function MemLib.EntityIterator.NotOfPlayer0()
    return function(_EntityId)
        return Logic.EntityGetPlayer(_EntityId) ~= 0
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param ... integer
---@return function|userdata
function MemLib.EntityIterator.OfAnyCategory(...)
    return function(_EntityId)
        for i = 1, table.getn(arg) do
            if Logic.IsEntityInCategory(_EntityId, arg[i]) == 1 then
                return true
            end
        end
        return false
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param ... integer
---@return function|userdata
function MemLib.EntityIterator.OfAnyClass(...)
    return function(_EntityId)
        local entityClass = MemLib.Entity.GetMemory(_EntityId)[0]:GetInt()
        for i = 1, table.getn(arg) do
            if entityClass == arg[i] then
                return true
            end
        end
        return false
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param ... integer
---@return function|userdata
function MemLib.EntityIterator.OfAnyPlayer(...)
    return function(_EntityId)
        for i = 1, table.getn(arg) do
            if Logic.EntityGetPlayer(_EntityId) == arg[i] then
                return true
            end
        end
        return false
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param ... integer
---@return function|userdata
function MemLib.EntityIterator.OfAnyType(...)
    return function(_EntityId)
        for i = 1, table.getn(arg) do
            if Logic.GetEntityType(_EntityId) == arg[i] then
                return true
            end
        end
        return false
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param ... integer
---@return function|userdata
function MemLib.EntityIterator.OfAnyUpgradeCategory(...)
    return function(_EntityId)
        if Logic.IsBuilding(_EntityId) == 1 then
            for i = 1, table.getn(arg) do
                if Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(_EntityId)) == arg[i] then
                    return true
                end
            end
        elseif Logic.IsSettler(_EntityId) == 1 then
            for i = 1, table.getn(arg) do
                if MemLib.SettlerType.GetUpgradeCategory(Logic.GetEntityType(_EntityId)) == arg[i] then
                    return true
                end
            end
        end
        return false
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _EntityCategory integer
---@return function|userdata
function MemLib.EntityIterator.OfCategory(_EntityCategory)
    return function(_EntityId)
        return Logic.IsEntityInCategory(_EntityId, _EntityCategory) == 1
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _EntityClass integer
---@return function|userdata
function MemLib.EntityIterator.OfClass(_EntityClass)
    return function(_EntityId)
        return MemLib.Entity.GetMemory(_EntityId)[0]:GetInt() == _EntityClass
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _Player integer
---@return function|userdata
function MemLib.EntityIterator.OfPlayer(_Player)
    return function(_EntityId)
        return Logic.EntityGetPlayer(_EntityId) == _Player
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _EntityType integer
---@return function|userdata
function MemLib.EntityIterator.OfType(_EntityType)
    return function(_EntityId)
        return Logic.GetEntityType(_EntityId) == _EntityType
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _UpgradeCategory integer
---@return function|userdata
function MemLib.EntityIterator.OfUpgradeCategory(_UpgradeCategory)
    return function(_EntityId)
        if Logic.IsBuilding(_EntityId) == 1 then
            return Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(_EntityId)) == _UpgradeCategory
        elseif Logic.IsSettler(_EntityId) == 1 then
            return MemLib.SettlerType.GetUpgradeCategory(Logic.GetEntityType(_EntityId)) == _UpgradeCategory
        end
        return false
    end
end
--------------------------------------------------------------------------------
-- use only with MemLib.EntityIterator.Iterator
---@param _ResourceType integer
---@return function|userdata
function MemLib.EntityIterator.ProvidesResource(_ResourceType)
    return function(_EntityId)
        return Logic.GetResourceDoodadGoodType(_EntityId) == _ResourceType
    end
end
--------------------------------------------------------------------------------
-- CEntityIterator exists
--------------------------------------------------------------------------------
if CEntityIterator then

    ---@param ... function|userdata
    ---@return table|function
    function MemLib.EntityIterator.Iterator(...)

        local nativePredicates = {}
        local customPredicates = {}
        local areAllPredicatesNative = true

        for i = 1,table.getn(arg) do
            if type(arg[i]) == "function" then
                table.insert(customPredicates, arg[i])
                areAllPredicatesNative = false
            else
                table.insert(nativePredicates, arg[i])
            end
        end

        local iterator = CEntityIterator.Iterator(unpack(nativePredicates))

        if areAllPredicatesNative then
            return iterator
        end

        return function()

            local entity = iterator()

            while entity ~= nil do
                local meetsCriteria = true
                for i = 1,table.getn(customPredicates) do
                    if not customPredicates[i](entity) then
                        meetsCriteria = false
                        break
                    end
                end

                if meetsCriteria then
                    return entity
                end

                entity = iterator()
            end

            return entity
        end
    end
    --------------------------------------------------------------------------------
    ---@param _X number
    ---@param _Y number
    ---@param _R number
    ---@return function|userdata
    function MemLib.EntityIterator.InCircle(_X, _Y, _R)
        return CEntityIterator.InCircleFilter(_X, _Y, _R)
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    ---@param _X number
    ---@param _Y number
    ---@param _R number
    function MemLib.EntityIterator.InRange(_X, _Y, _R)
        return CEntityIterator.InRangeFilter(_X, _Y, _R)
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsBuilding()
        return CEntityIterator.IsBuildingFilter()
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsNotSoldier()
        return CEntityIterator.IsNotSoldierFilter()
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsSettler()
        return CEntityIterator.IsSettlerFilter()
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsSettlerOrBuilding()
        return CEntityIterator.IsSettlerOrBuildingFilter()
    end
    --------------------------------------------------------------------------------
    ---@param _Player integer
    ---@return function|userdata
    function MemLib.EntityIterator.NotOfPlayer(_Player)
        return CEntityIterator.NotOfPlayerFilter(_Player)
    end
    --------------------------------------------------------------------------------
    ---@param ... integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfAnyCategory(...)
        return CEntityIterator.OfAnyCategoryFilter(unpack(arg))
    end
    --------------------------------------------------------------------------------
    ---@param ... integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfAnyPlayer(...)
        return CEntityIterator.OfAnyPlayerFilter(unpack(arg))
    end
    --------------------------------------------------------------------------------
    ---@param ... integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfAnyType(...)
        return CEntityIterator.OfAnyTypeFilter(unpack(arg))
    end
    --------------------------------------------------------------------------------
    ---@param _EntityCategory integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfCategory(_EntityCategory)
        return CEntityIterator.OfCategoryFilter(_EntityCategory)
    end
    --------------------------------------------------------------------------------
    ---@param _EntityClass integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfClass(_EntityClass)
        return CEntityIterator.OfClassFilter(_EntityClass)
    end
    --------------------------------------------------------------------------------
    ---@param _Player integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfPlayer(_Player)
        return CEntityIterator.OfPlayerFilter(_Player)
    end
    --------------------------------------------------------------------------------
    ---@param _EntityType integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfType(_EntityType)
        return CEntityIterator.OfTypeFilter(_EntityType)
    end

--------------------------------------------------------------------------------
-- S5Hook.EntityIterator exists
--------------------------------------------------------------------------------
elseif S5Hook and Predicate then

    ---@param ... function|userdata
    ---@return table|function
    function MemLib.EntityIterator.Iterator(...)

        local nativePredicates = {}
        local customPredicates = {}
        local areAllPredicatesNative = true

        for i = 1,table.getn(arg) do
            if type(arg[i]) == "function" then
                table.insert(customPredicates, arg[i])
                areAllPredicatesNative = false
            else
                table.insert(nativePredicates, arg[i])
            end
        end

        local iterator = S5Hook.EntityIterator(unpack(nativePredicates))

        if areAllPredicatesNative then
            return iterator
        end

        return function()

            local entity = iterator()

            while entity ~= nil do
                local meetsCriteria = true
                for i = 1,table.getn(customPredicates) do
                    if not customPredicates[i](entity) then
                        meetsCriteria = false
                        break
                    end
                end

                if meetsCriteria then
                    return entity
                end

                entity = iterator()
            end

            return entity
        end
    end
    --------------------------------------------------------------------------------
    ---@param _X number
    ---@param _Y number
    ---@param _R number
    ---@return function|userdata
    function MemLib.EntityIterator.InCircle(_X, _Y, _R)
        return Predicate.InCircle(_X, _Y, _R)
    end
    --------------------------------------------------------------------------------
    ---@param _X1 number
    ---@param _Y1 number
    ---@param _X2 number
    ---@param _Y2 number
    ---@return function|userdata
    function MemLib.EntityIterator.InRectangle(_X1, _Y1, _X2, _Y2)
        return Predicate.InRect(_X1, _Y1, _X2, _Y2)
    end
    --------------------------------------------------------------------------------
    ---@param _Sector integer
    ---@return function|userdata
    function MemLib.EntityIterator.InSector(_Sector)
        return Predicate.InCircle(_Sector)
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsBuilding()
        return Predicate.IsBuilding()
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsNotSoldier()
        return Predicate.IsNotSoldier()
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsSettler()
        return Predicate.IsSettler()
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.IsSettlerOrBuilding()
        return Predicate.IsSettlerOrBuilding()
    end
    --------------------------------------------------------------------------------
    ---@return function|userdata
    function MemLib.EntityIterator.NotOfPlayer0()
        return Predicate.NotOfPlayer0()
    end
    --------------------------------------------------------------------------------
    ---@param ... integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfAnyPlayer(...)
        return Predicate.OfAnyPlayer(unpack(arg))
    end
    --------------------------------------------------------------------------------
    ---@param ... integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfAnyType(...)
        return Predicate.OfAnyType(unpack(arg))
    end
    --------------------------------------------------------------------------------
    ---@param _EntityCategory integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfCategory(_EntityCategory)
        return Predicate.OfCategory(_EntityCategory)
    end
    --------------------------------------------------------------------------------
    ---@param _Player integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfPlayer(_Player)
        return Predicate.OfPlayer(_Player)
    end
    --------------------------------------------------------------------------------
    ---@param _EntityType integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfType(_EntityType)
        return Predicate.OfType(_EntityType)
    end
    --------------------------------------------------------------------------------
    ---@param _UpgradeCategory integer
    ---@return function|userdata
    function MemLib.EntityIterator.OfUpgradeCategory(_UpgradeCategory)
        return Predicate.OfUpgradeCategory(_UpgradeCategory)
    end
    --------------------------------------------------------------------------------
    ---@param _ResourceType integer
    ---@return function|userdata
    function MemLib.EntityIterator.ProvidesResource(_ResourceType)
        return Predicate.ProvidesResource(_ResourceType)
    end

else

    if mcbPacker then
        mcbPacker.require("s5CommunityLib/Lib/MemLib/SV")
        mcbPacker.require("s5CommunityLib/Lib/MemLib/Entity")
        mcbPacker.require("s5CommunityLib/Lib/MemLib/SettlerType")
    else
        if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
        MemLib.Load("SV", "Entity", "SettlerType")
    end

end