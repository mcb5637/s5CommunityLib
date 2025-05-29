--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Logic
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Comfort/Table/Table")
    mcbPacker.require("s5CommunityLib/Tables/ArmorClasses")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Comfort/Table/Table", "Tables/ArmorClasses")
end
--------------------------------------------------------------------------------
MemLib.Logic = {}
--------------------------------------------------------------------------------
---@return userdata|table
function MemLib.Logic.CLogicPropertiesGetMemory()
    return MemLib.GetMemory(MemLib.Offsets.CLogicProperties.GlobalObject)[0]
end
--------------------------------------------------------------------------------
---@return userdata|table
function MemLib.Logic.CPlayerAttractionPropsGetMemory()
    return MemLib.GetMemory(MemLib.Offsets.CPlayerAttractionProps.GlobalObject)[0]
end
--------------------------------------------------------------------------------
-- TODO: find DamageClassesHolder`s global object
if MemLib.Offsets.DamageClassesHolder.GlobalObject then

    --------------------------------------------------------------------------------
    ---@return userdata|table
    function MemLib.Internal.GetDamageClassVectorMemory()
        return MemLib.GetMemory(MemLib.Offsets.CMain.GlobalObject)[0][MemLib.Offsets.CMain.CGLUEPropsMgr][5][MemLib.Offsets.CDamageClassesPropsMgr.VectorStart]
    end

else

    --------------------------------------------------------------------------------
    ---@return userdata|table
    function MemLib.Internal.GetDamageClassVectorMemory()
        return MemLib.GetMemory(MemLib.Offsets.DamageClassesHolder.GlobalObject)[0][MemLib.Offsets.DamageClassesHolder.VectorStart]
    end

end
--------------------------------------------------------------------------------
---@return integer WorkTimeBase
---@return integer WorkTimeThresholdWork
function MemLib.Logic.GetWorkTimeThresholds()
	local logicproperties = MemLib.Logic.CLogicPropertiesGetMemory()
	return logicproperties[MemLib.Offsets.CLogicProperties.WorkTimeBase]:GetInt(), logicproperties[MemLib.Offsets.CLogicProperties.WorkTimeThresholdWork]:GetInt()
end
--------------------------------------------------------------------------------
---@param _TaxLevel integer
---@return integer
function MemLib.Logic.TaxLevelGetIncomePerWorker(_TaxLevel)
    assert(type(_TaxLevel) == "number" and _TaxLevel >= 0 and _TaxLevel <= 4, "MemLib.Logic.TaxLevelGetIncomePerWorker: _TaxLevel must be >= 0 and <= 4")
	return MemLib.Logic.CLogicPropertiesGetMemory()[MemLib.Offsets.CLogicProperties.STaxationLevelVectorStart][_TaxLevel * 3 + 1]:GetInt()
end
--------------------------------------------------------------------------------
---@param _TaxLevel integer
---@param _Income integer
function MemLib.Logic.TaxLevelSetIncomePerWorker(_TaxLevel, _Income)
    assert(type(_TaxLevel) == "number" and _TaxLevel >= 0 and _TaxLevel <= 4, "MemLib.Logic.TaxLevelSetIncomePerWorker: _TaxLevel must be >= 0 and <= 4")
    assert(type(_Income) == "number", "MemLib.Logic.TaxLevelSetIncomePerWorker: _Income invalid")
	MemLib.Logic.CLogicPropertiesGetMemory()[MemLib.Offsets.CLogicProperties.STaxationLevelVectorStart][_TaxLevel * 3 + 1]:SetInt(_Income)
end
--------------------------------------------------------------------------------
---@param _TaxLevel integer
---@return integer
function MemLib.Logic.TaxLevelGetMotivationEffect(_TaxLevel)
    assert(type(_TaxLevel) == "number" and _TaxLevel >= 0 and _TaxLevel <= 4, "MemLib.Logic.TaxLevelGetMotivationEffect: _TaxLevel must be >= 0 and <= 4")
	return MemLib.Logic.CLogicPropertiesGetMemory()[MemLib.Offsets.CLogicProperties.STaxationLevelVectorStart][_TaxLevel * 3 + 2]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _TaxLevel integer
---@param _Motivation number
function MemLib.Logic.TaxLevelSetMotivationEffect(_TaxLevel, _Motivation)
    assert(type(_TaxLevel) == "number" and _TaxLevel >= 0 and _TaxLevel <= 4, "MemLib.Logic.TaxLevelSetMotivationEffect: _TaxLevel must be >= 0 and <= 4")
    assert(type(_Motivation) == "number", "MemLib.Logic.TaxLevelSetMotivationEffect: _Motivation invalid")
	MemLib.Logic.CLogicPropertiesGetMemory()[MemLib.Offsets.CLogicProperties.STaxationLevelVectorStart][_TaxLevel * 3 + 2]:SetFloat(_Motivation)
end
--------------------------------------------------------------------------------
---@return number
function MemLib.Logic.GetMaxDistanceWorkplaceToFarm()
	return MemLib.Logic.CPlayerAttractionPropsGetMemory()[MemLib.Offsets.CPlayerAttractionProps.DistanceWorkplaceFarm]:GetFloat()
end
--------------------------------------------------------------------------------
---@return number
function MemLib.Logic.GetMaxDistanceWorkplaceToResidence()
	return MemLib.Logic.CPlayerAttractionPropsGetMemory()[MemLib.Offsets.CPlayerAttractionProps.DistanceWorkplaceResidence]:GetFloat()
end
--------------------------------------------------------------------------------
if CInterface and CInterface.Logic then

    --------------------------------------------------------------------------------
    ---@param _DamageClass integer
    ---@param _ArmorClass integer
    ---@return number
    function MemLib.Logic.DamageClassGetArmorClassFactor(_DamageClass, _ArmorClass)
        assert(table.find(DamageClasses, _DamageClass), "MemLib.Logic.DamageClassSetArmorClassFactor: _DamageClass invalid")
        assert(table.find(ArmorClasses, _ArmorClass), "MemLib.Logic.DamageClassSetArmorClassFactor: _ArmorClass invalid")
        return CInterface.Logic.GetDamageFactorForDamageClassAndArmorClass(_DamageClass, _ArmorClass)
    end

elseif CppLogic then

    --------------------------------------------------------------------------------
    ---@param _DamageClass integer
    ---@param _ArmorClass integer
    ---@return number
    function MemLib.Logic.DamageClassGetArmorClassFactor(_DamageClass, _ArmorClass)
        return CppLogic.Logic.GetDamageFactor(_DamageClass, _ArmorClass)
    end

else

    --------------------------------------------------------------------------------
    ---@param _DamageClass integer
    ---@param _ArmorClass integer
    ---@return number
    function MemLib.Logic.DamageClassGetArmorClassFactor(_DamageClass, _ArmorClass)
        assert(table.find(DamageClasses, _DamageClass), "MemLib.Logic.DamageClassSetArmorClassFactor: _DamageClass invalid")
        assert(table.find(ArmorClasses, _ArmorClass), "MemLib.Logic.DamageClassSetArmorClassFactor: _ArmorClass invalid")
        return MemLib.Internal.GetDamageClassVectorMemory()[_DamageClass][_ArmorClass]:GetFloat()
    end

end

if CppLogic then

    --------------------------------------------------------------------------------
    ---@param _DamageClass integer
    ---@param _ArmorClass integer
    ---@param _Factor number
    function MemLib.Logic.DamageClassSetArmorClassFactor(_DamageClass, _ArmorClass, _Factor)
        CppLogic.Logic.SetDamageFactor(_DamageClass, _ArmorClass, _Factor)
    end

else

    --------------------------------------------------------------------------------
    ---@param _DamageClass integer
    ---@param _ArmorClass integer
    ---@param _Factor number
    function MemLib.Logic.DamageClassSetArmorClassFactor(_DamageClass, _ArmorClass, _Factor)
        assert(table.find(DamageClasses, _DamageClass), "MemLib.Logic.DamageClassSetArmorClassFactor: _DamageClass invalid")
        assert(table.find(ArmorClasses, _ArmorClass), "MemLib.Logic.DamageClassSetArmorClassFactor: _ArmorClass invalid")
        assert(type(_Factor) == "number" and _Factor >= 0, "MemLib.Logic.DamageClassSetArmorClassFactor: _Factor invalid")
        MemLib.Internal.GetDamageClassVectorMemory()[_DamageClass][_ArmorClass]:SetFloat(_Factor)
    end

end